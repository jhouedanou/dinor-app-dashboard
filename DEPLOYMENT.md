# 🚀 Guide de Déploiement - Dinor App Dashboard

## 📋 Checklist Pré-Déploiement

### ✅ Avant de commencer
- [ ] Serveur Laravel Forge configuré
- [ ] Base de données PostgreSQL créée
- [ ] Certificat SSL configuré
- [ ] Redis disponible
- [ ] Accès SSH au serveur

## 🔧 Configuration Laravel Forge

### 1. 📦 Script de Déploiement

**Remplacez le script par défaut dans Forge par** :

```bash
cd /home/forge/your-domain.com

# Mise à jour du code
git pull origin $FORGE_SITE_BRANCH

echo "📦 Installation des dépendances Composer..."
$FORGE_COMPOSER install --no-dev --no-interaction --prefer-dist --optimize-autoloader

echo "📦 Installation des dépendances NPM..."
npm ci

echo "🏗️ Build des assets..."
npm run build

echo "⚡ Optimisation Laravel..."
$FORGE_PHP artisan config:cache
$FORGE_PHP artisan route:cache
$FORGE_PHP artisan view:cache
$FORGE_PHP artisan event:cache

echo "🗄️ Migration de la base de données..."
if [ -f artisan ]; then
    $FORGE_PHP artisan migrate --force
fi

echo "🔧 Configuration des permissions..."
chmod -R 755 storage bootstrap/cache
chown -R forge:forge storage bootstrap/cache

echo "♻️ Redémarrage des services..."
sudo supervisorctl restart all

# Rechargement PHP-FPM avec protection contre les rechargements concurrents
touch /tmp/fpmlock 2>/dev/null || true
( flock -w 10 9 || exit 1
    echo '🔄 Rechargement PHP-FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9</tmp/fpmlock

echo "✅ Déploiement terminé avec succès!"
```

### 2. 🔒 Variables d'Environnement

**Configurez ces variables dans l'onglet "Environment" de Forge** :

```env
# Application
APP_NAME="Dinor App"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Base de données (PostgreSQL)
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=forge
DB_USERNAME=forge
DB_PASSWORD=YOUR_SECURE_PASSWORD

# Cache et Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail (exemple avec Mailgun)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@mg.your-domain.com
MAIL_PASSWORD=your-mailgun-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@your-domain.com"
MAIL_FROM_NAME="Dinor App"

# Stockage
FILESYSTEM_DISK=public
```

### 3. 🗄️ Configuration Base de Données

**Étapes** :
1. Créer une base PostgreSQL dans Forge
2. Noter les identifiants
3. Les ajouter aux variables d'environnement
4. Le script de déploiement exécutera automatiquement les migrations

### 4. 📁 Commandes Post-Déploiement

**Première fois seulement** - Connectez-vous en SSH et exécutez :

```bash
cd /home/forge/your-domain.com

# Créer le lien symbolique pour le stockage
php artisan storage:link

# Seeder les données initiales (optionnel)
php artisan db:seed --class=IngredientsSeeder

# Créer un utilisateur admin
php artisan admin:create-test
```

## 🛠️ Résolution des Problèmes

### ❌ Erreur 500 - Checklist de Debug

1. **Vérifier les logs** :
```bash
tail -f /home/forge/your-domain.com/storage/logs/laravel.log
```

2. **Vérifier les permissions** :
```bash
cd /home/forge/your-domain.com
chmod -R 755 storage bootstrap/cache
chown -R forge:forge storage bootstrap/cache
```

3. **Nettoyer les caches** :
```bash
php artisan optimize:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

4. **Vérifier la configuration** :
```bash
php artisan config:show database
php artisan env
```

### 🔍 Problèmes Courants

| Problème | Solution |
|----------|----------|
| **Erreur de connexion DB** | Vérifier les variables DB_* dans .env |
| **Erreur de permissions** | `chmod -R 755 storage bootstrap/cache` |
| **Cache corrompu** | `php artisan optimize:clear` |
| **Assets manquants** | `npm run build` |
| **Erreur Filament** | Vérifier que toutes les migrations sont passées |

### 📊 Monitoring

**Commandes utiles pour surveiller** :

```bash
# Statut des services
sudo supervisorctl status

# Logs en temps réel
tail -f storage/logs/laravel.log

# Espace disque
df -h

# Processus PHP
ps aux | grep php

# Statut Redis
redis-cli ping
```

## ⚡ Optimisations Performance

### 🚀 Configuration Serveur (dans Forge)

1. **PHP** : Version 8.2+
2. **OPcache** : Activé
3. **Redis** : Installé et configuré
4. **Nginx** : Configuration par défaut Forge

### 📈 Optimisations Laravel

**Ajouter au script de déploiement** :

```bash
# Optimisations supplémentaires
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Optimisation Composer
composer dump-autoload --optimize --classmap-authoritative
```

## 🔐 Sécurité

### 🛡️ Checklist Sécurité

- [ ] `APP_DEBUG=false` en production
- [ ] HTTPS avec certificat SSL valide
- [ ] Mots de passe forts pour la base de données
- [ ] Accès admin sécurisé avec 2FA (recommandé)
- [ ] Sauvegardes automatiques configurées
- [ ] Logs de sécurité activés

### 🔑 Gestion des Utilisateurs Admin

**Créer un admin en production** :
```bash
php artisan make:command CreateProdAdmin
```

**Ou utiliser la commande existante** :
```bash
php artisan admin:create-test
```

## 📱 Tests Post-Déploiement

### ✅ Checklist de Validation

1. **Application accessible** : `https://your-domain.com`
2. **Dashboard admin** : `https://your-domain.com/admin`
3. **Connexion admin** : Tester avec les identifiants créés
4. **API disponible** : `https://your-domain.com/api/v1/recipes`
5. **Upload d'images** : Tester via le dashboard
6. **Performance** : Temps de chargement < 2s

### 🧪 Tests API

```bash
# Test des endpoints principaux
curl https://your-domain.com/api/v1/recipes
curl https://your-domain.com/api/v1/ingredients
curl https://your-domain.com/api/v1/events
```

## 📞 Support

**En cas de problème** :

1. **Consulter les logs** : `storage/logs/laravel.log`
2. **Vérifier la configuration** : Variables d'environnement
3. **Tester en local** : Reproduire avec Docker
4. **Documentation Forge** : [forge.laravel.com/docs](https://forge.laravel.com/docs)

---

💡 **Conseil** : Gardez une copie de ce guide et adaptez-le selon votre configuration spécifique. 