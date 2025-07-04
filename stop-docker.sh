#!/bin/bash

# Script d'arrêt Docker pour Dinor Dashboard
echo "🛑 Arrêt de l'environnement Docker Dinor..."

# Arrêter les conteneurs
echo "⏹️  Arrêt des conteneurs..."
docker-compose down

echo "✅ Environnement Docker arrêté avec succès !"
echo ""
echo "💡 Pour redémarrer, utilisez: ./start-docker.sh" 