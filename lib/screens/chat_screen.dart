import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../Service/message_service.dart';


class ChatMessage {
  final String id;
  final String text;
  final DateTime time;
  final bool isMe;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.isRead = false,
  });
}

class ChatScreen extends StatefulWidget {
  final String profileName;
  final String? profileImage;
  final DateTime meetingTime;
  final int bookingId;

  const ChatScreen({
    super.key,
    required this.profileName,
    this.profileImage,
    required this.meetingTime,
    required this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  
  final FocusNode _messageFocusNode = FocusNode();
  
  Timer? _refreshTimer;
  static const int _refreshIntervalSeconds = 5;
  
  // Typing indicator state
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;
  Timer? _typingStatusTimer;
  bool _iAmTyping = false;
  static const int _typingTimeoutSeconds = 3; // Stop showing typing after 3 seconds of no update
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    _initializeChat();
    
    _startAutoRefresh();
    _startTypingStatusPolling();
    
    // Listen to text changes for typing indicator
    _messageController.addListener(_onTextChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadMessages();
      _startAutoRefresh();
      _startTypingStatusPolling();
    } else if (state == AppLifecycleState.paused) {
      _stopAutoRefresh();
      _stopTypingStatusPolling();
      // Send stop typing when app goes to background
      if (_iAmTyping) {
        _sendTypingStatus(false);
      }
    }
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: _refreshIntervalSeconds),
      (_) => _loadMessagesQuietly(),
    );
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ==================== TYPING INDICATOR METHODS ====================
  
