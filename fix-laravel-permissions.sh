#!/bin/bash

echo "🔐 [PERMS] Correction des permissions Laravel"

# 1. Correction des permissions storage
echo "📁 [STORAGE] Correction des permissions storage..."
sudo chown -R $USER:www-data storage/
sudo chmod -R 775 storage/
sudo chmod -R 775 storage/framework/
sudo chmod -R 775 storage/framework/sessions/
sudo chmod -R 775 storage/framework/cache/
sudo chmod -R 775 storage/framework/views/
sudo chmod -R 775 storage/logs/
sudo chmod -R 775 storage/app/

# 2. Correction des permissions bootstrap/cache
echo "📁 [BOOTSTRAP] Correction des permissions bootstrap/cache..."
sudo chown -R $USER:www-data bootstrap/cache/
sudo chmod -R 775 bootstrap/cache/

# 3. Correction des permissions public
echo "📁 [PUBLIC] Correction des permissions public..."
sudo chown -R $USER:www-data public/
sudo chmod -R 755 public/

# 4. Créer les répertoires manquants si nécessaire
echo "📂 [DIRS] Création des répertoires Laravel..."
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p storage/app/public

# 5. Nettoyer les caches
echo "🧹 [CACHE] Nettoyage des caches..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear

# 6. Régénérer les caches
echo "🔄 [REBUILD] Régénération des caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Vérifier les permissions finales
echo "✅ [CHECK] Vérification des permissions..."
echo "Storage framework:"
ls -la storage/framework/
echo ""
echo "Sessions:"
ls -la storage/framework/sessions/ | head -3
echo ""
echo "Bootstrap cache:"
ls -la bootstrap/cache/ | head -3

echo ""
echo "🎉 [SUCCESS] Permissions corrigées !"
echo ""
echo "📋 [INFO] Permissions définies:"
echo "- storage/: 775 (rwxrwxr-x)"
echo "- bootstrap/cache/: 775 (rwxrwxr-x)"
echo "- public/: 755 (rwxr-xr-x)"
echo "- Propriétaire: $USER:www-data"