#!/bin/bash

# Script de génération automatique des APKs Dinor App
# Usage: ./build-apks.sh

set -e

echo "🚀 Début de la génération des APKs Dinor App..."

# Aller dans le dossier Flutter
cd flutter_app

echo "🧹 Nettoyage des builds précédents..."
flutter clean

echo "📦 Installation des dépendances..."
flutter pub get

echo "🔨 Génération de l'APK universel..."
flutter build apk --release

echo "🎯 Génération des APKs optimisés par architecture..."
flutter build apk --release --split-per-abi

echo "📁 Création du dossier de distribution..."
mkdir -p ../distribution
rm -f ../distribution/*.apk

echo "📋 Copie des APKs avec noms clairs..."
cp build/app/outputs/flutter-apk/app-release.apk ../distribution/dinor-app-universal-release.apk
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ../distribution/dinor-app-arm64-release.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ../distribution/dinor-app-arm32-release.apk
cp build/app/outputs/flutter-apk/app-x86_64-release.apk ../distribution/dinor-app-x86-release.apk

echo "📊 Tailles des APKs générés:"
ls -lh ../distribution/*.apk

echo "✅ Génération terminée avec succès!"
echo "📁 Les APKs sont disponibles dans le dossier: distribution/"
echo ""
echo "🎯 APKs générés:"
echo "  - dinor-app-universal-release.apk (pour tous les appareils)"
echo "  - dinor-app-arm64-release.apk (smartphones modernes)"
echo "  - dinor-app-arm32-release.apk (smartphones anciens)" 
echo "  - dinor-app-x86-release.apk (émulateurs)"