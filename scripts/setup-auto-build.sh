#!/bin/bash

# Script de configuration pour l'automatisation du build et du vidage du cache
# Usage: ./scripts/setup-auto-build.sh [options]

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_setup() {
    echo -e "${PURPLE}[SETUP]${NC} $1"
}

# Fonction d'aide
show_help() {
    cat << EOF
Script de configuration pour l'automatisation du build et du vidage du cache

Usage: $0 [OPTIONS]

OPTIONS:
    --install-deps     Installer les dépendances système
    --setup-scripts    Configurer les scripts npm/composer
    --create-aliases   Créer des alias pour les commandes
    --all             Effectuer toutes les configurations
    --help            Afficher cette aide

EXEMPLES:
    $0 --all                    # Configuration complète
    $0 --install-deps           # Installer seulement les dépendances
    $0 --setup-scripts          # Configurer seulement les scripts
    $0 --create-aliases         # Créer seulement les alias

EOF
}

# Détecter le système d'exploitation
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Installer les dépendances système
install_system_dependencies() {
    local os=$(detect_os)
    
    log_setup "Installation des dépendances système pour $os..."
    
    case $os in
        "linux")
            # Ubuntu/Debian
            if command -v apt-get &> /dev/null; then
                log_info "Installation via apt-get..."
                sudo apt-get update
                sudo apt-get install -y inotify-tools curl wget git
                log_success "Dépendances installées via apt-get"
            # CentOS/RHEL/Fedora
            elif command -v yum &> /dev/null; then
                log_info "Installation via yum..."
                sudo yum install -y inotify-tools curl wget git
                log_success "Dépendances installées via yum"
            # Arch Linux
            elif command -v pacman &> /dev/null; then
                log_info "Installation via pacman..."
                sudo pacman -S --noconfirm inotify-tools curl wget git
                log_success "Dépendances installées via pacman"
            else
                log_error "Gestionnaire de paquets non reconnu"
                return 1
            fi
            ;;
        "macos")
            log_info "Installation via Homebrew..."
            if ! command -v brew &> /dev/null; then
                log_info "Installation de Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install inotify-tools curl wget git
            log_success "Dépendances installées via Homebrew"
            ;;
        "windows")
            log_warning "Windows détecté. Veuillez installer manuellement:"
            echo "  - inotify-tools (via WSL ou Git Bash)"
            echo "  - Node.js: https://nodejs.org/"
            echo "  - PHP: https://windows.php.net/"
            echo "  - Composer: https://getcomposer.org/"
            return 1
            ;;
        *)
            log_error "Système d'exploitation non supporté: $os"
            return 1
            ;;
    esac
}

# Vérifier les dépendances
check_dependencies() {
    log_setup "Vérification des dépendances..."
    
    local missing_deps=()
    
    # Vérifier inotify-tools
    if ! command -v inotifywait &> /dev/null; then
        missing_deps+=("inotify-tools")
    fi
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        missing_deps+=("Node.js")
    fi
    
    # Vérifier npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    # Vérifier PHP
    if ! command -v php &> /dev/null; then
        missing_deps+=("PHP")
    fi
    
    # Vérifier Composer
    if ! command -v composer &> /dev/null; then
        missing_deps+=("Composer")
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        log_success "Toutes les dépendances sont installées"
        return 0
    else
        log_warning "Dépendances manquantes: ${missing_deps[*]}"
        return 1
    fi
}

# Configurer les scripts npm
setup_npm_scripts() {
    log_setup "Configuration des scripts npm..."
    
    if [ ! -f "package.json" ]; then
        log_warning "Fichier package.json non trouvé"
        return 1
    fi
    
    # Vérifier si les scripts existent déjà
    if grep -q '"auto:watch"' package.json; then
        log_info "Scripts npm déjà configurés"
        return 0
    fi
    
    # Ajouter les nouveaux scripts
    local temp_file=$(mktemp)
    jq '.scripts += {
        "auto:watch": "./scripts/auto-build-watch.sh",
        "auto:dev": "./scripts/dev-watch.sh",
        "auto:build": "./scripts/auto-build-watch.sh --build-only",
        "auto:clear": "./scripts/auto-build-watch.sh --clear-cache",
        "dev:full": "./scripts/dev-watch.sh --clear-cache",
        "dev:laravel": "./scripts/dev-watch.sh --laravel-only",
        "dev:pwa": "./scripts/dev-watch.sh --pwa-only"
    }' package.json > "$temp_file"
    
    mv "$temp_file" package.json
    
    log_success "Scripts npm configurés"
}

# Configurer les scripts composer
setup_composer_scripts() {
    log_setup "Configuration des scripts composer..."
    
    if [ ! -f "composer.json" ]; then
        log_warning "Fichier composer.json non trouvé"
        return 1
    fi
    
    # Vérifier si les scripts existent déjà
    if grep -q '"auto:watch"' composer.json; then
        log_info "Scripts composer déjà configurés"
        return 0
    fi
    
    # Ajouter les nouveaux scripts
    local temp_file=$(mktemp)
    jq '.scripts += {
        "auto:watch": "./scripts/auto-build-watch.sh",
        "auto:build": "./scripts/auto-build-watch.sh --build-only",
        "auto:clear": "./scripts/auto-build-watch.sh --clear-cache",
        "dev:full": "./scripts/dev-watch.sh --clear-cache",
        "dev:laravel": "./scripts/dev-watch.sh --laravel-only"
    }' composer.json > "$temp_file"
    
    mv "$temp_file" composer.json
    
    log_success "Scripts composer configurés"
}

