#!/bin/bash

# Script de déploiement pour Dinor App
# Ce script configure l'application pour la production

echo "🚀 Démarrage du déploiement de Dinor App..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "artisan" ]; then
    error "Ce script doit être exécuté depuis la racine du projet Laravel"
    exit 1
fi

# 1. Vérification des dépendances
info "Vérification des dépendances..."
if ! command -v php &> /dev/null; then
    error "PHP n'est pas installé"
    exit 1
fi

if ! command -v composer &> /dev/null; then
    error "Composer n'est pas installé"
    exit 1
fi

# 2. Installation des dépendances
info "Installation des dépendances Composer..."
composer install --optimize-autoloader --no-dev

# 3. Configuration de l'environnement
info "Configuration de l'environnement..."
if [ ! -f ".env" ]; then
    warning "Fichier .env non trouvé, copie depuis .env.example"
    cp .env.example .env
    php artisan key:generate
fi

# 4. Exécution du setup de production
info "Exécution du setup de production personnalisé..."
php artisan dinor:setup-production --force

# 5. Optimisations finales
info "Optimisations finales..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Permissions
info "Configuration des permissions..."
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# 7. Vérification finale
info "Vérification finale..."
if php artisan --version &> /dev/null; then
    success "Application Laravel fonctionne correctement"
else
    error "Problème avec l'application Laravel"
    exit 1
fi

echo ""
success "🎉 Déploiement terminé avec succès!"
echo ""
echo "=== INFORMATIONS DE CONNEXION ==="
echo "Dashboard Admin: /admin"
echo "⚠️ Utilisez les credentials générés lors du seeding"
echo ""
echo "=== PAGES PUBLIQUES ==="
echo "Dashboard: /dashboard.html"
echo "Recettes: /recipe.html?id=1"
echo "Astuces: /tip.html?id=1"
echo ""
echo "=== DONNÉES CRÉÉES ==="
echo "- Recettes avec galeries d'images"
echo "- Astuces avec contenus riches"
echo "- Événements programmés"
echo "- Pages statiques"
echo "- Vidéos Dinor TV"
echo "- Utilisateurs de test"
echo "- Likes et commentaires"
echo ""
success "L'application est maintenant prête pour la production! 🚀"