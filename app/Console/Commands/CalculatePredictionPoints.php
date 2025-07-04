<?php

namespace App\Console\Commands;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\Leaderboard;
use Illuminate\Console\Command;

class CalculatePredictionPoints extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'predictions:calculate-points {--match-id= : Calculate points for a specific match}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Calculate points for predictions based on finished matches';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🏆 Calcul des points de pronostics...');

        if ($this->option('match-id')) {
            $this->calculatePointsForMatch($this->option('match-id'));
        } else {
            $this->calculatePointsForAllFinishedMatches();
        }

        $this->updateLeaderboards();
        
        $this->info('✅ Calcul des points terminé!');
    }

    private function calculatePointsForAllFinishedMatches()
    {
        $finishedMatches = FootballMatch::finished()
            ->whereHas('predictions', function($query) {
                $query->where('is_calculated', false);
            })
            ->get();

        if ($finishedMatches->isEmpty()) {
            $this->info('Aucun match terminé avec des prédictions non calculées.');
            return;
        }

        $this->info("Traitement de {$finishedMatches->count()} match(s) terminé(s)...");

        foreach ($finishedMatches as $match) {
            $this->calculatePointsForMatch($match->id);
        }
    }

    private function calculatePointsForMatch($matchId)
    {
        $match = FootballMatch::with(['predictions.user'])->find($matchId);
        
        if (!$match) {
            $this->error("Match avec ID {$matchId} non trouvé.");
            return;
        }

        if (!$match->is_finished) {
            $this->warn("Le match {$match->homeTeam->name} vs {$match->awayTeam->name} n'est pas encore terminé.");
            return;
        }

        $predictions = $match->predictions()->where('is_calculated', false)->get();
        
        if ($predictions->isEmpty()) {
            $this->info("Aucune prédiction non calculée pour ce match.");
            return;
        }

        $this->info("Calcul des points pour {$predictions->count()} prédiction(s) du match {$match->homeTeam->name} vs {$match->awayTeam->name}");
        $this->info("Score final: {$match->home_score} - {$match->away_score}");

        $pointsCalculated = 0;

        foreach ($predictions as $prediction) {
            $points = $this->calculatePredictionPoints($prediction, $match);
            
            $prediction->update([
                'points_earned' => $points,
                'is_calculated' => true
            ]);

            if ($points > 0) {
                $pointsCalculated++;
                $this->line("  ✓ {$prediction->user->name}: {$points} point(s) - Pronostic: {$prediction->predicted_home_score}-{$prediction->predicted_away_score}");
            } else {
                $this->line("  ✗ {$prediction->user->name}: {$points} point(s) - Pronostic: {$prediction->predicted_home_score}-{$prediction->predicted_away_score}");
            }
        }

        $this->info("Points attribués à {$pointsCalculated} utilisateur(s).");
    }

    private function calculatePredictionPoints(Prediction $prediction, FootballMatch $match)
    {
        $actualWinner = $match->winner;
        $exactScore = ($prediction->predicted_home_score == $match->home_score && 
                      $prediction->predicted_away_score == $match->away_score);
        $correctWinner = ($prediction->predicted_winner == $actualWinner);

        $points = 0;

        if ($exactScore) {
            // Score exact = 3 points (peu importe le gagnant)
            $points = 3;
        } elseif ($correctWinner) {
            // Bon gagnant seulement = 1 point
            $points = 1;
        }

        return $points;
    }

    private function updateLeaderboards()
    {
        $this->info('📊 Mise à jour du classement...');

        // Obtenir tous les utilisateurs ayant fait des prédictions
        $userIds = Prediction::distinct('user_id')->pluck('user_id');

        foreach ($userIds as $userId) {
            $leaderboard = Leaderboard::firstOrCreate(['user_id' => $userId]);
            $leaderboard->updateStats();
        }

        // Mettre à jour les rangs
        Leaderboard::updateRankings();

        $this->info('✅ Classement mis à jour!');
    }
}
