#!/bin/bash

# VERIFY_FIREBASE_CONFIG.SH - SCRIPT DE VÉRIFICATION FIREBASE
# 
# Ce script vérifie que la configuration Firebase est correcte
# et que tous les fichiers nécessaires sont présents.

echo "🔍 Vérification de la configuration Firebase Analytics..."
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo ""
echo "📋 Vérification des dépendances..."

# Vérifier pubspec.yaml
if grep -q "firebase_analytics" pubspec.yaml; then
    print_result 0 "Firebase Analytics dans pubspec.yaml"
else
    print_result 1 "Firebase Analytics manquant dans pubspec.yaml"
fi

if grep -q "firebase_core" pubspec.yaml; then
    print_result 0 "Firebase Core dans pubspec.yaml"
else
    print_result 1 "Firebase Core manquant dans pubspec.yaml"
fi

if grep -q "firebase_crashlytics" pubspec.yaml; then
    print_result 0 "Firebase Crashlytics dans pubspec.yaml"
else
    print_result 1 "Firebase Crashlytics manquant dans pubspec.yaml"
fi

echo ""
echo "📁 Vérification des fichiers de configuration..."

# Vérifier google-services.json pour Android
if [ -f "android/app/google-services.json" ]; then
    print_result 0 "google-services.json présent (Android)"
    
    # Vérifier le contenu du fichier
    if grep -q "project_id" android/app/google-services.json; then
        print_result 0 "google-services.json semble valide"
    else
        print_warning "google-services.json pourrait être invalide"
    fi
else
    print_result 1 "google-services.json manquant (Android)"
fi

# Vérifier GoogleService-Info.plist pour iOS
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_result 0 "GoogleService-Info.plist présent (iOS)"
    
    # Vérifier le contenu du fichier
    if grep -q "GOOGLE_APP_ID" ios/Runner/GoogleService-Info.plist; then
        print_result 0 "GoogleService-Info.plist semble valide"
    else
        print_warning "GoogleService-Info.plist pourrait être invalide"
    fi
else
    print_result 1 "GoogleService-Info.plist manquant (iOS)"
fi

# Vérifier GoogleService-Info.plist pour macOS
if [ -f "macos/Runner/GoogleService-Info.plist" ]; then
    print_result 0 "GoogleService-Info.plist présent (macOS)"
    
    # Vérifier le contenu du fichier
    if grep -q "GOOGLE_APP_ID" macos/Runner/GoogleService-Info.plist; then
        print_result 0 "GoogleService-Info.plist semble valide (macOS)"
    else
        print_warning "GoogleService-Info.plist pourrait être invalide (macOS)"
    fi
else
    print_result 1 "GoogleService-Info.plist manquant (macOS)"
fi

echo ""
echo "📄 Vérification des fichiers de code..."

# Vérifier analytics_service.dart
if [ -f "lib/services/analytics_service.dart" ]; then
    print_result 0 "analytics_service.dart présent"
    
    # Vérifier les méthodes principales
    if grep -q "logAppInstall" lib/services/analytics_service.dart; then
        print_result 0 "Méthode logAppInstall présente"
    else
        print_result 1 "Méthode logAppInstall manquante"
    fi
    
    if grep -q "logScreenView" lib/services/analytics_service.dart; then
        print_result 0 "Méthode logScreenView présente"
    else
        print_result 1 "Méthode logScreenView manquante"
    fi
    
    if grep -q "logViewContent" lib/services/analytics_service.dart; then
        print_result 0 "Méthode logViewContent présente"
    else
        print_result 1 "Méthode logViewContent manquante"
    fi
else
    print_result 1 "analytics_service.dart manquant"
fi

# Vérifier analytics_tracker.dart
if [ -f "lib/services/analytics_tracker.dart" ]; then
    print_result 0 "analytics_tracker.dart présent"
    
    # Vérifier les méthodes principales
    if grep -q "startScreenTracking" lib/services/analytics_tracker.dart; then
        print_result 0 "Méthode startScreenTracking présente"
    else
        print_result 1 "Méthode startScreenTracking manquante"
    fi
    
    if grep -q "trackButtonClick" lib/services/analytics_tracker.dart; then
        print_result 0 "Méthode trackButtonClick présente"
    else
        print_result 1 "Méthode trackButtonClick manquante"
    fi
