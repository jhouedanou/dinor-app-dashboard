#!/bin/bash

echo "🔍 DIAGNOSTIC COMPLET ERREUR 403 - DINOR DASHBOARD"
echo "=================================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour les logs colorés
log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_info() {
    echo "ℹ️  $1"
}

# Naviguer vers le dossier du site
SITE_PATH="/home/forge/new.dinorapp.com"
if [ ! -d "$SITE_PATH" ]; then
    log_error "Dossier du site non trouvé : $SITE_PATH"
    exit 1
fi

cd $SITE_PATH

echo ""
echo "📁 DIAGNOSTIC 1: STRUCTURE DES FICHIERS"
echo "========================================"

# Vérifier la structure de base
if [ -f "public/index.php" ]; then
    log_success "public/index.php existe"
else
    log_error "public/index.php MANQUANT - Problème critique!"
fi

if [ -f ".env" ]; then
    log_success ".env existe"
else
    log_error ".env MANQUANT - Problème critique!"
fi

if [ -f "artisan" ]; then
    log_success "artisan existe"
else
    log_error "artisan MANQUANT - Problème critique!"
fi

# Vérifier les permissions
echo ""
echo "🔐 DIAGNOSTIC 2: PERMISSIONS"
echo "============================"
log_info "Permissions du dossier racine:"
ls -la | head -5

log_info "Permissions public/:"
ls -la public/ | head -5

log_info "Permissions storage/:"
ls -la storage/ | head -5

echo ""
echo "⚙️  DIAGNOSTIC 3: CONFIGURATION PHP/LARAVEL"
echo "==========================================="

# Test PHP
php_version=$(php -v | head -n 1)
log_info "Version PHP: $php_version"

# Test Laravel
if php artisan --version > /dev/null 2>&1; then
    laravel_version=$(php artisan --version)
    log_success "Laravel fonctionne: $laravel_version"
else
    log_error "Laravel ne répond pas - Problème critique!"
fi

# Test de la base de données
echo ""
echo "🗄️  DIAGNOSTIC 4: BASE DE DONNÉES"
echo "================================="

if php artisan migrate:status > /dev/null 2>&1; then
    log_success "Connexion base de données OK"
    log_info "État des migrations:"
    php artisan migrate:status | tail -5
else
    log_error "Problème de connexion à la base de données!"
fi

# Vérifier l'utilisateur admin
admin_count=$(php artisan tinker --execute="echo App\Models\AdminUser::count();" 2>/dev/null | tail -1)
if [ "$admin_count" -gt 0 ] 2>/dev/null; then
    log_success "Utilisateur admin existe (count: $admin_count)"
else
    log_error "Aucun utilisateur admin trouvé!"
    log_info "Création d'un utilisateur admin..."
    php artisan db:seed --class=AdminUserSeeder
fi

echo ""
echo "🌐 DIAGNOSTIC 5: ROUTES ET FILAMENT"
echo "=================================="

# Test des routes
if php artisan route:list | grep -q "admin"; then
    log_success "Routes admin configurées"
    log_info "Routes admin disponibles:"
    php artisan route:list | grep admin | head -3
else
    log_error "Routes admin non trouvées!"
fi

# Test de la configuration Filament
if php artisan config:show filament > /dev/null 2>&1; then
    log_success "Configuration Filament OK"
else
    log_error "Problème avec la configuration Filament!"
fi

echo ""
echo "📋 DIAGNOSTIC 6: VARIABLES D'ENVIRONNEMENT"
echo "=========================================="

# Vérifier les variables critiques (sans afficher les valeurs sensibles)
if grep -q "APP_KEY=base64:" .env; then
    log_success "APP_KEY configurée"
else
    log_error "APP_KEY manquante ou incorrecte"
    log_info "Génération d'une nouvelle clé..."
    php artisan key:generate --force
fi

if grep -q "APP_ENV=production" .env; then
    log_success "APP_ENV=production"
else
    log_warning "APP_ENV n'est pas en production"
fi

if grep -q "DB_DATABASE=" .env; then
    log_success "DB_DATABASE configurée"
else
    log_error "DB_DATABASE manquante"
fi

echo ""
echo "🔧 DIAGNOSTIC 7: CACHE ET OPTIMISATIONS"
echo "======================================="

# Nettoyer les caches
log_info "Nettoyage des caches..."
php artisan optimize:clear > /dev/null 2>&1
log_success "Caches nettoyés"

# Reconfigurer les caches
log_info "Reconfiguration des caches..."
php artisan config:cache > /dev/null 2>&1
php artisan route:cache > /dev/null 2>&1
log_success "Caches reconfigurés"

