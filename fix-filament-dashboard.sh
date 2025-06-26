#!/bin/bash

echo "🔧 Correction du Dashboard Filament en production"
echo "================================================="

echo "📦 1. Vérification de l'environnement Docker..."
if ! docker ps | grep -q dinor-app; then
    echo "❌ Le conteneur dinor-app n'est pas en cours d'exécution"
    exit 1
fi
echo "✅ Conteneur dinor-app actif"

echo ""
echo "🧹 2. Nettoyage des caches..."
docker exec dinor-app php artisan config:clear
docker exec dinor-app php artisan route:clear
docker exec dinor-app php artisan view:clear
docker exec dinor-app php artisan cache:clear

echo ""
echo "⚙️  3. Régénération des caches optimisés..."
docker exec dinor-app php artisan config:cache
docker exec dinor-app php artisan route:cache
docker exec dinor-app php artisan view:cache

echo ""
echo "🎨 4. Optimisation Filament..."
docker exec dinor-app php artisan filament:optimize-clear
docker exec dinor-app php artisan filament:cache-components

echo ""
echo "🔍 5. Vérification des routes Filament..."
echo "Routes disponibles :"
docker exec dinor-app php artisan route:list | grep admin | head -10

echo ""
echo "📋 6. Test des ressources critiques..."
RESOURCES=("admin/dinor-tvs" "admin/categories" "admin/users" "admin/pwa-menu-items")

for resource in "${RESOURCES[@]}"; do
    if docker exec dinor-app php artisan route:list | grep -q "$resource"; then
        echo "✅ $resource - OK"
    else
        echo "❌ $resource - MANQUANTE"
    fi
done

echo ""
echo "🎯 7. Vérification du panel Filament..."
docker exec dinor-app php -r "
    require 'vendor/autoload.php';
    \$app = require 'bootstrap/app.php';
    \$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
    
    try {
        \$panel = Filament\Facades\Filament::getDefaultPanel();
        echo '✅ Panel Filament configuré : ' . \$panel->getId() . PHP_EOL;
        echo '📂 Groupes de navigation : ' . implode(', ', \$panel->getNavigationGroups()) . PHP_EOL;
    } catch (Exception \$e) {
        echo '❌ Erreur panel : ' . \$e->getMessage() . PHP_EOL;
    }
"

echo ""
echo "🔄 8. Redémarrage final du conteneur..."
docker restart dinor-app
sleep 10

echo ""
echo "✅ CORRECTION TERMINÉE !"
echo ""
echo "🌐 Accédez maintenant au dashboard Filament :"
echo "   http://localhost:8000/admin"
echo ""
echo "📋 Les ressources suivantes devraient être visibles :"
echo "   • Dinor TV (Contenu)"
echo "   • Catégories (Contenu)" 
echo "   • Utilisateurs (Administration)"
echo "   • Configuration PWA (Configuration PWA)" 