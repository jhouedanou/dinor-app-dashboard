#!/bin/bash

# Script de correction pour la migration pages problématique
echo "🔧 === CORRECTION MIGRATION PAGES URL FIELDS ==="
echo ""

# Fonction pour les logs
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1"
}

# Vérifier l'environnement
if [ -f .env ]; then
    log_success "Fichier .env trouvé"
else
    log_error "Fichier .env non trouvé"
    exit 1
fi

# Vérifier la base de données
log_info "🗄️ Vérification de la structure de la table pages..."

# Diagnostiquer le problème
log_info "📊 Diagnostic de la table pages..."

# Script PHP pour vérifier la structure
cat > check_pages_structure.php << 'EOF'
<?php

require_once 'vendor/autoload.php';

// Charger Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

echo "🔍 Vérification de la structure de la table pages...\n";

try {
    // Vérifier si la table existe
    if (!Schema::hasTable('pages')) {
        echo "❌ La table 'pages' n'existe pas\n";
        exit(1);
    }
    
    echo "✅ Table 'pages' existe\n";
    
    // Lister toutes les colonnes
    $columns = Schema::getColumnListing('pages');
    echo "📋 Colonnes existantes dans 'pages':\n";
    foreach ($columns as $column) {
        echo "   - $column\n";
    }
    
    echo "\n🔍 Vérification des colonnes problématiques:\n";
    
    // Vérifier chaque colonne individuellement
    $checkColumns = ['featured_image', 'url', 'embed_url', 'is_external'];
    
    foreach ($checkColumns as $column) {
        if (Schema::hasColumn('pages', $column)) {
            echo "✅ Colonne '$column' existe\n";
        } else {
            echo "❌ Colonne '$column' manquante\n";
        }
    }
    
    // Vérifier les migrations
    echo "\n📊 État des migrations liées aux pages:\n";
    $migrations = DB::table('migrations')
        ->where('migration', 'like', '%pages%')
        ->orderBy('batch')
        ->get();
    
    foreach ($migrations as $migration) {
        echo "   ✅ {$migration->migration} (batch: {$migration->batch})\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\n🎉 Diagnostic terminé\n";
EOF

# Exécuter le diagnostic
log_info "🚀 Exécution du diagnostic..."
php check_pages_structure.php

# Nettoyer le fichier temporaire
rm check_pages_structure.php

echo ""
log_info "🔧 Application de la correction..."

# Marquer la migration problématique comme exécutée si les colonnes existent déjà
log_info "📝 Tentative de correction de la migration..."

# Script PHP pour corriger la migration
cat > fix_pages_migration.php << 'EOF'
<?php

require_once 'vendor/autoload.php';

// Charger Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

echo "🔧 Correction de la migration pages...\n";

try {
    $migrationName = '2025_06_27_195245_add_url_fields_to_pages_table';
    
    // Vérifier si la migration est déjà marquée comme exécutée
    $migrationExists = DB::table('migrations')
        ->where('migration', $migrationName)
        ->exists();
    
    if ($migrationExists) {
        echo "✅ Migration déjà marquée comme exécutée\n";
    } else {
        // Vérifier si les colonnes existent
        $urlExists = Schema::hasColumn('pages', 'url');
        $embedUrlExists = Schema::hasColumn('pages', 'embed_url');
        $isExternalExists = Schema::hasColumn('pages', 'is_external');
        
        if ($urlExists && $embedUrlExists && $isExternalExists) {
            // Les colonnes existent déjà, marquer la migration comme exécutée
            $batch = DB::table('migrations')->max('batch') + 1;
            
            DB::table('migrations')->insert([
                'migration' => $migrationName,
                'batch' => $batch
            ]);
            
            echo "✅ Migration marquée comme exécutée (colonnes déjà présentes)\n";
        } else {
            echo "⚠️ Certaines colonnes manquent, la migration doit être exécutée normalement\n";
        }
    }
    
} catch (Exception $e) {
    echo "❌ Erreur lors de la correction: " . $e->getMessage() . "\n";
    exit(1);
}

echo "🎉 Correction terminée\n";
EOF

# Exécuter la correction
php fix_pages_migration.php

# Nettoyer le fichier temporaire
rm fix_pages_migration.php

echo ""
log_info "🔄 Tentative de migration normale..."

# Essayer de faire la migration normalement
php artisan migrate --force

if [ $? -eq 0 ]; then
    log_success "Migration réussie !"
else
    log_warning "Migration échouée, mais la correction manuelle a pu résoudre le problème"
fi

echo ""
log_success "=== CORRECTION TERMINÉE ==="
echo ""
echo "📋 Prochaines étapes :"
echo "1. Vérifiez que l'application fonctionne correctement"
echo "2. Testez les fonctionnalités des pages"
echo "3. Si problème persiste, contactez le support"
echo "" 