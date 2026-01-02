import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/chat_service.dart';
import '../model/getchatmodel.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _errorMessage;
  
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
    
    _loadChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadChats();
    }
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ChatService.getChats();

      if (result != null && result.success) {
        setState(() {
          _chats = result.data.chats;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _chats = [];
          _isLoading = false;
          _errorMessage = 'Failed to load chats';
        });
      }
    } catch (e) {
      
      setState(() {
        _chats = [];
        _isLoading = false;
        _errorMessage = 'Something went wrong';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }
  
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//+'), '/');
    return cleaned;
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}';
    }
  }
  
  String _formatMeetingTime(DateTime time) {
    final day = time.day;
    final month = _getMonthName(time.month);
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    
    return '$day $month, $hour:$minute $period';
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  Color _getStatusColor(String status, Color primaryColor) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return primaryColor;
    }
  }
  
  String _getLastMessageText(dynamic lastMessage) {
    if (lastMessage == null) {
      return 'No messages yet';
    }
    
    if (lastMessage is Map) {
      final text = lastMessage['text'] ?? lastMessage['message'] ?? lastMessage['content'];
      if (text != null && text.toString().isNotEmpty) {
        return text.toString();
      }
      return 'No messages yet';
    }
    
    if (lastMessage is String) {
      return lastMessage.isNotEmpty ? lastMessage : 'No messages yet';
    }
    
    final stringValue = lastMessage.toString();
    if (stringValue.isNotEmpty && stringValue != 'null') {
      return stringValue;
    }
    
    return 'No messages yet';
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
    
    final listPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 10.0 : 16.0;
    
    final actionIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    final fabIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptySpacingSmall = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final emptySpacingMedium = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final cardMarginBottom = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final avatarRadius = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 22.0 : 28.0;
    final avatarIconSize = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 22.0 : 28.0;
    final unreadDotSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 10.0 : 14.0;
    final unreadDotBorder = isDesktop ? 3.0 : isTablet ? 2.5 : isSmallScreen ? 1.5 : 2.0;
    
    final nameTextSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final timeTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final messageTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    final meetingBadgePaddingH = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final meetingBadgePaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    final meetingBadgeRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final meetingBadgeIconSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final meetingBadgeTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    final avatarSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final rowSpacingSmall = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    final rowSpacingMedium = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    return BaseScreen(
      title: 'Chats',
      showBackButton: false,
      actions: [
        IconButton(
          icon: Icon(Icons.search, size: actionIconSize),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search feature coming soon')),
            );
          },
        ),
      ],
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor, emptyIconSize, emptyTitleSize, emptySubtitleSize, emptySpacingSmall, emptySpacingMedium)
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  color: primaryColor,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _chats.isEmpty
                        ? _buildEmptyState(
                            colors,
                            iconSize: emptyIconSize,
                            titleSize: emptyTitleSize,
                            subtitleSize: emptySubtitleSize,
                            spacingSmall: emptySpacingSmall,
                            spacingMedium: emptySpacingMedium,
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(listPadding),
                            itemCount: _chats.length,
                            itemBuilder: (context, index) {
                              return _buildChatCard(
                                _chats[index], 
                                colors, 
                                primaryColor,
                                cardRadius: cardRadius,
                                cardMarginBottom: cardMarginBottom,
                                cardPadding: cardPadding,
                                avatarRadius: avatarRadius,
                                avatarIconSize: avatarIconSize,
                                unreadDotSize: unreadDotSize,
                                unreadDotBorder: unreadDotBorder,
                                nameTextSize: nameTextSize,
                                timeTextSize: timeTextSize,
                                messageTextSize: messageTextSize,
                                meetingBadgePaddingH: meetingBadgePaddingH,
                                meetingBadgePaddingV: meetingBadgePaddingV,
                                meetingBadgeRadius: meetingBadgeRadius,
                                meetingBadgeIconSize: meetingBadgeIconSize,
                                meetingBadgeTextSize: meetingBadgeTextSize,
                                avatarSpacing: avatarSpacing,
                                rowSpacingSmall: rowSpacingSmall,
                                rowSpacingMedium: rowSpacingMedium,
                              );
                            },
                          ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat feature coming soon')),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.chat, size: fabIconSize),
      ),
    );
  }
  
  Widget _buildErrorState(
    AppColorSet colors,
    Color primaryColor,
    double iconSize,
    double titleSize,
    double subtitleSize,
    double spacingSmall,
    double spacingMedium,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: iconSize,
            color: colors.textTertiary,
          ),
          SizedBox(height: spacingMedium),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: spacingSmall),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: subtitleSize,
              color: colors.textTertiary,
            ),
          ),
          SizedBox(height: spacingMedium),
          ElevatedButton.icon(
            onPressed: _loadChats,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(
    AppColorSet colors, {
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
    required double spacingSmall,
    required double spacingMedium,
  }) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: iconSize,
                color: colors.textTertiary,
              ),
              SizedBox(height: spacingMedium),
              Text(
                'No chats yet',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: spacingSmall),
              Text(
                'Your approved connections will appear here',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildChatCard(
    Chat chat, 
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardMarginBottom,
    required double cardPadding,
    required double avatarRadius,
    required double avatarIconSize,
    required double unreadDotSize,
    required double unreadDotBorder,
    required double nameTextSize,
    required double timeTextSize,
    required double messageTextSize,
    required double meetingBadgePaddingH,
    required double meetingBadgePaddingV,
    required double meetingBadgeRadius,
    required double meetingBadgeIconSize,
    required double meetingBadgeTextSize,
    required double avatarSpacing,
    required double rowSpacingSmall,
    required double rowSpacingMedium,
  }) {
    final hasUnread = chat.unreadCount > 0;
    final avatarUrl = _cleanImageUrl(chat.otherUser.avatar);
    final lastMessageText = _getLastMessageText(chat.lastMessage);
    final statusColor = _getStatusColor(chat.bookingStatus, primaryColor);
    
    return Card(
      elevation: 1,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      margin: EdgeInsets.only(bottom: cardMarginBottom),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                profileName: chat.otherUser.name,
                profileImage: avatarUrl,
                meetingTime: chat.bookingDate,
                bookingId: chat.bookingId,
              ),
            ),
          ).then((_) {
            _loadChats();
          });
        },
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl) 
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: avatarIconSize,
                            color: primaryColor,
                          )
                        : null,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: unreadDotSize,
                        height: unreadDotSize,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.card,
                            width: unreadDotBorder,
                          ),
                        ),
                        child: chat.unreadCount > 0
                            ? Center(
                                child: Text(
                                  chat.unreadCount > 9 ? '9+' : chat.unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: unreadDotSize * 0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
              SizedBox(width: avatarSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherUser.name,
                            style: TextStyle(
                              fontSize: nameTextSize,
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: rowSpacingSmall),
                        Text(
                          _formatTime(chat.updatedAt),
                          style: TextStyle(
                            fontSize: timeTextSize,
                            color: hasUnread 
                                ? primaryColor 
                                : colors.textTertiary,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rowSpacingSmall),
                    Text(
                      lastMessageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: messageTextSize,
                        color: hasUnread 
                            ? colors.textPrimary 
                            : colors.textTertiary,
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: rowSpacingMedium),
                    Row(
                      children: [
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
                                size: meetingBadgeIconSize,
                                color: primaryColor,
                              ),
                              SizedBox(width: rowSpacingSmall),
                              Text(
                                _formatMeetingTime(chat.bookingDate),
                                style: TextStyle(
                                  fontSize: meetingBadgeTextSize,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: rowSpacingSmall),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: meetingBadgePaddingH, vertical: meetingBadgePaddingV),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(meetingBadgeRadius),
                          ),
                          child: Text(
                            chat.bookingStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: meetingBadgeTextSize - 1,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}
