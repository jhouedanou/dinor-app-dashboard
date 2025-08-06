#!/bin/bash

# Script pour créer un DMG de Dinor App
set -e

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "💿 Création du DMG pour Dinor App..."

# Variables
APP_NAME="Dinor App - Votre master chef de poche"
DMG_NAME="DinorApp-macOS-v1.2.0"
DMG_TEMP="dmg_temp"

# Vérifier que l'app existe
if [ -d "build/macos/Build/Products/Release/$APP_NAME.app" ]; then
    APP_PATH="build/macos/Build/Products/Release/$APP_NAME.app"
elif [ -d "build/macos/Build/Products/Release/dinor_app.app" ]; then
    APP_PATH="build/macos/Build/Products/Release/dinor_app.app"
    APP_NAME="dinor_app"
else
    echo -e "${RED}❌ App macOS non trouvée. Lancez d'abord ./build-macos.sh${NC}"
    exit 1
fi

echo -e "${BLUE}📱 App trouvée: $APP_PATH${NC}"

# Nettoyer le dossier temporaire s'il existe
rm -rf "$DMG_TEMP"
mkdir -p "$DMG_TEMP"

# Copier l'app dans le dossier temporaire
echo -e "${YELLOW}📋 Copie de l'application...${NC}"
cp -R "$APP_PATH" "$DMG_TEMP/"

# Créer un lien vers Applications
echo -e "${YELLOW}🔗 Création du lien vers Applications...${NC}"
ln -s /Applications "$DMG_TEMP/Applications"

# Créer le fichier .DS_Store pour un meilleur agencement (optionnel)
cat > "$DMG_TEMP/.DS_Store_template" << 'EOF'
# Configuration de l'agencement du DMG
# L'utilisateur verra l'app à gauche et le dossier Applications à droite
EOF

# Supprimer l'ancien DMG s'il existe
rm -f "$DMG_NAME.dmg"

# Créer le DMG temporaire
echo -e "${YELLOW}💿 Création du DMG temporaire...${NC}"
hdiutil create -volname "$DMG_NAME" -srcfolder "$DMG_TEMP" -ov -format UDRW "$DMG_NAME-temp.dmg"

# Monter le DMG temporaire
echo -e "${YELLOW}🔧 Configuration du DMG...${NC}"
DEVICE=$(hdiutil attach -readwrite -noverify "$DMG_NAME-temp.dmg" | egrep '^/dev/' | sed 1q | awk '{print $1}')

# Attendre que le volume soit monté
sleep 2

# Configurer l'apparence du DMG
VOLUME_PATH="/Volumes/$DMG_NAME"
if [ -d "$VOLUME_PATH" ]; then
    # Définir l'icône du volume (si disponible)
    if [ -f "assets/icons/app_icon.icns" ]; then
        cp "assets/icons/app_icon.icns" "$VOLUME_PATH/.VolumeIcon.icns"
        SetFile -c icnC "$VOLUME_PATH/.VolumeIcon.icns"
        SetFile -a C "$VOLUME_PATH"
    fi
    
    # Configuration de l'affichage Finder
    osascript << EOF
tell application "Finder"
    tell disk "$DMG_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 920, 440}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set background picture of viewOptions to file ".background:background.png"
        set position of item "$APP_NAME.app" of container window to {160, 205}
        set position of item "Applications" of container window to {360, 205}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF
fi

# Démonter le volume
hdiutil detach "$DEVICE"

# Convertir en DMG final (compressé et read-only)
echo -e "${YELLOW}🗜️  Compression du DMG...${NC}"
hdiutil convert "$DMG_NAME-temp.dmg" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME.dmg"

# Nettoyer les fichiers temporaires
rm -f "$DMG_NAME-temp.dmg"
rm -rf "$DMG_TEMP"

# Vérifier le DMG créé
if [ -f "$DMG_NAME.dmg" ]; then
    DMG_SIZE=$(du -sh "$DMG_NAME.dmg" | cut -f1)
    echo -e "${GREEN}✅ DMG créé avec succès !${NC}"
    echo -e "${BLUE}📍 Fichier: $DMG_NAME.dmg${NC}"
    echo -e "${BLUE}📊 Taille: $DMG_SIZE${NC}"
    echo ""
    echo -e "${GREEN}🎉 Installation:${NC}"
    echo "1. Double-cliquez sur $DMG_NAME.dmg"
    echo "2. Glissez l'app vers le dossier Applications"
    echo "3. Éjectez le volume DMG"
    echo ""
else
    echo -e "${RED}❌ Erreur lors de la création du DMG${NC}"
    exit 1
fi