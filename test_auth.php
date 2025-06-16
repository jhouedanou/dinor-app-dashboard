<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

echo "🔍 TEST D'AUTHENTIFICATION ADMIN\n";
echo "================================\n\n";

// Test 1: Utilisateur existe ?
$admin = AdminUser::where('email', 'admin@dinor.app')->first();
echo "✅ Utilisateur trouvé: " . ($admin ? "OUI" : "NON") . "\n";

if ($admin) {
    echo "📊 Détails utilisateur:\n";
    echo "   - ID: {$admin->id}\n";
    echo "   - Email: {$admin->email}\n";
    echo "   - Actif: " . ($admin->is_active ? "OUI" : "NON") . "\n";
    echo "   - Email vérifié: " . ($admin->email_verified_at ? "OUI" : "NON") . "\n";
    
    // Test 2: Password valide ?
    $passwordValid = Hash::check('password123', $admin->password);
    echo "🔑 Mot de passe valide: " . ($passwordValid ? "OUI" : "NON") . "\n";
    
    // Test 3: Auth attempt
    echo "\n🔐 Test d'authentification...\n";
    $credentials = [
        'email' => 'admin@dinor.app',
        'password' => 'password123'
    ];
    
    $attempt = Auth::guard('admin')->attempt($credentials);
    echo "🎯 Connexion réussie: " . ($attempt ? "OUI" : "NON") . "\n";
    
    if ($attempt) {
        $user = Auth::guard('admin')->user();
        echo "👤 Utilisateur connecté: {$user->email}\n";
        Auth::guard('admin')->logout();
    }
}

echo "\n✅ Test terminé!\n"; 