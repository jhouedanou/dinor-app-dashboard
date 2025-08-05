<?php

require_once 'vendor/autoload.php';

// Load Laravel
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\FootballMatch;
use App\Models\Tournament;

echo "=== DIAGNOSTIC DES PRONOSTICS ===\n\n";

// Récupérer tous les tournois et matches
$tournaments = Tournament::with('matches')->get();

echo "Nombre de tournois trouvés: " . $tournaments->count() . "\n\n";

foreach ($tournaments as $tournament) {
    echo "--- TOURNOI: {$tournament->name} (ID: {$tournament->id}) ---\n";
    echo "Status: {$tournament->status}\n";
    echo "Peut prédire: " . ($tournament->can_predict ? 'OUI' : 'NON') . "\n";
    echo "Nombre de matches: " . $tournament->matches->count() . "\n\n";
    
    foreach ($tournament->matches as $match) {
        echo "  MATCH {$match->id}:\n";
        $homeTeamName = $match->homeTeam ? $match->homeTeam->name : 'N/A';
        $awayTeamName = $match->awayTeam ? $match->awayTeam->name : 'N/A';
        echo "  - Équipes: {$homeTeamName} vs {$awayTeamName}\n";
        echo "  - Date du match: {$match->match_date}\n";
        $closeAt = $match->predictions_close_at ? $match->predictions_close_at : 'Utilise date du match';
        echo "  - Fermeture prédictions: {$closeAt}\n";
        echo "  - Status: {$match->status}\n";
        echo "  - Actif: " . ($match->is_active ? 'OUI' : 'NON') . "\n";
        echo "  - Prédictions activées: " . ($match->predictions_enabled ? 'OUI' : 'NON') . "\n";
        echo "  - Peut prédire: " . ($match->can_predict ? 'OUI' : 'NON') . "\n";
        
        // Diagnostic détaillé
        if (!$match->can_predict) {
            echo "  RAISONS POURQUOI ON NE PEUT PAS PRÉDIRE:\n";
            if (!$match->predictions_enabled) {
                echo "    - Prédictions désactivées\n";
            }
            if (!$match->is_active) {
                echo "    - Match inactif\n";
            }
            if ($match->predictions_close_at && now() >= $match->predictions_close_at) {
                echo "    - Date de fermeture des prédictions dépassée (" . $match->predictions_close_at . ")\n";
            } elseif (!$match->predictions_close_at && now() >= $match->match_date) {
                echo "    - Date du match dépassée (" . $match->match_date . ")\n";
            }
        }
        echo "\n";
    }
    echo "\n";
}

echo "Date/heure actuelle: " . now() . "\n";