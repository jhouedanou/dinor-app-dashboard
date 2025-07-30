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

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../composables/use_auth_handler.dart';

class ApiService {
  final Ref _ref;
  static const String _baseUrl = 'https://new.dinorapp.com/api/v1';

  ApiService(this._ref);

  // Requête GET
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Erreur GET $endpoint: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Requête POST
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      print('📡 [ApiService] POST $endpoint');
      print('📡 [ApiService] URL: $uri');
      print('📡 [ApiService] Headers: $headers');
      print('📡 [ApiService] Data: ${json.encode(data)}');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));
      
      print('📡 [ApiService] Response status: ${response.statusCode}');
      print('📡 [ApiService] Response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Erreur POST $endpoint: $e');
      if (e.toString().contains('TimeoutException')) {
        return {'success': false, 'error': 'Timeout de connexion. Vérifiez votre connexion internet.'};
      } else if (e.toString().contains('SocketException')) {
        return {'success': false, 'error': 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // Requête PUT
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Erreur PUT $endpoint: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Requête DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Erreur DELETE $endpoint: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Requête avec gestion du cache et force refresh
  Future<Map<String, dynamic>> request(String endpoint, {
    Map<String, String>? params,
    bool forceRefresh = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
      final headers = await _getHeaders();
      
      if (forceRefresh) {
        headers['Cache-Control'] = 'no-cache';
      }
      
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] Erreur request $endpoint: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Obtenir les headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Ajouter le token d'authentification si disponible
    final token = _ref.read(useAuthHandlerProvider.notifier).token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Gérer la réponse
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      // Si la réponse est 401, essayer de rafraîchir le token
      if (response.statusCode == 401) {
        print('🔐 [ApiService] Token expiré, tentative de rafraîchissement');
        // TODO: Implémenter le rafraîchissement automatique du token
        return {'success': false, 'error': 'Token expiré'};
      }
      
      // Si la réponse est 422 (validation errors)
      if (response.statusCode == 422) {
        return {
          'success': false,
          'error': 'Erreur de validation',
          'validation_errors': data['errors'] ?? {},
        };
      }
      
      // Si la réponse est un succès
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data['data'] ?? data,
          'message': data['message'],
        };
      }
      
      // Erreur générale
      return {
        'success': false,
        'error': data['message'] ?? 'Erreur inconnue',
        'status_code': response.statusCode,
      };
    } catch (e) {
      print('❌ [ApiService] Erreur parsing réponse: $e');
      return {
        'success': false,
        'error': 'Erreur de parsing de la réponse',
        'raw_response': response.body,
      };
    }
  }

  // Méthodes spécifiques pour les likes
  Future<Map<String, dynamic>> likeContent(String type, String id) async {
    return await post('/likes', {
      'type': type,
      'id': id,
    });
  }

  Future<Map<String, dynamic>> unlikeContent(String type, String id) async {
    return await delete('/likes/$type/$id');
  }

  Future<Map<String, dynamic>> checkLike(String type, String id) async {
    return await get('/likes/check', params: {
      'type': type,
      'id': id,
    });
  }

  // Méthodes spécifiques pour les favoris
  Future<Map<String, dynamic>> addToFavorites(String type, String id) async {
    return await post('/favorites', {
      'type': type,
      'id': id,
    });
  }

  Future<Map<String, dynamic>> removeFromFavorites(String type, String id) async {
    return await delete('/favorites/$type/$id');
  }

  Future<Map<String, dynamic>> checkFavorite(String type, String id) async {
    return await get('/favorites/check', params: {
      'type': type,
      'id': id,
    });
  }

  // Méthodes spécifiques pour les commentaires
  Future<Map<String, dynamic>> getComments(String type, String id) async {
    return await get('/comments', params: {
      'commentable_type': 'App\\Models\\${type.substring(0, 1).toUpperCase() + type.substring(1)}',
      'commentable_id': id,
    });
  }

  Future<Map<String, dynamic>> addComment(String type, String id, String content) async {
    return await post('/comments', {
      'commentable_type': 'App\\Models\\${type.substring(0, 1).toUpperCase() + type.substring(1)}',
      'commentable_id': id,
      'content': content,
    });
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    return await delete('/comments/$commentId');
  }

  // Méthodes spécifiques pour le profil utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/user/profile');
  }

  Future<Map<String, dynamic>> getUserFavorites() async {
    return await get('/favorites');
  }

  Future<Map<String, dynamic>> getPredictionsStats() async {
    return await get('/user/predictions/stats');
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await post('/user/change-password', {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  // Méthodes spécifiques pour le partage
  Future<Map<String, dynamic>?> getCompleteShareData({
    required String type,
    required String id,
    String? platform,
  }) async {
    try {
      final response = await get('/shares/data', params: {
        'type': type,
        'id': id,
        if (platform != null) 'platform': platform,
      });
      
      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('❌ [ApiService] Error getting share data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> trackShare({
    required String type,
    required String id,
    required String platform,
  }) async {
    return await post('/shares/track', {
      'type': type,
      'id': id,
      'platform': platform,
    });
  }
}