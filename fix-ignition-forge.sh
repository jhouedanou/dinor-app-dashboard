#!/bin/bash

echo "🔧 === CORRECTION RAPIDE DU PROBLÈME IGNITION ==="

# 1. Nettoyer TOUS les caches
echo "🧹 Nettoyage complet des caches..."
rm -f bootstrap/cache/packages.php
rm -f bootstrap/cache/services.php
rm -f bootstrap/cache/config.php
rm -f bootstrap/cache/routes-v7.php

# 2. Forcer APP_ENV en production
echo "⚙️ Configuration de l'environnement..."
export APP_ENV=production
export APP_DEBUG=false

# 3. Créer un cache de packages sans Ignition
echo "📦 Création du cache de packages production..."
cat > bootstrap/cache/packages.php << 'EOF'
<?php return array (
  'filament/filament' => 
  array (
    'providers' => 
    array (
      0 => 'Filament\\FilamentServiceProvider',
    ),
  ),
  'laravel/sanctum' => 
  array (
    'providers' => 
    array (
      0 => 'Laravel\\Sanctum\\SanctumServiceProvider',
    ),
  ),
  'nunomaduro/collision' => 
  array (
    'providers' => 
    array (
      0 => 'NunoMaduro\\Collision\\Adapters\\Laravel\\CollisionServiceProvider',
    ),
  ),
);
EOF

# 4. Installer les dépendances sans les packages dev
echo "📦 Installation des dépendances production..."
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# 5. Redécouvrir les packages
echo "🔍 Redécouverte des packages..."
php artisan package:discover --ansi

echo "✅ Correction appliquée !" 