#!/bin/bash

# Script d'automatisation pour build et vidage du cache lors des modifications
# Usage: ./scripts/auto-build-watch.sh [options]

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
WATCH_DIRS=("app" "resources" "config" "routes" "database" "src")
EXCLUDE_PATTERNS=("*.log" "*.tmp" "*.cache" "node_modules/*" "vendor/*" ".git/*" "storage/logs/*" "storage/framework/cache/*")
BUILD_DELAY=2
LAST_BUILD=0
BUILD_IN_PROGRESS=false

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

log_build() {
    echo -e "${PURPLE}[BUILD]${NC} $1"
}

log_watch() {
    echo -e "${CYAN}[WATCH]${NC} $1"
}

# Fonction d'aide
show_help() {
    cat << EOF
Script d'automatisation pour build et vidage du cache lors des modifications

Usage: $0 [OPTIONS]

OPTIONS:
    --watch-only     Surveiller seulement, sans build automatique
    --build-only     Build immédiat sans surveillance
    --clear-cache    Vider le cache avant de commencer
    --dev            Mode développement (build PWA + Laravel)
    --prod           Mode production (build optimisé)
    --help           Afficher cette aide

EXEMPLES:
    $0                  # Surveillance complète avec build automatique
    $0 --watch-only     # Surveillance seulement
    $0 --build-only     # Build immédiat
    $0 --dev            # Mode développement
    $0 --clear-cache    # Vider le cache et commencer

EOF
}

# Vérifier les dépendances
check_dependencies() {
    log_info "Vérification des dépendances..."
    
    # Vérifier inotify-tools
    if ! command -v inotifywait &> /dev/null; then
        log_error "inotify-tools n'est pas installé. Installez-le avec: sudo apt-get install inotify-tools"
        exit 1
    fi
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérifier PHP
    if ! command -v php &> /dev/null; then
        log_error "PHP n'est pas installé"
        exit 1
    fi
    
    # Vérifier Composer
    if ! command -v composer &> /dev/null; then
        log_error "Composer n'est pas installé"
        exit 1
    fi
    
    log_success "Toutes les dépendances sont installées"
}

# Vider le cache Laravel
clear_laravel_cache() {
    log_info "Vidage du cache Laravel..."
    
    if [ -f "artisan" ]; then
        php artisan cache:clear 2>/dev/null || log_warning "Impossible de vider le cache général"
        php artisan config:clear 2>/dev/null || log_warning "Impossible de vider le cache de config"
        php artisan view:clear 2>/dev/null || log_warning "Impossible de vider le cache des vues"
        php artisan route:clear 2>/dev/null || log_warning "Impossible de vider le cache des routes"
        
        # Redécouverte des composants Livewire
        php artisan livewire:discover 2>/dev/null || log_warning "Impossible de redécouvrir les composants Livewire"
        
        log_success "Cache Laravel vidé"
    else
        log_warning "Fichier artisan non trouvé"
    fi
}

# Vider le cache PWA
clear_pwa_cache() {
    log_info "Vidage du cache PWA..."
    
    if [ -f "package.json" ]; then
        npm run pwa:clear-cache 2>/dev/null || log_warning "Impossible de vider le cache PWA"
        log_success "Cache PWA vidé"
    else
        log_warning "Fichier package.json non trouvé"
    fi
}

# Build Laravel
build_laravel() {
    log_build "Build Laravel..."
    
    if [ -f "artisan" ]; then
        # Optimiser l'autoloader
        composer dump-autoload --optimize 2>/dev/null || log_warning "Problème avec dump-autoload"
        
        # Reconstruire les caches optimisés
        php artisan config:cache 2>/dev/null || log_warning "Problème avec config:cache"
        php artisan route:cache 2>/dev/null || log_warning "Problème avec route:cache"
        php artisan view:cache 2>/dev/null || log_warning "Problème avec view:cache"
        
        log_success "Build Laravel terminé"
    else
        log_warning "Fichier artisan non trouvé"
    fi
}

