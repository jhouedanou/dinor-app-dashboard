<?php

require_once __DIR__ . '/vendor/autoload.php';

// Chargement de l'application Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== DIAGNOSTIC DASHBOARD FILAMENT ===\n\n";

// 1. Vérification des ressources Filament
echo "1. RESSOURCES FILAMENT DISPONIBLES:\n";
echo "-----------------------------------\n";

$resourcesPath = app_path('Filament/Resources');
$resourceFiles = glob($resourcesPath . '/*.php');

foreach ($resourceFiles as $file) {
    $resourceName = basename($file, '.php');
    $className = "App\\Filament\\Resources\\{$resourceName}";
    
    if (class_exists($className)) {
        echo "✓ {$resourceName} - Classe existante\n";
        
        // Vérification des propriétés de navigation
        $reflection = new ReflectionClass($className);
        
        $navigationIcon = $reflection->getProperty('navigationIcon');
        $navigationIcon->setAccessible(true);
        $icon = $navigationIcon->getValue();
        
        $navigationLabel = $reflection->getProperty('navigationLabel');
        $navigationLabel->setAccessible(true);
        $label = $navigationLabel->getValue();
        
        $navigationGroup = $reflection->getProperty('navigationGroup');
        $navigationGroup->setAccessible(true);
        $group = $navigationGroup->getValue();
        
        echo "  - Icône: {$icon}\n";
        echo "  - Label: {$label}\n";
        echo "  - Groupe: {$group}\n";
        
        // Vérification si la ressource est cachée
        try {
            if (method_exists($className, 'shouldRegisterNavigation')) {
                $shouldRegister = $className::shouldRegisterNavigation();
                echo "  - Navigation: " . ($shouldRegister ? "Visible" : "Cachée") . "\n";
            } else {
                echo "  - Navigation: Visible (par défaut)\n";
            }
        } catch (Exception $e) {
            echo "  - Navigation: Erreur lors de la vérification\n";
        }
        
        echo "\n";
    } else {
        echo "✗ {$resourceName} - Classe non trouvée\n\n";
    }
}

// 2. Vérification du AdminPanelProvider
echo "2. CONFIGURATION ADMIN PANEL PROVIDER:\n";
echo "-------------------------------------\n";

$adminProviderPath = app_path('Providers/Filament/AdminPanelProvider.php');
if (file_exists($adminProviderPath)) {
    echo "✓ AdminPanelProvider existe\n";
    
    $content = file_get_contents($adminProviderPath);
    
    // Vérification des ressources découvertes
    if (strpos($content, 'discoverResources') !== false) {
        echo "✓ Auto-découverte des ressources activée\n";
    } else {
        echo "✗ Auto-découverte des ressources désactivée\n";
    }
    
    // Vérification des groupes de navigation
    if (strpos($content, 'navigationGroups') !== false) {
        echo "✓ Groupes de navigation configurés\n";
        preg_match_all("/'([^']+)'/", $content, $matches);
        if (isset($matches[1])) {
            $groups = array_filter($matches[1], function($group) {
                return in_array($group, ['Contenu', 'Administration', 'Interactions', 'Gestion', 'Configuration PWA']);
            });
            echo "  - Groupes: " . implode(', ', $groups) . "\n";
        }
    } else {
        echo "✗ Groupes de navigation non configurés\n";
    }
} else {
    echo "✗ AdminPanelProvider non trouvé\n";
}

echo "\n";

// 3. Vérification des modèles
echo "3. VÉRIFICATION DES MODÈLES:\n";
echo "----------------------------\n";

$models = [
    'Category' => 'App\\Models\\Category',
    'User' => 'App\\Models\\User',
    'DinorTv' => 'App\\Models\\DinorTv',
    'PwaMenuItem' => 'App\\Models\\PwaMenuItem',
    'Recipe' => 'App\\Models\\Recipe',
    'Tip' => 'App\\Models\\Tip',
    'Event' => 'App\\Models\\Event',
];

foreach ($models as $name => $className) {
    if (class_exists($className)) {
        echo "✓ {$name} - Modèle existant\n";
    } else {
        echo "✗ {$name} - Modèle non trouvé\n";
    }
}

echo "\n";

// 4. Vérification de l'authentification
echo "4. CONFIGURATION AUTHENTIFICATION:\n";
echo "----------------------------------\n";

$authConfig = config('auth');
if (isset($authConfig['guards']['admin'])) {
    echo "✓ Guard 'admin' configuré\n";
    echo "  - Driver: " . $authConfig['guards']['admin']['driver'] . "\n";
    echo "  - Provider: " . $authConfig['guards']['admin']['provider'] . "\n";
} else {
    echo "✗ Guard 'admin' non configuré\n";
}

if (isset($authConfig['providers']['admin_users'])) {
    echo "✓ Provider 'admin_users' configuré\n";
    echo "  - Model: " . $authConfig['providers']['admin_users']['model'] . "\n";
} else {
    echo "✗ Provider 'admin_users' non configuré\n";
}

echo "\n";

// 5. Vérification des routes
echo "5. ROUTES FILAMENT:\n";
echo "------------------\n";

try {
    $routes = \Illuminate\Support\Facades\Route::getRoutes();
    $filamentRoutes = [];
    
    foreach ($routes as $route) {
        $uri = $route->uri();
        if (strpos($uri, 'admin/') === 0) {
            $filamentRoutes[] = $uri;
        }
    }
    
    echo "✓ " . count($filamentRoutes) . " routes Filament détectées\n";
    
    $resourceRoutes = array_filter($filamentRoutes, function($route) {
        return strpos($route, 'admin/categories') !== false ||
               strpos($route, 'admin/users') !== false ||
               strpos($route, 'admin/dinor-tvs') !== false ||
               strpos($route, 'admin/pwa-menu-items') !== false;
    });
    
    echo "✓ " . count($resourceRoutes) . " routes de ressources principales\n";
    
} catch (Exception $e) {
    echo "✗ Erreur lors de la vérification des routes: " . $e->getMessage() . "\n";
}

echo "\n";

echo "=== FIN DU DIAGNOSTIC ===\n";