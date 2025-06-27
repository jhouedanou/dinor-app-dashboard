# Guide des Catégories d'Événements 📅

## Vue d'ensemble

Ce guide détaille le nouveau système de catégories spécifiques aux événements créé pour résoudre le problème d'affichage des catégories dans l'administration Filament.

## Problème résolu

**Avant :** Dans Filament, lors de l'édition d'un événement, le champ catégorie affichait uniquement "1" au lieu du nom de la catégorie.

**Après :** Système de catégories dédié aux événements avec affichage correct, création inline, et intégration PWA complète.

## Structure du système

### 1. Modèle EventCategory

- **Table :** `event_categories`
- **Champs :** 
  - `id`, `name`, `slug`, `description`
  - `image`, `color`, `icon`
  - `is_active`, `created_at`, `updated_at`

### 2. Relation avec les événements

- **Champ ajouté :** `event_category_id` dans la table `events`
- **Relation :** `Event::eventCategory()` (belongsTo)
- **Relation inverse :** `EventCategory::events()` (hasMany)

## Installation

### Exécution automatique

```bash
./setup-event-categories.sh
```

### Exécution manuelle

1. **Migrations :**
```bash
php artisan migrate --path=database/migrations/2025_01_01_000000_create_event_categories_table.php
php artisan migrate --path=database/migrations/2025_01_01_000001_add_event_category_id_to_events_table.php
```

2. **Seeders :**
```bash
php artisan db:seed --class=EventCategorySeeder
```

3. **Cache :**
```bash
php artisan cache:clear
php artisan config:clear
```

## Catégories par défaut

Le système crée automatiquement 10 catégories d'événements :

1. **Séminaire** 🎓 - Événements de formation et d'apprentissage culinaire
2. **Conférence** 🎤 - Conférences sur la nutrition et la gastronomie
3. **Atelier** 🔧 - Ateliers pratiques de cuisine ivoirienne
4. **Cours de cuisine** 📚 - Cours d'apprentissage des techniques culinaires
5. **Dégustation** ❤️ - Événements de dégustation de plats traditionnels
6. **Festival** ✨ - Festivals culinaires et célébrations gastronomiques
7. **Concours** 🏆 - Compétitions et concours culinaires
8. **Networking** 👥 - Événements de réseautage pour professionnels
9. **Exposition** 🏪 - Expositions de produits et matériels culinaires
10. **Fête** 🎁 - Événements festifs et célébrations communautaires

## Interface d'administration

### Gestion des catégories

**Navigation :** Configuration > Catégories d'événements

**Fonctionnalités :**
- ✅ Liste avec compteur d'événements par catégorie
- ✅ Création/modification avec preview couleur
- ✅ Gestion des icônes et images
- ✅ Statut actif/inactif

### Édition des événements

**Améliorations :**
- ✅ Sélecteur avec noms de catégories (plus de "1")
- ✅ Création inline de nouvelles catégories
- ✅ Affichage avec couleurs dans les badges
- ✅ Filtre par catégorie dans la liste

## API Endpoints

### Catégories d'événements

```http
GET /api/event-categories
# Retourne toutes les catégories actives

GET /api/event-categories/{id}
# Détails d'une catégorie avec ses événements

POST /api/event-categories
# Créer une nouvelle catégorie

POST /api/event-categories/check-exists
# Vérifier si une catégorie existe
```

### Événements avec catégories

```http
GET /api/events?event_category_id=1
# Filtrer les événements par catégorie

GET /api/events
# Les événements incluent maintenant eventCategory
```

### Exemple de réponse API

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Atelier Attiéké",
      "eventCategory": {
        "id": 3,
        "name": "Atelier",
        "slug": "atelier",
        "color": "#f59e0b",
        "icon": "heroicon-o-wrench-screwdriver"
      }
    }
  ]
}
```

## Intégration PWA

### Composables

```javascript
// Gestion des catégories
import { useEventCategories } from '@/composables/useEventCategories'

// Filtrage des événements
import { useEventsPagination } from '@/composables/useEvents'
const { filterByEventCategory } = useEventsPagination()
```

### Composant de filtre

```vue
<EventCategoryFilter 
  :selected-category-id="selectedCategory"
  @category-selected="filterByEventCategory"
/>
```

## Migration des données existantes

Le script permet de migrer automatiquement les événements existants :

1. Recherche des correspondances de noms entre anciennes et nouvelles catégories
2. Association automatique quand une correspondance est trouvée
3. Attribution à "Événement général" pour les cas non correspondants

## Tests et vérification

### Vérifier l'installation

```bash
# Tester l'API
curl http://your-domain/api/event-categories

# Vérifier les données
php artisan tinker
>>> App\Models\EventCategory::count()
>>> App\Models\Event::with('eventCategory')->first()
```

### Interface Filament

1. Aller dans **Configuration > Catégories d'événements**
2. Vérifier que les 10 catégories sont présentes
3. Éditer un événement et vérifier le sélecteur de catégorie
4. Tester la création inline d'une nouvelle catégorie

## Personnalisation

### Ajouter des catégories

```php
// Dans le seeder ou via l'interface
EventCategory::create([
    'name' => 'Ma Catégorie',
    'slug' => 'ma-categorie',
    'description' => 'Description de ma catégorie',
    'color' => '#ff6b6b',
    'icon' => 'heroicon-o-star',
    'is_active' => true
]);
```

### Modifier les couleurs et icônes

Les couleurs et icônes peuvent être modifiées :
- Via l'interface d'administration
- Directement dans le seeder
- Via l'API

## Maintenance

### Cache

Le système utilise le cache pour optimiser les performances :
- Cache API : 10 minutes
- Invalidation automatique lors des modifications

### Nettoyage

```bash
# Vider les caches
php artisan cache:clear
php artisan config:clear

# Rebuilder la PWA si nécessaire
./rebuild-pwa.sh
```

## Support

En cas de problème :

1. Vérifier les logs Laravel
2. Tester les endpoints API
3. Vérifier les relations dans Tinker
4. Contrôler la cohérence des données

---

**Créé le :** $(date)
**Version :** 1.0
**Auteur :** Assistant IA 