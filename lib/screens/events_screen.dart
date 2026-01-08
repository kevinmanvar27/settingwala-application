import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../theme/theme.dart';
import '../Service/event_service.dart';
import '../routes/app_routes.dart';
import '../utils/debouncer.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 300);
  bool _isSearching = false;
  
  bool _isLoading = true;
  String? _errorMessage;

  List<EventModel> _events = [];

  List<EventModel> get filteredEvents {
    if (_searchController.text.isEmpty) {
      return _events;
    }
    
    return _events.where((event) {
      final searchLower = _searchController.text.toLowerCase();
      return event.title.toLowerCase().contains(searchLower) ||
          (event.location?.toLowerCase().contains(searchLower) ?? false) ||
          (event.description?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadEvents();
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await EventService.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load events. Please try again.';
      });
      
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
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
    
    final searchBarPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final searchBarHeight = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 42.0 : 48.0;
    final searchBarRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final searchHintSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final searchIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final searchContentPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    final listPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final listItemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptySpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // FAB removed as per UI requirements
    
    final gridCrossAxisCount = isDesktop ? 3 : isTablet ? 2 : 1;
    final useGrid = isTablet || isDesktop;
    
    return BaseScreen(
      title: 'Events',
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(searchBarPadding),
              color: colors.card,
              child: Container(
                height: searchBarHeight,
                decoration: BoxDecoration(
                  color: colors.inputBackground,
                  borderRadius: BorderRadius.circular(searchBarRadius),
                  border: Border.all(color: colors.inputBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Debounce search to reduce unnecessary rebuilds
                    _searchDebouncer.run(() {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    });
                  },
                  style: TextStyle(fontSize: searchHintSize),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    hintStyle: TextStyle(
                      color: colors.textTertiary,
                      fontSize: searchHintSize,
                    ),
                    prefixIcon: Icon(Icons.search, color: primaryColor, size: searchIconSize),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colors.textTertiary, size: searchIconSize),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: searchContentPadding),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: _buildContent(
                colors: colors,
                primaryColor: primaryColor,
                listPadding: listPadding,
                listItemSpacing: listItemSpacing,
                emptyIconSize: emptyIconSize,
                emptyTitleSize: emptyTitleSize,
                emptySubtitleSize: emptySubtitleSize,
                emptySpacing: emptySpacing,
                useGrid: useGrid,
                gridCrossAxisCount: gridCrossAxisCount,
                isDesktop: isDesktop,
              ),
            ),
          ],
        ),
      ),
      // FAB removed as per requirement
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
    required bool useGrid,
    required int gridCrossAxisCount,
    required bool isDesktop,
  }) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: emptySpacing),
            Text(
              'Loading events...',
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
              onPressed: _loadEvents,
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

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: emptyIconSize,
              color: primaryColor.withOpacity(0.7),
            ),
            SizedBox(height: emptySpacing),
            Text(
              _isSearching ? 'No events found' : 'No events available',
              style: TextStyle(
                fontSize: emptyTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: emptySpacing / 2),
            Text(
              _isSearching 
                  ? 'Try changing your search term'
                  : 'Check back later for upcoming events',
              style: TextStyle(
                fontSize: emptySubtitleSize,
                color: colors.textSecondary,
              ),
            ),
            if (!_isSearching) ...[
              SizedBox(height: emptySpacing),
              ElevatedButton.icon(
                onPressed: _loadEvents,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: primaryColor,
      child: useGrid
          ? GridView.builder(
              padding: EdgeInsets.all(listPadding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCrossAxisCount,
                crossAxisSpacing: listItemSpacing,
                mainAxisSpacing: listItemSpacing,
                childAspectRatio: isDesktop ? 1.1 : 0.95,
              ),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return SlideTransition(
                  position: _slideAnimation,
                  child: EventCard(event: event),
                );
              },
            )
          : ListView.builder(
              padding: EdgeInsets.all(listPadding),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: listItemSpacing),
                    child: EventCard(event: event),
                  ),
                );
              },
            ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  IconData _getEventIcon() {
    final title = event.title.toLowerCase();
    if (title.contains('coffee') || title.contains('cafe')) return Icons.local_cafe;
    if (title.contains('sport') || title.contains('game')) return Icons.sports;
    if (title.contains('movie') || title.contains('cinema')) return Icons.movie;
    if (title.contains('music') || title.contains('concert')) return Icons.music_note;
    if (title.contains('dinner') || title.contains('restaurant')) return Icons.restaurant;
    if (title.contains('hike') || title.contains('trek')) return Icons.terrain;
    if (title.contains('book') || title.contains('read')) return Icons.menu_book;
    if (title.contains('party') || title.contains('celebration')) return Icons.celebration;
    if (title.contains('meet') || title.contains('dating')) return Icons.favorite;
    return Icons.event;
  }

  String _formatDate() {
    if (event.eventDate == null) return 'Date TBD';
    final date = event.eventDate!;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
    
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final iconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final iconSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final titleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final dateSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final locationSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final descriptionSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    final badgePaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final badgePaddingV = isDesktop ? 8.0 : isTablet ? 7.0 : isSmallScreen ? 4.0 : 6.0;
    final badgeRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final badgeIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final badgeTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final badgeIconSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    final locationIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final locationIconSpacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    final titleDateSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    final sectionSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final buttonSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final buttonRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final buttonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final buttonPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardRadius - 1),
                topRight: Radius.circular(cardRadius - 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconContainerPadding),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getEventIcon(),
                    color: primaryColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: titleDateSpacing),
                      Text(
                        _formatDate(),
                        style: TextStyle(
                          fontSize: dateSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(badgeRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: badgeIconSize,
                      ),
                      SizedBox(width: badgeIconSpacing),
                      Text(
                        '${event.participantsCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: badgeTextSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: locationIconSize,
                      color: primaryColor,
                    ),
                    SizedBox(width: locationIconSpacing),
                    Expanded(
                      child: Text(
                        event.location ?? 'Location TBD',
                        style: TextStyle(
                          fontSize: locationSize,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: sectionSpacing),
                
                Text(
                  event.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: descriptionSize,
                    color: colors.textPrimary,
                  ),
                  maxLines: isTablet || isDesktop ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: buttonSpacing),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppRoutes.toEventDetails(context, event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: buttonPaddingH, vertical: buttonPaddingV),
                    ),
                    child: Text(
                      event.isJoined ? 'View Details' : 'Join Event',
                      style: TextStyle(fontSize: buttonTextSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
