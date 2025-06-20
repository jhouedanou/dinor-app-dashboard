#!/bin/bash

# Script pour nettoyer les conflits Git avant déploiement
# Usage: ./fix-git-conflicts.sh

set -e

echo "🧹 Nettoyage des conflits Git..."

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Supprimer les fichiers de logs qui causent des conflits
log_info "Suppression des fichiers de logs..."
rm -rf storage/logs/*.log 2>/dev/null || true
touch storage/logs/.gitkeep 2>/dev/null || true

# 2. Nettoyer les fichiers temporaires
log_info "Nettoyage des fichiers temporaires..."
rm -rf storage/framework/cache/data/* 2>/dev/null || true
rm -rf storage/framework/sessions/* 2>/dev/null || true
rm -rf storage/framework/views/*.php 2>/dev/null || true
rm -rf bootstrap/cache/*.php 2>/dev/null || true

# 3. Nettoyer les fichiers Git en cache
log_info "Nettoyage du cache Git..."
git rm --cached storage/logs/*.log 2>/dev/null || true
git rm --cached storage/logs/laravel.log 2>/dev/null || true

# 4. Ajouter tous les changements au staging
log_info "Ajout des changements..."
git add . 2>/dev/null || true

# 5. Commit des changements de nettoyage
if ! git diff-index --quiet HEAD --; then
    log_info "Commit des changements de nettoyage..."
    git commit -m "Nettoyage des conflits Git avant déploiement - $(date)" 2>/dev/null || true
fi

# 6. Faire un stash de sécurité
log_info "Sauvegarde temporaire des changements..."
git stash push -m "Sauvegarde de sécurité avant déploiement - $(date)" 2>/dev/null || true

# 7. Mettre à jour depuis origin
log_info "Mise à jour depuis origin/main..."
git fetch origin main
git reset --hard origin/main

log_success "Conflits Git nettoyés avec succès!"
echo ""
echo "Vous pouvez maintenant exécuter:"
echo "  ./deploy-production.sh"
echo "" 