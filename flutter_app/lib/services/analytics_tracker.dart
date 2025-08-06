/**
 * ANALYTICS_TRACKER.DART - SERVICE DE TRACKING AUTOMATIQUE
 * 
 * FONCTIONNALITÉS :
 * - Tracking automatique du temps passé sur les écrans
 * - Suivi des interactions utilisateur
 * - Métriques d'engagement automatiques
 * - Gestion des sessions utilisateur
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'analytics_service.dart';

class AnalyticsTracker {
  static final Map<String, DateTime> _screenStartTimes = {};
  static final Map<String, int> _screenVisitCounts = {};
  static DateTime? _sessionStartTime;
  static Timer? _sessionTimer;
  
  // === TRACKING AUTOMATIQUE DES ÉCRANS ===
  
  // Démarrer le tracking d'un écran
  static void startScreenTracking(String screenName) {
    try {
      _screenStartTimes[screenName] = DateTime.now();
      
      // Incrémenter le compteur de visites
      _screenVisitCounts[screenName] = (_screenVisitCounts[screenName] ?? 0) + 1;
      
      // Logger la visite d'écran
      AnalyticsService.logScreenView(screenName: screenName);
      
      debugPrint('📱 [Tracker] Début tracking écran: $screenName');
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur startScreenTracking: $e');
    }
  }
  
  // Arrêter le tracking d'un écran
  static void stopScreenTracking(String screenName) {
    try {
      final startTime = _screenStartTimes[screenName];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime).inSeconds;
        
        // Logger le temps passé sur l'écran
        AnalyticsService.logScreenTime(
          screenName: screenName,
          durationSeconds: duration,
        );
        
        // Logger l'utilisation de la fonctionnalité
        AnalyticsService.logFeatureUsage(
          featureName: screenName,
          category: 'screen_usage',
          additionalData: {
            'visit_count': _screenVisitCounts[screenName] ?? 1,
            'duration_seconds': duration,
          },
        );
        
        _screenStartTimes.remove(screenName);
        debugPrint('📱 [Tracker] Fin tracking écran: $screenName (${duration}s)');
      }
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur stopScreenTracking: $e');
    }
  }
  
  // === GESTION DES SESSIONS ===
  
  // Démarrer une session utilisateur
  static void startSession() {
    try {
      _sessionStartTime = DateTime.now();
      
      // Logger le début de session
      AnalyticsService.logCustomEvent(
        eventName: 'session_start',
        parameters: {
          'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
          'platform': 'flutter',
        },
      );
      
      // Démarrer le timer de session
      _startSessionTimer();
      
      debugPrint('🔄 [Tracker] Session démarrée');
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur startSession: $e');
    }
  }
  
  // Arrêter la session utilisateur
  static void stopSession() {
    try {
      if (_sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
        
        // Logger la fin de session
        AnalyticsService.logCustomEvent(
          eventName: 'session_end',
          parameters: {
            'duration_minutes': duration,
            'screens_visited': _screenVisitCounts.keys.length,
          },
        );
        
        // Logger une session longue si > 5 minutes
        if (duration > 5) {
          AnalyticsService.logLongSession(durationMinutes: duration);
        }
        
        _sessionStartTime = null;
        _sessionTimer?.cancel();
        _screenStartTimes.clear();
        _screenVisitCounts.clear();
        
        debugPrint('🔄 [Tracker] Session terminée (${duration} minutes)');
      }
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur stopSession: $e');
    }
  }
  
  // Timer pour surveiller la session
  static void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
        
        // Logger l'engagement quotidien
        AnalyticsService.logDailyEngagement();
        
        // Logger les sessions longues
        if (duration == 5 || duration == 10 || duration == 15) {
          AnalyticsService.logLongSession(durationMinutes: duration);
        }
      }
    });
  }
  
  // === TRACKING DES INTERACTIONS ===
  
  // Tracker un clic sur un bouton
  static void trackButtonClick({
    required String buttonName,
    required String screenName,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      AnalyticsService.logCustomEvent(
        eventName: 'button_click',
        parameters: {
          'button_name': buttonName,
          'screen_name': screenName,
          ...?additionalData,
        },
      );
      
      debugPrint('🖱️ [Tracker] Clic bouton: $buttonName sur $screenName');
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur trackButtonClick: $e');
    }
  }
  
  // Tracker une erreur utilisateur
  static void trackUserError({
    required String errorType,
    required String errorMessage,
    String? screenName,
    Map<String, dynamic>? context,
  }) {
    try {
      AnalyticsService.logUserError(
        errorType: errorType,
        errorMessage: errorMessage,
        screenName: screenName,
        context: context,
      );
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur trackUserError: $e');
    }
  }
  
  // Tracker une action de navigation
  static void trackNavigation({
    required String fromScreen,
    required String toScreen,
    String? method,
  }) {
    try {
      AnalyticsService.logNavigation(
        from: fromScreen,
        to: toScreen,
        method: method,
      );
    } catch (e) {
      debugPrint('❌ [Tracker] Erreur trackNavigation: $e');
    }
  }
  
  // === MIXIN POUR LES WIDGETS ===
}

// Mixin pour automatiser le tracking des écrans
mixin AnalyticsScreenMixin<T extends StatefulWidget> on State<T> {
  String get screenName;
  
  @override
  void initState() {
    super.initState();
    AnalyticsTracker.startScreenTracking(screenName);
  }
  
  @override
  void dispose() {
    AnalyticsTracker.stopScreenTracking(screenName);
    super.dispose();
  }
}

// Mixin pour automatiser le tracking des boutons
mixin AnalyticsButtonMixin {
  void trackButtonClick({
    required String buttonName,
    required String screenName,
    Map<String, dynamic>? additionalData,
  }) {
    AnalyticsTracker.trackButtonClick(
      buttonName: buttonName,
      screenName: screenName,
      additionalData: additionalData,
    );
  }
}

// Widget wrapper pour automatiser le tracking
class AnalyticsWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  
  const AnalyticsWrapper({
    Key? key,
    required this.child,
    required this.screenName,
  }) : super(key: key);
  
  @override
  State<AnalyticsWrapper> createState() => _AnalyticsWrapperState();
}

class _AnalyticsWrapperState extends State<AnalyticsWrapper> with AnalyticsScreenMixin {
  @override
  String get screenName => widget.screenName;
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 