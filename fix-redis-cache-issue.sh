#!/bin/bash

echo "🔧 [REDIS] Correction du problème Redis/Cache"

# 1. Sauvegarder le .env actuel
echo "💾 [BACKUP] Sauvegarde du fichier .env..."
cp .env .env.backup-$(date +%Y%m%d-%H%M%S)

# 2. Remplacer Redis par file dans .env
echo "⚙️ [CONFIG] Configuration du cache en mode file..."
sed -i 's/CACHE_DRIVER=redis/CACHE_DRIVER=file/g' .env
sed -i 's/SESSION_DRIVER=redis/SESSION_DRIVER=file/g' .env
sed -i 's/QUEUE_CONNECTION=redis/QUEUE_CONNECTION=sync/g' .env

# 3. Supprimer les caches existants
echo "🧹 [CLEAR] Suppression des caches existants..."
rm -rf bootstrap/cache/config.php
rm -rf bootstrap/cache/routes-*.php
rm -rf bootstrap/cache/services.php
rm -rf storage/framework/cache/data/*
rm -rf storage/framework/sessions/*
rm -rf storage/framework/views/*

# 4. Recréer les répertoires nécessaires
echo "📁 [DIRS] Recréation des répertoires..."
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs

# 5. Corriger les permissions
echo "🔐 [PERMS] Correction des permissions..."
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/

# 6. Nettoyer et recréer les caches
echo "🔄 [CACHE] Régénération des caches..."
php artisan cache:clear 2>/dev/null || echo "Cache déjà vide"
php artisan config:clear 2>/dev/null || echo "Config déjà vide"
php artisan view:clear 2>/dev/null || echo "Views déjà vides"
php artisan route:clear 2>/dev/null || echo "Routes déjà vides"

php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Vérifier la configuration
echo "✅ [CHECK] Vérification de la configuration..."
echo "Configuration cache actuelle:"
grep -E "(CACHE_DRIVER|SESSION_DRIVER|QUEUE_CONNECTION)" .env

echo ""
echo "Répertoires de cache:"
ls -la storage/framework/

echo ""
echo "🎉 [SUCCESS] Problème Redis corrigé !"
echo ""
echo "📋 [CHANGES] Changements effectués:"
echo "- CACHE_DRIVER: redis → file"
echo "- SESSION_DRIVER: redis → file (si présent)"
echo "- QUEUE_CONNECTION: redis → sync (si présent)"
echo "- Caches supprimés et régénérés"
echo "- Permissions corrigées"