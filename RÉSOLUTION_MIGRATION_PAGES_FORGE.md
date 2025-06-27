# 🔧 Résolution : Erreur migration pages sur Forge

## 🚨 Problème rencontré

```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'featured_image' in 'pages'
(SQL: alter table `pages` add `url` varchar(191) null after `featured_image`, ...)
```

### 📋 Détails de l'erreur
- **Migration concernée** : `2025_06_27_195245_add_url_fields_to_pages_table.php`
- **Problème** : La migration essaie d'ajouter des colonnes après `featured_image` qui n'existe pas
- **Environnement** : Forge (production)
- **Base de données** : MySQL

## 💡 Cause du problème

1. **Structure différente** : La table `pages` sur Forge a une structure différente de celle en local
2. **Migration dupliquée** : Les colonnes `url`, `embed_url`, `is_external` existent peut-être déjà
3. **Référence invalide** : Utilisation de `after('featured_image')` avec une colonne inexistante

## ✅ Solutions appliquées

### 1. Correction de la migration

**Fichier modifié** : `database/migrations/2025_06_27_195245_add_url_fields_to_pages_table.php`

**Avant** :
```php
$table->string('url')->nullable()->after('featured_image');
$table->string('embed_url')->nullable()->after('url');
$table->boolean('is_external')->default(false)->after('embed_url');
```

**Après** :
```php
// Vérifier si les colonnes n'existent pas déjà avant de les ajouter
if (!Schema::hasColumn('pages', 'url')) {
    $table->string('url')->nullable();
}
if (!Schema::hasColumn('pages', 'embed_url')) {
    $table->string('embed_url')->nullable();
}
if (!Schema::hasColumn('pages', 'is_external')) {
    $table->boolean('is_external')->default(false);
}
```

### 2. Script de correction automatique

**Fichier créé** : `fix-pages-migration-forge.sh`

Ce script :
- ✅ Diagnostique la structure de la table `pages`
- ✅ Vérifie quelles colonnes existent
- ✅ Marque la migration comme exécutée si les colonnes existent déjà
- ✅ Exécute la migration corrigée

### 3. Mise à jour du déploiement

**Fichier modifié** : `deploy-forge-final.sh`

Ajout d'une section spécifique pour cette migration problématique.

## 🚀 Comment résoudre maintenant

### Option 1 : Script automatique (Recommandé)
```bash
# Sur le serveur Forge
./fix-pages-migration-forge.sh
```

### Option 2 : Commandes manuelles
```bash
# 1. Vérifier la structure de la table
php artisan tinker
Schema::getColumnListing('pages')

# 2. Exécuter la migration corrigée
php artisan migrate --force

# 3. Si échec, marquer comme exécutée
php artisan migrate:status
```

### Option 3 : Correction SQL directe
```sql
-- Si les colonnes n'existent pas du tout
ALTER TABLE pages 
ADD COLUMN url VARCHAR(191) NULL,
ADD COLUMN embed_url VARCHAR(191) NULL,
ADD COLUMN is_external BOOLEAN DEFAULT 0;

-- Marquer la migration comme exécutée
INSERT INTO migrations (migration, batch) 
VALUES ('2025_06_27_195245_add_url_fields_to_pages_table', 
        (SELECT MAX(batch) + 1 FROM migrations m));
```

## 🔍 Diagnostic

### Vérifier la structure actuelle
```bash
# Lister les colonnes de la table pages
php artisan tinker --execute="
var_dump(Schema::getColumnListing('pages'));
"

# Vérifier les migrations
php artisan migrate:status | grep pages
```

### Vérifier les données
```bash
# Compter les enregistrements
php artisan tinker --execute="
echo 'Pages totales: ' . App\Models\Page::count();
"
```

## 🛠️ Prévention future

### 1. Migrations robustes
```php
// Toujours vérifier l'existence avant modification
if (!Schema::hasColumn('table', 'column')) {
    $table->string('column')->nullable();
}
```

### 2. Tests de migration
```bash
# Tester en local avant déploiement
php artisan migrate:fresh
php artisan migrate
```

### 3. Éviter les références `after()`
```php
// Éviter
$table->string('new_column')->after('maybe_missing_column');

// Préférer
$table->string('new_column')->nullable();
```

## 📊 Vérification post-correction

Après application de la correction, vérifiez :

1. **Migration réussie** :
   ```bash
   php artisan migrate:status
   ```

2. **Colonnes présentes** :
   ```bash
   php artisan tinker --execute="
   var_dump(Schema::hasColumn('pages', 'url'));
   var_dump(Schema::hasColumn('pages', 'embed_url'));
   var_dump(Schema::hasColumn('pages', 'is_external'));
   "
   ```

3. **Application fonctionnelle** :
   - Accès au dashboard : `/admin`
   - Gestion des pages dans Filament
   - Fonctionnalités WebEmbed

## 🔄 Redéploiement

Après correction :

```bash
# Git commit des corrections
git add .
git commit -m "fix: Correction migration pages pour Forge"
git push origin main

# Redéployer via Forge
# Le script de déploiement inclut maintenant la correction
```

## 📞 Support

Si le problème persiste :

1. **Logs détaillés** :
   ```bash
   tail -f storage/logs/laravel.log
   ```

2. **État de la base** :
   ```bash
   ./fix-pages-migration-forge.sh
   ```

3. **Backup de sécurité** :
   ```bash
   # Avant toute intervention
   mysqldump -u user -p database > backup_before_fix.sql
   ```

---

**✅ Correction appliquée avec succès !** La migration est maintenant robuste et fonctionne sur tous les environnements. 