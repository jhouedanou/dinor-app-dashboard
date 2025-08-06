#!/bin/bash

# Script de build macOS pour Dinor App
set -e

echo "🖥️  Construction de l'app macOS Dinor App..."

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé ou pas dans le PATH${NC}"
    echo "Installez Flutter: https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

# Afficher la version Flutter
echo -e "${BLUE}🔍 Version Flutter:${NC}"
flutter --version

# Nettoyer le projet
echo -e "${YELLOW}🧹 Nettoyage du projet...${NC}"
flutter clean

# Récupérer les dépendances
echo -e "${YELLOW}📦 Installation des dépendances...${NC}"
flutter pub get

# Construire l'app macOS
echo -e "${YELLOW}🔨 Construction de l'app macOS...${NC}"
flutter build macos --release

# Vérifier que le build a réussi
if [ -d "build/macos/Build/Products/Release/Dinor App - Votre master chef de poche.app" ]; then
    APP_PATH="build/macos/Build/Products/Release/Dinor App - Votre master chef de poche.app"
elif [ -d "build/macos/Build/Products/Release/dinor_app.app" ]; then
    APP_PATH="build/macos/Build/Products/Release/dinor_app.app"
else
    echo -e "${RED}❌ L'app macOS n'a pas été trouvée dans le dossier de build${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App macOS construite avec succès !${NC}"
echo -e "${BLUE}📍 Chemin: $APP_PATH${NC}"

# Obtenir la taille de l'app
APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
echo -e "${BLUE}📊 Taille de l'app: $APP_SIZE${NC}"

# Vérifier les permissions et signature (optionnel)
echo -e "${YELLOW}🔐 Vérification des permissions...${NC}"
codesign -dv "$APP_PATH" 2>/dev/null || echo -e "${YELLOW}⚠️  App non signée (normal en développement)${NC}"

# Instructions d'installation
echo -e "${GREEN}"
echo "🎉 Construction terminée !"
echo ""
echo "Pour installer l'app :"
echo "1. Ouvrez le Finder et naviguez vers:"
echo "   $(pwd)/$APP_PATH"
echo "2. Glissez l'app vers le dossier Applications"
echo "3. Ou double-cliquez pour lancer directement"
echo ""
echo "Pour créer un DMG :"
echo "   ./create-dmg-macos.sh"
echo -e "${NC}"