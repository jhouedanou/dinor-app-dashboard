# Rapport de Build - Dinor App v3.1.0

## Informations de Version
- **Version**: 3.1.0+31
- **Date de Build**: 22 Août 2024
- **Type de Build**: Debug et Release

## APKs Générés

### APK Debug (Test)
- **Fichier**: `dinor-app-v3.1.0-debug.apk`
- **Taille**: 113.5 MB
- **Usage**: Tests et développement
- **Signature**: Debug (non signée)

### APK Release (Production)
- **Fichier**: `dinor-app-v3.1.0-release.apk`
- **Taille**: 38.8 MB
- **Usage**: Distribution et production
- **Signature**: Release (signée avec keystore)

## Configuration de Build

### Version Flutter
- SDK Flutter : >=3.2.0 <4.0.0
- Version de l'application : 3.1.0+31

### Configuration Android
- **Namespace**: com.bfedition.dinorapp
- **Compile SDK**: Flutter compile SDK version
- **Min SDK**: Flutter min SDK version
- **Target SDK**: Flutter target SDK version
- **NDK Version**: 27.0.12077973

### Signing
- **Keystore**: Configuré (key.properties)
- **Signing Config**: Release configuré

## Dépendances Principales
- Provider 6.1.5 (État global)
- Riverpod 2.6.1
- Firebase Core 3.6.0
- Firebase Analytics 11.3.3
- OneSignal 5.2.5 (Notifications)
- Video Player (Lecteur TikTok)
- Cached Network Image 3.3.0

## Notes de Build
- Build debug : 138.7s
- Build release : 231.6s
- Tree-shaking des icônes activé
- Avertissements mineurs sur API dépréciées (non bloquants)

## Fichiers de Sortie
- APK Debug : `build/app/outputs/flutter-apk/app-debug.apk`
- APK Release : `build/app/outputs/flutter-apk/app-release.apk`
- Copies renommées dans le répertoire racine

## Instructions d'Installation

### Pour Tests (Debug)
```bash
adb install dinor-app-v3.1.0-debug.apk
```

### Pour Production (Release)
```bash
adb install dinor-app-v3.1.0-release.apk
```

## Vérification de la Version
La version 3.1.0 est correctement configurée dans :
- `pubspec.yaml` : version: 3.1.0+31
- Configuration Android : versionCode et versionName automatiques

---
*Build généré le 22 Août 2024*
