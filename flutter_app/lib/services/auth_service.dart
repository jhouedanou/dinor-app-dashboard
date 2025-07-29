import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _baseUrl = 'https://new.dinorapp.com/api/v1';

  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _token != null;

  // Initialiser le service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      _user = json.decode(userData);
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        _token = data['data']['token'];
        _user = data['data']['user'];
        
        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userKey, json.encode(_user));
        
        print('✅ [AuthService] Connexion réussie');
        return true;
      } else {
        print('❌ [AuthService] Erreur connexion: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('❌ [AuthService] Erreur connexion: $e');
      return false;
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        _token = data['data']['token'];
        _user = data['data']['user'];
        
        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userKey, json.encode(_user));
        
        print('✅ [AuthService] Inscription réussie');
        return true;
      } else {
        print('❌ [AuthService] Erreur inscription: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('❌ [AuthService] Erreur inscription: $e');
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      if (_token != null) {
        // Appeler l'API de déconnexion
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      print('❌ [AuthService] Erreur déconnexion API: $e');
    } finally {
      // Nettoyer les données locales
      _token = null;
      _user = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      print('✅ [AuthService] Déconnexion réussie');
    }
  }

  // Obtenir le token
  String? get token => _token;

  // Obtenir l'utilisateur
  Map<String, dynamic>? get user => _user;

  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _token != null;

  // Rafraîchir le token
  Future<bool> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        _token = data['data']['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        
        print('✅ [AuthService] Token rafraîchi');
        return true;
      } else {
        print('❌ [AuthService] Erreur rafraîchissement token');
        return false;
      }
    } catch (e) {
      print('❌ [AuthService] Erreur rafraîchissement token: $e');
      return false;
    }
  }

  // Valider le token
  Future<bool> validateToken() async {
    if (_token == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _user = data['data'];
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, json.encode(_user));
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ [AuthService] Erreur validation token: $e');
      return false;
    }
  }
} 