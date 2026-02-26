import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';

class NotificationsSummaryState {
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationsSummaryState({
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsSummaryState copyWith({
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsSummaryState(
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsSummaryNotifier extends StateNotifier<NotificationsSummaryState> {
  final Ref ref;
  NotificationsSummaryNotifier(this.ref) : super(const NotificationsSummaryState());

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(notificationsServiceProvider);
      final result = await service.getNotifications(page: 1);
      if (result['success'] == true) {
        final List<NotificationModel> list = result['notifications'] ?? <NotificationModel>[];
        final int unread = list.where((n) => !(n.isRead)).length;
        state = state.copyWith(unreadCount: unread, isLoading: false, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: result['error']?.toString());
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void decrementIfUnread(int notificationId) {
    // Méthode utilitaire si on veut mettre à jour localement après "marquer comme lu"
    if (state.unreadCount > 0) {
      state = state.copyWith(unreadCount: state.unreadCount - 1);
    }
  }
}

final notificationsSummaryProvider =
    StateNotifierProvider<NotificationsSummaryNotifier, NotificationsSummaryState>((ref) {
  return NotificationsSummaryNotifier(ref);
});


