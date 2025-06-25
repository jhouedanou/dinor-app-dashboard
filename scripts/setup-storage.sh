#!/bin/bash

# Script de configuration du storage pour la PWA Dinor

echo "🔧 Configuration du storage Laravel pour PWA..."

# Créer le lien symbolique pour le storage public
echo "📂 Création du lien symbolique storage..."
php artisan storage:link

# Créer les dossiers nécessaires
echo "📁 Création des dossiers d'images..."
mkdir -p storage/app/public/recipes/featured
mkdir -p storage/app/public/recipes/gallery
mkdir -p storage/app/public/tips
mkdir -p storage/app/public/events/featured
mkdir -p storage/app/public/events/gallery
mkdir -p storage/app/public/pages
mkdir -p storage/app/public/media
mkdir -p storage/app/public/dinor-tv

# Définir les permissions correctes
echo "🔐 Configuration des permissions..."
chmod -R 775 storage/app/public
chmod -R 775 public/storage

# Vérifier que le lien symbolique existe
if [ -L "public/storage" ]; then
    echo "✅ Lien symbolique storage créé avec succès"
else
    echo "❌ Erreur: Lien symbolique non créé"
    exit 1
fi

# Créer des images par défaut si elles n'existent pas
echo "🖼️ Création des images par défaut..."

# Image par défaut pour les recettes
if [ ! -f "storage/app/public/recipes/featured/default-recipe.jpg" ]; then
    # Créer une image de placeholder simple ou copier depuis assets
    echo "⚠️ Image par défaut recette manquante - À ajouter manuellement"
fi

# Image par défaut pour les événements
if [ ! -f "storage/app/public/events/featured/default-event.jpg" ]; then
    echo "⚠️ Image par défaut événement manquante - À ajouter manuellement"
fi

# Image par défaut pour les vidéos
if [ ! -f "storage/app/public/dinor-tv/default-video-thumbnail.jpg" ]; then
    echo "⚠️ Image par défaut vidéo manquante - À ajouter manuellement"
fi

echo "✨ Configuration du storage terminée!"
echo ""
echo "📋 Prochaines étapes manuelles:"
echo "1. Ajouter les images par défaut dans storage/app/public/"
echo "2. Vérifier les permissions sur le serveur de production"
echo "3. Configurer le serveur web pour servir /storage"
echo ""
echo "🔗 URLs d'accès aux images:"
echo "   - Recettes: /storage/recipes/featured/"
echo "   - Événements: /storage/events/featured/"
echo "   - Dinor TV: /storage/dinor-tv/"