

import 'package:flutter/material.dart';
import 'package:settingwala/screens/main_navigation_screen.dart';
import 'google.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';
import 'widgets/themed_logo.dart';
import 'providers/chat_icon_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GoogleAuthService _authService = GoogleAuthService();
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && mounted) {
        // Refresh chat icon visibility after successful login
        ChatIconProvider.maybeOf(context)?.refresh();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavigationScreen()),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Sign-In cancelled or failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final logoSize = isSmallScreen ? 90.0 : (isTablet ? 150.0 : 120.0);
    final heartIconSize = isSmallScreen ? 45.0 : (isTablet ? 75.0 : 60.0);
    final heartInnerSize = isSmallScreen ? 22.0 : (isTablet ? 38.0 : 30.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isTablet ? 34.0 : 28.0);
    final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final buttonHeight = isSmallScreen ? 48.0 : (isTablet ? 64.0 : 56.0);
    final buttonFontSize = isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0);
    final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isSmallScreen ? 24.0 : (isTablet ? 60.0 : 40.0);
    final sectionSpacing = isSmallScreen ? 30.0 : (isTablet ? 60.0 : 50.0);
    final cardPadding = isSmallScreen ? 14.0 : (isTablet ? 28.0 : 20.0);
    final featureIconSize = isSmallScreen ? 40.0 : (isTablet ? 60.0 : 50.0);
    final featureInnerIconSize = isSmallScreen ? 20.0 : (isTablet ? 30.0 : 24.0);
    final featureLabelSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final sectionTitleSize = isSmallScreen ? 16.0 : (isTablet ? 22.0 : 18.0);
    final footerFontSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);

    if (isLandscape && !isTablet) {
      return _buildLandscapeLayout(
        colors, primaryColor, isDark, logoSize, heartIconSize, heartInnerSize,
        titleFontSize, subtitleFontSize, buttonHeight, buttonFontSize,
        horizontalPadding, cardPadding, featureIconSize, featureInnerIconSize,
        featureLabelSize, sectionTitleSize, footerFontSize,
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Center(
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ThemedLogo(),
                        ),
                      ),
                    ),
                    SizedBox(height: sectionSpacing * 0.8),

                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Container(
                        width: heartIconSize,
                        height: heartIconSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.card,
                          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: primaryColor,
                          size: heartInnerSize,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
                              child: Text(
                                'Sign in to continue your journey to finding meaningful connections',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sectionSpacing),

                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: AppColors.error, fontSize: subtitleFontSize),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                            icon: _isSigningIn
                                ? SizedBox(
                              width: isSmallScreen ? 18 : 20,
                              height: isSmallScreen ? 18 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? AppColors.black : AppColors.white,
                                ),
                              ),
                            )
                                : Icon(
                              Icons.account_circle,
                              color: isDark ? AppColors.black : AppColors.white,
                              size: isSmallScreen ? 22 : (isTablet ? 28 : 24),
                            ),
                            label: Text(
                              _isSigningIn ? 'Signing In...' : 'Continue with Google',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDark ? AppColors.black : AppColors.white,
                              elevation: 2,
                              shadowColor: primaryColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: primaryColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 18 : 24),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Quick & Secure Access',
                                style: TextStyle(
                                  fontSize: sectionTitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureItem(Icons.security, 'Secure', colors, primaryColor, featureIconSize, featureInnerIconSize, featureLabelSize),
                                  _buildFeatureItem(Icons.verified_user, 'Verified', colors, primaryColor, featureIconSize, featureInnerIconSize, featureLabelSize),
                                  _buildFeatureItem(Icons.shield, 'Trusted', colors, primaryColor, featureIconSize, featureInnerIconSize, featureLabelSize),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
                          child: Text(
                            'Join thousands of users who have found meaningful connections through our secure platform',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: footerFontSize,
                              fontStyle: FontStyle.italic,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
      AppColorSet colors, Color primaryColor, bool isDark, double logoSize,
      double heartIconSize, double heartInnerSize, double titleFontSize,
      double subtitleFontSize, double buttonHeight, double buttonFontSize,
      double horizontalPadding, double cardPadding, double featureIconSize,
      double featureInnerIconSize, double featureLabelSize, double sectionTitleSize,
      double footerFontSize,
      ) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: logoSize * 0.8,
                      height: logoSize * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ThemedLogo(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: heartIconSize * 0.7,
                      height: heartIconSize * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.card,
                        border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: primaryColor,
                        size: heartInnerSize * 0.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: titleFontSize * 0.85,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your journey',
                              style: TextStyle(
                                fontSize: subtitleFontSize * 0.9,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),

                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          height: buttonHeight * 0.85,
                          child: ElevatedButton.icon(
                            onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                            icon: _isSigningIn
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Icon(
                              Icons.account_circle,
                              color: isDark ? AppColors.black : AppColors.white,
                            ),
                            label: Text(
                              _isSigningIn ? 'Signing In...' : 'Continue with Google',
                              style: TextStyle(
                                fontSize: buttonFontSize * 0.85,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDark ? AppColors.black : AppColors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem(Icons.security, 'Secure', colors, primaryColor, featureIconSize * 0.8, featureInnerIconSize * 0.8, featureLabelSize * 0.9),
                            _buildFeatureItem(Icons.verified_user, 'Verified', colors, primaryColor, featureIconSize * 0.8, featureInnerIconSize * 0.8, featureLabelSize * 0.9),
                            _buildFeatureItem(Icons.shield, 'Trusted', colors, primaryColor, featureIconSize * 0.8, featureInnerIconSize * 0.8, featureLabelSize * 0.9),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, AppColorSet colors, Color primaryColor, double containerSize, double iconSize, double labelSize) {
    return Column(
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: colors.card,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
