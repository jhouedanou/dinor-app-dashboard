#!/bin/bash

# Script d'installation APK Dinor App
# Usage: ./install-apk.sh

APK_FILE="dinor-app-v1.2.0-production-20250805.apk"

echo "🚀 Installation de Dinor App..."
echo "📱 Fichier: $APK_FILE"

# Vérifier si le fichier existe
if [ ! -f "$APK_FILE" ]; then
    echo "❌ Erreur: Fichier APK non trouvé: $APK_FILE"
    exit 1
fi

# Vérifier si adb est installé
if ! command -v adb &> /dev/null; then
    echo "❌ Erreur: ADB n'est pas installé"
    echo "📥 Installez Android SDK Platform Tools:"
    echo "   - Ubuntu/Debian: sudo apt install android-tools-adb"
    echo "   - macOS: brew install android-platform-tools"
    echo "   - Windows: Téléchargez depuis developer.android.com"
    exit 1
fi

# Vérifier les appareils connectés
echo "🔍 Recherche d'appareils Android..."
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ Aucun appareil Android connecté"
    echo "📱 Connectez votre appareil et activez le débogage USB:"
    echo "   1. Paramètres → À propos du téléphone"
    echo "   2. Tapez 7 fois sur 'Numéro de build'"
    echo "   3. Paramètres → Système → Options de développement"
    echo "   4. Activez 'Débogage USB'"
    exit 1
fi

echo "✅ $DEVICES appareil(s) détecté(s)"

# Afficher les informations de l'APK
echo "📋 Informations APK:"
echo "   - Nom: Dinor App - Votre chef de poche"
echo "   - Version: 1.2.0 (build 2)"
echo "   - Taille: $(du -h $APK_FILE | cut -f1)"
echo "   - Package: com.dinorapp.mobile"

# Demander confirmation
read -p "🤔 Voulez-vous installer l'APK? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Installation annulée"
    exit 0
fi

# Installation
echo "📦 Installation en cours..."
if adb install -r "$APK_FILE"; then
    echo "✅ Installation réussie!"
    echo "🎉 Dinor App est maintenant installée sur votre appareil"
    echo "📱 Vous pouvez la trouver dans le menu des applications"
    
    # Optionnel: lancer l'app
    read -p "🚀 Voulez-vous lancer l'application maintenant? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Lancement de l'application..."
        adb shell am start -n com.dinorapp.mobile/.MainActivity
        echo "✅ Application lancée!"
    fi
else
    echo "❌ Échec de l'installation"
    echo "🔧 Vérifiez que:"
    echo "   - L'appareil est bien connecté"
    echo "   - Le débogage USB est activé"
    echo "   - Les sources inconnues sont autorisées"
    exit 1
fi

echo "🎯 Installation terminée avec succès!"