# Créer des alias pour les commandes
create_aliases() {
    log_setup "Création des alias..."
    
    local shell_rc=""
    local alias_content=""
    
    # Détecter le shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        log_warning "Shell non reconnu: $SHELL"
        return 1
    fi
    
    # Vérifier si les alias existent déjà
    if grep -q "alias dinor-watch" "$shell_rc" 2>/dev/null; then
        log_info "Alias déjà configurés dans $shell_rc"
        return 0
    fi
    
    # Créer le contenu des alias
    alias_content="
# Aliases pour Dinor Dashboard - Auto Build & Cache
alias dinor-watch='./scripts/auto-build-watch.sh'
alias dinor-dev='./scripts/dev-watch.sh'
alias dinor-build='./scripts/auto-build-watch.sh --build-only'
alias dinor-clear='./scripts/auto-build-watch.sh --clear-cache'
alias dinor-dev-full='./scripts/dev-watch.sh --clear-cache'
alias dinor-dev-laravel='./scripts/dev-watch.sh --laravel-only'
alias dinor-dev-pwa='./scripts/dev-watch.sh --pwa-only'
"
    
    # Ajouter les alias au fichier de configuration du shell
    echo "$alias_content" >> "$shell_rc"
    
    log_success "Alias ajoutés à $shell_rc"
    log_info "Rechargez votre shell avec: source $shell_rc"
}

# Créer un fichier de configuration
create_config_file() {
    log_setup "Création du fichier de configuration..."
    
    local config_file=".auto-build-config"
    
    if [ -f "$config_file" ]; then
        log_info "Fichier de configuration déjà existant"
        return 0
    fi
    
    cat > "$config_file" << EOF
# Configuration pour l'automatisation du build et du vidage du cache
# Fichier généré automatiquement par setup-auto-build.sh

# Répertoires à surveiller
WATCH_DIRS=("app" "resources" "config" "routes" "database" "src")

# Patterns à exclure
EXCLUDE_PATTERNS=("*.log" "*.tmp" "*.cache" "node_modules/*" "vendor/*" ".git/*" "storage/logs/*" "storage/framework/cache/*")

# Délai entre les builds (en secondes)
BUILD_DELAY=2

# Mode par défaut (dev/prod)
DEFAULT_MODE="dev"

# Serveurs par défaut
DEFAULT_SERVERS=("laravel" "pwa")

# Configuration des ports
LARAVEL_PORT=8000
PWA_PORT=5173
BROWSERSYNC_PORT=3001

# Configuration du cache
CACHE_TAGS=("pwa" "recipes" "events" "tips" "dinor-tv" "pages")
CACHE_PREFIX="dinor_cache_"

# Configuration des logs
LOG_LEVEL="info"
LOG_FILE="storage/logs/auto-build.log"

# Configuration de la surveillance
WATCH_EVENTS=("modify" "create" "delete" "move")
WATCH_RECURSIVE=true
WATCH_MONITOR=true
EOF
    
    log_success "Fichier de configuration créé: $config_file"
}

