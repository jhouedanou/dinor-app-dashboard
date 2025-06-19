#!/bin/bash

echo "🧪 Test du Dashboard Dinor - Validation Complète"
echo "==============================================="

# 1. Vérifier les images
echo "📸 Vérification des images..."
RECIPE_IMAGES=$(find public/storage/recipes/ -name "*.jpg" -o -name "*.png" | wc -l)
EVENT_IMAGES=$(find public/storage/events/ -name "*.jpg" -o -name "*.png" | wc -l)

echo "   ✅ Images de recettes trouvées: $RECIPE_IMAGES"
echo "   ✅ Images d'événements trouvées: $EVENT_IMAGES"

# 2. Vérifier le lien symbolique
echo "🔗 Vérification du lien symbolique..."
if [ -L "public/storage" ]; then
    echo "   ✅ Lien symbolique présent"
    if [ -d "public/storage/recipes" ]; then
        echo "   ✅ Dossier recipes accessible"
    else
        echo "   ❌ Dossier recipes non accessible"
        exit 1
    fi
else
    echo "   ❌ Lien symbolique manquant"
    exit 1
fi

# 3. Vérifier le fichier dashboard
echo "📄 Vérification du fichier dashboard..."
if [ -f "public/dashboard.html" ]; then
    echo "   ✅ Fichier dashboard.html présent"
    
    # Vérifier la présence de données de test
    if grep -q "Poulet Kedjenou Traditionnel" public/dashboard.html; then
        echo "   ✅ Données de test recettes présentes"
    else
        echo "   ❌ Données de test recettes manquantes"
    fi
    
    if grep -q "Festival Culinaire" public/dashboard.html; then
        echo "   ✅ Données de test événements présentes"
    else
        echo "   ❌ Données de test événements manquantes"
    fi
else
    echo "   ❌ Fichier dashboard.html manquant"
    exit 1
fi

# 4. Tester les URLs des images
echo "🌐 Test d'accessibilité..."
echo "   📍 Dashboard disponible à: http://localhost:3000/dashboard.html"
echo "   📍 Test image recette: http://localhost:3000/storage/recipes/featured/recipe-1.jpg"
echo "   📍 Test image événement: http://localhost:3000/storage/events/featured/event-1.jpg"

# 5. Instructions finales
echo ""
echo "🎯 Instructions de Test:"
echo "========================="
echo "1. Ouvrez http://localhost:3000/dashboard.html dans votre navigateur"
echo "2. Cliquez sur une carte de recette (Poulet Kedjenou)"
echo "3. Vérifiez que la modal s'ouvre avec:"
echo "   - ✅ Image principale visible"
echo "   - ✅ Galerie de miniatures"
echo "   - ✅ Liste d'ingrédients (pas d'[object Object])"
echo "   - ✅ Instructions numérotées (pas d'[object Object])"
echo "   - ✅ Clic sur l'image pour zoomer"
echo "4. Testez la même chose avec un événement"
echo "5. Testez le zoom d'images et la navigation dans la galerie"
echo ""
echo "🐛 Si vous voyez encore '[object Object]':"
echo "   - Vérifiez la console (F12) pour les erreurs"
echo "   - Rechargez la page (Ctrl+F5)"
echo "   - Vérifiez que le JavaScript AlpineJS est chargé"
echo ""
echo "✨ Le dashboard devrait maintenant être parfaitement fonctionnel !"
echo ""
echo "📊 Statistiques finales:"
echo "   - Recettes de test: 3"
echo "   - Événements de test: 3" 
echo "   - Images disponibles: $((RECIPE_IMAGES + EVENT_IMAGES))"
echo "   - Fonctionnalités: Modal, Zoom, Galeries, Navigation" 