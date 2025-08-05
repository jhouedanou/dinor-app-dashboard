#!/bin/bash

# Script de build iOS pour Dinor App
# Usage: ./build-ios.sh [debug|release|ipa]

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🔄 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Ce script doit être exécuté sur macOS pour compiler iOS"
    print_warning "Alternatives pour Linux/Windows :"
    echo "  - Codemagic (https://codemagic.io)"
    echo "  - GitHub Actions avec runners macOS"
    echo "  - Services cloud CI/CD"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode n'est pas installé"
    print_warning "Installez Xcode depuis le Mac App Store"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter n'est pas installé"
    print_warning "Installez Flutter depuis https://flutter.dev"
    exit 1
fi

# Parse arguments
BUILD_MODE="debug"
if [[ $# -gt 0 ]]; then
    BUILD_MODE="$1"
fi

print_status "Démarrage du build iOS Dinor App..."
print_status "Mode de build: $BUILD_MODE"

# Check Flutter doctor
print_status "Vérification de l'environnement Flutter..."
if ! flutter doctor --android-licenses > /dev/null 2>&1; then
    print_warning "Problèmes détectés avec Flutter doctor"
fi

# Clean project
print_status "Nettoyage du projet..."
flutter clean

# Get dependencies
print_status "Récupération des dépendances..."
flutter pub get

# Check if iOS simulator is available
print_status "Vérification des appareils iOS..."
DEVICES=$(flutter devices | grep ios || true)
if [[ -z "$DEVICES" ]]; then
    print_warning "Aucun appareil/simulateur iOS détecté"
    print_warning "Connectez un iPhone/iPad ou lancez un simulateur"
else
    echo "$DEVICES"
fi

# Install/update CocoaPods
print_status "Configuration des dépendances iOS (CocoaPods)..."
cd ios

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    print_error "CocoaPods n'est pas installé"
    print_status "Installation de CocoaPods..."
    sudo gem install cocoapods
fi

# Clean and install pods
rm -f Podfile.lock
rm -rf Pods/
pod install --repo-update

cd ..

# Build based on mode
case $BUILD_MODE in
    "debug")
        print_status "Build DEBUG pour développement..."
        flutter build ios --debug
        
        print_success "Build DEBUG terminé !"
        print_status "Fichier généré: build/ios/iphoneos/Runner.app"
        
        # Check for connected device and offer to install
        IOS_DEVICE=$(flutter devices | grep "ios" | grep -v "simulator" | head -1 | cut -d'•' -f2 | xargs || true)
        if [[ ! -z "$IOS_DEVICE" ]]; then
            read -p "🤔 Installer sur l'appareil connecté? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installation sur l'appareil..."
                flutter install --device-id "$IOS_DEVICE"
                print_success "App installée sur l'appareil !"
            fi
        fi
        ;;
        
    "release")
        print_status "Build RELEASE pour App Store..."
        flutter build ios --release
        
        print_success "Build RELEASE terminé !"
        print_status "Fichier généré: build/ios/iphoneos/Runner.app"
        print_warning "Pour distribuer: utilisez Xcode pour créer une Archive"
        ;;
        
    "ipa")
        print_status "Build IPA pour distribution..."
        
        # Check if export options exist
        if [[ ! -f "ios/ExportOptions.plist" ]]; then
            print_warning "Création du fichier ExportOptions.plist..."
            cat > ios/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
        fi
        
        flutter build ipa --release
        
        IPA_FILE=$(find build/ios/ipa -name "*.ipa" | head -1)
        if [[ -f "$IPA_FILE" ]]; then
            print_success "Build IPA terminé !"
            print_status "Fichier IPA: $IPA_FILE"
            
            # Copy IPA with descriptive name
            IPA_NAME="dinor-app-v1.2.0-ios-$(date +%Y%m%d).ipa"
            cp "$IPA_FILE" "$IPA_NAME"
            print_success "IPA copié: $IPA_NAME"
            
            print_status "📱 Pour distribuer:"
            echo "  1. App Store: Utilisez Transporter ou Xcode Organizer"
            echo "  2. TestFlight: Upload vers App Store Connect"
            echo "  3. Ad-hoc: Distribuez le fichier IPA directement"
        else
            print_error "Erreur: Fichier IPA non trouvé"
            exit 1
        fi
        ;;
        
    *)
        print_error "Mode de build invalide: $BUILD_MODE"
        echo "Usage: $0 [debug|release|ipa]"
        echo ""
        echo "Modes disponibles:"
        echo "  debug   - Build de développement (défaut)"
        echo "  release - Build de production pour App Store"
        echo "  ipa     - Génère un fichier IPA pour distribution"
        exit 1
        ;;
esac

# Final information
print_success "🎉 Build iOS terminé avec succès !"
print_status "📋 Informations de l'app:"
echo "  - Nom: Dinor App - Votre chef de poche"
echo "  - Bundle ID: com.dinorapp.mobile"
echo "  - Version: $(grep 'version:' pubspec.yaml | cut -d' ' -f2)"
echo "  - Mode: $BUILD_MODE"

print_status "📚 Prochaines étapes:"
case $BUILD_MODE in
    "debug")
        echo "  1. Testez l'app sur simulateur ou appareil"
        echo "  2. Débugguez les fonctionnalités si nécessaire"
        ;;
    "release")
        echo "  1. Ouvrez ios/Runner.xcworkspace dans Xcode"
        echo "  2. Product → Archive pour créer une archive"
        echo "  3. Distribuez via App Store Connect"
        ;;
    "ipa")
        echo "  1. Téléchargez Transporter depuis le Mac App Store"
        echo "  2. Glissez-déposez le fichier IPA pour upload"
        echo "  3. Ou utilisez Xcode Organizer"
        ;;
esac

print_success "✨ Script terminé !"