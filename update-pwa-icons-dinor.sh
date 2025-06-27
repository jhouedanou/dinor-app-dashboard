#!/bin/bash

echo "🚀 === MISE À JOUR DES ICÔNES PWA DINOR ==="
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

# Vérifier que le logo SVG existe
LOGO_PATH="public/images/Dinor-Logo.svg"
if [ ! -f "$LOGO_PATH" ]; then
    log_error "Logo Dinor SVG introuvable : $LOGO_PATH"
    exit 1
fi

log_success "Logo Dinor SVG trouvé : $LOGO_PATH"

# Créer le répertoire de sauvegarde pour les anciennes icônes
BACKUP_DIR="public/pwa/icons/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

log_info "📁 Sauvegarde des anciennes icônes dans : $BACKUP_DIR"

# Sauvegarder les anciennes icônes
cp public/pwa/icons/icon-*.png "$BACKUP_DIR/" 2>/dev/null || log_warning "Aucune ancienne icône à sauvegarder"

# Vérifier que Node.js est installé pour utiliser un convertisseur SVG
if command -v node >/dev/null 2>&1; then
    log_success "Node.js détecté, installation du convertisseur SVG..."
    
    # Installer sharp si nécessaire (pour la conversion SVG vers PNG)
    if ! npm list sharp >/dev/null 2>&1; then
        log_info "📦 Installation de sharp pour la conversion SVG..."
        npm install sharp --save-dev
    fi
    
    # Créer un script Node.js pour la conversion (compatible ESM)
    cat > convert-svg-to-icons.mjs << 'EOF'
import sharp from 'sharp';
import fs from 'fs';

const sizes = [32, 72, 96, 128, 144, 152, 192, 384, 512];
const inputSvg = 'public/images/Dinor-Logo.svg';

async function generateIcons() {
    console.log('🔄 Génération des icônes PNG à partir du SVG...');
    
    for (const size of sizes) {
        try {
            const outputPath = `public/pwa/icons/icon-${size}x${size}.png`;
            
            await sharp(inputSvg)
                .resize(size, size, {
                    fit: 'contain',
                    background: '#ffffff'
                })
                .flatten({ background: '#ffffff' })
                .png()
                .toFile(outputPath);
            
            console.log(`✅ Icône générée: ${outputPath}`);
        } catch (error) {
            console.error(`❌ Erreur pour la taille ${size}:`, error.message);
        }
    }
    
    console.log('🎉 Génération terminée!');
}

generateIcons().catch(console.error);
EOF

    # Exécuter la conversion
    log_info "🔄 Conversion du SVG en icônes PNG..."
    node convert-svg-to-icons.mjs
    
    # Nettoyer le script temporaire
    rm convert-svg-to-icons.mjs
    
    log_success "Icônes PNG générées avec succès"
    
else
    log_warning "Node.js non détecté. Utilisez le générateur HTML : public/pwa/icons/generate-dinor-icons.html"
    log_info "📖 Instructions manuelles :"
    log_info "1. Ouvrez public/pwa/icons/generate-dinor-icons.html dans votre navigateur"
    log_info "2. Cliquez sur 'Générer les icônes Dinor'"
    log_info "3. Cliquez sur 'Télécharger toutes les icônes'"
    log_info "4. Placez les fichiers téléchargés dans public/pwa/icons/"
    
    # Ouvrir le générateur HTML automatiquement si possible
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "public/pwa/icons/generate-dinor-icons.html"
    elif command -v open >/dev/null 2>&1; then
        open "public/pwa/icons/generate-dinor-icons.html"
    fi
    
    echo ""
    read -p "Appuyez sur Entrée une fois que vous avez placé les nouvelles icônes dans public/pwa/icons/"
fi

# Vérifier que les nouvelles icônes ont été créées
ICON_COUNT=$(ls public/pwa/icons/icon-*.png 2>/dev/null | wc -l)

if [ "$ICON_COUNT" -lt 8 ]; then
    log_error "Pas assez d'icônes générées ($ICON_COUNT/8+). Vérifiez le processus."
    exit 1
fi

log_success "$ICON_COUNT icônes PWA trouvées"

# Mettre à jour le manifest.json si nécessaire
MANIFEST_PATH="public/manifest.json"
if [ -f "$MANIFEST_PATH" ]; then
    log_info "📝 Vérification du manifest.json..."
    
    # Créer une sauvegarde du manifest
    cp "$MANIFEST_PATH" "$MANIFEST_PATH.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Le manifest existe déjà avec la bonne structure, pas besoin de le modifier
    log_success "Manifest.json déjà configuré pour les icônes PWA"
else
    log_warning "Manifest.json introuvable à $MANIFEST_PATH"
fi

# Mettre à jour les icônes dans l'index.html de la PWA si nécessaire
PWA_INDEX="src/pwa/index.html"
if [ -f "$PWA_INDEX" ]; then
    log_info "📝 Vérification des liens d'icônes dans $PWA_INDEX..."
    
    # Vérifier si les liens d'icônes existent
    if grep -q "apple-touch-icon" "$PWA_INDEX"; then
        log_success "Liens d'icônes déjà présents dans $PWA_INDEX"
    else
        log_info "Ajout des liens d'icônes dans $PWA_INDEX..."
        # Insérer les liens d'icônes dans le head
        sed -i '/<head>/a\
  <link rel="icon" type="image/png" sizes="32x32" href="/pwa/icons/icon-32x32.png">\
  <link rel="icon" type="image/png" sizes="192x192" href="/pwa/icons/icon-192x192.png">\
  <link rel="apple-touch-icon" sizes="180x180" href="/pwa/icons/icon-192x192.png">\
  <meta name="msapplication-TileImage" content="/pwa/icons/icon-144x144.png">' "$PWA_INDEX"
        
        log_success "Liens d'icônes ajoutés dans $PWA_INDEX"
    fi
fi

# Afficher un résumé
echo ""
log_success "=== MISE À JOUR TERMINÉE ==="
echo ""
echo "📋 Résumé :"
echo "• Icônes générées : $ICON_COUNT"
echo "• Sauvegarde : $BACKUP_DIR"
echo "• Manifest : $MANIFEST_PATH"
echo ""
echo "🌐 Test de la PWA :"
echo "1. Démarrez votre serveur de développement"
echo "2. Allez sur votre PWA dans le navigateur"
echo "3. Vérifiez que la nouvelle icône apparaît dans :"
echo "   - L'onglet du navigateur"
echo "   - Le menu d'installation de la PWA"
echo "   - L'écran d'accueil (mobile)"
echo ""
echo "🔧 Si les icônes ne s'affichent pas :"
echo "- Videz le cache du navigateur (Ctrl+Shift+R)"
echo "- Vérifiez la console pour les erreurs 404"
echo "- Testez sur un autre appareil/navigateur"
echo "" 