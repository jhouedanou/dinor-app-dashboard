<?php

namespace App\Jobs;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\Leaderboard;
use App\Models\TournamentLeaderboard;
use App\Services\OneSignalService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class CalculatePredictionPointsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $match;
    protected $notifyUsers;

    /**
     * Create a new job instance.
     */
    public function __construct(FootballMatch $match, bool $notifyUsers = true)
    {
        $this->match = $match;
        $this->notifyUsers = $notifyUsers;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            Log::info('Job CalculatePredictionPoints démarré', [
                'match_id' => $this->match->id,
                'home_score' => $this->match->home_score,
                'away_score' => $this->match->away_score,
                'status' => $this->match->status
            ]);

            // Vérifier que le match est terminé et a un score
            if (!$this->match->is_finished || 
                $this->match->home_score === null || 
                $this->match->away_score === null) {
                
                Log::warning('Match non terminé ou sans score, report du calcul', [
                    'match_id' => $this->match->id,
                    'is_finished' => $this->match->is_finished,
                    'home_score' => $this->match->home_score,
                    'away_score' => $this->match->away_score
                ]);

                // Reporter le job de 30 minutes
                self::dispatch($this->match, $this->notifyUsers)
                    ->delay(now()->addMinutes(30));
                    
                return;
            }

            DB::beginTransaction();

            // Récupérer toutes les prédictions pour ce match
            $predictions = Prediction::where('football_match_id', $this->match->id)
                ->where('is_calculated', false)
                ->with(['user'])
                ->get();

            $calculatedCount = 0;
            $userPointsUpdates = [];

            foreach ($predictions as $prediction) {
                $points = $this->calculatePredictionPoints($prediction);
                
                // Mettre à jour la prédiction
                $prediction->update([
                    'points_earned' => $points,
                    'is_calculated' => true
                ]);

                $calculatedCount++;
                
                // Collecter les mises à jour de points pour les utilisateurs
                if (!isset($userPointsUpdates[$prediction->user_id])) {
                    $userPointsUpdates[$prediction->user_id] = [
                        'user' => $prediction->user,
                        'points' => 0,
                        'predictions' => []
                    ];
                }
                
                $userPointsUpdates[$prediction->user_id]['points'] += $points;
                $userPointsUpdates[$prediction->user_id]['predictions'][] = $prediction;
            }

            // Mettre à jour les leaderboards
            $this->updateLeaderboards($userPointsUpdates);

            DB::commit();

            Log::info('Points calculés avec succès', [
                'match_id' => $this->match->id,
                'predictions_calculated' => $calculatedCount,
                'users_affected' => count($userPointsUpdates)
            ]);

            // Envoyer des notifications aux utilisateurs
            if ($this->notifyUsers && !empty($userPointsUpdates)) {
                $this->sendPointsNotifications($userPointsUpdates);
            }

            // Invalider les caches
            $this->invalidateRelatedCaches();

        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Erreur lors du calcul des points', [
                'match_id' => $this->match->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            throw $e;
        }
    }

    /**
     * Calculate points for a specific prediction
     */
    private function calculatePredictionPoints(Prediction $prediction): int
    {
        $points = 0;
        $actualWinner = $this->match->winner;
        
        // Score exact
        $exactScore = ($prediction->predicted_home_score == $this->match->home_score && 
                      $prediction->predicted_away_score == $this->match->away_score);
        
        // Bon vainqueur
        $correctWinner = ($prediction->predicted_winner == $actualWinner);

        if ($exactScore) {
            // Score exact = 3 points (même si le vainqueur est incorrect, ce qui ne devrait pas arriver)
            $points = 3;
        } elseif ($correctWinner) {
            // Bon vainqueur seulement = 1 point
            $points = 1;
        }
        // Sinon 0 point

        Log::debug('Points calculés pour une prédiction', [
            'prediction_id' => $prediction->id,
            'user_id' => $prediction->user_id,
            'predicted_score' => "{$prediction->predicted_home_score}-{$prediction->predicted_away_score}",
            'actual_score' => "{$this->match->home_score}-{$this->match->away_score}",
            'predicted_winner' => $prediction->predicted_winner,
            'actual_winner' => $actualWinner,
            'exact_score' => $exactScore,
            'correct_winner' => $correctWinner,
            'points_earned' => $points
        ]);

        return $points;
    }

    /**
     * Update global and tournament leaderboards
     */
    private function updateLeaderboards(array $userPointsUpdates): void
    {
        foreach ($userPointsUpdates as $userId => $data) {
            // Mettre à jour le leaderboard global
            $this->updateGlobalLeaderboard($userId, $data['points']);
            
            // Mettre à jour le leaderboard du tournoi si applicable
            if ($this->match->tournament_id) {
                $this->updateTournamentLeaderboard($userId, $data['points']);
            }
        }
    }

    /**
     * Update global leaderboard for a user
     */
    private function updateGlobalLeaderboard(int $userId, int $newPoints): void
    {
        // Récupérer ou créer l'entrée du leaderboard
        $leaderboard = Leaderboard::firstOrNew(['user_id' => $userId]);
        
        // Calculer les nouvelles statistiques
        $userPredictions = Prediction::where('user_id', $userId)
            ->where('is_calculated', true)
            ->get();

        $totalPoints = $userPredictions->sum('points_earned');
        $totalPredictions = $userPredictions->count();
        $correctScores = $userPredictions->where('points_earned', 3)->count();
        $correctWinners = $userPredictions->where('points_earned', '>', 0)->count();
        $accuracy = $totalPredictions > 0 ? round(($correctWinners / $totalPredictions) * 100, 2) : 0;

        $leaderboard->fill([
            'total_points' => $totalPoints,
            'total_predictions' => $totalPredictions,
            'correct_scores' => $correctScores,
            'correct_winners' => $correctWinners,
            'accuracy_percentage' => $accuracy,
            'last_updated' => now()
        ]);

        $leaderboard->save();
    }

    /**
     * Update tournament leaderboard for a user
     */
    private function updateTournamentLeaderboard(int $userId, int $newPoints): void
    {
        $tournamentLeaderboard = TournamentLeaderboard::firstOrNew([
            'tournament_id' => $this->match->tournament_id,
            'user_id' => $userId
        ]);

        // Calculer les statistiques du tournoi
        $tournamentPredictions = Prediction::whereHas('footballMatch', function ($query) {
                $query->where('tournament_id', $this->match->tournament_id);
            })
            ->where('user_id', $userId)
            ->where('is_calculated', true)
            ->get();

        $totalPoints = $tournamentPredictions->sum('points_earned');
        $totalPredictions = $tournamentPredictions->count();
        $correctPredictions = $tournamentPredictions->where('points_earned', '>', 0)->count();
        $accuracy = $totalPredictions > 0 ? round(($correctPredictions / $totalPredictions) * 100, 1) : 0;

        $tournamentLeaderboard->fill([
            'total_points' => $totalPoints,
            'total_predictions' => $totalPredictions,
            'correct_predictions' => $correctPredictions,
            'accuracy' => $accuracy,
            'last_updated' => now()
        ]);

        $tournamentLeaderboard->save();
    }

    /**
     * Send notifications to users about their points
     */
    private function sendPointsNotifications(array $userPointsUpdates): void
    {
        try {
            $homeTeam = $this->match->homeTeam->short_name ?? $this->match->homeTeam->name;
            $awayTeam = $this->match->awayTeam->short_name ?? $this->match->awayTeam->name;
            $score = "{$this->match->home_score}-{$this->match->away_score}";

            foreach ($userPointsUpdates as $userId => $data) {
                $points = $data['points'];
                $user = $data['user'];
                
                if ($points > 0) {
                    $title = "🎉 Félicitations !";
                    $message = "Vous avez gagné {$points} point(s) pour {$homeTeam} vs {$awayTeam} ({$score})";
                } else {
                    $title = "Résultat du match";
                    $message = "Match terminé : {$homeTeam} vs {$awayTeam} ({$score}). Pas de points cette fois.";
                }

                $oneSignalService = app(OneSignalService::class);
                $oneSignalService->sendToUsers([$userId], $title, $message, [
                    'type' => 'prediction_result',
                    'match_id' => $this->match->id,
                    'points_earned' => $points,
                    'tournament_id' => $this->match->tournament_id
                ]);
            }

            Log::info('Notifications de résultats envoyées', [
                'match_id' => $this->match->id,
                'user_count' => count($userPointsUpdates)
            ]);

        } catch (\Exception $e) {
            Log::warning('Erreur lors de l\'envoi des notifications de résultats', [
                'match_id' => $this->match->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Invalidate related caches
     */
    private function invalidateRelatedCaches(): void
    {
        // Invalider les caches des leaderboards
        Cache::forget('leaderboard_top_users');
        Cache::forget('leaderboard_global');
        
        // Invalider les caches des prédictions utilisateur
        $userIds = Prediction::where('football_match_id', $this->match->id)
            ->pluck('user_id')
            ->unique();

        foreach ($userIds as $userId) {
            Cache::forget("user_predictions_{$userId}");
            Cache::forget("user_prediction_{$userId}_{$this->match->id}");
        }

        // Invalider le cache du tournoi si applicable
        if ($this->match->tournament_id) {
            Cache::forget("tournament_leaderboard_{$this->match->tournament_id}");
        }
    }
} 