# Guide de Déploiement - Dinor App

## 🚀 Déploiement Rapide en Production

### Option 1: Script de Déploiement Automatique

Le moyen le plus simple de déployer l'application avec toutes les données :

```bash
# Depuis la racine du projet
./deploy-production.sh
```

### Option 2: Commande Artisan Personnalisée

```bash
php artisan dinor:setup-production --force
```

### Option 3: Déploiement Manuel

```bash
# 1. Migrations
php artisan migrate --force

# 2. Lien symbolique pour le stockage
php artisan storage:link

# 3. Données de démonstration
php artisan db:seed --class=ProductionSetupSeeder --force

# 4. Optimisations
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

## 📊 Données Créées

Le système créera automatiquement :

### 👥 **Utilisateurs de Test**
- **Admin**: `admin@dinor.app` / `admin123`
- **Chef**: `chef.aya@dinor.app` / `password`
- **Utilisateurs**: `marie.adjoua@example.com` / `password`

### 🍽️ **Contenu de Démonstration**
- **6+ Recettes** avec ingrédients et instructions
- **3+ Astuces** avec conseils pratiques
- **4+ Événements** programmés
- **3+ Pages** statiques
- **3+ Vidéos** Dinor TV
- **10+ Catégories** organisées par type
- **Likes et Commentaires** pour rendre l'app vivante

## 🔧 Configuration Requise

### Serveur Web
- **PHP**: 8.2+ avec extensions (pdo, mbstring, xml, etc.)
- **Composer**: Pour les dépendances
- **Base de données**: MySQL/MariaDB ou SQLite

### Configuration Laravel
```bash
# .env minimum requis
APP_NAME="Dinor"
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://votre-domaine.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dinor_app
DB_USERNAME=username
DB_PASSWORD=password
```

## 📱 Interface Utilisateur

### Dashboard Admin Filament
- **URL**: `/admin`
- **Fonctionnalités**:
  - Gestion des recettes avec galeries
  - Gestion des astuces 
  - Gestion des événements
  - Gestion des utilisateurs
  - Gestion des likes et commentaires
  - Statistiques complètes

### Pages Publiques
- **Dashboard**: `/dashboard.html`
- **Recettes**: `/recipe.html?id=1`
- **Astuces**: `/tip.html?id=1`
- **Événements**: `/event.html?id=1`

## 🔐 Authentification

### Système Intégré
- **Connexion/Inscription** via modals automatiques
- **JWT Tokens** pour l'authentification API
- **Protection** des actions (likes, commentaires)
- **Stockage local** des sessions

### API Endpoints
```
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/likes/toggle (authentifié)
POST /api/v1/comments (authentifié)
GET  /api/v1/recipes/{id}
GET  /api/v1/tips/{id}
```

## 🛠️ Dépannage

### Problèmes Courants

1. **Erreur 500 sur les likes**
   ```bash
   php artisan migrate
   php artisan db:seed --class=UserSeeder
   ```

2. **Alpine.js errors**
   - Vérifiez que les scripts sont inclus
   - Videz le cache du navigateur

3. **Images manquantes**
   ```bash
   php artisan storage:link
   ```

4. **Base de données vide**
   ```bash
   php artisan db:seed --class=ProductionDataSeeder --force
   ```

### Logs Utiles
```bash
# Logs Laravel
tail -f storage/logs/laravel.log

# Logs du serveur web
tail -f /var/log/nginx/error.log
tail -f /var/log/apache2/error.log
```

## 🔄 Mise à Jour

Pour mettre à jour les données en production :

```bash
# Ajouter plus de contenu
php artisan db:seed --class=ProductionDataSeeder

# Recréer complètement
php artisan migrate:fresh --seed
```

## 📋 Checklist de Déploiement

- [ ] Base de données configurée
- [ ] Fichier .env configuré
- [ ] Migrations exécutées
- [ ] Seeders exécutés
- [ ] Storage link créé
- [ ] Cache configuré
- [ ] Permissions correctes
- [ ] HTTPS configuré (recommandé)
- [ ] Sauvegardes automatiques

## 🎯 Résultat Attendu

Après déploiement, vous devriez avoir :

✅ **Dashboard admin fonctionnel** avec toutes les ressources
✅ **Pages publiques** avec contenu de démonstration
✅ **Système d'authentification** opérationnel
✅ **API fonctionnelle** pour l'app mobile
✅ **Données réalistes** pour la démonstration
✅ **Interactions** (likes, commentaires) fonctionnelles

## 🆘 Support

En cas de problème :

1. Vérifiez les logs Laravel
2. Vérifiez la configuration de la base de données
3. Assurez-vous que PHP et les extensions sont installés
4. Vérifiez les permissions des dossiers `storage/` et `bootstrap/cache/`

L'application est maintenant prête pour la production ! 🎉