#!/bin/bash

echo "🧹 Nettoyage complet de Docker..."

# Arrêter tous les conteneurs
docker-compose down --volumes --remove-orphans

# Supprimer les images de l'application
docker rmi dinor-app-dashboard-app 2>/dev/null || true
docker rmi dinor-app-dashboard_app 2>/dev/null || true

# Nettoyer les volumes et réseaux orphelins
docker volume prune -f
docker network prune -f

# Nettoyer les images intermédiaires
docker image prune -f

# Nettoyer le cache du builder
docker builder prune -f

echo "✅ Nettoyage terminé!"
echo "🔨 Construction de l'image..."

# Reconstruire complètement
docker-compose build --no-cache app

echo "🚀 Construction terminée!"