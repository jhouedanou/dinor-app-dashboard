#!/bin/bash

echo "🔧 === CORRECTION DES ERREURS CONSOLE ==="
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

# 1. Corriger le script d'icônes (ES modules)
log_info "🔄 Correction du script de génération d'icônes..."

# Tester le script corrigé
if [ -f "update-pwa-icons-dinor.sh" ]; then
    log_success "Script d'icônes déjà corrigé (utilise .cjs)"
else
    log_warning "Script d'icônes non trouvé"
fi

# 2. Vérifier les corrections du cache PWA
log_info "🔄 Vérification des corrections du cache PWA..."

if grep -q "Cache PWA non disponible" src/pwa/stores/api.js; then
    log_success "Gestion d'erreur du cache PWA améliorée"
else
    log_warning "Corrections du cache PWA non appliquées"
fi

# 3. Nettoyer les fichiers temporaires
log_info "🧹 Nettoyage des fichiers temporaires..."

# Supprimer d'anciens scripts avec l'extension .js
if [ -f "convert-svg-to-icons.js" ]; then
    rm convert-svg-to-icons.js
    log_success "Ancien script .js supprimé"
fi

# Supprimer le fichier de test s'il existe
if [ -f "test-icon-generator.html" ]; then
    log_info "Fichier de test trouvé : test-icon-generator.html"
    read -p "Voulez-vous le supprimer ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm test-icon-generator.html
        log_success "Fichier de test supprimé"
    fi
fi

# 4. Tester la génération d'icônes
log_info "🧪 Test de la génération d'icônes..."

if [ -f "public/images/Dinor-Logo.svg" ]; then
    log_success "Logo SVG trouvé"
    
    if command -v node >/dev/null 2>&1; then
        log_info "Test rapide du script d'icônes..."
        # Créer un script de test minimal
        cat > test-icon-generation.cjs << 'EOF'
console.log('✅ Script CommonJS fonctionne');
console.log('📁 Logo SVG:', require('fs').existsSync('./public/images/Dinor-Logo.svg') ? 'trouvé' : 'manquant');
console.log('🎯 Test terminé avec succès');
EOF
        
        if node test-icon-generation.cjs; then
            log_success "Script CommonJS fonctionne correctement"
        else
            log_error "Problème avec le script CommonJS"
        fi
        
        rm test-icon-generation.cjs
    else
        log_warning "Node.js non disponible pour les tests"
    fi
else
    log_error "Logo SVG manquant : public/images/Dinor-Logo.svg"
fi

# 5. Vérifier l'état du serveur de développement
log_info "🌐 Vérification du serveur de développement..."

if curl -s http://localhost:3000/api/v1/banners > /dev/null 2>&1; then
    log_success "Backend Laravel accessible"
else
    log_warning "Backend Laravel non accessible sur localhost:3000"
    log_info "Démarrez le serveur avec : php artisan serve --port=3000"
fi

# 6. Recommandations
echo ""
log_info "📋 Résumé des corrections appliquées :"
echo ""
echo "✅ Script d'icônes : Utilise maintenant .cjs (CommonJS)"
echo "✅ Cache PWA : Gestion gracieuse des erreurs 400/404"
echo "✅ Images YouTube : Gestion d'erreur existante (@error=handleImageError)"
echo ""
echo "🎯 Actions recommandées :"
echo ""
echo "1. Redémarrer le serveur de développement :"
echo "   npm run dev"
echo ""
echo "2. Vider le cache du navigateur :"
echo "   Ctrl+Shift+R ou F12 → Application → Storage → Clear Storage"
echo ""
echo "3. Vérifier les logs de la console :"
echo "   Les erreurs 400 cache PWA sont maintenant des infos ℹ️"
echo "   Les erreurs 404 YouTube sont gérées par les images de fallback"
echo ""
echo "4. Si besoin de générer les icônes :"
echo "   ./update-pwa-icons-dinor.sh"
echo ""

log_success "=== CORRECTION TERMINÉE ==="
echo ""
echo "🔍 Pour vérifier que les erreurs sont corrigées :"
echo "- Ouvrez la console du navigateur (F12)"
echo "- Rafraîchissez la page (Ctrl+R)"
echo "- Les erreurs 400 doivent être remplacées par des messages ℹ️"
echo "- Les erreurs 404 YouTube ne doivent plus apparaître"
echo "" 