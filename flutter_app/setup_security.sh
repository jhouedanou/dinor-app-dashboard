#!/bin/bash

# Script de setup pour configurer les clés d'API de Dinor App
# Usage: ./setup_security.sh

echo "🔒 Setup de sécurité - Dinor App v3.1.0"
echo "========================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  Ce script vous aide à configurer les clés d'API manquantes${NC}"
echo ""

# Vérifier si les fichiers de configuration existent
echo "📋 Vérification des fichiers de configuration..."

# Firebase Android
if [ ! -f "android/app/google-services.json" ]; then
    echo -e "${RED}❌ android/app/google-services.json manquant${NC}"
    echo "   👉 Copiez depuis android/app/google-services.json.example"
    MISSING_FILES=true
else
    echo -e "${GREEN}✅ android/app/google-services.json présent${NC}"
fi

# Firebase iOS
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${RED}❌ ios/Runner/GoogleService-Info.plist manquant${NC}"
    echo "   👉 Copiez depuis ios/Runner/GoogleService-Info.plist.example"
    MISSING_FILES=true
else
    echo -e "${GREEN}✅ ios/Runner/GoogleService-Info.plist présent${NC}"
fi

# Vérifier les clés dans le code
echo ""
echo "🔍 Vérification des clés d'API..."

if grep -q "YOUR_FIREBASE_API_KEY_HERE" lib/firebase_options.dart; then
    echo -e "${RED}❌ Clé d'API à configurer dans lib/firebase_options.dart${NC}"
    API_KEYS_MISSING=true
else
    echo -e "${GREEN}✅ Clé d'API configurée dans firebase_options.dart${NC}"
fi

if grep -q "YOUR_FIREBASE_API_KEY_HERE" android/app/src/main/res/values/firebase_values.xml; then
    echo -e "${RED}❌ Clé d'API à configurer dans firebase_values.xml${NC}"
    API_KEYS_MISSING=true
else
    echo -e "${GREEN}✅ Clé d'API configurée dans firebase_values.xml${NC}"
fi

# Afficher les instructions si nécessaire
if [ "$MISSING_FILES" = true ] || [ "$API_KEYS_MISSING" = true ]; then
    echo ""
    echo -e "${YELLOW}📝 Instructions de configuration :${NC}"
    echo "================================="
    echo ""
    echo "1. 🔥 Configurez Firebase :"
    echo "   cp android/app/google-services.json.example android/app/google-services.json"
    echo "   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist"
    echo ""
    echo "2. 🔑 Remplacez les clés d'API :"
    echo "   - Dans lib/firebase_options.dart : YOUR_FIREBASE_API_KEY_HERE"
    echo "   - Dans android/.../firebase_values.xml : YOUR_FIREBASE_API_KEY_HERE"
    echo ""
    echo "3. 📋 Créez votre fichier .env :"
    echo "   cp .env.example .env"
    echo ""
    echo "4. 🏗️ Reconstruisez l'app :"
    echo "   flutter clean && flutter pub get && flutter build apk --release"
    echo ""
    echo -e "${RED}⚠️  N'oubliez pas d'ajouter vos vraies clés Firebase !${NC}"
else
    echo ""
    echo -e "${GREEN}🎉 Configuration complète ! L'app est prête.${NC}"
    echo ""
    echo "Pour rebuilder l'APK :"
    echo "flutter clean && flutter pub get && flutter build apk --release"
fi

echo ""
echo "📖 Consultez SECURITY_README.md pour plus de détails"