import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String? icon;
  final String? contentType;
  final String? contentId;
  final String? contentName;
  final String? deepLink;
  final String? url;
  final DateTime? sentAt;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.icon,
    this.contentType,
    this.contentId,
    this.contentName,
    this.deepLink,
    this.url,
    this.sentAt,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      icon: json['icon'],
      contentType: json['content_type'],
      contentId: json['content_id']?.toString(),
      contentName: json['content_name'],
      deepLink: json['deep_link'],
      url: json['url'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  String get displayDate {
    final date = sentAt ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  String get typeEmoji {
    return switch (contentType) {
      'recipe' => '🍽️',
      'tip' => '💡',
      'event' => '📅',
      'dinor_tv' => '📺',
      'page' => '📄',
      _ => '📱',
    };
  }

  /// Crée une copie de cette notification marquée comme lue
  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      icon: icon,
      contentType: contentType,
      contentId: contentId,
      contentName: contentName,
      deepLink: deepLink,
      url: url,
      sentAt: sentAt,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}

class NotificationsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  NotificationsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory NotificationsPagination.fromJson(Map<String, dynamic> json) {
    return NotificationsPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? false,
    );
  }
}

class NotificationsService {
  final ApiService _apiService;

  NotificationsService(this._apiService);

  /// Récupérer les notifications de l'utilisateur
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    try {
      print('📱 [NotificationsService] Récupération des notifications (page $page)');
      
      final response = await _apiService.get('/notifications', params: {
        'page': page.toString(),
      });

      print('📱 [NotificationsService] Réponse API complète: $response');
      print('📱 [NotificationsService] Success: ${response['success']}');
      print('📱 [NotificationsService] Error: ${response['error']}');
      print('📱 [NotificationsService] Status Code: ${response['status_code']}');

      if (response['success'] == true) {
        final List<dynamic> notificationsData = response['data'] ?? [];
        final List<NotificationModel> notifications = notificationsData
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        final pagination = response['pagination'] != null 
            ? NotificationsPagination.fromJson(response['pagination'])
            : NotificationsPagination(
                currentPage: 1,
                lastPage: 1,
                perPage: 20,
                total: notifications.length,
                hasMorePages: false,
              );

        print('✅ [NotificationsService] ${notifications.length} notifications récupérées');

        return {
          'success': true,
          'notifications': notifications,
          'pagination': pagination,
        };
      } else {
        print('❌ [NotificationsService] Erreur API: ${response['message']}');
        
        // Si c'est un problème d'authentification ou d'endpoint, retourner des données vides
        if (response['error']?.toString().contains('Token expiré') == true ||
            response['error']?.toString().contains('ENDPOINT_NOT_FOUND') == true ||
            response['error']?.toString().contains('Endpoint non trouvé') == true ||
            response['status_code'] == 401 ||
            response['status_code'] == 404) {
          print('🔧 [NotificationsService] Endpoint non disponible (404), retour données vides');
          return {
            'success': true,
            'notifications': <NotificationModel>[],
            'pagination': NotificationsPagination(
              currentPage: 1,
              lastPage: 1,
              perPage: 20,
              total: 0,
              hasMorePages: false,
            ),
          };
        }
        
        return {
          'success': false,
          'error': response['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      print('❌ [NotificationsService] Erreur: $e');
      
      // En cas d'erreur de connexion, retourner des données vides pour éviter le crash
      print('🔧 [NotificationsService] Retour données vides suite à erreur réseau');
      return {
        'success': true,
        'notifications': <NotificationModel>[],
        'pagination': NotificationsPagination(
          currentPage: 1,
          lastPage: 1,
          perPage: 20,
          total: 0,
          hasMorePages: false,
        ),
      };
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(int notificationId) async {
    try {
      print('📱 [NotificationsService] Marquage notification $notificationId comme lue');
      
      final response = await _apiService.patch('/notifications/$notificationId/read', {});

      if (response['success'] == true) {
        print('✅ [NotificationsService] Notification marquée comme lue');
        return true;
      } else {
        print('❌ [NotificationsService] Erreur marquage: ${response['message']}');
        // Même en cas d'erreur API, on peut marquer localement comme lue pour l'UX
        return true;
      }
    } catch (e) {
      print('❌ [NotificationsService] Erreur marquage: $e');
      // En cas d'erreur réseau, on marque quand même localement comme lue
      return true;
    }
  }
}

// Provider pour le service de notifications
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return NotificationsService(apiService);
}); 