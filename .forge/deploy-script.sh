cd /home/forge/new.dinorapp.com

# Mettre à jour le code
git pull origin main

# Nettoyer les caches AVANT l'installation des dépendances
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Supprimer les fichiers de cache qui pourraient contenir des références aux packages dev
rm -f bootstrap/cache/packages.php
rm -f bootstrap/cache/services.php

# Installer les dépendances de production uniquement
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Redécouvrir les packages (sans les packages dev)
php artisan package:discover --ansi

# Vérifier les migrations en attente avant de les exécuter
echo "Migrations en attente :"
php artisan migrate:status | grep "No"

# Exécuter les migrations avec logs détaillés
echo "Exécution des migrations..."
php artisan migrate --force --verbose

# Vérifier que les colonnes content_type et content_id existent maintenant
echo "Vérification de la structure de la table push_notifications :"
php artisan tinker --execute="echo 'Colonnes de push_notifications: '; print_r(array_keys(Schema::getColumnListing('push_notifications')));"

# Construire les assets
npm install --production
npm run build

# Optimiser l'application
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:cache-components

# Permissions
chmod -R 755 storage bootstrap/cache

# Redémarrer les queues
php artisan queue:restart

# Recharger PHP-FPM
sudo -S service php8.2-fpm reload 