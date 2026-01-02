import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            SlideTransition(
              position: _slideAnimation,
              child: Container(
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
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
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
                                  [Icons.local_cafe, Icons.sports, Icons.movie, Icons.music_note, Icons.restaurant][index % 5],
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
                                          ['Coffee Meetup', 'Sports Day', 'Movie Night', 'Music Festival', 'Dinner Party'][index % 5],
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
                                          ['Dec 18, 2025', 'Dec 20, 2025', 'Dec 22, 2025', 'Dec 25, 2025', 'Dec 27, 2025'][index % 5],
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
                                            ['Central Park', 'Sports Club', 'City Cinema', 'Beach Arena', 'Luxury Restaurant'][index % 5],
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
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                height: peopleListHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
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
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: primaryColor,
                                size: personAvatarSize * 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Text(
                            'Person ${index + 1}',
                            style: TextStyle(
                              fontSize: personNameSize,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
