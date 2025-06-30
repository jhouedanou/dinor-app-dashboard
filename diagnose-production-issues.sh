#!/bin/bash

echo "🔍 [DIAGNOSTIC] Analyse des problèmes de déploiement en production"

# 1. Vérifier les fichiers d'assets
echo "📦 [ASSETS] Vérification des fichiers d'assets..."
echo "Contenu de public/pwa/dist/:"
ls -la public/pwa/dist/ 2>/dev/null || echo "❌ Répertoire public/pwa/dist/ non trouvé"

echo ""
echo "Contenu de public/:"
ls -la public/ | grep -E "(manifest|registerSW|sw\.js)" || echo "❌ Fichiers PWA manquants"

# 2. Vérifier les hashes d'assets dans index.html
echo ""
echo "🔗 [LINKS] Vérification des liens d'assets..."
if [ -f public/pwa/dist/index.html ]; then
    echo "Assets référencés dans index.html:"
    grep -E "(assets/.*\.(js|css))" public/pwa/dist/index.html || echo "❌ Aucun asset trouvé dans index.html"
else
    echo "❌ public/pwa/dist/index.html non trouvé"
fi

# 3. Vérifier les icônes PWA
echo ""
echo "🎨 [ICONS] Vérification des icônes PWA..."
echo "Icônes dans public/pwa/icons/:"
ls -la public/pwa/icons/ 2>/dev/null || echo "❌ Répertoire public/pwa/icons/ non trouvé"

# 4. Vérifier les configurations
echo ""
echo "⚙️ [CONFIG] Vérification des configurations..."
echo "Variables d'environnement importantes:"
grep -E "(APP_URL|APP_ENV)" .env 2>/dev/null || echo "❌ Fichier .env non trouvé"

# 5. Vérifier les erreurs dans les logs
echo ""
echo "📋 [LOGS] Dernières erreurs dans les logs..."
if [ -f storage/logs/laravel.log ]; then
    echo "Dernières erreurs (5 dernières):"
    grep "ERROR" storage/logs/laravel.log | tail -5 || echo "✅ Aucune erreur récente"
else
    echo "❌ Fichier de log non trouvé"
fi

# 6. Vérifier les permissions
echo ""
echo "🔐 [PERMS] Vérification des permissions..."
echo "Permissions de public/:"
ls -ld public/
echo "Permissions de storage/:"
ls -ld storage/

# 7. Vérifier la configuration Vite
echo ""
echo "⚡ [VITE] Vérification de la configuration Vite..."
if [ -f vite.pwa.config.js ]; then
    echo "✅ vite.pwa.config.js trouvé"
    echo "Configuration de build:"
    grep -A 5 "build:" vite.pwa.config.js
else
    echo "❌ vite.pwa.config.js non trouvé"
fi

echo ""
echo "📊 [SUMMARY] Résumé du diagnostic:"
echo "1. Vérifiez que 'npm run pwa:build' a été exécuté"
echo "2. Vérifiez que manifest.webmanifest et registerSW.js existent"
echo "3. Vérifiez les références localhost dans les vues Filament"
echo "4. Redéployez sur Forge après les corrections"