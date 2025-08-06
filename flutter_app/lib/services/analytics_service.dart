/**
 * ANALYTICS_SERVICE.DART - SERVICE DE SUIVI FIREBASE ANALYTICS
 * 
 * FONCTIONNALITÉS :
 * - Suivi des installations et ouvertures d'app
 * - Événements personnalisés (navigation, interactions)
 * - Propriétés utilisateur (authentification, préférences)
 * - Crash reporting avec Crashlytics
 * - Métriques de performance et engagement
 */

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  // Initialisation du service
  static Future<void> initialize() async {
    try {
      debugPrint('📊 [Analytics] Initialisation Firebase Analytics...');
      
      // Configuration des propriétés par défaut
      await _analytics.setDefaultEventParameters({
        'platform': Platform.operatingSystem,
        'app_version': '1.2.0',
        'build_number': '2',
      });

      // Configuration Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // Enregistrer les erreurs Flutter automatiquement
      FlutterError.onError = _crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      debugPrint('✅ [Analytics] Firebase Analytics initialisé avec succès');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur initialisation: $e');
    }
  }

  // === ÉVÉNEMENTS D'APPLICATION ===
  
  // Ouverture de l'app
  static Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      debugPrint('📱 [Analytics] App ouverte');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur app_open: $e');
    }
  }

  // Première ouverture (installation)
  static Future<void> logFirstOpen() async {
    try {
      await _analytics.logEvent(name: 'first_open', parameters: {
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('🎉 [Analytics] Première ouverture enregistrée');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur first_open: $e');
    }
  }

  // === ÉVÉNEMENTS DE NAVIGATION ===
  
  // Changement d'écran
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
        parameters: parameters,
      );
      debugPrint('🧭 [Analytics] Écran visité: $screenName');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur screen_view: $e');
    }
  }

  // Navigation entre sections
  static Future<void> logNavigation({
    required String from,
    required String to,
    String? method, // 'tab', 'button', 'deep_link'
  }) async {
    try {
      await _analytics.logEvent(name: 'navigation', parameters: {
        'from_screen': from,
        'to_screen': to,
        'method': method ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('🧭 [Analytics] Navigation: $from → $to');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur navigation: $e');
    }
  }

  // === ÉVÉNEMENTS DE CONTENU ===
  
  // Consultation de contenu
  static Future<void> logViewContent({
    required String contentType, // 'recipe', 'tip', 'event', 'video'
    required String contentId,
    required String contentName,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final parameters = {
        'content_type': contentType,
        'item_id': contentId,
        'item_name': contentName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalParams,
      };
      
      await _analytics.logViewItem(parameters: parameters);
      debugPrint('👀 [Analytics] Contenu consulté: $contentType/$contentName');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur view_content: $e');
    }
  }

  // Recherche
  static Future<void> logSearch({
    required String searchTerm,
    String? category,
    int? resultsCount,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: {
          'category': category,
          'results_count': resultsCount ?? 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('🔍 [Analytics] Recherche: "$searchTerm" ($resultsCount résultats)');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur search: $e');
    }
  }

  // === ÉVÉNEMENTS D'INTERACTION ===
  
  // Like/Unlike
  static Future<void> logLikeAction({
    required String contentType,
    required String contentId,
    required bool isLiked,
  }) async {
    try {
      await _analytics.logEvent(
        name: isLiked ? 'like_content' : 'unlike_content',
        parameters: {
          'content_type': contentType,
          'content_id': contentId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('${isLiked ? '❤️' : '💔'} [Analytics] ${isLiked ? 'Like' : 'Unlike'}: $contentType/$contentId');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur like_action: $e');
    }
  }

  // Ajout aux favoris
  static Future<void> logFavoriteAction({
    required String contentType,
    required String contentId,
    required bool isFavorited,
  }) async {
    try {
      await _analytics.logEvent(
        name: isFavorited ? 'add_to_favorites' : 'remove_from_favorites',
        parameters: {
          'content_type': contentType,
          'content_id': contentId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('⭐ [Analytics] ${isFavorited ? 'Ajout' : 'Suppression'} favoris: $contentType/$contentId');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur favorite_action: $e');
    }
  }

  // Partage de contenu
  static Future<void> logShareContent({
    required String contentType,
    required String contentId,
    required String method, // 'facebook', 'twitter', 'whatsapp', 'copy_link'
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: contentId,
        method: method,
      );
      debugPrint('📤 [Analytics] Partage: $contentType/$contentId via $method');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur share: $e');
    }
  }

  // === ÉVÉNEMENTS D'AUTHENTIFICATION ===
  
  // Connexion
  static Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      debugPrint('🔐 [Analytics] Connexion via: $method');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur login: $e');
    }
  }

  // Inscription
  static Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      debugPrint('✍️ [Analytics] Inscription via: $method');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur signup: $e');
    }
  }

  // Déconnexion
  static Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout', parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('🚪 [Analytics] Déconnexion');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur logout: $e');
    }
  }

  // === PROPRIÉTÉS UTILISATEUR ===
  
  // Définir l'ID utilisateur
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
      debugPrint('👤 [Analytics] User ID défini: $userId');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur setUserId: $e');
    }
  }

  // Propriétés utilisateur personnalisées
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('🏷️ [Analytics] Propriété utilisateur: $name = $value');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur setUserProperty: $e');
    }
  }

  // === GESTION D'ERREURS ===
  
  // Enregistrer une erreur non fatale
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: context,
        information: additionalData?.entries.map((e) => 
          DiagnosticsProperty(e.key, e.value)).toList() ?? [],
        fatal: false,
      );
      debugPrint('⚠️ [Analytics] Erreur enregistrée: $exception');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur recordError: $e');
    }
  }

  // === ÉVÉNEMENTS PERSONNALISÉS ===
  
  // Événement personnalisé générique
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final params = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parameters,
      };
      
      await _analytics.logEvent(name: eventName, parameters: params);
      debugPrint('🎯 [Analytics] Événement personnalisé: $eventName');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur custom_event: $e');
    }
  }

  // Performance d'une action (temps d'exécution)
  static Future<void> logPerformance({
    required String actionName,
    required int durationMs,
    String? category,
  }) async {
    try {
      await _analytics.logEvent(name: 'performance_timing', parameters: {
        'action_name': actionName,
        'duration_ms': durationMs,
        'category': category ?? 'general',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('⏱️ [Analytics] Performance: $actionName = ${durationMs}ms');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur performance: $e');
    }
  }
}

// Provider pour le service Analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});