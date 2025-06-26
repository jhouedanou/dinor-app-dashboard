#!/bin/bash

echo "🔄 Reconstruction complète de la PWA..."

# 1. Nettoyer les anciens builds
echo "🧹 Nettoyage des anciens builds..."
rm -rf public/pwa/dist/*
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf src/pwa/dist 2>/dev/null || true

# 2. Supprimer le cache du service worker
echo "🗑️ Suppression du cache service worker..."
rm -rf public/pwa/sw.js 2>/dev/null || true
rm -rf public/pwa/workbox-* 2>/dev/null || true

# 3. Réinstaller les dépendances NPM
echo "📦 Réinstallation des dépendances NPM..."
rm -rf node_modules package-lock.json
npm install

# 4. Build complet de la PWA avec debug
echo "🏗️ Build PWA avec informations de debug..."
npm run pwa:rebuild

# 5. Vérifier que les fichiers ont été générés
echo "🔍 Vérification des fichiers générés..."
if [ -d "public/pwa/dist" ]; then
    echo "✅ Dossier public/pwa/dist trouvé"
    ls -la public/pwa/dist/
else
    echo "❌ Dossier public/pwa/dist non trouvé"
    exit 1
fi

# 6. Créer un nouveau fichier de version pour forcer le cache busting
echo "📝 Mise à jour de la version PWA..."
echo "$(date +%s)" > public/pwa/version.txt
echo "PWA_VERSION=$(date +%s)" > public/pwa/.env

# 7. Vérifier les erreurs JavaScript potentielles
echo "🔍 Vérification des erreurs JavaScript..."
if [ -f "public/pwa/dist/assets/main.*.js" ]; then
    echo "✅ Fichier JavaScript principal trouvé"
else
    echo "❌ Fichier JavaScript principal non trouvé"
    ls -la public/pwa/dist/assets/ || echo "Aucun asset trouvé"
fi

# 8. Permissions
echo "🔧 Configuration des permissions..."
chmod -R 755 public/pwa/
chown -R $USER:$USER public/pwa/ 2>/dev/null || true

echo "🎉 Reconstruction PWA terminée!"
echo ""
echo "📋 Actions recommandées:"
echo "   1. Vider le cache du navigateur (Ctrl+Shift+R)"
echo "   2. Désinstaller/réinstaller la PWA si installée"
echo "   3. Tester avec un navigateur privé"
echo ""