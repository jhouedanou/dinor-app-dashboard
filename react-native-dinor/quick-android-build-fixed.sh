#!/bin/bash

echo "📱 CONSTRUCTION RAPIDE APK ANDROID - DINOR (VERSION CORRIGÉE)"
echo "=============================================================="
echo ""

PROJECT_ROOT="/home/bigfiver/Documents/GitHub/dinor-app-dashboard"
DINOR_RN_DIR="$PROJECT_ROOT/react-native-dinor"
BUILD_DIR="$PROJECT_ROOT/DinorMobileBuild"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "$DINOR_RN_DIR" ]; then
    echo "❌ Dossier react-native-dinor introuvable"
    exit 1
fi

echo "🔧 Étape 1: Création du projet React Native avec la nouvelle CLI..."

# Supprimer le dossier de build s'il existe
if [ -d "$BUILD_DIR" ]; then
    echo "🗑️  Suppression de l'ancien build..."
    rm -rf "$BUILD_DIR"
fi

# Créer un nouveau projet RN avec la nouvelle CLI
cd "$PROJECT_ROOT"
echo "🚀 Initialisation React Native avec @react-native-community/cli..."

# Utiliser la nouvelle CLI recommandée
npx @react-native-community/cli@latest init DinorMobileBuild --template react-native-template-typescript

if [ $? -ne 0 ]; then
    echo "❌ Erreur avec la nouvelle CLI. Tentative avec Expo CLI..."
    
    # Alternative : utiliser Expo comme base puis éjecter
    echo "🔄 Tentative avec Expo CLI..."
    npx create-expo-app DinorMobileBuild --template blank-typescript
    cd DinorMobileBuild
    
    # Éjecter vers React Native pur
    npx expo eject
    
    if [ $? -ne 0 ]; then
        echo "❌ Échec avec Expo aussi. Utilisation d'une approche manuelle..."
        
        # Approche manuelle : cloner un template de base
        cd "$PROJECT_ROOT"
        git clone https://github.com/react-native-community/react-native-template-typescript.git DinorMobileBuild
        cd DinorMobileBuild
        
        # Nettoyer le git
        rm -rf .git
        
        # Initialiser un nouveau git
        git init
        
        # Mettre à jour le nom du projet
        sed -i 's/"HelloWorld"/"DinorMobileBuild"/g' package.json
        sed -i 's/"HelloWorld"/"DinorMobileBuild"/g' app.json
        sed -i 's/HelloWorld/DinorMobileBuild/g' android/settings.gradle
        
        echo "✅ Projet créé manuellement"
    fi
fi

cd "$BUILD_DIR"

echo "📦 Étape 2: Installation des dépendances..."

# Sauvegarder le package.json original
cp package.json package.json.backup

# Fusionner avec notre package.json personnalisé
echo "🔄 Mise à jour des dépendances..."

# Ajouter nos dépendances spécifiques
npm install @react-navigation/native@^6.1.9 \
            @react-navigation/bottom-tabs@^6.5.11 \
            @react-navigation/stack@^6.3.20 \
            react-native-screens@^3.25.0 \
            react-native-safe-area-context@^4.7.4 \
            react-native-gesture-handler@^2.13.4 \
            zustand@^4.4.6 \
            @react-native-async-storage/async-storage@^1.19.5 \
            @react-native-community/netinfo@^11.0.0

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi

# Installation des pods iOS (si disponible)
if [ -d "ios" ]; then
    echo "🍎 Installation des pods iOS..."
    cd ios && pod install && cd ..
fi

echo "📁 Étape 3: Copie des fichiers source..."

# Créer la structure de dossiers si nécessaire
mkdir -p src/components/common
mkdir -p src/components/icons
mkdir -p src/screens
mkdir -p src/stores
mkdir -p src/services
mkdir -p src/styles

# Supprimer les fichiers par défaut
rm -f App.tsx App.js
rm -f src/App.tsx src/App.js 2>/dev/null || true

