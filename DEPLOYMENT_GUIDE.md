# Guide de Déploiement Pérenne - Dinor Dashboard

Ce guide présente plusieurs méthodes pour déployer l'application de manière automatisée, sans avoir à recréer manuellement l'utilisateur admin à chaque déploiement.

## 🚀 Solutions Pérennes Disponibles

### 1. Script de Déploiement Automatisé (Recommandé)

Le script `deploy-production.sh` automatise tout le processus de déploiement :

```bash
# Rendre le script exécutable (première fois seulement)
chmod +x deploy-production.sh

# Lancer le déploiement
./deploy-production.sh
```

**Ce que fait le script :**
- ✅ Met à jour le code depuis Git
- ✅ Installe les dépendances Composer
- ✅ Configure automatiquement les variables d'environnement
- ✅ Génère la clé d'application
- ✅ Exécute les migrations
- ✅ Crée/met à jour l'utilisateur admin automatiquement
- ✅ Optimise l'application pour la production
- ✅ Vérifie que tout fonctionne

### 2. Commande Artisan de Configuration

```bash
# Configuration complète pour la production
php artisan dinor:setup-production

# Avec options
php artisan dinor:setup-production --force
php artisan dinor:setup-production --skip-admin
```

### 3. Seeders Automatiques

L'AdminUserSeeder s'exécute automatiquement avec les migrations :

```bash
# Exécution manuelle si nécessaire
php artisan db:seed --class=AdminUserSeeder
```

## 🧹 Résolution des Problèmes de Déploiement

### Script de Nettoyage Git (Nouveau!)

Si vous rencontrez des conflits Git lors du déploiement, utilisez le script de nettoyage :

```bash
# Rendre le script exécutable
chmod +x git-cleanup.sh

# Lancer le nettoyage
./git-cleanup.sh
```

**Ce script résout :**
- ❌ Conflits avec storage/logs/laravel.log
- ❌ Fichiers de cache qui causent des conflits
- ❌ node_modules et vendor corrompus
- ❌ Fichiers temporaires non suivis

### Erreurs Communes et Solutions

#### Erreur CollisionServiceProvider
```
Class "NunoMaduro\Collision\Adapters\Laravel\CollisionServiceProvider" not found
```
**Solution :** L'AppServiceProvider a été mis à jour pour gérer automatiquement ce problème.

#### Erreur Git merge
```
error: Your local changes to the following files would be overwritten by merge
```
**Solution :** Utilisez `./git-cleanup.sh` avant le déploiement.

#### Erreur 419 CSRF Token
**Solution :** Vérifiez les variables d'environnement de session dans `.env`.

## 📋 Variables d'Environnement

Ajoutez ces variables à votre fichier `.env` pour configurer automatiquement l'admin :

```env
# Configuration admin par défaut
ADMIN_DEFAULT_EMAIL=admin@dinor.app
ADMIN_DEFAULT_PASSWORD=Dinor2024!Admin
ADMIN_DEFAULT_NAME=Administrateur Dinor

# Configuration production
APP_ENV=production
APP_DEBUG=false
APP_URL=https://new.dinorapp.com
SESSION_DOMAIN=.dinorapp.com
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax
SANCTUM_STATEFUL_DOMAINS=new.dinorapp.com,dinorapp.com,localhost

# Base de données
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=votre_base_de_donnees
DB_USERNAME=votre_utilisateur
DB_PASSWORD=votre_mot_de_passe
```

## 🔄 Processus de Déploiement Recommandé

### Option A : Script Automatisé (Plus Simple)
```bash
# 1. Nettoyer les conflits potentiels (si nécessaire)
./git-cleanup.sh

# 2. Configurer les variables d'environnement (une seule fois)
# Éditer le fichier .env avec vos paramètres

# 3. Lancer le déploiement automatisé
./deploy-production.sh
```

