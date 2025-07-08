<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Tournament;
use App\Models\TournamentParticipant;
use App\Models\Prediction;
use App\Models\User;

echo "=== DEBUG TOURNOIS ===\n\n";

try {
    // 1. Compter les données
    $tournamentsCount = Tournament::count();
    $participantsCount = TournamentParticipant::count();
    $predictionsCount = Prediction::count();
    
    echo "📊 STATISTIQUES:\n";
    echo "   - Tournois: {$tournamentsCount}\n";
    echo "   - Participants: {$participantsCount}\n";
    echo "   - Prédictions: {$predictionsCount}\n\n";
    
    // 2. Vérifier l'utilisateur 4 (Fatima)
    $user = User::find(4);
    if ($user) {
        echo "👤 UTILISATEUR 4:\n";
        echo "   - Nom: {$user->name}\n";
        echo "   - Email: {$user->email}\n\n";
        
        // Ses participations
        $userParticipations = TournamentParticipant::where('user_id', 4)->get();
        echo "🏆 PARTICIPATIONS DE FATIMA:\n";
        echo "   - Nombre: " . $userParticipations->count() . "\n";
        
        foreach ($userParticipations as $participation) {
            $tournament = Tournament::find($participation->tournament_id);
            echo "   - Tournoi: " . ($tournament ? $tournament->name : "Tournoi #{$participation->tournament_id} (introuvable)") . "\n";
            echo "     Status: {$participation->status}\n";
            echo "     Date inscription: {$participation->created_at}\n\n";
        }
    } else {
        echo "❌ Utilisateur 4 non trouvé!\n\n";
    }
    
    // 3. Lister tous les tournois
    $allTournaments = Tournament::all();
    echo "🏆 TOUS LES TOURNOIS ({$allTournaments->count()}):\n";
    
    foreach ($allTournaments as $tournament) {
        echo "   - ID: {$tournament->id}\n";
        echo "     Nom: {$tournament->name}\n";
        echo "     Status: {$tournament->status}\n";
        echo "     Date début: {$tournament->start_date}\n";
        echo "     Date fin: {$tournament->end_date}\n";
        echo "     Participants: " . $tournament->participants()->count() . "\n\n";
    }
    
    // 4. Test de la requête exacte du contrôleur
    echo "🔍 TEST REQUÊTE CONTRÔLEUR:\n";
    $tournaments = Tournament::whereHas('participants', function ($query) {
        $query->where('user_id', 4)
              ->where('status', 'active');
    })
    ->with([
        'leaderboard' => function ($query) {
            $query->where('user_id', 4);
        }
    ])
    ->orderByDesc('start_date')
    ->get();
    
    echo "   - Résultat requête: " . $tournaments->count() . " tournois\n";
    
    if ($tournaments->count() === 0) {
        echo "   ❌ Aucun tournoi trouvé avec la requête du contrôleur\n";
        echo "   💡 Cela explique pourquoi l'API retourne 'TOURNAMENT_NOT_FOUND'\n\n";
        
        // Regardons pourquoi
        echo "🔍 ANALYSE:\n";
        $allParticipants = TournamentParticipant::where('user_id', 4)->get();
        echo "   - Participations totales utilisateur 4: " . $allParticipants->count() . "\n";
        
        $activeParticipants = TournamentParticipant::where('user_id', 4)
            ->where('status', 'active')
            ->get();
        echo "   - Participations actives: " . $activeParticipants->count() . "\n";
        
        foreach ($allParticipants as $participant) {
            echo "   - Participation ID {$participant->id}: status '{$participant->status}'\n";
        }
    }
    
} catch (\Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    echo "📍 Trace: " . $e->getTraceAsString() . "\n";
}

echo "\n=== FIN DEBUG ===\n"; 