else
    print_result 1 "analytics_tracker.dart manquant"
fi

# Vérifier l'initialisation dans main.dart
if [ -f "lib/main.dart" ]; then
    if grep -q "Firebase.initializeApp" lib/main.dart; then
        print_result 0 "Firebase.initializeApp dans main.dart"
    else
        print_result 1 "Firebase.initializeApp manquant dans main.dart"
    fi
    
    if grep -q "AnalyticsService.initialize" lib/main.dart; then
        print_result 0 "AnalyticsService.initialize dans main.dart"
    else
        print_result 1 "AnalyticsService.initialize manquant dans main.dart"
    fi
    
    if grep -q "AnalyticsTracker.startSession" lib/main.dart; then
        print_result 0 "AnalyticsTracker.startSession dans main.dart"
    else
        print_result 1 "AnalyticsTracker.startSession manquant dans main.dart"
    fi
else
    print_result 1 "main.dart manquant"
fi

echo ""
echo "🔧 Vérification de l'intégration dans les écrans..."

# Vérifier l'utilisation dans home_screen.dart
if [ -f "lib/screens/home_screen.dart" ]; then
    if grep -q "AnalyticsScreenMixin" lib/screens/home_screen.dart; then
        print_result 0 "AnalyticsScreenMixin utilisé dans home_screen.dart"
    else
        print_warning "AnalyticsScreenMixin non utilisé dans home_screen.dart"
    fi
    
    if grep -q "AnalyticsTracker.trackButtonClick" lib/screens/home_screen.dart; then
        print_result 0 "Tracking des boutons dans home_screen.dart"
    else
        print_warning "Tracking des boutons non implémenté dans home_screen.dart"
    fi
else
    print_result 1 "home_screen.dart manquant"
fi

echo ""
echo "📊 Vérification des dépendances Flutter..."

# Vérifier si flutter pub get a été exécuté
if [ -f "pubspec.lock" ]; then
    if grep -q "firebase_analytics" pubspec.lock; then
        print_result 0 "Firebase Analytics installé via pubspec.lock"
    else
        print_result 1 "Firebase Analytics non installé"
    fi
else
    print_warning "pubspec.lock manquant - exécutez 'flutter pub get'"
fi

echo ""
echo "🚀 Tests de compilation..."

# Tester la compilation
if command -v flutter &> /dev/null; then
    echo "Compilation en cours..."
    flutter analyze --no-fatal-infos > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_result 0 "Compilation réussie"
    else
        print_result 1 "Erreurs de compilation détectées"
        print_info "Exécutez 'flutter analyze' pour voir les détails"
    fi
else
    print_warning "Flutter non installé ou non dans le PATH"
fi

echo ""
echo "📋 Résumé des vérifications..."

# Compter les erreurs
errors=0
warnings=0

# Compter les erreurs dans la sortie
errors=$(echo "$output" | grep -c "❌" || echo "0")
warnings=$(echo "$output" | grep -c "⚠️" || echo "0")

echo ""
echo "=================================================="
echo "📊 Résumé :"
echo "   Erreurs détectées : $errors"
echo "   Avertissements : $warnings"

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}🎉 Configuration Firebase Analytics OK !${NC}"
    echo ""
    echo "Prochaines étapes :"
    echo "1. Déployer l'application"
    echo "2. Vérifier les données dans Firebase Console"
    echo "3. Tester les événements avec test_analytics_integration.dart"
else
    echo -e "${RED}⚠️  Des problèmes ont été détectés${NC}"
    echo ""
    echo "Actions recommandées :"
    echo "1. Corriger les erreurs listées ci-dessus"
    echo "2. Vérifier les fichiers de configuration Firebase"
    echo "3. Exécuter 'flutter pub get'"
    echo "4. Relancer ce script de vérification"
fi

echo ""
echo "📚 Documentation :"
echo "- FIREBASE_ANALYTICS_INTEGRATION.md"
echo "- test_analytics_integration.dart"
echo ""

echo "🔗 Liens utiles :"
echo "- Firebase Console : https://console.firebase.google.com/"
echo "- Documentation Flutter Firebase : https://firebase.flutter.dev/"
echo "- Analytics DebugView : https://console.firebase.google.com/project/_/analytics/debugview" 