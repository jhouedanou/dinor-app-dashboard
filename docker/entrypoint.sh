#!/bin/bash
set -e

echo "🚀 Dinor App - Démarrage du container..."

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
MAX_RETRIES=30
RETRY=0
until php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'ok'; } catch(\Exception \$e) { exit(1); }" 2>/dev/null | grep -q "ok"; do
    RETRY=$((RETRY + 1))
    if [ $RETRY -ge $MAX_RETRIES ]; then
        echo "❌ PostgreSQL non disponible après ${MAX_RETRIES} tentatives"
        exit 1
    fi
    echo "   Tentative $RETRY/$MAX_RETRIES..."
    sleep 2
done
echo "✅ PostgreSQL est prêt"

# Générer APP_KEY si absent
if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null || grep -q "^APP_KEY=base64:AAAA" .env 2>/dev/null; then
    echo "🔑 Génération de APP_KEY..."
    php artisan key:generate --force
fi

# Exécuter les migrations
echo "📦 Exécution des migrations..."
php artisan migrate --force --no-interaction
echo "✅ Migrations terminées"

# Créer le compte admin par défaut s'il n'existe pas
echo "👤 Vérification du compte admin..."
php artisan tinker --execute="
if (!\App\Models\AdminUser::where('email', 'admin@dinor.app')->exists()) {
    \App\Models\AdminUser::create([
        'name' => 'Admin Dinor',
        'email' => 'admin@dinor.app',
        'password' => bcrypt('password'),
        'is_active' => true,
    ]);
    echo '✅ Compte admin créé (admin@dinor.app / password)';
} else {
    echo '✅ Compte admin existe déjà';
}
"

# Vider et reconstruire les caches
echo "🧹 Configuration des caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:assets 2>/dev/null || true
echo "✅ Caches configurés"

# Lien symbolique storage
php artisan storage:link 2>/dev/null || true

echo "🎉 Dinor App prête ! Lancement de Supervisor..."

# Démarrer supervisor (nginx + php-fpm)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
