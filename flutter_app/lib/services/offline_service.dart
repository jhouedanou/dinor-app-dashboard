import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'cache_service.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final CacheService _cacheService = CacheService();
  
  // URLs de base pour l'API
  static const String _baseUrl = 'https://new.dinorapp.com/api/v1';

  // Charger les données avec gestion hors ligne
  Future<Map<String, dynamic>> loadDataWithOfflineSupport({
    required String endpoint,
    required String cacheKey,
    Map<String, String>? params,
    bool forceRefresh = false,
  }) async {
    try {
      // Vérifier si on est en ligne
      final isOnline = await _cacheService.isOnline();
      final isOfflineMode = await _cacheService.isOfflineMode();

      // Si on est hors ligne ou en mode hors ligne, utiliser le cache
      if (!isOnline || isOfflineMode) {
        print('📱 [OfflineService] Mode hors ligne - utilisation du cache');
        final cachedData = await _cacheService.getCachedData(cacheKey);
        if (cachedData != null) {
          return {
            'success': true,
            'data': cachedData,
            'fromCache': true,
            'offline': true,
          };
        } else {
          return {
            'success': false,
            'error': 'Aucune donnée disponible hors ligne',
            'offline': true,
          };
        }
      }

      // Si on est en ligne, essayer de charger depuis l'API
      try {
        final uri = Uri.parse(endpoint).replace(queryParameters: params);
        final response = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Mettre en cache les données
          await _cacheService.cacheData(cacheKey, data);
          
          return {
            'success': true,
            'data': data,
            'fromCache': false,
            'offline': false,
          };
        } else {
          throw Exception('Erreur API: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ [OfflineService] Erreur API: $e');
        
        // En cas d'erreur API, essayer le cache
        final cachedData = await _cacheService.getCachedData(cacheKey);
        if (cachedData != null) {
          return {
            'success': true,
            'data': cachedData,
            'fromCache': true,
            'offline': false,
            'apiError': e.toString(),
          };
        } else {
          return {
            'success': false,
            'error': 'Erreur de connexion et aucune donnée en cache',
            'offline': false,
          };
        }
      }
    } catch (e) {
      print('❌ [OfflineService] Erreur générale: $e');
      return {
        'success': false,
        'error': e.toString(),
        'offline': true,
      };
    }
  }

  // Charger les détails d'un élément avec gestion hors ligne
  Future<Map<String, dynamic>> loadDetailWithOfflineSupport({
    required String endpoint,
    required String cacheKey,
    required String id,
  }) async {
    try {
      final isOnline = await _cacheService.isOnline();
      final isOfflineMode = await _cacheService.isOfflineMode();

      // Si hors ligne, utiliser le cache
      if (!isOnline || isOfflineMode) {
        final cachedData = await _cacheService.getCachedData('$cacheKey:$id');
        if (cachedData != null) {
          return {
            'success': true,
            'data': cachedData,
            'fromCache': true,
            'offline': true,
          };
        } else {
          return {
            'success': false,
            'error': 'Détails non disponibles hors ligne',
            'offline': true,
          };
        }
      }

      // En ligne, charger depuis l'API
      try {
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final detailData = data['data'] ?? data;
          
          // Mettre en cache
          await _cacheService.cacheData('$cacheKey:$id', detailData);
          
          return {
            'success': true,
            'data': detailData,
            'fromCache': false,
            'offline': false,
          };
        } else {
          throw Exception('Erreur API: ${response.statusCode}');
        }
      } catch (e) {
        // En cas d'erreur, essayer le cache
        final cachedData = await _cacheService.getCachedData('$cacheKey:$id');
        if (cachedData != null) {
          return {
            'success': true,
            'data': cachedData,
            'fromCache': true,
            'offline': false,
            'apiError': e.toString(),
          };
        } else {
          return {
            'success': false,
            'error': 'Erreur de connexion et détails non en cache',
            'offline': false,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'offline': true,
      };
    }
  }

  // Synchroniser les données en arrière-plan
  Future<void> backgroundSync() async {
    try {
      if (!await _cacheService.isOnline()) {
        print('📡 [OfflineService] Pas de connexion pour la synchronisation');
        return;
      }

      print('🔄 [OfflineService] Synchronisation en arrière-plan...');
      await _cacheService.syncCache();
    } catch (e) {
      print('❌ [OfflineService] Erreur synchronisation: $e');
    }
  }

  // Afficher un indicateur de mode hors ligne
  Widget buildOfflineIndicator(bool isOffline) {
    if (!isOffline) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Text(
            'Mode hors ligne - Données en cache',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Afficher les statistiques du cache
  Future<Widget> buildCacheStats() async {
    final stats = await _cacheService.getCacheStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques du cache',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildStatRow('Recettes', stats['recipesCount']?.toString() ?? '0'),
          _buildStatRow('Astuces', stats['tipsCount']?.toString() ?? '0'),
          _buildStatRow('Événements', stats['eventsCount']?.toString() ?? '0'),
          _buildStatRow('Vidéos', stats['videosCount']?.toString() ?? '0'),
          _buildStatRow('Taille', stats['cacheSize']?.toString() ?? '0B'),
          _buildStatRow('Dernière mise à jour', 
            stats['lastUpdate'] != null 
              ? '${stats['lastUpdate'].day}/${stats['lastUpdate'].month}/${stats['lastUpdate'].year}'
              : 'Jamais'
          ),
          _buildStatRow('Mode hors ligne', 
            stats['offlineMode'] == true ? 'Activé' : 'Désactivé'
          ),
          _buildStatRow('Connectivité', 
            stats['isOnline'] == true ? 'En ligne' : 'Hors ligne'
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Gérer les actions hors ligne
  Future<bool> handleOfflineAction(String action, {Map<String, dynamic>? data}) async {
    try {
      switch (action) {
        case 'like':
          // Stocker l'action pour synchronisation ultérieure
          await _storeOfflineAction('like', data);
          return true;
        case 'favorite':
          await _storeOfflineAction('favorite', data);
          return true;
        case 'comment':
          await _storeOfflineAction('comment', data);
          return true;
        default:
          return false;
      }
    } catch (e) {
      print('❌ [OfflineService] Erreur action hors ligne: $e');
      return false;
    }
  }

  Future<void> _storeOfflineAction(String action, Map<String, dynamic>? data) async {
    try {
      final prefs = await _cacheService.getCachedData('offline_actions') ?? [];
      prefs.add({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _cacheService.cacheData('offline_actions', prefs);
      print('💾 [OfflineService] Action hors ligne stockée: $action');
    } catch (e) {
      print('❌ [OfflineService] Erreur stockage action: $e');
    }
  }

  // Synchroniser les actions hors ligne
  Future<void> syncOfflineActions() async {
    try {
      if (!await _cacheService.isOnline()) return;

      final actions = await _cacheService.getCachedData('offline_actions') ?? [];
      if (actions.isEmpty) return;

      print('🔄 [OfflineService] Synchronisation de ${actions.length} actions...');

      for (final action in actions) {
        try {
          // TODO: Implémenter la synchronisation avec l'API
          print('📤 [OfflineService] Synchronisation action: ${action['action']}');
        } catch (e) {
          print('❌ [OfflineService] Erreur sync action: $e');
        }
      }

      // Nettoyer les actions synchronisées
      await _cacheService.cacheData('offline_actions', []);
      print('✅ [OfflineService] Actions synchronisées');
    } catch (e) {
      print('❌ [OfflineService] Erreur sync actions: $e');
    }
  }

  // Précharger les contenus essentiels pour l'utilisation hors ligne
  Future<void> preloadEssentialContent() async {
    print('📦 [OfflineService] Préchargement du contenu essentiel...');
    
    try {
      // Précharger les recettes populaires
      await loadDataWithOfflineSupport(
        endpoint: '$_baseUrl/recipes',
        cacheKey: 'popular_recipes',
        params: {'limit': '20', 'popular': '1'},
      );
      
      // Précharger les astuces populaires
      await loadDataWithOfflineSupport(
        endpoint: '$_baseUrl/tips',
        cacheKey: 'popular_tips',
        params: {'limit': '20', 'popular': '1'},
      );
      
      // Précharger les événements récents
      await loadDataWithOfflineSupport(
        endpoint: '$_baseUrl/events',
        cacheKey: 'recent_events',
        params: {'limit': '10'},
      );
      
      // Précharger les vidéos DinorTV
      await loadDataWithOfflineSupport(
        endpoint: '$_baseUrl/dinor-tv',
        cacheKey: 'dinor_tv_videos',
        params: {'limit': '15'},
      );
      
      print('✅ [OfflineService] Préchargement terminé');
    } catch (e) {
      print('❌ [OfflineService] Erreur préchargement: $e');
    }
  }

  // Vérifier quels contenus sont disponibles hors ligne
  Future<Map<String, bool>> checkOfflineAvailability() async {
    final checks = <String, bool>{};
    
    final cacheKeys = [
      'popular_recipes',
      'popular_tips', 
      'recent_events',
      'dinor_tv_videos',
      'home_recipes',
      'home_tips',
      'home_events',
      'home_videos',
    ];
    
    for (final key in cacheKeys) {
      final data = await _cacheService.getCachedData(key);
      checks[key] = data != null;
    }
    
    return checks;
  }

  // Obtenir le statut de synchronisation
  Future<Map<String, dynamic>> getSyncStatus() async {
    final isOnline = await _cacheService.isOnline();
    final isOfflineMode = await _cacheService.isOfflineMode();
    final availability = await checkOfflineAvailability();
    
    final availableCount = availability.values.where((v) => v).length;
    final totalCount = availability.length;
    
    return {
      'isOnline': isOnline,
      'isOfflineMode': isOfflineMode,
      'availableContent': availableCount,
      'totalContent': totalCount,
      'syncPercentage': (availableCount / totalCount * 100).round(),
      'lastSync': await _cacheService.getCachedData('last_sync_time'),
    };
  }

  // Vider tout le cache hors ligne
  Future<void> clearOfflineCache() async {
    print('🧹 [OfflineService] Vidage du cache hors ligne...');
    
    final cacheKeys = [
      'popular_recipes',
      'popular_tips', 
      'recent_events',
      'dinor_tv_videos',
      'home_recipes',
      'home_tips',
      'home_events',
      'home_videos',
      'banners_home',
      'offline_actions',
    ];
    
    for (final key in cacheKeys) {
      await _cacheService.cacheData(key, null);
    }
    
    print('✅ [OfflineService] Cache vidé');
  }
} 