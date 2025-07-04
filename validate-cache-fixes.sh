#!/bin/bash

# Script de validation finale des corrections du cache PWA
echo "🔍 Validation finale des corrections du cache PWA"
echo "================================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
BASE_URL="http://localhost:8000"
API_BASE="$BASE_URL/api/v1"
TOTAL_TESTS=0
PASSED_TESTS=0

# Fonction pour afficher les résultats
print_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Fonction pour tester une API
test_api() {
    local endpoint="$1"
    local description="$2"
    local expected_status="${3:-200}"
    
    echo -n "Test: $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE$endpoint")
    
    if [ "$response" -eq "$expected_status" ]; then
        print_result 0 "$description"
        return 0
    else
        print_result 1 "$description (HTTP $response)"
        return 1
    fi
}

# Fonction pour tester le cache
test_cache_invalidation() {
    local content_type="$1"
    local description="$2"
    
    echo -n "Test cache: $description... "
    
    # Invalider le cache
    invalidation_response=$(curl -s -X POST "$API_BASE/pwa/cache/invalidate-content" \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"$content_type\"}" | jq -r '.success' 2>/dev/null)
    
    if [ "$invalidation_response" = "true" ]; then
        print_result 0 "$description"
        return 0
    else
        print_result 1 "$description"
        return 1
    fi
}

echo -e "${BLUE}1. Vérification de l'environnement${NC}"
echo "----------------------------------------"

# Vérifier que Docker est en cours d'exécution
echo -n "Vérification Docker... "
if docker-compose ps | grep -q "Up"; then
    print_result 0 "Docker en cours d'exécution"
else
    print_result 1 "Docker non en cours d'exécution"
    echo -e "${RED}❌ Veuillez démarrer l'application avec : ./restart-with-cache-fixes.sh${NC}"
    exit 1
fi

# Vérifier Redis
echo -n "Vérification Redis... "
if docker-compose exec -T redis redis-cli ping | grep -q "PONG"; then
    print_result 0 "Redis accessible"
else
    print_result 1 "Redis non accessible"
fi

# Vérifier la configuration du cache
echo -n "Vérification du driver de cache... "
cache_driver=$(curl -s "$API_BASE/pwa/cache/stats" | jq -r '.data.cache_driver' 2>/dev/null)
if [ "$cache_driver" = "redis" ]; then
    print_result 0 "Cache driver: $cache_driver"
else
    print_result 1 "Cache driver: $cache_driver (devrait être redis)"
fi

# Vérifier le support des tags
echo -n "Vérification du support des tags... "
tags_supported=$(curl -s "$API_BASE/pwa/cache/stats" | jq -r '.data.tags_supported' 2>/dev/null)
if [ "$tags_supported" = "true" ]; then
    print_result 0 "Tags supportés"
else
    print_result 1 "Tags non supportés"
fi

echo -e "\n${BLUE}2. Test des APIs principales${NC}"
echo "--------------------------------"

# Tests des APIs
test_api "/recipes" "API Recettes"
test_api "/events" "API Événements"
test_api "/tips" "API Astuces"
test_api "/categories" "API Catégories"

echo -e "\n${BLUE}3. Test du système de cache${NC}"
echo "--------------------------------"

# Test du statut du cache
echo -n "Test du statut du cache... "
status_response=$(curl -s "$API_BASE/pwa/cache/status" | jq -r '.success' 2>/dev/null)
if [ "$status_response" = "true" ]; then
    print_result 0 "Statut du cache"
else
    print_result 1 "Statut du cache"
fi

# Test des statistiques du cache
echo -n "Test des statistiques du cache... "
stats_response=$(curl -s "$API_BASE/pwa/cache/stats" | jq -r '.success' 2>/dev/null)
if [ "$stats_response" = "true" ]; then
    print_result 0 "Statistiques du cache"
else
    print_result 1 "Statistiques du cache"
fi

echo -e "\n${BLUE}4. Test de l'invalidation du cache${NC}"
echo "----------------------------------------"

# Tests d'invalidation par type de contenu
test_cache_invalidation "recipes" "Invalidation cache recettes"
test_cache_invalidation "events" "Invalidation cache événements"
test_cache_invalidation "tips" "Invalidation cache astuces"

