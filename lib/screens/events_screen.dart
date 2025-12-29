import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Sample event data
  final List<Map<String, dynamic>> _events = [
    {
      'name': 'Coffee Meetup',
      'date': 'Dec 18, 2025',
      'time': '10:00 AM - 12:00 PM',
      'location': 'Central Park Cafe',
      'icon': Icons.local_cafe,
      'attendees': 15,
      'description': 'Join us for a casual coffee meetup to discuss books and make new friends.',
      'fee': 299.0,
    },
    {
      'name': 'Sports Day',
      'date': 'Dec 20, 2025',
      'time': '8:00 AM - 5:00 PM',
      'location': 'Sports Club',
      'icon': Icons.sports,
      'attendees': 24,
      'description': 'A fun day of various sports activities. All skill levels welcome!',
      'fee': 599.0,
    },
    {
      'name': 'Movie Night',
      'date': 'Dec 22, 2025',
      'time': '7:00 PM - 10:00 PM',
      'location': 'City Cinema',
      'icon': Icons.movie,
      'attendees': 32,
      'description': 'Watch the latest blockbuster with fellow movie enthusiasts.',
      'fee': 399.0,
    },
    {
      'name': 'Music Festival',
      'date': 'Dec 25, 2025',
      'time': '4:00 PM - 11:00 PM',
      'location': 'Beach Arena',
      'icon': Icons.music_note,
      'attendees': 120,
      'description': 'Annual music festival featuring local bands and artists.',
      'fee': 999.0,
    },
    {
      'name': 'Dinner Party',
      'date': 'Dec 27, 2025',
      'time': '7:30 PM - 10:30 PM',
      'location': 'Luxury Restaurant',
      'icon': Icons.restaurant,
      'attendees': 18,
      'description': 'Elegant dinner party with gourmet food and great conversation.',
      'fee': 1499.0,
    },
    {
      'name': 'Hiking Trip',
      'date': 'Jan 05, 2026',
      'time': '6:00 AM - 2:00 PM',
      'location': 'Mountain Trails',
      'icon': Icons.terrain,
      'attendees': 12,
      'description': 'Explore beautiful hiking trails and enjoy nature with a friendly group.',
      'fee': 499.0,
    },
    {
      'name': 'Book Club',
      'date': 'Jan 10, 2026',
      'time': '5:00 PM - 7:00 PM',
      'location': 'Community Library',
      'icon': Icons.menu_book,
      'attendees': 8,
      'description': 'Monthly book club meeting to discuss our latest read over coffee.',
      'fee': 199.0,
    },
  ];

  List<Map<String, dynamic>> get filteredEvents {
    if (_searchController.text.isEmpty) {
      return _events;
    }
    
    return _events.where((event) {
      return event['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          event['location'].toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }

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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
    
    // Responsive search bar values
    final searchBarPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final searchBarHeight = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 42.0 : 48.0;
    final searchBarRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final searchHintSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final searchIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final searchContentPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    // Responsive list padding
    final listPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final listItemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive empty state values
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptySpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive FAB size
    final fabSize = isDesktop ? 64.0 : isTablet ? 60.0 : isSmallScreen ? 48.0 : 56.0;
    final fabIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 22.0 : 24.0;
    
    // Grid columns for tablet/desktop
    final gridCrossAxisCount = isDesktop ? 3 : isTablet ? 2 : 1;
    final useGrid = isTablet || isDesktop;
    
    return BaseScreen(
      title: 'Events',
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
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
                    setState(() {
                      _isSearching = value.isNotEmpty;
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
            
            // Events List or Grid
            Expanded(
              child: filteredEvents.isEmpty
                  ? Center(
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
                            'No events found',
                            style: TextStyle(
                              fontSize: emptyTitleSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: emptySpacing / 2),
                          Text(
                            'Try changing your search term',
                            style: TextStyle(
                              fontSize: emptySubtitleSize,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : useGrid
                      // Grid layout for tablet/desktop
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
                              child: EventCard(
                                name: event['name'],
                                date: event['date'],
                                time: event['time'],
                                location: event['location'],
                                icon: event['icon'],
                                attendees: event['attendees'],
                                description: event['description'],
                                fee: event['fee'],
                              ),
                            );
                          },
                        )
                      // List layout for phones
                      : ListView.builder(
                          padding: EdgeInsets.all(listPadding),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            return SlideTransition(
                              position: _slideAnimation,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: listItemSpacing),
                                child: EventCard(
                                  name: event['name'],
                                  date: event['date'],
                                  time: event['time'],
                                  location: event['location'],
                                  icon: event['icon'],
                                  attendees: event['attendees'],
                                  description: event['description'],
                                  fee: event['fee'],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create event feature coming soon')),
            );
          },
          backgroundColor: primaryColor,
          child: Icon(Icons.add, size: fabIconSize),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String name;
  final String date;
  final String time;
  final String location;
  final IconData icon;
  final int attendees;
  final String description;
  final double fee;

  const EventCard({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.icon,
    required this.attendees,
    required this.description,
    required this.fee,
  });

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
    
    // Responsive card values
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive header icon container
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final iconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final iconSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive typography
    final titleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final dateSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final locationSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final descriptionSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    // Responsive attendees badge
    final badgePaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final badgePaddingV = isDesktop ? 8.0 : isTablet ? 7.0 : isSmallScreen ? 4.0 : 6.0;
    final badgeRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final badgeIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final badgeTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final badgeIconSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    // Responsive location row
    final locationIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final locationIconSpacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    // Responsive spacing
    final titleDateSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    final sectionSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final buttonSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive button values
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
          // Event Header with Icon
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
                    icon,
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
                        name,
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
                        date,
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
                        '$attendees',
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
          
          // Event Details
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
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
                        location,
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
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionSize,
                    color: colors.textPrimary,
                  ),
                  maxLines: isTablet || isDesktop ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: buttonSpacing),
                
                // Join Event Button - Full Width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            eventName: name,
                            eventDate: date,
                            eventTime: time,
                            eventLocation: location,
                            eventFee: fee,
                          ),
                        ),
                      );
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
                      'Join Event',
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