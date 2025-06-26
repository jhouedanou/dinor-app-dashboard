<?php
/**
 * Script pour corriger la structure de la table pwa_menu_items
 * À exécuter sur le serveur Forge
 */

require_once 'vendor/autoload.php';

// Charger Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

echo "🔧 === CORRECTION TABLE PWA_MENU_ITEMS ===\n";

try {
    // Vérifier si la table existe
    if (!Schema::hasTable('pwa_menu_items')) {
        echo "❌ Table pwa_menu_items n'existe pas\n";
        exit(1);
    }

    echo "✅ Table pwa_menu_items trouvée\n";

    // Vérifier les colonnes existantes
    $columns = Schema::getColumnListing('pwa_menu_items');
    echo "Colonnes existantes: " . implode(', ', $columns) . "\n\n";

    // Colonnes requises par le seeder
    $requiredColumns = ['name', 'path', 'action_type', 'web_url', 'description'];
    $missingColumns = array_diff($requiredColumns, $columns);

    if (empty($missingColumns)) {
        echo "✅ Toutes les colonnes requises sont présentes\n";
        exit(0);
    }

    echo "⚠️ Colonnes manquantes: " . implode(', ', $missingColumns) . "\n";
    echo "🔧 Ajout des colonnes manquantes...\n";

    // Ajouter les colonnes manquantes
    Schema::table('pwa_menu_items', function ($table) use ($columns) {
        if (!in_array('name', $columns)) {
            $table->string('name')->nullable();
        }
        if (!in_array('path', $columns)) {
            $table->string('path')->nullable();
        }
        if (!in_array('action_type', $columns)) {
            $table->enum('action_type', ['route', 'web_embed', 'external_link'])->default('route');
        }
        if (!in_array('web_url', $columns)) {
            $table->text('web_url')->nullable();
        }
        if (!in_array('description', $columns)) {
            $table->text('description')->nullable();
        }
    });

    echo "✅ Colonnes ajoutées avec succès\n";

    // Remplir les colonnes avec des données par défaut basées sur les données existantes
    $items = DB::table('pwa_menu_items')->get();
    
    foreach ($items as $item) {
        $updates = [];
        
        // Générer 'name' basé sur 'route' si manquant
        if (empty($item->name ?? null)) {
            $updates['name'] = strtolower(str_replace('-', '_', $item->route ?? $item->label ?? 'unknown'));
        }
        
        // Générer 'path' basé sur 'route' si manquant
        if (empty($item->path ?? null)) {
            $route = $item->route ?? '';
            $updates['path'] = match($route) {
                'home' => '/',
                'recipes' => '/recipes',
                'tips' => '/tips',
                'dinor-tv' => '/dinor-tv',
                'events' => '/events',
                default => '/' . $route
            };
        }
        
        // Action type par défaut
        if (empty($item->action_type ?? null)) {
            $updates['action_type'] = 'route';
        }

        if (!empty($updates)) {
            DB::table('pwa_menu_items')
                ->where('id', $item->id)
                ->update($updates);
        }
    }

    echo "✅ Données par défaut ajoutées\n";

    // Afficher le résultat final
    echo "\n📊 Structure finale:\n";
    $finalColumns = Schema::getColumnListing('pwa_menu_items');
    echo "Colonnes: " . implode(', ', $finalColumns) . "\n";
    
    $count = DB::table('pwa_menu_items')->count();
    echo "Nombre d'éléments: {$count}\n";

    echo "\n🎉 Correction terminée avec succès !\n";
    echo "Vous pouvez maintenant exécuter le seeder ou continuer le déploiement.\n";

} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
    exit(1);
} 