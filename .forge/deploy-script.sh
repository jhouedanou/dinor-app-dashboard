cd /home/forge/your-site-directory

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

# Exécuter les migrations
php artisan migrate --force

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