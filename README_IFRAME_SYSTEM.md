# 🖼️ Système d'Iframe et Corrections de Déploiement

## Vue d'ensemble

Ce document décrit les nouvelles fonctionnalités ajoutées pour :
1. **Affichage des pages web dans des iframes** depuis l'administration Filament
2. **Correction du problème de migration** lors du déploiement sur Forge
3. **API des pages** pour l'application PWA

## 📋 Fonctionnalités Implémentées

### 1. Système d'Iframe pour les Pages Web

#### 🎯 Objectif
Permettre aux administrateurs de prévisualiser les pages web directement dans l'interface d'administration Filament avant de les publier dans l'application PWA.

#### ✨ Fonctionnalités
- **Prévisualisation en temps réel** des pages web dans un iframe
- **Contrôles de taille d'écran** (Desktop, Tablet, Mobile)
- **Bouton d'actualisation** de l'iframe
- **Redimensionnement manuel** du container
- **Gestion des erreurs** de chargement
- **Informations détaillées** sur la page

#### 🔧 Composants Ajoutés

**Nouveau contrôleur de page Filament :**
```
app/Filament/Resources/PageResource/Pages/ViewPageInIframe.php
```

**Nouvelle vue Blade :**
```
resources/views/filament/resources/page-resource/pages/view-page-in-iframe.blade.php
```

**Modifications dans PageResource :**
- Ajout du bouton "Prévisualiser" dans les actions de table
- Nouvelle route 'iframe' dans getPages()

#### 🚀 Utilisation

1. **Accéder à la liste des pages** dans l'administration Filament
2. **Cliquer sur "Prévisualiser"** pour une page avec une URL définie
3. **Utiliser les contrôles** pour ajuster la taille d'affichage
4. **Tester la page** avant publication

### 2. API des Pages pour PWA

#### 📡 Endpoints Disponibles

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/pages` | GET | Liste toutes les pages publiées |
| `/api/pages/menu` | GET | Pages pour le menu de navigation |
| `/api/pages/homepage` | GET | Page d'accueil |
| `/api/pages/latest` | GET | Dernière page créée |
| `/api/pages/{id}` | GET | Page spécifique |

#### 📄 Structure des Données

```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "À propos",
    "url": "https://example.com/about",
    "embed_url": "https://example.com/about?embed=1",
    "is_external": true,
    "is_published": true,
    "order": 1,
    "content": "...",
    "meta_title": "À propos - Mon App",
    "meta_description": "Page à propos de notre application",
    "created_at": "2025-01-07T10:00:00.000000Z",
    "updated_at": "2025-01-07T12:00:00.000000Z"
  }
}
```

### 3. Correction des Migrations

#### 🐛 Problème Résolu
Erreur lors du déploiement : `Duplicate column name 'rank'` dans la table `leaderboards`

#### ✅ Solution Implémentée

**Migration corrigée :**
```
database/migrations/2025_07_07_174154_add_rank_column_to_leaderboards_table.php
```

La migration vérifie maintenant l'existence des colonnes avant de les ajouter :

```php
if (!Schema::hasColumn('leaderboards', 'rank')) {
    $table->integer('rank')->nullable()->after('accuracy_percentage');
}

if (!Schema::hasColumn('leaderboards', 'correct_predictions')) {
    $table->integer('correct_predictions')->default(0)->after('correct_winners');
}
```

#### 🛠️ Scripts de Correction

**Script de correction rapide :**
```bash
./fix-migration-rank-column.sh
```

**Script de déploiement complet :**
```bash
./deploy-forge-with-fixes.sh
```

## 🚀 Déploiement sur Forge

### Étapes de Déploiement

1. **Exécuter le script de déploiement :**
   ```bash
   ./deploy-forge-with-fixes.sh
   ```

2. **Le script effectue automatiquement :**
   - Récupération du code depuis Git
   - Installation des dépendances Composer
   - Correction des migrations problématiques
   - Optimisation des caches Laravel
   - Construction des assets (si npm disponible)
   - Vérifications finales
   - Configuration des permissions

### Vérifications Post-Déploiement

✅ **Migrations appliquées** : `php artisan migrate:status`
✅ **API fonctionnelle** : Tester `/api/pages`
✅ **Filament accessible** : Accéder à l'administration
✅ **Iframe opérationnel** : Tester la prévisualisation des pages

## 📱 Intégration PWA

### Affichage des Pages dans l'App Mobile

Les pages sont automatiquement disponibles dans l'application PWA via l'API. L'application mobile peut :

1. **Récupérer la liste des pages** via `/api/pages/menu`
2. **Afficher les pages dans des webviews/iframes** en utilisant les URLs
3. **Gérer le cache** des pages pour un accès hors-ligne
4. **Naviguer** entre les pages via le menu

### Configuration Recommandée

```javascript
// Exemple d'intégration dans l'app PWA
const loadPages = async () => {
  try {
    const response = await fetch('/api/pages/menu');
    const { data } = await response.json();
    
    // Créer les éléments de menu
    data.forEach(page => {
      if (page.is_published) {
        addMenuItems({
          title: page.title,
          url: page.url,
          order: page.order
        });
      }
    });
  } catch (error) {
    console.error('Erreur lors du chargement des pages:', error);
  }
};
```

## 🔧 Maintenance

### Commandes Utiles

```bash
# Vérifier l'état des migrations
php artisan migrate:status

# Vider les caches
php artisan cache:clear
php artisan view:clear
php artisan config:clear

# Optimiser pour la production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Tester l'API
curl -s http://localhost/api/pages | jq
```

### Logs et Debugging

- **Logs Laravel** : `storage/logs/laravel.log`
- **Logs de migration** : Voir la sortie de `php artisan migrate:status`
- **Erreurs iframe** : Console développeur du navigateur

## 🚨 Troubleshooting

### Problèmes Courants

#### 1. Iframe ne s'affiche pas
**Cause :** Politique de sécurité X-Frame-Options
**Solution :** Vérifier les en-têtes du site cible ou utiliser le bouton "Ouvrir dans un nouvel onglet"

#### 2. Migration échoue toujours
**Cause :** Base de données dans un état incohérent
**Solution :** 
```bash
php artisan migrate:rollback --step=5
php artisan migrate --force
```

#### 3. API non accessible
**Cause :** Routes non mises en cache ou erreur de configuration
**Solution :**
```bash
php artisan route:clear
php artisan route:cache
```

## 📞 Support

Pour toute question ou problème :
1. Vérifier les logs dans `storage/logs/`
2. Exécuter les scripts de diagnostic
3. Consulter la documentation Laravel et Filament

---

*Dernière mise à jour : Janvier 2025* 