  /// Start polling for other user's typing status
  void _startTypingStatusPolling() {
    _stopTypingStatusPolling();
    // Poll every 2 seconds for typing status
    _typingStatusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkTypingStatus(),
    );
  }

  void _stopTypingStatusPolling() {
    _typingStatusTimer?.cancel();
    _typingStatusTimer = null;
  }

  /// Check if other user is typing
  Future<void> _checkTypingStatus() async {
    try {
      final response = await MessageService.getTypingStatus(widget.bookingId);
      if (response != null && response.success && mounted) {
        setState(() {
          _isOtherUserTyping = response.isTyping;
        });
      }
    } catch (e) {
      // Silently fail - typing indicator is not critical
    }
  }

  /// Called when text field content changes
  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;
    
    if (hasText && !_iAmTyping) {
      // Started typing
      _iAmTyping = true;
      _sendTypingStatus(true);
    }
    
    // Reset typing timeout timer
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(
        Duration(seconds: _typingTimeoutSeconds),
        () {
          // User stopped typing (no input for 3 seconds)
          if (_iAmTyping) {
            _iAmTyping = false;
            _sendTypingStatus(false);
          }
        },
      );
    } else {
      // Text is empty - stop typing
      if (_iAmTyping) {
        _iAmTyping = false;
        _sendTypingStatus(false);
      }
    }
  }

  /// Send typing status to server
  Future<void> _sendTypingStatus(bool isTyping) async {
    try {
      await MessageService.sendTypingStatus(widget.bookingId, isTyping);
    } catch (e) {
      // Silently fail - typing indicator is not critical
    }
  }

  // ==================== END TYPING INDICATOR METHODS ====================

  Future<void> _loadMessagesQuietly() async {
    try {
      final response = await MessageService.getMessages(widget.bookingId);
      
      if (response != null && response.success) {
        final newMessages = response.messages.map((msg) {
          return ChatMessage(
            id: msg.id,
            text: msg.text,
            time: msg.createdAt,
            isMe: msg.isMine,
            isRead: msg.isRead,
          );
        }).toList();
        
        newMessages.sort((a, b) => a.time.compareTo(b.time));
        
        // Check if messages changed (new messages OR read status changed)
        final hasChanges = _hasMessageChanges(newMessages);
        
        if (hasChanges) {
          final hasNewMessages = newMessages.length != _messages.length;
          
          setState(() {
            _messages = newMessages;
          });
          
          // Only mark as read and scroll if there are new messages
          if (hasNewMessages) {
            MessageService.markAsRead(widget.bookingId);
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        }
      }
    } catch (e) {
      
    }
  }
  
  /// Check if messages have changed (new messages or read status updated)
  bool _hasMessageChanges(List<ChatMessage> newMessages) {
    // Different count = definitely changed
    if (newMessages.length != _messages.length) {
      return true;
    }
    
    // Same count - check if any read status changed
    for (int i = 0; i < newMessages.length; i++) {
      if (newMessages[i].isRead != _messages[i].isRead) {
        return true; // Read status changed - blue tick update needed
      }
    }
    
    return false;
  }

  Future<void> _initializeChat() async {
    await _loadCurrentUserId();
    await _loadMessages();
  }

  Future<void> _loadCurrentUserId() async {
    await SharedPreferences.getInstance();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await MessageService.getMessages(widget.bookingId);
      
      if (response != null && response.success) {
        setState(() {
          _messages = response.messages.map((msg) {
            
            return ChatMessage(
              id: msg.id,
              text: msg.text,
              time: msg.createdAt,
              isMe: msg.isMine,
              isRead: msg.isRead,
            );
          }).toList();
          _messages.sort((a, b) => a.time.compareTo(b.time));
          
          _isLoading = false;
        });
        
        MessageService.markAsRead(widget.bookingId);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _stopTypingStatusPolling();
    _typingTimer?.cancel();
    _messageController.removeListener(_onTextChanged);
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: messageText,
      time: DateTime.now(),
      isMe: true,
      isRead: false,
    );
    
    setState(() {
      _messages.add(tempMessage);
      _messageController.clear();
    });
    
    _scrollToBottom();
    
    Future.delayed(Duration(milliseconds: 100), () {
      _messageFocusNode.requestFocus();
    });
    
    final sentMessage = await MessageService.sendMessage(widget.bookingId, messageText);
    
    if (sentMessage != null && mounted) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: sentMessage.id,
            text: sentMessage.text,
            time: sentMessage.createdAt,
            isMe: true,
            isRead: sentMessage.isRead,
          );
        }
      });
    }
    
    _scrollToBottom();
  }

  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  String _formatMeetingTime(DateTime time) {
    final day = time.day;
    final month = _getMonthName(time.month);
    final year = time.year;
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    
    return '$day $month $year, $hour:$minute $period';
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Build animated typing dots indicator
  Widget _buildTypingDots(Color color) {
    return _TypingDotsAnimation(color: color);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final meetingCardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 16.0;
    final meetingIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 18.0 : 24.0;
    final meetingTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final meetingIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    final chatListPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 10.0 : 16.0;
    
    final dateSeparatorMarginV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorPaddingV = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final dateSeparatorRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    final bubbleMaxWidthFactor = isDesktop ? 0.55 : isTablet ? 0.65 : isSmallScreen ? 0.80 : 0.75;
    final bubbleRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bubblePaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bubblePaddingV = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final bubbleMarginBottom = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final bubbleTextSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final bubbleTimeSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final bubbleReadIconSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    
    final inputBarPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 16.0;
    final inputBarPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final inputFieldRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final inputFieldPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final inputIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final inputHintSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    final actionIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Future.delayed(Duration(milliseconds: 50), () {
          _messageFocusNode.requestFocus();
        });
      },
      child: BaseScreen(
        title: widget.profileName,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: actionIconSize),
            onPressed: () {
              _showProfileInfo(context, colors, primaryColor);
            },
          ),
        ],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(meetingCardPadding),
                color: primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: primaryColor,
                      size: meetingIconSize,
                    ),
                    SizedBox(width: meetingIconSpacing),
                    Expanded(
                      child: Text(
                        'Meeting scheduled: ${_formatMeetingTime(widget.meetingTime)}',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: meetingTextSize,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_calendar,
                        color: primaryColor,
                        size: meetingIconSize,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule meeting feature coming soon'),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : _hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: colors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load messages',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please check your internet connection',
                                  style: TextStyle(
                                    color: colors.textTertiary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadMessages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: colors.textTertiary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No messages yet',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start the conversation!',
                                      style: TextStyle(
                                        color: colors.textTertiary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                },
                                child: RefreshIndicator(
                                  onRefresh: _loadMessages,
                                  color: primaryColor,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.all(chatListPadding),
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _messages[index];
                                      final showDate = index == 0 || 
                                          _formatDate(message.time) != _formatDate(_messages[index - 1].time);
                                      

                                      return Column(
                                        children: [
                                          if (showDate) ...[
                                            Center(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: dateSeparatorMarginV),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: dateSeparatorPaddingH, 
                                                  vertical: dateSeparatorPaddingV,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colors.card,
                                                  borderRadius: BorderRadius.circular(dateSeparatorRadius),
                                                ),
                                                child: Text(
                                                  _formatDate(message.time),
                                                  style: TextStyle(
                                                    color: colors.textTertiary,
                                                    fontSize: dateSeparatorTextSize,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          _buildMessageBubble(
                                            message, 
                                            colors, 
                                            primaryColor,
                                            maxWidthFactor: bubbleMaxWidthFactor,
                                            radius: bubbleRadius,
                                            paddingH: bubblePaddingH,
                                            paddingV: bubblePaddingV,
                                            marginBottom: bubbleMarginBottom,
                                            textSize: bubbleTextSize,
                                            timeSize: bubbleTimeSize,
                                            readIconSize: bubbleReadIconSize,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
              ),
              
              // Typing indicator
              if (_isOtherUserTyping)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: inputBarPaddingH, vertical: 8),
                  color: colors.card.withOpacity(0.5),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      _buildTypingDots(primaryColor),
                      SizedBox(width: 8),
                      Text(
                        '${widget.profileName} is typing...',
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Input bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: inputBarPaddingH, vertical: inputBarPaddingV),
                color: colors.card,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: colors.textTertiary,
                        size: inputIconSize,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attachment feature coming soon'),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        style: TextStyle(fontSize: inputHintSize),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: colors.textTertiary,
                            fontSize: inputHintSize,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(inputFieldRadius),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colors.background,
                          contentPadding: EdgeInsets.symmetric(horizontal: inputFieldPaddingH),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (_) {
                          _sendMessage();
                          Future.delayed(Duration(milliseconds: 100), () {
                            _messageFocusNode.requestFocus();
                          });
                        },
                        onTap: () {
                          if (!_messageFocusNode.hasFocus) {
                            _messageFocusNode.requestFocus();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: primaryColor,
                        size: inputIconSize,
                      ),
                      onPressed: () {
                        _sendMessage();
                        _messageFocusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageBubble(
    ChatMessage message, 
    AppColorSet colors, 
    Color primaryColor, {
    required double maxWidthFactor,
    required double radius,
    required double paddingH,
    required double paddingV,
    required double marginBottom,
    required double textSize,
    required double timeSize,
    required double readIconSize,
  }) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
        ),
        decoration: BoxDecoration(
          color: message.isMe 
              ? colors.card
              : primaryColor,
          borderRadius: BorderRadius.circular(radius).copyWith(
            bottomRight: message.isMe ? const Radius.circular(0) : null,
            bottomLeft: !message.isMe ? const Radius.circular(0) : null,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? colors.textPrimary : Colors.white,
                fontSize: textSize,
              ),
            ),
            SizedBox(height: paddingV * 0.4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.time),
                  style: TextStyle(
                    color: message.isMe 
                        ? colors.textTertiary 
                        : Colors.white.withOpacity(0.7),
                    fontSize: timeSize,
                  ),
                ),
                if (message.isMe) ...[
                  SizedBox(width: paddingV * 0.4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: readIconSize,
                    color: message.isRead 
                        ? Colors.blue 
                        : colors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showProfileInfo(BuildContext context, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final sheetRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
    final sheetPadding = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 16.0 : 24.0;
    final avatarRadius = isDesktop ? 70.0 : isTablet ? 60.0 : isSmallScreen ? 40.0 : 50.0;
    final avatarIconSize = isDesktop ? 70.0 : isTablet ? 60.0 : isSmallScreen ? 40.0 : 50.0;
    final nameTextSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final meetingBadgePaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final meetingBadgePaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final meetingBadgeRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final meetingBadgeIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final meetingBadgeTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final actionButtonRadius = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final actionButtonIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final actionButtonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final actionButtonPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final spacingSmall = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final spacingMedium = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final spacingLarge = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(sheetPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: widget.profileImage != null 
                  ? NetworkImage(widget.profileImage!) 
                  : null,
              child: widget.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: avatarIconSize,
                      color: primaryColor,
                    )
                  : null,
            ),
            SizedBox(height: spacingMedium),
            Text(
              widget.profileName,
              style: TextStyle(
                fontSize: nameTextSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: spacingSmall),
            Container(
              padding: EdgeInsets.symmetric(horizontal: meetingBadgePaddingH, vertical: meetingBadgePaddingV),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(meetingBadgeRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event,
                    color: primaryColor,
                    size: meetingBadgeIconSize,
                  ),
                  SizedBox(width: spacingSmall),
                  Text(
                    'Meeting: ${_formatMeetingTime(widget.meetingTime)}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: meetingBadgeTextSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.call,
                  label: 'Call',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call feature coming soon')),
                    );
                  },
                  buttonRadius: actionButtonRadius,
                  iconSize: actionButtonIconSize,
                  textSize: actionButtonTextSize,
                  padding: actionButtonPadding,
                  spacing: spacingSmall,
                ),
                _buildActionButton(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video call feature coming soon')),
                    );
                  },
                  buttonRadius: actionButtonRadius,
                  iconSize: actionButtonIconSize,
                  textSize: actionButtonTextSize,
                  padding: actionButtonPadding,
                  spacing: spacingSmall,
                ),
                _buildActionButton(
                  icon: Icons.block,
                  label: 'Block',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Block feature coming soon')),
                    );
                  },
                  buttonRadius: actionButtonRadius,
                  iconSize: actionButtonIconSize,
                  textSize: actionButtonTextSize,
                  padding: actionButtonPadding,
                  spacing: spacingSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double buttonRadius,
    required double iconSize,
    required double textSize,
    required double padding,
    required double spacing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: buttonRadius,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: textSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated typing dots widget
class _TypingDotsAnimation extends StatefulWidget {
  final Color color;
  
  const _TypingDotsAnimation({required this.color});
  
  @override
  State<_TypingDotsAnimation> createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 28,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              // Calculate animation phase for each dot (staggered)
              final phase = (_controller.value + (index * 0.33)) % 1.0;
              // Create bounce effect
              final bounce = phase < 0.5 
                  ? phase * 2 
                  : 2 - (phase * 2);
              final offset = -4 * bounce;
              
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
