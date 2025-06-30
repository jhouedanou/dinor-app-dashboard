#!/bin/bash

echo "🔧 [PWA] Correction du routage PWA pour production"

# 1. Copier l'index.html de la PWA vers la racine du site pour l'accès PWA
echo "📄 [COPY] Copie de l'index.html PWA vers la racine..."
cp public/pwa/dist/index.html public/pwa-index.html

# 2. Créer une route d'accès PWA dans le .htaccess ou équivalent
echo "⚙️ [ROUTE] Configuration des routes PWA..."

# Créer un fichier .htaccess pour Apache si nécessaire
cat > public/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Redirect /pwa to the PWA app
    RewriteRule ^pwa/?$ /pwa/dist/index.html [L]
    RewriteRule ^pwa/(.*)$ /pwa/dist/$1 [L]
    
    # Handle Laravel routes
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>
EOF

# 3. Vérifier que les assets sont bien en place
echo "📦 [CHECK] Vérification des assets..."
echo "Assets dans public/pwa/dist/assets/:"
ls -la public/pwa/dist/assets/ | head -5

echo ""
echo "📄 Fichiers PWA principaux:"
ls -la public/pwa/dist/ | grep -E "(index\.html|manifest|registerSW|sw\.js)"

# 4. Vérifier le contenu du sw.js pour les erreurs de cache
echo ""
echo "🔍 [SW] Vérification du Service Worker..."
if grep -q "Failed to execute 'addAll'" public/pwa/dist/sw.js; then
    echo "⚠️ Problème détecté dans le Service Worker"
else
    echo "✅ Service Worker semble correct"
fi

# 5. Instructions pour Forge
echo ""
echo "🚀 [FORGE] Instructions pour Laravel Forge:"
echo "1. Assurez-vous que mod_rewrite est activé"
echo "2. Vérifiez que les fichiers sont déployés:"
echo "   - https://new.dinorapp.com/pwa/dist/index.html"
echo "   - https://new.dinorapp.com/pwa/dist/assets/index.C1mfdDgG.js"
echo "   - https://new.dinorapp.com/pwa/dist/assets/vendor.BeqKZlTx.js"
echo "   - https://new.dinorapp.com/pwa/dist/assets/index.Wn4EB9GG.css"
echo "3. Testez l'accès PWA: https://new.dinorapp.com/pwa"

echo ""
echo "✅ [DONE] Configuration PWA terminée !"