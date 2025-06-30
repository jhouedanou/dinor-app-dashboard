#!/bin/bash

echo "🚀 [FORGE] Script de déploiement pour Laravel Forge"

# 1. Mettre à jour le .env pour la production
echo "⚙️ [ENV] Configuration de l'environnement production..."

# Vérifier si on doit mettre à jour APP_URL
if grep -q "APP_URL=http://localhost:8000" .env; then
    echo "🔧 [ENV] Mise à jour de APP_URL pour la production..."
    sed -i 's|APP_URL=http://localhost:8000|APP_URL=https://new.dinorapp.com|g' .env
fi

# Vérifier si on doit mettre à jour APP_ENV
if grep -q "APP_ENV=local" .env; then
    echo "🔧 [ENV] Mise à jour de APP_ENV pour la production..."
    sed -i 's|APP_ENV=local|APP_ENV=production|g' .env
fi

# 2. Optimiser pour la production
echo "⚡ [OPTIMIZE] Optimisation pour la production..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache

# 3. Migrations
echo "🗃️ [DB] Exécution des migrations..."
php artisan migrate --force

# 4. Permissions
echo "🔐 [PERMS] Configuration des permissions..."
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/
chmod -R 755 public/

# 5. Vérifications finales
echo "✅ [CHECK] Vérifications finales..."

echo "📦 Assets PWA générés:"
ls -la public/pwa/dist/assets/ | head -5

echo ""
echo "📄 Fichiers PWA essentiels:"
ls -la public/manifest.webmanifest public/registerSW.js public/pwa/dist/sw.js

echo ""
echo "⚙️ Configuration actuelle:"
grep -E "(APP_URL|APP_ENV)" .env

echo ""
echo "🎉 [SUCCESS] Déploiement prêt !"
echo ""
echo "📋 [NEXT] Prochaines étapes sur Forge:"
echo "1. Commitez et pushez ces changements"
echo "2. Déclenchez un déploiement sur Forge"
echo "3. Vérifiez que les assets sont accessibles sur https://new.dinorapp.com/"
echo "4. Testez la PWA et le dashboard"