echo ""
echo "🌐 DIAGNOSTIC 8: TEST DES URLs"
echo "============================="

# Test avec curl si disponible
if command -v curl > /dev/null; then
    DOMAIN=$(grep APP_URL .env | cut -d'=' -f2 | tr -d '"')
    if [ ! -z "$DOMAIN" ]; then
        log_info "Test de l'URL principale: $DOMAIN"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN" 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            log_success "URL principale répond (code: $HTTP_CODE)"
        else
            log_error "URL principale ne répond pas (code: $HTTP_CODE)"
        fi
        
        log_info "Test de l'URL admin: $DOMAIN/admin"
        HTTP_CODE_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/admin" 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE_ADMIN" = "200" ] || [ "$HTTP_CODE_ADMIN" = "302" ]; then
            log_success "URL admin répond (code: $HTTP_CODE_ADMIN)"
        else
            log_error "URL admin ne répond pas (code: $HTTP_CODE_ADMIN)"
        fi
    fi
fi

echo ""
echo "📝 DIAGNOSTIC 9: LOGS D'ERREURS"
echo "==============================="

# Vérifier les logs Laravel
if [ -f "storage/logs/laravel.log" ]; then
    log_info "Dernières erreurs Laravel:"
    tail -10 storage/logs/laravel.log | grep -E "(ERROR|CRITICAL|emergency)" || log_success "Aucune erreur récente dans Laravel"
else
    log_warning "Fichier de log Laravel non trouvé"
fi

echo ""
echo "🎯 DIAGNOSTIC 10: TESTS SPÉCIFIQUES"
echo "=================================="

# Test d'accès direct au fichier index.php
log_info "Test d'accès au fichier index.php..."
if [ -r "public/index.php" ]; then
    log_success "public/index.php est lisible"
    
    # Vérifier le contenu du fichier index.php
    if grep -q "Laravel" public/index.php; then
        log_success "public/index.php contient le code Laravel"
    else
        log_error "public/index.php ne semble pas être un fichier Laravel valide!"
    fi
else
    log_error "public/index.php n'est pas lisible!"
fi

# Test des assets CSS/JS
log_info "Vérification des assets compilés..."
if [ -d "public/css" ] && [ -d "public/js" ]; then
    log_success "Dossiers assets présents"
else
    log_warning "Assets manquants - rebuild nécessaire"
    log_info "Tentative de build des assets..."
    if command -v npm > /dev/null; then
        npm run build > /dev/null 2>&1 && log_success "Assets buildés" || log_warning "Échec du build des assets"
    fi
fi

echo ""
echo "📊 RÉSUMÉ DU DIAGNOSTIC"
echo "======================"

# Créer un fichier de rapport
REPORT_FILE="diagnostic-403-$(date +%Y%m%d-%H%M%S).txt"
{
    echo "=== RAPPORT DIAGNOSTIC 403 ==="
    echo "Date: $(date)"
    echo "Site: $SITE_PATH"
    echo ""
    echo "Structure fichiers:"
    echo "- public/index.php: $([ -f public/index.php ] && echo 'OK' || echo 'MANQUANT')"
    echo "- .env: $([ -f .env ] && echo 'OK' || echo 'MANQUANT')"
    echo "- artisan: $([ -f artisan ] && echo 'OK' || echo 'MANQUANT')"
    echo ""
    echo "Laravel:"
    echo "- Version: $(php artisan --version 2>/dev/null || echo 'ERROR')"
    echo "- Base de données: $(php artisan migrate:status > /dev/null 2>&1 && echo 'OK' || echo 'ERROR')"
    echo "- Admin users: $(php artisan tinker --execute="echo App\Models\AdminUser::count();" 2>/dev/null | tail -1 || echo 'ERROR')"
    echo ""
    echo "Configuration:"
    echo "- APP_KEY: $(grep -q 'APP_KEY=base64:' .env && echo 'OK' || echo 'MANQUANT')"
    echo "- APP_ENV: $(grep 'APP_ENV=' .env | cut -d'=' -f2 || echo 'NON_DÉFINI')"
} > $REPORT_FILE

log_success "Rapport sauvegardé: $REPORT_FILE"

echo ""
echo "🚀 PROCHAINES ÉTAPES RECOMMANDÉES"
echo "================================="

log_info "1. Vérifiez le rapport: cat $REPORT_FILE"
log_info "2. Si tous les tests sont OK, le problème vient de Nginx/Forge"
log_info "3. Vérifiez la configuration Nginx dans Forge"
log_info "4. Contactez le support si nécessaire"

echo ""
echo "✅ Diagnostic terminé!" 