import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> with TickerProviderStateMixin {
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
    
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final itemSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    final sectionHeaderFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 18.0 : 20.0;
    final bodyFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final cardTitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 15.0 : 16.0;
    final cardBodyFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    
    final maxContentWidth = isDesktop ? 900.0 : double.infinity;
    
    return BaseScreen(
      title: 'Safety Tips',
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
                    iconSize: isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 48.0 : 64.0,
                    titleFontSize: isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0,
                    bodyFontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Safety First', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildInfoCard(
                    title: 'Your safety is our top priority',
                    content: 'Follow these essential guidelines to ensure a safe and enjoyable dating experience on SettingWala. While SettingWala provides a secure platform with verified profiles, it\'s important to stay vigilant and follow these safety guidelines for the best experience.',
                    icon: Icons.shield,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    iconSize: isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Online Safety', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildSafetyCard(
                    title: 'Protect Your Personal Information',
                    items: [
                      'Never share your full name, address, or phone number in your profile',
                      'Avoid sharing financial information or workplace details',
                      'Use the platform\'s messaging system initially',
                      'Be cautious about sharing social media profiles',
                    ],
                    icon: Icons.lock,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: itemSpacing),
                  _buildSafetyCard(
                    title: 'Red Flags to Watch For',
                    items: [
                      'Requests for money or financial assistance',
                      'Profiles with limited or suspicious photos',
                      'Immediate requests to move off the platform',
                      'Overly aggressive or inappropriate messages',
                    ],
                    icon: Icons.warning,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Meeting in Person', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildSafetyCard(
                    title: 'First Meeting Guidelines',
                    items: [
                      'Meet in public places during daytime',
                      'Inform a friend or family member about your plans',
                      'Arrange your own transportation',
                      'Keep your phone charged and accessible',
                    ],
                    icon: Icons.people,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: itemSpacing),
                  _buildSafetyCard(
                    title: 'Trust Your Instincts',
                    items: [
                      'If something feels off, leave immediately',
                      'Don\'t feel obligated to stay if uncomfortable',
                      'Watch your drink and never leave it unattended',
                      'Set boundaries and communicate them clearly',
                    ],
                    icon: Icons.psychology,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Event Safety', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildSafetyCard(
                    title: 'Before the Event',
                    items: [
                      'Research the event location and venue',
                      'Plan your route and transportation',
                      'Share event details with someone you trust',
                      'Bring emergency contact information',
                    ],
                    icon: Icons.event,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: itemSpacing),
                  _buildSafetyCard(
                    title: 'During the Event',
                    items: [
                      'Stay in well-lit, populated areas',
                      'Don\'t leave with someone you just met',
                      'Report any inappropriate behavior to organizers',
                      'Check in with your emergency contact',
                    ],
                    icon: Icons.event_available,
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Emergency Contacts', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildEmergencyContacts(
                    colors, 
                    primaryColor, 
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
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
      padding: EdgeInsets.only(top: verticalPadding, bottom: 8.0),
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
              Icons.security,
              size: iconSize,
              color: primaryColor,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'Safety First',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: itemSpacing),
            Text(
              'Your safety is our top priority. Follow these essential guidelines to ensure a safe and enjoyable dating experience on SettingWala.',
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
    required double itemSpacing,
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

  Widget _buildSafetyCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double cardPadding,
    required double titleFontSize,
    required double bodyFontSize,
    required double itemSpacing,
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
                  size: 24.0,
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
            ...items.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: bodyFontSize, color: primaryColor)),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double titleFontSize,
    required double bodyFontSize,
    required double itemSpacing,
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
            Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            _buildContactItem('Emergency Services', 'Call 112', Icons.call, colors, primaryColor),
            _buildContactItem('Police', 'Call 100', Icons.local_police, colors, primaryColor),
            _buildContactItem('Ambulance', 'Call 108', Icons.local_hospital, colors, primaryColor),
            _buildContactItem('Women\'s Helpline', 'Call 1091', Icons.woman, colors, primaryColor),
            SizedBox(height: itemSpacing),
            Text(
              '24/7 Support',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            _buildContactItem('SettingWala Support', 'Contact via app', Icons.headset_mic, colors, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String name, String number, IconData icon, 
      AppColorSet colors, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.0, color: colors.textSecondary),
        ],
      ),
    );
  }
}
