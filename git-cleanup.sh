#!/bin/bash

# Script de nettoyage Git pour Dinor Dashboard
# Usage: ./git-cleanup.sh

echo "🧹 === NETTOYAGE GIT POUR DÉPLOIEMENT ==="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Sauvegarder les changements locaux s'il y en a
echo "1. Vérification des changements locaux..."
if ! git diff-index --quiet HEAD --; then
    log_warning "Changements locaux détectés"
    read -p "Voulez-vous les sauvegarder avant nettoyage ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash push -m "Sauvegarde manuelle avant nettoyage $(date)"
        log_info "Changements sauvegardés dans le stash"
    fi
else
    log_info "Aucun changement local"
fi

# 2. Nettoyer les fichiers de logs qui causent des conflits
echo "2. Nettoyage des fichiers de logs..."
rm -rf storage/logs/*.log 2>/dev/null && log_info "Fichiers de logs supprimés" || log_warning "Aucun fichier de log à supprimer"

# Retirer du suivi Git
git rm --cached storage/logs/*.log 2>/dev/null && log_info "Logs retirés du suivi Git" || true
git rm --cached storage/logs/laravel.log 2>/dev/null || true

# 3. Nettoyer les caches et fichiers temporaires
echo "3. Nettoyage des caches..."
rm -rf storage/framework/cache/data/* 2>/dev/null || true
rm -rf storage/framework/sessions/* 2>/dev/null || true
rm -rf storage/framework/views/*.php 2>/dev/null || true
rm -rf bootstrap/cache/*.php 2>/dev/null || true
rm -rf public/storage 2>/dev/null || true
log_info "Caches nettoyés"

# 4. Nettoyer node_modules et vendor
echo "4. Nettoyage des dépendances..."
rm -rf node_modules/ 2>/dev/null && log_info "node_modules supprimé" || true
rm -rf vendor/ 2>/dev/null && log_info "vendor supprimé" || true
rm -f package-lock.json yarn.lock composer.lock 2>/dev/null || true

# 5. Nettoyer les fichiers non suivis
echo "5. Nettoyage des fichiers non suivis..."
git clean -fd
log_info "Fichiers non suivis supprimés"

# 6. Réinitialiser à l'état propre
echo "6. Réinitialisation du repository..."
git reset --hard HEAD
log_info "Repository réinitialisé"

# 7. Mettre à jour le .gitignore pour éviter ces problèmes à l'avenir
echo "7. Vérification du .gitignore..."
if git status --porcelain | grep -q ".gitignore"; then
    log_warning ".gitignore modifié, commit des changements..."
    git add .gitignore
    git commit -m "Mise à jour .gitignore pour éviter les conflits de déploiement"
    log_info ".gitignore mis à jour"
fi

# 8. Récréer les dossiers nécessaires
echo "8. Recréation des dossiers de storage..."
mkdir -p storage/logs
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/app/public
chmod -R 755 storage
log_info "Dossiers de storage recréés"

# 9. Affichage du statut final
echo ""
echo "📊 === STATUT FINAL ==="
git status --short
echo ""

if [ -z "$(git status --porcelain)" ]; then
    log_info "Repository propre et prêt pour le déploiement!"
    echo ""
    echo "🚀 Vous pouvez maintenant lancer:"
    echo "   ./deploy-production.sh"
    echo ""
else
    log_warning "Il reste encore des fichiers modifiés:"
    git status --short
    echo ""
    echo "💡 Options:"
    echo "   - git add . && git commit -m 'Nettoyage manuel'"
    echo "   - git stash push -m 'Sauvegarde temporaire'"
    echo "   - git reset --hard HEAD (attention: perte des changements)"
fi

echo "🏁 Nettoyage terminé!" 