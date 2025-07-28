#!/bin/bash

echo "📱 CONSTRUCTION RAPIDE APK ANDROID - DINOR"
echo "=========================================="
echo ""

PROJECT_ROOT="/home/bigfiver/Documents/GitHub/dinor-app-dashboard"
DINOR_RN_DIR="$PROJECT_ROOT/react-native-dinor"
BUILD_DIR="$PROJECT_ROOT/DinorMobileBuild"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "$DINOR_RN_DIR" ]; then
    echo "❌ Dossier react-native-dinor introuvable"
    exit 1
fi

echo "🔧 Étape 1: Création du projet React Native..."

# Supprimer le dossier de build s'il existe
if [ -d "$BUILD_DIR" ]; then
    echo "🗑️  Suppression de l'ancien build..."
    rm -rf "$BUILD_DIR"
fi

# Créer un nouveau projet RN
cd "$PROJECT_ROOT"
echo "🚀 Initialisation React Native (cela peut prendre quelques minutes)..."
npx react-native init DinorMobileBuild --template react-native-template-typescript --skip-install

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'initialisation React Native"
    exit 1
fi

cd "$BUILD_DIR"

echo "📦 Étape 2: Installation des dépendances..."

# Copier notre package.json personnalisé
cp "$DINOR_RN_DIR/package.json" .

# Installer les dépendances
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi

echo "📁 Étape 3: Copie des fichiers source..."

# Supprimer les fichiers par défaut
rm -rf src
rm App.tsx App.js 2>/dev/null || true
rm index.js 2>/dev/null || true

# Copier nos fichiers
cp -r "$DINOR_RN_DIR/src" .
cp "$DINOR_RN_DIR/index.js" .
cp "$DINOR_RN_DIR/babel.config.js" .
cp "$DINOR_RN_DIR/metro.config.js" .
cp "$DINOR_RN_DIR/tsconfig.json" .

echo "🔨 Étape 4: Construction de l'APK..."

# Aller dans le dossier Android
cd android

# Nettoyer et construire
echo "🧹 Nettoyage..."
./gradlew clean

echo "🏗️  Construction de l'APK (debug)..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    APK_PATH="$BUILD_DIR/android/app/build/outputs/apk/debug/app-debug.apk"
    
    echo ""
    echo "🎉 APK CONSTRUITE AVEC SUCCÈS!"
    echo "==============================================="
    echo "📍 Emplacement: $APK_PATH"
    echo "📱 Taille: $(du -h "$APK_PATH" | cut -f1)"
    echo ""
    echo "📋 PROCHAINES ÉTAPES:"
    echo "1. Connecter votre téléphone Android en USB"
    echo "2. Activer le 'Débogage USB' dans Options développeur"
    echo "3. Installer avec: adb install \"$APK_PATH\""
    echo ""
    echo "OU"
    echo ""
    echo "1. Copier l'APK sur votre téléphone"
    echo "2. Ouvrir le gestionnaire de fichiers"
    echo "3. Appuyer sur l'APK pour l'installer"
    echo ""
    
    # Essayer d'installer automatiquement si un appareil est connecté
    if command -v adb &> /dev/null; then
        echo "🔍 Recherche d'appareils Android connectés..."
        DEVICES=$(adb devices | grep -v "List of devices" | grep "device$")
        
        if [ ! -z "$DEVICES" ]; then
            echo "📱 Appareil trouvé! Installation automatique..."
            adb install "$APK_PATH"
            
            if [ $? -eq 0 ]; then
                echo "✅ APPLICATION INSTALLÉE AVEC SUCCÈS!"
                echo "🚀 Vous pouvez maintenant ouvrir l'app Dinor sur votre téléphone"
            else
                echo "⚠️  Erreur lors de l'installation automatique"
                echo "💡 Essayez l'installation manuelle"
            fi
        else
            echo "📱 Aucun appareil Android détecté"
            echo "💡 Connectez votre téléphone pour installation automatique"
        fi
    fi
    
    echo ""
    echo "🎯 L'application Dinor est prête à tester!"
    
else
    echo "❌ ÉCHEC DE LA CONSTRUCTION"
    echo "💡 Vérifiez les erreurs ci-dessus"
    exit 1
fi