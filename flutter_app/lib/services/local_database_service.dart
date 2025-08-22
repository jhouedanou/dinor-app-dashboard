/// LOCAL_DATABASE_SERVICE.DART - SERVICE DE BASE DE DONNÉES LOCALE
/// 
/// FONCTIONNALITÉS :
/// - Stockage persistant des likes, favoris, état d'authentification
/// - Cache local des données utilisateur pour performance
/// - Synchronisation avec SharedPreferences et SecureStorage
/// - Gestion des données hors ligne
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys pour les différents types de données
  static const String _userLikesKey = 'user_likes_v2';
  static const String _userFavoritesKey = 'user_favorites_v2';
  static const String _userPredictionsKey = 'user_predictions_v2';
  static const String _authStateKey = 'auth_state_v2';
  static const String _userProfileKey = 'user_profile_v2';
  static const String _cacheTimestampKey = 'cache_timestamp_v2';

  // Cache en mémoire pour les performances
  final Map<String, dynamic> _memoryCache = {};
  DateTime? _lastCacheUpdate;

  // === GESTION DU CACHE ===

  Future<void> _updateCacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    _lastCacheUpdate = DateTime.now();
  }

  Future<bool> _isCacheValid({int maxAgeMinutes = 30}) async {
    if (_lastCacheUpdate == null) {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp == null) return false;
      _lastCacheUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastCacheUpdate!);
    return difference.inMinutes < maxAgeMinutes;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
    _memoryCache.clear();
    _lastCacheUpdate = null;
    print('🧹 [LocalDB] Cache complètement vidé');
  }

  // === GESTION DES LIKES ===

  Future<Map<String, bool>> getUserLikes() async {
    try {
      if (_memoryCache.containsKey(_userLikesKey) && await _isCacheValid()) {
        return Map<String, bool>.from(_memoryCache[_userLikesKey]);
      }

      final prefs = await SharedPreferences.getInstance();
      final likesJson = prefs.getString(_userLikesKey);
      
      if (likesJson != null) {
        final Map<String, dynamic> likesData = json.decode(likesJson);
        final userLikes = likesData.map((key, value) => MapEntry(key, value as bool));
        
        _memoryCache[_userLikesKey] = userLikes;
        return userLikes;
      }
      
      return {};
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture likes: $e');
      return {};
    }
  }

  Future<Map<String, int>> getLikeCounts() async {
    try {
      const key = 'like_counts_v2';
      if (_memoryCache.containsKey(key) && await _isCacheValid()) {
        return Map<String, int>.from(_memoryCache[key]);
      }

      final prefs = await SharedPreferences.getInstance();
      final countsJson = prefs.getString(key);
      
      if (countsJson != null) {
        final Map<String, dynamic> countsData = json.decode(countsJson);
        final likeCounts = countsData.map((key, value) => MapEntry(key, value as int));
        
        _memoryCache[key] = likeCounts;
        return likeCounts;
      }
      
      return {};
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture compteurs likes: $e');
      return {};
    }
  }

  Future<void> saveUserLikes(Map<String, bool> likes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userLikesKey, json.encode(likes));
      
      _memoryCache[_userLikesKey] = likes;
      await _updateCacheTimestamp();
      
      print('💾 [LocalDB] Likes sauvegardés: ${likes.length} éléments');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde likes: $e');
    }
  }

  Future<void> saveLikeCounts(Map<String, int> counts) async {
    try {
      const key = 'like_counts_v2';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(counts));
      
      _memoryCache[key] = counts;
      await _updateCacheTimestamp();
      
      print('💾 [LocalDB] Compteurs likes sauvegardés: ${counts.length} éléments');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde compteurs likes: $e');
    }
  }

  Future<void> updateLike(String type, String itemId, bool isLiked) async {
    final likes = await getUserLikes();
    final key = '${type}_$itemId';
    
    if (isLiked) {
      likes[key] = true;
    } else {
      likes.remove(key);
    }
    
    await saveUserLikes(likes);
  }

  // === GESTION DES FAVORIS ===

  Future<List<Map<String, dynamic>>> getUserFavorites() async {
    try {
      if (_memoryCache.containsKey(_userFavoritesKey) && await _isCacheValid()) {
        return List<Map<String, dynamic>>.from(_memoryCache[_userFavoritesKey]);
      }

      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_userFavoritesKey);
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesData = json.decode(favoritesJson);
        final favorites = favoritesData.cast<Map<String, dynamic>>();
        
        _memoryCache[_userFavoritesKey] = favorites;
        return favorites;
      }
      
      return [];
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture favoris: $e');
      return [];
    }
  }

  Future<void> saveUserFavorites(List<Map<String, dynamic>> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userFavoritesKey, json.encode(favorites));
      
      _memoryCache[_userFavoritesKey] = favorites;
      await _updateCacheTimestamp();
      
      print('💾 [LocalDB] Favoris sauvegardés: ${favorites.length} éléments');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde favoris: $e');
    }
  }

  // === GESTION DES PRONOSTICS ===

  Future<List<Map<String, dynamic>>> getUserPredictions() async {
    try {
      if (_memoryCache.containsKey(_userPredictionsKey) && await _isCacheValid()) {
        return List<Map<String, dynamic>>.from(_memoryCache[_userPredictionsKey]);
      }

      final prefs = await SharedPreferences.getInstance();
      final predictionsJson = prefs.getString(_userPredictionsKey);
      
      if (predictionsJson != null) {
        final List<dynamic> predictionsData = json.decode(predictionsJson);
        final predictions = predictionsData.cast<Map<String, dynamic>>();
        
        _memoryCache[_userPredictionsKey] = predictions;
        return predictions;
      }
      
      return [];
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture pronostics: $e');
      return [];
    }
  }

  Future<void> saveUserPredictions(List<Map<String, dynamic>> predictions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPredictionsKey, json.encode(predictions));
      
      _memoryCache[_userPredictionsKey] = predictions;
      await _updateCacheTimestamp();
      
      print('💾 [LocalDB] Pronostics sauvegardés: ${predictions.length} éléments');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde pronostics: $e');
    }
  }

  // === GESTION DE L'ÉTAT D'AUTHENTIFICATION ===

  Future<Map<String, dynamic>?> getAuthState() async {
    try {
      final authStateJson = await _secureStorage.read(key: _authStateKey);
      
      if (authStateJson != null) {
        return json.decode(authStateJson);
      }
      
      return null;
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture état auth: $e');
      return null;
    }
  }

  Future<void> saveAuthState(Map<String, dynamic> authState) async {
    try {
      await _secureStorage.write(
        key: _authStateKey,
        value: json.encode(authState),
      );
      
      print('🔐 [LocalDB] État d\'authentification sauvegardé');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde état auth: $e');
    }
  }

  Future<void> clearAuthState() async {
    try {
      await _secureStorage.delete(key: _authStateKey);
      await _secureStorage.delete(key: _userProfileKey);
      
      // Supprimer aussi du cache en mémoire
      _memoryCache.remove(_authStateKey);
      _memoryCache.remove(_userProfileKey);
      
      print('🔐 [LocalDB] État d\'authentification supprimé');
    } catch (e) {
      print('❌ [LocalDB] Erreur suppression état auth: $e');
    }
  }

  // === GESTION DU PROFIL UTILISATEUR ===

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_memoryCache.containsKey(_userProfileKey) && await _isCacheValid()) {
        return Map<String, dynamic>.from(_memoryCache[_userProfileKey]);
      }

      final profileJson = await _secureStorage.read(key: _userProfileKey);
      
      if (profileJson != null) {
        final profile = json.decode(profileJson);
        _memoryCache[_userProfileKey] = profile;
        return profile;
      }
      
      return null;
    } catch (e) {
      print('❌ [LocalDB] Erreur lecture profil: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      await _secureStorage.write(
        key: _userProfileKey,
        value: json.encode(profile),
      );
      
      _memoryCache[_userProfileKey] = profile;
      await _updateCacheTimestamp();
      
      print('👤 [LocalDB] Profil utilisateur sauvegardé');
    } catch (e) {
      print('❌ [LocalDB] Erreur sauvegarde profil: $e');
    }
  }

  // === STATISTIQUES ET DEBUG ===

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final likes = await getUserLikes();
    final favorites = await getUserFavorites();
    final predictions = await getUserPredictions();
    final authState = await getAuthState();
    final profile = await getUserProfile();

    return {
      'likes_count': likes.length,
      'favorites_count': favorites.length,
      'predictions_count': predictions.length,
      'is_authenticated': authState != null,
      'has_profile': profile != null,
      'cache_valid': await _isCacheValid(),
      'last_update': _lastCacheUpdate?.toIso8601String(),
    };
  }
}

// Provider pour le service de base de données locale
final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});