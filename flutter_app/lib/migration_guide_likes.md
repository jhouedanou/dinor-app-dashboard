# Guide de Migration - Système de Likes Amélioré

## 📋 Résumé des Améliorations

✅ **Base de données locale complète** - Stockage des likes, favoris, état de connexion  
✅ **Panneau de debug masqué** - Likes cachés dans le profil  
✅ **Système de synchronisation en temps réel** - Compteurs exacts depuis l'API  
✅ **Service de likes amélioré** - Synchronisation automatique, cache intelligent  
✅ **Composant LikeButton avancé** - Animations, feedback, gestion d'erreurs  

## 🔄 Migration des Composants

### Ancien LikeButton → EnhancedLikeButton

```dart
// AVANT (ancien système)
import '../components/common/like_button.dart';

LikeButton(
  type: 'recipe',
  itemId: recipe['id'].toString(),
  initialLiked: recipe['is_liked'] ?? false,
  initialCount: recipe['likes_count'] ?? 0,
)

// APRÈS (nouveau système)
import '../components/common/enhanced_like_button.dart';

EnhancedLikeButton(
  type: 'recipe',
  itemId: recipe['id'].toString(),
  initialLiked: recipe['is_liked'] ?? false,
  initialCount: recipe['likes_count'] ?? 0,
  autoFetch: true, // Récupère automatiquement les compteurs exacts
  onAuthRequired: () => setState(() => _showAuthModal = true),
)
```

## 🚀 Nouveaux Services Disponibles

### 1. EnhancedLikesService
```dart
import '../services/enhanced_likes_service.dart';

// Dans votre widget ConsumerWidget
final likesState = ref.watch(enhancedLikesProvider);

// Vérifier si un contenu est liké
bool isLiked = likesState.isLiked('recipe', '123');

// Obtenir le nombre exact de likes
int count = likesState.getLikeCount('recipe', '123');

// Synchroniser avec le serveur
await ref.read(enhancedLikesProvider.notifier).syncWithServer();
```

### 2. ContentSyncService
```dart
import '../services/content_sync_service.dart';

// Dans votre initState ou onRefresh
final syncService = ref.read(contentSyncServiceProvider);

// Synchronisation forcée (pull-to-refresh)
await syncService.forceSyncAll();

// Synchroniser un contenu spécifique
await syncService.syncSpecificContent('recipe', '123');
```

## 📱 Utilisation dans les Écrans

### Exemple d'intégration complète

```dart
class SimpleRecipeDetailScreen extends ConsumerStatefulWidget {
  // ... existing code

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(enhancedLikesProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Synchroniser les données
          await ref.read(syncStatusProvider.notifier).forceSync();
          await _loadRecipeDetail();
        },
        child: Column(
          children: [
            // Contenu existant...
            
            // Actions avec le nouveau système
            Row(
              children: [
                EnhancedLikeButton(
                  type: 'recipe',
                  itemId: recipe['id'].toString(),
                  initialLiked: recipe['is_liked'] ?? false,
                  initialCount: recipe['likes_count'] ?? 0,
                  size: 'large',
                  variant: 'filled',
                  onAuthRequired: () => setState(() => _showAuthModal = true),
                ),
                
                // Indicateur de synchronisation
                if (syncStatus.isSyncing)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Fonctionnalités Clés

### 1. Synchronisation Automatique
- ✅ Synchronisation toutes les 2 minutes
- ✅ Retry automatique avec backoff exponentiel
- ✅ Cache intelligent avec invalidation

### 2. Compteurs Exacts
- ✅ Récupération depuis l'API en temps réel
- ✅ Mise à jour immédiate lors des interactions
- ✅ Sauvegarde locale pour performance

### 3. Gestion d'Authentification
- ✅ Détection automatique des erreurs 401
- ✅ Callback `onAuthRequired` pour modal d'auth
- ✅ Retry automatique après connexion

### 4. Feedback Utilisateur
- ✅ Animations smooth lors des interactions
- ✅ Messages de confirmation
- ✅ Indicateurs de chargement
- ✅ Gestion d'erreurs avec retry

## 🔧 Configuration des Providers

Ajouter dans votre `main.dart` ou widget racine :

```dart
import 'services/content_sync_service.dart';
import 'services/enhanced_likes_service.dart';

// Les providers sont automatiquement configurés
// La synchronisation démarre automatiquement
```

## 📊 APIs Disponibles

### Endpoints utilisés
- `GET /api/v1/user/likes/detailed` - Likes détaillés de l'utilisateur
- `GET /api/v1/content/{type}/{id}/likes` - Likes d'un contenu spécifique  
- `POST /api/v1/likes/toggle` - Toggle un like
- `GET /api/v1/content/likes/bulk` - Compteurs en masse
- `GET /api/v1/content/metadata/updated` - Métadonnées mises à jour

## 🎨 Variants du LikeButton

```dart
// Minimal (sans bordure)
EnhancedLikeButton(variant: 'minimal')

// Standard (avec bordure)
EnhancedLikeButton(variant: 'standard')

// Filled (arrière-plan coloré)
EnhancedLikeButton(variant: 'filled')

// Tailles disponibles
EnhancedLikeButton(size: 'small')   // 16px icon
EnhancedLikeButton(size: 'medium')  // 20px icon  
EnhancedLikeButton(size: 'large')   // 26px icon
```

## 🚀 Migration Étape par Étape

1. **Remplacer les imports**
   ```dart
   // Remplacer
   import '../components/common/like_button.dart';
   // Par
   import '../components/common/enhanced_like_button.dart';
   ```

2. **Mettre à jour les widgets**
   ```dart
   // Remplacer LikeButton par EnhancedLikeButton
   // Ajouter autoFetch: true pour les compteurs exacts
   ```

3. **Ajouter le RefreshIndicator**
   ```dart
   RefreshIndicator(
     onRefresh: () => ref.read(syncStatusProvider.notifier).forceSync(),
     child: // votre contenu
   )
   ```

4. **Tester la synchronisation**
   - Vérifier que les compteurs se mettent à jour automatiquement
   - Tester le pull-to-refresh  
   - Vérifier la persistance hors ligne

## ✨ Résultat Final

- 🎯 **Compteurs exacts** synchronisés avec l'API
- ⚡ **Performance optimisée** avec cache intelligent  
- 🔄 **Synchronisation automatique** en arrière-plan
- 💫 **Interface fluide** avec animations et feedback
- 🛡️ **Robustesse** avec gestion d'erreurs et retry
- 📱 **Expérience utilisateur** améliorée

Le système est maintenant prêt pour une utilisation en production avec une synchronisation fiable des likes en temps réel !