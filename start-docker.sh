#!/bin/bash

# Script de démarrage Docker pour Dinor Dashboard
echo "🎯 Démarrage de l'environnement Docker Dinor..."

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

# Démarrer les conteneurs
echo "🚀 Démarrage des conteneurs Docker..."
docker-compose up -d

# Attendre que les conteneurs soient prêts
echo "⏳ Attente du démarrage des conteneurs..."
sleep 10

# Installer les dépendances si nécessaire
echo "📦 Vérification des dépendances..."
docker exec -it dinor-app composer install --no-interaction

# Vérifier si la base de données est prête
echo "🗄️  Vérification de la base de données..."
docker exec -it dinor-app php artisan migrate --force

# Afficher les URLs d'accès
echo ""
echo "✅ Environnement Docker démarré avec succès !"
echo ""
echo "🌐 URLs d'accès :"
echo "   🖥️  Application Laravel: http://localhost:8000"
echo "   ⚙️  Admin Dashboard: http://localhost:8000/admin"
echo "   🗄️  Adminer (DB): http://localhost:8080"
echo "   📱 PWA Dev: http://localhost:5173"
echo ""
echo "🔧 Commandes utiles :"
echo "   - Arrêter: docker-compose down"
echo "   - Logs: docker-compose logs -f"
echo "   - Shell: docker exec -it dinor-app bash"
echo "   - Artisan: docker exec -it dinor-app php artisan"
echo ""
echo "🚨 Appuyez sur Ctrl+C pour arrêter l'affichage des logs"
echo ""

# Afficher les logs en temps réel
docker-compose logs -f 