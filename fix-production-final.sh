#!/bin/bash

echo "🚀 [FINAL] Correction finale pour la production"

# 1. Configuration environnement production
echo "⚙️ [ENV] Configuration production..."
sed -i 's/APP_ENV=local/APP_ENV=production/g' .env
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/g' .env
sed -i 's|APP_URL=http://localhost:8000|APP_URL=https://new.dinorapp.com|g' .env
sed -i 's/CACHE_DRIVER=redis/CACHE_DRIVER=file/g' .env
sed -i 's/SESSION_DRIVER=redis/SESSION_DRIVER=file/g' .env

# 2. Nettoyage complet des caches
echo "🧹 [CACHE] Nettoyage complet..."
rm -rf bootstrap/cache/*
rm -rf storage/framework/cache/data/*
rm -rf storage/framework/sessions/*
rm -rf storage/framework/views/*

# 3. Permissions Laravel
echo "🔐 [PERMS] Correction des permissions..."
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/

# 4. Optimisation production
echo "⚡ [OPTIMIZE] Optimisation production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Build PWA final
echo "📦 [PWA] Build PWA final..."
npm run pwa:build

# 6. Vérifications finales
echo "✅ [CHECK] Vérifications finales..."
echo "Configuration .env:"
grep -E "(APP_ENV|APP_DEBUG|APP_URL|CACHE_DRIVER)" .env

echo ""
echo "Assets PWA:"
ls -la public/pwa/dist/assets/ | head -3

echo ""
echo "Permissions storage:"
ls -ld storage/framework/sessions/

echo ""
echo "🎉 [SUCCESS] Application prête pour la production !"
echo ""
echo "📋 [NEXT] Étapes suivantes:"
echo "1. Commitez les changements"
echo "2. Pushez vers le repository"
echo "3. Déclenchez un déploiement sur Forge"
echo "4. Testez https://new.dinorapp.com/"