import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'navigation_service.dart';

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
      
      // Attendre un peu pour que l'inscription se fasse
      await Future.delayed(Duration(seconds: 2));
      
      // Récupérer et afficher l'ID utilisateur
      final userId = OneSignal.User.getOnesignalId();
      debugPrint('🆔 [NotificationService] OneSignal User ID: $userId');
      
      // Vérifier l'état de la subscription
      final subscriptionId = OneSignal.User.pushSubscription.id;
      debugPrint('📱 [NotificationService] Subscription ID: $subscriptionId');
      final subscriptionOptedIn = OneSignal.User.pushSubscription.optedIn;
      debugPrint('📱 [NotificationService] Subscription OptedIn: $subscriptionOptedIn');
      
      if (userId == null || subscriptionId == null) {
        debugPrint('⚠️ [NotificationService] PROBLÈME: User ID ou Subscription ID manquant');
        debugPrint('⚠️ [NotificationService] Tentative de forcer l\'inscription...');
        
        // Forcer l'opt-in
        await OneSignal.User.pushSubscription.optIn();
        debugPrint('🔄 [NotificationService] Opt-in forcé, attente 2 secondes...');
        
        await Future.delayed(Duration(seconds: 2));
        final newUserId = OneSignal.User.getOnesignalId();
        final newSubscriptionId = OneSignal.User.pushSubscription.id;
        debugPrint('🆔 [NotificationService] Nouveau User ID: $newUserId');
        debugPrint('📱 [NotificationService] Nouveau Subscription ID: $newSubscriptionId');
      }
      
      // TEST DE NAVIGATION (à supprimer après debug)
      debugPrint('🧪 [NotificationService] Test de navigation dans 10 secondes...');
      Future.delayed(Duration(seconds: 10), () {
        debugPrint('🧪 [NotificationService] Lancement du test de navigation...');
        testNavigation();
      });
      
      debugPrint('✅ [NotificationService] OneSignal initialisé avec succès');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur d\'initialisation: $e');
    }
  }
  
  // Méthode de test pour vérifier la navigation
  static void testNavigation() {
    try {
      debugPrint('🧪 [NotificationService] Test de navigation vers recette ID: 1');
      _handleContentNavigation('recipe', '1');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur test navigation: $e');
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
        
        // TOUJOURS afficher la notification en bannière, même en foreground
        // Ne pas appeler event.preventDefault() pour permettre l'affichage système
        debugPrint('📱 [NotificationService] Affichage de la notification en bannière système');
        
        // La notification sera automatiquement affichée en bannière
        // car on ne prévient pas son affichage par défaut
      });
      
      // Notification cliquée
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('👆 [NotificationService] =================================');
        debugPrint('👆 [NotificationService] Notification cliquée: ${event.notification.title}');
        debugPrint('👆 [NotificationService] =================================');
        
        // Gérer les données de navigation
        final data = event.notification.additionalData;
        debugPrint('📱 [NotificationService] Données notification: $data');
        debugPrint('📱 [NotificationService] Launch URL: ${event.notification.launchUrl}');
        
        // Variable pour tracker si on a navigué
        bool hasNavigated = false;
        
        if (data != null) {
          debugPrint('🔍 [NotificationService] Données détaillées:');
          data.forEach((key, value) {
            debugPrint('🔍 [NotificationService]   $key: $value (${value.runtimeType})');
          });
          
          // Priorité aux données personnalisées (deep link)
          if (data.containsKey('deep_link')) {
            debugPrint('🚀 [NotificationService] Navigation via deep_link: ${data['deep_link']}');
            _handleNotificationUrl(data['deep_link']);
            hasNavigated = true;
          } else if (data.containsKey('content_type') && data.containsKey('content_id')) {
            debugPrint('🚀 [NotificationService] Navigation via content_type/content_id: ${data['content_type']}/${data['content_id']}');
            // Navigation directe via les données
            _handleContentNavigation(data['content_type'], data['content_id'].toString());
            hasNavigated = true;
          } else if (data.containsKey('url')) {
            debugPrint('🚀 [NotificationService] Navigation via URL: ${data['url']}');
            // URL classique en fallback
            _handleNotificationUrl(data['url']);
            hasNavigated = true;
          }
        } else {
          debugPrint('⚠️ [NotificationService] Aucune donnée dans la notification');
        }
        
        // Fallback : URL de la notification elle-même
        if (!hasNavigated && event.notification.launchUrl != null && event.notification.launchUrl!.isNotEmpty) {
          debugPrint('🚀 [NotificationService] Navigation fallback via launchUrl: ${event.notification.launchUrl}');
          _handleNotificationUrl(event.notification.launchUrl!);
          hasNavigated = true;
        }
        
        if (!hasNavigated) {
          debugPrint('❌ [NotificationService] AUCUNE NAVIGATION EFFECTUÉE - Pas de données de navigation trouvées');
        }
        
        debugPrint('👆 [NotificationService] =================================');
      });
      
      // Changement de l'ID utilisateur
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint('👤 [NotificationService] Subscription changée');
        if (state.current.id != null) {
          debugPrint('👤 [NotificationService] Subscription ID: ${state.current.id}');
        }
      });
      
      debugPrint('✅ [NotificationService] Event listeners configurés');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur configuration listeners: $e');
    }
  }
  
  static void _handleNotificationUrl(String url) {
    debugPrint('🔗 [NotificationService] Redirection vers: $url');
    
    try {
      // Vérifier si c'est un deep link de l'app
      if (url.startsWith('dinor://')) {
        _handleDeepLink(url);
      } else {
        // URL web classique - ouvrir dans le navigateur
        debugPrint('🌐 [NotificationService] Ouverture URL web: $url');
        // Ici on pourrait utiliser url_launcher pour ouvrir dans le navigateur
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur navigation: $e');
    }
  }
  
  static void _handleDeepLink(String deepLink) {
    debugPrint('🔗 [NotificationService] Traitement deep link: $deepLink');
    
    // Parser le deep link : dinor://recipe/123
    final uri = Uri.parse(deepLink);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isEmpty) {
      debugPrint('❌ [NotificationService] Deep link invalide: $deepLink');
      return;
    }
    
    final contentType = pathSegments[0];
    final contentId = pathSegments.length > 1 ? pathSegments[1] : null;
    
    if (contentId == null) {
      debugPrint('❌ [NotificationService] ID manquant dans deep link: $deepLink');
      return;
    }
    
    _handleContentNavigation(contentType, contentId);
  }
  
  static void _handleContentNavigation(String contentType, String contentId) {
    debugPrint('📱 [NotificationService] ========== NAVIGATION CONTENT ==========');
    debugPrint('📱 [NotificationService] Type: $contentType');
    debugPrint('📱 [NotificationService] ID: $contentId');
    
    // Vérifier si NavigationService est disponible
    if (NavigationService.navigatorKey.currentState == null) {
      debugPrint('❌ [NotificationService] NavigatorKey.currentState est null !');
      return;
    }
    
    try {
      // Naviguer selon le type de contenu
      switch (contentType) {
        case 'recipe':
          debugPrint('🍽️ [NotificationService] Navigation vers recette ID: $contentId');
          NavigationService.goToRecipeDetail(contentId);
          debugPrint('✅ [NotificationService] Navigation recette lancée');
          break;
        case 'tip':
          debugPrint('💡 [NotificationService] Navigation vers astuce ID: $contentId');
          NavigationService.goToTipDetail(contentId);
          debugPrint('✅ [NotificationService] Navigation astuce lancée');
          break;
        case 'event':
          debugPrint('📅 [NotificationService] Navigation vers événement ID: $contentId');
          NavigationService.goToEventDetail(contentId);
          debugPrint('✅ [NotificationService] Navigation événement lancée');
          break;
        case 'dinor-tv':
        case 'dinor_tv':
          debugPrint('📺 [NotificationService] Navigation vers Dinor TV');
          NavigationService.goToDinorTv();
          debugPrint('✅ [NotificationService] Navigation Dinor TV lancée');
          break;
        case 'page':
          debugPrint('📄 [NotificationService] Navigation vers page: $contentId');
          debugPrint('⚠️ [NotificationService] Navigation page non implémentée');
          break;
        default:
          debugPrint('⚠️ [NotificationService] Type de contenu non géré: $contentType');
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur lors de la navigation: $e');
    }
    
    debugPrint('📱 [NotificationService] ====================================');
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
  
  static void addTag(String key, String value) {
    try {
      OneSignal.User.addTags({key: value});
      debugPrint('🏷️ [NotificationService] Tag ajouté: $key = $value');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur addTag: $e');
    }
  }
  
  static void removeTag(String key) {
    try {
      OneSignal.User.removeTags([key]);
      debugPrint('🏷️ [NotificationService] Tag supprimé: $key');
    } catch (e) {
      debugPrint('❌ [NotificationService] Erreur removeTag: $e');
    }
  }
} 