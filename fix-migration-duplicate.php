<?php
/**
 * Script pour résoudre le conflit de migration pwa_menu_items
 * À exécuter sur le serveur Forge
 */

require_once 'vendor/autoload.php';

// Charger Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

echo "🔧 === RÉSOLUTION CONFLIT MIGRATION PWA_MENU_ITEMS ===\n";

try {
    // Vérifier si la table existe
    $tableExists = Schema::hasTable('pwa_menu_items');
    echo "Table pwa_menu_items existe : " . ($tableExists ? "OUI" : "NON") . "\n";
    
    if ($tableExists) {
        // Vérifier si la migration problématique est déjà enregistrée
        $migrationExists = DB::table('migrations')
            ->where('migration', '2025_06_26_185701_create_pwa_menu_items_table')
            ->exists();
            
        echo "Migration dans la table : " . ($migrationExists ? "OUI" : "NON") . "\n";
        
        if (!$migrationExists) {
            // Marquer la migration comme exécutée
            $maxBatch = DB::table('migrations')->max('batch') ?? 0;
            
            DB::table('migrations')->insert([
                'migration' => '2025_06_26_185701_create_pwa_menu_items_table',
                'batch' => $maxBatch + 1
            ]);
            
            echo "✅ Migration marquée comme exécutée (batch " . ($maxBatch + 1) . ")\n";
        } else {
            echo "ℹ️ Migration déjà marquée comme exécutée\n";
        }
        
        // Vérifier les colonnes existantes
        $columns = Schema::getColumnListing('pwa_menu_items');
        echo "Colonnes actuelles : " . implode(', ', $columns) . "\n";
        
        // Vérifier si on doit ajouter des colonnes manquantes
        $requiredColumns = ['name', 'path', 'action_type', 'web_url', 'description'];
        $missingColumns = array_diff($requiredColumns, $columns);
        
        if (!empty($missingColumns)) {
            echo "⚠️ Colonnes manquantes détectées : " . implode(', ', $missingColumns) . "\n";
            echo "💡 Vous devrez peut-être ajouter ces colonnes manuellement ou créer une migration de mise à jour\n";
        } else {
            echo "✅ Toutes les colonnes requises sont présentes\n";
        }
        
    } else {
        echo "❌ La table n'existe pas. La migration originale n'a pas été exécutée.\n";
    }
    
    echo "\n🎉 Script terminé avec succès !\n";
    
} catch (Exception $e) {
    echo "❌ Erreur : " . $e->getMessage() . "\n";
    exit(1);
} 