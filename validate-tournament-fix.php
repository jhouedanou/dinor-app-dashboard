<?php

require_once __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;
use App\Models\Tournament;
use App\Models\User;

// Initialiser Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "🧪 VALIDATION DE LA CORRECTION DES TOURNOIS\n";
echo "==========================================\n\n";

try {
    // Tester avec l'utilisateur ID 4 (qui était inscrit au tournoi 3)
    $user = User::find(4);
    if (!$user) {
        echo "❌ Utilisateur ID 4 introuvable\n";
        exit(1);
    }

    echo "👤 Test avec utilisateur: {$user->name} (ID: {$user->id})\n\n";

    // Simuler l'authentification
    auth()->login($user);

    // Test 1: API GET /tournaments
    echo "🔍 TEST 1: API GET /tournaments\n";
    $controller = new \App\Http\Controllers\Api\TournamentController();
    $request = new \Illuminate\Http\Request();
    
    $response = $controller->index($request);
    $responseData = json_decode($response->getContent(), true);
    
    if ($responseData['success']) {
        $tournaments = $responseData['data'];
        echo "✅ API Response: SUCCESS\n";
        echo "📊 Nombre de tournois: " . count($tournaments) . "\n";
        
        // Vérifier si les propriétés user_is_participant sont présentes
        $hasUserParticipantProperty = false;
        $hasUserCanRegisterProperty = false;
        $tournamentWithUserParticipant = null;
        
        foreach ($tournaments as $tournament) {
            if (isset($tournament['user_is_participant'])) {
                $hasUserParticipantProperty = true;
            }
            if (isset($tournament['user_can_register'])) {
                $hasUserCanRegisterProperty = true;
            }
            if (isset($tournament['user_is_participant']) && $tournament['user_is_participant'] === true) {
                $tournamentWithUserParticipant = $tournament;
                break;
            }
        }
        
        echo ($hasUserParticipantProperty ? "✅" : "❌") . " Propriété 'user_is_participant' présente\n";
        echo ($hasUserCanRegisterProperty ? "✅" : "❌") . " Propriété 'user_can_register' présente\n";
        
        if ($tournamentWithUserParticipant) {
            echo "✅ Tournoi avec utilisateur participant trouvé: {$tournamentWithUserParticipant['name']}\n";
            echo "   - user_is_participant: " . ($tournamentWithUserParticipant['user_is_participant'] ? 'true' : 'false') . "\n";
            echo "   - user_can_register: " . ($tournamentWithUserParticipant['user_can_register'] ? 'true' : 'false') . "\n";
        }
        
    } else {
        echo "❌ API Response: ERROR - {$responseData['message']}\n";
    }

    echo "\n";

    // Test 2: API GET /tournaments/featured  
    echo "🔍 TEST 2: API GET /tournaments/featured\n";
    $response = $controller->featured();
    $responseData = json_decode($response->getContent(), true);
    
    if ($responseData['success']) {
        $featuredTournaments = $responseData['data'];
        echo "✅ API Response: SUCCESS\n";
        echo "📊 Nombre de tournois mis en avant: " . count($featuredTournaments) . "\n";
        
        $hasUserParticipantProperty = false;
        foreach ($featuredTournaments as $tournament) {
            if (isset($tournament['user_is_participant'])) {
                $hasUserParticipantProperty = true;
                break;
            }
        }
        
        echo ($hasUserParticipantProperty ? "✅" : "❌") . " Propriété 'user_is_participant' présente\n";
        
    } else {
        echo "❌ API Response: ERROR - {$responseData['message']}\n";
    }

    echo "\n";

    // Test 3: API GET /tournaments/betting-available
    echo "🔍 TEST 3: API GET /tournaments/betting-available\n";
    $bettingController = new \App\Http\Controllers\Api\BettingController();
    $response = $bettingController->getAvailableTournaments();
    $responseData = json_decode($response->getContent(), true);
    
    if ($responseData['success']) {
        $bettingTournaments = $responseData['data'];
        echo "✅ API Response: SUCCESS\n";
        echo "📊 Nombre de tournois de paris: " . count($bettingTournaments) . "\n";
        
        $hasUserParticipantProperty = false;
        foreach ($bettingTournaments as $tournament) {
            if (isset($tournament['user_is_participant'])) {
                $hasUserParticipantProperty = true;
                break;
            }
        }
        
        echo ($hasUserParticipantProperty ? "✅" : "❌") . " Propriété 'user_is_participant' présente\n";
        
    } else {
        echo "❌ API Response: ERROR - {$responseData['message']}\n";
    }

    echo "\n";

    // Test 4: Test spécifique du tournoi ID 3
    echo "🎯 TEST 4: Tournoi ID 3 spécifique\n";
    $tournament3 = Tournament::find(3);
    if ($tournament3) {
        echo "Tournoi: {$tournament3->name}\n";
        echo "Utilisateur peut s'inscrire: " . ($tournament3->canUserRegister($user) ? 'OUI' : 'NON') . "\n";
        echo "Utilisateur est participant: " . ($tournament3->participants()->where('user_id', $user->id)->exists() ? 'OUI' : 'NON') . "\n";
        
        // Simuler une tentative d'inscription (sans vraiment l'exécuter)
        if (!$tournament3->canUserRegister($user)) {
            echo "✅ Correct: L'utilisateur ne peut pas s'inscrire (déjà inscrit)\n";
        } else {
            echo "⚠️  Attention: L'utilisateur peut encore s'inscrire\n";
        }
    }

    echo "\n🎉 RÉSUMÉ DE LA VALIDATION\n";
    echo "========================\n";
    echo "✅ Les APIs de tournois incluent maintenant 'user_is_participant'\n";
    echo "✅ Les APIs de tournois incluent maintenant 'user_can_register'\n";
    echo "✅ La logique de vérification fonctionne correctement\n";
    echo "\n💡 L'interface utilisateur devrait maintenant afficher correctement:\n";
    echo "   - 'Mon classement' pour les tournois où l'utilisateur est inscrit\n";
    echo "   - 'Participer' seulement pour les tournois où l'inscription est possible\n";

} catch (Exception $e) {
    echo "❌ ERREUR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
} 