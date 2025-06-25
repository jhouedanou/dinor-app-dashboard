# Guide de Diagnostic - Erreur 500 sur Forge

## 🔍 Étapes de Diagnostic

### 1. **Vérifier les Logs**
```bash
# Sur Forge, accédez aux logs
tail -f /home/forge/new.dinorapp.com/storage/logs/laravel.log

# Ou consultez les logs via l'interface Forge
```

### 2. **Vérifications Communes**

#### A. **Permissions des Fichiers**
```bash
# Sur le serveur Forge
chmod -R 755 /home/forge/new.dinorapp.com
chmod -R 775 /home/forge/new.dinorapp.com/storage
chmod -R 775 /home/forge/new.dinorapp.com/bootstrap/cache
```

#### B. **Cache et Configuration**
```bash
# Vider les caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Regénérer les caches
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### C. **Variables d'Environnement**
Vérifiez le fichier `.env` sur Forge :
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://new.dinorapp.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=forge
DB_USERNAME=forge
DB_PASSWORD=

# Clés requises
APP_KEY=base64:...
```

### 3. **Erreurs Spécifiques Possibles**

#### A. **Migration Manquante**
```bash
php artisan migrate --force
```

#### B. **Autoloader Composer**
```bash
composer dump-autoload --optimize
```

#### C. **Liens Symboliques**
```bash
php artisan storage:link
```

### 4. **Vérifications Spécifiques Dinor**

#### A. **Fichiers CSS Compilés**
```bash
npm run production
```

#### B. **Nouvelles Migrations**
Si vous avez ajouté la migration `pwa_menu_items` :
```bash
php artisan migrate --force
```

### 5. **Debug Temporaire**

Activez temporairement le debug :
```env
# Dans .env sur Forge
APP_DEBUG=true
```

**⚠️ N'oubliez pas de le remettre à `false` après diagnostic !**

### 6. **Script de Diagnostic Rapide**

Créez ce script sur Forge :

```bash
#!/bin/bash
echo "=== Diagnostic Dinor App ==="
echo "PHP Version: $(php -v | head -1)"
echo "Laravel Version: $(php artisan --version)"
echo "Environment: $(grep APP_ENV .env)"
echo "Debug: $(grep APP_DEBUG .env)"
echo "URL: $(grep APP_URL .env)"
echo ""
echo "=== Permissions ==="
ls -la storage/
ls -la bootstrap/cache/
echo ""
echo "=== Last 10 Error Logs ==="
tail -10 storage/logs/laravel.log
echo ""
echo "=== Routes Test ==="
php artisan route:list | grep login
```

## 🔧 Solutions Courantes

### Solution 1 : **Reconstruction Complète**
```bash
composer install --no-dev --optimize-autoloader
npm install
npm run production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force
```

### Solution 2 : **Reset Filament**
```bash
php artisan filament:optimize
```

### Solution 3 : **Vérification Base de Données**
```bash
php artisan tinker
>>> DB::connection()->getPdo();
>>> User::count();
```

## 📝 Checklist Déploiement

- [ ] Fichier `.env` configuré correctement
- [ ] Base de données accessible
- [ ] Migrations exécutées
- [ ] Cache vidé et regénéré
- [ ] Assets compilés (CSS/JS)
- [ ] Permissions correctes
- [ ] Liens symboliques créés
- [ ] Composer optimisé

## 🆘 Si l'Erreur Persiste

1. **Consultez les logs détaillés** dans Forge
2. **Activez temporairement APP_DEBUG=true**
3. **Vérifiez la configuration NGINX/Apache**
4. **Testez une route simple** (ex: `/api/health`)

## 📞 Support

Si l'erreur persiste, fournissez :
- Le contenu des logs d'erreur
- La configuration `.env` (sans les secrets)
- La version PHP utilisée
- Le résultat de `composer show`

---

**Note :** La plupart des erreurs 500 après déploiement sont liées aux permissions, au cache, ou aux variables d'environnement. 