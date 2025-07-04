#!/bin/bash

echo "🔧 Redémarrage de l'application Dinor avec les corrections..."

# Arrêter les conteneurs
echo "🛑 Arrêt des conteneurs..."
docker-compose down

# Reconstruire l'image avec les nouvelles modifications
echo "🔨 Reconstruction de l'image Docker..."
docker-compose build --no-cache

# Redémarrer les conteneurs
echo "🚀 Redémarrage des conteneurs..."
docker-compose up -d

# Attendre que l'application soit prête
echo "⏳ Attente du démarrage des services..."
sleep 10

# Exécuter les migrations et optimisations dans le conteneur
echo "🗄️ Exécution des migrations et optimisations..."
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
docker-compose exec app composer install --no-dev --optimize-autoloader

# Vider le cache Redis
echo "🗑️ Vidage du cache Redis..."
docker-compose exec app php artisan cache:clear

# Redémarrer le service worker
echo "🔄 Redémarrage du service worker..."
docker-compose exec app php artisan queue:restart

echo "✅ Application redémarrée avec succès !"
echo "🌐 Accédez à l'application sur: http://localhost:8000"
echo "📱 PWA disponible sur: http://localhost:8000/pwa/"
echo "🗄️ Base de données sur: http://localhost:8080 (Adminer)"

# Afficher les logs en temps réel
echo "📋 Logs en temps réel (Ctrl+C pour arrêter):"
docker-compose logs -f app