import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationServiceSimple {
  static const String _appId = "d98be3fd-e812-47ea-a075-bca9a16b4f6b";
  
  static Future<void> initialize() async {
    debugPrint('🔔 [NotificationService] Initialisation OneSignal (version simple)...');
    
    try {
      // Configuration OneSignal basique
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_appId);
      
      // Demande de permission
      await requestPermission();
      
      // Configuration des événements de base
      _setupBasicEventListeners();
      
      debugPrint('✅ [NotificationService] OneSignal initialisé avec succès (version simple)');
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
  
  static void _setupBasicEventListeners() {
    try {
      // Notification reçue
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('🔔 [NotificationService] Notification reçue: ${event.notification.title}');
        
        // Afficher la notification
        event.preventDefault();
        event.notification.display();
      });
      
      // Notification cliquée
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('👆 [NotificationService] Notification cliquée: ${event.notification.title}');
        
        // Gérer l'URL si présente
        final data = event.notification.additionalData;
        if (data != null && data.containsKey('url')) {
          debugPrint('🔗 [NotificationService] URL trouvée: ${data['url']}');
        }
      });
      
      debugPrint('✅ [NotificationService] Event listeners configurés (version simple)');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur configuration listeners: $e');
    }
  }
  
  static Future<String?> getUserId() async {
    try {
      final userId = OneSignal.User.getOnesignalId();
      debugPrint('👤 [NotificationService] User ID: $userId');
      return userId;
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
} 