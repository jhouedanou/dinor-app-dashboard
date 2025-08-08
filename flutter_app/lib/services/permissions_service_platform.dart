import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service de permissions adaptatif pour différentes plateformes
class PlatformPermissionsService {
  
  /// Vérifie si les permissions de notification sont supportées sur cette plateforme
  static bool get isNotificationPermissionSupported {
    if (kIsWeb) {
      // Les notifications sont supportées sur web moderne
      return true;
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      // Les notifications sont supportées sur mobile
      return true;
    }
    
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Sur desktop, OneSignal peut gérer les notifications
      // mais pas via permission_handler
      return true;
    }
    
    return false;
  }
  
  /// Vérifie si permission_handler est disponible sur cette plateforme
  static bool get isPermissionHandlerSupported {
    // permission_handler ne fonctionne que sur mobile
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// Obtient une description de la plateforme actuelle pour les logs
  static String get platformDescription {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown Platform';
  }
  
  /// Stratégie de permission selon la plateforme
  static String get permissionStrategy {
    if (kIsWeb) {
      return 'OneSignal + Browser API';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'OneSignal + permission_handler';
    } else {
      return 'OneSignal uniquement';
    }
  }
}

/// Messages d'erreur adaptés selon la plateforme
class PlatformPermissionMessages {
  static String getPermissionDeniedMessage() {
    if (kIsWeb) {
      return 'Pour recevoir les notifications Dinor, autorisez les notifications dans votre navigateur.';
    } else if (Platform.isIOS) {
      return 'Pour recevoir les notifications Dinor, autorisez les notifications dans Réglages > Notifications > Dinor.';
    } else if (Platform.isAndroid) {
      return 'Pour recevoir les notifications Dinor, autorisez les notifications dans les paramètres de l\'application.';
    } else {
      return 'Pour recevoir les notifications Dinor, vérifiez les paramètres de notification de votre système.';
    }
  }
  
  static String getPermissionRequestTitle() {
    return 'Autoriser les notifications';
  }
  
  static String getPermissionRequestDescription() {
    if (kIsWeb) {
      return 'Dinor souhaite afficher des notifications dans votre navigateur pour vous tenir informé des nouveautés.';
    } else {
      return 'Dinor souhaite vous envoyer des notifications pour vous tenir informé des nouvelles recettes, astuces et événements.';
    }
  }
}