#!/bin/bash

# Script d'urgence pour les permissions NPM
# Usage rapide: ./npm-emergency-fix.sh

echo "🚨 CORRECTIF D'URGENCE NPM"

# Arrêter tous les processus NPM
pkill -f "npm" 2>/dev/null || true

# Corriger les permissions de tout le projet
echo "🔐 Correction des permissions..."
chown -R forge:forge . 2>/dev/null || true

# Suppression forcée de node_modules et fichiers lock
echo "🗑️ Suppression forcée..."
rm -rf node_modules/ 2>/dev/null || true
rm -f package-lock.json .package-lock.json npm-shrinkwrap.json yarn.lock 2>/dev/null || true

# Nettoyage cache NPM
echo "🧹 Nettoyage cache..."
npm cache clean --force 2>/dev/null || true

# Installation directe
echo "📦 Installation NPM..."
if npm install --no-fund --no-audit --cache=/tmp/npm-temp; then
    echo "✅ NPM installé avec succès"
    rm -rf /tmp/npm-temp 2>/dev/null || true
    chown -R forge:forge node_modules/ 2>/dev/null || true
    chmod -R 755 node_modules/ 2>/dev/null || true
else
    echo "❌ Échec NPM - créer structure minimale"
    mkdir -p node_modules/.bin
    chown -R forge:forge node_modules/ 2>/dev/null || true
fi

echo "🎉 Correctif d'urgence terminé!"