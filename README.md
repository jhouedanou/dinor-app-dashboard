# 🍳 Dinor App Dashboard

Un tableau de bord complet pour la gestion de contenu culinaire avec Filament 3, Laravel 11 et PostgreSQL.

## 📋 Table des Matières

- [🚀 Installation Locale](#-installation-locale)
- [🔧 Configuration](#-configuration)
- [🌐 Déploiement sur Laravel Forge](#-déploiement-sur-laravel-forge)
- [🔒 Variables d'Environnement](#-variables-denvironnement)
- [🗄️ Base de Données](#️-base-de-données)
- [📝 Administration](#-administration)
- [🛠️ Maintenance](#️-maintenance)

## 🚀 Installation Locale

### Prérequis
- Docker & Docker Compose
- Git

### Installation rapide

```bash
# Cloner le repository
git clone <your-repo-url>
cd dinor-app-dashboard

# Lancer l'environnement Docker
docker-compose up --build -d

# Créer le fichier .env
docker-compose exec app cp .env.example .env

# Générer la clé d'application
docker-compose exec app php artisan key:generate --force

# Lancer les migrations et seeders
docker-compose exec app php artisan migrate:fresh --seed

# Créer un utilisateur admin
docker-compose exec app php artisan admin:create-test
```

🎉 **L'application est accessible sur** : `http://localhost:8000/admin`

**Identifiants par défaut** :
- Email : `admin@dinor.com`
- Mot de passe : `password`

## 🔧 Configuration

### Structure des Services

- **App** : Laravel 11 + Filament 3 (PHP 8.2)
- **Base de données** : PostgreSQL 15
- **Cache** : Redis 7
- **Adminer** : Interface de gestion BDD (`http://localhost:8080`)

### Ports utilisés
- `8000` : Application principale
- `5432` : PostgreSQL
- `6379` : Redis
- `8080` : Adminer

## 🌐 Déploiement sur Laravel Forge

### 📦 Script de Déploiement Forge

Remplacez le script de déploiement par défaut dans Forge par :

```bash
cd /home/forge/your-domain.com
git pull origin $FORGE_SITE_BRANCH

# Installation des dépendances Composer (production)
$FORGE_COMPOSER install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Installation des dépendances NPM et build des assets
npm ci
npm run build

# Optimisation Laravel
$FORGE_PHP artisan config:cache
$FORGE_PHP artisan route:cache
$FORGE_PHP artisan view:cache
$FORGE_PHP artisan event:cache

# Migrations (avec --force pour éviter la confirmation)
if [ -f artisan ]; then
    $FORGE_PHP artisan migrate --force
fi

# Optimisation des permissions
chmod -R 755 storage bootstrap/cache
chown -R forge:forge storage bootstrap/cache

# Restart services
echo "Restarting services..."
sudo supervisorctl restart all

# Prevent concurrent php-fpm reloads  
touch /tmp/fpmlock 2>/dev/null || true
( flock -w 10 9 || exit 1
    echo 'Reloading PHP FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9</tmp/fpmlock

echo "✅ Deployment completed successfully!"
```

### 🔒 Variables d'Environnement

#### Variables essentielles à configurer dans Forge :

```env
# Application
APP_NAME="Dinor App"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Base de données (PostgreSQL recommandé)
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=forge
DB_USERNAME=forge
DB_PASSWORD=your-secure-password

# Cache & Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail (configurer selon votre service)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=your-username
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@your-domain.com"
MAIL_FROM_NAME="${APP_NAME}"

# Stockage de fichiers
FILESYSTEM_DISK=public
```

### 🗄️ Base de Données

#### Configuration PostgreSQL (Recommandé)

1. **Créer la base de données** dans Forge
2. **Configurer les variables** d'environnement
3. **Lancer les migrations** :

```bash
php artisan migrate:fresh --seed --force
```

#### Structure des Tables

- `categories` - Catégories de recettes
- `recipes` - Recettes avec ingrédients et instructions
- `ingredients` - Base de données des ingrédients
- `admin_users` - Utilisateurs administrateurs
- `likes` - Système de likes
- `comments` - Commentaires

### 📝 Administration

#### Créer un utilisateur admin en production

```bash
php artisan make:command CreateAdminUser
```

Ou utilisez la commande existante :

```bash
php artisan admin:create-test
```

#### Accès au dashboard

- **URL** : `https://your-domain.com/admin`
- **Interface** : Filament 3 avec thème personnalisé

### 🛠️ Maintenance

#### Commandes utiles

```bash
# Nettoyer les caches
php artisan optimize:clear

# Recréer les caches
php artisan optimize

# Vérifier les logs
tail -f storage/logs/laravel.log

# Lister les routes
php artisan route:list

# Statut de la queue
php artisan queue:work --verbose
```

#### Debugging des erreurs 500

1. **Vérifier les logs** : `storage/logs/laravel.log`
2. **Permissions** : 
   ```bash
   chmod -R 755 storage bootstrap/cache
   chown -R forge:forge storage bootstrap/cache
   ```
3. **Variables d'environnement** : Vérifier le `.env`
4. **Cache** : Nettoyer avec `php artisan optimize:clear`

#### Performance

```bash
# Optimisation en production
php artisan config:cache
php artisan route:cache  
php artisan view:cache
php artisan event:cache

# Pour annuler (en cas de problème)
php artisan optimize:clear
```

### 🔐 Sécurité

#### Checklist de sécurité

- [ ] `APP_DEBUG=false` en production
- [ ] Utiliser HTTPS (certificat SSL)
- [ ] Mots de passe forts pour la BDD
- [ ] Sauvegardes automatiques configurées
- [ ] Mise à jour régulière des dépendances

#### Sauvegardes

Configurer les sauvegardes automatiques dans Forge :
- Base de données : Quotidienne
- Fichiers : Hebdomadaire

### 📱 Fonctionnalités

#### Interface Ingrédients
- ✅ Base de données complète des ingrédients
- ✅ Catégories et sous-catégories
- ✅ Unités de mesure (g, kg, ml, l, etc.)
- ✅ Marques recommandées
- ✅ Prix moyens et descriptions

#### Interface Recettes  
- ✅ Sélecteur d'ingrédients intelligent
- ✅ Popup pour ajouter de nouveaux ingrédients
- ✅ Instructions avec éditeur riche
- ✅ Sous-catégories de recettes
- ✅ Gestion des images et vidéos

#### Gestion de Contenu
- ✅ Système de likes et commentaires
- ✅ Catégories personnalisables  
- ✅ Médias et galeries d'images
- ✅ Pages statiques
- ✅ Événements

## 🆘 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** : `storage/logs/laravel.log`
2. **Testez en local** avec Docker
3. **Vérifiez les permissions** de fichiers
4. **Consultez la documentation Filament** : [filamentphp.com](https://filamentphp.com)

---

**Développé avec ❤️ en utilisant Laravel 11, Filament 3, et PostgreSQL** 