#!/bin/bash

echo "🚨 DIAGNOSTIC COMPLET 403 - DINOR"
echo "=================================="

cd /home/forge/new.dinorapp.com

echo ""
echo "1️⃣ Test direct index.php..."
echo "URL: https://new.dinorapp.com/index.php"
curl -v https://new.dinorapp.com/index.php 2>&1 | head -20

echo ""
echo "2️⃣ Test direct admin..."
echo "URL: https://new.dinorapp.com/admin"
curl -v https://new.dinorapp.com/admin 2>&1 | head -20

echo ""
echo "3️⃣ Vérification configuration Nginx..."
sudo nginx -T | grep -A20 -B5 "server_name.*dinorapp.com"

echo ""
echo "4️⃣ Test fichier statique..."
echo "Test: public/css/filament/filament/app.css"
if [ -f "public/css/filament/filament/app.css" ]; then
    echo "✅ Fichier CSS existe"
    curl -I https://new.dinorapp.com/css/filament/filament/app.css
else
    echo "❌ Fichier CSS manquant"
fi

echo ""
echo "5️⃣ Permissions détaillées..."
echo "Propriétaire dossier public:"
ls -la public/ | head -5
echo ""
echo "Propriétaire index.php:"
ls -la public/index.php

echo ""
echo "6️⃣ Test PHP direct..."
echo "<?php echo 'PHP fonctionne: ' . phpversion();" > public/test-php.php
curl https://new.dinorapp.com/test-php.php
rm public/test-php.php

echo ""
echo "7️⃣ Variables d'environnement critiques..."
echo "APP_URL: $(grep APP_URL .env)"
echo "APP_ENV: $(grep APP_ENV .env)"
echo "APP_DEBUG: $(grep APP_DEBUG .env)"

echo ""
echo "8️⃣ Logs Nginx récents..."
echo "Dernières erreurs Nginx:"
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "9️⃣ Processus actifs..."
echo "Nginx:"
sudo systemctl status nginx --no-pager | head -5
echo ""
echo "PHP-FPM:"
sudo systemctl status php8.3-fpm --no-pager | head -5

echo ""
echo "🔟 Test Laravel artisan serve..."
echo "Test si Laravel fonctionne en direct:"
timeout 5 php artisan serve --host=0.0.0.0 --port=8080 &
sleep 2
curl -I http://localhost:8080/ 2>/dev/null || echo "Artisan serve ne répond pas"
pkill -f "artisan serve" 2>/dev/null

echo ""
echo "✅ Diagnostic terminé!" 