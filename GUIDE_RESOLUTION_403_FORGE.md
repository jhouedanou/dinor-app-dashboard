# 🚨 Guide Résolution Erreur 403 Forbidden - Laravel Forge

## 📋 **Checklist de Diagnostic**

### **1. Vérification du Document Root**
Dans l'interface Forge :
- **Sites** → **Votre site** → **Meta**
- **Document Root** doit être : `/public`
- ❌ Si c'est `/` → **Changer pour `/public`**

### **2. Vérification des Variables d'Environnement**
Dans l'interface Forge :
- **Sites** → **Votre site** → **Environment**
- Variables critiques à vérifier :

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com

# Base de données
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_DATABASE=forge
DB_USERNAME=forge
DB_PASSWORD=[votre-mot-de-passe]

# Authentification
ADMIN_LOGIN_ENABLED=true
```

### **3. Vérification de la Configuration Nginx**
Dans l'interface Forge :
- **Sites** → **Votre site** → **Nginx Configuration**
- Vérifiez que le bloc `location` ressemble à :

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    fastcgi_param DOCUMENT_ROOT $realpath_root;
}
```

## 🔧 **Actions de Correction**

### **Action 1 : Script de Permissions**
1. Connectez-vous en SSH : `ssh forge@votre-serveur`
2. Exécutez le script de permissions :
```bash
bash fix-forge-permissions.sh
```

### **Action 2 : Vérification Laravel**
```bash
cd /home/forge/new.dinorapp.com
php artisan --version
php artisan migrate:status
php artisan config:clear
php artisan cache:clear
```

### **Action 3 : Test des Routes**
```bash
php artisan route:list | grep admin
```
**Résultat attendu :**
```
GET|HEAD  admin .................. filament.admin.pages.dashboard
GET|HEAD  admin/login ............ filament.admin.auth.login
```

### **Action 4 : Vérification des Logs**
```bash
tail -50 storage/logs/laravel.log
```

## 🛠️ **Solutions Spécifiques par Symptôme**

### **Symptôme : 403 sur `/admin`**
**Cause probable :** Configuration Filament
**Solution :**
1. Vérifiez que l'admin existe :
```bash
php artisan tinker
>>> App\Models\AdminUser::count()
```
2. Si 0, créez un admin :
```bash
php artisan db:seed --class=AdminUserSeeder
```

### **Symptôme : 403 sur toutes les pages**
**Cause probable :** Document Root incorrect
**Solution :**
1. Dans Forge → Sites → Meta → Document Root : `/public`
2. Rechargez la configuration Nginx

### **Symptôme : 403 intermittent**
**Cause probable :** Permissions ou cache
**Solution :**
```bash
php artisan optimize:clear
sudo service nginx reload
sudo service php8.2-fpm reload
```

## 🔍 **Tests de Validation**

### **Test 1 : Accès direct au fichier index.php**
URL : `https://votre-domaine.com/index.php`
**Attendu :** Redirection vers `/admin`

### **Test 2 : Route admin**
URL : `https://votre-domaine.com/admin`
**Attendu :** Page de connexion Filament

### **Test 3 : Assets publics**
URL : `https://votre-domaine.com/css/filament/filament/app.css`
**Attendu :** Fichier CSS chargé

## 📞 **Support Avancé**

### **Si le problème persiste :**

1. **Logs Nginx** :
```bash
sudo tail -50 /var/log/nginx/error.log
```

2. **Logs PHP-FPM** :
```bash
sudo tail -50 /var/log/php8.2-fpm.log
```

3. **Test de configuration PHP** :
```bash
php -m | grep -E "(pdo|mysql|openssl)"
```

### **Commandes de Debug Laravel**
```bash
# État de l'application
php artisan about

# Test de la base de données  
php artisan migrate:status

# Vérification des providers
php artisan config:show filament
```

## ✅ **Validation Finale**

Après correction, ces URL doivent fonctionner :
- ✅ `https://votre-domaine.com` → Redirige vers `/admin`
- ✅ `https://votre-domaine.com/admin` → Page de connexion
- ✅ Connexion avec : `admin@dinor.app` / `Dinor2024!Admin`

---

**🎯 Cas le plus fréquent :** Document Root incorrect dans Forge
**🔧 Solution rapide :** Changer le Document Root pour `/public` dans l'interface Forge 