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

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _currentUserId;
  
  @override
  void initState() {
    super.initState();
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
    
    // Load current user ID first, then load messages
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadCurrentUserId();
    await _loadMessages();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('user_id');
    print('Current User ID: $_currentUserId');
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
          _messages = response.messages.map((msg) => ChatMessage(
            id: msg.id,
            text: msg.text,
            time: msg.createdAt,
            isMe: msg.senderId == _currentUserId,
            isRead: msg.isRead,
          )).toList();
          _isLoading = false;
        });
        
        // Mark messages as read
        MessageService.markAsRead(widget.bookingId);
        
        // Scroll to bottom after rendering
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
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    
    // Create temporary message for immediate UI feedback
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
    
    // Send message to API
    final sentMessage = await MessageService.sendMessage(widget.bookingId, messageText);
    
    if (sentMessage != null && mounted) {
      setState(() {
        // Replace temp message with actual message from server
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive meeting info card
    final meetingCardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 16.0;
    final meetingIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 18.0 : 24.0;
    final meetingTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final meetingIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    // Responsive chat list
    final chatListPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 10.0 : 16.0;
    
    // Responsive date separator
    final dateSeparatorMarginV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorPaddingV = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final dateSeparatorRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dateSeparatorTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    // Responsive message bubble
    final bubbleMaxWidthFactor = isDesktop ? 0.55 : isTablet ? 0.65 : isSmallScreen ? 0.80 : 0.75;
    final bubbleRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bubblePaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bubblePaddingV = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final bubbleMarginBottom = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final bubbleTextSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final bubbleTimeSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final bubbleReadIconSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    
    // Responsive input bar
    final inputBarPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 16.0;
    final inputBarPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final inputFieldRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final inputFieldPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final inputIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final inputHintSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    // Responsive action bar icon size
    final actionIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    return BaseScreen(
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
            // Meeting info card
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
            
            // Chat messages
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
                          : RefreshIndicator(
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
            
            // Message input
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: primaryColor,
                      size: inputIconSize,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
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
              ? primaryColor
              : colors.card,
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
                color: message.isMe ? Colors.white : colors.textPrimary,
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
                        ? Colors.white.withOpacity(0.7) 
                        : colors.textTertiary,
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
                        : Colors.white.withOpacity(0.7),
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
    // Responsive variables for bottom sheet
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
                  color: primaryColor,
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