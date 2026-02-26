import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permissions_service_platform.dart';

class PermissionsService {
  static const _notificationPromptKey = 'notifications_permission_prompt_shown_v1';

  static Future<bool> requestNotificationPermission() async {
    try {
      final platformDesc = PlatformPermissionsService.platformDescription;
      final strategy = PlatformPermissionsService.permissionStrategy;
      debugPrint('🔔 [PermissionsService] Demande de permission ($platformDesc) - Stratégie: $strategy');

      // 1. Demander la permission via OneSignal (fonctionne sur toutes les plateformes)
      bool oneSignalPermission = false;
      try {
        oneSignalPermission = await OneSignal.Notifications.requestPermission(true);
        debugPrint('🔔 [PermissionsService] Permission OneSignal: $oneSignalPermission');
      } catch (e) {
        debugPrint('⚠️ [PermissionsService] Erreur OneSignal: $e');
        oneSignalPermission = false;
      }

      // 2. Demander la permission système selon la plateforme
      bool systemPermissionGranted = true;

      if (kIsWeb) {
        // Sur Web, OneSignal gère les permissions du navigateur
        debugPrint('🔔 [PermissionsService] Web - OneSignal gère les permissions navigateur');
        systemPermissionGranted = oneSignalPermission;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Sur desktop, OneSignal peut fonctionner sans permission système
        debugPrint('🔔 [PermissionsService] Desktop (${Platform.operatingSystem}) - permission automatique');
        systemPermissionGranted = true;
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Sur mobile, utiliser permission_handler si disponible
        if (PlatformPermissionsService.isPermissionHandlerSupported) {
          try {
            final notificationPermission = await Permission.notification.request();
            systemPermissionGranted = notificationPermission.isGranted;
            debugPrint('🔔 [PermissionsService] Permission système mobile: $notificationPermission');
          } catch (e) {
            debugPrint('⚠️ [PermissionsService] Permission handler échoué: $e');
            // Si permission_handler échoue, se baser uniquement sur OneSignal
            systemPermissionGranted = oneSignalPermission;
          }
        } else {
          debugPrint('🔔 [PermissionsService] Permission handler non supporté, utilisation OneSignal uniquement');
          systemPermissionGranted = oneSignalPermission;
        }
      } else {
        // Plateforme inconnue
        debugPrint('⚠️ [PermissionsService] Plateforme non reconnue: ${Platform.operatingSystem}');
        systemPermissionGranted = oneSignalPermission;
      }

      final isGranted = oneSignalPermission || systemPermissionGranted; // OR au lieu de AND pour être plus permissif
      
      if (isGranted) {
        debugPrint('✅ [PermissionsService] Permission accordée pour les notifications ($platformDesc)');
      } else {
        debugPrint('❌ [PermissionsService] Permission refusée pour les notifications ($platformDesc)');
      }

      return isGranted;
    } catch (e) {
      debugPrint('❌ [PermissionsService] Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  static Future<bool> checkNotificationPermission() async {
    try {
      final platformDesc = PlatformPermissionsService.platformDescription;
      debugPrint('🔍 [PermissionsService] Vérification des permissions ($platformDesc)...');

      // 1. Vérifier la permission OneSignal (fonctionne sur toutes les plateformes)
      bool oneSignalPermission = false;
      try {
        oneSignalPermission = OneSignal.Notifications.permission;
        debugPrint('🔍 [PermissionsService] OneSignal permission: $oneSignalPermission');
      } catch (e) {
        debugPrint('⚠️ [PermissionsService] Erreur OneSignal check: $e');
        oneSignalPermission = false;
      }

      // 2. Vérifier la permission système selon la plateforme
      bool systemPermissionGranted = true;
      
      if (kIsWeb) {
        // Sur Web, OneSignal gère les permissions du navigateur
        debugPrint('🔍 [PermissionsService] Web - vérification via OneSignal');
        systemPermissionGranted = oneSignalPermission;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Sur desktop, considérer comme accordé si OneSignal fonctionne
        debugPrint('🔍 [PermissionsService] Desktop (${Platform.operatingSystem}) - permission automatique');
        systemPermissionGranted = true;
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Sur mobile, utiliser permission_handler si disponible
        if (PlatformPermissionsService.isPermissionHandlerSupported) {
          try {
            final notificationPermission = await Permission.notification.status;
            systemPermissionGranted = notificationPermission.isGranted;
            debugPrint('🔍 [PermissionsService] Permission système mobile: $notificationPermission');
          } catch (e) {
            debugPrint('⚠️ [PermissionsService] Permission handler check échoué: $e');
            // Si permission_handler échoue, se baser uniquement sur OneSignal
            systemPermissionGranted = oneSignalPermission;
          }
        } else {
          debugPrint('🔍 [PermissionsService] Permission handler non supporté, utilisation OneSignal uniquement');
          systemPermissionGranted = oneSignalPermission;
        }
      } else {
        // Plateforme inconnue
        debugPrint('⚠️ [PermissionsService] Plateforme non reconnue pour check: ${Platform.operatingSystem}');
        systemPermissionGranted = oneSignalPermission;
      }

      final isGranted = oneSignalPermission || systemPermissionGranted; // OR au lieu de AND pour être plus permissif
      
      debugPrint('🔍 [PermissionsService] Permissions accordées ($platformDesc): $isGranted');
      return isGranted;
    } catch (e) {
      debugPrint('❌ [PermissionsService] Erreur lors de la vérification: $e');
      return false;
    }
  }

  static Future<bool> canShowNotifications() async {
    return await checkNotificationPermission();
  }

  static Future<void> ensureInitialPermissionRequest(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyPrompted = prefs.getBool(_notificationPromptKey) ?? false;

      final hasPermission = await checkNotificationPermission();
      if (hasPermission) {
        if (!alreadyPrompted) {
          await prefs.setBool(_notificationPromptKey, true);
        }
        return;
      }

      if (alreadyPrompted) {
        return;
      }

      // Laisser le temps à l'UI de se stabiliser avant d'afficher la demande iOS
      await Future.delayed(const Duration(milliseconds: 600));

      final granted = await requestNotificationPermission();
      await prefs.setBool(_notificationPromptKey, true);

      if (!granted && context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      debugPrint('❌ [PermissionsService] Erreur ensureInitialPermissionRequest: $e');
    }
  }

  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Color(0xFFE53E3E)),
              SizedBox(width: 8),
              Text('Autoriser les notifications'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pour recevoir des notifications push sur :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: Color(0xFFE53E3E)),
                  SizedBox(width: 8),
                  Text('Nouvelles recettes'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Color(0xFFE53E3E)),
                  SizedBox(width: 8),
                  Text('Astuces culinaires'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Color(0xFFE53E3E)),
                  SizedBox(width: 8),
                  Text('Événements spéciaux'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.play_circle, size: 16, color: Color(0xFFE53E3E)),
                  SizedBox(width: 8),
                  Text('Nouveaux contenus DinorTV'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Dinor a besoin de votre autorisation pour vous envoyer des notifications.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Plus tard',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Autoriser'),
              onPressed: () async {
                Navigator.of(context).pop();
                final granted = await requestNotificationPermission();
                
                if (!granted) {
                  // Si permission refusée, proposer d'aller dans les paramètres
                  _showPermissionDeniedDialog(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Permission requise'),
            ],
          ),
          content: const Text(
            'Pour recevoir les notifications Dinor, vous devez autoriser les notifications dans les paramètres de votre appareil.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ouvrir les paramètres'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showNotificationSettingsInfo(BuildContext context) async {
    final hasPermission = await checkNotificationPermission();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFFE53E3E)),
              SizedBox(width: 8),
              Text('Paramètres de notifications'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasPermission ? Icons.check_circle : Icons.cancel,
                    color: hasPermission ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasPermission 
                        ? 'Notifications activées' 
                        : 'Notifications désactivées',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hasPermission ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!hasPermission) ...[
                const Text(
                  'Vous ne recevrez pas de notifications pour :',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text('• Nouvelles recettes'),
                const Text('• Astuces culinaires'),
                const Text('• Événements spéciaux'),
                const Text('• Contenus DinorTV'),
              ] else ...[
                const Text(
                  'Vous recevrez des notifications pour tous les nouveaux contenus Dinor !',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            if (!hasPermission) ...[
              TextButton(
                child: const Text('Plus tard'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activer'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await showPermissionDialog(context);
                },
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

// Provider pour le service de permissions
final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService();
}); 
