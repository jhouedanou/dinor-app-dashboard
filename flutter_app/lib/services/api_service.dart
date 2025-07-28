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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  
  ApiService._();
  
  late String _baseURL;
  String? _authToken;
  
  // Configuration identique à api.js Vue
  static Future<void> initialize() async {
    final instance = ApiService.instance;
    instance._baseURL = instance._getBaseURL();
    await instance._loadAuthToken();
    
    print('📡 [API] Service initialisé avec baseURL: ${instance._baseURL}');
  }
  
  String _getBaseURL() {
    // Configuration identique à Vue/React Native
    if (kDebugMode) {
      return 'http://localhost:8000/api/v1'; // Dev avec proxy
    }
    return 'https://dinor.app/api/v1'; // Production
  }
  
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    print('🔐 [API] Token d\'authentification: ${_authToken != null ? '***existe***' : 'null'}');
  }
  
  Future<void> _saveAuthToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
      _authToken = token;
    } else {
      await prefs.remove('auth_token');
      _authToken = null;
    }
  }
  
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest', // Identique Laravel Vue
    };
    
    // Ajouter token Bearer si disponible (identique à Vue)
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<Map<String, dynamic>> _request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final url = Uri.parse('$_baseURL$endpoint');
    final headers = {..._getHeaders(), ...?additionalHeaders};
    
    print('📡 [API] Requête vers: $endpoint (${method.toUpperCase()})');
    print('🔐 [API] Headers: ${headers.keys.toList()}');
    
    try {
      late http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }
      
      print('📡 [API] Réponse reçue: ${response.statusCode}');
      
      // Gestion d'erreurs identique à Vue
      if (!_isSuccessStatusCode(response.statusCode)) {
        if (response.statusCode == 401) {
          print('🔒 [API] Erreur 401 - Token invalide ou manquant');
          await _saveAuthToken(null); // Clear invalid token
        }
        
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP error! status: ${response.statusCode}',
        );
      }
      
      // Parse JSON response (structure identique Vue/Laravel)
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('✅ [API] Réponse JSON: success=${data['success']}, endpoint=$endpoint');
      
      return data;
      
    } catch (e) {
      print('❌ [API] Erreur de requête: $endpoint - ${e.toString()}');
      rethrow;
    }
  }
  
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  // RECIPES - Endpoints identiques à Vue/React Native
  Future<Map<String, dynamic>> getRecipes({Map<String, dynamic>? params}) async {
    String endpoint = '/recipes';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> getRecipe(String id) async {
    return _request('/recipes/$id');
  }
  
  Future<Map<String, dynamic>> getRecipesFresh({Map<String, dynamic>? params}) async {
    // Force fresh data (équivalent requestFresh Vue)
    return getRecipes(params: {...?params, '_t': DateTime.now().millisecondsSinceEpoch});
  }
  
  Future<Map<String, dynamic>> getRecipeFresh(String id) async {
    return _request('/recipes/$id?_t=${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // TIPS - Endpoints identiques
  Future<Map<String, dynamic>> getTips({Map<String, dynamic>? params}) async {
    String endpoint = '/tips';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> getTip(String id) async {
    return _request('/tips/$id');
  }
  
  Future<Map<String, dynamic>> getTipsFresh({Map<String, dynamic>? params}) async {
    return getTips(params: {...?params, '_t': DateTime.now().millisecondsSinceEpoch});
  }
  
  Future<Map<String, dynamic>> getTipFresh(String id) async {
    return _request('/tips/$id?_t=${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // EVENTS - Endpoints identiques
  Future<Map<String, dynamic>> getEvents({Map<String, dynamic>? params}) async {
    String endpoint = '/events';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> getEvent(String id) async {
    return _request('/events/$id');
  }
  
  Future<Map<String, dynamic>> getEventsFresh({Map<String, dynamic>? params}) async {
    return getEvents(params: {...?params, '_t': DateTime.now().millisecondsSinceEpoch});
  }
  
  Future<Map<String, dynamic>> getEventFresh(String id) async {
    return _request('/events/$id?_t=${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // DINOR TV - Endpoints identiques
  Future<Map<String, dynamic>> getVideos({Map<String, dynamic>? params}) async {
    String endpoint = '/dinor-tv';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> getVideo(String id) async {
    return _request('/dinor-tv/$id');
  }
  
  Future<Map<String, dynamic>> getVideosFresh({Map<String, dynamic>? params}) async {
    return getVideos(params: {...?params, '_t': DateTime.now().millisecondsSinceEpoch});
  }
  
  Future<Map<String, dynamic>> getVideoFresh(String id) async {
    return _request('/dinor-tv/$id?_t=${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // INTERACTIONS - Identiques à Vue
  Future<Map<String, dynamic>> toggleLike(String type, String id) async {
    final result = await _request(
      '/$type/$id/like',
      method: 'POST',
    );
    print('🔄 [API] Toggle like: $type $id');
    return result;
  }
  
  Future<Map<String, dynamic>> getComments(String type, String id) async {
    return _request('/$type/$id/comments');
  }
  
  Future<Map<String, dynamic>> addComment(String type, String id, String content) async {
    return _request(
      '/$type/$id/comments',
      method: 'POST',
      body: {'content': content},
    );
  }
  
  // CATEGORIES - Identiques à Vue
  Future<Map<String, dynamic>> getCategories() async {
    return _request('/categories');
  }
  
  Future<Map<String, dynamic>> getEventCategories() async {
    return _request('/categories/events');
  }
  
  Future<Map<String, dynamic>> getRecipeCategories() async {
    return _request('/categories/recipes');
  }
  
  // SEARCH - Identique à Vue
  Future<Map<String, dynamic>> search(String query, {String? type}) async {
    final params = {'q': query};
    if (type != null) params['type'] = type;
    
    final queryString = Uri(queryParameters: params).query;
    return _request('/search?$queryString');
  }
  
  // FAVORITES - Identiques à Vue
  Future<Map<String, dynamic>> getFavorites({Map<String, dynamic>? params}) async {
    String endpoint = '/favorites';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> toggleFavorite(String type, String id) async {
    return _request(
      '/favorites/toggle',
      method: 'POST',
      body: {
        'type': type,
        'id': id,
      },
    );
  }
  
  Future<Map<String, dynamic>> checkFavorite(String type, String id) async {
    return _request('/favorites/check?type=$type&id=$id');
  }
  
  Future<Map<String, dynamic>> removeFavorite(String favoriteId) async {
    return _request('/favorites/$favoriteId', method: 'DELETE');
  }
  
  // AUTHENTICATION - Système identique Vue/Laravel
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    print('🔐 [Auth] Tentative d\'inscription avec: ${userData.keys.toList()}');
    
    final data = await _request(
      '/auth/register',
      method: 'POST',
      body: userData,
    );
    
    if (data['success'] == true && data['data']?['token'] != null) {
      await _saveAuthToken(data['data']['token']);
      print('✅ [Auth] Inscription réussie');
    }
    
    return data;
  }
  
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    print('🔐 [Auth] Tentative de connexion pour: ${credentials['email']}');
    
    final data = await _request(
      '/auth/login',
      method: 'POST',
      body: credentials,
    );
    
    if (data['success'] == true && data['data']?['token'] != null) {
      await _saveAuthToken(data['data']['token']);
      print('✅ [Auth] Connexion réussie');
    }
    
    return data;
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      if (_authToken != null) {
        await _request('/auth/logout', method: 'POST');
      }
    } catch (e) {
      print('⚠️ [Auth] Erreur lors de la déconnexion: $e');
    } finally {
      await _saveAuthToken(null);
      print('👋 [Auth] Déconnexion terminée');
    }
    
    return {'success': true};
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    if (_authToken == null) {
      throw ApiException(statusCode: 401, message: 'Non authentifié');
    }
    
    try {
      final data = await _request('/auth/profile');
      if (data['success'] == true) {
        return data;
      }
      throw ApiException(statusCode: 400, message: data['message'] ?? 'Erreur inconnue');
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        await _saveAuthToken(null); // Clear invalid token
      }
      rethrow;
    }
  }
  
  // PAGES - Pour bannières et contenu statique
  Future<Map<String, dynamic>> getPages({Map<String, dynamic>? params}) async {
    String endpoint = '/pages';
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
      endpoint += '?$queryString';
    }
    return _request(endpoint);
  }
  
  Future<Map<String, dynamic>> getPage(String id) async {
    return _request('/pages/$id');
  }
  
  // UTILITY METHODS
  Future<void> clearCache() async {
    print('🗑️ [API] Nettoyage du cache (équivalent Vue clearCache)');
    // En Flutter, pas de cache côté service (communication directe comme Vue)
    // On peut invalider les stores Provider/Riverpod si nécessaire
  }
  
  bool get isAuthenticated => _authToken != null;
  String? get authToken => _authToken;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({required this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}