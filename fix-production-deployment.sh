#!/bin/bash

echo "🚀 [DEPLOY] Correction des erreurs de déploiement en production"

# 1. Nettoyer et reconstruire la PWA
echo "📦 [BUILD] Nettoyage et reconstruction de la PWA..."
rm -rf public/pwa/dist/*
rm -rf node_modules/.vite
npm run pwa:build

# 2. Créer le manifest.webmanifest manquant
echo "📄 [MANIFEST] Création du manifest.webmanifest..."
cat > public/manifest.webmanifest << 'EOF'
{
  "name": "Dinor App",
  "short_name": "Dinor",
  "description": "Application de recettes, astuces et événements culinaires",
  "theme_color": "#E1251B",
  "background_color": "#ffffff",
  "display": "standalone",
  "orientation": "portrait",
  "scope": "/",
  "start_url": "/",
  "icons": [
    {
      "src": "/pwa/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "/pwa/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

# 3. Créer le fichier registerSW.js manquant
echo "⚙️ [SW] Création du script registerSW.js..."
cat > public/registerSW.js << 'EOF'
// Service Worker Registration Script
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('✅ SW registered: ', registration);
      })
      .catch((registrationError) => {
        console.log('❌ SW registration failed: ', registrationError);
      });
  });
}
EOF

# 4. Corriger les références localhost dans les vues Filament
echo "🔧 [FIX] Correction des références localhost..."
find resources/views -name "*.php" -type f -exec sed -i 's/localhost:5174/new.dinorapp.com/g' {} \;
find resources/views -name "*.blade.php" -type f -exec sed -i 's/localhost:5174/new.dinorapp.com/g' {} \;

# 5. Générer les vues de cache
echo "🔄 [CACHE] Génération des vues de cache..."
php artisan view:cache

# 6. Optimiser l'application
echo "⚡ [OPTIMIZE] Optimisation de l'application..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Vérifier les permissions
echo "🔐 [PERMS] Vérification des permissions..."
chmod -R 755 public/
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/

# 8. Afficher les résultats
echo "📊 [RESULT] Vérification des fichiers générés..."
echo "Fichiers dans public/pwa/dist/:"
ls -la public/pwa/dist/
echo ""
echo "Manifest.webmanifest:"
ls -la public/manifest.webmanifest
echo ""
echo "RegisterSW.js:"
ls -la public/registerSW.js

echo "✅ [DEPLOY] Correction terminée ! Redéployez maintenant sur Forge."