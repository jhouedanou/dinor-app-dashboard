#!/bin/bash

# Script de déploiement d'urgence SANS NPM
# Usage: ./deploy-without-npm.sh

echo "🚨 === DÉPLOIEMENT D'URGENCE SANS NPM ==="
echo "⚠️  Ce script évite complètement l'installation NPM"
echo ""

cd /home/forge/new.dinorapp.com

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

# 1. Mise en mode maintenance
log_info "🔄 Mise en mode maintenance..."
$FORGE_PHP artisan down --retry=60 --render="errors::503" --secret="dinor-maintenance-secret" || log_warning "Impossible de mettre en mode maintenance"

# 2. Mise à jour du code source uniquement
log_info "📥 Mise à jour du code source..."
git fetch origin $FORGE_SITE_BRANCH
git reset --hard origin/$FORGE_SITE_BRANCH
log_success "Code source mis à jour"

# 3. Installation Composer uniquement
log_info "📦 Installation des dépendances Composer..."
rm -rf vendor/ 2>/dev/null || true
$FORGE_COMPOSER install --no-dev --no-interaction --prefer-dist --optimize-autoloader
log_success "Dépendances Composer installées"

# 4. Configuration des variables d'environnement
log_info "⚙️ Configuration des variables..."
if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    $FORGE_PHP artisan key:generate --force
fi

# 5. Migration de la base de données
log_info "🗄️ Migration de la base de données..."
$FORGE_PHP artisan migrate --force
log_success "Migrations exécutées"

# 6. BYPASS NPM - Utiliser les assets existants ou créer un placeholder
log_info "🔄 Gestion des assets sans NPM..."

# Vérifier si public/build existe déjà
if [ ! -d "public/build" ]; then
    log_warning "Création d'un dossier public/build placeholder..."
    mkdir -p public/build
    echo "/* Placeholder CSS */" > public/build/app.css
    echo "/* Placeholder JS */" > public/build/app.js
fi

# Pour la PWA, créer une version minimale si elle n'existe pas
if [ ! -d "public/pwa/dist" ]; then
    log_warning "Création d'une PWA minimale..."
    mkdir -p public/pwa/dist
    cat > public/pwa/dist/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Dinor App</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <div id="app">
        <h1>Dinor App</h1>
        <p>Application en cours de maintenance...</p>
    </div>
</body>
</html>
EOF
    echo "$(date +%s)" > public/pwa/version.txt
fi

log_success "Assets gérés sans NPM"

# 7. Configuration des permissions
log_info "🔧 Configuration des permissions..."
mkdir -p storage/logs storage/framework/cache/data storage/framework/sessions storage/framework/views storage/app/public bootstrap/cache
chmod -R 775 storage bootstrap/cache 2>/dev/null || true
chown -R forge:www-data storage bootstrap/cache 2>/dev/null || true
log_success "Permissions configurées"

# 8. Seeders essentiels
log_info "📋 Exécution des seeders essentiels..."
$FORGE_PHP artisan db:seed --class=AdminUserSeeder --force 2>/dev/null || log_warning "AdminUserSeeder échoué"
$FORGE_PHP artisan db:seed --class=CategorySeeder --force 2>/dev/null || log_warning "CategorySeeder échoué"
$FORGE_PHP artisan db:seed --class=PwaMenuItemSeeder --force 2>/dev/null || log_warning "PwaMenuItemSeeder échoué"

# 9. Lien symbolique de stockage
log_info "🔗 Création du lien symbolique de stockage..."
$FORGE_PHP artisan storage:link || log_warning "Lien symbolique déjà existant"

# 10. Optimisation Laravel
log_info "⚡ Optimisation Laravel..."
$FORGE_PHP artisan config:cache
$FORGE_PHP artisan route:cache
$FORGE_PHP artisan view:cache
log_success "Optimisations appliquées"

# 11. Vérifications finales
log_info "🔍 Vérifications finales..."
if $FORGE_PHP artisan migrate:status >/dev/null 2>&1; then
    log_success "Base de données OK"
fi

# 12. Sortie du mode maintenance
log_info "🟢 Sortie du mode maintenance..."
$FORGE_PHP artisan up
log_success "Application remise en ligne"

echo ""
log_success "🎉 Déploiement d'urgence terminé!"
echo ""
echo "⚠️  IMPORTANT: Ce déploiement fonctionne SANS assets NPM"
echo ""
echo "📋 Prochaines étapes recommandées:"
echo "   1. Résoudre les problèmes NPM avec ./nuclear-npm-fix.sh"
echo "   2. Rebuilder les assets: npm run build && npm run pwa:build"
echo "   3. Redéployer normalement"
echo ""
echo "🌐 L'application est accessible à: https://new.dinorapp.com"
echo "🔑 Admin: admin@dinor.app / Dinor2024!Admin"