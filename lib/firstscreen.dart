import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';

class Firstscreen extends StatefulWidget {
  const Firstscreen({super.key});

  @override
  State<Firstscreen> createState() => _FirstscreenState();
}

class _FirstscreenState extends State<Firstscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Sign Up with Google',
      'description': 'Getting started is quick and secure. Simply sign up using your Google account - no complicated forms or lengthy registration process.\n\n• Secure Google OAuth authentication\n• Verified email address',
      'icon': Icons.login_rounded,
    },
    {
      'title': 'Complete Your Profile',
      'description': 'Create a compelling profile that showcases who you are. A complete profile is required to join events and increases your chances of finding the right match.\n\n• Upload your best profile picture\n• Add your interests and hobbies\n• Share your basic information',
      'icon': Icons.person_rounded,
    },
    {
      'title': 'Join Local Events',
      'description': 'Discover and join carefully curated local events where you can meet like-minded people in a comfortable, safe environment.\n\n• Browse upcoming events in your area\n• Pay per event (no subscriptions)\n• Meet verified members only\n• Local Events & Meetups\n• Join curated events in your area to meet new people',
      'icon': Icons.event_rounded,
    },
    {
      'title': 'Build Great Friendships',
      'description': 'Connect with people who share your interests and values. Build meaningful friendships that can last a lifetime.\n\n• Meet in safe, public environments\n• Connect based on shared interests\n• Build lasting relationships',
      'icon': Icons.people_alt_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive
    Responsive.init(context);
    
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Responsive sizes
    final titleFontSize = isSmallScreen ? 20.0 : (isTablet ? 28.0 : 24.0);
    final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final horizontalPadding = isSmallScreen ? 12.0 : (isTablet ? 32.0 : 20.0);
    final verticalPadding = isSmallScreen ? 16.0 : (isTablet ? 40.0 : 30.0);
    final iconContainerSize = isSmallScreen ? 60.0 : (isTablet ? 100.0 : 80.0);
    final iconSize = isSmallScreen ? 30.0 : (isTablet ? 50.0 : 40.0);
    final stepNumberSize = isSmallScreen ? 28.0 : (isTablet ? 44.0 : 36.0);
    final stepTitleFontSize = isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0);
    final descriptionFontSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final buttonHeight = isSmallScreen ? 44.0 : (isTablet ? 56.0 : 50.0);
    final buttonFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final dotSize = isSmallScreen ? 6.0 : 8.0;
    final activeDotWidth = isSmallScreen ? 18.0 : 24.0;
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: isLandscape && !isTablet
            ? _buildLandscapeLayout(
                colors, primaryColor, horizontalPadding, titleFontSize, 
                subtitleFontSize, iconContainerSize, iconSize, stepNumberSize,
                stepTitleFontSize, descriptionFontSize, buttonHeight, 
                buttonFontSize, dotSize, activeDotWidth, isDark)
            : _buildPortraitLayout(
                colors, primaryColor, horizontalPadding, verticalPadding,
                titleFontSize, subtitleFontSize, iconContainerSize, iconSize,
                stepNumberSize, stepTitleFontSize, descriptionFontSize,
                buttonHeight, buttonFontSize, dotSize, activeDotWidth, isDark),
      ),
    );
  }

  Widget _buildPortraitLayout(
    AppColorSet colors, Color primaryColor, double horizontalPadding,
    double verticalPadding, double titleFontSize, double subtitleFontSize,
    double iconContainerSize, double iconSize, double stepNumberSize,
    double stepTitleFontSize, double descriptionFontSize, double buttonHeight,
    double buttonFontSize, double dotSize, double activeDotWidth, bool isDark,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chal Bhai tera Setting karva dete hain!',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.isMobile ? 8 : 10),
              Text(
                _currentPage == 0
                    ? 'Bas Kar Pagle, Rulayega Kya? Akele akele ghoom rahe ho, koi interesting person nahi mil raha? "Koi toh mile yaar" wala feeling aa raha hai na?'
                    : _currentPage == 1
                        ? 'SettingWala Mein Aa Jao! Yahan sab cool log hain! Verified profiles dekho aur "Ye toh meri type ka hai" wala feeling lo. Guaranteed maza!'
                        : 'Setting Ho Gayi! 🔥 "Ye bhi theek hai" se "Ye toh mast hai" tak ka safar! Real mein mil ke activities karo, setting complete!',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  children: [
                    Container(
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _onboardingData[index]['icon'],
                        size: iconSize,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: Responsive.isMobile ? 16 : 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: stepNumberSize,
                                height: stepNumberSize,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: stepNumberSize * 0.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Responsive.isMobile ? 8 : 12),
                              Expanded(
                                child: Text(
                                  _onboardingData[index]['title'],
                                  style: TextStyle(
                                    fontSize: stepTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.isMobile ? 12 : 16),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shadowColor: primaryColor.withOpacity(0.2),
                              color: colors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(Responsive.isMobile ? 12.0 : 16.0),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _onboardingData[index]['description'],
                                    style: TextStyle(
                                      fontSize: descriptionFontSize,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: dotSize,
                    width: _currentPage == index ? activeDotWidth : dotSize,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? primaryColor
                          : colors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Responsive.isMobile ? 16 : 20),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Chalo Sharu Karte He',
                    style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    AppColorSet colors, Color primaryColor, double horizontalPadding,
    double titleFontSize, double subtitleFontSize, double iconContainerSize,
    double iconSize, double stepNumberSize, double stepTitleFontSize,
    double descriptionFontSize, double buttonHeight, double buttonFontSize,
    double dotSize, double activeDotWidth, bool isDark,
  ) {
    return Row(
      children: [
        // Left side - Title and description
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chal Bhai tera Setting karva dete hain!',
                  style: TextStyle(
                    fontSize: titleFontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentPage == 0
                      ? 'Bas Kar Pagle, Rulayega Kya?'
                      : _currentPage == 1
                          ? 'SettingWala Mein Aa Jao!'
                          : 'Setting Ho Gayi! 🔥',
                  style: TextStyle(
                    fontSize: subtitleFontSize * 0.9,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Dots and button
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: dotSize * 0.8,
                      width: _currentPage == index ? activeDotWidth * 0.8 : dotSize * 0.8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? primaryColor : colors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: primaryColor, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight * 0.85,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? AppColors.black : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Chalo Sharu Karte He',
                      style: TextStyle(fontSize: buttonFontSize * 0.9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - PageView
        Expanded(
          flex: 3,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(horizontalPadding * 0.8),
                child: Row(
                  children: [
                    Container(
                      width: iconContainerSize * 0.8,
                      height: iconContainerSize * 0.8,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _onboardingData[index]['icon'],
                        size: iconSize * 0.8,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: stepNumberSize * 0.8,
                                height: stepNumberSize * 0.8,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: stepNumberSize * 0.4,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _onboardingData[index]['title'],
                                  style: TextStyle(
                                    fontSize: stepTitleFontSize * 0.85,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shadowColor: primaryColor.withOpacity(0.2),
                              color: colors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _onboardingData[index]['description'],
                                    style: TextStyle(
                                      fontSize: descriptionFontSize * 0.9,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}