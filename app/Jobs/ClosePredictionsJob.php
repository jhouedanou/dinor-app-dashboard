<?php

namespace App\Jobs;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Services\OneSignalService;
use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class ClosePredictionsJob implements ShouldQueue
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
            Log::info('Job ClosePredictions démarré', [
                'match_id' => $this->match->id,
                'match_date' => $this->match->match_date,
                'home_team' => $this->match->homeTeam->name ?? 'N/A',
                'away_team' => $this->match->awayTeam->name ?? 'N/A'
            ]);

            // Vérifier que le match n'est pas déjà commencé
            if ($this->match->match_date <= now()) {
                Log::warning('Match déjà commencé, fermeture des pronostics', [
                    'match_id' => $this->match->id
                ]);
            }

            // Fermer les pronostics en mettant à jour predictions_close_at
            $this->match->update([
                'predictions_close_at' => now(),
                'predictions_enabled' => false
            ]);

            // Invalider le cache des matchs
            Cache::forget("match_prediction_check_{$this->match->id}");
            Cache::forget("tournament_matches_{$this->match->tournament_id}");

            // Compter les pronostics pour ce match
            $predictionsCount = Prediction::where('football_match_id', $this->match->id)->count();

            Log::info('Pronostics fermés avec succès', [
                'match_id' => $this->match->id,
                'predictions_count' => $predictionsCount,
                'closed_at' => now()
            ]);

            // Envoyer des notifications push si activé
            if ($this->notifyUsers && $predictionsCount > 0) {
                $this->sendClosureNotifications();
            }

            // Programmer le job de calcul des points après le match
            $this->schedulePointsCalculation();

        } catch (\Exception $e) {
            Log::error('Erreur lors de la fermeture des pronostics', [
                'match_id' => $this->match->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            throw $e;
        }
    }

    /**
     * Send notifications to users about predictions closure
     */
    private function sendClosureNotifications(): void
    {
        try {
            $homeTeam = $this->match->homeTeam->short_name ?? $this->match->homeTeam->name;
            $awayTeam = $this->match->awayTeam->short_name ?? $this->match->awayTeam->name;
            
            $title = "Pronostics fermés";
            $message = "Les pronostics pour {$homeTeam} vs {$awayTeam} sont maintenant fermés.";
            
            // Récupérer les utilisateurs qui ont fait des pronostics pour ce match
            $userIds = Prediction::where('football_match_id', $this->match->id)
                ->pluck('user_id')
                ->unique()
                ->toArray();

            if (!empty($userIds)) {
                $oneSignalService = app(OneSignalService::class);
                $oneSignalService->sendToUsers($userIds, $title, $message, [
                    'type' => 'predictions_closed',
                    'match_id' => $this->match->id,
                    'tournament_id' => $this->match->tournament_id
                ]);

                Log::info('Notifications de fermeture envoyées', [
                    'match_id' => $this->match->id,
                    'user_count' => count($userIds)
                ]);
            }

        } catch (\Exception $e) {
            Log::warning('Erreur lors de l\'envoi des notifications de fermeture', [
                'match_id' => $this->match->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Schedule points calculation job after match ends
     */
    private function schedulePointsCalculation(): void
    {
        try {
            // Programmer le calcul des points 30 minutes après la fin prévue du match
            // (durée normale d'un match + 30 minutes de marge)
            $calculationTime = $this->match->match_date->addMinutes(120);
            
            // Utiliser le job existant ou en créer un nouveau
            CalculatePredictionPointsJob::dispatch($this->match)
                ->delay($calculationTime);

            Log::info('Job de calcul des points programmé', [
                'match_id' => $this->match->id,
                'calculation_time' => $calculationTime
            ]);

        } catch (\Exception $e) {
            Log::warning('Erreur lors de la programmation du calcul des points', [
                'match_id' => $this->match->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Schedule predictions closure for all upcoming matches
     */
    public static function scheduleForUpcomingMatches(): int
    {
        $scheduledCount = 0;
        
        try {
            // Récupérer tous les matchs à venir avec pronostics ouverts
            $upcomingMatches = FootballMatch::where('is_active', true)
                ->where('predictions_enabled', true)
                ->where('match_date', '>', now())
                ->where('match_date', '<=', now()->addDays(7)) // Programmer pour les 7 prochains jours
                ->whereNull('predictions_close_at')
                ->get();

            foreach ($upcomingMatches as $match) {
                // Calculer l'heure de fermeture (15 minutes avant le match)
                $closureTime = $match->match_date->subMinutes(15);
                
                // Ne programmer que si c'est dans le futur
                if ($closureTime > now()) {
                    self::dispatch($match)->delay($closureTime);
                    $scheduledCount++;
                    
                    Log::info('Job de fermeture programmé', [
                        'match_id' => $match->id,
                        'closure_time' => $closureTime,
                        'match_date' => $match->match_date
                    ]);
                }
            }

            Log::info('Programmation des fermetures terminée', [
                'scheduled_count' => $scheduledCount,
                'total_matches' => $upcomingMatches->count()
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la programmation des fermetures', [
                'error' => $e->getMessage()
            ]);
        }

        return $scheduledCount;
    }
} 