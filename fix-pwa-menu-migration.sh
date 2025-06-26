#!/bin/bash

echo "🔧 Correction de la migration PWA menu items..."

# 1. Exécuter la migration en attente
echo "📝 Exécution de la migration PWA menu items..."
php artisan migrate --force

# 2. Exécuter le seeder pour peupler la table
echo "🌱 Exécution du seeder PWA menu items..."
php artisan db:seed --class=PwaMenuItemSeeder --force

# 3. Vérifier que la table existe et a des données
echo "🔍 Vérification de la table pwa_menu_items..."
php artisan tinker --execute="
try {
    \$count = \App\Models\PwaMenuItem::count();
    echo 'Nombre d\'éléments de menu: ' . \$count . PHP_EOL;
    if (\$count > 0) {
        \$items = \App\Models\PwaMenuItem::select('name', 'label', 'is_active')->get();
        foreach (\$items as \$item) {
            echo '- ' . \$item->name . ' (' . \$item->label . ') - ' . (\$item->is_active ? 'Actif' : 'Inactif') . PHP_EOL;
        }
    }
} catch (Exception \$e) {
    echo 'Erreur: ' . \$e->getMessage() . PHP_EOL;
}
"

# 4. Tester l'endpoint API
echo "🌐 Test de l'endpoint API..."
curl -s "http://localhost:8000/api/v1/pwa-menu-items" | head -100 || echo "Erreur de test API"

echo "✅ Migration PWA menu items terminée!"