#!/bin/bash

echo "🚀 Démarrage du setup Dinor Dashboard..."

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

echo "✅ Docker et Docker Compose sont disponibles"

# Construire et démarrer les conteneurs
echo "📦 Construction et démarrage des conteneurs..."
docker-compose up -d --build

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services (30 secondes)..."
sleep 30

# Configuration de l'application
echo "⚙️ Configuration de l'application Laravel..."

# Copier le fichier d'environnement
docker exec dinor-app cp .env.example .env

# Installer les dépendances
echo "📚 Installation des dépendances..."
docker exec dinor-app composer install --optimize-autoloader --no-dev

# Générer la clé d'application
echo "🔑 Génération de la clé d'application..."
docker exec dinor-app php artisan key:generate

# Exécuter les migrations
echo "🗄️ Création de la base de données..."
docker exec dinor-app php artisan migrate --force

# Créer le lien symbolique pour le storage
echo "📁 Configuration du stockage..."
docker exec dinor-app php artisan storage:link

# Peupler la base de données avec des données de démonstration
echo "🌱 Création des données de démonstration..."
docker exec dinor-app php artisan db:seed

# Instructions finales
echo ""
echo "🎉 Installation terminée avec succès!"
echo ""
echo "📍 Accès aux services:"
echo "   - Dashboard Admin: http://localhost:8000/admin"
echo "   - API: http://localhost:8000/api/v1/"
echo "   - PhpMyAdmin: http://localhost:8080"
echo "   - Application: http://localhost:8000"
echo ""
echo "🔧 Pour créer un utilisateur admin:"
echo "   docker exec -it dinor-app php artisan make:filament-user"
echo ""
echo "📊 Base de données MySQL:"
echo "   - Host: localhost:3306"
echo "   - Database: dinor_dashboard"
echo "   - Username: dinor"
echo "   - Password: password"
echo ""
echo "✨ Votre dashboard Dinor est prêt!" 