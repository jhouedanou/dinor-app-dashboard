#!/bin/bash

# Script de correction PWA pour Dinor App
echo "🚀 Correction PWA - Build et déploiement"

# Nettoyage des anciens fichiers
echo "🧹 Nettoyage des anciens fichiers PWA..."
rm -rf public/pwa/dist/*

# Build PWA
echo "🔨 Build PWA..."
npm run pwa:build

# Vérification que le fichier index.html existe
if [ -f "public/pwa/dist/index.html" ]; then
    echo "✅ index.html généré avec succès"
    ls -la public/pwa/dist/index.html
else
    echo "❌ ERREUR: index.html n'a pas été généré"
    exit 1
fi

# Afficher les fichiers générés
echo "📁 Fichiers PWA générés:"
ls -la public/pwa/dist/

# Instructions pour le serveur
echo ""
echo "📋 INSTRUCTIONS POUR LE SERVEUR:"
echo "1. Copier tous les fichiers de public/pwa/dist/ vers /var/www/html/public/pwa/dist/"
echo "2. Vérifier les permissions (chown -R www-data:www-data /var/www/html/public/pwa/dist/)"
echo "3. Redémarrer nginx/apache si nécessaire"

# Optionnel: Si vous utilisez rsync pour le déploiement
if command -v rsync >/dev/null 2>&1; then
    echo ""
    echo "📤 Commande de déploiement suggérée (remplacez SERVER_IP):"
    echo "rsync -avz --delete public/pwa/dist/ user@SERVER_IP:/var/www/html/public/pwa/dist/"
fi

echo ""
echo "✅ Script terminé avec succès!" 