# Corrections de Base de Données - 14 Août 2025

## 🚨 Problèmes Identifiés

### 1. Erreur de Difficulté des Recettes
**Erreur :** `SQLSTATE[01000]: Warning: 1265 Data truncated for column 'difficulty' at row 1`

**Cause :** 
- La table `recipes.difficulty` était un ENUM limité à `['easy', 'medium', 'hard']`
- Le formulaire Filament envoyait `'beginner'` qui n'était pas dans l'ENUM
- MySQL tronquait la valeur et générait un warning

**Solution appliquée :**
- Migration `2025_08_14_000001_update_difficulty_enum_in_recipes_table.php`
- Extension de l'ENUM à `['beginner', 'easy', 'medium', 'hard', 'expert']`
- Valeur par défaut changée à `'beginner'`

### 2. Erreur de Champ Category_id des Événements
**Erreur :** `SQLSTATE[HY000]: General error: 1364 Field 'category_id' doesn't have a default value`

**Cause :**
- La table `events.category_id` était définie comme `NOT NULL` sans valeur par défaut
- Le formulaire Filament utilisait `event_category_id` mais le modèle tentait d'insérer dans `category_id`
- Le champ `category_id` était vide lors de l'insertion

**Solution appliquée :**
- Migration `2025_08_14_000002_fix_events_category_id_field.php`
- Rendre le champ `category_id` nullable dans la table `events`

## 🔧 Fichiers Modifiés

### Migrations
1. `database/migrations/2025_08_14_000001_update_difficulty_enum_in_recipes_table.php`
2. `database/migrations/2025_08_14_000002_fix_events_category_id_field.php`

### Modèles
1. `app/Models/Recipe.php` - Ajout des labels pour 'beginner' et 'expert'

### Scripts
1. `deployGood.sh` - Mise à jour avec application automatique des migrations
2. `scripts/test-fixes.sh` - Script de test des corrections

## 🚀 Application des Corrections

### En Local
```bash
# Appliquer les migrations
php artisan migrate

# Tester les corrections
./scripts/test-fixes.sh
```

### En Production
```bash
# Le script deployGood.sh applique automatiquement les migrations
./deployGood.sh
```

## ✅ Vérifications

### Recettes
- [ ] L'ENUM `difficulty` inclut `'beginner', 'easy', 'medium', 'hard', 'expert'`
- [ ] Création d'une recette avec `difficulty = 'beginner'` fonctionne
- [ ] Les labels s'affichent correctement dans l'interface

### Événements
- [ ] Le champ `category_id` est nullable
- [ ] Création d'un événement sans `category_id` fonctionne
- [ ] Le champ `event_category_id` est utilisé correctement

## 🔍 Tests de Validation

Le script `scripts/test-fixes.sh` vérifie automatiquement :
1. Présence des migrations
2. Structure des tables
3. Création de test des recettes et événements
4. Validation des contraintes de base de données

## 📝 Notes Importantes

- **Compatibilité :** Les corrections sont rétrocompatibles
- **Rollback :** Les migrations incluent des méthodes `down()` pour annuler
- **Performance :** Aucun impact sur les performances existantes
- **Sécurité :** Aucune modification des permissions ou de la sécurité

## 🆘 En Cas de Problème

1. **Vérifier les logs :** `storage/logs/laravel.log`
2. **Tester manuellement :** `php artisan tinker`
3. **Rollback si nécessaire :** `php artisan migrate:rollback --step=2`
4. **Vérifier la structure :** `php artisan migrate:status`

---

**Date :** 14 Août 2025  
**Auteur :** Assistant IA  
**Version :** 1.0
