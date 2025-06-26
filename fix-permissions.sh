#!/bin/bash

echo "🔧 Correction des permissions en production..."

# 1. Changer le propriétaire des fichiers PWA vers forge
echo "👤 Correction du propriétaire des fichiers..."
chown -R forge:forge public/pwa/ 2>/dev/null || sudo chown -R forge:forge public/pwa/

# 2. Définir les permissions appropriées
echo "🔐 Configuration des permissions..."
chmod -R 755 public/pwa/
chmod -R 644 public/pwa/*.html 2>/dev/null || true
chmod -R 644 public/pwa/*.css 2>/dev/null || true
chmod -R 644 public/pwa/*.js 2>/dev/null || true

# 3. Permissions spéciales pour les dossiers
echo "📁 Permissions des dossiers..."
find public/pwa/ -type d -exec chmod 755 {} \;
find public/pwa/ -type f -exec chmod 644 {} \;

# 4. Supprimer les fichiers problématiques en force
echo "🗑️ Suppression forcée des fichiers problématiques..."
rm -rf public/pwa/dist/* 2>/dev/null || true
rm -rf public/pwa/components/*.js 2>/dev/null || true
rm -rf public/pwa/app.js 2>/dev/null || true
rm -rf public/pwa/README.md 2>/dev/null || true

# 5. Recréer les dossiers nécessaires
echo "📂 Recréation des dossiers..."
mkdir -p public/pwa/dist
mkdir -p public/pwa/icons
mkdir -p public/pwa/styles
mkdir -p public/pwa/components/navigation

# 6. Permissions finales
chmod -R 755 public/pwa/
chown -R forge:forge public/pwa/ 2>/dev/null || sudo chown -R forge:forge public/pwa/

echo "✅ Permissions corrigées!"

# 7. Test de création de fichier
echo "🧪 Test de création de fichier..."
echo "test" > public/pwa/test-permissions.txt
if [ -f "public/pwa/test-permissions.txt" ]; then
    echo "✅ Test d'écriture réussi"
    rm public/pwa/test-permissions.txt
else
    echo "❌ Problème de permissions persistant"
    exit 1
fi

echo "🎉 Corrections des permissions terminées!"