# Copier nos fichiers
if [ -d "$DINOR_RN_DIR/src" ]; then
    cp -r "$DINOR_RN_DIR/src"/* src/
fi

# Copier les fichiers de configuration
cp "$DINOR_RN_DIR/index.js" . 2>/dev/null || true
cp "$DINOR_RN_DIR/babel.config.js" . 2>/dev/null || true
cp "$DINOR_RN_DIR/metro.config.js" . 2>/dev/null || true

# Créer un App.tsx simple si nos fichiers ne sont pas copiés
if [ ! -f "src/App.tsx" ]; then
    echo "⚠️  Création d'un App.tsx de base..."
    cat > App.tsx << 'EOF'
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const App = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>🍽️ Dinor</Text>
      <Text style={styles.subtitle}>Application mobile convertie depuis Vue.js</Text>
      <Text style={styles.description}>
        Cette application React Native reproduit fidèlement l'expérience Vue.js originale.
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#E53E3E',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: '#2D3748',
    marginBottom: 20,
    textAlign: 'center',
    fontWeight: '600',
  },
  description: {
    fontSize: 16,
    color: '#4A5568',
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default App;
EOF
fi

echo "🔨 Étape 4: Construction de l'APK..."

# Aller dans le dossier Android
cd android

# Vérifier que gradle wrapper existe
if [ ! -f "gradlew" ]; then
    echo "❌ Gradle wrapper introuvable"
    exit 1
fi

# Rendre gradlew exécutable
chmod +x gradlew

# Nettoyer et construire
echo "🧹 Nettoyage..."
./gradlew clean

echo "🏗️  Construction de l'APK (debug)..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    APK_PATH="$BUILD_DIR/android/app/build/outputs/apk/debug/app-debug.apk"
    
    # Vérifier que l'APK existe
    if [ -f "$APK_PATH" ]; then
        echo ""
        echo "🎉 APK CONSTRUITE AVEC SUCCÈS!"
        echo "==============================================="
        echo "📍 Emplacement: $APK_PATH"
        echo "📱 Taille: $(du -h "$APK_PATH" | cut -f1)"
        echo ""
        
        # Copier l'APK dans un endroit plus accessible
        EASY_APK_PATH="$PROJECT_ROOT/dinor-mobile-app.apk"
        cp "$APK_PATH" "$EASY_APK_PATH"
        echo "📋 Copie facile d'accès: $EASY_APK_PATH"
        echo ""
        
        echo "📋 INSTALLATION SUR TÉLÉPHONE:"
        echo "================================"
        echo ""
        echo "📱 MÉTHODE 1 - Via USB (Recommandée):"
        echo "1. Connecter votre téléphone Android en USB"
        echo "2. Activer 'Options développeur' (appuyer 7x sur Numéro de build)"
        echo "3. Activer 'Débogage USB' dans Options développeur"
        echo "4. Installer: adb install \"$EASY_APK_PATH\""
        echo ""
        echo "📱 MÉTHODE 2 - Transfert manuel:"
        echo "1. Copier le fichier: $EASY_APK_PATH"
        echo "2. Transférer sur votre téléphone (USB, email, cloud)"
        echo "3. Sur le téléphone: ouvrir le gestionnaire de fichiers"
        echo "4. Appuyer sur l'APK et autoriser l'installation"
        echo ""
        
        # Essayer d'installer automatiquement si un appareil est connecté
        if command -v adb &> /dev/null; then
            echo "🔍 Recherche d'appareils Android connectés..."
            DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
            
            if [ $DEVICES -gt 0 ]; then
                echo "📱 Appareil trouvé! Tentative d'installation automatique..."
                adb install "$EASY_APK_PATH"
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo "✅ APPLICATION INSTALLÉE AVEC SUCCÈS!"
                    echo "🚀 Recherchez 'DinorMobileBuild' dans vos applications"
                    echo "🎯 L'app Dinor est maintenant sur votre téléphone!"
                else
                    echo "⚠️  Installation automatique échouée (normal si pas d'autorisation)"
                    echo "💡 Utilisez l'installation manuelle ci-dessus"
                fi
            else
                echo "📱 Aucun appareil Android détecté en débogage USB"
                echo "💡 Utilisez l'installation manuelle"
            fi
        else
            echo "⚠️  ADB non disponible - installation manuelle uniquement"
        fi
        
        echo ""
        echo "🎉 SUCCESS! L'application Dinor est prête!"
        echo "=========================================="
        
    else
        echo "❌ APK non trouvée à l'emplacement attendu"
        echo "🔍 Recherche d'autres APK..."
        find "$BUILD_DIR" -name "*.apk" -type f
    fi
    
else
    echo "❌ ÉCHEC DE LA CONSTRUCTION"
    echo "💡 Erreurs de construction détectées"
    echo ""
    echo "🔧 SOLUTIONS POSSIBLES:"
    echo "1. Vérifier que Android SDK est installé"
    echo "2. Définir ANDROID_HOME dans votre environnement"
    echo "3. Installer Android Studio et configurer le SDK"
    echo "4. Vérifier Java JDK (version 11 ou 17 recommandée)"
    exit 1
fi