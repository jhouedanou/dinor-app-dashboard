#!/bin/bash

echo "🔧 Correction des problèmes de configuration en production..."

# Corriger les variables d'environnement manquantes
echo "📝 Correction des variables d'environnement..."

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

# Variables de logging essentielles
update_env_var "LOG_CHANNEL" "stack"
update_env_var "LOG_DEPRECATIONS_CHANNEL" "null"
update_env_var "LOG_LEVEL" "error"

# Variables d'application
update_env_var "APP_ENV" "production"
update_env_var "APP_DEBUG" "false"

# Variables de cache
update_env_var "CACHE_DRIVER" "file"
update_env_var "SESSION_DRIVER" "file"
update_env_var "QUEUE_CONNECTION" "sync"

echo "✅ Variables d'environnement corrigées"

# Vider tous les caches
echo "🧹 Vidage complet des caches..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Redécouverte des composants Livewire
echo "🔍 Redécouverte des composants Livewire..."
php artisan livewire:discover 2>/dev/null || echo "⚠️ Commande livewire:discover non disponible"

# Optimiser l'autoloader
echo "⚡ Optimisation de l'autoloader..."
composer dump-autoload --optimize

# Reconstruire les caches optimisés
echo "🏗️ Reconstruction des caches optimisés..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Créer les dossiers de logs avec permissions
echo "📁 Configuration des dossiers de logs..."
mkdir -p storage/logs
chmod 755 storage/logs
touch storage/logs/laravel.log
chmod 644 storage/logs/laravel.log

echo "🎉 Configuration de production corrigée!"