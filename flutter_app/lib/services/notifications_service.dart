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
        return {
          'success': false,
          'error': response['message'] ?? 'Erreur inconnue',
        };
      }
    } catch (e) {
      print('❌ [NotificationsService] Erreur: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
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
        return false;
      }
    } catch (e) {
      print('❌ [NotificationsService] Erreur marquage: $e');
      return false;
    }
  }
}

// Provider pour le service de notifications
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return NotificationsService(apiService);
}); 