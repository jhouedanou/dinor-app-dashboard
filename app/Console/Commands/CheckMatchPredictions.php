<?php

namespace App\Console\Commands;

use App\Models\FootballMatch;
use App\Models\Tournament;
use Illuminate\Console\Command;

class CheckMatchPredictions extends Command
{
    protected $signature = 'check:match-predictions';
    protected $description = 'Diagnostic des pronostics de matchs';

    public function handle()
    {
        $this->info('=== DIAGNOSTIC DES PRONOSTICS ===');
        $this->newLine();

        // Récupérer tous les tournois et matches
        $tournaments = Tournament::with(['matches.homeTeam', 'matches.awayTeam'])->get();

        $this->info("Nombre de tournois trouvés: " . $tournaments->count());
        $this->newLine();

        foreach ($tournaments as $tournament) {
            $this->info("--- TOURNOI: {$tournament->name} (ID: {$tournament->id}) ---");
            $this->line("Status: {$tournament->status}");
            $this->line("Peut prédire: " . ($tournament->can_predict ? 'OUI' : 'NON'));
            $this->line("Nombre de matches: " . $tournament->matches->count());
            $this->newLine();
            
            foreach ($tournament->matches as $match) {
                $this->line("  MATCH {$match->id}:");
                $homeTeamName = $match->homeTeam ? $match->homeTeam->name : 'N/A';
                $awayTeamName = $match->awayTeam ? $match->awayTeam->name : 'N/A';
                $this->line("  - Équipes: {$homeTeamName} vs {$awayTeamName}");
                $this->line("  - Date du match: {$match->match_date}");
                $closeAt = $match->predictions_close_at ? $match->predictions_close_at : 'Utilise date du match';
                $this->line("  - Fermeture prédictions: {$closeAt}");
                $this->line("  - Status: {$match->status}");
                $this->line("  - Actif: " . ($match->is_active ? 'OUI' : 'NON'));
                $this->line("  - Prédictions activées: " . ($match->predictions_enabled ? 'OUI' : 'NON'));
                $this->line("  - Peut prédire: " . ($match->can_predict ? 'OUI' : 'NON'));
                
                // Diagnostic détaillé
                if (!$match->can_predict) {
                    $this->warn("  RAISONS POURQUOI ON NE PEUT PAS PRÉDIRE:");
                    if (!$match->predictions_enabled) {
                        $this->line("    - Prédictions désactivées");
                    }
                    if (!$match->is_active) {
                        $this->line("    - Match inactif");
                    }
                    if ($match->predictions_close_at && now() >= $match->predictions_close_at) {
                        $this->line("    - Date de fermeture des prédictions dépassée (" . $match->predictions_close_at . ")");
                    } elseif (!$match->predictions_close_at && now() >= $match->match_date) {
                        $this->line("    - Date du match dépassée (" . $match->match_date . ")");
                    }
                }
                $this->newLine();
            }
            $this->newLine();
        }

        $this->info("Date/heure actuelle: " . now());
        
        return Command::SUCCESS;
    }
}