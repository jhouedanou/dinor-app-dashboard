import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/likes_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

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
  final LikesService _likesService;
  
  AuthNotifier(this._apiService, this._likesService) : super(const AuthState()) {
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
      print('🔐 [AuthNotifier] Endpoint: https://new.dinorapp.com/api/v1/auth/login');
      
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      print('🔐 [AuthNotifier] Réponse de l\'API: $response');
      
      if (response['success'] == true) {
        print('✅ [AuthNotifier] Réponse API positive');
        final data = response['data'];
        print('🔐 [AuthNotifier] Data structure: ${data.keys.toList()}');
        
        final user = data['user'];
        final token = data['token'];
        
        if (user == null || token == null) {
          print('❌ [AuthNotifier] Données manquantes - user: $user, token: $token');
          return false;
        }
        
        print('🔐 [AuthNotifier] User data: ${user.toString()}');
        print('🔐 [AuthNotifier] Token: ${token.toString().substring(0, 20)}...');
        
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
        
        // Sync user likes after successful login
        await _likesService.syncWithServer();
        
        return true;
      } else {
        print('❌ [AuthNotifier] Échec de connexion - response success: ${response['success']}');
        print('❌ [AuthNotifier] Error: ${response['error']}');
        print('❌ [AuthNotifier] Message: ${response['message']}');
        return false;
      }
      
    } catch (error) {
      print('❌ [AuthNotifier] Exception lors de la connexion: $error');
      print('❌ [AuthNotifier] Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      print('📝 [AuthNotifier] Tentative d\'inscription pour: $email');
      print('📝 [AuthNotifier] Endpoint: https://new.dinorapp.com/api/v1/auth/register');
      
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      
      print('📝 [AuthNotifier] Réponse de l\'API: $response');
      
      if (response['success'] == true) {
        print('✅ [AuthNotifier] Réponse API positive');
        final data = response['data'];
        final user = data['user'];
        final token = data['token'];
        
        if (user == null || token == null) {
          print('❌ [AuthNotifier] Données manquantes - user: $user, token: $token');
          return false;
        }
        
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
        
        // Sync user likes after successful registration
        await _likesService.syncWithServer();
        
        return true;
      } else {
        print('❌ [AuthNotifier] Échec d\'inscription - response success: ${response['success']}');
        print('❌ [AuthNotifier] Error: ${response['error']}');
        print('❌ [AuthNotifier] Message: ${response['message']}');
        print('❌ [AuthNotifier] Validation errors: ${response['validation_errors']}');
        return false;
      }
      
    } catch (error) {
      print('❌ [AuthNotifier] Exception lors de l\'inscription: $error');
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
      
      // Clear user likes
      _likesService.clearUserLikes();
      
      // Réinitialiser l'état
      state = const AuthState();
      
      print('✅ [AuthNotifier] Déconnexion réussie');
    } catch (error) {
      print('❌ [AuthNotifier] Erreur déconnexion: $error');
    }
  }

  Future<bool> loginAsGuest() async {
    try {
      print('👤 [AuthNotifier] Connexion en tant qu\'invité');
      
      // Créer un token invité simple avec timestamp
      final guestToken = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      
      state = AuthState(
        isAuthenticated: true,
        userName: 'Invité',
        userEmail: 'invite@dinor.app',
        token: guestToken,
      );
      
      await _storeAuth(guestToken, 'Invité', 'invite@dinor.app');
      print('✅ [AuthNotifier] Connexion invité réussie');
      return true;
    } catch (error) {
      print('❌ [AuthNotifier] Erreur connexion invité: $error');
      return false;
    }
  }

  Future<bool> checkAuth() async {
    try {
      print('🔐 [AuthNotifier] Vérification de l\'authentification...');
      print('🔐 [AuthNotifier] État actuel: isAuthenticated=${state.isAuthenticated}, token=${state.token != null ? "Présent" : "Absent"}');
      
      if (!state.isAuthenticated || state.token == null) {
        print('❌ [AuthNotifier] Pas authentifié ou token manquant');
        return false;
      }
      
      // Si c'est un token invité, considérer comme valide
      if (state.token!.startsWith('guest_')) {
        print('✅ [AuthNotifier] Token invité valide');
        return true;
      }
      
      final response = await _apiService.get('/auth/me');
      final isValid = response['success'];
      print('🔐 [AuthNotifier] Vérification API: $isValid');
      
      if (!isValid) {
        print('❌ [AuthNotifier] Token invalide, déconnexion...');
        await logout();
      }
      
      return isValid;
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
  final likesService = ref.read(likesServiceProvider);
  return AuthNotifier(apiService, likesService);
}); 