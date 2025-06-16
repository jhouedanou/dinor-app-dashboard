#!/bin/bash

echo "🎨 Correction des problèmes CSS Dinor Dashboard"
echo "==============================================="

# Fonction pour exécuter une commande dans le conteneur
exec_in_container() {
    local container=$1
    local command=$2
    echo "🔧 Exécution dans $container: $command"
    docker exec -it "$container" bash -c "$command"
}

echo ""
echo "1️⃣ Nettoyage des caches Laravel..."
exec_in_container "dinor-app" "php artisan cache:clear"
exec_in_container "dinor-app" "php artisan config:clear"
exec_in_container "dinor-app" "php artisan view:clear"
exec_in_container "dinor-app" "php artisan route:clear"

echo ""
echo "2️⃣ Publication des assets Filament..."
exec_in_container "dinor-app" "php artisan filament:assets"

echo ""
echo "3️⃣ Recréation du lien symbolique storage..."
exec_in_container "dinor-app" "php artisan storage:link --force"

echo ""
echo "4️⃣ Nettoyage et reconstruction des assets frontend..."
exec_in_container "dinor-app" "rm -rf node_modules/.vite"
exec_in_container "dinor-app" "rm -rf public/build"
exec_in_container "dinor-app" "npm run build"

echo ""
echo "🎨 Actualisation du thème personnalisé..."
exec_in_container "dinor-app" "php artisan config:cache"

echo ""
echo "5️⃣ Optimisation Laravel..."
exec_in_container "dinor-app" "php artisan optimize"

echo ""
echo "6️⃣ Vérification des assets générés..."
exec_in_container "dinor-app" "ls -la public/build/assets/"

echo ""
echo "7️⃣ Test de l'accès aux CSS..."
exec_in_container "dinor-app" "curl -I http://localhost/build/assets/app-*.css || echo 'CSS non accessible'"

echo ""
echo "✅ Correction terminée !"
echo ""
echo "🔍 Si le problème persiste, vérifiez :"
echo "   - Les permissions : docker exec -it dinor-app chown -R www-data:www-data /var/www/html/public"
echo "   - Les logs : docker logs dinor-app"
echo "   - L'accès direct : http://localhost:8000/build/assets/"
echo ""
echo "💡 Alternative : Utilisez les CSS par défaut de Filament en supprimant le thème personnalisé" 