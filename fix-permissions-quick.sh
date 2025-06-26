#!/bin/bash

echo "🔧 === CORRECTION RAPIDE DES PERMISSIONS ==="

cd /home/forge/new.dinorapp.com

echo "🔐 Suppression forcée des fichiers de cache problématiques..."

# Supprimer avec sudo pour forcer les permissions
sudo rm -rf bootstrap/cache/filament 2>/dev/null || true
sudo rm -rf bootstrap/cache/*.php 2>/dev/null || true
sudo rm -rf bootstrap/cache/panels 2>/dev/null || true

echo "📁 Recréation du dossier cache..."
mkdir -p bootstrap/cache
chmod -R 755 bootstrap/cache
chown -R forge:forge bootstrap/cache

echo "🔄 Tentative de git reset..."
git reset --hard origin/main

if [ $? -eq 0 ]; then
    echo "✅ Git reset réussi !"
else
    echo "⚠️ Git reset échoué, nettoyage forcé..."
    git clean -fdx
    git reset --hard origin/main
fi

echo "✅ Correction terminée !"
echo ""
echo "🚀 Vous pouvez maintenant relancer le déploiement complet" 