### Option B : Commandes Manuelles
```bash
# 1. Nettoyage préalable
./git-cleanup.sh

# 2. Dépendances
composer install --no-dev --optimize-autoloader

# 3. Configuration
php artisan dinor:setup-production

# 4. Optimisation
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🛠️ Intégration avec les Plateformes de Déploiement

### Laravel Forge
Ajoutez dans votre script de déploiement Forge :
```bash
cd /home/forge/new.dinorapp.com
./git-cleanup.sh
./deploy-production.sh
```

### Serveur VPS/Dédié
Créez un cron job ou utilisez un webhook :
```bash
# Webhook endpoint qui lance
/var/www/dinor-app-dashboard/deploy-production.sh
```

### Docker/Kubernetes
Ajoutez à votre Dockerfile :
```dockerfile
COPY . /var/www/html
RUN ./deploy-production.sh
```

## 🔧 Maintenance et Mise à Jour

### Mise à jour de l'application
```bash
# Méthode simple avec nettoyage automatique
./deploy-production.sh

# Ou étape par étape
./git-cleanup.sh
git pull origin main
php artisan migrate --force
php artisan db:seed --class=AdminUserSeeder --force
php artisan config:cache
```

### Réinitialisation du mot de passe admin
```bash
# Via Artisan
php artisan admin:reset-password admin@dinor.app --password="NouveauMotDePasse"

# Via variables d'environnement
# Modifier ADMIN_DEFAULT_PASSWORD dans .env puis
php artisan db:seed --class=AdminUserSeeder --force
```

## 🔍 Diagnostic et Dépannage

### Vérification de l'état
```bash
# Diagnostic complet
php diagnosis-login.php

# Nettoyage Git
./git-cleanup.sh

# Vérification avec Artisan
php artisan dinor:setup-production --force
```

### URLs de test importantes
- Dashboard : https://new.dinorapp.com/admin/login
- API Test : https://new.dinorapp.com/api/test/database-check
- API Recettes : https://new.dinorapp.com/api/v1/recipes

## 📚 Scripts Utilitaires

| Script | Usage | Description |
|--------|-------|-------------|
| `deploy-production.sh` | `./deploy-production.sh` | Déploiement complet automatisé |
| `git-cleanup.sh` | `./git-cleanup.sh` | Nettoyage Git avant déploiement |
| `create-production-admin.php` | `php create-production-admin.php` | Création admin sans Laravel |
| `diagnosis-login.php` | `php diagnosis-login.php` | Diagnostic des problèmes |

## ✅ Avantages de cette Approche

1. **Automatisé** : Plus besoin de recréer l'admin manuellement
2. **Sécurisé** : Mots de passe configurés via variables d'environnement
3. **Répétable** : Même processus à chaque déploiement
4. **Robuste** : Vérifications et rollback en cas d'erreur
5. **Flexible** : Plusieurs méthodes selon vos préférences
6. **Résistant aux conflits** : Gestion automatique des problèmes Git

## 🚨 Points Importants

- Les mots de passe sont configurés via les variables d'environnement
- L'utilisateur admin est créé/mis à jour automatiquement
- Tous les caches sont gérés automatiquement
- Les permissions sont configurées correctement
- Les vérifications garantissent que tout fonctionne
- Les conflits Git sont résolus automatiquement

## 🛡️ Sécurité .gitignore

Le `.gitignore` a été amélioré pour exclure automatiquement :
- ✅ Tous les logs (`storage/logs/*.log`)
- ✅ Fichiers de cache (`storage/framework/*`)
- ✅ Sessions (`storage/framework/sessions/*`)
- ✅ Fichiers temporaires (`*.tmp`, `*.backup`)
- ✅ Dépendances (`vendor/`, `node_modules/`)
- ✅ Configuration locale (`.env*`)

**Plus besoin de recréer l'admin à chaque déploiement !** 🎉

## 🆘 En Cas de Problème

Si le déploiement échoue, suivez cette procédure :

1. **Nettoyer d'abord :**
   ```bash
   ./git-cleanup.sh
   ```

2. **Diagnostic :**
   ```bash
   php diagnosis-login.php
   ```

3. **Redéployer :**
   ```bash
   ./deploy-production.sh
   ```

4. **Si ça ne marche toujours pas, créer l'admin manuellement :**
   ```bash
   php create-production-admin.php
   ``` 