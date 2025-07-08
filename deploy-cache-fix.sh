#!/bin/bash

echo "🚀 Déploiement et vidage des caches..."

# Vider tous les caches Laravel
php artisan cache:clear
echo "✅ Cache général vidé"

# Vider le cache de configuration 
php artisan config:clear
echo "✅ Cache de configuration vidé"

# Vider le cache des vues
php artisan view:clear
echo "✅ Cache des vues vidé"

# Vider le cache des routes
php artisan route:clear
echo "✅ Cache des routes vidé"

# Reconstruire les caches optimisés
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo "✅ Caches optimisés reconstruits"

# Découverte des composants Livewire
php artisan livewire:discover
echo "✅ Composants Livewire redécouverts"

# Optimiser l'autoloader
composer dump-autoload --optimize
echo "✅ Autoloader optimisé"

echo "🎉 Déploiement terminé avec succès!"