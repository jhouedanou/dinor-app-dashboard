import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notifications_service.dart';
import '../services/navigation_service.dart';
import '../services/permissions_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  NotificationsPagination? pagination;
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _checkAuthAndLoadNotifications() async {
    final authState = ref.read(useAuthHandlerProvider);
    
    if (!authState.isAuthenticated) {
      _showAuthModal();
      return;
    }

    await _loadNotifications();
  }

  void _showAuthModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AuthModal(
          isOpen: true,
          onClose: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          onAuthenticated: () {
            Navigator.of(context, rootNavigator: true).pop();
            _loadNotifications();
          },
        );
      },
    );
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        notifications.clear();
        pagination = null;
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final notificationsService = ref.read(notificationsServiceProvider);
      final result = await notificationsService.getNotifications(page: 1);

      if (result['success']) {
        setState(() {
          notifications = result['notifications'];
          pagination = result['pagination'];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = result['error'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || 
        pagination == null || 
        !pagination!.hasMorePages) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final notificationsService = ref.read(notificationsServiceProvider);
      final result = await notificationsService.getNotifications(
        page: pagination!.currentPage + 1
      );

      if (result['success']) {
        setState(() {
          notifications.addAll(result['notifications']);
          pagination = result['pagination'];
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
        _showErrorSnackBar(result['error']);
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      _showErrorSnackBar('Erreur de chargement: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    // Marquer comme lue (optionnel)
    ref.read(notificationsServiceProvider).markAsRead(notification.id);

    // Navigation vers le contenu
    if (notification.deepLink != null) {
      _handleDeepLink(notification.deepLink!);
    } else if (notification.contentType != null && notification.contentId != null) {
      _handleContentNavigation(notification.contentType!, notification.contentId!);
    } else if (notification.url != null) {
      // Gestion URL classique - ouvrir dans le navigateur
      print('📱 URL notification: ${notification.url}');
      _launchUrl(notification.url!);
    }
  }

  void _handleDeepLink(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty) {
        final contentType = pathSegments[0];
        final contentId = pathSegments.length > 1 ? pathSegments[1] : null;
        
        if (contentId != null) {
          _handleContentNavigation(contentType, contentId);
        }
      }
    } catch (e) {
      print('❌ Erreur parsing deep link: $e');
    }
  }

  void _handleContentNavigation(String contentType, String contentId) {
    switch (contentType) {
      case 'recipe':
        NavigationService.goToRecipeDetail(contentId);
        break;
      case 'tip':
        NavigationService.goToTipDetail(contentId);
        break;
      case 'event':
        NavigationService.goToEventDetail(contentId);
        break;
      case 'dinor-tv':
      case 'dinor_tv':
        NavigationService.goToDinorTv();
        break;
      default:
        print('⚠️ Type de contenu non géré: $contentType');
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('🌐 URL ouverte avec succès: $url');
      } else {
        print('❌ Impossible d\'ouvrir l\'URL: $url');
        _showErrorSnackBar('Impossible d\'ouvrir le lien');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'ouverture de l\'URL: $e');
      _showErrorSnackBar('Erreur lors de l\'ouverture du lien');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => PermissionsService.showNotificationSettingsInfo(context),
            tooltip: 'Paramètres de notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadNotifications(refresh: true),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNotifications(refresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous recevrez ici toutes vos notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji/Icône du type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.typeEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contenu de la notification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                        if (notification.contentName != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notification.contentName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Date
                  Text(
                    notification.displayDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 