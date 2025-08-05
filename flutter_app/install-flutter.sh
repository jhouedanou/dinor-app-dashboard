#!/bin/bash

# Script d'installation Flutter pour Netlify
set -e

echo "📦 Installation de Flutter pour Netlify..."

# Vérifier si Flutter est déjà installé
if command -v flutter &> /dev/null; then
    echo "✅ Flutter est déjà installé"
    flutter --version
    exit 0
fi

# Installer les dépendances système
echo "🔧 Installation des dépendances système..."
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Télécharger et installer Flutter
echo "📥 Téléchargement de Flutter..."
FLUTTER_VERSION=${FLUTTER_VERSION:-"stable"}
FLUTTER_HOME="$HOME/flutter"

# Cloner Flutter
git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION --depth 1 $FLUTTER_HOME

# Ajouter Flutter au PATH
export PATH="$FLUTTER_HOME/bin:$PATH"

# Configurer Flutter
echo "⚙️ Configuration de Flutter..."
flutter config --no-analytics
flutter config --enable-web
flutter doctor

# Vérifier l'installation
echo "✅ Installation Flutter terminée !"
flutter --version

echo "🚀 Flutter est prêt à être utilisé !" 