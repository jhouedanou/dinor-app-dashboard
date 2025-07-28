/**
 * AUTH_STORE.DART - CONVERSION FIDÈLE DE auth.js Vue/Pinia
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - État identique : user, token, loading, error
 * - Actions identiques : login(), register(), logout(), getProfile()
 * - Storage identique : SharedPreferences = localStorage
 * - Gestion d'erreurs identique
 * - API calls identiques via ApiService
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/api_service.dart';

// Provider pour l'état global d'authentification
final authStoreProvider = ChangeNotifierProvider<AuthStore>((ref) => AuthStore());

class AuthStore extends ChangeNotifier {
  static AuthStore? _instance;
  static AuthStore get instance => _instance ??= AuthStore._();
  
  AuthStore._() {
    _initAuth();
  }
  
  // État identique à auth.js Vue
  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = false;
  String? _error;
  
  // Getters identiques à auth.js
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  String get userName => _user?['name'] ?? '';
  String get userEmail => _user?['email'] ?? '';
  
  // IDENTIQUE à setToken() Vue
  Future<void> _setToken(String? newToken) async {
    _token = newToken;
    final prefs = await SharedPreferences.getInstance();
    
    if (newToken != null) {
      await prefs.setString('auth_token', newToken);
    } else {
      await prefs.remove('auth_token');
    }
    
    notifyListeners();
  }
  
  // IDENTIQUE à setUser() Vue
  Future<void> _setUser(Map<String, dynamic>? userData) async {
    _user = userData;
    final prefs = await SharedPreferences.getInstance();
    
    if (userData != null) {
      await prefs.setString('auth_user', jsonEncode(userData));
    } else {
      await prefs.remove('auth_user');
    }
    
    notifyListeners();
  }
  
  // IDENTIQUE à initAuth() Vue
  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    final savedUser = prefs.getString('auth_user');
    
    if (savedToken != null && savedUser != null) {
      _token = savedToken;
      try {
        final parsedUser = jsonDecode(savedUser) as Map<String, dynamic>;
        if (parsedUser.isNotEmpty) {
          _user = parsedUser;
          print('🔍 [AuthStore] Utilisateur restauré: ${parsedUser['name']}');
        } else {
          print('🔍 [AuthStore] Données utilisateur invalides');
          await clearAuth();
        }
      } catch (error) {
        print('🔍 [AuthStore] Erreur parsing utilisateur: $error');
        await clearAuth();
      }
    }
    
    notifyListeners();
  }
  
  // IDENTIQUE à clearAuth() Vue
  Future<void> clearAuth() async {
    await _setUser(null);
    await _setToken(null);
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    
    notifyListeners();
  }
  
  // REPRODUCTION EXACTE de register() Vue
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('🔐 [Auth] Tentative d\'inscription avec: ${userData.keys.toList()}');
      
      final data = await ApiService.instance.register(userData);
      
      print('📄 [Auth] Données de réponse: ${data['success']}');
      
      if (data['success'] == true) {
        await _setToken(data['data']['token']);
        await _setUser(data['data']['user']);
        print('✅ [Auth] Inscription réussie pour: ${data['data']['user']['name']}');
        return {'success': true, 'user': data['data']['user']};
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (err) {
      print('❌ [Auth] Erreur d\'inscription: ${err.toString()}');
      _error = err.toString();
      notifyListeners();
      return {'success': false, 'error': err.toString()};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // REPRODUCTION EXACTE de login() Vue
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    // Vérifier si l'utilisateur est déjà connecté
    if (isAuthenticated) {
      print('✅ [Auth] Utilisateur déjà connecté, pas besoin de se reconnecter');
      return {'success': true, 'user': _user};
    }
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('🔐 [Auth] Tentative de connexion pour: ${credentials['email']}');
      
      final data = await ApiService.instance.login(credentials);
      
      print('📩 [Auth] Réponse de connexion: ${data['success']}');
      
      if (data['success'] == true) {
        await _setToken(data['data']['token']);
        await _setUser(data['data']['user']);
        print('✅ [Auth] Connexion réussie pour: ${data['data']['user']['name']}');
        return {'success': true, 'user': data['data']['user']};
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la connexion');
      }
    } catch (err) {
      print('❌ [Auth] Erreur de connexion: ${err.toString()}');
      _error = err.toString();
      notifyListeners();
      return {'success': false, 'error': err.toString()};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // IDENTIQUE à logout() Vue
  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    
    try {
      if (_token != null) {
        await ApiService.instance.logout();
      }
    } catch (err) {
      print('Erreur lors de la déconnexion: $err');
    } finally {
      await clearAuth();
      _loading = false;
      print('👋 [Auth] Déconnexion terminée');
      notifyListeners();
    }
  }
  
  // IDENTIQUE à getProfile() Vue
  Future<Map<String, dynamic>?> getProfile() async {
    if (_token == null) return null;
    
    try {
      final data = await ApiService.instance.getProfile();
      if (data['success'] == true) {
        await _setUser(data['data']);
        return data['data'];
      }
    } catch (err) {
      print('Erreur lors de la récupération du profil: $err');
      if (err.toString().contains('401')) {
        // Token invalide, on déconnecte
        await clearAuth();
      }
    }
    
    return null;
  }
  
  // Initialiser au démarrage (équivalent initAuth() Vue)
  static Future<void> initialize() async {
    final store = AuthStore.instance;
    await store._initAuth();
  }
}

// Import Riverpod pour les providers
import 'package:flutter_riverpod/flutter_riverpod.dart';