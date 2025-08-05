#!/bin/bash

# Script pour construire et déployer la version web Flutter de Dinor App
# Usage: ./build-web.sh [serve|deploy]

set -e

# Vérifier que le script est exécutable
if [ ! -x "$0" ]; then
    echo "❌ Le script n'est pas exécutable. Ajout des permissions..."
    chmod +x "$0"
fi

echo "🚀 Construction de la version web Flutter..."

# Vérifier que Flutter est installé et l'installer si nécessaire
if ! command -v flutter &> /dev/null; then
    echo "📦 Flutter n'est pas installé. Installation automatique..."
    
    # Exécuter le script d'installation Flutter
    if [ -f "./install-flutter.sh" ]; then
        echo "📦 Utilisation du script d'installation Flutter..."
        chmod +x ./install-flutter.sh
        source ./install-flutter.sh
    else
        # Installation de base si le script n'existe pas
        git clone https://github.com/flutter/flutter.git -b stable --depth 1
        export PATH="$PATH:`pwd`/flutter/bin"
        flutter config --enable-web
    fi
    
    echo "✅ Flutter installé avec succès !"
else
    echo "✅ Flutter est déjà installé"
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