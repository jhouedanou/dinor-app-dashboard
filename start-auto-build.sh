#!/bin/bash

# Script de démarrage rapide pour l'automatisation du build et du vidage du cache
# Usage: ./start-auto-build.sh [options]

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_quick() {
    echo -e "${PURPLE}[QUICK]${NC} $1"
}

# Fonction d'aide
show_help() {
    cat << EOF
Script de démarrage rapide pour l'automatisation du build et du vidage du cache

Usage: $0 [OPTIONS]

OPTIONS:
    --setup           Configuration initiale complète
    --test            Tester le système d'automatisation
    --watch           Surveillance automatique avec build
    --dev             Environnement de développement complet
    --build           Build immédiat
    --clear           Vider le cache
    --laravel         Serveur Laravel + surveillance
    --pwa             Serveur PWA + surveillance
    --help            Afficher cette aide

EXEMPLES:
    $0 --setup                    # Configuration initiale
    $0 --test                     # Test du système
    $0 --watch                    # Surveillance automatique
    $0 --dev                      # Environnement de développement
    $0 --build                    # Build immédiat
    $0 --clear                    # Vider le cache
    $0 --laravel                  # Serveur Laravel
    $0 --pwa                      # Serveur PWA

RACCOURCIS:
    $0 setup                      # Alias pour --setup
    $0 test                       # Alias pour --test
    $0 watch                      # Alias pour --watch
    $0 dev                        # Alias pour --dev
    $0 build                      # Alias pour --build
    $0 clear                      # Alias pour --clear

EOF
}

# Vérifier si les scripts existent
check_scripts() {
    local missing_scripts=()
    
    if [ ! -f "scripts/setup-auto-build.sh" ]; then
        missing_scripts+=("scripts/setup-auto-build.sh")
    fi
    
    if [ ! -f "scripts/auto-build-watch.sh" ]; then
        missing_scripts+=("scripts/auto-build-watch.sh")
    fi
    
    if [ ! -f "scripts/dev-watch.sh" ]; then
        missing_scripts+=("scripts/dev-watch.sh")
    fi
    
    if [ ! -f "scripts/test-auto-build.sh" ]; then
        missing_scripts+=("scripts/test-auto-build.sh")
    fi
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        log_error "Scripts manquants: ${missing_scripts[*]}"
        log_info "Veuillez d'abord exécuter la configuration initiale"
        return 1
    fi
    
    return 0
}

# Configuration initiale
setup_initial() {
    log_quick "Configuration initiale..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter la configuration
    ./scripts/setup-auto-build.sh --all
    
    log_success "Configuration initiale terminée!"
    log_info "Vous pouvez maintenant utiliser les commandes:"
    echo "  $0 watch    # Surveillance automatique"
    echo "  $0 dev      # Environnement de développement"
    echo "  $0 build    # Build immédiat"
    echo "  $0 clear    # Vider le cache"
}

# Test du système
test_system() {
    log_quick "Test du système d'automatisation..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter les tests
    ./scripts/test-auto-build.sh --all
}

# Surveillance automatique
start_watch() {
    log_quick "Démarrage de la surveillance automatique..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter la surveillance
    ./scripts/auto-build-watch.sh
}

# Environnement de développement
start_dev() {
    log_quick "Démarrage de l'environnement de développement..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter l'environnement de développement
    ./scripts/dev-watch.sh --clear-cache
}

# Build immédiat
start_build() {
    log_quick "Build immédiat..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter le build
    ./scripts/auto-build-watch.sh --build-only
}

# Vider le cache
clear_cache() {
    log_quick "Vidage du cache..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter le vidage du cache
    ./scripts/auto-build-watch.sh --clear-cache
}

# Serveur Laravel
start_laravel() {
    log_quick "Démarrage du serveur Laravel..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter le serveur Laravel
    ./scripts/dev-watch.sh --laravel-only
}

# Serveur PWA
start_pwa() {
    log_quick "Démarrage du serveur PWA..."
    
    if ! check_scripts; then
        log_error "Impossible de continuer sans les scripts"
        exit 1
    fi
    
    # Exécuter le serveur PWA
    ./scripts/dev-watch.sh --pwa-only
}

# Script principal
main() {
    log_info "🚀 Démarrage rapide de l'automatisation"
    echo ""
    
    # Si aucun argument n'est fourni, afficher l'aide
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Traiter les arguments
    case $1 in
        --setup|setup)
            setup_initial
            ;;
        --test|test)
            test_system
            ;;
        --watch|watch)
            start_watch
            ;;
        --dev|dev)
            start_dev
            ;;
        --build|build)
            start_build
            ;;
        --clear|clear)
            clear_cache
            ;;
        --laravel|laravel)
            start_laravel
            ;;
        --pwa|pwa)
            start_pwa
            ;;
        --help|help)
            show_help
            ;;
        *)
            log_error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
}

# Exécuter le script principal
main "$@" 