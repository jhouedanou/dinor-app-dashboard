<?php

require_once __DIR__ . '/vendor/autoload.php';

use App\Models\Tournament;
use Carbon\Carbon;

// Bootstrap Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "🔧 Correction automatique d'inscription aux tournois\n";
echo "===================================================\n\n";

// Récupérer l'ID du tournoi depuis les arguments
$tournamentId = $argv[1] ?? null;

if (!$tournamentId) {
    echo "❌ Usage: php fix-tournament-registration.php <tournament_id>\n";
    echo "   Exemple: php fix-tournament-registration.php 3\n";
    exit(1);
}

try {
    $tournament = Tournament::findOrFail($tournamentId);
    
    echo "🏆 Correction du tournoi: {$tournament->name} (ID: {$tournamentId})\n\n";
    
    $fixes = [];
    
    // 1. Vérifier et corriger le statut
    if ($tournament->status !== Tournament::STATUS_REGISTRATION_OPEN) {
        echo "🔄 Correction du statut...\n";
        $oldStatus = $tournament->status;
        $tournament->status = Tournament::STATUS_REGISTRATION_OPEN;
        $fixes[] = "Statut: {$oldStatus} → registration_open";
    }
    
    // 2. Vérifier et corriger les dates d'inscription
    $now = now();
    
    if ($tournament->registration_start && $now < $tournament->registration_start) {
        echo "📅 Correction de la date de début d'inscription...\n";
        $oldDate = $tournament->registration_start->format('d/m/Y H:i');
        $tournament->registration_start = $now->subDay();
        $fixes[] = "Date début inscription: {$oldDate} → " . $tournament->registration_start->format('d/m/Y H:i');
    }
    
    if ($tournament->registration_end && $now > $tournament->registration_end) {
        echo "📅 Correction de la date de fin d'inscription...\n";
        $oldDate = $tournament->registration_end->format('d/m/Y H:i');
        $tournament->registration_end = $now->addWeek();
        $fixes[] = "Date fin inscription: {$oldDate} → " . $tournament->registration_end->format('d/m/Y H:i');
    }
    
    // 3. Si pas de dates d'inscription, en créer
    if (!$tournament->registration_start) {
        echo "📅 Création de la date de début d'inscription...\n";
        $tournament->registration_start = now()->subDay();
        $fixes[] = "Date début inscription créée: " . $tournament->registration_start->format('d/m/Y H:i');
    }
    
    if (!$tournament->registration_end) {
        echo "📅 Création de la date de fin d'inscription...\n";
        $tournament->registration_end = now()->addWeeks(2);
        $fixes[] = "Date fin inscription créée: " . $tournament->registration_end->format('d/m/Y H:i');
    }
    
    // 4. Vérifier la limite de participants
    if ($tournament->max_participants && $tournament->participants_count >= $tournament->max_participants) {
        echo "👥 Augmentation de la limite de participants...\n";
        $oldLimit = $tournament->max_participants;
        $tournament->max_participants = $tournament->participants_count + 50;
        $fixes[] = "Limite participants: {$oldLimit} → {$tournament->max_participants}";
    }
    
    // 5. S'assurer que le tournoi est public
    if (!$tournament->is_public) {
        echo "🌐 Activation du mode public...\n";
        $tournament->is_public = true;
        $fixes[] = "Tournoi rendu public";
    }
    
    // Sauvegarder les modifications
    if (!empty($fixes)) {
        $tournament->save();
        
        echo "\n✅ Corrections appliquées:\n";
        foreach ($fixes as $fix) {
            echo "   - {$fix}\n";
        }
        
        // Vérifier que l'inscription fonctionne maintenant
        echo "\n🧪 Test après correction:\n";
        $tournament = $tournament->fresh();
        echo "   - Statut: {$tournament->status}\n";
        echo "   - Peut s'inscrire: " . ($tournament->can_register ? 'Oui ✅' : 'Non ❌') . "\n";
        
        if ($tournament->can_register) {
            echo "\n🎉 Le tournoi accepte maintenant les inscriptions !\n";
        } else {
            echo "\n⚠️ Le tournoi n'accepte toujours pas les inscriptions. Vérifications supplémentaires nécessaires.\n";
        }
        
    } else {
        echo "✅ Aucune correction nécessaire. Le tournoi est déjà configuré correctement.\n";
        echo "   - Peut s'inscrire: " . ($tournament->can_register ? 'Oui ✅' : 'Non ❌') . "\n";
    }
    
    echo "\n";
    
    // Afficher l'état final
    echo "📊 État final du tournoi:\n";
    echo "   - Nom: {$tournament->name}\n";
    echo "   - Statut: {$tournament->status}\n";
    echo "   - Début inscriptions: " . ($tournament->registration_start ? $tournament->registration_start->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Fin inscriptions: " . ($tournament->registration_end ? $tournament->registration_end->format('d/m/Y H:i') : 'Non défini') . "\n";
    echo "   - Participants: {$tournament->participants_count}" . ($tournament->max_participants ? "/{$tournament->max_participants}" : '') . "\n";
    echo "   - Public: " . ($tournament->is_public ? 'Oui' : 'Non') . "\n";
    echo "   - Peut s'inscrire: " . ($tournament->can_register ? 'Oui ✅' : 'Non ❌') . "\n";
    
} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\n✅ Correction terminée.\n"; 