<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "=== RÉINITIALISATION MOT DE PASSE FATIMA ===\n\n";

try {
    $user = User::where('email', 'fatima.traore@example.com')->first();
    
    if (!$user) {
        echo "❌ Utilisateur Fatima non trouvé!\n";
        exit(1);
    }
    
    echo "👤 Utilisateur trouvé:\n";
    echo "   - ID: {$user->id}\n";
    echo "   - Nom: {$user->name}\n";
    echo "   - Email: {$user->email}\n\n";
    
    // Définir le nouveau mot de passe
    $newPassword = 'password123';
    
    $user->update([
        'password' => Hash::make($newPassword)
    ]);
    
    echo "✅ Mot de passe mis à jour avec succès!\n";
    echo "📝 Nouveau mot de passe: {$newPassword}\n\n";
    
} catch (\Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    echo "📍 Trace: " . $e->getTraceAsString() . "\n";
}

echo "=== FIN ===\n"; 