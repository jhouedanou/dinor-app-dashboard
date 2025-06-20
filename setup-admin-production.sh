#!/bin/bash

echo "🚀 === CONFIGURATION ADMIN PRODUCTION DINOR ==="
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Vérification des prérequis
log_info "Vérification de l'environnement..."

if [ ! -f "artisan" ]; then
    log_error "Ce script doit être exécuté depuis la racine du projet Laravel"
    exit 1
fi

if [ ! -f ".env" ]; then
    log_error "Fichier .env non trouvé"
    exit 1
fi

log_success "Environnement validé"

# Configuration des variables d'environnement
log_info "Configuration des variables d'environnement..."

# Fonction pour mettre à jour les variables d'environnement
update_env_var() {
    local key=$1
    local value=$2
    
    if grep -q "^${key}=" .env; then
        sed -i "s/^${key}=.*/${key}=${value}/" .env
        log_info "Variable ${key} mise à jour"
    else
        echo "${key}=${value}" >> .env
        log_info "Variable ${key} ajoutée"
    fi
}

# Variables essentielles pour l'admin
update_env_var "ADMIN_DEFAULT_EMAIL" "admin@dinor.app"
update_env_var "ADMIN_DEFAULT_PASSWORD" "Dinor2024!Admin"
update_env_var "ADMIN_DEFAULT_NAME" "Administrateur Dinor"

log_success "Variables d'environnement configurées"

# Nettoyage du cache
log_info "Nettoyage du cache Laravel..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
log_success "Cache nettoyé"

# Exécution du seeder spécialisé
log_info "Exécution du seeder admin production..."
php artisan db:seed --class=ProductionAdminSeeder --force

if [ $? -eq 0 ]; then
    log_success "Seeder admin exécuté avec succès"
else
    log_error "Erreur lors de l'exécution du seeder"
    
    log_warning "Tentative avec le seeder standard..."
    php artisan db:seed --class=AdminUserSeeder --force
    
    if [ $? -eq 0 ]; then
        log_success "Seeder standard exécuté avec succès"
    else
        log_error "Échec de tous les seeders admin"
        exit 1
    fi
fi

# Vérification finale
log_info "Vérification de l'admin créé..."

ADMIN_CHECK=$(php artisan tinker --execute="
\$admin = App\Models\AdminUser::where('email', 'admin@dinor.app')->first();
if (\$admin) {
    echo 'ADMIN_EXISTS:' . \$admin->id . ':' . \$admin->name . ':' . (\$admin->is_active ? 'ACTIVE' : 'INACTIVE');
} else {
    echo 'ADMIN_NOT_FOUND';
}
" 2>/dev/null | grep "ADMIN_")

if [[ $ADMIN_CHECK == *"ADMIN_EXISTS"* ]]; then
    IFS=':' read -ra ADMIN_INFO <<< "$ADMIN_CHECK"
    ADMIN_ID="${ADMIN_INFO[1]}"
    ADMIN_NAME="${ADMIN_INFO[2]}"
    ADMIN_STATUS="${ADMIN_INFO[3]}"
    
    log_success "Admin trouvé - ID: $ADMIN_ID - Nom: $ADMIN_NAME - Status: $ADMIN_STATUS"
    
    if [[ $ADMIN_STATUS == "ACTIVE" ]]; then
        log_success "Admin actif et prêt à l'utilisation"
    else
        log_warning "Admin trouvé mais inactif"
    fi
else
    log_error "Admin non trouvé après la création"
    exit 1
fi

# Reconfiguration du cache pour la production
log_info "Optimisation pour la production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
log_success "Optimisations appliquées"

echo ""
echo "🎉 === CONFIGURATION TERMINÉE ==="
echo ""
echo "📋 Informations de connexion:"
echo "🌐 URL: $(grep APP_URL .env | cut -d '=' -f2)/admin/login"
echo "📧 Email: admin@dinor.app"
echo "🔑 Mot de passe: Dinor2024!Admin"
echo ""
echo "💡 Note: Ces identifiants sont identiques à ceux utilisés localement"
echo ""
log_success "Votre admin est prêt pour la production!" 