<?php

require_once __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\Schema;

// Initialiser Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

// Diagnostic de la soumission de recettes
echo "=== DIAGNOSTIC SOUMISSION DE RECETTES ===" . PHP_EOL;

try {
    // Vérifier si la table professional_contents existe
    if (Schema::hasTable('professional_contents')) {
        echo "✅ Table 'professional_contents' existe" . PHP_EOL;
        
        // Vérifier les colonnes
        $columns = Schema::getColumnListing('professional_contents');
        echo "Colonnes disponibles: " . implode(', ', $columns) . PHP_EOL;
        
        // Compter les enregistrements
        $count = \App\Models\ProfessionalContent::count();
        echo "Nombre d'enregistrements: $count" . PHP_EOL;
        
    } else {
        echo "❌ Table 'professional_contents' n'existe pas" . PHP_EOL;
        echo "Solution: Exécuter 'php artisan migrate'" . PHP_EOL;
    }
    
    // Vérifier la table users et les rôles
    echo "\n=== VÉRIFICATION DES UTILISATEURS ===" . PHP_EOL;
    
    $users = \App\Models\User::select('id', 'name', 'email', 'role')->get();
    foreach ($users as $user) {
        $isProfessional = $user->isProfessional() ? '✅' : '❌';
        echo "User #{$user->id} - {$user->name} ({$user->email}) - Role: {$user->role} - Professional: $isProfessional" . PHP_EOL;
    }
    
    // Tester la création d'un contenu professionnel
    echo "\n=== TEST DE CRÉATION ===" . PHP_EOL;
    
    $testUser = \App\Models\User::where('role', 'professional')->orWhere('role', 'admin')->first();
    if ($testUser) {
        echo "Utilisateur de test trouvé: {$testUser->name} (Role: {$testUser->role})" . PHP_EOL;
        
        try {
            $testContent = \App\Models\ProfessionalContent::create([
                'user_id' => $testUser->id,
                'content_type' => 'recipe',
                'title' => 'Test Recipe',
                'description' => 'Test description',
                'content' => 'Test content',
                'status' => 'pending',
                'submitted_at' => now(),
            ]);
            
            echo "✅ Test de création réussi. ID: {$testContent->id}" . PHP_EOL;
            
            // Nettoyer le test
            $testContent->delete();
            echo "Test nettoyé" . PHP_EOL;
            
        } catch (Exception $e) {
            echo "❌ Erreur lors du test de création: " . $e->getMessage() . PHP_EOL;
            echo "Trace: " . $e->getTraceAsString() . PHP_EOL;
        }
    } else {
        echo "❌ Aucun utilisateur avec rôle professional/admin trouvé" . PHP_EOL;
    }
    
    // Vérifier les permissions de storage
    echo "\n=== VÉRIFICATION DU STORAGE ===" . PHP_EOL;
    
    $storagePath = storage_path('app/public');
    $professionalContentPath = $storagePath . '/professional-content';
    
    if (is_dir($storagePath)) {
        echo "✅ Dossier storage/app/public existe" . PHP_EOL;
        echo "Permissions: " . substr(sprintf('%o', fileperms($storagePath)), -4) . PHP_EOL;
    } else {
        echo "❌ Dossier storage/app/public n'existe pas" . PHP_EOL;
    }
    
    if (is_dir($professionalContentPath)) {
        echo "✅ Dossier professional-content existe" . PHP_EOL;
    } else {
        echo "⚠️ Dossier professional-content n'existe pas (sera créé automatiquement)" . PHP_EOL;
    }
    
    // Vérifier les logs
    echo "\n=== VÉRIFICATION DES LOGS ===" . PHP_EOL;
    
    $logFile = storage_path('logs/laravel.log');
    if (file_exists($logFile) && is_readable($logFile)) {
        echo "✅ Fichier de log accessible" . PHP_EOL;
        
        // Chercher les erreurs récentes liées au contenu professionnel
        $logContent = file_get_contents($logFile);
        $lines = explode("\n", $logContent);
        $recentErrors = [];
        
        foreach (array_reverse($lines) as $line) {
            if (strpos($line, 'professional') !== false || strpos($line, 'ProfessionalContent') !== false) {
                $recentErrors[] = $line;
                if (count($recentErrors) >= 5) break;
            }
        }
        
        if (!empty($recentErrors)) {
            echo "Erreurs récentes trouvées:" . PHP_EOL;
            foreach ($recentErrors as $error) {
                echo "  $error" . PHP_EOL;
            }
        } else {
            echo "Aucune erreur récente trouvée" . PHP_EOL;
        }
    } else {
        echo "❌ Fichier de log non accessible" . PHP_EOL;
    }
    
} catch (Exception $e) {
    echo "❌ Erreur générale: " . $e->getMessage() . PHP_EOL;
    echo "Fichier: " . $e->getFile() . ":" . $e->getLine() . PHP_EOL;
}

echo "\n=== FIN DU DIAGNOSTIC ===" . PHP_EOL;