# Guide de Gestion des Tournois - Dinor App

## Table des Matières
- [Vue d'ensemble](#vue-densemble)
- [Création d'un tournoi](#création-dun-tournoi)
- [Gestion des statuts](#gestion-des-statuts)
- [Gestion des participants](#gestion-des-participants)
- [Gestion des pronostics](#gestion-des-pronostics)
- [Matchs et résultats](#matchs-et-résultats)
- [Classement et récompenses](#classement-et-récompenses)
- [Dépannage](#dépannage)

## Vue d'ensemble

Le système de tournois de Dinor App permet aux utilisateurs de créer, gérer et participer à des tournois de pronostics sportifs. Le système est conçu pour être flexible et peut gérer différents types de tournois.

### Composants principaux

1. **Tournois** - Conteneur principal
2. **Participants** - Utilisateurs inscrits au tournoi
3. **Matchs** - Événements sportifs associés au tournoi
4. **Pronostics** - Prédictions des utilisateurs sur les matchs
5. **Classement** - Système de points et de rang

## Création d'un tournoi

### Étapes de création

1. **Accédez à l'interface d'administration**
   - Connectez-vous à `/admin`
   - Naviguez vers "Tournois"

2. **Créer un nouveau tournoi**
   - Cliquez sur "Créer un tournoi"
   - Remplissez les informations requises :

### Informations générales

| Champ | Description | Requis |
|-------|-------------|---------|
| **Nom du tournoi** | Nom descriptif du tournoi | ✅ |
| **Description** | Description détaillée du tournoi | ❌ |
| **Image** | Image de couverture du tournoi | ❌ |

### Dates et délais

| Champ | Description | Requis |
|-------|-------------|---------|
| **Date de début** | Date de début du tournoi | ✅ |
| **Date de fin** | Date de fin du tournoi | ✅ |
| **Début des inscriptions** | Quand les inscriptions commencent | ❌ |
| **Fin des inscriptions** | Quand les inscriptions se terminent | ❌ |

### Configuration

| Champ | Description | Requis |
|-------|-------------|---------|
| **Statut** | Statut actuel du tournoi | ✅ |
| **Nombre max de participants** | Limite de participants | ❌ |
| **Mis en avant** | Afficher en tant que tournoi vedette | ❌ |
| **Public** | Visible pour tous les utilisateurs | ❌ |

## Gestion des statuts

### Statuts disponibles

1. **À venir** (`upcoming`)
   - Tournoi créé mais pas encore commencé
   - Les inscriptions peuvent être fermées

2. **Inscriptions ouvertes** (`registration_open`)
   - Les utilisateurs peuvent s'inscrire
   - Statut requis pour permettre les inscriptions

3. **Inscriptions fermées** (`registration_closed`)
   - Plus d'inscriptions possibles
   - Tournoi en attente de début

4. **En cours** (`active`)
   - Tournoi en cours d'exécution
   - Matchs en cours, pronostics possibles

5. **Terminé** (`finished`)
   - Tournoi terminé
   - Classement final disponible

6. **Annulé** (`cancelled`)
   - Tournoi annulé
   - Aucune activité possible

### Transitions de statut recommandées

```
upcoming → registration_open → registration_closed → active → finished
                                      ↓
                                  cancelled
```

## Gestion des participants

### Inscription des participants

Les utilisateurs peuvent s'inscrire automatiquement si :
- Le tournoi a le statut `registration_open`
- La date actuelle est entre `registration_start` et `registration_end`
- Le nombre maximum de participants n'est pas atteint
- L'utilisateur n'est pas déjà inscrit

### Vérification des inscriptions

```php
// Vérifier si un utilisateur peut s'inscrire
$canRegister = $tournament->canUserRegister($user);

// Inscrire un utilisateur
$participant = $tournament->registerUser($user);
```

### Gestion manuelle des participants

Vous pouvez également gérer les participants manuellement :

1. **Ajouter un participant**
   - Accédez au tournoi
   - Section "Participants"
   - Ajouter manuellement un utilisateur

2. **Supprimer un participant**
   - Attention : supprime aussi tous ses pronostics
   - Ne faire que si nécessaire

## Gestion des pronostics

### Système de pronostics

Les pronostics sont liés aux matchs du tournoi :

1. **Création de matchs**
   - Créez des matchs associés au tournoi
   - Définissez les équipes et dates

2. **Prédictions des utilisateurs**
   - Les participants peuvent faire des pronostics
   - Différents types de pronostics possibles

3. **Calcul des points**
   - Points attribués selon la précision
   - Système de bonus pour les scores exacts

### Types de pronostics

- **Résultat simple** : Victoire/Défaite/Égalité
- **Score exact** : Prédiction du score final
- **Handicap** : Prédiction avec handicap

## Matchs et résultats

### Création de matchs

1. **Informations du match**
   - Équipes participantes
   - Date et heure
   - Stade/lieu

2. **Liaison au tournoi**
   - Associer le match au tournoi
   - Définir les coefficients de points

### Saisie des résultats

1. **Résultats finaux**
   - Score final
   - Résultat (1/X/2)
   - Événements spéciaux

2. **Calcul automatique**
   - Les points sont calculés automatiquement
   - Mise à jour du classement

## Classement et récompenses

### Système de points

Le classement est basé sur :

1. **Points totaux** - Somme de tous les points
2. **Nombre de pronostics** - Nombre total de prédictions
3. **Précision** - Pourcentage de réussite
4. **Scores exacts** - Nombre de scores parfaits

### Calcul du classement

```php
// Récupérer le classement
$leaderboard = $tournament->getLeaderboard();

// Statistiques d'un utilisateur
$userStats = $tournament->getUserStats($user);
```

### Récompenses

Les récompenses peuvent être configurées :
- Prix en argent
- Trophées virtuels
- Badges spéciaux
- Mentions dans l'app

## Dépannage

### Problèmes courants

#### 1. Utilisateur ne peut pas s'inscrire

**Vérifications :**
- [ ] Statut du tournoi = `registration_open`
- [ ] Date actuelle dans la période d'inscription
- [ ] Nombre max de participants pas atteint
- [ ] Utilisateur pas déjà inscrit

**Solution :**
```php
// Vérifier manuellement
$tournament = Tournament::find($id);
$user = User::find($userId);
dd($tournament->canUserRegister($user));
```

#### 2. Pronostics non comptabilisés

**Vérifications :**
- [ ] Match lié au tournoi
- [ ] Résultat du match saisi
- [ ] Pronostic fait avant la date limite
- [ ] Utilisateur inscrit au tournoi

#### 3. Classement incorrect

**Solutions :**
- Recalculer le classement manuellement
- Vérifier les paramètres de points
- Contrôler les données des matchs

### Commandes utiles

```bash
# Recalculer tous les classements
php artisan tournament:recalculate-leaderboard

# Vérifier l'intégrité des données
php artisan tournament:check-integrity

# Nettoyer les données obsolètes
php artisan tournament:cleanup
```

### Logs et monitoring

Les logs des tournois se trouvent dans :
- `storage/logs/tournaments.log`
- `storage/logs/laravel.log`

### Base de données

Tables principales :
- `tournaments`
- `tournament_participants`
- `tournament_leaderboard`
- `football_matches`
- `predictions`

## Conseils et bonnes pratiques

### Avant le lancement

1. **Testez le tournoi** avec des données factices
2. **Vérifiez les permissions** des utilisateurs
3. **Configurez les notifications** pour les participants
4. **Préparez les règles** du tournoi

### Pendant le tournoi

1. **Surveillez les inscriptions** régulièrement
2. **Mettez à jour les résultats** rapidement
3. **Répondez aux questions** des participants
4. **Surveillez les performances** de l'application

### Après le tournoi

1. **Annoncez les résultats** officiels
2. **Distribuez les récompenses** si applicable
3. **Archivez les données** du tournoi
4. **Collectez les retours** des participants

## Support technique

### Contacts

- **Développeur principal** : [email]
- **Support technique** : [email]
- **Documentation** : [URL]

### Ressources additionnelles

- [API Documentation](./api-docs.md)
- [Database Schema](./database-schema.md)
- [Troubleshooting Guide](./troubleshooting.md)

---

*Guide mis à jour le : $(date)*
*Version : 1.0*