import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../utils/api_constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../Service/event_service.dart';
import '../Service/user_service.dart';
import '../model/getusersmodel.dart' as users_model;
import '../routes/app_routes.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // API Data State Variables
  List<EventModel> _upcomingEvents = [];
  List<users_model.User> _peopleNearYou = [];
  bool _isLoadingEvents = true;
  bool _isLoadingPeople = true;
  String? _eventsError;
  String? _peopleError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward();
    
    // Load API data
    _loadUpcomingEvents();
    _loadPeopleNearYou();
  }

  // Fetch upcoming events from API
  Future<void> _loadUpcomingEvents() async {
    try {
      final events = await EventService.getEvents();
      if (mounted) {
        setState(() {
          _upcomingEvents = events.take(5).toList(); // Show max 5 events
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _eventsError = 'Failed to load events';
          _isLoadingEvents = false;
        });
      }
    }
  }

  // Fetch people near you from API
  Future<void> _loadPeopleNearYou() async {
    try {
      final usersResponse = await UserService.getUsers();
      if (mounted) {
        setState(() {
          if (usersResponse != null && usersResponse.success) {
            _peopleNearYou = usersResponse.data.users.take(4).toList(); // Show max 4 users
          }
          _isLoadingPeople = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _peopleError = 'Failed to load people';
          _isLoadingPeople = false;
        });
      }
    }
  }

  // Navigate to event details
  void _navigateToEventDetails(EventModel event) {
    AppRoutes.toEventDetails(context, event);
  }

  // Navigate to person profile
  void _navigateToPersonProfile(users_model.User person) {
    // Convert User model to Map for PersonProfileScreen
    final personMap = {
      'id': person.id,
      'name': person.name,
      'profile_picture': person.profilePicture,
      'age': person.age,
      'city': person.city,
      'state': person.state,
      'bio': person.bio,
      'gender': person.gender,
      'is_verified': person.isVerified,
      'is_online': person.isOnline,
      'rating': person.rating,
      'reviews_count': person.reviewsCount,
    };
    AppRoutes.toPersonProfile(context, personMap);
  }

  // Get event icon based on title or index
  IconData _getEventIcon(EventModel event, int index) {
    final title = event.title.toLowerCase();
    if (title.contains('coffee') || title.contains('cafe')) return Icons.local_cafe;
    if (title.contains('sport') || title.contains('game')) return Icons.sports;
    if (title.contains('movie') || title.contains('film')) return Icons.movie;
    if (title.contains('music') || title.contains('concert')) return Icons.music_note;
    if (title.contains('dinner') || title.contains('food') || title.contains('restaurant')) return Icons.restaurant;
    if (title.contains('party')) return Icons.celebration;
    if (title.contains('meet') || title.contains('network')) return Icons.people;
    // Default icons rotation
    final defaultIcons = [Icons.event, Icons.local_cafe, Icons.sports, Icons.movie, Icons.music_note];
    return defaultIcons[index % defaultIcons.length];
  }

  // Format event date
  String _formatEventDate(DateTime? date) {
    if (date == null) return 'TBA';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final user = FirebaseAuth.instance.currentUser;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final bodyPadding = isSmallScreen ? 12.0 : (isTablet ? 24.0 : 16.0);
    final welcomeFontSize = isSmallScreen ? 20.0 : (isTablet ? 28.0 : 24.0);
    final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final sectionTitleSize = isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0);
    final cardWidth = isSmallScreen ? 200.0 : (isTablet ? 320.0 : 260.0);
    final cardHeight = isSmallScreen ? 180.0 : (isTablet ? 260.0 : 220.0);
    final cardImageHeight = isSmallScreen ? 80.0 : (isTablet ? 120.0 : 100.0);
    final cardTitleSize = isSmallScreen ? 14.0 : (isTablet ? 20.0 : 18.0);
    final cardSubtitleSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final personAvatarSize = isSmallScreen ? 50.0 : (isTablet ? 70.0 : 60.0);
    final personContainerWidth = isSmallScreen ? 65.0 : (isTablet ? 95.0 : 80.0);
    final personNameSize = isSmallScreen ? 10.0 : (isTablet ? 14.0 : 12.0);
    final peopleListHeight = isSmallScreen ? 85.0 : (isTablet ? 115.0 : 100.0);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(bodyPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Container - Full Width
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity, // Full width
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.displayName?.split(' ')[0] ?? 'Friend'}!',
                        style: TextStyle(
                          fontSize: welcomeFontSize,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Text(
                        'Ready to make some meaningful connections today?',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            // Upcoming Events - API Data with Navigation
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                height: cardHeight,
                child: _isLoadingEvents
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : _eventsError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: colors.textSecondary, size: 40),
                                const SizedBox(height: 8),
                                Text(_eventsError!, style: TextStyle(color: colors.textSecondary)),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoadingEvents = true;
                                      _eventsError = null;
                                    });
                                    _loadUpcomingEvents();
                                  },
                                  child: Text('Retry', style: TextStyle(color: primaryColor)),
                                ),
                              ],
                            ),
                          )
                        : _upcomingEvents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_busy, color: colors.textSecondary, size: 40),
                                    const SizedBox(height: 8),
                                    Text('No upcoming events', style: TextStyle(color: colors.textSecondary)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _upcomingEvents.length,
                                itemBuilder: (context, index) {
                                  final event = _upcomingEvents[index];
                                  return GestureDetector(
                                    onTap: () => _navigateToEventDetails(event),
                                    child: Container(
                                      width: cardWidth,
                                      margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colors.card,
                                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: cardImageHeight,
                                              decoration: BoxDecoration(
                                                color: colors.surface,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(isSmallScreen ? 19 : 29),
                                                  topRight: Radius.circular(isSmallScreen ? 19 : 29),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  _getEventIcon(event, index),
                                                  color: primaryColor,
                                                  size: isSmallScreen ? 30 : (isTablet ? 50 : 40),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          event.title,
                                                          style: TextStyle(
                                                            fontSize: cardTitleSize,
                                                            fontWeight: FontWeight.bold,
                                                            color: colors.textPrimary,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                                        Text(
                                                          _formatEventDate(event.eventDate),
                                                          style: TextStyle(
                                                            fontSize: cardSubtitleSize,
                                                            color: colors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: isSmallScreen ? 12 : 16,
                                                          color: primaryColor,
                                                        ),
                                                        SizedBox(width: isSmallScreen ? 2 : 4),
                                                        Expanded(
                                                          child: Text(
                                                            event.location ?? 'Location TBA',
                                                            style: TextStyle(
                                                              fontSize: cardSubtitleSize,
                                                              color: colors.textTertiary,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'People Near You',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            // People Near You - API Data (Max 4 users) with Navigation
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                height: peopleListHeight,
                child: _isLoadingPeople
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : _peopleError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: colors.textSecondary, size: 30),
                                const SizedBox(height: 4),
                                Text(_peopleError!, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoadingPeople = true;
                                      _peopleError = null;
                                    });
                                    _loadPeopleNearYou();
                                  },
                                  child: Text('Retry', style: TextStyle(color: primaryColor, fontSize: 12)),
                                ),
                              ],
                            ),
                          )
                        : _peopleNearYou.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline, color: colors.textSecondary, size: 30),
                                    const SizedBox(height: 4),
                                    Text('No people found', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _peopleNearYou.length,
                                itemBuilder: (context, index) {
                                  final person = _peopleNearYou[index];
                                  final hasProfilePic = person.profilePicture.isNotEmpty;
                                  return GestureDetector(
                                    onTap: () => _navigateToPersonProfile(person),
                                    child: Container(
                                      width: personContainerWidth,
                                      margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: personAvatarSize,
                                            height: personAvatarSize,
                                            decoration: BoxDecoration(
                                              color: colors.card,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: primaryColor.withOpacity(0.3),
                                                width: 2,
                                              ),
                                              image: hasProfilePic
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        ApiConstants.getStorageUrl(person.profilePicture),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: hasProfilePic
                                                ? null
                                                : Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      color: primaryColor,
                                                      size: personAvatarSize * 0.5,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(height: isSmallScreen ? 4 : 8),
                                          Text(
                                            person.name.split(' ').first, // Show first name only
                                            style: TextStyle(
                                              fontSize: personNameSize,
                                              color: colors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
