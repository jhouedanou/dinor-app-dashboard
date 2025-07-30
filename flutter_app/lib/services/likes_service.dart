import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_service.dart';

class LikesService {
  LikesService(this._apiService);

  final ApiService _apiService;
  final Dio _dio = Dio();
  Map<String, bool> _userLikes = {};
  Map<String, int> _likeCounts = {};

  Future<void> loadUserLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likesJson = prefs.getString('user_likes');
      final countsJson = prefs.getString('like_counts');
      
      if (likesJson != null) {
        final Map<String, dynamic> likesData = json.decode(likesJson);
        _userLikes = likesData.map((key, value) => MapEntry(key, value as bool));
      }
      
      if (countsJson != null) {
        final Map<String, dynamic> countsData = json.decode(countsJson);
        _likeCounts = countsData.map((key, value) => MapEntry(key, value as int));
      }

      print('✅ [LikesService] User likes loaded: ${_userLikes.length} items');
    } catch (e) {
      print('❌ [LikesService] Error loading user likes: $e');
    }
  }

  Future<void> _saveUserLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_likes', json.encode(_userLikes));
      await prefs.setString('like_counts', json.encode(_likeCounts));
      print('💾 [LikesService] User likes saved');
    } catch (e) {
      print('❌ [LikesService] Error saving user likes: $e');
    }
  }

  String _getLikeKey(String type, String itemId) {
    return '${type}_$itemId';
  }

  bool isLiked(String type, String itemId) {
    final key = _getLikeKey(type, itemId);
    return _userLikes[key] ?? false;
  }

  int getLikeCount(String type, String itemId) {
    final key = _getLikeKey(type, itemId);
    return _likeCounts[key] ?? 0;
  }

  void setInitialLikeData(String type, String itemId, bool isLiked, int count) {
    final key = _getLikeKey(type, itemId);
    _userLikes[key] = isLiked;
    _likeCounts[key] = count;
  }

  Future<Map<String, dynamic>> toggleLike(String type, String itemId) async {
    final key = _getLikeKey(type, itemId);
    final wasLiked = _userLikes[key] ?? false;
    
    try {
      print('❤️ [LikesService] Toggling like for $type:$itemId (was: $wasLiked)');
      
      final response = await _apiService.post('/likes/toggle', {
        'type': type,
        'id': itemId,
      });
      
      if (response['success']) {
        final newLiked = !wasLiked;
        final newCount = response['data']['total_likes'] ?? (_likeCounts[key] ?? 0);
        
        // Update local state
        _userLikes[key] = newLiked;
        _likeCounts[key] = newCount;
        
        // Save to persistent storage
        await _saveUserLikes();
        
        print('✅ [LikesService] Like toggled successfully: $newLiked, count: $newCount');
        
        return {
          'success': true,
          'is_liked': newLiked,
          'total_likes': newCount,
        };
      } else {
        print('❌ [LikesService] API returned error: ${response['error']}');
        return response;
      }
    } catch (e) {
      print('❌ [LikesService] Exception toggling like: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> syncWithServer() async {
    try {
      print('🔄 [LikesService] Synchronisation avec le serveur...');
      
      final response = await _apiService.get('/user/likes');
      if (response['success'] && response['data'] != null) {
        final serverLikes = response['data'] as List;
        
        // Clear current likes
        _userLikes.clear();
        _likeCounts.clear();
        
        // Update with server data
        for (final like in serverLikes) {
          final type = like['likeable_type'];
          final itemId = like['likeable_id'].toString();
          final key = _getLikeKey(type, itemId);
          _userLikes[key] = true;
          _likeCounts[key] = like['total_likes'] ?? 1;
        }
        
        await _saveUserLikes();
        print('✅ [LikesService] Synchronisé ${serverLikes.length} likes depuis le serveur');
      } else {
        print('❌ [LikesService] Erreur réponse serveur: ${response['message']}');
      }
    } catch (e) {
      print('❌ [LikesService] Erreur synchronisation serveur: $e');
    }
  }

  // Méthode pour forcer la synchronisation et recharger
  Future<void> forceSyncAndReload() async {
    try {
      print('🔄 [LikesService] Forçage synchronisation...');
      await syncWithServer();
      await loadUserLikes();
      print('✅ [LikesService] Synchronisation forcée terminée');
    } catch (e) {
      print('❌ [LikesService] Erreur synchronisation forcée: $e');
    }
  }

  void clearUserLikes() {
    _userLikes.clear();
    _likeCounts.clear();
    _saveUserLikes();
    print('🧹 [LikesService] User likes cleared');
  }
}

// Provider for the likes service
final likesServiceProvider = Provider<LikesService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return LikesService(apiService);
});