# Build PWA
build_pwa() {
    log_build "Build PWA..."
    
    if [ -f "package.json" ]; then
        npm run pwa:build 2>/dev/null || log_warning "Problème avec le build PWA"
        log_success "Build PWA terminé"
    else
        log_warning "Fichier package.json non trouvé"
    fi
}

# Build complet
build_all() {
    if [ "$BUILD_IN_PROGRESS" = true ]; then
        log_warning "Build déjà en cours, ignoré"
        return
    fi
    
    BUILD_IN_PROGRESS=true
    CURRENT_TIME=$(date +%s)
    
    # Éviter les builds trop fréquents
    if [ $((CURRENT_TIME - LAST_BUILD)) -lt $BUILD_DELAY ]; then
        log_warning "Build ignoré (trop fréquent)"
        BUILD_IN_PROGRESS=false
        return
    fi
    
    log_build "🚀 Démarrage du build automatique..."
    echo ""
    
    # Vider les caches
    clear_laravel_cache
    clear_pwa_cache
    
    # Build selon le mode
    if [ "$DEV_MODE" = true ]; then
        build_laravel
        build_pwa
    elif [ "$PROD_MODE" = true ]; then
        build_laravel
        build_pwa
        # Optimisations supplémentaires pour la production
        if [ -f "artisan" ]; then
            php artisan filament:optimize-clear 2>/dev/null || log_warning "Problème avec filament:optimize-clear"
        fi
    else
        build_laravel
        build_pwa
    fi
    
    LAST_BUILD=$CURRENT_TIME
    BUILD_IN_PROGRESS=false
    
    echo ""
    log_success "✅ Build automatique terminé!"
    echo ""
}

# Construire la commande inotifywait
build_inotify_command() {
    local cmd="inotifywait -r -m"
    
    # Ajouter les répertoires à surveiller
    for dir in "${WATCH_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            cmd="$cmd $dir"
        fi
    done
    
    # Ajouter les événements à surveiller
    cmd="$cmd -e modify,create,delete,move"
    
    # Ajouter les exclusions
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        cmd="$cmd --exclude '$pattern'"
    done
    
    # Format de sortie
    cmd="$cmd --format '%w%f %e'"
    
    echo "$cmd"
}

# Fonction de surveillance
watch_files() {
    log_info "Démarrage de la surveillance des fichiers..."
    log_info "Répertoires surveillés: ${WATCH_DIRS[*]}"
    log_info "Appuyez sur Ctrl+C pour arrêter"
    echo ""
    
    # Construire la commande inotifywait
    local inotify_cmd=$(build_inotify_command)
    
    # Démarrer la surveillance
    eval "$inotify_cmd" | while read -r file event; do
        # Ignorer les fichiers temporaires
        if [[ "$file" =~ \.(tmp|log|cache|swp|swo)$ ]] || [[ "$file" =~ /\. ]]; then
            continue
        fi
        
        log_watch "Fichier modifié: $file ($event)"
        
        # Déclencher le build si activé
        if [ "$WATCH_ONLY" = false ]; then
            build_all
        fi
    done
}

# Variables par défaut
WATCH_ONLY=false
BUILD_ONLY=false
CLEAR_CACHE=false
DEV_MODE=false
PROD_MODE=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --watch-only)
            WATCH_ONLY=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --clear-cache)
            CLEAR_CACHE=true
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
    log_info "🚀 Démarrage du système d'automatisation build/cache"
    echo ""
    
    # Vérifications préliminaires
    check_dependencies
    
    # Vider le cache si demandé
    if [ "$CLEAR_CACHE" = true ]; then
        clear_laravel_cache
        clear_pwa_cache
    fi
    
    # Build immédiat si demandé
    if [ "$BUILD_ONLY" = true ]; then
        build_all
        exit 0
    fi
    
    # Démarrer la surveillance
    watch_files
}

# Gestion de l'interruption
trap 'echo ""; log_info "Arrêt de la surveillance..."; exit 0' INT TERM

# Exécuter le script principal
main 