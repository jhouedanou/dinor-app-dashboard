# Guide de Gestion des Catégories - Dinor Dashboard

## Vue d'ensemble

Le système de gestion des catégories permet d'organiser les recettes par catégories avec la possibilité d'ajouter de nouvelles catégories directement depuis le formulaire de création de recette.

## Fonctionnalités

### 1. Menu dédié aux catégories
- **Accès** : Menu "Contenu" > "Catégories" dans le dashboard admin
- **Fonctions** :
  - Liste de toutes les catégories
  - Création de nouvelles catégories
  - Modification des catégories existantes
  - Activation/désactivation des catégories
  - Suppression de catégories

### 2. Ajout rapide de catégories
- **Lors de la création d'une recette** : Bouton "+" à côté du champ catégorie
- **Fonctionnalité** : Modal pour créer une nouvelle catégorie sans quitter le formulaire
- **Avantages** :
  - Gain de temps
  - Sélection automatique de la nouvelle catégorie
  - Interface intuitive

### 3. Widget de statistiques
- **Dashboard** : Affichage des statistiques des catégories
- **Informations** :
  - Total des catégories
  - Catégories actives
  - Catégories utilisées
  - Nombre total de recettes

## Utilisation

### Créer une nouvelle catégorie

#### Méthode 1 : Via le menu Catégories
1. Aller dans "Contenu" > "Catégories"
2. Cliquer sur "Nouvelle catégorie"
3. Remplir les champs :
   - **Nom** : Nom de la catégorie (obligatoire)
   - **Slug URL** : Généré automatiquement
   - **Description** : Description optionnelle
   - **Image** : Image représentative
   - **Couleur** : Couleur d'identification
   - **Icône** : Icône Heroicon
   - **Actif** : Activer/désactiver la catégorie

#### Méthode 2 : Depuis le formulaire de recette
1. Créer ou modifier une recette
2. Dans le champ "Catégorie", cliquer sur le bouton "+"
3. Remplir les informations de la nouvelle catégorie
4. Cliquer sur "Créer la catégorie"
5. La nouvelle catégorie est automatiquement sélectionnée

### Gérer les catégories existantes

#### Modifier une catégorie
1. Aller dans "Contenu" > "Catégories"
2. Cliquer sur l'action "Modifier" d'une catégorie
3. Modifier les champs souhaités
4. Sauvegarder

#### Activer/Désactiver une catégorie
- **Via la liste** : Utiliser le toggle "Actif"
- **Via l'édition** : Modifier le champ "Actif"
- **Actions en lot** : Sélectionner plusieurs catégories et utiliser les actions "Activer" ou "Désactiver"

#### Supprimer une catégorie
1. Aller dans "Contenu" > "Catégories"
2. Cliquer sur l'action "Supprimer" d'une catégorie
3. Confirmer la suppression

**⚠️ Attention** : La suppression d'une catégorie peut affecter les recettes qui l'utilisent.

## Structure des données

### Modèle Category
```php
- id : Identifiant unique
- name : Nom de la catégorie
- slug : Slug URL unique
- description : Description optionnelle
- image : Image représentative
- color : Couleur d'identification
- icon : Icône Heroicon
- is_active : Statut actif/inactif
- created_at : Date de création
- updated_at : Date de modification
```

### Relations
- **Category -> Recipe** : Une catégorie peut avoir plusieurs recettes
- **Recipe -> Category** : Une recette appartient à une catégorie

## API Endpoints

### Récupérer toutes les catégories actives
```
GET /api/v1/categories
```

### Créer une nouvelle catégorie
```
POST /api/v1/categories
{
    "name": "Nom de la catégorie",
    "slug": "slug-optionnel",
    "description": "Description optionnelle",
    "color": "#FF0000",
    "icon": "heroicon-o-cake"
}
```

### Vérifier si une catégorie existe
```
GET /api/v1/categories/check?name=Nom de la catégorie
```

## Bonnes pratiques

### Nommage des catégories
- Utiliser des noms clairs et descriptifs
- Éviter les doublons
- Respecter la hiérarchie logique

### Gestion des couleurs
- Utiliser des couleurs contrastées
- Maintenir une cohérence visuelle
- Éviter les couleurs trop similaires

### Icônes
- Utiliser les icônes Heroicon
- Choisir des icônes représentatives
- Maintenir une cohérence dans le style

### Activation/Désactivation
- Désactiver plutôt que supprimer pour préserver l'historique
- Réactiver les catégories populaires
- Nettoyer régulièrement les catégories inutilisées

## Dépannage

### Problème : Catégorie non visible dans la liste
- Vérifier que la catégorie est active (`is_active = true`)
- Vérifier les permissions d'accès
- Rafraîchir la page

### Problème : Erreur lors de la création
- Vérifier que le nom est unique
- Vérifier que le slug est unique
- Vérifier les champs obligatoires

### Problème : API non accessible
- Vérifier les routes API
- Vérifier les middlewares
- Vérifier les permissions CORS

## Support

Pour toute question ou problème :
1. Consulter les logs d'erreur
2. Vérifier la documentation Laravel/Filament
3. Contacter l'équipe de développement 