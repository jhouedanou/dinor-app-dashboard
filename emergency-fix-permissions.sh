#!/bin/bash

echo "🚨 CORRECTIF D'URGENCE - Permissions Git/PWA"

# 1. Reset git en force (attention: perte des changements locaux)
echo "🔄 Reset Git forcé..."
git reset --hard HEAD 2>/dev/null || true
git clean -fd 2>/dev/null || true

# 2. Suppression complète du dossier PWA problématique
echo "🗑️ Suppression complète PWA..."
rm -rf public/pwa/ 2>/dev/null || sudo rm -rf public/pwa/

# 3. Recréation du dossier avec bonnes permissions
echo "📁 Recréation du dossier PWA..."
mkdir -p public/pwa/dist
mkdir -p public/pwa/icons
mkdir -p public/pwa/styles
mkdir -p public/pwa/components/navigation

# 4. Permissions appropriées
echo "🔐 Configuration des permissions..."
chown -R forge:forge public/ 2>/dev/null || sudo chown -R forge:forge public/
chmod -R 755 public/pwa/

# 5. Pull Git propre
echo "📥 Pull Git propre..."
git fetch origin main
git reset --hard origin/main

# 6. Vérification finale
echo "🔍 Vérification finale..."
if [ -d "public/pwa" ]; then
    echo "✅ Dossier PWA recrée"
    ls -la public/pwa/ || echo "Dossier vide (normal)"
else
    echo "❌ Problème persistant"
    exit 1
fi

echo "🎉 Correctif d'urgence terminé!"
echo "📋 Prochaines étapes:"
echo "   1. Lancer le déploiement normal"
echo "   2. Rebuilder la PWA"
echo "   3. Tester l'application"