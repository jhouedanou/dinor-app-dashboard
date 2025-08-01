import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static const String _appId = "d98be3fd-e812-47ea-a075-bca9a16b4f6b";
  
  static Future<void> initialize() async {
    debugPrint('🔔 [NotificationService] Initialisation OneSignal...');
    
    try {
      // Configuration OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_appId);
      
      // Demande de permission
      await requestPermission();
      
      // Configuration des événements
      _setupEventListeners();
      
      debugPrint('✅ [NotificationService] OneSignal initialisé avec succès');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur d\'initialisation: $e');
    }
  }
  
  static Future<void> requestPermission() async {
    try {
      debugPrint('📱 [NotificationService] Demande de permission...');
      
      final permission = await OneSignal.Notifications.requestPermission(true);
      debugPrint('📱 [NotificationService] Permission accordée: $permission');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur permission: $e');
    }
  }
  
  static void _setupEventListeners() {
    try {
      // Notification reçue en foreground
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('🔔 [NotificationService] Notification reçue en foreground: ${event.notification.title}');
        
        // Afficher la notification même en foreground
        event.preventDefault();
        event.notification.display();
      });
      
      // Notification cliquée
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('👆 [NotificationService] Notification cliquée: ${event.notification.title}');
        
        // Gérer l'URL de redirection si présente
        final data = event.notification.additionalData;
        if (data != null && data.containsKey('url')) {
          _handleNotificationUrl(data['url']);
        }
      });
      
      // Changement de l'ID utilisateur
      OneSignal.User.addObserver((state) {
        debugPrint('👤 [NotificationService] User ID changé: ${state.current.onesignalId}');
      });
      
      debugPrint('✅ [NotificationService] Event listeners configurés');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur configuration listeners: $e');
    }
  }
  
  static void _handleNotificationUrl(String url) {
    debugPrint('🔗 [NotificationService] Redirection vers: $url');
    // Ici vous pouvez implémenter la navigation vers l'URL
    // Exemple : NavigationService.pushNamed(url);
  }
  
  static Future<String?> getUserId() async {
    try {
      final state = OneSignal.User.getOnesignalId();
      debugPrint('👤 [NotificationService] User ID: $state');
      return state;
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur getUserId: $e');
      return null;
    }
  }
  
  static void setExternalUserId(String userId) {
    try {
      OneSignal.login(userId);
      debugPrint('👤 [NotificationService] External User ID défini: $userId');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur setExternalUserId: $e');
    }
  }
  
  static void addTag(String key, String value) {
    try {
      OneSignal.User.addTag(key, value);
      debugPrint('🏷️ [NotificationService] Tag ajouté: $key = $value');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur addTag: $e');
    }
  }
  
  static void removeTag(String key) {
    try {
      OneSignal.User.removeTag(key);
      debugPrint('🏷️ [NotificationService] Tag supprimé: $key');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur removeTag: $e');
    }
  }
} 