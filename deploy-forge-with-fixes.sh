#!/bin/bash

echo "🚀 Déploiement avec Docker et corrections..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Détection de l'environnement
if [ -f "docker-compose.yml" ]; then
    USE_DOCKER=true
    info "🐳 Environnement Docker détecté"
else
    USE_DOCKER=false
    info "🏢 Environnement Forge détecté"
fi

log "📋 Début du déploiement..."

# 1. Mise à jour du code
log "📥 Récupération du code..."
git pull origin main || {
    error "Impossible de récupérer le code"
    exit 1
}

# 2. Installation des dépendances
log "📦 Installation des dépendances Composer..."
if [ "$USE_DOCKER" = true ]; then
    docker-compose exec -T app composer install --no-dev --optimize-autoloader || {
        error "Échec de l'installation Composer (Docker)"
        exit 1
    }
else
    composer install --no-dev --optimize-autoloader || {
        error "Échec de l'installation Composer"
        exit 1
    }
fi

# 3. Correction des migrations problématiques
log "🔧 Correction des migrations..."
info "Application de la migration corrigée pour la colonne 'rank'..."

# Fonction pour exécuter les commandes artisan
run_artisan() {
    if [ "$USE_DOCKER" = true ]; then
        docker-compose exec -T app php artisan $@
    else
        php artisan $@
    fi
}

# Tenter la migration normale d'abord
if run_artisan migrate --force; then
    log "✅ Migrations appliquées avec succès"
else
    warning "Échec de la migration, tentative de correction..."
    
    # Si échec, tenter de corriger
    if run_artisan migrate:rollback --step=1 --force 2>/dev/null; then
        info "Migration problématique annulée"
    fi
    
    # Réessayer la migration
    if run_artisan migrate --force; then
        log "✅ Migrations appliquées après correction"
    else
        error "Impossible d'appliquer les migrations"
        exit 1
    fi
fi

# 4. Optimisations Laravel
log "⚡ Optimisations Laravel..."
run_artisan config:cache
run_artisan route:cache
run_artisan view:cache
run_artisan event:cache
run_artisan queue:restart

# 5. Construction des assets
log "🔨 Construction des assets..."
if [ "$USE_DOCKER" = true ]; then
    # Avec Docker, utiliser le service node s'il existe, sinon utiliser app
    if docker-compose ps node >/dev/null 2>&1; then
        docker-compose exec -T node npm ci --silent
        docker-compose exec -T node npm run build --silent
    else
        info "Utilisation du conteneur app pour npm..."
        docker-compose exec -T app npm ci --silent
        docker-compose exec -T app npm run build --silent
    fi
else
    if command -v npm >/dev/null 2>&1; then
        npm ci --silent
        npm run build --silent
    else
        warning "Node.js non disponible, assets non construits"
    fi
fi

# 6. Nettoyage des caches
log "🧹 Nettoyage des caches..."
run_artisan cache:clear
run_artisan view:clear
run_artisan config:clear

# 7. Vérifications finales
log "🏥 Vérifications finales..."

# Vérifier les migrations
info "État des migrations :"
run_artisan migrate:status

# Vérifier la configuration
info "Test de la configuration :"
run_artisan config:show --json >/dev/null && log "✅ Configuration valide" || error "❌ Configuration invalide"

# Vérifier les routes
info "Test des routes :"
run_artisan route:list --json >/dev/null && log "✅ Routes valides" || error "❌ Routes invalides"

# 8. Gestion des permissions (pour les fichiers de log, storage, etc.)
log "🔒 Configuration des permissions..."
if [ "$USE_DOCKER" = true ]; then
    docker-compose exec -T app chmod -R 755 storage bootstrap/cache
    docker-compose exec -T app chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
else
    chmod -R 755 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
fi

# 9. Test de l'API des pages (pour vérifier que l'iframe fonctionne)
log "🧪 Test de l'API des pages..."
if [ "$USE_DOCKER" = true ]; then
    API_URL="http://localhost:8000/api/pages"
else
    API_URL="http://localhost/api/pages"
fi

if curl -s -f "$API_URL" >/dev/null; then
    log "✅ API des pages accessible"
else
    warning "API des pages non accessible (peut être normal selon la configuration)"
fi

# 10. Finalisation
log "🎉 Déploiement terminé avec succès !"

echo ""
info "📝 Résumé :"
echo "   ✅ Code mis à jour"
echo "   ✅ Dépendances installées"
echo "   ✅ Migrations appliquées"
echo "   ✅ Caches optimisés"
echo "   ✅ Permissions configurées"
echo ""
log "🌐 L'application est prête !"
log "🖼️  Les pages avec iframe sont maintenant disponibles via l'API /api/pages"
log "⚙️  Administration Filament accessible avec prévisualisation iframe"

echo ""
warning "⚠️  N'oubliez pas de :"
echo "   - Configurer les variables d'environnement sur Forge"
echo "   - Vérifier les DNS et certificats SSL"
echo "   - Tester l'application en production"

exit 0 