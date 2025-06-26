#!/bin/bash

# Script spécialisé pour corriger les permissions NPM sur Forge
# Usage: ./fix-npm-permissions.sh

echo "🔧 === CORRECTIF PERMISSIONS NPM FORGE ==="
echo ""

# Fonction pour les logs
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1"
}

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "package.json" ]; then
    log_error "Fichier package.json non trouvé. Exécutez ce script dans le répertoire du projet."
    exit 1
fi

log_info "Répertoire de travail: $(pwd)"

# 1. Diagnostic initial
log_info "🔍 Diagnostic des permissions actuelles..."
if [ -d "node_modules" ]; then
    echo "📁 node_modules existe"
    NODE_MODULES_OWNER=$(stat -c '%U:%G' node_modules/ 2>/dev/null || echo "inconnu")
    echo "   Propriétaire: $NODE_MODULES_OWNER"
    
    # Vérifier les fichiers cachés problématiques
    if [ -f "node_modules/.package-lock.json" ]; then
        HIDDEN_OWNER=$(stat -c '%U:%G' node_modules/.package-lock.json 2>/dev/null || echo "inconnu")
        echo "   .package-lock.json propriétaire: $HIDDEN_OWNER"
        log_warning "Fichier .package-lock.json détecté (source du problème)"
    fi
else
    echo "📁 node_modules n'existe pas"
fi

# 2. Arrêt des processus NPM en cours
log_info "🛑 Arrêt des processus NPM en cours..."
pkill -f "npm" 2>/dev/null || true
sleep 2

# 3. Correction agressive des permissions
log_info "🔐 Correction agressive des permissions..."

# Corriger le propriétaire de tous les fichiers
chown -R forge:forge . 2>/dev/null || true

# Correction spécifique pour node_modules
if [ -d "node_modules" ]; then
    log_info "🔧 Correction spécifique node_modules..."
    
    # Permissions sur tous les fichiers et dossiers
    find node_modules/ -type f -exec chown forge:forge {} \; 2>/dev/null || true
    find node_modules/ -type d -exec chown forge:forge {} \; 2>/dev/null || true
    
    # Permissions spéciales pour les fichiers cachés
    find node_modules/ -name ".*" -type f -exec chown forge:forge {} \; 2>/dev/null || true
    find node_modules/ -name ".*" -type f -exec chmod 644 {} \; 2>/dev/null || true
    find node_modules/ -name ".*" -type d -exec chown forge:forge {} \; 2>/dev/null || true
    find node_modules/ -name ".*" -type d -exec chmod 755 {} \; 2>/dev/null || true
    
    # Chmod récursif
    chmod -R 755 node_modules/ 2>/dev/null || true
fi

# Correction des fichiers lock
chown forge:forge package-lock.json 2>/dev/null || true
chown forge:forge .package-lock.json 2>/dev/null || true

log_success "Permissions corrigées"

# 4. Nettoyage complet
log_info "🧹 Nettoyage complet..."

# Supprimer les fichiers problématiques spécifiques
rm -f node_modules/.package-lock.json 2>/dev/null || true
rm -f .package-lock.json 2>/dev/null || true

# Suppression complète de node_modules avec plusieurs méthodes
if [ -d "node_modules" ]; then
    log_info "🗑️ Suppression de node_modules..."
    
    # Méthode 1: rm standard
    rm -rf node_modules/ 2>/dev/null || true
    
    # Méthode 2: find et delete si le dossier existe encore
    if [ -d "node_modules" ]; then
        find node_modules/ -delete 2>/dev/null || true
    fi
    
    # Méthode 3: suppression manuelle du contenu puis du dossier
    if [ -d "node_modules" ]; then
        rm -rf node_modules/* 2>/dev/null || true
        rmdir node_modules/ 2>/dev/null || true
    fi
fi

# Supprimer les lock files
rm -f package-lock.json npm-shrinkwrap.json yarn.lock 2>/dev/null || true

log_success "Nettoyage terminé"

# 5. Nettoyage du cache NPM
log_info "🗄️ Nettoyage du cache NPM..."
npm cache clean --force 2>/dev/null || true
rm -rf ~/.npm/_cacache 2>/dev/null || true
rm -rf /home/forge/.npm/_cacache 2>/dev/null || true
log_success "Cache NPM nettoyé"

# 6. Test d'installation NPM
log_info "🚀 Test d'installation NPM..."

# Tentative 1: installation standard
if npm install --no-fund --no-audit; then
    log_success "✅ Installation NPM réussie (méthode standard)"
    
# Tentative 2: npm ci
elif npm ci --no-fund --no-audit 2>/dev/null; then
    log_success "✅ Installation NPM réussie (npm ci)"
    
# Tentative 3: avec --force
elif npm install --force --no-fund --no-audit; then
    log_warning "⚠️ Installation NPM réussie (avec --force)"
    
# Tentative 4: avec cache temporaire
elif npm install --no-fund --no-audit --cache=/tmp/npm-cache-temp; then
    log_success "✅ Installation NPM réussie (cache temporaire)"
    rm -rf /tmp/npm-cache-temp 2>/dev/null || true
    
else
    log_error "❌ Échec de toutes les tentatives d'installation NPM"
    echo ""
    echo "🔍 Diagnostic:"
    echo "   - Vérifiez que package.json est valide"
    echo "   - Vérifiez la connectivité réseau"
    echo "   - Essayez manuellement: npm install --verbose"
    exit 1
fi

# 7. Vérification finale
log_info "🔍 Vérification finale..."
if [ -d "node_modules" ]; then
    NODE_COUNT=$(find node_modules/ -type d -name "*" | wc -l)
    log_success "node_modules créé avec $NODE_COUNT dossiers"
    
    # Vérifier les permissions finales
    FINAL_OWNER=$(stat -c '%U:%G' node_modules/ 2>/dev/null || echo "inconnu")
    echo "   Propriétaire final: $FINAL_OWNER"
    
    # Corriger les permissions finales si nécessaire
    chown -R forge:forge node_modules/ 2>/dev/null || true
    chmod -R 755 node_modules/ 2>/dev/null || true
else
    log_error "node_modules non créé"
    exit 1
fi

echo ""
log_success "🎉 Correctif des permissions NPM terminé avec succès!"
echo ""
echo "📋 Prochaines étapes recommandées:"
echo "   1. Tester le build: npm run build"
echo "   2. Tester la PWA: npm run pwa:build"
echo "   3. Vérifier les permissions: ls -la node_modules/"
echo ""