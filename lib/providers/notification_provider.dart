import 'package:flutter/material.dart';
import '../Service/notification_service.dart';

/// Provider to manage notification count across the app
/// Notification count is shown in app bar badge
class NotificationProvider extends InheritedNotifier<NotificationNotifier> {
  const NotificationProvider({
    super.key,
    required NotificationNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static NotificationNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NotificationProvider>();
    assert(provider != null, 'No NotificationProvider found in context');
    return provider!.notifier!;
  }

  static NotificationNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NotificationProvider>();
    return provider?.notifier;
  }
}

class NotificationNotifier extends ChangeNotifier {
  int _unreadCount = 0;
  bool _isLoading = true;

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationNotifier() {
    _loadUnreadCount();
  }

  /// Load unread notification count from API
  Future<void> _loadUnreadCount() async {
    try {
      final response = await NotificationService.getUnreadCount();
      if (response != null && response.success) {
        _unreadCount = response.unreadCount;
      } else {
        _unreadCount = 0;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the unread count
  /// Call this after viewing notifications or marking as read
  Future<void> refresh() async {
    await _loadUnreadCount();
  }

  /// Manually set unread count (for optimistic updates)
  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  /// Decrement unread count by 1 (when single notification is read)
  void decrementCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  /// Reset count to 0 (when all notifications are marked as read)
  void clearCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  /// Increment count by 1 (when new notification arrives)
  void incrementCount() {
    _unreadCount++;
    notifyListeners();
  }
}

/// Extension to easily access NotificationNotifier from BuildContext
extension NotificationContext on BuildContext {
  NotificationNotifier get notificationNotifier => NotificationProvider.of(this);
  int get unreadNotificationCount => NotificationProvider.maybeOf(this)?.unreadCount ?? 0;
}
