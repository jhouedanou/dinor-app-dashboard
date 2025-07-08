<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use App\Models\Prediction;
use App\Models\Leaderboard;
use App\Models\FootballMatch;

echo "=== FAIRE GAGNER FATIMA TRAORÉ ===\n\n";

try {
    $fatima = User::where('email', 'fatima.traore@example.com')->first();
    
    if (!$fatima) {
        echo "❌ Fatima non trouvée!\n";
        exit(1);
    }
    
    echo "👤 Utilisateur trouvé: {$fatima->name} (ID: {$fatima->id})\n\n";
    
    // Récupérer ses prédictions
    $predictions = Prediction::where('user_id', $fatima->id)->get();
    echo "📊 Prédictions trouvées: " . $predictions->count() . "\n\n";
    
    $totalPoints = 0;
    $correctPredictions = 0;
    
    foreach ($predictions as $prediction) {
        // Simuler que toutes ses prédictions sont justes
        $points = rand(3, 5); // Points aléatoires entre 3 et 5
        
        $prediction->update([
            'points_earned' => $points,
            'is_calculated' => true
        ]);
        
        $totalPoints += $points;
        $correctPredictions++;
        
        echo "✅ Prédiction #{$prediction->id} : +{$points} points\n";
    }
    
    echo "\n🎯 RÉSUMÉ:\n";
    echo "   - Prédictions correctes: {$correctPredictions}\n";
    echo "   - Points totaux: {$totalPoints}\n\n";
    
    // Mettre à jour le leaderboard
    $leaderboard = Leaderboard::where('user_id', $fatima->id)->first();
    
    if ($leaderboard) {
        $leaderboard->update([
            'total_points' => $totalPoints,
            'total_predictions' => $predictions->count(),
            'correct_predictions' => $correctPredictions,
            'accuracy_percentage' => $predictions->count() > 0 ? ($correctPredictions / $predictions->count()) * 100 : 0,
            'current_rank' => 1, // Premier rang !
            'last_updated' => now()
        ]);
        echo "🏆 Leaderboard mis à jour - FATIMA EST PREMIÈRE!\n";
    } else {
        // Créer un nouvel enregistrement leaderboard
        Leaderboard::create([
            'user_id' => $fatima->id,
            'total_points' => $totalPoints,
            'total_predictions' => $predictions->count(),
            'correct_predictions' => $correctPredictions,
            'accuracy_percentage' => $predictions->count() > 0 ? ($correctPredictions / $predictions->count()) * 100 : 0,
            'current_rank' => 1,
            'last_updated' => now()
        ]);
        echo "🏆 Nouveau leaderboard créé - FATIMA EST PREMIÈRE!\n";
    }
    
    echo "\n🎉 FATIMA TRAORÉ EST MAINTENANT LA CHAMPIONNE!\n";
    
} catch (\Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
}

echo "\n=== FIN ===\n"; 