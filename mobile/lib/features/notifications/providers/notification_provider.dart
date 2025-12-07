/// Notification Provider
/// Riverpod providers for notification management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});

final notificationsListProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsNotifier(service);
});

class NotificationsState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;
  final int total;
  final int page;
  final bool hasMore;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
  });

  NotificationsState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    int? total,
    int? page,
    bool? hasMore,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationService _service;
  bool _hasLoaded = false;

  NotificationsNotifier(this._service) : super(NotificationsState()) {
    // Don't auto-load - wait for screen to load
  }
  
  void ensureLoaded() {
    if (!_hasLoaded) {
      _hasLoaded = true;
      loadNotifications();
    }
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = NotificationsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final notifications = await _service.getNotifications(
        page: refresh ? 1 : state.page,
      );

      final unreadCount = notifications
          .where((n) => n['is_read'] == false || n['is_read'] == null)
          .length;

      state = state.copyWith(
        notifications: refresh
            ? notifications
            : [...state.notifications, ...notifications],
        isLoading: false,
        unreadCount: unreadCount,
        hasMore: notifications.length == 20, // Assuming 20 is page size
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final notifications = await _service.getNotifications(
        page: state.page + 1,
      );

      state = state.copyWith(
        notifications: [...state.notifications, ...notifications],
        isLoading: false,
        page: state.page + 1,
        hasMore: notifications.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      // Update local state
      final updated = state.notifications.map((n) {
        if (n['id'] == notificationId) {
          return {...n, 'is_read': true};
        }
        return n;
      }).toList();

      final unreadCount = updated
          .where((n) => n['is_read'] == false || n['is_read'] == null)
          .length;

      state = state.copyWith(
        notifications: updated,
        unreadCount: unreadCount,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      // Update local state
      final updated = state.notifications
          .map((n) => {...n, 'is_read': true})
          .toList();

      state = state.copyWith(
        notifications: updated,
        unreadCount: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      // Remove from local state
      final updated = state.notifications
          .where((n) => n['id'] != notificationId)
          .toList();

      final unreadCount = updated
          .where((n) => n['is_read'] == false || n['is_read'] == null)
          .length;

      state = state.copyWith(
        notifications: updated,
        unreadCount: unreadCount,
        total: state.total - 1,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

