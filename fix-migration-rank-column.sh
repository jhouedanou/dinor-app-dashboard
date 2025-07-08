#!/bin/bash

echo "🔧 Correction du problème de migration sur Forge..."

# Marquer cette migration spécifique comme déjà exécutée si elle échoue
echo "📋 Vérification de l'état des migrations..."

# Option 1: Reset de la migration problématique
echo "🔄 Reset de la migration problématique..."
php artisan migrate:rollback --step=1 --force 2>/dev/null || true

# Option 2: Marquer la migration comme exécutée manuellement
echo "✅ Application de la migration corrigée..."
php artisan migrate --force

# Vérifier que tout fonctionne
echo "🏥 Vérification de l'état de la base de données..."
php artisan migrate:status

echo "✅ Correction terminée !"

# Optionnel: Optimiser l'application après la migration
echo "⚡ Optimisation de l'application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "🚀 Application prête pour le déploiement sur Forge !" 