#!/bin/bash

echo "🚀 Configuration pour tester l'application Dinor sur téléphone"
echo ""

# 1. Vérifier l'environnement
echo "📋 Vérification de l'environnement..."

# Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js non installé"
    echo "   Installer depuis: https://nodejs.org"
    exit 1
fi

# React Native CLI
if command -v react-native &> /dev/null; then
    echo "✅ React Native CLI: $(react-native --version | head -1)"
else
    echo "⚠️  React Native CLI non installé"
    echo "   Installation: npm install -g react-native-cli"
    npm install -g react-native-cli
fi

# Android SDK (si disponible)
if [ -n "$ANDROID_HOME" ]; then
    echo "✅ Android SDK: $ANDROID_HOME"
    
    # Vérifier ADB
    if command -v adb &> /dev/null; then
        echo "✅ ADB disponible"
        
        # Lister les appareils connectés
        echo ""
        echo "📱 Appareils Android connectés:"
        adb devices
    else
        echo "❌ ADB non trouvé dans PATH"
    fi
else
    echo "⚠️  ANDROID_HOME non configuré"
    echo "   Configurer Android Studio et SDK"
fi

echo ""
echo "📋 Instructions pour tester sur téléphone:"
echo ""
echo "🤖 ANDROID:"
echo "1. Activer 'Options développeur' sur votre téléphone"
echo "2. Activer 'Débogage USB'"
echo "3. Connecter en USB"
echo "4. Lancer: npm run android"
echo ""
echo "🍎 iOS (nécessite Mac + Xcode):"
echo "1. Ouvrir: open ios/DinorApp.xcworkspace"
echo "2. Connecter iPhone en USB"
echo "3. Sélectionner iPhone comme target"
echo "4. Appuyer sur Play ▶️"
echo ""
echo "📦 Ou construire APK Android:"
echo "cd android && ./gradlew assembleDebug"
echo "APK sera dans: android/app/build/outputs/apk/debug/"
echo ""

# Créer un projet React Native de base si nécessaire
if [ ! -d "android" ] && [ ! -d "ios" ]; then
    echo "⚠️  Dossiers natifs manquants"
    echo "   Voulez-vous initialiser un projet React Native? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🔧 Initialisation projet React Native..."
        
        # Sauvegarder les fichiers existants
        mkdir -p ../backup-dinor-src
        cp -r src ../backup-dinor-src/
        cp package.json ../backup-dinor-src/
        cp *.js ../backup-dinor-src/ 2>/dev/null || true
        cp *.json ../backup-dinor-src/ 2>/dev/null || true
        
        # Initialiser React Native
        cd ..
        npx react-native init DinorReactNative --template react-native-template-typescript
        
        # Restaurer nos fichiers
        cd DinorReactNative
        rm -rf src
        cp -r ../backup-dinor-src/src .
        cp ../backup-dinor-src/package.json .
        cp ../backup-dinor-src/*.js . 2>/dev/null || true
        
        echo "✅ Projet React Native initialisé!"
        echo "   Relancer ce script pour continuer"
    fi
fi

echo ""
echo "🚀 Prêt à tester l'application Dinor!"