// State notifier for reactive likes management
class LikesState {
  final Map<String, bool> userLikes;
  final Map<String, int> likeCounts;

  const LikesState({
    this.userLikes = const {},
    this.likeCounts = const {},
  });

  LikesState copyWith({
    Map<String, bool>? userLikes,
    Map<String, int>? likeCounts,
  }) {
    return LikesState(
      userLikes: userLikes ?? this.userLikes,
      likeCounts: likeCounts ?? this.likeCounts,
    );
  }
}

class LikesNotifier extends StateNotifier<LikesState> {
  final LikesService _likesService;
  
  LikesNotifier(this._likesService) : super(const LikesState()) {
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    print('🔄 [LikesNotifier] Chargement des likes...');
    await _likesService.loadUserLikes();
    state = LikesState(
      userLikes: Map<String, bool>.from(_likesService._userLikes),
      likeCounts: Map<String, int>.from(_likesService._likeCounts),
    );
    print('✅ [LikesNotifier] Likes chargés: ${state.userLikes.length} éléments');
  }

  Future<bool> toggleLike(String type, String itemId) async {
    final result = await _likesService.toggleLike(type, itemId);
    
    if (result['success']) {
      // Update state immediately for UI responsiveness
      final key = _likesService._getLikeKey(type, itemId);
      final newUserLikes = Map<String, bool>.from(state.userLikes);
      final newLikeCounts = Map<String, int>.from(state.likeCounts);
      
      newUserLikes[key] = result['is_liked'];
      newLikeCounts[key] = result['total_likes'];
      
      state = LikesState(
        userLikes: newUserLikes,
        likeCounts: newLikeCounts,
      );
      
      return true;
    }
    
    return false;
  }

  void setInitialData(String type, String itemId, bool isLiked, int count) {
    _likesService.setInitialLikeData(type, itemId, isLiked, count);
    
    final key = _likesService._getLikeKey(type, itemId);
    final newUserLikes = Map<String, bool>.from(state.userLikes);
    final newLikeCounts = Map<String, int>.from(state.likeCounts);
    
    newUserLikes[key] = isLiked;
    newLikeCounts[key] = count;
    
    state = LikesState(
      userLikes: newUserLikes,
      likeCounts: newLikeCounts,
    );
  }

  bool isLiked(String type, String itemId) {
    final key = _likesService._getLikeKey(type, itemId);
    return state.userLikes[key] ?? false;
  }

  int getLikeCount(String type, String itemId) {
    final key = _likesService._getLikeKey(type, itemId);
    return state.likeCounts[key] ?? 0;
  }

  Future<void> syncWithServer() async {
    await _likesService.syncWithServer();
    await _loadLikes();
  }

  Future<void> forceSync() async {
    print('🔄 [LikesNotifier] Forçage synchronisation...');
    await _likesService.forceSyncAndReload();
    await _loadLikes();
    print('✅ [LikesNotifier] Synchronisation forcée terminée');
  }

  void clearLikes() {
    _likesService.clearUserLikes();
    state = const LikesState();
  }
}

final likesProvider = StateNotifierProvider<LikesNotifier, LikesState>((ref) {
  final likesService = ref.read(likesServiceProvider);
  return LikesNotifier(likesService);
});