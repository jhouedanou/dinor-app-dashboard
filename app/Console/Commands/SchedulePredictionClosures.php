<?php

namespace App\Console\Commands;

use App\Jobs\ClosePredictionsJob;
use App\Models\FootballMatch;
use Illuminate\Console\Command;
use Carbon\Carbon;

class SchedulePredictionClosures extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'predictions:schedule-closures 
                            {--days=7 : Number of days ahead to schedule}
                            {--force : Force reschedule even if already scheduled}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Schedule automatic closure of predictions 15 minutes before matches start';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $days = (int) $this->option('days');
        $force = $this->option('force');

        $this->info("Programmation des fermetures de pronostics pour les {$days} prochains jours...");

        try {
            $scheduledCount = ClosePredictionsJob::scheduleForUpcomingMatches();
            
            $this->info("✅ {$scheduledCount} fermetures de pronostics programmées avec succès.");
            
            // Afficher les détails des matchs programmés
            $this->showScheduledMatches($days);
            
            return 0;

        } catch (\Exception $e) {
            $this->error("❌ Erreur lors de la programmation : " . $e->getMessage());
            return 1;
        }
    }

    /**
     * Show details of scheduled matches
     */
    private function showScheduledMatches(int $days): void
    {
        $upcomingMatches = FootballMatch::with(['homeTeam', 'awayTeam', 'tournament'])
            ->where('is_active', true)
            ->where('predictions_enabled', true)
            ->where('match_date', '>', now())
            ->where('match_date', '<=', now()->addDays($days))
            ->orderBy('match_date')
            ->get();

        if ($upcomingMatches->isEmpty()) {
            $this->warn("Aucun match trouvé pour les {$days} prochains jours.");
            return;
        }

        $this->newLine();
        $this->info("📅 Matchs à venir :");
        
        $headers = ['Match', 'Date', 'Tournoi', 'Fermeture prédictions'];
        $rows = [];

        foreach ($upcomingMatches as $match) {
            $closureTime = $match->match_date->copy()->subMinutes(15);
            
            $rows[] = [
                "{$match->homeTeam->short_name} vs {$match->awayTeam->short_name}",
                $match->match_date->format('d/m/Y H:i'),
                $match->tournament->name ?? 'N/A',
                $closureTime > now() ? $closureTime->format('d/m/Y H:i') : 'Déjà fermé'
            ];
        }

        $this->table($headers, $rows);
    }
} 