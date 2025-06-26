<?php

require_once __DIR__ . '/vendor/autoload.php';

// Chargement de l'application Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== DIAGNOSTIC PRODUCTION FILAMENT ===\n\n";

// 1. Vérification de l'environnement
echo "1. ENVIRONNEMENT:\n";
echo "----------------\n";
echo "APP_ENV: " . env('APP_ENV') . "\n";
echo "APP_DEBUG: " . (env('APP_DEBUG') ? 'true' : 'false') . "\n";
echo "APP_URL: " . env('APP_URL') . "\n";
echo "PHP Version: " . PHP_VERSION . "\n";
echo "Laravel Version: " . app()->version() . "\n\n";

// 2. Vérification des permissions
echo "2. PERMISSIONS ET RÉPERTOIRES:\n";
echo "------------------------------\n";

$directories = [
    'storage/app' => storage_path('app'),
    'storage/framework' => storage_path('framework'),
    'storage/logs' => storage_path('logs'),
    'bootstrap/cache' => base_path('bootstrap/cache'),
    'public/storage' => public_path('storage'),
];

foreach ($directories as $name => $path) {
    if (is_dir($path)) {
        $writable = is_writable($path);
        echo ($writable ? "✓" : "✗") . " {$name} - " . ($writable ? "Accessible en écriture" : "Pas d'accès en écriture") . "\n";
    } else {
        echo "✗ {$name} - Répertoire non trouvé\n";
    }
}

echo "\n";

// 3. Vérification de la base de données
echo "3. BASE DE DONNÉES:\n";
echo "------------------\n";

try {
    $connection = DB::connection();
    $databaseName = $connection->getDatabaseName();
    echo "✓ Connexion DB établie\n";
    echo "  - Database: {$databaseName}\n";
    echo "  - Driver: " . $connection->getDriverName() . "\n";
    
    // Vérification des tables principales
    $tables = ['categories', 'users', 'dinor_tv', 'pwa_menu_items', 'admin_users'];
    foreach ($tables as $table) {
        try {
            $exists = Schema::hasTable($table);
            echo ($exists ? "✓" : "✗") . " Table '{$table}' - " . ($exists ? "Existe" : "Manquante") . "\n";
        } catch (Exception $e) {
            echo "✗ Table '{$table}' - Erreur: " . $e->getMessage() . "\n";
        }
    }
    
} catch (Exception $e) {
    echo "✗ Erreur de connexion DB: " . $e->getMessage() . "\n";
}

echo "\n";

// 4. Vérification des assets et compilation
echo "4. ASSETS ET COMPILATION:\n";
echo "------------------------\n";

$cssPath = public_path('css/filament/filament/app.css');
$jsPath = public_path('js/filament/filament/app.js');

echo (file_exists($cssPath) ? "✓" : "✗") . " CSS Filament compilé\n";
echo (file_exists($jsPath) ? "✓" : "✗") . " JS Filament compilé\n";

// Vérification du lien symbolique
$symlinkPath = public_path('storage');
if (is_link($symlinkPath)) {
    echo "✓ Symlink storage existe\n";
    echo "  - Pointe vers: " . readlink($symlinkPath) . "\n";
} else {
    echo "✗ Symlink storage manquant\n";
}

echo "\n";

// 5. Vérification des logs d'erreurs
echo "5. LOGS D'ERREURS RÉCENTS:\n";
echo "-------------------------\n";

$logPath = storage_path('logs/laravel.log');
if (file_exists($logPath)) {
    $log = file_get_contents($logPath);
    $lines = explode("\n", $log);
    $recentErrors = [];
    
    foreach (array_reverse($lines) as $line) {
        if (strpos($line, 'ERROR') !== false || strpos($line, 'CRITICAL') !== false || strpos($line, 'EMERGENCY') !== false) {
            $recentErrors[] = $line;
            if (count($recentErrors) >= 5) break;
        }
    }
    
    if (empty($recentErrors)) {
        echo "✓ Aucune erreur récente trouvée\n";
    } else {
        echo "⚠ " . count($recentErrors) . " erreur(s) récente(s) trouvée(s):\n";
        foreach ($recentErrors as $error) {
            echo "  - " . substr($error, 0, 100) . "...\n";
        }
    }
} else {
    echo "✗ Fichier de log non trouvé\n";
}

echo "\n";

// 6. Vérification des middlewares
echo "6. MIDDLEWARES:\n";
echo "--------------\n";

try {
    $middleware = app('router')->getMiddleware();
    $filamentMiddleware = isset($middleware['filament']) ? "✓ Middleware Filament enregistré" : "✗ Middleware Filament manquant";
    echo $filamentMiddleware . "\n";
    
    // Vérification du middleware d'authentification admin
    $adminAuthPath = app_path('Http/Middleware/FilamentAdminAuth.php');
    if (file_exists($adminAuthPath)) {
        echo "✓ FilamentAdminAuth middleware existe\n";
    } else {
        echo "✗ FilamentAdminAuth middleware manquant\n";
    }
    
} catch (Exception $e) {
    echo "✗ Erreur lors de la vérification des middlewares: " . $e->getMessage() . "\n";
}

echo "\n";

// 7. Vérification des providers
echo "7. SERVICE PROVIDERS:\n";
echo "--------------------\n";

$providers = config('app.providers');
$filamentProvider = in_array('App\\Providers\\Filament\\AdminPanelProvider', $providers);
echo ($filamentProvider ? "✓" : "✗") . " AdminPanelProvider enregistré\n";

// Vérification que le provider est chargé
try {
    $app->make('App\\Providers\\Filament\\AdminPanelProvider');
    echo "✓ AdminPanelProvider instanciable\n";
} catch (Exception $e) {
    echo "✗ AdminPanelProvider non instanciable: " . $e->getMessage() . "\n";
}

echo "\n";

// 8. Test de création d'URL Filament
echo "8. URLS FILAMENT:\n";
echo "----------------\n";

try {
    $adminUrl = route('filament.admin.pages.dashboard');
    echo "✓ URL dashboard: {$adminUrl}\n";
    
    $loginUrl = route('filament.admin.auth.login');
    echo "✓ URL login: {$loginUrl}\n";
    
} catch (Exception $e) {
    echo "✗ Erreur génération URLs: " . $e->getMessage() . "\n";
}

echo "\n";

echo "=== RECOMMANDATIONS ===\n";
echo "Si les ressources n'apparaissent pas en production:\n\n";
echo "1. Vérifiez les permissions des répertoires storage/ et bootstrap/cache/\n";
echo "2. Exécutez: php artisan storage:link\n";
echo "3. Nettoyez tous les caches:\n";
echo "   - php artisan filament:optimize-clear\n";
echo "   - php artisan route:clear\n";
echo "   - php artisan config:clear\n";
echo "   - php artisan view:clear\n";
echo "4. Vérifiez les logs en temps réel pendant l'accès au dashboard\n";
echo "5. Assurez-vous que la base de données est accessible\n";
echo "6. Vérifiez que l'utilisateur admin existe et peut se connecter\n\n";

echo "=== FIN DU DIAGNOSTIC ===\n";