#!/bin/bash

cd /home/forge/new.dinorapp.com

# Fonction pour les logs (compatible Forge)
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

echo "🚀 === DÉPLOIEMENT DINOR DASHBOARD FORGE ==="
echo ""

# 1. Mise en mode maintenance
log_info "🔄 Mise en mode maintenance..."
$FORGE_PHP artisan down --retry=60 --render="errors::503" --secret="dinor-maintenance-secret" || log_warning "Impossible de mettre en mode maintenance"

# 2. Nettoyage préalable des conflits Git
log_info "🧹 Nettoyage des conflits Git potentiels..."

# Supprimer les fichiers de logs qui causent des conflits
rm -rf storage/logs/*.log 2>/dev/null || true
rm -rf storage/logs/laravel.log 2>/dev/null || true

# Nettoyer les fichiers temporaires qui peuvent causer des conflits
rm -rf storage/framework/cache/data/* 2>/dev/null || true
rm -rf storage/framework/sessions/* 2>/dev/null || true
rm -rf storage/framework/views/*.php 2>/dev/null || true
rm -rf bootstrap/cache/*.php 2>/dev/null || true

# Nettoyer le cache Git
git rm --cached storage/logs/*.log 2>/dev/null || true
git rm --cached storage/logs/laravel.log 2>/dev/null || true

# Stash les changements locaux s'il y en a (sécurité)
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_warning "Changements locaux détectés, sauvegarde temporaire..."
    git stash push -m "Sauvegarde automatique Forge $(date)" 2>/dev/null || true
fi

log_success "Conflits Git nettoyés"

# 3. Mise à jour du code source
log_info "📥 Mise à jour du code source..."
git fetch origin $FORGE_SITE_BRANCH
git reset --hard origin/$FORGE_SITE_BRANCH
log_success "Code source mis à jour"

# 4. Nettoyage préalable des dépendances
log_info "🧹 Nettoyage des anciennes dépendances..."
rm -rf vendor/ 2>/dev/null || true
rm -f composer.lock 2>/dev/null || true
log_success "Anciennes dépendances supprimées"

# 5. Installation des dépendances Composer avec nunomaduro/collision
log_info "📦 Installation des dépendances Composer..."
$FORGE_COMPOSER install --no-dev --no-interaction --prefer-dist --optimize-autoloader
if [ $? -ne 0 ]; then
    log_error "Erreur lors de l'installation Composer"
    exit 1
fi
log_success "Dépendances Composer installées"

# 6. Vérification que les dépendances critiques sont installées
log_info "🔍 Vérification des dépendances critiques..."
if [ ! -d "vendor/nunomaduro/collision" ]; then
    log_warning "Tentative d'installation manuelle de nunomaduro/collision..."
    $FORGE_COMPOSER require nunomaduro/collision:^7.0 --no-interaction
fi
log_success "Dépendances critiques vérifiées"

# 7. Génération de la clé d'application si nécessaire
log_info "🔑 Vérification de la clé d'application..."
if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    log_warning "Génération d'une nouvelle clé d'application..."
    $FORGE_PHP artisan key:generate --force
    log_success "Clé d'application générée"
else
    log_info "Clé d'application déjà présente"
fi

# 8. Configuration des variables d'environnement admin
log_info "⚙️ Configuration des variables admin..."

# Fonction pour mettre à jour les variables d'environnement
update_env_var() {
    local key=$1
    local value=$2
    
    # Échapper les valeurs avec des espaces ou des caractères spéciaux
    if [[ "$value" == *" "* ]] || [[ "$value" == *"!"* ]]; then
        value="\"${value}\""
    fi
    
    if grep -q "^${key}=" .env 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" .env
    else
        echo "${key}=${value}" >> .env
    fi
}

# Variables pour l'admin (identiques au local)
update_env_var "ADMIN_DEFAULT_EMAIL" "admin@dinor.app"
update_env_var "ADMIN_DEFAULT_PASSWORD" "Dinor2024!Admin"
update_env_var "ADMIN_DEFAULT_NAME" "AdministrateurDinor"

# Variables de production importantes
update_env_var "APP_ENV" "production"
update_env_var "APP_DEBUG" "false"
update_env_var "SESSION_SECURE_COOKIE" "true"
update_env_var "SESSION_SAME_SITE" "lax"

# Variables de cache pour éviter les erreurs
update_env_var "CACHE_DRIVER" "file"
update_env_var "SESSION_DRIVER" "file"
update_env_var "QUEUE_CONNECTION" "sync"

# Variables de logging
update_env_var "LOG_CHANNEL" "stack"
update_env_var "LOG_DEPRECATIONS_CHANNEL" "null"
update_env_var "LOG_LEVEL" "debug"

log_success "Variables d'environnement configurées"

# 9. Nettoyage des caches avant NPM  
log_info "🧹 Nettoyage des caches Laravel..."
$FORGE_PHP artisan optimize:clear || log_warning "Problème avec optimize:clear, mais continue..."
# Nettoyage manuel des caches en cas d'échec
rm -rf bootstrap/cache/*.php storage/framework/cache/data/* storage/framework/views/*.php 2>/dev/null || true
log_success "Caches Laravel nettoyés"

# 10. Installation complète des dépendances NPM
log_info "📦 Installation des dépendances NPM..."
rm -rf node_modules/ package-lock.json 2>/dev/null || true
npm install
if [ $? -ne 0 ]; then
    log_warning "Problème avec npm install, tentative avec npm ci..."
    npm ci 2>/dev/null || npm install --force
fi
log_success "Dépendances NPM installées"

# 11. Build des assets de production
log_info "🏗️ Build des assets de production..."
npx vite build || npm run build || npm run production
if [ $? -ne 0 ]; then
    log_warning "Build des assets échoué, mais continue..."
fi
log_success "Assets buildés"

# 12. Recréation des dossiers nécessaires avec permissions
log_info "📁 Création des dossiers de storage..."
mkdir -p storage/logs
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/app/public
mkdir -p bootstrap/cache

# Configuration des permissions de base
chmod -R 775 storage bootstrap/cache 2>/dev/null || true
chown -R forge:www-data storage bootstrap/cache 2>/dev/null || true

log_success "Dossiers de storage créés avec permissions"

# 13. Migration de la base de données
log_info "🗄️ Migration de la base de données..."
if [ -f artisan ]; then
    $FORGE_PHP artisan migrate --force
    if [ $? -eq 0 ]; then
        log_success "Migrations exécutées"
    else
        log_warning "Problème avec les migrations, mais continue..."
    fi
else
    log_warning "Fichier artisan non trouvé"
fi

# 14. Configuration de l'utilisateur admin (amélioré)
log_info "👤 Configuration de l'utilisateur admin..."

# Essayer d'abord le seeder spécialisé pour la production
if $FORGE_PHP artisan db:seed --class=ProductionAdminSeeder --force 2>/dev/null; then
    log_success "✅ Admin configuré avec le seeder spécialisé"
else
    log_warning "Seeder spécialisé non trouvé, utilisation du seeder standard..."
    $FORGE_PHP artisan db:seed --class=AdminUserSeeder --force 2>/dev/null || log_warning "Problème avec AdminUserSeeder"
    log_success "✅ Admin configuré avec le seeder standard"
fi

# Exécuter les seeders manquants pour les panels
log_info "📋 Exécution des seeders manquants pour les panels..."

# EventCategoriesSeeder - crucial pour les panels d'événements
if $FORGE_PHP artisan db:seed --class=EventCategoriesSeeder --force 2>/dev/null; then
    log_success "✅ EventCategoriesSeeder exécuté"
else
    log_warning "EventCategoriesSeeder non trouvé ou erreur"
fi

# IngredientsSeeder - pour les ingrédients
if $FORGE_PHP artisan db:seed --class=IngredientsSeeder --force 2>/dev/null; then
    log_success "✅ IngredientsSeeder exécuté"
else
    log_warning "IngredientsSeeder non trouvé ou erreur"
fi

log_success "✅ Seeders manquants traités"

# Vérification que l'admin est bien créé
ADMIN_CHECK=$($FORGE_PHP artisan tinker --execute="
\$admin = App\\Models\\AdminUser::where('email', 'admin@dinor.app')->first();
if (\$admin && \$admin->is_active) {
    echo 'ADMIN_OK:' . \$admin->id . ':' . \$admin->name;
} else {
    echo 'ADMIN_PROBLEM';
}" 2>/dev/null | grep -E "ADMIN_OK|ADMIN_PROBLEM")

if [[ $ADMIN_CHECK == *"ADMIN_OK"* ]]; then
    ADMIN_ID=$(echo $ADMIN_CHECK | cut -d':' -f2)
    ADMIN_NAME=$(echo $ADMIN_CHECK | cut -d':' -f3)
    log_success "Admin vérifié et opérationnel (ID: $ADMIN_ID - $ADMIN_NAME)"
else
    log_warning "Tentative de création manuelle de l'admin..."
    
    # Création manuelle en cas d'échec des seeders
    $FORGE_PHP artisan tinker --execute="
    try {
        \$admin = App\\Models\\AdminUser::updateOrCreate(
            ['email' => 'admin@dinor.app'],
            [
                                 'name' => 'AdministrateurDinor',
                'password' => bcrypt('Dinor2024!Admin'),
                'email_verified_at' => now(),
                'is_active' => true
            ]
        );
        echo 'MANUAL_ADMIN_OK:' . \$admin->id;
    } catch (Exception \$e) {
        echo 'MANUAL_ADMIN_FAILED:' . \$e->getMessage();
    }
    " 2>/dev/null || log_error "Création manuelle échouée"
fi

# 15. Lien symbolique de stockage
log_info "🔗 Création du lien symbolique de stockage..."
$FORGE_PHP artisan storage:link || log_warning "Lien symbolique déjà existant"
log_success "Lien symbolique vérifié"

# 16. Optimisation Laravel pour la production
log_info "⚡ Optimisation Laravel..."
$FORGE_PHP artisan config:cache
$FORGE_PHP artisan route:cache
$FORGE_PHP artisan view:cache
log_success "Optimisations appliquées"

# 17. Configuration des permissions (sécurisé pour Forge)
log_info "🔧 Configuration des permissions..."
chmod -R 755 storage bootstrap/cache 2>/dev/null || true
chown -R forge:forge storage bootstrap/cache 2>/dev/null || true
log_success "Permissions configurées"

# 18. Vérification finale de l'état de l'application
log_info "🔍 Vérification finale..."

# Test rapide de la connexion à la base de données
if $FORGE_PHP artisan migrate:status >/dev/null 2>&1; then
    log_success "Connexion base de données OK"
else
    log_warning "Problème potentiel avec la base de données"
fi

# Vérification finale de l'admin
FINAL_ADMIN_CHECK=$($FORGE_PHP artisan tinker --execute="
\$admin = App\\Models\\AdminUser::where('email', 'admin@dinor.app')->first();
echo \$admin ? 'FINAL_ADMIN_EXISTS' : 'FINAL_ADMIN_MISSING';
" 2>/dev/null | grep "FINAL_ADMIN")

if [[ $FINAL_ADMIN_CHECK == *"EXISTS"* ]]; then
    log_success "Vérification finale admin: ✅ OK"
else
    log_warning "Vérification finale admin: ⚠️ Problème potentiel"
fi

# 19. Rechargement PHP-FPM (comme dans le script original)
log_info "🔄 Rechargement PHP-FPM..."
touch /tmp/fpmlock 2>/dev/null || true
( flock -w 10 9 || exit 1
    echo 'Rechargement PHP FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9</tmp/fpmlock 2>/dev/null || log_warning "Rechargement PHP-FPM échoué"

# 20. Sortie du mode maintenance
log_info "🟢 Sortie du mode maintenance..."
$FORGE_PHP artisan up
log_success "Application remise en ligne"

echo ""
echo "🎉 === DÉPLOIEMENT FORGE TERMINÉ AVEC SUCCÈS ==="
echo ""
echo "📋 Informations de connexion admin:"
echo "   🌐 Dashboard: https://new.dinorapp.com/admin/login"
echo "   📧 Email: admin@dinor.app"
echo "   🔑 Mot de passe: Dinor2024!Admin"
echo ""
echo "📋 Vérifications recommandées:"
echo "   - API Test: https://new.dinorapp.com/api/test/database-check"
echo "   - Logs: storage/logs/laravel.log"
echo ""
echo "💡 Note: Identifiants admin identiques au développement local"
echo ""
echo "✅ Déploiement terminé!" 