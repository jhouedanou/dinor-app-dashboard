#!/bin/bash

echo "🔧 DIAGNOSTIC ET CORRECTION PERMISSIONS FORGE"
echo "=============================================="

# Naviguer vers le dossier du site
cd /home/forge/new.dinorapp.com

echo ""
echo "1️⃣ Vérification des permissions actuelles..."
ls -la

echo ""
echo "2️⃣ Correction des permissions de base..."
# Permissions recommandées pour Laravel sur Forge
sudo chown -R forge:forge .
sudo chmod -R 755 .
sudo chmod -R 775 storage
sudo chmod -R 775 bootstrap/cache

echo ""
echo "3️⃣ Permissions spécifiques Laravel..."
# Dossiers critiques
chmod -R 775 storage/logs
chmod -R 775 storage/framework/cache
chmod -R 775 storage/framework/sessions  
chmod -R 775 storage/framework/views
chmod -R 775 storage/app/public

echo ""
echo "4️⃣ Vérification du document root..."
# Le document root doit pointer vers /public
echo "Document root actuel : $(pwd)/public"
ls -la public/

echo ""
echo "5️⃣ Test de l'application..."
# Vérifier que Laravel peut démarrer
php artisan --version
php artisan config:cache
php artisan route:clear

echo ""
echo "6️⃣ Vérification des fichiers critiques..."
# Fichiers qui doivent exister
if [ -f "public/index.php" ]; then
    echo "✅ public/index.php existe"
else
    echo "❌ public/index.php manquant"
fi

if [ -f ".env" ]; then
    echo "✅ .env existe"
else
    echo "❌ .env manquant"
fi

echo ""
echo "7️⃣ Vérification de la configuration Nginx..."
echo "Vérifiez que le document root dans Forge pointe vers :"
echo "/home/forge/new.dinorapp.com/public"

echo ""
echo "✅ Script terminé. Testez maintenant votre site." 