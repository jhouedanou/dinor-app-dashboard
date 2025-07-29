/**
 * ENHANCED_LIKES_SERVICE.DART - SERVICE DE LIKES AVEC SYNCHRONISATION EN TEMPS RÉEL
 * 
 * FONCTIONNALITÉS :
 * - Récupération des compteurs exacts depuis l'API
 * - Synchronisation automatique des likes
 * - Cache intelligent avec invalidation
 * - Mise à jour en temps réel des compteurs
 * - Gestion des erreurs et retry automatique
 */

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'local_database_service.dart';

class ContentLikeData {
  final String type;
  final String itemId;
  final bool isLiked;
  final int likesCount;
  final DateTime lastUpdated;

  ContentLikeData({
    required this.type,
    required this.itemId,
    required this.isLiked,
    required this.likesCount,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  String get key => '${type}_$itemId';

  Map<String, dynamic> toJson() => {
        'type': type,
        'itemId': itemId,
        'isLiked': isLiked,
        'likesCount': likesCount,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory ContentLikeData.fromJson(Map<String, dynamic> json) {
    return ContentLikeData(
      type: json['type'],
      itemId: json['itemId'],
      isLiked: json['isLiked'],
      likesCount: json['likesCount'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class EnhancedLikesState {
  final Map<String, ContentLikeData> likes;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final DateTime? lastSync;

  const EnhancedLikesState({
    this.likes = const {},
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.lastSync,
  });

  EnhancedLikesState copyWith({
    Map<String, ContentLikeData>? likes,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    DateTime? lastSync,
  }) {
    return EnhancedLikesState(
      likes: likes ?? this.likes,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  bool isLiked(String type, String itemId) {
    final key = '${type}_$itemId';
    return likes[key]?.isLiked ?? false;
  }

  int getLikeCount(String type, String itemId) {
    final key = '${type}_$itemId';
    return likes[key]?.likesCount ?? 0;
  }
}

class EnhancedLikesService extends StateNotifier<EnhancedLikesState> {
  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  final LocalDatabaseService _localDB;

  EnhancedLikesService(this._localDB) : super(const EnhancedLikesState()) {
    _loadFromCache();
  }

  // Charger depuis le cache local
  Future<void> _loadFromCache() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final likes = await _localDB.getUserLikes();
      final counts = await _localDB.getLikeCounts();
      
      final Map<String, ContentLikeData> likeData = {};
      
      // Combiner les likes et compteurs
      for (final entry in likes.entries) {
        final parts = entry.key.split('_');
        if (parts.length >= 2) {
          final type = parts[0];
          final itemId = parts.sublist(1).join('_');
          
          likeData[entry.key] = ContentLikeData(
            type: type,
            itemId: itemId,
            isLiked: entry.value,
            likesCount: counts[entry.key] ?? 0,
          );
        }
      }
      
      state = state.copyWith(likes: likeData, isLoading: false);
      print('✅ [EnhancedLikes] Cache chargé: ${likeData.length} éléments');
    } catch (e) {
      print('❌ [EnhancedLikes] Erreur chargement cache: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Synchroniser avec le serveur
  Future<void> syncWithServer({bool force = false}) async {
    if (state.isSyncing && !force) return;
    
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      print('🔄 [EnhancedLikes] Synchronisation avec le serveur...');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/likes/detailed'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final serverLikes = data['data'] as List;
          final Map<String, ContentLikeData> newLikes = {};
          
          // Traiter les données du serveur
          for (final item in serverLikes) {
            final likeData = ContentLikeData(
              type: item['likeable_type'] ?? '',
              itemId: item['likeable_id']?.toString() ?? '',
              isLiked: item['is_liked'] ?? false,
              likesCount: item['total_likes'] ?? 0,
            );
            
            newLikes[likeData.key] = likeData;
          }
          
          // Sauvegarder localement
          await _saveToCache(newLikes);
          
          state = state.copyWith(
            likes: newLikes,
            isSyncing: false,
            lastSync: DateTime.now(),
          );
          
          print('✅ [EnhancedLikes] Synchronisé ${newLikes.length} likes depuis le serveur');
        } else {
          throw Exception(data['message'] ?? 'Erreur API');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [EnhancedLikes] Erreur synchronisation: $e');
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }

  // Récupérer les compteurs pour un contenu spécifique
  Future<ContentLikeData?> fetchContentLikes(String type, String itemId) async {
    try {
      print('🔍 [EnhancedLikes] Récupération likes pour $type:$itemId');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/content/$type/$itemId/likes'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final likeData = ContentLikeData(
            type: type,
            itemId: itemId,
            isLiked: data['data']['is_liked'] ?? false,
            likesCount: data['data']['total_likes'] ?? 0,
          );
          
          // Mettre à jour le cache local
          final updatedLikes = Map<String, ContentLikeData>.from(state.likes);
          updatedLikes[likeData.key] = likeData;
          
          await _saveToCache(updatedLikes);
          state = state.copyWith(likes: updatedLikes);
          
          print('✅ [EnhancedLikes] Likes récupérés: ${likeData.isLiked}, count: ${likeData.likesCount}');
          return likeData;
        }
      }
    } catch (e) {
      print('❌ [EnhancedLikes] Erreur récupération likes: $e');
    }
    
    return null;
  }

  // Toggle un like et mettre à jour les compteurs
  Future<bool> toggleLike(String type, String itemId) async {
    try {
      print('❤️ [EnhancedLikes] Toggle like $type:$itemId');
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/likes/toggle'),
        headers: headers,
        body: json.encode({
          'likeable_type': type,
          'likeable_id': itemId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final newLikeData = ContentLikeData(
            type: type,
            itemId: itemId,
            isLiked: data['data']['is_liked'] ?? false,
            likesCount: data['data']['total_likes'] ?? 0,
          );
          
          // Mettre à jour immédiatement le state
          final updatedLikes = Map<String, ContentLikeData>.from(state.likes);
          updatedLikes[newLikeData.key] = newLikeData;
          
          state = state.copyWith(likes: updatedLikes);
          
          // Sauvegarder en arrière-plan
          _saveToCache(updatedLikes);
          
          print('✅ [EnhancedLikes] Like toggled: ${newLikeData.isLiked}, count: ${newLikeData.likesCount}');
          return true;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      }
    } catch (e) {
      print('❌ [EnhancedLikes] Erreur toggle like: $e');
      rethrow;
    }
    
    return false;
  }

  // Initialiser les données d'un contenu
  void setInitialData(String type, String itemId, bool isLiked, int count) {
    final key = '${type}_$itemId';
    
    // Ne mettre à jour que si on n'a pas déjà des données plus récentes
    if (!state.likes.containsKey(key)) {
      final likeData = ContentLikeData(
        type: type,
        itemId: itemId,
        isLiked: isLiked,
        likesCount: count,
      );
      
      final updatedLikes = Map<String, ContentLikeData>.from(state.likes);
      updatedLikes[key] = likeData;
      
      state = state.copyWith(likes: updatedLikes);
      
      // Sauvegarder en arrière-plan
      _saveToCache(updatedLikes);
      
      print('📝 [EnhancedLikes] Données initiales définies pour $type:$itemId');
    }
  }

  // Méthodes utilitaires
  Future<Map<String, String>> _getHeaders() async {
    final authState = await _localDB.getAuthState();
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (authState != null && authState['token'] != null) {
      headers['Authorization'] = 'Bearer ${authState['token']}';
    }
    
    return headers;
  }

  Future<void> _saveToCache(Map<String, ContentLikeData> likes) async {
    try {
      final likeStates = <String, bool>{};
      final likeCounts = <String, int>{};
      
      for (final entry in likes.entries) {
        likeStates[entry.key] = entry.value.isLiked;
        likeCounts[entry.key] = entry.value.likesCount;
      }
      
      await Future.wait([
        _localDB.saveUserLikes(likeStates),
        _localDB.saveLikeCounts(likeCounts),
      ]);
    } catch (e) {
      print('❌ [EnhancedLikes] Erreur sauvegarde cache: $e');
    }
  }

  // Synchronisation automatique périodique
  void startPeriodicSync() {
    Future.delayed(const Duration(minutes: 5), () async {
      if (mounted) {
        await syncWithServer();
        startPeriodicSync();
      }
    });
  }

  void clearLikes() {
    state = const EnhancedLikesState();
    _localDB.saveUserLikes({});
    _localDB.saveLikeCounts({});
  }
}

// Provider pour le service de likes amélioré
final enhancedLikesProvider = StateNotifierProvider<EnhancedLikesService, EnhancedLikesState>((ref) {
  final localDB = ref.read(localDatabaseServiceProvider);
  final service = EnhancedLikesService(localDB);
  
  // Démarrer la synchronisation périodique
  service.startPeriodicSync();
  
  return service;
});