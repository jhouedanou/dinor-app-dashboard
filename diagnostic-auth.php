<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

echo "=== DIAGNOSTIC D'AUTHENTIFICATION ===\n\n";

// 1. Vérifier les utilisateurs
echo "1. UTILISATEURS EN BASE:\n";
$users = User::all();
foreach ($users as $user) {
    echo "   - ID: {$user->id}, Email: {$user->email}, Nom: {$user->name}\n";
}
echo "   Total: " . $users->count() . " utilisateurs\n\n";

// 2. Vérifier les tokens Sanctum
echo "2. TOKENS SANCTUM:\n";
$tokens = PersonalAccessToken::all();
foreach ($tokens as $token) {
    $user = User::find($token->tokenable_id);
    $expires = $token->expires_at ? $token->expires_at->format('Y-m-d H:i:s') : 'Jamais';
    $expired = $token->expires_at && $token->expires_at->isPast() ? 'EXPIRÉ' : 'VALIDE';
    
    echo "   - Token ID: {$token->id}\n";
    echo "     Nom: {$token->name}\n";
    echo "     Utilisateur: " . ($user ? "{$user->email} (ID: {$user->id})" : "Utilisateur non trouvé") . "\n";
    echo "     Créé le: {$token->created_at}\n";
    echo "     Expire le: {$expires}\n";
    echo "     Statut: {$expired}\n";
    echo "     Hash: " . substr($token->token, 0, 20) . "...\n\n";
}

if ($tokens->count() === 0) {
    echo "   Aucun token trouvé!\n\n";
}

// 3. Vérifier la configuration Sanctum
echo "3. CONFIGURATION SANCTUM:\n";
echo "   - Stateful domains: " . json_encode(config('sanctum.stateful')) . "\n";
echo "   - Session lifetime: " . config('sanctum.expiration') . " minutes\n";
echo "   - Token expiration: " . (config('sanctum.expiration') ?: 'Aucune expiration') . "\n\n";

// 4. Créer un token de test si pas d'utilisateur connecté
if ($users->count() > 0) {
    echo "4. TEST TOKEN POUR UTILISATEUR 1:\n";
    $user = $users->first();
    $testToken = $user->createToken('test-diagnostic');
    echo "   - Token créé: " . $testToken->plainTextToken . "\n";
    echo "   - Vous pouvez tester avec: curl -H 'Authorization: Bearer {$testToken->plainTextToken}' http://localhost:8000/api/v1/predictions/my-recent\n\n";
}

echo "=== FIN DU DIAGNOSTIC ===\n"; 