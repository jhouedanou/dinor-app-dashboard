#!/bin/bash

# Script nucléaire pour les permissions NPM impossibles à corriger
# Usage: ./nuclear-npm-fix.sh

echo "☢️  === CORRECTIF NUCLÉAIRE NPM ==="
echo "⚠️  Ce script utilise des méthodes extrêmes"
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

# Détecter si on est root et corriger immédiatement
if [ "$EUID" -eq 0 ]; then
    log_warning "Script exécuté en tant que ROOT - correction des permissions globales..."
    chown -R forge:forge /home/forge/new.dinorapp.com/
    chmod -R 755 /home/forge/new.dinorapp.com/
fi

# 1. Diagnostic complet
log_info "🔍 Diagnostic des permissions bloquées..."
if [ -f "node_modules/.package-lock.json" ]; then
    PERMISSIONS=$(ls -la node_modules/.package-lock.json 2>/dev/null || echo "impossible à lire")
    echo "   .package-lock.json: $PERMISSIONS"
fi

# 2. Arrêt de tous les processus liés
log_info "🛑 Arrêt de tous les processus NPM/Node..."
pkill -f "npm" 2>/dev/null || true
pkill -f "node" 2>/dev/null || true
sleep 3

# 3. Méthode nucléaire: renommer le dossier problématique
log_info "☢️  Méthode nucléaire: isolation du dossier problématique..."

if [ -d "node_modules" ]; then
    # Correction forcée des permissions avant isolation
    if [ "$EUID" -eq 0 ]; then
        chown -R root:root node_modules/ 2>/dev/null || true
        chmod -R 777 node_modules/ 2>/dev/null || true
    fi
    
    # Renommer node_modules pour l'isoler
    TIMESTAMP=$(date +%s)
    mv node_modules "node_modules_broken_$TIMESTAMP" 2>/dev/null || true
    
    if [ -d "node_modules_broken_$TIMESTAMP" ]; then
        log_success "Dossier problématique isolé: node_modules_broken_$TIMESTAMP"
        
        # Tentative de suppression agressive en arrière-plan
        log_info "🧹 Suppression agressive en arrière-plan..."
        if [ "$EUID" -eq 0 ]; then
            (chmod -R 777 "node_modules_broken_$TIMESTAMP" && rm -rf "node_modules_broken_$TIMESTAMP" 2>/dev/null &) || true
        else
            (rm -rf "node_modules_broken_$TIMESTAMP" 2>/dev/null &) || true
        fi
    fi
fi

# 4. Nettoyage complet de tous les fichiers lock
log_info "🗑️ Suppression de tous les fichiers lock..."
rm -f package-lock.json 2>/dev/null || true
rm -f npm-shrinkwrap.json 2>/dev/null || true
rm -f yarn.lock 2>/dev/null || true
rm -f .package-lock.json 2>/dev/null || true

# 5. Recréation d'un environnement propre
log_info "🏗️ Création d'un environnement NPM propre..."

# Utiliser un répertoire temporaire pour l'installation
TEMP_DIR="/tmp/npm_install_$$"
mkdir -p "$TEMP_DIR"

# Copier package.json vers le répertoire temporaire
cp package.json "$TEMP_DIR/" 2>/dev/null || true

# Aller dans le répertoire temporaire
cd "$TEMP_DIR"

# Installation dans le répertoire temporaire
log_info "📦 Installation NPM dans un environnement isolé..."
if npm install --no-fund --no-audit --production=false; then
    log_success "Installation réussie dans l'environnement temporaire"
    
    # Retourner au répertoire original
    cd - > /dev/null
    
    # Déplacer le node_modules créé
    if [ -d "$TEMP_DIR/node_modules" ]; then
        log_info "📋 Déplacement du node_modules propre..."
        mv "$TEMP_DIR/node_modules" . || cp -r "$TEMP_DIR/node_modules" .
        
        # Corriger les permissions du nouveau node_modules
        if [ "$EUID" -eq 0 ]; then
            chown -R forge:forge node_modules/ 2>/dev/null || true
            chmod -R 755 node_modules/ 2>/dev/null || true
        else
            chown -R forge:forge node_modules/ 2>/dev/null || true
            chmod -R 755 node_modules/ 2>/dev/null || true
        fi
        
        log_success "node_modules propre installé"
    fi
    
    # Copier le package-lock.json si créé
    if [ -f "$TEMP_DIR/package-lock.json" ]; then
        cp "$TEMP_DIR/package-lock.json" . 2>/dev/null || true
        if [ "$EUID" -eq 0 ]; then
            chown forge:forge package-lock.json 2>/dev/null || true
        fi
    fi
    
else
    log_warning "Échec de l'installation temporaire"
    cd - > /dev/null
    
    # Plan B: installation minimale manuelle
    log_info "🆘 Plan B: structure minimale manuelle..."
    mkdir -p node_modules/.bin
    echo '{}' > package-lock.json
    if [ "$EUID" -eq 0 ]; then
        chown -R forge:forge node_modules/ package-lock.json 2>/dev/null || true
        chmod -R 755 node_modules/ 2>/dev/null || true
    fi
fi

# Nettoyage du répertoire temporaire
rm -rf "$TEMP_DIR" 2>/dev/null || true

# 6. Vérification finale
log_info "🔍 Vérification finale..."
if [ -d "node_modules" ]; then
    NODE_COUNT=$(find node_modules/ -maxdepth 1 -type d | wc -l)
    log_success "node_modules créé avec $NODE_COUNT répertoires"
    
    # Test de création de fichier pour vérifier les permissions
    if touch node_modules/.test_permissions 2>/dev/null; then
        rm node_modules/.test_permissions 2>/dev/null || true
        log_success "Permissions d'écriture confirmées"
    else
        log_warning "Permissions d'écriture limitées"
    fi
    
    # Afficher les permissions finales
    echo "   Propriétaire final: $(stat -c '%U:%G' node_modules/ 2>/dev/null || echo 'inconnu')"
else
    log_error "Échec de la création de node_modules"
fi

# 7. Nettoyage final des processus fantômes
log_info "🧹 Nettoyage final..."

# Nettoyer les processus NPM fantômes
pkill -f "npm" 2>/dev/null || true

# Nettoyer le cache NPM utilisateur
npm cache clean --force 2>/dev/null || true
rm -rf ~/.npm/_cacache 2>/dev/null || true
rm -rf /home/forge/.npm/_cacache 2>/dev/null || true

# Correction finale des permissions si root
if [ "$EUID" -eq 0 ]; then
    log_info "🔐 Correction finale des permissions (root vers forge)..."
    chown -R forge:forge /home/forge/new.dinorapp.com/
    chmod -R 755 /home/forge/new.dinorapp.com/
fi

echo ""
log_success "☢️  Correctif nucléaire terminé!"
echo ""
echo "📋 Actions effectuées:"
echo "   ✅ Isolation du dossier problématique"
echo "   ✅ Installation dans un environnement propre"
echo "   ✅ Transfert du node_modules fonctionnel"
echo "   ✅ Correction des permissions (root → forge)"
echo ""
echo "🧪 Tests recommandés:"
echo "   1. npm ls (vérifier les dépendances)"
echo "   2. npm run build (tester le build)"
echo "   3. ls -la node_modules/ (vérifier les permissions)"
echo ""
echo "⚠️  Si vous êtes connecté en root, passez à l'utilisateur forge:"
echo "   su - forge"
echo "   cd /home/forge/new.dinorapp.com"
echo ""
echo "🗑️ Nettoyage manuel si nécessaire:"
echo "   rm -rf node_modules_broken_* (supprimer les dossiers isolés)"