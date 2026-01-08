import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../theme/theme.dart';
import '../Service/event_service.dart';
import 'event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMyEvents();
  }

  void _setupAnimations() {
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
  }

  Future<void> _loadMyEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all events and filter by is_joined flag
      // Note: getMyEvents() endpoint does not exist in API, use getEvents() with filter
      final allEventsResult = await EventService.getEvents();
      
      // Filter all events to get only joined ones
      final joinedEvents = allEventsResult.where((e) => e.isJoined).toList();
      
      // Sort by event date (upcoming first)
      joinedEvents.sort((a, b) {
        if (a.eventDate == null && b.eventDate == null) return 0;
        if (a.eventDate == null) return 1;
        if (b.eventDate == null) return -1;
        return a.eventDate!.compareTo(b.eventDate!);
      });
      
      setState(() {
        _myEvents = joinedEvents;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load your events. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date TBD';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Time TBD';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  bool _isUpcoming(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
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
    
    final listPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final listItemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptySpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    return BaseScreen(
      title: 'My Events',
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildContent(
          colors: colors,
          primaryColor: primaryColor,
          listPadding: listPadding,
          listItemSpacing: listItemSpacing,
          emptyIconSize: emptyIconSize,
          emptyTitleSize: emptyTitleSize,
          emptySubtitleSize: emptySubtitleSize,
          emptySpacing: emptySpacing,
          isDesktop: isDesktop,
          isTablet: isTablet,
          isSmallScreen: isSmallScreen,
        ),
      ),
    );
  }

  Widget _buildContent({
    required AppColorSet colors,
    required Color primaryColor,
    required double listPadding,
    required double listItemSpacing,
    required double emptyIconSize,
    required double emptyTitleSize,
    required double emptySubtitleSize,
    required double emptySpacing,
    required bool isDesktop,
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: emptySpacing),
            Text(
              'Loading your events...',
              style: TextStyle(
                fontSize: emptySubtitleSize,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: emptyIconSize,
              color: AppColors.error.withOpacity(0.7),
            ),
            SizedBox(height: emptySpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: emptyTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: emptySpacing),
            ElevatedButton.icon(
              onPressed: _loadMyEvents,
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

    if (_myEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: emptyIconSize,
              color: primaryColor.withOpacity(0.5),
            ),
            SizedBox(height: emptySpacing),
            Text(
              'No Events Joined Yet',
              style: TextStyle(
                fontSize: emptyTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: emptySpacing / 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: listPadding * 2),
              child: Text(
                'Join events to see them here. Explore available events and start connecting!',
                style: TextStyle(
                  fontSize: emptySubtitleSize,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Separate upcoming and past events
    final upcomingEvents = _myEvents.where((e) => _isUpcoming(e.eventDate)).toList();
    final pastEvents = _myEvents.where((e) => !_isUpcoming(e.eventDate)).toList();

    return RefreshIndicator(
      onRefresh: _loadMyEvents,
      color: primaryColor,
      child: ListView(
        padding: EdgeInsets.all(listPadding),
        children: [
          if (upcomingEvents.isNotEmpty) ...[
            _buildSectionHeader('Upcoming Events', colors, primaryColor, isSmallScreen),
            SizedBox(height: listItemSpacing / 2),
            ...upcomingEvents.map((event) => Padding(
              padding: EdgeInsets.only(bottom: listItemSpacing),
              child: _buildEventCard(event, colors, primaryColor, isSmallScreen, isTablet, isDesktop, true),
            )),
            SizedBox(height: listItemSpacing),
          ],
          if (pastEvents.isNotEmpty) ...[
            _buildSectionHeader('Past Events', colors, primaryColor, isSmallScreen),
            SizedBox(height: listItemSpacing / 2),
            ...pastEvents.map((event) => Padding(
              padding: EdgeInsets.only(bottom: listItemSpacing),
              child: _buildEventCard(event, colors, primaryColor, isSmallScreen, isTablet, isDesktop, false),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColorSet colors, Color primaryColor, bool isSmallScreen) {
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    
    return Row(
      children: [
        Container(
          width: 4,
          height: titleSize + 8,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(
    EventModel event,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
    bool isUpcoming,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final titleSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final iconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final badgePaddingH = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final badgePaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    final badgeTextSize = isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 9.0 : 10.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        ).then((_) => _loadMyEvents());
      },
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: isUpcoming 
                ? primaryColor.withOpacity(0.3) 
                : colors.border.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: (isUpcoming ? primaryColor : colors.textTertiary).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Icon
                Container(
                  padding: EdgeInsets.all(cardPadding * 0.75),
                  decoration: BoxDecoration(
                    color: (isUpcoming ? primaryColor : colors.textTertiary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(cardRadius * 0.6),
                  ),
                  child: Icon(
                    event.isCoupleEvent ? Icons.favorite : Icons.event,
                    color: isUpcoming ? primaryColor : colors.textTertiary,
                    size: iconSize * 1.5,
                  ),
                ),
                SizedBox(width: cardPadding * 0.75),
                // Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: isUpcoming ? colors.textPrimary : colors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: badgePaddingH,
                              vertical: badgePaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: isUpcoming 
                                  ? AppColors.success.withOpacity(0.1)
                                  : colors.textTertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(badgePaddingH),
                            ),
                            child: Text(
                              isUpcoming ? 'Upcoming' : 'Completed',
                              style: TextStyle(
                                fontSize: badgeTextSize,
                                fontWeight: FontWeight.w600,
                                color: isUpcoming ? AppColors.success : colors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: cardPadding * 0.5),
                      // Date & Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: iconSize,
                            color: isUpcoming ? primaryColor : colors.textTertiary,
                          ),
                          SizedBox(width: cardPadding * 0.3),
                          Text(
                            _formatDate(event.eventDate),
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: isUpcoming ? colors.textSecondary : colors.textTertiary,
                            ),
                          ),
                          SizedBox(width: cardPadding),
                          Icon(
                            Icons.access_time,
                            size: iconSize,
                            color: isUpcoming ? primaryColor : colors.textTertiary,
                          ),
                          SizedBox(width: cardPadding * 0.3),
                          Text(
                            _formatTime(event.eventDate),
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: isUpcoming ? colors.textSecondary : colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      if (event.location != null && event.location!.isNotEmpty) ...[
                        SizedBox(height: cardPadding * 0.3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: iconSize,
                              color: isUpcoming ? primaryColor : colors.textTertiary,
                            ),
                            SizedBox(width: cardPadding * 0.3),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: isUpcoming ? colors.textSecondary : colors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Participants count
            if (event.participantsCount > 0) ...[
              SizedBox(height: cardPadding * 0.75),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding * 0.75,
                  vertical: cardPadding * 0.4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(cardRadius * 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: iconSize,
                      color: primaryColor,
                    ),
                    SizedBox(width: cardPadding * 0.3),
                    Text(
                      '${event.participantsCount} participants',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
