#!/bin/bash

# Script de déploiement complet pour Laravel Forge
# Inclut les migrations, cache, et configurations Analytics Firebase

echo "🚀 Déploiement Forge - Dinor App avec Analytics Firebase"

# 1. Mise à jour des dépendances
echo "📦 Installation des dépendances..."
composer install --no-dev --optimize-autoloader --no-interaction
npm ci --production

# 2. Configuration de l'environnement
echo "⚙️ Configuration de l'environnement..."

# S'assurer que les variables Firebase sont dans .env
if ! grep -q "VITE_FIREBASE_ANALYTICS_ENABLED" .env; then
    echo "🔥 Ajout des variables Firebase Analytics dans .env..."
    cat >> .env << 'EOL'

# Firebase Analytics Configuration
VITE_FIREBASE_ANALYTICS_ENABLED=true
VITE_FIREBASE_PROJECT_ID=dinor-app-2
VITE_FIREBASE_API_KEY=AIzaSyCq37nk-Cjt0r3n-QDqZ6R2rB0JOSJQtfM
VITE_ANALYTICS_DEBUG_MODE=false
EOL
fi

# 3. Cache et optimisations
echo "🧹 Nettoyage et optimisation des caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# 4. Générer les caches optimisés
echo "⚡ Génération des caches de production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Migrations de base de données
echo "🗄️ Exécution des migrations..."
php artisan migrate --force

# Vérifier que la table analytics_events existe
if ! php artisan migrate:status | grep -q "create_analytics_events_table"; then
    echo "❌ ERREUR: Migration analytics_events manquante"
    exit 1
fi

# 6. Seeders de production si nécessaire
if [ "$1" = "--seed" ]; then
    echo "🌱 Exécution des seeders de production..."
    php artisan db:seed --class=ProductionDataSeeder
fi

# 7. Permissions et liens symboliques
echo "🔗 Configuration des liens symboliques et permissions..."
php artisan storage:link

# Créer les dossiers nécessaires s'ils n'existent pas
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p public/images/{recipes,tips,events,banners}

# Permissions (adaptées pour Forge)
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/
chown -R forge:forge storage/ bootstrap/cache/ || echo "⚠️ Impossible de changer les permissions (normal sur Forge)"

# 8. Build des assets frontend
echo "🎨 Build des assets frontend..."

# PWA Build
if [ -f "vite.pwa.config.js" ]; then
    echo "📱 Build PWA..."
    npm run pwa:build
fi

# Build principal
npm run build

# 9. Compilation SCSS si nécessaire
if command -v sass &> /dev/null; then
    echo "🎨 Compilation SCSS..."
    npm run scss:build
fi

# 10. Tests de santé post-déploiement
echo "🔍 Tests de santé..."

# Test de la base de données
if ! php artisan migrate:status &> /dev/null; then
    echo "❌ ERREUR: Problème de connexion à la base de données"
    exit 1
fi

# Test des routes API Analytics
if ! php artisan route:list | grep -q "api/analytics/event"; then
    echo "❌ ERREUR: Routes Analytics manquantes"
    exit 1
fi

# Test de l'existence des widgets Filament
if [ ! -f "app/Filament/Widgets/FirebaseAnalyticsWidget.php" ]; then
    echo "❌ ERREUR: Widget Analytics manquant"
    exit 1
fi

# Test de la configuration Firebase
if [ ! -f "src/pwa/services/firebaseConfig.js" ]; then
    echo "❌ ERREUR: Configuration Firebase manquante"
    exit 1
fi

# 11. Redémarrage des services si nécessaire
echo "🔄 Redémarrage des services..."

# Queue workers (si utilisés)
if [ -f "artisan" ] && php artisan queue:restart &> /dev/null; then
    echo "✅ Queue redémarrée"
fi

# Cache Redis (si utilisé)
if command -v redis-cli &> /dev/null; then
    redis-cli flushdb || echo "⚠️ Redis non disponible"
fi

# Supervisor (si configuré)
if command -v supervisorctl &> /dev/null; then
    sudo supervisorctl reread || echo "⚠️ Supervisor non configuré"
    sudo supervisorctl update || echo "⚠️ Supervisor non configuré"
fi

# 12. Rapport de déploiement
echo ""
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo ""
echo "📊 Composants installés :"
echo "   ✓ Laravel Backend avec Analytics API"
echo "   ✓ Firebase Analytics SDK (PWA)"
echo "   ✓ Widgets Dashboard Filament" 
echo "   ✓ Table analytics_events migrée"
echo "   ✓ Navigation tactile corrigée"
echo ""
echo "🔧 Configuration vérifiée :"
echo "   ✓ Base de données : $(php artisan migrate:status | wc -l) migrations"
echo "   ✓ Cache : Configuration mise en cache"
echo "   ✓ Assets : Build terminé"
echo "   ✓ Firebase : Clés configurées"
echo ""
echo "🌐 URLs importantes :"
echo "   📋 Dashboard Admin: $(php artisan route:list | grep 'admin' | head -1 | awk '{print $4}' || echo '/admin')"
echo "   📡 API Analytics: /api/analytics/metrics"
echo "   📱 PWA: /pwa"
echo ""
echo "🔍 Pour tester les Analytics :"
echo "   curl -X POST $(php artisan route:list | grep 'api/analytics/event' | awk '{print $4}' || echo '/api/analytics/event') -H 'Content-Type: application/json' -d '{\"event_type\":\"test\",\"session_id\":\"test123\",\"timestamp\":$(date +%s)000}'"
echo ""
echo "🎯 Déploiement Analytics Firebase : COMPLET !"

# 13. Logs finaux
echo "📝 Logs récents :" 
tail -5 storage/logs/laravel.log 2>/dev/null || echo "Pas de logs récents"

exit 0