#!/bin/bash

echo "🎨 Configuration des images pour le Dashboard Dinor"
echo "=================================================="

# Créer le lien symbolique pour storage si il n'existe pas
if [ ! -L "public/storage" ]; then
    echo "📂 Création du lien symbolique pour storage..."
    ln -s ../storage/app/public public/storage
    echo "✅ Lien symbolique créé"
else
    echo "✅ Lien symbolique déjà existant"
fi

# Vérifier les permissions des dossiers
echo "🔐 Vérification des permissions..."
chmod -R 755 storage/app/public/
chmod -R 755 public/storage/ 2>/dev/null || true

# Vérifier que les dossiers d'images existent
echo "📁 Vérification des dossiers d'images..."

RECIPE_DIRS=("storage/app/public/recipes/featured" "storage/app/public/recipes/gallery")
EVENT_DIRS=("storage/app/public/events/featured" "storage/app/public/events/gallery")

for dir in "${RECIPE_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "🔨 Création du dossier $dir"
        mkdir -p "$dir"
    fi
done

for dir in "${EVENT_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "🔨 Création du dossier $dir"
        mkdir -p "$dir"
    fi
done

# Compter les images existantes
RECIPE_COUNT=$(find storage/app/public/recipes/ -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | wc -l)
EVENT_COUNT=$(find storage/app/public/events/ -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" | wc -l)

echo "📊 Images trouvées:"
echo "   - Recettes: $RECIPE_COUNT images"
echo "   - Événements: $EVENT_COUNT images"

# Instructions pour la suite
echo ""
echo "🚀 Configuration terminée !"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Ouvrir public/dashboard.html dans votre navigateur"
echo "2. Exécuter add-test-images-data.sql pour ajouter des données de test"
echo "3. Consulter DASHBOARD_GUIDE.md pour plus d'informations"
echo ""
echo "🎯 URLs à tester:"
echo "   - Dashboard: file://$(pwd)/public/dashboard.html"
echo "   - Images: http://localhost:8000/storage/ (si serveur web actif)"
echo ""
echo "✨ Votre dashboard avec images et galleries est prêt !" 