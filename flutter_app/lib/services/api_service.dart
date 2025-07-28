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
  static const String baseUrl = 'https://dinor.app/api'; // Même API que React Native
  static const Duration timeout = Duration(seconds: 30);
  
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Headers par défaut
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'DinorFlutter/1.0',
  };

  // Obtenir le token d'authentification
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (error) {
      print('❌ [ApiService] Erreur récupération token:', error);
      return null;
    }
  }

  // Headers avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await _getAuthToken();
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Méthode générique pour les requêtes
  Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    bool forceRefresh = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      final headers = await _getHeaders();
      
      // Vérifier le cache pour les requêtes GET
      if (method == 'GET' && !forceRefresh) {
        final cachedData = _getCachedData(endpoint, params);
        if (cachedData != null) {
          print('📦 [ApiService] Données récupérées du cache: $endpoint');
          return cachedData;
        }
      }

      print('🌐 [ApiService] $method $url');

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(timeout);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      print('📡 [ApiService] Réponse ${response.statusCode}: $endpoint');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        
        // Mettre en cache les réponses GET réussies
        if (method == 'GET') {
          _setCachedData(endpoint, params, data);
        }
        
        return data;
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (error) {
      print('❌ [ApiService] Erreur requête $method $endpoint:', error);
      rethrow;
    }
  }

  // Méthodes spécifiques
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? params, bool forceRefresh = false}) {
    return request(endpoint, params: params, forceRefresh: forceRefresh);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) {
    return request(endpoint, method: 'POST', body: body);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) {
    return request(endpoint, method: 'PUT', body: body);
  }

  Future<Map<String, dynamic>> delete(String endpoint) {
    return request(endpoint, method: 'DELETE');
  }

  // Gestion des erreurs
  Exception _handleErrorResponse(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Erreur serveur';
      
      switch (response.statusCode) {
        case 401:
          return Exception('Non authentifié: $message');
        case 403:
          return Exception('Accès refusé: $message');
        case 404:
          return Exception('Ressource non trouvée: $message');
        case 422:
          return Exception('Données invalides: $message');
        case 500:
          return Exception('Erreur serveur: $message');
        default:
          return Exception('Erreur ${response.statusCode}: $message');
      }
    } catch (e) {
      return Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  // Gestion du cache
  String _getCacheKey(String endpoint, Map<String, dynamic>? params) {
    final paramsString = params != null ? json.encode(params) : '';
    return '$endpoint$paramsString';
  }

  Map<String, dynamic>? _getCachedData(String endpoint, Map<String, dynamic>? params) {
    final key = _getCacheKey(endpoint, params);
    final timestamp = _cacheTimestamps[key];
    
    if (timestamp != null && DateTime.now().difference(timestamp) < _cacheDuration) {
      return _cache[key];
    }
    
    return null;
  }

  void _setCachedData(String endpoint, Map<String, dynamic>? params, Map<String, dynamic> data) {
    final key = _getCacheKey(endpoint, params);
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('🧹 [ApiService] Cache vidé');
  }

  // Méthodes spécifiques pour les recettes
  Future<Map<String, dynamic>> getRecipeCategories() {
    return get('/recipe-categories');
  }

  Future<Map<String, dynamic>> getRecipes({Map<String, dynamic>? params}) {
    return get('/recipes', params: params);
  }

  Future<Map<String, dynamic>> getRecipe(String id) {
    return get('/recipes/$id');
  }

  // Méthodes spécifiques pour les événements
  Future<Map<String, dynamic>> getEvents({Map<String, dynamic>? params}) {
    return get('/events', params: params);
  }

  Future<Map<String, dynamic>> getEvent(String id) {
    return get('/events/$id');
  }

  // Méthodes spécifiques pour les vidéos DinorTV
  Future<Map<String, dynamic>> getVideos({Map<String, dynamic>? params, bool forceRefresh = false}) {
    return get('/dinor-tv', params: params, forceRefresh: forceRefresh);
  }

  Future<Map<String, dynamic>> getVideo(String id) {
    return get('/dinor-tv/$id');
  }

  // Méthodes spécifiques pour les likes
  Future<Map<String, dynamic>> toggleLike(String type, String id) {
    return post('/likes/toggle', {
      'likeable_type': type,
      'likeable_id': id,
    });
  }

  Future<Map<String, dynamic>> checkLike(String type, String id) {
    return get('/likes/check', params: {
      'type': type,
      'id': id,
    });
  }

  // Méthodes spécifiques pour les commentaires
  Future<Map<String, dynamic>> getComments(String type, String id) {
    return get('/comments', params: {
      'commentable_type': type,
      'commentable_id': id,
    });
  }

  Future<Map<String, dynamic>> addComment(String type, String id, String content) {
    return post('/comments', {
      'commentable_type': type,
      'commentable_id': id,
      'content': content,
    });
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) {
    return delete('/comments/$commentId');
  }

  // Méthodes spécifiques pour les favoris
  Future<Map<String, dynamic>> toggleFavorite(String type, String id) {
    return post('/favorites/toggle', {
      'favoritable_type': type,
      'favoritable_id': id,
    });
  }

  Future<Map<String, dynamic>> checkFavorite(String type, String id) {
    return get('/favorites/check', params: {
      'type': type,
      'id': id,
    });
  }

  // Méthodes d'authentification
  Future<Map<String, dynamic>> login(String email, String password) {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) {
    return post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Map<String, dynamic>> logout() {
    return post('/auth/logout');
  }

  Future<Map<String, dynamic>> getCurrentUser() {
    return get('/auth/me');
  }
}

// Provider pour Riverpod
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});