#!/bin/bash

# Script tout-en-un pour builder et packager Dinor App pour macOS
set -e

echo "🚀 Build et packaging complet de Dinor App pour macOS"
echo "=================================================="

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Étape 1: Build de l'app
echo -e "${BLUE}Étape 1/2: Construction de l'application${NC}"
./build-macos.sh

echo ""
echo -e "${BLUE}Étape 2/2: Création du DMG${NC}"
./create-dmg-macos.sh

echo ""
echo -e "${GREEN}🎉 Build et packaging terminés avec succès !${NC}"
echo ""
echo "Fichiers générés :"
echo "📱 App: build/macos/Build/Products/Release/Dinor App - Votre master chef de poche.app"
echo "💿 DMG: DinorApp-macOS-v1.2.0.dmg"
echo ""
echo "Pour distribuer l'app :"
echo "1. Partagez le fichier DMG"
echo "2. Les utilisateurs n'ont qu'à double-cliquer et glisser vers Applications"