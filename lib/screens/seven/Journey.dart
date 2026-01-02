import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> with TickerProviderStateMixin {
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
    final cardTitleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : isSmallScreen ? 15.0 : 18.0;
    final cardBodyFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    
    final heroIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 48.0 : 64.0;
    final cardIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    
    final maxContentWidth = isDesktop ? 900.0 : double.infinity;
    
    return BaseScreen(
      title: 'Journey to Meaningful Connections',
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
                    'From feeling alone to finding your perfect activity partner', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildJourneySteps(
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
                    'Sign Up Process', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildRegistrationSteps(
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
                    'Safety Tips', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: verticalPadding * 0.5,
                  ),
                  _buildSafetySection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    iconSize: cardIconSize,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing + 8),
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
              Icons.route,
              size: iconSize,
              color: primaryColor,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'Your Journey to Connections',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'Discover how SettingWala helps you connect with like-minded people through shared activities and interests.',
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

  Widget _buildJourneySteps(
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
        _buildStepCard(
          step: '01',
          title: 'Bas Kar Pagle, Rulayega Kya?',
          content: 'Akele akele ghoom rahe ho, koi interesting person nahi mil raha? "Koi toh mile yaar" wala feeling aa raha hai na?',
          icon: Icons.sentiment_dissatisfied,
          colors: colors,
          primaryColor: primaryColor,
          cardRadius: cardRadius,
          cardPadding: cardPadding,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
        ),
        SizedBox(height: itemSpacing),
        _buildStepCard(
          step: '02',
          title: 'SettingWala Mein Aa Jao!',
          content: 'Yahan sab cool log hain! Verified profiles dekho aur "Ye toh meri type ka hai" wala feeling lo. Guaranteed maza!',
          icon: Icons.sentiment_satisfied,
          colors: colors,
          primaryColor: primaryColor,
          cardRadius: cardRadius,
          cardPadding: cardPadding,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
        ),
        SizedBox(height: itemSpacing),
        _buildStepCard(
          step: '03',
          title: 'Setting Ho Gayi! 🔥',
          content: '"Ye bhi theek hai" se "Ye toh mast hai" tak ka safar! Real mein mil ke activities karo, setting complete!',
          icon: Icons.celebration,
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

  Widget _buildRegistrationSteps(
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
          title: '1. Sign Up with Google',
          content: 'Getting started is quick and secure. Simply sign up using your Google account - no complicated forms or lengthy registration process.\n\n• Secure Google OAuth authentication\n• Verified email address\n• Instant account creation',
          icon: Icons.login,
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
          title: '2. Complete Your Profile',
          content: 'Create a compelling profile that showcases who you are. A complete profile is required to join events and increases your chances of finding the right match.\n\n• Upload your best profile picture\n• Add your interests and hobbies\n• Share your basic information\n\n💡 Pro Tip: Profiles that are 100% complete get 3x more event participation!',
          icon: Icons.person,
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
          title: '3. Join Local Events',
          content: 'Discover and join carefully curated local events where you can meet like-minded people in a comfortable, safe environment.\n\n• Browse upcoming events in your area\n• Pay per event (no subscriptions)\n• Meet verified members only',
          icon: Icons.event,
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
          title: '4. Build Great Friendships',
          content: 'Connect with people who share your interests and values. Build meaningful friendships that can last a lifetime.\n\n• Meet in safe, public environments\n• Connect based on shared interests\n• Build lasting relationships',
          icon: Icons.group,
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

  Widget _buildSafetySection(
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
          title: 'Safety First',
          content: 'While SettingWala provides a secure platform with verified profiles, it\'s important to stay vigilant and follow these safety guidelines for the best experience.',
          icon: Icons.shield,
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
          title: 'Online Safety',
          content: 'Protect Your Personal Information:\n\n• Never share your full name, address, or phone number in your profile\n• Avoid sharing financial information or workplace details\n• Use the platform\'s messaging system initially\n• Be cautious about sharing social media profiles\n\nRed Flags to Watch For:\n\n• Requests for money or financial assistance\n• Profiles with limited or suspicious photos\n• Immediate requests to move off the platform\n• Overly aggressive or inappropriate messages',
          icon: Icons.security,
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
          title: 'Meeting in Person',
          content: 'First Meeting Guidelines:\n\n• Meet in public places during daytime\n• Inform a friend or family member about your plans\n• Arrange your own transportation\n• Keep your phone charged and accessible\n\nTrust Your Instincts:\n\n• If something feels off, leave immediately\n• Don\'t feel obligated to stay if uncomfortable\n• Watch your drink and never leave it unattended\n• Set boundaries and communicate them clearly',
          icon: Icons.people,
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


  Widget _buildStepCard({
    required String step,
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  step,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
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
                  SizedBox(height: cardPadding * 0.5),
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
}
