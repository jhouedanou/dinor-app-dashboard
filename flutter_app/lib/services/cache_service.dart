import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class CacheService {
  static const String _recipesKey = 'cached_recipes';
  static const String _tipsKey = 'cached_tips';
  static const String _eventsKey = 'cached_events';
  static const String _videosKey = 'cached_videos';
  static const String _recipeDetailsKey = 'cached_recipe_details';
  static const String _tipDetailsKey = 'cached_tip_details';
  static const String _eventDetailsKey = 'cached_event_details';
  static const String _lastUpdateKey = 'last_cache_update';
  static const String _cacheVersionKey = 'cache_version';
  static const String _offlineModeKey = 'offline_mode';
  
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache en mémoire pour les accès rapides
  final Map<String, dynamic> _memoryCache = {};
  
  // Version du cache pour la gestion des mises à jour
  static const int _currentCacheVersion = 1;

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

  // Vérifier si le cache est à jour (moins de 24 heures pour le mode hors ligne)
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const oneDay = 24 * 60 * 60 * 1000; // 24 heures en millisecondes
      
      return (now - lastUpdate) < oneDay;
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
      await prefs.setInt(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la mise à jour du timestamp: $e');
    }
  }

  // Méthodes spécifiques pour chaque type de contenu
  Future<void> cacheRecipes(List<dynamic> recipes) async {
    await cacheData(_recipesKey, recipes);
    await _cacheImages(recipes, 'recipe');
  }

  Future<List<dynamic>?> getCachedRecipes() async {
    final data = await getCachedData(_recipesKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  Future<void> cacheTips(List<dynamic> tips) async {
    await cacheData(_tipsKey, tips);
    await _cacheImages(tips, 'tip');
  }

  Future<List<dynamic>?> getCachedTips() async {
    final data = await getCachedData(_tipsKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  Future<void> cacheEvents(List<dynamic> events) async {
    await cacheData(_eventsKey, events);
    await _cacheImages(events, 'event');
  }

  Future<List<dynamic>?> getCachedEvents() async {
    final data = await getCachedData(_eventsKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  Future<void> cacheVideos(List<dynamic> videos) async {
    await cacheData(_videosKey, videos);
    await _cacheImages(videos, 'video');
  }

  Future<List<dynamic>?> getCachedVideos() async {
    final data = await getCachedData(_videosKey);
    return data != null ? List<dynamic>.from(data) : null;
  }

  // Cache pour les détails
  Future<void> cacheRecipeDetail(String id, Map<String, dynamic> recipe) async {
    await cacheData('$_recipeDetailsKey:$id', recipe);
    await _cacheDetailImages(recipe, 'recipe', id);
  }

  Future<Map<String, dynamic>?> getCachedRecipeDetail(String id) async {
    return await getCachedData('$_recipeDetailsKey:$id');
  }

  Future<void> cacheTipDetail(String id, Map<String, dynamic> tip) async {
    await cacheData('$_tipDetailsKey:$id', tip);
    await _cacheDetailImages(tip, 'tip', id);
  }

  Future<Map<String, dynamic>?> getCachedTipDetail(String id) async {
    return await getCachedData('$_tipDetailsKey:$id');
  }

  Future<void> cacheEventDetail(String id, Map<String, dynamic> event) async {
    await cacheData('$_eventDetailsKey:$id', event);
    await _cacheDetailImages(event, 'event', id);
  }

  Future<Map<String, dynamic>?> getCachedEventDetail(String id) async {
    return await getCachedData('$_eventDetailsKey:$id');
  }

  // Cache des images pour le mode hors ligne
  Future<void> _cacheImages(List<dynamic> items, String type) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      for (final item in items) {
        final imageUrl = item['featured_image_url'] ?? item['image_url'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _cacheImage(imageUrl, type, item['id'].toString());
        }
      }
    } catch (e) {
      print('❌ [CacheService] Erreur lors du cache des images: $e');
    }
  }

  Future<void> _cacheDetailImages(Map<String, dynamic> item, String type, String id) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Cache image principale
      final imageUrl = item['featured_image_url'] ?? item['image_url'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _cacheImage(imageUrl, type, id);
      }

      // Cache images de la galerie
      final galleryUrls = item['gallery_urls'];
      if (galleryUrls is List) {
        for (int i = 0; i < galleryUrls.length; i++) {
          await _cacheImage(galleryUrls[i], '${type}_gallery', '${id}_$i');
        }
      }
    } catch (e) {
      print('❌ [CacheService] Erreur lors du cache des images de détail: $e');
    }
  }

  Future<void> _cacheImage(String imageUrl, String type, String id) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      final imageFile = File('${imagesDir.path}/${type}_$id.jpg');

      if (!await imageFile.exists()) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          await imageFile.writeAsBytes(response.bodyBytes);
          print('🖼️ [CacheService] Image mise en cache: $type/$id');
        }
      }
    } catch (e) {
      print('❌ [CacheService] Erreur lors du cache de l\'image: $e');
    }
  }

  // Récupérer une image du cache local
  Future<String?> getCachedImagePath(String imageUrl, String type, String id) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      final imageFile = File('${imagesDir.path}/${type}_$id.jpg');

      if (await imageFile.exists()) {
        return imageFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Synchroniser le cache avec le serveur
  Future<void> syncCache() async {
    try {
      if (!await isOnline()) {
        print('📡 [CacheService] Pas de connexion internet, synchronisation impossible');
        return;
      }

      print('🔄 [CacheService] Début de la synchronisation du cache...');
      
      // Vérifier la version du cache
      final prefs = await SharedPreferences.getInstance();
      final cacheVersion = prefs.getInt(_cacheVersionKey) ?? 0;
      
      if (cacheVersion < _currentCacheVersion) {
        print('🔄 [CacheService] Mise à jour du cache vers la version $_currentCacheVersion');
        await clearCache();
      }

      // Synchroniser les données principales
      await _syncMainData();
      
      // Mettre à jour le timestamp
      await updateCacheTimestamp();
      
      print('✅ [CacheService] Synchronisation terminée');
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la synchronisation: $e');
    }
  }

  Future<void> _syncMainData() async {
    try {
      // Synchroniser les recettes
      final recipesResponse = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/recipes?limit=50'),
        headers: {'Accept': 'application/json'},
      );
      if (recipesResponse.statusCode == 200) {
        final data = json.decode(recipesResponse.body);
        if (data['data'] != null) {
          await cacheRecipes(data['data']);
        }
      }

      // Synchroniser les astuces
      final tipsResponse = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips?limit=50'),
        headers: {'Accept': 'application/json'},
      );
      if (tipsResponse.statusCode == 200) {
        final data = json.decode(tipsResponse.body);
        if (data['data'] != null) {
          await cacheTips(data['data']);
        }
      }

      // Synchroniser les événements
      final eventsResponse = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/events?limit=50'),
        headers: {'Accept': 'application/json'},
      );
      if (eventsResponse.statusCode == 200) {
        final data = json.decode(eventsResponse.body);
        if (data['data'] != null) {
          await cacheEvents(data['data']);
        }
      }

      // Synchroniser les vidéos
      final videosResponse = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/dinor-tv?limit=20'),
        headers: {'Accept': 'application/json'},
      );
      if (videosResponse.statusCode == 200) {
        final data = json.decode(videosResponse.body);
        if (data['data'] != null) {
          await cacheVideos(data['data']);
        }
      }
    } catch (e) {
      print('❌ [CacheService] Erreur lors de la synchronisation des données: $e');
    }
  }

  // Activer/désactiver le mode hors ligne
  Future<void> setOfflineMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineModeKey, enabled);
      print('📱 [CacheService] Mode hors ligne ${enabled ? 'activé' : 'désactivé'}');
    } catch (e) {
      print('❌ [CacheService] Erreur lors du changement de mode: $e');
    }
  }

  Future<bool> isOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_offlineModeKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Nettoyer le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _memoryCache.clear();
      
      // Nettoyer les images en cache
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
      }
      
      print('🗑️ [CacheService] Cache nettoyé');
    } catch (e) {
      print('❌ [CacheService] Erreur lors du nettoyage du cache: $e');
    }
  }

  // Obtenir la taille du cache
  Future<String> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imagesDir = Directory('${cacheDir.path}/dinor_images');
      
      if (await imagesDir.exists()) {
        int totalSize = 0;
        await for (final file in imagesDir.list(recursive: true)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
        
        if (totalSize < 1024) {
          return '${totalSize}B';
        } else if (totalSize < 1024 * 1024) {
          return '${(totalSize / 1024).toStringAsFixed(1)}KB';
        } else {
          return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
        }
      }
      return '0B';
    } catch (e) {
      return '0B';
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

  // Obtenir les statistiques du cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
      final cacheVersion = prefs.getInt(_cacheVersionKey) ?? 0;
      final isOffline = prefs.getBool(_offlineModeKey) ?? false;
      
      final recipes = await getCachedRecipes();
      final tips = await getCachedTips();
      final events = await getCachedEvents();
      final videos = await getCachedVideos();
      
      return {
        'lastUpdate': DateTime.fromMillisecondsSinceEpoch(lastUpdate),
        'cacheVersion': cacheVersion,
        'offlineMode': isOffline,
        'recipesCount': recipes?.length ?? 0,
        'tipsCount': tips?.length ?? 0,
        'eventsCount': events?.length ?? 0,
        'videosCount': videos?.length ?? 0,
        'cacheSize': await getCacheSize(),
        'isValid': await isCacheValid(),
        'isOnline': await isOnline(),
      };
    } catch (e) {
      return {};
    }
  }
} 