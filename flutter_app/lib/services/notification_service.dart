/**
 * NOTIFICATION_SERVICE.DART - ÉQUIVALENT DE oneSignal.js Vue
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Push notifications natives identiques
 * - Permissions identiques à OneSignal
 * - Configuration identique
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();
  
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  
  // INITIALISATION identique à OneSignal Vue
  static Future<void> initialize() async {
    if (_initialized) return;
    
    print('🔔 [NotificationService] Initialisation du service de notifications...');
    
    // Configuration Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuration iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    _initialized = true;
    print('✅ [NotificationService] Service initialisé');
  }
  
  // DEMANDE DE PERMISSIONS identique OneSignal
  static Future<bool> requestPermissions() async {
    print('🔔 [NotificationService] Demande de permissions...');
    
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? result = await androidImplementation?.requestPermission();
      return result ?? false;
    }
    
    return true;
  }
  
  // ENVOI DE NOTIFICATION LOCALE
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dinor_channel',
      'Dinor Notifications',
      channelDescription: 'Notifications de l\'application Dinor',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  // GESTION DES TAPS sur notifications (équivalent OneSignal onClick)
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    print('🔔 [NotificationService] Notification tappée avec payload: $payload');
    
    // TODO: Gérer la navigation selon le payload
    // Par exemple: naviguer vers une recette, un événement, etc.
  }
  
  // ANNULER TOUTES LES NOTIFICATIONS
  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('🔔 [NotificationService] Toutes les notifications annulées');
  }
  
  // ANNULER UNE NOTIFICATION SPÉCIFIQUE
  static Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('🔔 [NotificationService] Notification $id annulée');
  }
}