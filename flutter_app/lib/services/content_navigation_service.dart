/**
 * CONTENT_NAVIGATION_SERVICE.DART - SERVICE DE NAVIGATION ENTRE CONTENUS
 * - Récupération des contenus précédent/suivant
 * - Cache des listes pour éviter les requêtes multiples
 * - Support pour tous les types de contenu
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

class ContentNavigationService {
  final ApiService _apiService;
  
  // Cache des listes de contenu par type
  Map<String, List<dynamic>> _contentCache = {};
  
  ContentNavigationService(this._apiService);

  /// Récupère les informations de navigation pour un contenu donné
  Future<Map<String, dynamic>> getNavigationInfo(String contentType, String currentId) async {
    try {
      // Récupérer la liste des contenus depuis le cache ou l'API
      final contents = await _getContentList(contentType);
      
      // Trouver l'index du contenu actuel
      final currentIndex = contents.indexWhere((content) => content['id'].toString() == currentId);
      
      if (currentIndex == -1) {
        return {
          'previousId': null,
          'nextId': null,
          'previousTitle': null,
          'nextTitle': null,
        };
      }
      
      // Calculer précédent et suivant
      final previousIndex = currentIndex > 0 ? currentIndex - 1 : null;
      final nextIndex = currentIndex < contents.length - 1 ? currentIndex + 1 : null;
      
      return {
        'previousId': previousIndex != null ? contents[previousIndex]['id'].toString() : null,
        'nextId': nextIndex != null ? contents[nextIndex]['id'].toString() : null,
        'previousTitle': previousIndex != null ? contents[previousIndex]['title'] : null,
        'nextTitle': nextIndex != null ? contents[nextIndex]['title'] : null,
      };
    } catch (error) {
      print('❌ [ContentNavigation] Erreur récupération navigation: $error');
      return {
        'previousId': null,
        'nextId': null,
        'previousTitle': null,
        'nextTitle': null,
      };
    }
  }

  /// Récupère la liste des contenus depuis le cache ou l'API
  Future<List<dynamic>> _getContentList(String contentType) async {
    // Vérifier le cache
    if (_contentCache.containsKey(contentType)) {
      return _contentCache[contentType]!;
    }

    // Déterminer l'endpoint selon le type
    String endpoint;
    switch (contentType) {
      case 'recipe':
        endpoint = '/recipes';
        break;
      case 'tip':
        endpoint = '/tips';
        break;
      case 'event':
        endpoint = '/events';
        break;
      case 'video':
        endpoint = '/dinor-tv';
        break;
      default:
        throw Exception('Type de contenu non supporté: $contentType');
    }

    // Récupérer depuis l'API
    final data = await _apiService.get(endpoint, params: {
      'limit': '100', // Récupérer suffisamment d'éléments pour la navigation
      'sort_by': 'created_at',
      'sort_order': 'desc',
    });

    if (data['success'] == true) {
      final contents = (data['data'] as List?) ?? [];
      _contentCache[contentType] = contents;
      return contents;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors du chargement des contenus');
    }
  }

  /// Navigation vers le contenu précédent
  void navigateToPrevious(String contentType, String previousId) {
    _navigateToContent(contentType, previousId);
  }

  /// Navigation vers le contenu suivant
  void navigateToNext(String contentType, String nextId) {
    _navigateToContent(contentType, nextId);
  }

  /// Navigation vers un contenu spécifique
  void _navigateToContent(String contentType, String contentId) {
    // TODO: Implémenter la navigation selon le type de contenu
    switch (contentType) {
      case 'recipe':
        // NavigationService.goToRecipeDetail(contentId);
        print('🍳 Navigation vers recette: $contentId');
        break;
      case 'tip':
        // NavigationService.goToTipDetail(contentId);
        print('💡 Navigation vers astuce: $contentId');
        break;
      case 'event':
        // NavigationService.goToEventDetail(contentId);
        print('📅 Navigation vers événement: $contentId');
        break;
      case 'video':
        // NavigationService.goToVideoDetail(contentId);
        print('🎬 Navigation vers vidéo: $contentId');
        break;
    }
  }

  /// Nettoyer le cache
  void clearCache() {
    _contentCache.clear();
  }

  /// Nettoyer le cache pour un type spécifique
  void clearCacheForType(String contentType) {
    _contentCache.remove(contentType);
  }
}

// Provider pour le service de navigation de contenu
final contentNavigationServiceProvider = Provider<ContentNavigationService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ContentNavigationService(apiService);
});