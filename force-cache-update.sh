#!/bin/bash

# Script pour forcer la mise à jour du cache et corriger les problèmes de synchronisation
# Auteur: Assistant IA
# Date: $(date)

set -e

echo "🔄 Script de mise à jour forcée du cache PWA"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "artisan" ]; then
    log_error "Ce script doit être exécuté depuis la racine du projet Laravel"
    exit 1
fi

log_info "Début de la mise à jour forcée du cache..."

# 1. Vider tous les caches Laravel
log_info "1. Vidage des caches Laravel..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan filament:clear-cache

# 2. Vider le cache Redis si disponible
log_info "2. Vidage du cache Redis..."
if command -v redis-cli &> /dev/null; then
    if redis-cli ping &> /dev/null; then
        redis-cli flushall
        log_success "Cache Redis vidé"
    else
        log_warning "Redis n'est pas accessible"
    fi
else
    log_warning "Redis CLI non installé"
fi

# 3. Forcer la régénération des caches
log_info "3. Régénération des caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 4. Invalider le cache PWA via l'API
log_info "4. Invalidation du cache PWA..."
curl -X POST http://localhost:8000/api/v1/cache/invalidate-content \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"content_types": ["recipes", "tips", "events", "videos"]}' \
  --silent --show-error || log_warning "Impossible d'invalider le cache PWA via API"

# 5. Déclencher un rebuild PWA
log_info "5. Déclenchement du rebuild PWA..."
php artisan pwa:rebuild || log_warning "Commande PWA rebuild non disponible"

# 6. Vider le cache du navigateur (Service Worker)
log_info "6. Instructions pour vider le cache du navigateur..."
echo ""
echo "📱 Pour vider le cache PWA dans le navigateur :"
echo "   1. Ouvrez les outils de développement (F12)"
echo "   2. Allez dans l'onglet 'Application' ou 'Storage'"
echo "   3. Dans 'Service Workers', cliquez sur 'Unregister'"
echo "   4. Dans 'Storage', cliquez sur 'Clear storage'"
echo "   5. Rechargez la page (Ctrl+F5 ou Cmd+Shift+R)"
echo ""

# 7. Tester les endpoints API
log_info "7. Test des endpoints API..."
echo ""

# Test de l'endpoint des recettes
log_info "Test de l'endpoint /api/v1/recipes..."
RECIPES_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8000/api/v1/recipes)
RECIPES_STATUS="${RECIPES_RESPONSE: -3}"
RECIPES_DATA="${RECIPES_RESPONSE%???}"

if [ "$RECIPES_STATUS" = "200" ]; then
    RECIPES_COUNT=$(echo "$RECIPES_DATA" | jq '.data | length' 2>/dev/null || echo "0")
    log_success "Endpoint recettes OK - $RECIPES_COUNT recettes trouvées"
else
    log_error "Erreur endpoint recettes: $RECIPES_STATUS"
fi

# Test de l'endpoint des astuces
log_info "Test de l'endpoint /api/v1/tips..."
TIPS_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8000/api/v1/tips)
TIPS_STATUS="${TIPS_RESPONSE: -3}"
TIPS_DATA="${TIPS_RESPONSE%???}"

if [ "$TIPS_STATUS" = "200" ]; then
    TIPS_COUNT=$(echo "$TIPS_DATA" | jq '.data | length' 2>/dev/null || echo "0")
    log_success "Endpoint astuces OK - $TIPS_COUNT astuces trouvées"
else
    log_error "Erreur endpoint astuces: $TIPS_STATUS"
fi

# Test de l'endpoint des événements
log_info "Test de l'endpoint /api/v1/events..."
EVENTS_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8000/api/v1/events)
EVENTS_STATUS="${EVENTS_RESPONSE: -3}"
EVENTS_DATA="${EVENTS_RESPONSE%???}"

if [ "$EVENTS_STATUS" = "200" ]; then
    EVENTS_COUNT=$(echo "$EVENTS_DATA" | jq '.data | length' 2>/dev/null || echo "0")
    log_success "Endpoint événements OK - $EVENTS_COUNT événements trouvés"
else
    log_error "Erreur endpoint événements: $EVENTS_STATUS"
fi

# 8. Vérifier la configuration du cache
log_info "8. Vérification de la configuration du cache..."
CACHE_DRIVER=$(php artisan tinker --execute="echo config('cache.default');" 2>/dev/null || echo "unknown")
log_info "Driver de cache actuel: $CACHE_DRIVER"

if [ "$CACHE_DRIVER" = "redis" ]; then
    log_success "Redis est configuré comme driver de cache"
else
    log_warning "Redis n'est pas le driver de cache principal"
fi

# 9. Vérifier les permissions de stockage
log_info "9. Vérification des permissions de stockage..."
if [ -w "storage" ]; then
    log_success "Permissions de stockage OK"
else
    log_error "Problème de permissions sur le dossier storage"
    chmod -R 775 storage bootstrap/cache 2>/dev/null || log_warning "Impossible de corriger les permissions"
fi

# 10. Redémarrer les services si nécessaire
log_info "10. Redémarrage des services..."
if command -v supervisorctl &> /dev/null; then
    supervisorctl restart all 2>/dev/null || log_warning "Supervisor non configuré"
fi

# 11. Instructions finales
echo ""
log_success "Mise à jour forcée du cache terminée !"
echo ""
echo "📋 Actions recommandées :"
echo "   1. Rechargez la page PWA avec Ctrl+F5 (ou Cmd+Shift+R)"
echo "   2. Vérifiez que le contenu est à jour dans les carousels"
echo "   3. Testez la navigation entre les pages"
echo "   4. Vérifiez que les nouvelles recettes apparaissent"
echo ""
echo "🔧 Si les problèmes persistent :"
echo "   1. Videz le cache du navigateur complètement"
echo "   2. Désactivez temporairement le Service Worker"
echo "   3. Vérifiez les logs Laravel: tail -f storage/logs/laravel.log"
echo "   4. Vérifiez les logs du navigateur (Console)"
echo ""

# 12. Test de connectivité PWA
log_info "11. Test de connectivité PWA..."
PWA_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8000/pwa/ || echo "000")
PWA_STATUS="${PWA_RESPONSE: -3}"

if [ "$PWA_STATUS" = "200" ]; then
    log_success "PWA accessible"
else
    log_error "PWA non accessible (status: $PWA_STATUS)"
fi

echo ""
log_success "✅ Script terminé avec succès !"
echo ""
echo "🎯 Prochaines étapes :"
echo "   - Testez l'application PWA"
echo "   - Vérifiez que le contenu est synchronisé"
echo "   - Surveillez les logs pour détecter d'éventuels problèmes"
echo "" 