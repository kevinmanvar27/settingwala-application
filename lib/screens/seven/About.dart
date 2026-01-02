import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    final sectionSpacing = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 24.0 : 32.0;
    final itemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    final sectionHeaderFontSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 18.0 : 22.0;
    final heroTitleFontSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final bodyFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final cardTitleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : isSmallScreen ? 15.0 : 18.0;
    final cardBodyFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    final valueTitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final valueBodyFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    final heroIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 48.0 : 64.0;
    final cardIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final valueIconSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 26.0 : 32.0;
    final pillAvatarRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    

    final gridCrossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final gridChildAspectRatio = isDesktop ? 1.1 : isTablet ? 1.15 : isSmallScreen ? 1.1 : 1.2;
    
    final maxContentWidth = isDesktop ? 900.0 : double.infinity;
    
    return BaseScreen(
      title: 'About Us',
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding + 4,
                    iconSize: heroIconSize,
                    titleFontSize: heroTitleFontSize,
                    bodyFontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Our Story', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildStorySection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    iconSize: cardIconSize,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Our Mission', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildMissionSection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding + 4,
                    pillAvatarRadius: pillAvatarRadius,
                    iconSize: cardIconSize,
                    titleFontSize: valueTitleFontSize,
                    bodyFontSize: smallFontSize,
                    missionFontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Our Values', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildValuesSection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    iconSize: valueIconSize,
                    titleFontSize: valueTitleFontSize,
                    bodyFontSize: valueBodyFontSize,
                    introFontSize: bodyFontSize,
                    gridCrossAxisCount: gridCrossAxisCount,
                    gridChildAspectRatio: gridChildAspectRatio,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, 
    AppColorSet colors, {
    required double fontSize,
    required double verticalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double itemSpacing,
  }) {
    return Card(
      elevation: 2,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_rounded,
              size: iconSize,
              color: primaryColor,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'About SettingWala',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'We believe everyone deserves to find their perfect friends. Our platform connects people through verified profiles, meaningful interactions, and unforgettable local events.',
              style: TextStyle(
                fontSize: bodyFontSize,
                color: colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double itemSpacing,
  }) {
    return Column(
      children: [
        _buildInfoCard(
          title: 'The Beginning',
          content: 'SettingWala was born from a simple belief: finding great friends shouldn\'t be complicated or superficial. We wanted to create a platform that values quality connections over quantity.',
          icon: Icons.history,
          colors: colors,
          primaryColor: primaryColor,
          cardRadius: cardRadius,
          cardPadding: cardPadding,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
        ),
        SizedBox(height: itemSpacing),
        _buildInfoCard(
          title: 'Our Approach',
          content: 'Our platform focuses on bringing together like-minded individuals through verified profiles and carefully curated local events for genuine connections.',
          icon: Icons.handshake,
          colors: colors,
          primaryColor: primaryColor,
          cardRadius: cardRadius,
          cardPadding: cardPadding,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
        ),
        SizedBox(height: itemSpacing),
        _buildInfoCard(
          title: 'Our Success',
          content: 'Since our launch, we\'ve helped thousands of people find their perfect match and build lasting relationships that inspire us every day.',
          icon: Icons.emoji_events,
          colors: colors,
          primaryColor: primaryColor,
          cardRadius: cardRadius,
          cardPadding: cardPadding,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
        ),
      ],
    );
  }

  Widget _buildMissionSection(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double pillAvatarRadius,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double missionFontSize,
    required double itemSpacing,
  }) {
    return Column(
      children: [
        Card(
          elevation: 2,
          color: colors.card,
          shadowColor: primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To create a safe, authentic, and meaningful platform where people can find genuine connections and build lasting friendships based on shared values, interests, and life goals.',
                  style: TextStyle(
                    fontSize: missionFontSize,
                    fontStyle: FontStyle.italic,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: itemSpacing + 8),
        Row(
          children: [
            Expanded(
              child: _buildPillCard(
                title: 'Safety First',
                content: 'Verified profiles and secure interactions ensure a safe environment for everyone to explore meaningful connections.',
                icon: Icons.verified_user,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                avatarRadius: pillAvatarRadius,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
            ),
          ],
        ),
        SizedBox(height: itemSpacing),
        Row(
          children: [
            Expanded(
              child: _buildPillCard(
                title: 'Real Connections',
                content: 'Local events and meaningful interactions foster genuine relationships that go beyond surface-level attraction.',
                icon: Icons.connect_without_contact,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                avatarRadius: pillAvatarRadius,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
            ),
          ],
        ),
        SizedBox(height: itemSpacing),
        Row(
          children: [
            Expanded(
              child: _buildPillCard(
                title: 'Lasting Love',
                content: 'We focus on compatibility and shared values to help you build long-term relationships that stand the test of time.',
                icon: Icons.favorite,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                avatarRadius: pillAvatarRadius,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValuesSection(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double introFontSize,
    required int gridCrossAxisCount,
    required double gridChildAspectRatio,
    required double itemSpacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The core principles that guide everything we do at SettingWala',
          style: TextStyle(
            fontSize: introFontSize,
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: itemSpacing + 8),
        Container(
          height: 350,
          child: GridView.count(
            crossAxisCount: gridCrossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: itemSpacing,
            mainAxisSpacing: itemSpacing,
            childAspectRatio: gridChildAspectRatio,
            children: [
              _buildValueCard(
                title: 'Authenticity',
                content: 'We encourage genuine profiles and honest interactions.',
                icon: Icons.verified,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
              _buildValueCard(
                title: 'Respect',
                content: 'Every member deserves to be treated with dignity and kindness.',
                icon: Icons.handshake,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
              _buildValueCard(
                title: 'Privacy',
                content: 'Your personal information is protected and never shared.',
                icon: Icons.lock,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
              _buildValueCard(
                title: 'Inclusivity',
                content: 'Love knows no boundaries - everyone is welcome here.',
                icon: Icons.diversity_3,
                colors: colors,
                primaryColor: primaryColor,
                cardRadius: cardRadius,
                cardPadding: cardPadding,
                iconSize: iconSize,
                titleFontSize: titleFontSize,
                bodyFontSize: bodyFontSize,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double cardPadding,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
  }) {
    return Card(
      elevation: 1,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: iconSize,
                ),
                SizedBox(width: cardPadding * 0.75),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: cardPadding * 0.75),
            Text(
              content,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillCard({
    required String title,
    required String content,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double cardPadding,
    required double avatarRadius,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
  }) {
    return Card(
      elevation: 1,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(
                icon,
                color: primaryColor,
                size: iconSize,
              ),
            ),
            SizedBox(width: cardPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: cardPadding * 0.25),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard({
    required String title,
    required String content,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double cardPadding,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
  }) {
    return Card(
      elevation: 1,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: iconSize,
            ),
            SizedBox(height: cardPadding * 0.75),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: cardPadding * 0.5),
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
