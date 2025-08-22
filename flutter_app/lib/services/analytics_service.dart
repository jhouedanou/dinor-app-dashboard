/// ANALYTICS_SERVICE.DART - SERVICE DE SUIVI FIREBASE ANALYTICS
/// 
/// FONCTIONNALITÉS :
/// - Suivi des installations et ouvertures d'app
/// - Événements personnalisés (navigation, interactions)
/// - Propriétés utilisateur (authentification, préférences)
/// - Crash reporting avec Crashlytics
/// - Métriques de performance et engagement
/// - Tracking des installations et statistiques détaillées
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // Vérifier si c'est la première installation
      await _checkFirstInstallation();

      debugPrint('✅ [Analytics] Firebase Analytics initialisé avec succès');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur initialisation: $e');
    }
  }

  // === TRACKING DES INSTALLATIONS ===
  
  // Vérifier et tracker la première installation
  static Future<void> _checkFirstInstallation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstInstall = prefs.getBool('is_first_install') ?? true;
      
      if (isFirstInstall) {
        // Marquer comme installé
        await prefs.setBool('is_first_install', false);
        await prefs.setString('installation_date', DateTime.now().toIso8601String());
        
        // Tracker l'installation
        await logAppInstall();
        await logFirstOpen();
        
        debugPrint('🎉 [Analytics] Première installation détectée et trackée');
      } else {
        // Tracker la réouverture
        await logAppOpen();
        await _trackSessionStart();
      }
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur vérification installation: $e');
    }
  }

  // Tracker l'installation de l'app
  static Future<void> logAppInstall() async {
    try {
      await _analytics.logEvent(name: 'app_install', parameters: {
        'platform': Platform.operatingSystem,
        'app_version': '1.2.0',
        'build_number': '2',
        'installation_date': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('📱 [Analytics] Installation de l\'app trackée');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur app_install: $e');
    }
  }

  // Tracker le début de session
  static Future<void> _trackSessionStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCount = (prefs.getInt('session_count') ?? 0) + 1;
      await prefs.setInt('session_count', sessionCount);
      
      await _analytics.logEvent(name: 'session_start', parameters: {
        'session_number': sessionCount,
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('🔄 [Analytics] Session #$sessionCount démarrée');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur session_start: $e');
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

  // === STATISTIQUES D'UTILISATION ===
  
  // Tracker le temps passé sur un écran
  static Future<void> logScreenTime({
    required String screenName,
    required int durationSeconds,
  }) async {
    try {
      await _analytics.logEvent(name: 'screen_time', parameters: {
        'screen_name': screenName,
        'duration_seconds': durationSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('⏱️ [Analytics] Temps écran: $screenName = ${durationSeconds}s');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur screen_time: $e');
    }
  }

  // Tracker les fonctionnalités utilisées
  static Future<void> logFeatureUsage({
    required String featureName,
    String? category,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final parameters = {
        'feature_name': featureName,
        'category': category ?? 'general',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalData,
      };
      
      await _analytics.logEvent(name: 'feature_usage', parameters: parameters.cast<String, Object>());
      debugPrint('🔧 [Analytics] Fonctionnalité utilisée: $featureName');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur feature_usage: $e');
    }
  }

  // Tracker les erreurs utilisateur
  static Future<void> logUserError({
    required String errorType,
    required String errorMessage,
    String? screenName,
    Map<String, dynamic>? context,
  }) async {
    try {
      final errorParams = {
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (screenName != null) 'screen_name': screenName,
        ...?context,
      };
      await _analytics.logEvent(name: 'user_error', parameters: errorParams.cast<String, Object>());
      debugPrint('⚠️ [Analytics] Erreur utilisateur: $errorType - $errorMessage');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur user_error: $e');
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
        parameters: parameters?.cast<String, Object>(),
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
      
      await _analytics.logViewItem(parameters: parameters.cast<String, Object>());
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
      final searchParams = {
        'results_count': resultsCount ?? 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (category != null) 'category': category,
      };
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: searchParams.cast<String, Object>(),
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
      
      await _analytics.logEvent(name: eventName, parameters: params.cast<String, Object>());
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

  // === MÉTRIQUES D'ENGAGEMENT ===
  
  // Tracker l'engagement quotidien
  static Future<void> logDailyEngagement() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastEngagement = prefs.getString('last_engagement_date');
      
      if (lastEngagement != today) {
        await prefs.setString('last_engagement_date', today);
        
        await _analytics.logEvent(name: 'daily_engagement', parameters: {
          'date': today,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        debugPrint('📅 [Analytics] Engagement quotidien tracké: $today');
      }
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur daily_engagement: $e');
    }
  }

  // Tracker les sessions longues (>5 minutes)
  static Future<void> logLongSession({required int durationMinutes}) async {
    try {
      await _analytics.logEvent(name: 'long_session', parameters: {
        'duration_minutes': durationMinutes,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('⏰ [Analytics] Session longue: $durationMinutes minutes');
    } catch (e) {
      debugPrint('❌ [Analytics] Erreur long_session: $e');
    }
  }
}

// Provider pour le service Analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});