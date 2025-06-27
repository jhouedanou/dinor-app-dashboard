#!/bin/bash

# Script de vérification rapide des fichiers PWA
echo "🔍 Vérification des fichiers PWA"

# Vérifier les fichiers critiques
critical_files=(
    "public/pwa/dist/index.html"
    "public/pwa/dist/manifest.webmanifest"
    "public/pwa/dist/sw.js"
)

echo "📋 Vérification des fichiers critiques:"
all_exist=true

for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        echo "✅ $file ($size bytes)"
    else
        echo "❌ $file - MANQUANT"
        all_exist=false
    fi
done

# Vérifier le répertoire assets
if [ -d "public/pwa/dist/assets" ]; then
    asset_count=$(ls -1 public/pwa/dist/assets/ | wc -l)
    echo "✅ Répertoire assets ($asset_count fichiers)"
else
    echo "❌ Répertoire assets - MANQUANT"
    all_exist=false
fi

echo ""
if [ "$all_exist" = true ]; then
    echo "🎉 Tous les fichiers PWA sont présents!"
    echo ""
    echo "📊 Résumé des fichiers PWA:"
    ls -la public/pwa/dist/
else
    echo "⚠️  Certains fichiers PWA sont manquants!"
    echo "💡 Exécutez: ./deploy-pwa-fix.sh pour corriger"
fi 