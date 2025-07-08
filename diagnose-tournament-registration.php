<?php

require_once __DIR__ . '/vendor/autoload.php';

use App\Models\Tournament;
use App\Models\User;
use Carbon\Carbon;

// Bootstrap Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "🔍 Diagnostic d'inscription au tournoi\n";
echo "=====================================\n\n";

// Récupérer le tournoi ID 3
$tournamentId = 3;
echo "📋 Analyse du tournoi ID: {$tournamentId}\n\n";

try {
    $tournament = Tournament::findOrFail($tournamentId);
    
    echo "🏆 Informations du tournoi:\n";
    echo "   - Nom: {$tournament->name}\n";
    echo "   - Statut: {$tournament->status} ({$tournament->status_label})\n";
    echo "   - Début: " . ($tournament->start_date ? $tournament->start_date->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Fin: " . ($tournament->end_date ? $tournament->end_date->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Début inscriptions: " . ($tournament->registration_start ? $tournament->registration_start->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Fin inscriptions: " . ($tournament->registration_end ? $tournament->registration_end->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Public: " . ($tournament->is_public ? 'Oui' : 'Non') . "\n";
    echo "   - Max participants: " . ($tournament->max_participants ?? 'Illimité') . "\n";
    echo "   - Participants actuels: {$tournament->participants_count}\n";
    echo "   - Peut s'inscrire (attribut): " . ($tournament->can_register ? 'Oui' : 'Non') . "\n\n";

    // Vérifier les conditions d'inscription
    echo "🔎 Vérification des conditions d'inscription:\n";
    
    $now = now();
    echo "   - Date actuelle: " . $now->format('d/m/Y H:i') . "\n";
    
    // 1. Statut
    $statusOk = $tournament->status === Tournament::STATUS_REGISTRATION_OPEN;
    echo "   - Statut = 'registration_open': " . ($statusOk ? '✅' : '❌') . "\n";
    if (!$statusOk) {
        echo "     → Statut actuel: {$tournament->status}\n";
    }
    
    // 2. Date de début d'inscription
    $startOk = !$tournament->registration_start || $now >= $tournament->registration_start;
    echo "   - Après date début inscription: " . ($startOk ? '✅' : '❌') . "\n";
    if (!$startOk && $tournament->registration_start) {
        echo "     → Les inscriptions commencent le: " . $tournament->registration_start->format('d/m/Y H:i') . "\n";
    }
    
    // 3. Date de fin d'inscription
    $endOk = !$tournament->registration_end || $now <= $tournament->registration_end;
    echo "   - Avant date fin inscription: " . ($endOk ? '✅' : '❌') . "\n";
    if (!$endOk && $tournament->registration_end) {
        echo "     → Les inscriptions se terminent le: " . $tournament->registration_end->format('d/m/Y H:i') . "\n";
    }
    
    // 4. Limite de participants
    $limitOk = !$tournament->max_participants || $tournament->participants_count < $tournament->max_participants;
    echo "   - Limite participants: " . ($limitOk ? '✅' : '❌') . "\n";
    if (!$limitOk) {
        echo "     → {$tournament->participants_count}/{$tournament->max_participants} participants\n";
    }
    
    echo "\n";
    
    // Mettre à jour le statut automatiquement
    echo "🔄 Mise à jour automatique du statut...\n";
    $oldStatus = $tournament->status;
    $newStatus = $tournament->updateStatus();
    
    if ($oldStatus !== $newStatus) {
        echo "   - Statut changé: {$oldStatus} → {$newStatus}\n";
        echo "   - Peut maintenant s'inscrire: " . ($tournament->fresh()->can_register ? 'Oui' : 'Non') . "\n";
    } else {
        echo "   - Statut inchangé: {$newStatus}\n";
    }
    
    echo "\n";
    
    // Test avec un utilisateur exemple
    echo "👤 Test d'inscription avec utilisateur ID 4:\n";
    $user = User::find(4);
    
    if ($user) {
        echo "   - Utilisateur: {$user->name} ({$user->email})\n";
        
        // Vérifier si déjà inscrit
        $alreadyRegistered = $tournament->participants()->where('user_id', $user->id)->exists();
        echo "   - Déjà inscrit: " . ($alreadyRegistered ? 'Oui' : 'Non') . "\n";
        
        // Test de canUserRegister
        $canRegister = $tournament->canUserRegister($user);
        echo "   - Peut s'inscrire: " . ($canRegister ? 'Oui' : 'Non') . "\n";
        
        if (!$canRegister) {
            echo "   - Raisons:\n";
            if (!$tournament->can_register) {
                echo "     → Tournoi fermé aux inscriptions\n";
            }
            if ($alreadyRegistered) {
                echo "     → Utilisateur déjà inscrit\n";
            }
        }
    } else {
        echo "   - ❌ Utilisateur ID 4 non trouvé\n";
    }
    
    echo "\n";
    
    // Proposer des corrections
    echo "🔧 Corrections suggérées:\n";
    
    if (!$statusOk) {
        echo "   1. Changer le statut en 'registration_open':\n";
        echo "      UPDATE tournaments SET status = 'registration_open' WHERE id = {$tournamentId};\n\n";
    }
    
    if (!$startOk && $tournament->registration_start) {
        echo "   2. Ajuster la date de début d'inscription:\n";
        echo "      UPDATE tournaments SET registration_start = NOW() - INTERVAL 1 DAY WHERE id = {$tournamentId};\n\n";
    }
    
    if (!$endOk && $tournament->registration_end) {
        echo "   3. Étendre la date de fin d'inscription:\n";
        echo "      UPDATE tournaments SET registration_end = NOW() + INTERVAL 7 DAY WHERE id = {$tournamentId};\n\n";
    }
    
    if (!$limitOk) {
        echo "   4. Augmenter la limite de participants:\n";
        echo "      UPDATE tournaments SET max_participants = " . ($tournament->max_participants + 50) . " WHERE id = {$tournamentId};\n\n";
    }
    
    // Script de correction automatique
    echo "🛠️  Script de correction automatique:\n";
    echo "      php fix-tournament-registration.php {$tournamentId}\n";
    
} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
}

echo "\n✅ Diagnostic terminé.\n"; 