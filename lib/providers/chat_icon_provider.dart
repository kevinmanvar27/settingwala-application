import 'package:flutter/material.dart';
import '../Service/chat_service.dart';

/// Provider to manage chat icon visibility across the app
/// Chat icon is shown when user has active chats (non-completed bookings)
class ChatIconProvider extends InheritedNotifier<ChatIconNotifier> {
  const ChatIconProvider({
    super.key,
    required ChatIconNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ChatIconNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ChatIconProvider>();
    assert(provider != null, 'No ChatIconProvider found in context');
    return provider!.notifier!;
  }

  static ChatIconNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ChatIconProvider>();
    return provider?.notifier;
  }
}

class ChatIconNotifier extends ChangeNotifier {
  bool _showChatIcon = false;
  bool _isLoading = true;
  int _activeChatCount = 0;

  bool get showChatIcon => _showChatIcon;
  bool get isLoading => _isLoading;
  int get activeChatCount => _activeChatCount;

  ChatIconNotifier() {
    _checkChatIconVisibility();
  }

  /// Check if user has any active chats to show chat icon
  /// Chat icon is shown if there are non-completed chats
  Future<void> _checkChatIconVisibility() async {
    try {
      // Directly check for active chats
      final chatResult = await ChatService.getChats();
      
      if (chatResult != null && chatResult.success) {
        // Filter out completed chats - only count active chats
        final activeChats = chatResult.data.chats.where(
          (chat) => chat.bookingStatus.toLowerCase() != 'completed'
        ).toList();
        
        _activeChatCount = activeChats.length;
        _showChatIcon = activeChats.isNotEmpty;
      } else {
        _showChatIcon = false;
        _activeChatCount = 0;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // On error, keep chat icon hidden
      _showChatIcon = false;
      _activeChatCount = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the chat icon visibility state
  /// Call this after booking status changes (accept, reject, cancel, complete, etc.)
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _checkChatIconVisibility();
  }

  /// Manually set chat icon visibility
  /// Useful for optimistic updates when booking is accepted
  void setChatIconVisibility(bool show) {
    _showChatIcon = show;
    notifyListeners();
  }
  
  /// Update active chat count (call when a meeting is completed)
  void decrementChatCount() {
    _activeChatCount--;
    if (_activeChatCount <= 0) {
      _activeChatCount = 0;
      _showChatIcon = false;
    }
    notifyListeners();
  }
}

/// Extension to easily access ChatIconNotifier from BuildContext
extension ChatIconContext on BuildContext {
  ChatIconNotifier get chatIconNotifier => ChatIconProvider.of(this);
  bool get showChatIcon => ChatIconProvider.maybeOf(this)?.showChatIcon ?? false;
}
