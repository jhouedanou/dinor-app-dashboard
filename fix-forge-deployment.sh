#!/bin/bash

echo "🔧 === CORRECTION DU DÉPLOIEMENT FORGE ==="
echo ""

# 1. Vérifier l'environnement
echo "ℹ️  Environnement actuel : $APP_ENV"

# 2. Si en production, supprimer Ignition du bootstrap
if [ "$APP_ENV" = "production" ] || [ -z "$APP_ENV" ]; then
    echo "🔍 Recherche des références à Ignition..."
    
    # Rechercher dans bootstrap/app.php
    if grep -q "Spatie\\\LaravelIgnition" bootstrap/app.php 2>/dev/null; then
        echo "⚠️  Référence à Ignition trouvée dans bootstrap/app.php"
        echo "🧹 Suppression de la référence..."
        sed -i '/Spatie\\LaravelIgnition/d' bootstrap/app.php
    fi
    
    # Rechercher dans config/app.php
    if grep -q "Spatie\\\LaravelIgnition" config/app.php 2>/dev/null; then
        echo "⚠️  Référence à Ignition trouvée dans config/app.php"
        echo "🧹 Suppression de la référence..."
        sed -i '/Spatie\\LaravelIgnition/d' config/app.php
    fi
    
    # Rechercher dans bootstrap/cache/packages.php
    if [ -f "bootstrap/cache/packages.php" ]; then
        if grep -q "spatie/laravel-ignition" bootstrap/cache/packages.php 2>/dev/null; then
            echo "⚠️  Référence à Ignition trouvée dans le cache"
            echo "🧹 Nettoyage du cache..."
            rm -f bootstrap/cache/packages.php
            rm -f bootstrap/cache/services.php
        fi
    fi
fi

# 3. Installer les dépendances de production uniquement
echo ""
echo "📦 Installation des dépendances de production..."
composer install --no-dev --optimize-autoloader --no-interaction

# 4. Nettoyer et reconstruire le cache
echo ""
echo "🔄 Reconstruction du cache..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 5. Optimiser pour la production
echo ""
echo "⚡ Optimisation pour la production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Vérifier les permissions
echo ""
echo "🔐 Vérification des permissions..."
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true

echo ""
echo "✅ Corrections appliquées avec succès !"
echo ""
echo "📋 Actions effectuées :"
echo "  - Suppression des références à Ignition"
echo "  - Installation des dépendances de production"
echo "  - Nettoyage et reconstruction du cache"
echo "  - Optimisation pour la production"
echo "  - Correction des permissions"
echo ""
echo "🚀 Vous pouvez maintenant relancer le déploiement sur Forge" 