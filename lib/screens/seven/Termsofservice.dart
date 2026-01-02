import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class TermsofServiceScreen extends StatefulWidget {
  const TermsofServiceScreen({super.key});

  @override
  State<TermsofServiceScreen> createState() => _TermsofServiceScreenState();
}

class _TermsofServiceScreenState extends State<TermsofServiceScreen> with TickerProviderStateMixin {
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
    
    final maxContentWidth = isDesktop ? 900.0 : double.infinity;
    
    return BaseScreen(
      title: 'Terms of Service',
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
                  _buildSectionHeader(
                    '1. Acceptance of Terms', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'By accessing or using SettingWala ("the Service"), you agree to be bound by these Terms of Service ("Terms"). If you disagree with any part of these terms, you may not access the Service. These Terms apply to all visitors, users, and others who access or use the Service.\n\nBy using our Service, you represent that you are at least 18 years old and have the legal capacity to enter into these Terms.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '2. Description of Service', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'SettingWala is a friendship platform that connects people through verified profiles and local events. Our Service includes:\n\n• Profile creation and management\n• Event discovery and participation\n• Communication tools between verified users\n• Payment processing for event participation\n• Safety and verification features',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '3. User Responsibilities', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'As a user of SettingWala, you agree to:\n\n• Provide accurate and complete information in your profile\n• Maintain the security of your account credentials\n• Use the Service in a manner that is lawful and respectful to others\n• Not engage in any fraudulent, misleading, or inappropriate behavior\n• Respect the privacy and rights of other users\n• Report any suspicious or inappropriate activity\n• Comply with all applicable laws and regulations',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '4. Content Guidelines', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'You agree not to post, transmit, or share any content that:\n\n• Is illegal, offensive, or discriminatory\n• Violates the rights of others\n• Contains nudity, sexual content, or explicit material\n• Promotes violence or hate speech\n• Is false or misleading\n• Infringes on intellectual property rights\n\nWe reserve the right to remove any content that violates these guidelines.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '5. Privacy and Data', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'Your use of SettingWala is also governed by our Privacy Policy, which explains how we collect, use, and protect your personal information. By using the Service, you consent to the collection and use of your information as described in the Privacy Policy.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '6. Account Termination', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We may terminate or suspend your account immediately, without prior notice, for any reason whatsoever, including without limitation if you breach these Terms. Upon termination, your right to use the Service will cease immediately.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '7. Limitation of Liability', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'In no event shall SettingWala, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '8. Changes to Terms', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page. Your continued use of the Service after any changes constitute acceptance of those changes.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '9. Governing Law', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    '10. Contact Us', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'If you have any questions about these Terms of Service, please contact us through our support system within the app or by visiting our Contact Us page.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
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

  Widget _buildPolicyContent(
    String content,
    AppColorSet colors,
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double fontSize,
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
        child: Text(
          content,
          style: TextStyle(
            fontSize: fontSize,
            color: colors.textSecondary,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
