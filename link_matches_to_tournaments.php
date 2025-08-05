<?php

require_once 'vendor/autoload.php';

use App\Models\FootballMatch;
use App\Models\Tournament;
use Carbon\Carbon;

// Charger l'application Laravel
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "=== Liaison des matches aux tournois ===\n\n";

// Récupérer tous les tournois
$tournaments = Tournament::all();
echo "Tournois disponibles:\n";
foreach ($tournaments as $tournament) {
    echo "- ID: {$tournament->id}, Nom: {$tournament->name}, Période: {$tournament->start_date} à {$tournament->end_date}\n";
}
echo "\n";

// Récupérer tous les matches sans tournoi
$matchesWithoutTournament = FootballMatch::whereNull('tournament_id')->get();
echo "Matches sans tournoi: {$matchesWithoutTournament->count()}\n\n";

$linkedCount = 0;

foreach ($matchesWithoutTournament as $match) {
    $matchDate = Carbon::parse($match->match_date);
    
    // Trouver le tournoi correspondant à la date du match
    $matchingTournament = null;
    
    foreach ($tournaments as $tournament) {
        $tournamentStart = Carbon::parse($tournament->start_date);
        $tournamentEnd = Carbon::parse($tournament->end_date);
        
        if ($matchDate->between($tournamentStart, $tournamentEnd)) {
            $matchingTournament = $tournament;
            break;
        }
    }
    
    if ($matchingTournament) {
        $match->tournament_id = $matchingTournament->id;
        $match->save();
        $linkedCount++;
        
        echo "✓ Match ID {$match->id} ({$match->homeTeam->name} vs {$match->awayTeam->name}) lié au tournoi '{$matchingTournament->name}'\n";
    } else {
        echo "✗ Match ID {$match->id} ({$match->homeTeam->name} vs {$match->awayTeam->name}) - Aucun tournoi trouvé pour la date {$matchDate->format('Y-m-d')}\n";
    }
}

echo "\n=== Résumé ===\n";
echo "Matches liés: {$linkedCount}\n";
echo "Matches restants sans tournoi: " . FootballMatch::whereNull('tournament_id')->count() . "\n";

// Afficher les statistiques finales
echo "\n=== Statistiques finales ===\n";
$totalMatches = FootballMatch::count();
$matchesWithTournament = FootballMatch::whereNotNull('tournament_id')->count();
$matchesWithoutTournament = FootballMatch::whereNull('tournament_id')->count();

echo "Total matches: {$totalMatches}\n";
echo "Matches avec tournoi: {$matchesWithTournament}\n";
echo "Matches sans tournoi: {$matchesWithoutTournament}\n";
echo "Pourcentage de matches liés: " . round(($matchesWithTournament / $totalMatches) * 100, 2) . "%\n"; 