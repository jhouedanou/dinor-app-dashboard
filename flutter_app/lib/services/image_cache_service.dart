import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static final Map<String, String> _memoryCache = {};
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  /// Cache une image depuis une URL en mémoire et retourne l'URL ou null si échec
  static Future<String?> cacheImageUrl(String imageUrl) async {
    try {
      if (_memoryCache.containsKey(imageUrl)) {
        return imageUrl;
      }
      
      // Vérifier que l'URL est accessible
      final response = await http.head(
        Uri.parse(imageUrl),
        headers: {'User-Agent': 'DinorApp/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        _memoryCache[imageUrl] = DateTime.now().toIso8601String();
        return imageUrl;
      } else {
        return null;
      }
      
    } catch (e) {
      return null;
    }
  }
  
  /// Récupère une image depuis le cache si elle existe et est valide
  static String? getCachedImageUrl(String imageUrl) {
    try {
      final cachedTime = _memoryCache[imageUrl];
      if (cachedTime != null) {
        final cacheDateTime = DateTime.parse(cachedTime);
        final now = DateTime.now();
        final cacheAge = now.difference(cacheDateTime);
        
        if (cacheAge < _cacheExpiry) {
          return imageUrl;
        } else {
          _memoryCache.remove(imageUrl);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Crée un ImageProvider qui utilise le cache mémoire
  static ImageProvider getCachedImageProvider(String imageUrl) {
    final cachedUrl = getCachedImageUrl(imageUrl);
    if (cachedUrl != null) {
      return NetworkImage(cachedUrl);
    }
    
    // Cache en arrière-plan et retourne le provider
    cacheImageUrl(imageUrl);
    return NetworkImage(imageUrl);
  }
  
  /// Vide le cache mémoire
  static void clearCache() {
    _memoryCache.clear();
  }
  
  /// Nettoie les entrées expirées du cache
  static void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _memoryCache.entries) {
      try {
        final cacheDateTime = DateTime.parse(entry.value);
        final cacheAge = now.difference(cacheDateTime);
        
        if (cacheAge > _cacheExpiry) {
          expiredKeys.add(entry.key);
        }
      } catch (e) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
  }
}