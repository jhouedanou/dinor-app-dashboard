#!/bin/bash

echo "🔍 DIAGNOSTIC RAPIDE ERREUR 403 - DINOR"
echo "========================================"

# Aller au dossier du site
cd /home/forge/new.dinorapp.com

echo ""
echo "1️⃣ Vérification de la structure..."
if [ -f "public/index.php" ]; then
    echo "✅ public/index.php existe"
else
    echo "❌ public/index.php MANQUANT!"
fi

echo ""
echo "2️⃣ Test Laravel..."
php artisan --version

echo ""
echo "3️⃣ Nettoyage des caches..."
php artisan optimize:clear
php artisan config:cache

echo ""
echo "4️⃣ Vérification des permissions..."
sudo chown -R forge:forge .
sudo chmod -R 755 .
sudo chmod -R 775 storage bootstrap/cache

echo ""
echo "5️⃣ Test des routes admin..."
php artisan route:list | grep admin

echo ""
echo "6️⃣ Vérification utilisateur admin..."
php artisan tinker --execute="echo 'Admins: ' . App\Models\AdminUser::count();"

echo ""
echo "7️⃣ Informations Nginx..."
echo "Document root doit pointer vers: /home/forge/new.dinorapp.com/public"
echo ""
echo "✅ Diagnostic terminé!"
echo ""
echo "🌐 Testez maintenant: https://new.dinorapp.com/admin"
echo "🔐 Login: admin@dinor.app / Dinor2024!Admin" 