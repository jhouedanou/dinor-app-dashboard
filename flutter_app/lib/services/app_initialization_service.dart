/// APP_INITIALIZATION_SERVICE.DART - SERVICE D'INITIALISATION DE L'APP
/// 
/// FONCTIONNALITÉS :
/// - Chargement automatique des likes au démarrage
/// - Synchronisation avec le serveur
/// - Gestion de l'état d'authentification
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'likes_service.dart';
import 'favorites_service.dart';
import '../composables/use_auth_handler.dart';

class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  bool _isInitialized = false;

  Future<void> initializeApp(WidgetRef ref) async {
    if (_isInitialized) {
      print('⚠️ [AppInit] App déjà initialisée');
      return;
    }

    try {
      print('🚀 [AppInit] Démarrage de l\'initialisation...');
      
      // Vérifier l'état d'authentification
      final authState = ref.read(useAuthHandlerProvider);
      print('🔐 [AppInit] État authentification: ${authState.isAuthenticated}');
      
      if (authState.isAuthenticated) {
        print('✅ [AppInit] Utilisateur authentifié, chargement des données...');
        
        // Charger les likes
        await _initializeLikes(ref);
        
        // Charger les favoris
        await _initializeFavorites(ref);
        
        print('✅ [AppInit] Initialisation terminée avec succès');
      } else {
        print('⚠️ [AppInit] Utilisateur non authentifié, initialisation minimale');
      }
      
      _isInitialized = true;
    } catch (e) {
      print('❌ [AppInit] Erreur lors de l\'initialisation: $e');
    }
  }

  Future<void> _initializeLikes(WidgetRef ref) async {
    try {
      print('❤️ [AppInit] Initialisation des likes...');
      
      // Charger les likes depuis le cache et synchroniser avec le serveur
      await ref.read(likesProvider.notifier).syncWithServer();
      
      print('✅ [AppInit] Likes initialisés');
    } catch (e) {
      print('❌ [AppInit] Erreur initialisation likes: $e');
    }
  }

  Future<void> _initializeFavorites(WidgetRef ref) async {
    try {
      print('⭐ [AppInit] Initialisation des favoris...');
      
      // Charger les favoris
      await ref.read(favoritesServiceProvider.notifier).loadFavorites();
      
      print('✅ [AppInit] Favoris initialisés');
    } catch (e) {
      print('❌ [AppInit] Erreur initialisation favoris: $e');
    }
  }

  Future<void> reinitialize(WidgetRef ref) async {
    print('🔄 [AppInit] Réinitialisation...');
    _isInitialized = false;
    await initializeApp(ref);
  }

  Future<void> forceSyncAll(WidgetRef ref) async {
    try {
      print('🔄 [AppInit] Synchronisation forcée de tous les services...');
      
      // Forcer la synchronisation des likes
      await ref.read(likesProvider.notifier).forceSync();
      
      // Forcer la synchronisation des favoris
      await ref.read(favoritesServiceProvider.notifier).loadFavorites(refresh: true);
      
      print('✅ [AppInit] Synchronisation forcée terminée');
    } catch (e) {
      print('❌ [AppInit] Erreur synchronisation forcée: $e');
    }
  }

  bool get isInitialized => _isInitialized;
}

// Provider pour le service d'initialisation
final appInitializationServiceProvider = Provider<AppInitializationService>((ref) {
  return AppInitializationService();
}); 