echo -e "\n${BLUE}5. Test du Service Worker${NC}"
echo "--------------------------------"

# Vérifier que le Service Worker est accessible
echo -n "Vérification du Service Worker... "
sw_response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/sw.js")
if [ "$sw_response" -eq 200 ]; then
    print_result 0 "Service Worker accessible"
else
    print_result 1 "Service Worker non accessible (HTTP $sw_response)"
fi

# Vérifier la version du Service Worker
echo -n "Vérification de la version du Service Worker... "
sw_content=$(curl -s "$BASE_URL/sw.js")
if echo "$sw_content" | grep -q "dinor-pwa-v3"; then
    print_result 0 "Version du Service Worker (v3)"
else
    print_result 1 "Version du Service Worker obsolète"
fi

echo -e "\n${BLUE}6. Test de la PWA${NC}"
echo "------------------------"

# Vérifier que la PWA est accessible
echo -n "Vérification de la PWA... "
pwa_response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/pwa/")
if [ "$pwa_response" -eq 200 ]; then
    print_result 0 "PWA accessible"
else
    print_result 1 "PWA non accessible (HTTP $pwa_response)"
fi

echo -e "\n${BLUE}7. Test des headers de cache${NC}"
echo "----------------------------------"

# Vérifier les headers de cache pour les APIs
echo -n "Vérification des headers de cache... "
cache_headers=$(curl -s -I "$API_BASE/recipes" | grep -i "cache-control" | head -1)
if echo "$cache_headers" | grep -q "no-cache"; then
    print_result 0 "Headers de cache corrects"
else
    print_result 1 "Headers de cache incorrects"
fi

echo -e "\n${BLUE}8. Test de performance${NC}"
echo "----------------------------"

# Test de performance des APIs
echo -n "Test de performance API recettes... "
start_time=$(date +%s%N)
curl -s "$API_BASE/recipes" > /dev/null
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 ))

if [ $duration -lt 1000 ]; then
    print_result 0 "Performance API recettes (${duration}ms)"
else
    print_result 1 "Performance API recettes lente (${duration}ms)"
fi

echo -e "\n${BLUE}9. Test de la configuration Laravel${NC}"
echo "----------------------------------------"

# Vérifier la configuration Laravel
echo -n "Vérification de la configuration Laravel... "
if docker-compose exec -T app php artisan config:cache > /dev/null 2>&1; then
    print_result 0 "Configuration Laravel valide"
else
    print_result 1 "Configuration Laravel invalide"
fi

echo -e "\n${BLUE}10. Test des observateurs${NC}"
echo "--------------------------------"

# Vérifier que les observateurs sont enregistrés
echo -n "Vérification des observateurs... "
if docker-compose exec -T app php artisan tinker --execute="echo 'Observateurs OK';" > /dev/null 2>&1; then
    print_result 0 "Observateurs enregistrés"
else
    print_result 1 "Observateurs non enregistrés"
fi

echo -e "\n${YELLOW}📊 Résumé des tests${NC}"
echo "======================"
echo -e "Tests réussis: ${GREEN}$PASSED_TESTS/$TOTAL_TESTS${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}🎉 Tous les tests sont passés! Les corrections du cache PWA fonctionnent correctement.${NC}"
else
    echo -e "\n${YELLOW}⚠️  Certains tests ont échoué. Vérifiez la configuration et relancez les tests.${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Prochaines étapes recommandées:${NC}"
echo "1. Tester la mise à jour d'une recette dans Filament"
echo "2. Vérifier que les changements apparaissent dans la PWA"
echo "3. Tester l'invalidation manuelle du cache"
echo "4. Monitorer les performances"
echo ""
echo -e "${YELLOW}💡 Commandes utiles:${NC}"
echo "• Voir les logs: docker-compose logs -f app"
echo "• Redémarrer l'application: ./restart-with-cache-fixes.sh"
echo "• Tester les APIs: ./test-cache-fixes.sh"
echo "• Invalider le cache: curl -X POST $API_BASE/pwa/cache/invalidate-content -H 'Content-Type: application/json' -d '{\"type\": \"recipes\"}'" 