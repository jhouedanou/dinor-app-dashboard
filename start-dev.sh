#!/bin/bash

# Script de démarrage complet pour le développement
echo "🎯 Démarrage de l'environnement de développement complet Dinor..."

# Vérifier les prérequis
if ! command -v php &> /dev/null; then
    echo "❌ PHP n'est pas installé"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ Node.js/npm n'est pas installé"
    exit 1
fi

# Installer les dépendances si nécessaire
if [ ! -d "vendor" ]; then
    echo "📦 Installation des dépendances Composer..."
    composer install
fi

if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances NPM..."
    npm install
fi

# Copier .env si nécessaire
if [ ! -f ".env" ]; then
    echo "📄 Copie du fichier .env..."
    cp .env.example .env
    php artisan key:generate
fi

# Créer les dossiers nécessaires
mkdir -p public/pwa/dist
mkdir -p storage/app/public
mkdir -p public/storage

# Lancer Laravel en arrière-plan
echo "🚀 Démarrage de Laravel..."
php artisan serve --port=8000 &
LARAVEL_PID=$!

# Attendre que Laravel soit prêt
echo "⏳ Attente du démarrage de Laravel..."
while ! curl -s http://localhost:8000 > /dev/null; do
    sleep 1
done

echo "✅ Laravel démarré sur http://localhost:8000"
echo "✅ Admin Dashboard: http://localhost:8000/admin"

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt des services..."
    kill $LARAVEL_PID 2>/dev/null
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT

# Lancer le développement PWA
echo "🎨 Démarrage du serveur de développement PWA avec hot reload..."
echo ""
echo "📱 PWA: http://localhost:3000"
echo "🔧 HMR: http://localhost:3001"
echo "🖥️  Laravel: http://localhost:8000"
echo "⚙️  Admin: http://localhost:8000/admin"
echo ""
echo "💡 Vos modifications CSS/SCSS seront reflétées en temps réel !"
echo "🚨 Appuyez sur Ctrl+C pour arrêter tous les services"
echo ""

# Démarrer le développement PWA
./dev-pwa.sh