#!/bin/bash

echo "🔧 [FILAMENT] Correction des références localhost dans Filament"

# 1. Corriger les vues Filament
echo "📄 [FIX] Correction des vues Filament..."

# Trouver tous les fichiers qui contiennent localhost:5174
echo "🔍 [SEARCH] Recherche des fichiers contenant localhost:5174..."
grep -r "localhost:5174" resources/views/ 2>/dev/null || echo "Aucune référence localhost:5174 trouvée dans resources/views/"

# Corriger les fichiers de vues
find resources/views -name "*.php" -type f -exec sed -i 's/localhost:5174/new.dinorapp.com/g' {} \;
find resources/views -name "*.blade.php" -type f -exec sed -i 's/localhost:5174/new.dinorapp.com/g' {} \;

# 2. Vérifier les fichiers de configuration
echo "⚙️ [CONFIG] Vérification des configurations..."

# Vérifier APP_URL dans .env
if [ -f .env ]; then
    echo "📝 [ENV] Contenu de APP_URL dans .env:"
    grep "APP_URL" .env || echo "APP_URL non trouvé dans .env"
else
    echo "❌ [ENV] Fichier .env non trouvé"
fi

# 3. Nettoyer les caches
echo "🧹 [CACHE] Nettoyage des caches..."
php artisan config:clear
php artisan view:clear
php artisan cache:clear

# 4. Régénérer les caches
echo "🔄 [CACHE] Régénération des caches..."
php artisan config:cache
php artisan view:cache

# 5. Vérification finale
echo "✅ [CHECK] Vérification finale..."
echo "Recherche de localhost:5174 restants:"
grep -r "localhost:5174" resources/ 2>/dev/null || echo "✅ Aucune référence localhost:5174 trouvée"

echo "🎉 [DONE] Correction terminée !"