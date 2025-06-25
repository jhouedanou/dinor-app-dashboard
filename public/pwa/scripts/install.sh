#!/bin/bash

# Script d'installation et de démarrage pour le développement PWA

echo "🚀 Installation et configuration PWA Dinor..."

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "composer.json" ]; then
    echo "❌ Erreur: Exécutez ce script depuis la racine du projet Laravel"
    exit 1
fi

# Installation des dépendances Node.js
echo "📦 Installation des dépendances Node.js..."
npm install

# Installation des dépendances PHP si nécessaire
if [ ! -d "vendor" ]; then
    echo "📦 Installation des dépendances PHP..."
    composer install
fi

# Configuration du storage
echo "📂 Configuration du storage..."
./scripts/setup-storage.sh

# Génération des icônes PWA (optionnel)
echo "🎨 Pour générer les icônes PWA, ouvrez:"
echo "   http://localhost:8000/pwa/icons/generate-icons.html"

# Configuration de l'environnement
echo "⚙️ Vérification de la configuration..."

# Vérifier que APP_URL est défini
if grep -q "APP_URL=http://localhost" .env 2>/dev/null; then
    echo "✅ APP_URL configuré pour le développement"
else
    echo "⚠️ Assurez-vous que APP_URL=http://localhost:8000 dans .env"
fi

# Instructions de démarrage
echo ""
echo "🎯 Pour démarrer le développement PWA:"
echo ""
echo "📋 Option 1 - Docker (recommandé):"
echo "   docker-compose up -d"
echo "   # L'app sera disponible sur:"
echo "   # - Laravel: http://localhost:8000"
echo "   # - BrowserSync: http://localhost:3001 (hot reload)"
echo "   # - PWA: http://localhost:8000/pwa/"
echo ""
echo "📋 Option 2 - Développement local:"
echo "   # Terminal 1:"
echo "   php artisan serve"
echo "   # Terminal 2:"
echo "   npm run pwa:dev"
echo ""
echo "🔗 URLs importantes:"
echo "   - PWA: http://localhost:8000/pwa/"
echo "   - Admin: http://localhost:8000/admin"
echo "   - API: http://localhost:8000/api/v1/"
echo "   - Test: http://localhost:8000/pwa/test.html"
echo ""
echo "✨ Installation terminée! Happy coding! 🎉"