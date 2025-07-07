#!/bin/bash

# Script d'automatisation pour builds Docker optimisés avec BuildKit
# Usage: ./scripts/build.sh [options]

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CACHE_DIR="/tmp/.buildx-cache"
CACHE_DIR_NEW="/tmp/.buildx-cache-new"
IMAGE_NAME="dinor-dashboard"
COMPOSE_FILE="docker-compose.yml"

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

# Fonction d'aide
show_help() {
    cat << EOF
Script de build Docker optimisé pour le développement local

Usage: $0 [OPTIONS]

OPTIONS:
    --build-only    Construire l'image sans démarrer les services
    --no-cache      Ignorer le cache et forcer un rebuild complet
    --clean-cache   Nettoyer le cache BuildKit avant le build
    --dev           Démarrer avec le profil de développement (BrowserSync)
    --prod          Build pour la production (optimisations maximales)
    --help          Afficher cette aide

EXEMPLES:
    $0                  # Build normal avec cache
    $0 --dev            # Build et démarre avec BrowserSync
    $0 --clean-cache    # Nettoie le cache et rebuild
    $0 --no-cache       # Force un rebuild complet
    $0 --build-only     # Build seulement, sans démarrer

EOF
}

# Vérifier la disponibilité de BuildKit
check_buildkit() {
    log_info "Vérification de BuildKit..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé ou accessible"
        exit 1
    fi
    
    # Activer BuildKit si pas déjà fait
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    log_success "BuildKit activé"
}

# Nettoyer le cache BuildKit
clean_cache() {
    log_info "Nettoyage du cache BuildKit..."
    
    if [ -d "$CACHE_DIR" ]; then
        rm -rf "$CACHE_DIR"
        log_success "Cache ancien supprimé"
    fi
    
    if [ -d "$CACHE_DIR_NEW" ]; then
        rm -rf "$CACHE_DIR_NEW"
        log_success "Cache nouveau supprimé"
    fi
    
    # Nettoyer aussi le cache Docker
    docker builder prune -f || true
    log_success "Cache BuildKit nettoyé"
}

# Optimiser la rotation du cache
rotate_cache() {
    if [ -d "$CACHE_DIR_NEW" ]; then
        log_info "Rotation du cache..."
        rm -rf "$CACHE_DIR" || true
        mv "$CACHE_DIR_NEW" "$CACHE_DIR" || true
        log_success "Cache mis à jour"
    fi
}

# Build avec optimisations BuildKit
build_optimized() {
    local build_args=""
    local no_cache_flag=""
    
    if [ "$NO_CACHE" = "true" ]; then
        no_cache_flag="--no-cache"
        log_warning "Build sans cache demandé"
    fi
    
    log_info "Démarrage du build optimisé..."
    log_info "Image: $IMAGE_NAME"
    log_info "Cache: $CACHE_DIR"
    
    # Créer le répertoire de cache s'il n'existe pas
    mkdir -p "$CACHE_DIR"
    
    # Build avec cache BuildKit
    docker compose -f "$COMPOSE_FILE" build $no_cache_flag app
    
    # Rotation du cache pour la prochaine fois
    rotate_cache
    
    log_success "Build terminé avec succès"
}

# Démarrer les services
start_services() {
    local profile_arg=""
    
    if [ "$DEV_MODE" = "true" ]; then
        profile_arg="--profile dev"
        log_info "Démarrage en mode développement avec BrowserSync..."
    else
        log_info "Démarrage des services..."
    fi
    
    docker compose -f "$COMPOSE_FILE" $profile_arg up -d
    
    log_success "Services démarrés"
    
    # Afficher les URLs utiles
    echo ""
    log_info "Services disponibles:"
    echo "  📱 Application: http://localhost:8000"
    echo "  🗄️  Adminer: http://localhost:8080"
    echo "  📊 Redis: localhost:6379"
    
    if [ "$DEV_MODE" = "true" ]; then
        echo "  🔄 BrowserSync: http://localhost:3001"
        echo "  ⚙️  BrowserSync UI: http://localhost:3000"
    fi
    
    echo ""
    log_info "Logs en temps réel: docker compose logs -f"
}

# Afficher les statistiques de build
show_build_stats() {
    log_info "Statistiques des images:"
    docker images | grep -E "(dinor|REPOSITORY)" || true
    
    echo ""
    log_info "Utilisation du cache:"
    if [ -d "$CACHE_DIR" ]; then
        du -sh "$CACHE_DIR" 2>/dev/null || echo "Cache vide"
    else
        echo "Aucun cache présent"
    fi
}

# Variables par défaut
BUILD_ONLY=false
NO_CACHE=false
CLEAN_CACHE=false
DEV_MODE=false
PROD_MODE=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --clean-cache)
            CLEAN_CACHE=true
            shift
            ;;
        --dev)
            DEV_MODE=true
            shift
            ;;
        --prod)
            PROD_MODE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Script principal
main() {
    log_info "🚀 Démarrage du build Docker optimisé"
    echo ""
    
    # Vérifications préliminaires
    check_buildkit
    
    # Nettoyer le cache si demandé
    if [ "$CLEAN_CACHE" = "true" ]; then
        clean_cache
    fi
    
    # Build optimisé
    build_optimized
    
    # Démarrer les services sauf si build-only
    if [ "$BUILD_ONLY" = "false" ]; then
        start_services
        show_build_stats
    else
        log_success "Build terminé (services non démarrés)"
        show_build_stats
    fi
    
    echo ""
    log_success "✅ Processus terminé avec succès!"
}

# Exécuter le script principal
main "$@"