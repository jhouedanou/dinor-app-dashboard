# Guide de Déploiement sur Laravel Forge

## 🚨 Problème Résolu

**Erreur initiale :**
```
error: Your local changes to the following files would be overwritten by merge:
    storage/logs/laravel.log
Please commit your changes or stash them before you merge.
```

**Solution appliquée :**
1. ✅ Restauration du fichier de log
2. ✅ Ajout dans .gitignore
3. ✅ Commit des nouvelles fonctionnalités
4. ✅ Push vers le repository

## 🚀 Étapes de Déploiement sur Forge

### 1. **Vérification Pré-déploiement**

Avant de déclencher le déploiement sur Forge, s'assurer que :
- ✅ Tous les commits sont poussés
- ✅ Les fichiers de logs sont ignorés
- ✅ Les migrations sont prêtes

### 2. **Script de Déploiement Forge**

Voici le script recommandé pour Forge :

```bash
cd $FORGE_SITE_PATH

# Mise à jour du code
git pull origin main

# Installation des dépendances
composer install --no-dev --optimize-autoloader

# Exécution des migrations
php artisan migrate --force

# Optimisations Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Redémarrage des services
php artisan queue:restart

# Permissions (si nécessaire)
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

### 3. **Variables d'Environnement**

S'assurer que ces variables sont configurées dans Forge :

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=[votre-clé-app]

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=[nom-base]
DB_USERNAME=[utilisateur]
DB_PASSWORD=[mot-de-passe]

# Cache et Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Logs
LOG_CHANNEL=stack
LOG_LEVEL=error
```

### 4. **Nouvelles Migrations à Exécuter**

Les nouvelles migrations incluent :
- `2025_01_21_000001_create_ingredients_table.php`
- `2025_01_21_000002_add_subcategory_to_recipes_table.php`

### 5. **Seeder Optionnel**

Pour peupler la base d'ingrédients de base :
```bash
php artisan db:seed --class=IngredientsSeeder
```

## 🔧 Configuration Post-déploiement

### Vérifications à Effectuer

1. **Interface Admin** : `/admin`
   - Vérifier l'accès au nouveau menu "Ingrédients"
   - Tester la création d'ingrédients
   - Vérifier les sous-catégories dans les recettes

2. **Base de Données**
   - Confirmer que les tables sont créées
   - Vérifier les index
   - Tester les relations

3. **Fonctionnalités**
   - Interface d'ingrédients
   - Composants personnalisés
   - Formulaires de recettes améliorés

## 🛠 Résolution des Problèmes Courants

### Erreur : "Class not found"
```bash
composer dump-autoload
php artisan config:clear
```

### Erreur : "Column not found"
```bash
php artisan migrate:status
php artisan migrate --force
```

### Erreur : Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```

### Permissions
```bash
sudo chown -R www-data:www-data storage/
sudo chown -R www-data:www-data bootstrap/cache/
```

## 📋 Checklist de Déploiement

- [ ] Code pushé sur GitHub
- [ ] Variables d'environnement configurées
- [ ] Script de déploiement mis à jour
- [ ] Déploiement lancé sur Forge
- [ ] Migrations exécutées
- [ ] Tests d'interface effectués
- [ ] Fonctionnalités vérifiées

## 🎯 Nouvelles Fonctionnalités Déployées

### ✅ Système d'Ingrédients
- Base de données complète
- Interface d'administration
- Catégories et sous-catégories
- Unités de mesure standardisées

### ✅ Améliorations Recettes
- Champ sous-catégorie
- Interface d'ingrédients avancée
- Composants personnalisés
- Mode de saisie d'instructions amélioré

### ✅ Corrections Techniques
- Compatibilité PHP 7.2+
- Optimisations Filament 3
- Gestion des logs améliorée

## 🔄 Déploiements Futurs

### Préventions

1. **Toujours vérifier .gitignore**
   ```bash
   # Fichiers à ignorer
   storage/logs/*.log
   storage/framework/cache/*
   storage/framework/sessions/*
   storage/framework/views/*
   ```

2. **Script de pré-déploiement**
   ```bash
   #!/bin/bash
   git status
   php -l app/Models/*.php
   php artisan route:list > /dev/null
   ```

3. **Tests automatisés**
   - Vérification syntaxe PHP
   - Tests de base de données
   - Validation des resources Filament

---

## 📞 Support

En cas de problème pendant le déploiement :
1. Vérifier les logs Laravel : `storage/logs/laravel.log`
2. Vérifier les logs serveur web
3. Tester en local d'abord
4. Utiliser `php artisan tinker` pour déboguer

**Le déploiement devrait maintenant se dérouler sans problème !** 🚀 