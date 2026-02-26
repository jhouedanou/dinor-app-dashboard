# 🔄 Navigation Swipeable - Guide d'Utilisation

## 📱 Vue d'ensemble

La navigation swipeable permet aux utilisateurs de naviguer entre les fiches de détail en swipant d'un côté à l'autre. Cette fonctionnalité améliore l'expérience utilisateur en permettant une navigation fluide et intuitive.

## ✨ Fonctionnalités

### 🎯 Navigation par Swipe
- **Swipe horizontal** : Navigation entre les fiches de détail
- **Indicateur de position** : Points en haut de l'écran
- **Boutons de navigation** : Précédent/Suivant en bas
- **Compteur de position** : "1 / 5" en bas

### 📊 Types de Contenu Supportés
- ✅ **Recettes** : Détails des recettes avec ingrédients et instructions
- ✅ **Astuces** : Conseils culinaires et techniques
- ✅ **Événements** : Événements culinaires et ateliers
- ✅ **Vidéos** : Contenu vidéo Dinor TV

### 🎨 Interface Utilisateur
- **Animations fluides** : Transitions douces entre les écrans
- **Indicateurs visuels** : Position claire dans la liste
- **Bouton fermer** : Retour facile à l'écran précédent
- **Design cohérent** : Interface unifiée

## 🚀 Utilisation

### 1. Navigation depuis l'Accueil

```dart
// Dans home_screen.dart
void _handleRecipeClick(Map<String, dynamic> recipe) {
  // Navigation vers le swipeable detail avec la liste des recettes
  SwipeableNavigationService.navigateFromCarousel(
    context: context,
    initialId: recipe['id'].toString(),
    contentType: 'recipe',
    carouselItems: _latestRecipes,
    carouselIndex: _latestRecipes.indexOf(recipe),
  );
}
```

### 2. Navigation depuis une Liste

```dart
// Navigation depuis une liste de recettes
SwipeableNavigationService.navigateFromList(
  context: context,
  initialId: '123',
  contentType: 'recipe',
  items: recipeList,
  initialIndex: 2, // Optionnel
);
```

### 3. Navigation depuis les Favoris

```dart
// Navigation depuis les favoris
SwipeableNavigationService.navigateFromFavorites(
  context: context,
  initialId: '456',
  contentType: 'tip',
  favoriteItems: favoriteTips,
);
```

### 4. Navigation depuis la Recherche

```dart
// Navigation depuis les résultats de recherche
SwipeableNavigationService.navigateFromSearch(
  context: context,
  initialId: '789',
  contentType: 'event',
  searchResults: searchResults,
  searchTerm: 'cuisine française',
);
```

## 📱 Interface Utilisateur

### Indicateur de Position (Dots)
```
● ○ ○ ○ ○
```
- **Point plein** : Position actuelle
- **Point vide** : Autres positions
- **Position** : En haut de l'écran

### Boutons de Navigation
```
[<] 1 / 5 [>]
```
- **Bouton gauche** : Élément précédent (masqué si premier)
- **Compteur** : Position actuelle / Total
- **Bouton droit** : Élément suivant (masqué si dernier)

### Bouton Fermer
```
[X]
```
- **Position** : En haut à droite
- **Action** : Retour à l'écran précédent

## 🎯 Gestes Supportés

### Swipe Horizontal
- **Swipe gauche** : Élément suivant
- **Swipe droite** : Élément précédent
- **Animation** : Transition fluide de 300ms

### Tap sur Boutons
- **Bouton précédent** : Navigation vers l'élément précédent
- **Bouton suivant** : Navigation vers l'élément suivant
- **Bouton fermer** : Fermer l'écran

## 📊 Analytics Tracking

### Événements Trackés
- **Navigation** : Changement d'écran
- **Contenu consulté** : Détails de l'élément
- **Méthode de navigation** : Swipe, bouton, etc.
- **Position dans la liste** : Index actuel

### Exemple d'Analytics
```dart
// Événement de navigation
AnalyticsTracker.trackNavigation(
  fromScreen: 'carousel_screen',
  toScreen: 'swipeable_detail_recipe',
  method: 'carousel_item',
);

// Consultation de contenu
AnalyticsService.logViewContent(
  contentType: 'recipe',
  contentId: '123',
  contentName: 'Poulet rôti',
  additionalParams: {
    'carousel_index': 2,
    'carousel_total': 4,
  },
);
```

## 🔧 Configuration

### Types de Contenu Supportés
```dart
enum ContentType {
  recipe,    // Recettes
  tip,       // Astuces
  event,     // Événements
  video,     // Vidéos
}
```

### Service de Navigation
```dart
class SwipeableNavigationService {
  // Navigation depuis carousel
  static Future<void> navigateFromCarousel({...})
  
  // Navigation depuis liste
  static Future<void> navigateFromList({...})
  
  // Navigation depuis favoris
  static Future<void> navigateFromFavorites({...})
  
  // Navigation depuis recherche
  static Future<void> navigateFromSearch({...})
}
```

