/**
 * API_SERVICE.DART - REPRODUCTION FIDÈLE DU SERVICE VUE/REACT NATIVE
 * 
 * FIDÉLITÉ API :
 * - Même baseURL que React Native
 * - Headers identiques : Bearer token, X-Requested-With
 * - Endpoints identiques : /recipes, /tips, /events, /dinor-tv
 * - Structure de réponse identique : {success, data, meta, message}
 * - Gestion d'erreurs identique : 401, 404, 500
 * - Cache désactivé comme dans Vue (communication directe)
 * 
 * MÉTHODES IDENTIQUES :
 * - getRecipes(), getTips(), getEvents(), getVideos()
 * - toggleLike(), addComment(), toggleFavorite()
 * - Auth : login(), register(), logout(), getProfile()
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://dinor.app/api/v1';
  
  // Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Récupérer l'URL de partage depuis l'API
  static Future<String?> getShareUrl({
    required String type,
    required String id,
    String? platform,
  }) async {
    try {
      print('📡 [ApiService] Récupération URL de partage: $type/$id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/shares/url?type=$type&id=$id${platform != null ? '&platform=$platform' : ''}'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']?['url'] != null) {
          final shareUrl = data['data']['url'];
          print('✅ [ApiService] URL de partage récupérée: $shareUrl');
          return shareUrl;
        }
      }
      
      print('❌ [ApiService] Échec récupération URL de partage: ${response.statusCode}');
      return null;
    } catch (error) {
      print('💥 [ApiService] Erreur récupération URL de partage: $error');
      return null;
    }
  }

  /// Récupérer les métadonnées de partage depuis l'API
  static Future<Map<String, dynamic>?> getShareMetadata({
    required String type,
    required String id,
  }) async {
    try {
      print('📡 [ApiService] Récupération métadonnées: $type/$id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/shares/metadata?type=$type&id=$id'),
        headers: _defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ [ApiService] Métadonnées récupérées');
          return data['data'];
        }
      }
      
      print('❌ [ApiService] Échec récupération métadonnées: ${response.statusCode}');
      return null;
    } catch (error) {
      print('💥 [ApiService] Erreur récupération métadonnées: $error');
      return null;
    }
  }

  /// Tracker un partage dans l'API
  static Future<bool> trackShare({
    required String type,
    required String id,
    required String platform,
  }) async {
    try {
      print('📡 [ApiService] Tracking partage: $type/$id sur $platform');
      
      final response = await http.post(
        Uri.parse('$baseUrl/shares/track'),
        headers: _defaultHeaders,
        body: json.encode({
          'type': type,
          'id': id,
          'platform': platform,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ [ApiService] Partage tracké avec succès');
          return true;
        }
      }
      
      print('❌ [ApiService] Échec tracking partage: ${response.statusCode}');
      return false;
    } catch (error) {
      print('💥 [ApiService] Erreur tracking partage: $error');
      return false;
    }
  }

  /// Récupérer les données complètes de partage (URL + métadonnées)
  static Future<Map<String, dynamic>?> getCompleteShareData({
    required String type,
    required String id,
    String? platform,
  }) async {
    try {
      print('📡 [ApiService] Récupération données complètes: $type/$id');
      
      // Récupérer l'URL de partage
      final shareUrl = await getShareUrl(type: type, id: id, platform: platform);
      if (shareUrl == null) {
        print('❌ [ApiService] Impossible de récupérer l\'URL de partage');
        return null;
      }
      
      // Récupérer les métadonnées
      final metadata = await getShareMetadata(type: type, id: id);
      
      // Combiner les données
      final completeData = {
        'url': shareUrl,
        'title': metadata?['title'] ?? 'Dinor',
        'description': metadata?['description'] ?? 'Découvrez ceci sur Dinor',
        'image': metadata?['image'],
        'type': type,
        'id': id,
      };
      
      print('✅ [ApiService] Données complètes récupérées');
      return completeData;
    } catch (error) {
      print('💥 [ApiService] Erreur récupération données complètes: $error');
      return null;
    }
  }
}

// Provider pour Riverpod
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});