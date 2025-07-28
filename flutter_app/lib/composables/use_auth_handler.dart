import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userName;
  final String? userEmail;
  final String? token;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isAuthenticated = false,
    this.userName,
    this.userEmail,
    this.token,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? userEmail,
    String? token,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  
  AuthNotifier(this._apiService) : super(const AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      
      if (token != null) {
        state = AuthState(
          isAuthenticated: true,
          userName: userName,
          userEmail: userEmail,
          token: token,
        );
        print('🔐 [AuthNotifier] Authentification restaurée depuis le stockage');
      }
    } catch (error) {
      print('❌ [AuthNotifier] Erreur chargement auth stockée: $error');
    }
  }

  Future<void> _storeAuth(String token, String userName, String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_name', userName);
      await prefs.setString('user_email', userEmail);
      print('💾 [AuthNotifier] Authentification sauvegardée');
    } catch (error) {
      print('❌ [AuthNotifier] Erreur sauvegarde auth: $error');
    }
  }

  Future<void> _clearStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      print('🧹 [AuthNotifier] Authentification supprimée du stockage');
    } catch (error) {
      print('❌ [AuthNotifier] Erreur suppression auth: $error');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('🔐 [AuthNotifier] Tentative de connexion pour: $email');
      
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response['success']) {
        final user = response['data']['user'];
        final token = response['data']['token'];
        
        // Sauvegarder l'authentification
        await _storeAuth(
          token,
          user['name'] ?? '',
          user['email'] ?? '',
        );
        
        // Mettre à jour l'état
        state = AuthState(
          isAuthenticated: true,
          userName: user['name'],
          userEmail: user['email'],
          token: token,
          user: user,
        );
        
        print('✅ [AuthNotifier] Connexion réussie pour: ${user['name']}');
        return true;
      }
      
      return false;
    } catch (error) {
      print('❌ [AuthNotifier] Erreur connexion: $error');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      print('📝 [AuthNotifier] Tentative d\'inscription pour: $email');
      
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      
      if (response['success']) {
        final user = response['data']['user'];
        final token = response['data']['token'];
        
        // Sauvegarder l'authentification
        await _storeAuth(
          token,
          user['name'] ?? '',
          user['email'] ?? '',
        );
        
        // Mettre à jour l'état
        state = AuthState(
          isAuthenticated: true,
          userName: user['name'],
          userEmail: user['email'],
          token: token,
          user: user,
        );
        
        print('✅ [AuthNotifier] Inscription réussie pour: ${user['name']}');
        return true;
      }
      
      return false;
    } catch (error) {
      print('❌ [AuthNotifier] Erreur inscription: $error');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 [AuthNotifier] Déconnexion de: ${state.userName}');
      
      // Appeler l'API de déconnexion si nécessaire
      if (state.token != null) {
        try {
          await _apiService.post('/auth/logout', {});
        } catch (error) {
          print('⚠️ [AuthNotifier] Erreur API déconnexion (ignorée): $error');
        }
      }
      
      // Nettoyer le stockage
      await _clearStoredAuth();
      
      // Réinitialiser l'état
      state = const AuthState();
      
      print('✅ [AuthNotifier] Déconnexion réussie');
    } catch (error) {
      print('❌ [AuthNotifier] Erreur déconnexion: $error');
    }
  }

  Future<bool> checkAuth() async {
    try {
      if (!state.isAuthenticated || state.token == null) {
        return false;
      }
      
      final response = await _apiService.get('/auth/me');
      return response['success'];
    } catch (error) {
      print('❌ [AuthNotifier] Erreur vérification auth: $error');
      // Si erreur, considérer comme non authentifié
      await logout();
      return false;
    }
  }

  String? get token => state.token;
  bool get isAuthenticated => state.isAuthenticated;
  String? get userName => state.userName;
  String? get userEmail => state.userEmail;
  Map<String, dynamic>? get user => state.user;
}

final useAuthHandlerProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthNotifier(apiService);
}); 