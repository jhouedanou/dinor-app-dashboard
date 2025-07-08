# 🚀 Scripts de Déploiement et Corrections

## Vue d'ensemble

Ce répertoire contient tous les scripts nécessaires pour :
1. **Corriger les problèmes de migration** (colonne 'rank' en double)
2. **Résoudre les erreurs d'inscription aux tournois**
3. **Déployer sur Digital Ocean** avec toutes les corrections
4. **Gérer le système d'iframe** pour les pages web

## 📁 Scripts Disponibles

### 🔧 Scripts de Diagnostic

#### `diagnose-tournament-registration.php`
**Objectif :** Diagnostiquer pourquoi les inscriptions aux tournois échouent

**Usage :**
```bash
php diagnose-tournament-registration.php
```

**Fonctionnalités :**
- Analyse le tournoi ID 3 en détail
- Vérifie les conditions d'inscription
- Propose des solutions automatiques
- Affiche les requêtes SQL de correction

### 🛠️ Scripts de Correction

#### `fix-tournament-registration.php`
**Objectif :** Corriger automatiquement les problèmes d'inscription d'un tournoi

**Usage :**
```bash
php fix-tournament-registration.php <tournament_id>

# Exemple
php fix-tournament-registration.php 3
```

**Corrections appliquées :**
- ✅ Change le statut en `registration_open`
- ✅ Ajuste les dates d'inscription
- ✅ Augmente la limite de participants si nécessaire
- ✅ Active le mode public

#### `fix-migration-rank-column.sh`
**Objectif :** Corriger spécifiquement l'erreur de migration de la colonne 'rank'

**Usage :**
```bash
./fix-migration-rank-column.sh
```

**Fonctionnalités :**
- Rollback automatique si échec
- Nouvelle tentative de migration
- Optimisation des caches

### 🧪 Scripts de Test

#### `test-tournament-fixes.sh`
**Objectif :** Tester toutes les corrections en local avant déploiement

**Usage :**
```bash
./test-tournament-fixes.sh
```

**Étapes exécutées :**
1. Diagnostic du tournoi ID 3
2. Correction automatique
3. Vérification des migrations

#### `complete-migration-script.sh`
**Objectif :** Script de migration complet avec toutes les corrections

**Usage :**
```bash
./complete-migration-script.sh
```

**Fonctionnalités :**
- Migration avec gestion d'erreurs
- Correction automatique des colonnes dupliquées
- Exécution des seeders
- Correction de tous les tournois
- Vérifications finales

### 🚀 Scripts de Déploiement

#### `deploy-digital-ocean-complete.sh`
**Objectif :** Script de déploiement complet pour Digital Ocean

**Usage :** (À copier sur le serveur dans le script de déploiement Forge)

**Améliorations par rapport au script original :**
- ✅ Correction automatique des migrations
- ✅ Diagnostic et correction des tournois
- ✅ Gestion des erreurs de colonne 'rank'
- ✅ Test de l'API des tournois
- ✅ Vérifications complètes

## 🚨 Problèmes Résolus

### 1. Erreur de Migration : `Duplicate column name 'rank'`

**Symptôme :**
```
SQLSTATE[42S21]: Column already exists: 1060 Duplicate column name 'rank'
```

**Cause :** La colonne `rank` existe déjà dans la table `leaderboards` depuis la migration de création.

**Solution :** Migration modifiée avec vérification d'existence :
```php
if (!Schema::hasColumn('leaderboards', 'rank')) {
    $table->integer('rank')->nullable()->after('accuracy_percentage');
}
```

### 2. Erreur d'Inscription aux Tournois : `REGISTRATION_NOT_ALLOWED`

**Symptôme :**
```
📄 [API Store] Données d'erreur: {success: false, message: 'Inscription impossible pour ce tournoi', error: 'REGISTRATION_NOT_ALLOWED'}
```

**Causes possibles :**
- Statut du tournoi != `registration_open`
- Dates d'inscription incorrectes
- Limite de participants atteinte
- Tournoi non public

**Solution :** Script de correction automatique qui :
1. Met le statut à `registration_open`
2. Ajuste les dates d'inscription
3. Augmente la limite si nécessaire
4. Active le mode public

## 📋 Guide d'Utilisation

### En Local (Développement)

1. **Tester les corrections :**
   ```bash
   ./test-tournament-fixes.sh
   ```

2. **Migration complète :**
   ```bash
   ./complete-migration-script.sh
   ```

3. **Corriger un tournoi spécifique :**
   ```bash
   php fix-tournament-registration.php 3
   ```

### Sur Digital Ocean (Production)

1. **Remplacer le script de déploiement** par le contenu de `deploy-digital-ocean-complete.sh`

2. **Vérifier après déploiement :**
   - ✅ API Tournois : `https://new.dinorapp.com/api/v1/tournaments`
   - ✅ API Pages : `https://new.dinorapp.com/api/pages`
   - ✅ Administration : `https://new.dinorapp.com/admin/login`

## 🔄 Workflow Recommandé

### Avant Déploiement

```bash
# 1. Test en local
./test-tournament-fixes.sh

# 2. Migration complète
./complete-migration-script.sh

# 3. Vérifier que tout fonctionne
npm run dev
```

### Déploiement

```bash
# 1. Commit des changements
git add .
git commit -m "🔧 Corrections migrations et tournois"
git push

# 2. Le script de déploiement Digital Ocean se charge du reste
```

### Après Déploiement

```bash
# 1. Vérifier l'API des tournois
curl https://new.dinorapp.com/api/v1/tournaments

# 2. Tester l'inscription depuis l'app PWA
# 3. Vérifier les logs si nécessaire
```

## 🆘 Dépannage

### Migration échoue toujours

```bash
# Rollback manuel
php artisan migrate:rollback --step=5

# Relancer
php artisan migrate --force
```

### Tournoi n'accepte toujours pas les inscriptions

```bash
# Diagnostic détaillé
php diagnose-tournament-registration.php

# Correction manuelle
php fix-tournament-registration.php <ID_TOURNOI>
```

### API non accessible

```bash
# Vider les caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Reconstruire
php artisan config:cache
php artisan route:cache
```

## 📞 Support

En cas de problème :

1. **Vérifier les logs :** `storage/logs/laravel.log`
2. **Exécuter les diagnostics :** `./test-tournament-fixes.sh`
3. **Contacter l'équipe technique** avec les détails de l'erreur

## 📝 Notes Importantes

- ⚠️ **Toujours tester en local** avant déploiement
- 📋 **Garder une sauvegarde** de la base de données
- 🔍 **Vérifier les logs** après chaque déploiement
- 🧪 **Tester l'inscription** depuis l'interface PWA

---

*Dernière mise à jour : Janvier 2025* 