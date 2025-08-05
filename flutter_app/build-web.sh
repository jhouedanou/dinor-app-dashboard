#!/bin/bash

# Script pour construire et déployer la version web Flutter de Dinor App
# Usage: ./build-web.sh [serve|deploy]

set -e

echo "🚀 Construction de la version web Flutter..."

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ce script doit être exécuté depuis le répertoire de l'application Flutter."
    exit 1
fi

# Nettoyer les builds précédents
echo "🧹 Nettoyage des builds précédents..."
flutter clean

# Récupérer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Construire la version web
echo "🔨 Construction de la version web..."
flutter build web --release

echo "✅ Version web construite avec succès !"
echo "📁 Fichiers générés dans: build/web/"

# Vérifier si on veut servir localement
if [ "$1" = "serve" ]; then
    echo "🌐 Démarrage du serveur local sur http://localhost:8080"
    echo "Appuyez sur Ctrl+C pour arrêter le serveur"
    cd build/web
    python3 -m http.server 8080
elif [ "$1" = "deploy" ]; then
    echo "🚀 Préparation pour le déploiement..."
    echo "📁 Les fichiers de déploiement sont dans: build/web/"
    echo "💡 Vous pouvez maintenant déployer le contenu de build/web/ sur votre serveur web"
    echo "🔗 Exemples de déploiement:"
    echo "   - Netlify: glissez-déposez le dossier build/web/"
    echo "   - Vercel: importez le projet et configurez le dossier build/web/"
    echo "   - GitHub Pages: poussez le contenu de build/web/ vers la branche gh-pages"
    echo "   - Serveur web: copiez build/web/ vers votre répertoire web public"
else
    echo ""
    echo "📋 Options disponibles:"
    echo "   ./build-web.sh serve    - Construire et servir localement"
    echo "   ./build-web.sh deploy   - Construire pour le déploiement"
    echo "   ./build-web.sh          - Construire seulement"
    echo ""
    echo "🌐 Pour tester localement: cd build/web && python3 -m http.server 8080"
fi 