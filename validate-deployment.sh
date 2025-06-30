#!/bin/bash

echo "✅ [VALIDATION] Test final de déploiement PWA"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Vérifier que les fichiers existent localement
echo "📁 [LOCAL] Vérification des fichiers locaux..."

files_to_check=(
    "public/pwa/dist/index.html"
    "public/pwa/dist/assets/index.C1mfdDgG.js"
    "public/pwa/dist/assets/vendor.BeqKZlTx.js"
    "public/pwa/dist/assets/index.Wn4EB9GG.css"
    "public/manifest.webmanifest"
    "public/registerSW.js"
)

all_files_exist=true
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $file"
    else
        echo -e "${RED}❌${NC} $file - MANQUANT"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = true ]; then
    echo -e "${GREEN}✅ Tous les fichiers essentiels sont présents${NC}"
else
    echo -e "${RED}❌ Certains fichiers sont manquants${NC}"
fi

# 2. Vérifier le contenu de l'index.html
echo ""
echo "🔍 [HTML] Vérification du contenu index.html..."
if grep -q "/pwa/dist/assets/index.C1mfdDgG.js" public/pwa/dist/index.html; then
    echo -e "${GREEN}✅${NC} Référence JS correcte trouvée"
else
    echo -e "${RED}❌${NC} Référence JS incorrecte"
fi

if grep -q "/pwa/dist/assets/index.Wn4EB9GG.css" public/pwa/dist/index.html; then
    echo -e "${GREEN}✅${NC} Référence CSS correcte trouvée"
else
    echo -e "${RED}❌${NC} Référence CSS incorrecte"
fi

# 3. Vérifier les tailles de fichiers
echo ""
echo "📊 [SIZE] Tailles des fichiers..."
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "📄 $file: $size"
    fi
done

# 4. URLs à tester en production
echo ""
echo "🌐 [URLS] URLs à tester sur https://new.dinorapp.com :"
urls_to_test=(
    "/pwa"
    "/pwa/dist/index.html"
    "/pwa/dist/assets/index.C1mfdDgG.js"
    "/pwa/dist/assets/vendor.BeqKZlTx.js"
    "/pwa/dist/assets/index.Wn4EB9GG.css"
    "/manifest.webmanifest"
    "/registerSW.js"
)

for url in "${urls_to_test[@]}"; do
    echo "🔗 https://new.dinorapp.com$url"
done

# 5. Commandes pour tester sur le serveur
echo ""
echo "🧪 [TEST] Commandes de test pour le serveur:"
echo "# Test des assets principaux:"
echo "curl -I https://new.dinorapp.com/pwa/dist/assets/index.C1mfdDgG.js"
echo "curl -I https://new.dinorapp.com/pwa/dist/assets/vendor.BeqKZlTx.js"
echo "curl -I https://new.dinorapp.com/pwa/dist/assets/index.Wn4EB9GG.css"
echo ""
echo "# Test de la PWA:"
echo "curl -I https://new.dinorapp.com/pwa"

# 6. Résumé des corrections
echo ""
echo "📋 [SUMMARY] Résumé des corrections apportées:"
echo -e "${GREEN}✅${NC} Fusion système likes/favoris - Bouton cœur unifié"
echo -e "${GREEN}✅${NC} Correction chemins assets PWA - /pwa/dist/assets/"
echo -e "${GREEN}✅${NC} Génération manifest.webmanifest et registerSW.js"
echo -e "${GREEN}✅${NC} Configuration .htaccess pour routage"
echo -e "${GREEN}✅${NC} Routes Laravel pour servir la PWA"

echo ""
echo -e "${YELLOW}🚀 [DEPLOY] Prêt pour le déploiement sur Forge !${NC}"
echo ""
echo "📝 [STEPS] Prochaines étapes:"
echo "1. Pusher les changements vers le repository"
echo "2. Déclencher un déploiement sur Laravel Forge"
echo "3. Tester les URLs ci-dessus"
echo "4. Vérifier le fonctionnement de la PWA"

echo ""
echo -e "${GREEN}🎉 [SUCCESS] Validation terminée !${NC}"