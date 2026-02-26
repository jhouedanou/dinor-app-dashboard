# Système de Cache Hors Ligne - Dinor App

## Vue d'ensemble

Le système de cache hors ligne permet aux utilisateurs de consulter les contenus de l'application même sans connexion internet. Il utilise un système de cache intelligent qui synchronise automatiquement les données et les images.

## Architecture

### Services Principaux

#### 1. CacheService (`lib/services/cache_service.dart`)
- **Responsabilité** : Gestion du stockage local des données
- **Fonctionnalités** :
  - Cache des données JSON (recettes, astuces, événements, vidéos)
  - Cache des images avec gestion de l'espace disque
  - Gestion des versions de cache
  - Synchronisation avec l'API
  - Mode hors ligne forcé

#### 2. OfflineService (`lib/services/offline_service.dart`)
- **Responsabilité** : Logique métier pour le mode hors ligne
- **Fonctionnalités** :
  - Chargement intelligent des données (API + cache)
  - Gestion des erreurs de connexion
  - Indicateurs visuels de mode hors ligne
  - Actions hors ligne (likes, favoris, commentaires)

### Écrans

#### CacheManagementScreen (`lib/screens/cache_management_screen.dart`)
- **Fonctionnalités** :
  - Activation/désactivation du mode hors ligne
  - Visualisation des statistiques du cache
  - Synchronisation manuelle
  - Nettoyage du cache

## Fonctionnalités

### 1. Cache Automatique
- **Déclenchement** : Au démarrage de l'application
- **Données synchronisées** :
  - 50 dernières recettes
  - 50 dernières astuces
  - 50 derniers événements
  - 20 dernières vidéos
- **Images** : Cache automatique des images principales et galeries

### 2. Mode Hors Ligne
- **Activation** : Via l'écran de gestion du cache
- **Comportement** : Utilise uniquement les données en cache
- **Indicateurs** : SnackBar et badges visuels

### 3. Gestion Intelligente
- **Fallback** : En cas d'erreur API, utilisation du cache
- **Versioning** : Gestion des versions de cache
- **Expiration** : Cache valide 24h par défaut

## Utilisation

### Pour les Développeurs

#### Chargement de données avec support hors ligne
```dart
final result = await _offlineService.loadDataWithOfflineSupport(
  endpoint: 'https://new.dinorapp.com/api/v1/recipes',
  cacheKey: 'home_recipes',
  params: {'limit': '4'},
);

if (result['success']) {
  final data = result['data'];
  // Traitement des données
  if (result['offline'] == true) {
    // Afficher indicateur hors ligne
  }
}
```

#### Chargement de détails avec support hors ligne
```dart
final result = await _offlineService.loadDetailWithOfflineSupport(
  endpoint: 'https://new.dinorapp.com/api/v1/recipes/$id',
  cacheKey: 'recipe_detail',
  id: id,
);
```

#### Actions hors ligne
```dart
await _offlineService.handleOfflineAction('like', {
  'type': 'recipe',
  'id': recipeId,
});
```

### Pour les Utilisateurs

#### Activation du mode hors ligne
1. Ouvrir l'application
2. Cliquer sur l'icône de stockage dans l'en-tête
3. Activer le switch "Mode hors ligne"
4. Les données seront consultables hors ligne

#### Synchronisation manuelle
1. Aller dans l'écran de gestion du cache
2. Cliquer sur "Synchroniser le cache"
3. Attendre la confirmation

#### Nettoyage du cache
1. Aller dans l'écran de gestion du cache
2. Cliquer sur "Nettoyer le cache"
3. Confirmer l'action

## Configuration

### Paramètres de Cache
```dart
// Durée de validité du cache (24h)
final oneDay = 24 * 60 * 60 * 1000;

// Version du cache
static const int _currentCacheVersion = 1;

// Limites de synchronisation
recipes: 50 items
tips: 50 items
events: 50 items
videos: 20 items
```

### Gestion de l'Espace
- **Images** : Stockées dans le répertoire temporaire
- **Données** : Stockées dans SharedPreferences
- **Nettoyage** : Automatique lors de la synchronisation

## Indicateurs Visuels

### SnackBar Hors Ligne
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.wifi_off, color: Colors.white),
        Text('Mode hors ligne - Données en cache'),
      ],
    ),
    backgroundColor: Colors.orange,
  ),
);
```

### Badge Hors Ligne
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.wifi_off, color: Colors.orange[700]),
      Text('Mode hors ligne'),
    ],
  ),
);
```

## Statistiques

### Métriques Disponibles
- **Nombre d'éléments** : Par type de contenu
- **Taille du cache** : En bytes/KB/MB
- **Dernière mise à jour** : Timestamp
- **Mode hors ligne** : État actuel
- **Connectivité** : État de la connexion

### Affichage
```dart
Widget _buildCacheStats() {
  return Container(
    child: Column(
      children: [
        _buildStatRow('Recettes', stats['recipesCount']),
        _buildStatRow('Astuces', stats['tipsCount']),
        _buildStatRow('Événements', stats['eventsCount']),
        _buildStatRow('Vidéos', stats['videosCount']),
        _buildStatRow('Taille', stats['cacheSize']),
      ],
    ),
  );
}
```

## Maintenance

### Synchronisation Automatique
- **Déclenchement** : Au démarrage de l'application
- **Fréquence** : Une fois par session
- **Conditions** : Connexion internet disponible

### Nettoyage Automatique
- **Images** : Suppression lors du nettoyage du cache
- **Données** : Suppression lors du changement de version
- **Actions** : Synchronisation lors de la reconnexion

## Dépannage

### Problèmes Courants

#### Cache non synchronisé
- Vérifier la connexion internet
- Forcer la synchronisation manuelle
- Vérifier les logs de l'application

#### Images non chargées
- Vérifier l'espace disque disponible
- Nettoyer le cache
- Redémarrer l'application

#### Mode hors ligne non fonctionnel
- Vérifier que le cache contient des données
- Synchroniser le cache
- Vérifier les permissions de stockage

### Logs Utiles
```dart
// CacheService
print('💾 [CacheService] Données mises en cache: $key');
print('⚡ [CacheService] Données récupérées du cache: $key');
print('🔄 [CacheService] Synchronisation terminée');

// OfflineService
print('📱 [OfflineService] Mode hors ligne - utilisation du cache');
print('❌ [OfflineService] Erreur API: $e');
```

## Évolutions Futures

### Fonctionnalités Prévues
- **Synchronisation différée** : Actions hors ligne synchronisées automatiquement
- **Compression des images** : Optimisation de l'espace disque
- **Synchronisation sélective** : Choix des types de contenu à synchroniser
- **Notifications** : Alertes de synchronisation réussie/échouée

### Optimisations
- **Cache intelligent** : Préchargement basé sur l'usage
- **Compression des données** : Réduction de l'espace utilisé
- **Synchronisation incrémentale** : Mise à jour uniquement des changements 