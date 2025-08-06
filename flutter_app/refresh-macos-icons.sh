#!/bin/bash

# Script pour forcer le rechargement des icônes macOS
echo "🔄 Rechargement des icônes macOS..."

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Nettoyage du cache d'icônes macOS...${NC}"

# Nettoyer le cache d'icônes du système
sudo rm -rf /Library/Caches/com.apple.iconservices.store
killall Dock
killall Finder

# Nettoyer le cache d'icônes utilisateur
rm -rf ~/Library/Caches/com.apple.iconservices.store

echo -e "${YELLOW}🔨 Reconstruction de l'app macOS...${NC}"

# Nettoyer et rebuilder l'app Flutter
flutter clean
flutter pub get

# Rebuild l'app macOS
flutter build macos --release

echo -e "${GREEN}✅ Icônes mises à jour !${NC}"
echo ""
echo "L'app se trouve dans :"
echo "build/macos/Build/Products/Release/Dinor App - Votre master chef de poche.app"
echo ""
echo -e "${BLUE}💡 Si l'icône n'apparaît toujours pas :${NC}"
echo "1. Redémarrez votre Mac"
echo "2. Ou attendez quelques minutes que le cache se mette à jour"
echo "3. Vous pouvez aussi faire glisser l'app vers Applications"