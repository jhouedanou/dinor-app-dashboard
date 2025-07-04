#!/bin/bash

# Script pour redémarrer l'application avec les corrections du cache PWA
echo "🔄 Redémarrage avec les corrections du cache PWA"
echo "================================================"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les étapes
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

# Fonction pour afficher les succès
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Fonction pour afficher les erreurs
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Fonction pour afficher les avertissements
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_step "1. Arrêt des containers Docker"
docker-compose down

print_step "2. Vérification de la configuration Redis"
if ! docker-compose config | grep -q "redis:"; then
    print_error "Redis n'est pas configuré dans docker-compose.yml"
    exit 1
else
    print_success "Redis est configuré"
fi

print_step "3. Redémarrage des containers"
docker-compose up -d

print_step "4. Attente du démarrage des services"
sleep 10

print_step "5. Vérification de la connectivité Redis"
if docker-compose exec -T redis redis-cli ping | grep -q "PONG"; then
    print_success "Redis est accessible"
else
    print_error "Redis n'est pas accessible"
    exit 1
fi

print_step "6. Vérification de la connectivité de l'application"
if curl -s http://localhost:8000/api/v1/recipes > /dev/null; then
    print_success "Application accessible"
else
    print_warning "Application pas encore accessible, attente..."
    sleep 10
    if curl -s http://localhost:8000/api/v1/recipes > /dev/null; then
        print_success "Application accessible"
    else
        print_error "Application non accessible"
        exit 1
    fi
fi

print_step "7. Nettoyage des caches Laravel"
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan route:clear
docker-compose exec -T app php artisan view:clear

print_step "8. Vérification de la configuration du cache"
cache_driver=$(curl -s http://localhost:8000/api/v1/pwa/cache/stats | jq -r '.data.cache_driver' 2>/dev/null)
if [ "$cache_driver" = "redis" ]; then
    print_success "Cache driver configuré: $cache_driver"
else
    print_warning "Cache driver: $cache_driver (devrait être redis)"
fi

print_step "9. Test du Service Worker"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/sw.js | grep -q "200"; then
    print_success "Service Worker accessible"
else
    print_error "Service Worker non accessible"
fi

print_step "10. Test de la PWA"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/pwa/ | grep -q "200"; then
    print_success "PWA accessible"
else
    print_error "PWA non accessible"
fi

print_step "11. Test d'invalidation du cache"
invalidation_response=$(curl -s -X POST http://localhost:8000/api/v1/pwa/cache/invalidate-content \
    -H "Content-Type: application/json" \
    -d '{"type": "recipes"}' | jq -r '.success' 2>/dev/null)

if [ "$invalidation_response" = "true" ]; then
    print_success "Invalidation du cache fonctionnelle"
else
    print_error "Invalidation du cache non fonctionnelle"
fi

echo ""
echo -e "${GREEN}🎉 Redémarrage terminé avec succès!${NC}"
echo ""
echo -e "${BLUE}📋 Prochaines étapes de test:${NC}"
echo "1. Ouvrir http://localhost:8000/admin dans votre navigateur"
echo "2. Modifier une recette existante"
echo "3. Vérifier que les changements apparaissent dans la PWA"
echo "4. Tester l'invalidation manuelle du cache:"
echo "   curl -X POST http://localhost:8000/api/v1/pwa/cache/invalidate-content \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"type\": \"recipes\"}'"
echo ""
echo -e "${YELLOW}🔧 Commandes utiles:${NC}"
echo "• Voir les logs: docker-compose logs -f app"
echo "• Redémarrer un service: docker-compose restart app"
echo "• Vider le cache: docker-compose exec app php artisan cache:clear"
echo "• Tester les APIs: ./test-cache-fixes.sh" 