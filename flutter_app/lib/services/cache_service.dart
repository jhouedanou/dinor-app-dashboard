import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static const String _recipesKey = 'cached_recipes';
  static const String _tipsKey = 'cached_tips';
  static const String _eventsKey = 'cached_events';
  static const String _recipeDetailsKey = 'cached_recipe_details';
  static const String _tipDetailsKey = 'cached_tip_details';
  static const String _eventDetailsKey = 'cached_event_details';
  static const String _lastUpdateKey = 'last_cache_update';
  
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache en mémoire pour les accès rapides
  final Map<String, dynamic> _memoryCache = {};

  // Sauvegarder des données dans le cache
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(data);
      await prefs.setString(key, jsonData);
      
      // Mettre en cache en mémoire aussi
      _memoryCache[key] = data;
      
      print('💾 [CacheService] Données mises en cache: $key');
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la mise en cache: $e');
    }
  }

  // Récupérer des données du cache
  Future<dynamic> getCachedData(String key) async {
    try {
      // Vérifier d'abord le cache mémoire
      if (_memoryCache.containsKey(key)) {
        print('⚡ [CacheService] Données récupérées du cache mémoire: $key');
        return _memoryCache[key];
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(key);
      
      if (jsonData != null) {
        final data = json.decode(jsonData);
        _memoryCache[key] = data; // Mettre en cache mémoire
        print('💾 [CacheService] Données récupérées du cache: $key');
        return data;
      }
      
      return null;
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la récupération du cache: $e');
      return null;
    }
  }

  // Vérifier si le cache est à jour (moins de 1 heure)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHour = 60 * 60 * 1000; // 1 heure en millisecondes
      
      return (now - lastUpdate) < oneHour;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le timestamp de cache
  Future<void> updateCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastUpdateKey, now);
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la mise à jour du timestamp: $e');
    }
  }

  // Méthodes spécifiques pour chaque type de contenu
  Future<void> cacheRecipes(List<dynamic> recipes) async {
    await cacheData(_recipesKey, recipes);
  }

  Future<List<dynamic>?> getCachedRecipes() async {
    final data = await getCachedData(_recipesKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  Future<void> cacheTips(List<dynamic> tips) async {
    await cacheData(_tipsKey, tips);
  }

  Future<List<dynamic>?> getCachedTips() async {
    final data = await getCachedData(_tipsKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  Future<void> cacheEvents(List<dynamic> events) async {
    await cacheData(_eventsKey, events);
  }

  Future<List<dynamic>?> getCachedEvents() async {
    final data = await getCachedData(_eventsKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  // Cache pour les détails
  Future<void> cacheRecipeDetail(String id, Map<String, dynamic> recipe) async {
    await cacheData('$_recipeDetailsKey:$id', recipe);
  }

  Future<Map<String, dynamic>?> getCachedRecipeDetail(String id) async {
    return await getCachedData('$_recipeDetailsKey:$id');
  }

  Future<void> cacheTipDetail(String id, Map<String, dynamic> tip) async {
    await cacheData('$_tipDetailsKey:$id', tip);
  }

  Future<Map<String, dynamic>?> getCachedTipDetail(String id) async {
    return await getCachedData('$_tipDetailsKey:$id');
  }

  Future<void> cacheEventDetail(String id, Map<String, dynamic> event) async {
    await cacheData('$_eventDetailsKey:$id', event);
  }

  Future<Map<String, dynamic>?> getCachedEventDetail(String id) async {
    return await getCachedData('$_eventDetailsKey:$id');
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _memoryCache.clear();
      print('🗑️ [CacheService] Cache nettoyé');
    } catch (e) {
      print('❌ [CacheService] Erreur lors du nettoyage du cache: $e');
    }
  }

  // Vérifier la connectivité
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
} 