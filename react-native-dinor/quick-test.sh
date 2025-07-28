#!/bin/bash

# 🚀 SCRIPT DE TEST RAPIDE - DINOR REACT NATIVE
# Usage: ./quick-test.sh

echo "🧪 TEST RAPIDE - DINOR REACT NATIVE"
echo "====================================="

# Vérifier Node.js
echo "📋 Vérification des prérequis..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ requise (actuel: $(node --version))"
    exit 1
fi

echo "✅ Node.js $(node --version) - OK"

# Vérifier React Native CLI
if ! command -v npx &> /dev/null; then
    echo "❌ npx n'est pas disponible"
    exit 1
fi

echo "✅ npx disponible - OK"

# Aller dans le dossier React Native
cd "$(dirname "$0")"

# Vérifier si les dépendances sont installées
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation des dépendances"
        exit 1
    fi
    echo "✅ Dépendances installées"
else
    echo "✅ Dépendances déjà installées"
fi

# Test de l'API
echo "🌐 Test de connexion à l'API..."
if [ -f "test-api-connection.js" ]; then
    node test-api-connection.js
    if [ $? -ne 0 ]; then
        echo "⚠️  Attention: Problème de connexion à l'API"
        echo "   Vérifiez que https://new.dinorapp.com est accessible"
    else
        echo "✅ API accessible"
    fi
else
    echo "⚠️  Script de test API non trouvé"
fi

# Détecter la plateforme
echo "📱 Détection de la plateforme..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="ios"
    echo "🍎 Plateforme détectée: iOS"
else
    PLATFORM="android"
    echo "🤖 Plateforme détectée: Android"
fi

# Vérifier les outils de développement
if [ "$PLATFORM" = "ios" ]; then
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode n'est pas installé ou pas dans le PATH"
        echo "   Installez Xcode depuis l'App Store"
        exit 1
    fi
    
    echo "📦 Installation des pods iOS..."
    cd ios && pod install && cd ..
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation des pods"
        exit 1
    fi
    echo "✅ Pods iOS installés"
    
elif [ "$PLATFORM" = "android" ]; then
    if [ ! -f "android/local.properties" ]; then
        echo "⚠️  Android SDK non configuré"
        echo "   Créez le fichier android/local.properties avec:"
        echo "   sdk.dir=/path/to/your/android/sdk"
    fi
fi

# Lancer Metro bundler en arrière-plan
echo "🚀 Lancement de Metro bundler..."
npm start &
METRO_PID=$!

# Attendre que Metro soit prêt
echo "⏳ Attente du démarrage de Metro..."
sleep 10

# Lancer l'application
echo "📱 Lancement de l'application..."
if [ "$PLATFORM" = "ios" ]; then
    npm run ios
else
    npm run android
fi

# Nettoyer en cas d'arrêt
trap "echo '🛑 Arrêt de Metro...'; kill $METRO_PID 2>/dev/null" EXIT

echo ""
echo "🎉 Application lancée !"
echo "📋 Consultez TEST-GUIDE.md pour les tests à effectuer"
echo "🔍 Surveillez la console Metro pour les logs"
echo ""
echo "Pour arrêter: Ctrl+C" 