# Créer un fichier README pour l'automatisation
create_readme() {
    log_setup "Création du README d'automatisation..."
    
    local readme_file="AUTO_BUILD_README.md"
    
    if [ -f "$readme_file" ]; then
        log_info "README d'automatisation déjà existant"
        return 0
    fi
    
    cat > "$readme_file" << 'EOF'
# Automatisation du Build et du Vidage du Cache

Ce système automatise le build et le vidage du cache lors des modifications de fichiers dans votre projet Dinor Dashboard.

## 🚀 Installation

```bash
# Configuration complète
./scripts/setup-auto-build.sh --all

# Ou étape par étape
./scripts/setup-auto-build.sh --install-deps
./scripts/setup-auto-build.sh --setup-scripts
./scripts/setup-auto-build.sh --create-aliases
```

## 📋 Utilisation

### Commandes principales

```bash
# Surveillance automatique avec build
./scripts/auto-build-watch.sh

# Environnement de développement complet
./scripts/dev-watch.sh

# Build immédiat
./scripts/auto-build-watch.sh --build-only

# Vider le cache
./scripts/auto-build-watch.sh --clear-cache
```

### Commandes npm (après configuration)

```bash
npm run auto:watch      # Surveillance automatique
npm run auto:dev        # Environnement de développement
npm run auto:build      # Build immédiat
npm run auto:clear      # Vider le cache
npm run dev:full        # Développement complet
npm run dev:laravel     # Serveur Laravel seulement
npm run dev:pwa         # Serveur PWA seulement
```

### Commandes composer (après configuration)

```bash
composer auto:watch     # Surveillance automatique
composer auto:build     # Build immédiat
composer auto:clear     # Vider le cache
composer dev:full       # Développement complet
composer dev:laravel    # Serveur Laravel seulement
```

### Alias (après configuration)

```bash
dinor-watch            # Surveillance automatique
dinor-dev              # Environnement de développement
dinor-build            # Build immédiat
dinor-clear            # Vider le cache
dinor-dev-full         # Développement complet
dinor-dev-laravel      # Serveur Laravel seulement
dinor-dev-pwa          # Serveur PWA seulement
```

## ⚙️ Configuration

Le fichier `.auto-build-config` contient la configuration du système d'automatisation.

### Options principales

- `WATCH_DIRS`: Répertoires surveillés
- `EXCLUDE_PATTERNS`: Patterns à exclure
- `BUILD_DELAY`: Délai entre les builds
- `DEFAULT_MODE`: Mode par défaut (dev/prod)
- `DEFAULT_SERVERS`: Serveurs par défaut

## 🔧 Fonctionnalités

### Surveillance automatique
- Détection des modifications de fichiers en temps réel
- Exclusion des fichiers temporaires et de cache
- Déclenchement automatique du build et du vidage du cache

### Build automatique
- Vidage du cache Laravel (général, config, vues, routes)
- Vidage du cache PWA
- Redécouverte des composants Livewire
- Optimisation de l'autoloader Composer
- Reconstruction des caches optimisés
- Build PWA en arrière-plan

### Environnement de développement
- Serveur Laravel automatique (port 8000)
- Serveur PWA automatique (port 5173)
- BrowserSync optionnel (port 3001)
- Nettoyage automatique des processus à la sortie

## 🛠️ Dépannage

### Problèmes courants

1. **inotify-tools non installé**
   ```bash
   sudo apt-get install inotify-tools  # Ubuntu/Debian
   brew install inotify-tools          # macOS
   ```

2. **Permissions insuffisantes**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Ports déjà utilisés**
   - Vérifiez les processus sur les ports 8000, 5173, 3001
   - Arrêtez les processus conflictuels

4. **Cache corrompu**
   ```bash
   ./scripts/auto-build-watch.sh --clear-cache
   ```

### Logs

Les logs sont affichés en temps réel avec des codes couleur :
- 🔵 [INFO]: Informations générales
- 🟢 [SUCCESS]: Opérations réussies
- 🟡 [WARNING]: Avertissements
- 🔴 [ERROR]: Erreurs
- 🟣 [BUILD]: Opérations de build
- 🔵 [WATCH]: Surveillance des fichiers
- 🟣 [DEV]: Serveurs de développement

## 📝 Notes

- Le système évite les builds trop fréquents (délai configurable)
- Les builds PWA s'exécutent en arrière-plan pour ne pas bloquer
- Tous les processus sont automatiquement nettoyés à la sortie
- Le système fonctionne avec Docker et les environnements locaux

## 🤝 Contribution

Pour ajouter de nouvelles fonctionnalités ou corriger des bugs, modifiez les scripts dans le dossier `scripts/` et mettez à jour cette documentation.
EOF
    
    log_success "README d'automatisation créé: $readme_file"
}

# Script principal
main() {
    log_info "🚀 Configuration de l'automatisation du build et du vidage du cache"
    echo ""
    
    # Variables par défaut
    INSTALL_DEPS=false
    SETUP_SCRIPTS=false
    CREATE_ALIASES=false
    SETUP_ALL=false
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-deps)
                INSTALL_DEPS=true
                shift
                ;;
            --setup-scripts)
                SETUP_SCRIPTS=true
                shift
                ;;
            --create-aliases)
                CREATE_ALIASES=true
                shift
                ;;
            --all)
                SETUP_ALL=true
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
    
    # Si --all est spécifié, activer toutes les options
    if [ "$SETUP_ALL" = true ]; then
        INSTALL_DEPS=true
        SETUP_SCRIPTS=true
        CREATE_ALIASES=true
    fi
    
    # Si aucune option n'est spécifiée, afficher l'aide
    if [ "$INSTALL_DEPS" = false ] && [ "$SETUP_SCRIPTS" = false ] && [ "$CREATE_ALIASES" = false ]; then
        show_help
        exit 0
    fi
    
    # Installer les dépendances
    if [ "$INSTALL_DEPS" = true ]; then
        install_system_dependencies
        check_dependencies
    fi
    
    # Configurer les scripts
    if [ "$SETUP_SCRIPTS" = true ]; then
        setup_npm_scripts
        setup_composer_scripts
        create_config_file
        create_readme
    fi
    
    # Créer les alias
    if [ "$CREATE_ALIASES" = true ]; then
        create_aliases
    fi
    
    echo ""
    log_success "✅ Configuration terminée!"
    echo ""
    log_info "📋 Prochaines étapes:"
    echo "  1. Rechargez votre shell: source ~/.bashrc ou source ~/.zshrc"
    echo "  2. Testez l'automatisation: ./scripts/auto-build-watch.sh --help"
    echo "  3. Consultez le README: cat AUTO_BUILD_README.md"
    echo ""
}

# Exécuter le script principal
main "$@" 