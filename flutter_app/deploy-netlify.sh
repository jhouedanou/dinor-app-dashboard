#!/bin/bash

# Script de déploiement Netlify pour Dinor App Flutter
# Usage: ./deploy-netlify.sh

set -e

echo "🚀 Déploiement Netlify - Dinor App Flutter"
echo "=========================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ce script doit être exécuté depuis le répertoire de l'application Flutter."
    exit 1
fi

# Construire l'application
echo "🔨 Construction de l'application..."
./build-web.sh

# Vérifier que le build est réussi
if [ ! -d "build/web" ]; then
    echo "❌ Erreur: Le dossier build/web n'existe pas"
    exit 1
fi

echo "✅ Build réussi !"
echo "📁 Fichiers prêts pour le déploiement:"
ls -la build/web/

# Créer les fichiers de configuration Netlify s'ils n'existent pas
if [ ! -f "build/web/_redirects" ]; then
    echo "📝 Création du fichier _redirects..."
    echo "/*    /index.html   200" > build/web/_redirects
fi

if [ ! -f "build/web/_headers" ]; then
    echo "📝 Création du fichier _headers..."
    cat > build/web/_headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-XSS-Protection: 1; mode=block
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/*.js
  Cache-Control: public, max-age=31536000, immutable

/*.css
  Cache-Control: public, max-age=31536000, immutable

/*.png
  Cache-Control: public, max-age=31536000, immutable

/*.jpg
  Cache-Control: public, max-age=31536000, immutable

/*.ico
  Cache-Control: public, max-age=31536000, immutable

/*.svg
  Cache-Control: public, max-age=31536000, immutable
EOF
fi

echo ""
echo "🌐 Instructions de déploiement Netlify:"
echo "======================================"
echo ""
echo "📋 Méthode 1: Glisser-déposer (Recommandée)"
echo "1. Allez sur https://netlify.com"
echo "2. Créez un compte ou connectez-vous"
echo "3. Glissez-déposez le dossier build/web/ dans la zone de déploiement"
echo "4. Attendez que le déploiement se termine (30-60 secondes)"
echo "5. Votre site est en ligne ! 🎉"
echo ""
echo "📋 Méthode 2: CLI Netlify (Pour les développeurs)"
echo "1. Installez la CLI Netlify: npm install -g netlify-cli"
echo "2. Connectez-vous: netlify login"
echo "3. Déployez: netlify deploy --dir=build/web --prod"
echo ""
echo "📋 Méthode 3: Déploiement via Git"
echo "1. Créez un fichier netlify.toml à la racine du projet"
echo "2. Connectez Netlify à votre repository GitHub"
echo "3. Configurez le build automatique"
echo ""
echo "📊 Statistiques du build:"
echo "- Taille du bundle JavaScript: $(du -h build/web/main.dart.js | cut -f1)"
echo "- Nombre de fichiers: $(find build/web -type f | wc -l)"
echo "- Taille totale: $(du -sh build/web | cut -f1)"
echo ""
echo "🔍 Tests recommandés après déploiement:"
echo "1. Chargement de la page"
echo "2. Navigation entre les pages"
echo "3. Fonctionnalités PWA"
echo "4. Responsive design"
echo "5. Performance (Lighthouse)"
echo ""
echo "📞 Support:"
echo "- Documentation Netlify: https://docs.netlify.com"
echo "- Guide complet: NETLIFY_DEPLOYMENT_GUIDE.md"
echo ""
echo "🎉 Prêt pour le déploiement !" 