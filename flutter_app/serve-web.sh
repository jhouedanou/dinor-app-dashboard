#!/bin/bash

# Script pour servir l'application web Flutter localement
# Usage: ./serve-web.sh

set -e

echo "🌐 Démarrage du serveur web local..."

# Vérifier que le build web existe
if [ ! -d "build/web" ]; then
    echo "❌ Le dossier build/web n'existe pas. Construisez d'abord l'application avec ./build-web.sh"
    exit 1
fi

echo "📁 Dossier de build trouvé: build/web/"
echo "🚀 Démarrage du serveur sur http://localhost:8080"
echo "📱 Ouvrez votre navigateur sur l'URL ci-dessus"
echo "⏹️  Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

cd build/web
python3 -m http.server 8080 