## 🎨 Personnalisation

### Couleurs
```dart
// Couleurs par défaut
Colors.orange      // Boutons de navigation
Colors.black       // Indicateurs avec opacité
Colors.white       // Texte sur fond sombre
```

### Animations
```dart
// Durée des transitions
Duration(milliseconds: 300)

// Courbe d'animation
Curves.easeInOut
```

### Tailles
```dart
// Indicateurs de position
width: 8, height: 8

// Boutons de navigation
FloatingActionButton (56x56)

// Espacement
SizedBox(height: 16)
```

## 📱 Exemples d'Utilisation

### 1. Navigation depuis l'Accueil
```dart
// Clic sur une recette dans le carousel
SwipeableNavigationService.navigateFromCarousel(
  context: context,
  initialId: recipe['id'].toString(),
  contentType: 'recipe',
  carouselItems: latestRecipes,
  carouselIndex: index,
);
```

### 2. Navigation depuis une Liste
```dart
// Clic sur un élément dans une liste
SwipeableNavigationService.navigateFromList(
  context: context,
  initialId: item['id'].toString(),
  contentType: 'tip',
  items: tipList,
);
```

### 3. Navigation depuis les Favoris
```dart
// Clic sur un favori
SwipeableNavigationService.navigateFromFavorites(
  context: context,
  initialId: favorite['id'].toString(),
  contentType: 'event',
  favoriteItems: favoriteEvents,
);
```

### 4. Navigation depuis la Recherche
```dart
// Clic sur un résultat de recherche
SwipeableNavigationService.navigateFromSearch(
  context: context,
  initialId: result['id'].toString(),
  contentType: 'video',
  searchResults: searchResults,
  searchTerm: searchTerm,
);
```

## 🚀 Intégration dans l'Application

### 1. Écran d'Accueil
- ✅ Navigation depuis les carousels
- ✅ Support des 4 types de contenu
- ✅ Analytics tracking

### 2. Écrans de Liste
- ✅ Navigation depuis les listes
- ✅ Position initiale correcte
- ✅ Gestion des erreurs

### 3. Écrans de Recherche
- ✅ Navigation depuis les résultats
- ✅ Terme de recherche tracké
- ✅ Nombre de résultats

### 4. Écrans de Favoris
- ✅ Navigation depuis les favoris
- ✅ Liste des favoris
- ✅ Type de contenu détecté

## 📊 Métriques et Analytics

### Événements Trackés
- **Navigation** : Changement d'écran
- **Contenu** : Consultation de détails
- **Interaction** : Utilisation des boutons
- **Performance** : Temps de chargement

### Métriques Disponibles
- **Utilisation du swipe** : Fréquence d'utilisation
- **Navigation par boutons** : Préférence utilisateur
- **Temps par écran** : Engagement
- **Taux de fermeture** : Satisfaction

## 🔧 Dépannage

### Problèmes Courants

#### 1. Navigation ne fonctionne pas
```dart
// Vérifier que le contexte est correct
if (context.mounted) {
  SwipeableNavigationService.navigateFromCarousel(...);
}
```

#### 2. Liste vide
```dart
// Vérifier que la liste n'est pas vide
if (items.isNotEmpty) {
  SwipeableNavigationService.navigateFromList(...);
}
```

#### 3. Type de contenu non supporté
```dart
// Vérifier le type de contenu
if (SwipeableNavigationService.isContentTypeSupported(contentType)) {
  // Navigation
}
```

### Debug
```dart
// Activer les logs de debug
print('🔄 [SwipeableDetail] Navigation vers: $contentType');
print('🔄 [SwipeableDetail] Items: ${items.length}');
```

## 🎯 Bonnes Pratiques

### 1. Performance
- **Préchargement** : Charger les données à l'avance
- **Cache** : Mettre en cache les détails
- **Optimisation** : Limiter le nombre d'items

### 2. UX
- **Feedback visuel** : Indicateurs clairs
- **Gestes intuitifs** : Swipe naturel
- **Accessibilité** : Support des lecteurs d'écran

### 3. Analytics
- **Tracking complet** : Tous les événements
- **Métriques utiles** : Données actionnables
- **Performance** : Temps de chargement

## 🚀 Prochaines Étapes

### Améliorations Futures
1. **Animations personnalisées** : Transitions uniques
2. **Mode plein écran** : Immersion totale
3. **Partage** : Partage depuis le swipeable
4. **Favoris** : Ajout aux favoris depuis le swipeable

### Optimisations
1. **Performance** : Chargement lazy
2. **Mémoire** : Gestion du cache
3. **Réseau** : Optimisation des requêtes
4. **Batterie** : Réduction de la consommation

---

**Note** : La navigation swipeable améliore significativement l'expérience utilisateur en permettant une navigation fluide et intuitive entre les fiches de détail. 