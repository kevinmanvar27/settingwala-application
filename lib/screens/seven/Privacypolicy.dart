import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with TickerProviderStateMixin {
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
      title: 'Privacy Policy',
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
                    'Introduction', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'SettingWala ("we," "our," or "us") is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our friendship platform and services.\n\nBy using SettingWala, you consent to the data practices described in this policy. If you do not agree with the practices described in this policy, please do not use our services.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Information We Collect', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildSubSection(
                    'Information You Provide',
                    'Account information (name, email address, date of birth, gender)\nProfile information (photos, interests, preferences)\nPayment information (processed securely through Razorpay)\nCommunications with other users and our support team\nEvent participation and feedback',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  _buildSubSection(
                    'Information Collected Automatically',
                    'Device information (IP address, browser type, operating system)\nUsage data (pages visited, time spent, features used)\nLocation data (with your permission, for event recommendations)\nCookies and similar tracking technologies',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  _buildSubSection(
                    'Information from Third Parties',
                    'Google OAuth information (name, email, profile picture)\nSocial media information (if you choose to connect accounts)\nPayment processor information (transaction details)',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    titleFontSize: cardTitleFontSize,
                    bodyFontSize: cardBodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'How We Use Your Information', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We use your information to:\n\n• Provide and maintain our friendship services\n• Create and manage your account\n• Facilitate connections with other users\n• Organize and manage events\n• Process payments and transactions\n• Send notifications and updates\n• Improve our services and user experience\n• Ensure safety and prevent fraud\n• Comply with legal obligations\n• Respond to customer support inquiries',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'How We Share Your Information', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We may share your information in the following circumstances:\n\nWith Other Users:\n• Profile information visible to other verified users\n• Event participation status\n• Messages and communications within the platform\n\nWith Service Providers:\n• Payment processors (Razorpay) for transaction processing\n• Cloud storage providers for data hosting\n• Analytics providers for service improvement\n• Customer support tools\n\nLegal Requirements:\n• When required by law or legal process\n• To protect our rights and safety\n• To prevent fraud or illegal activities\n• In connection with business transfers',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Data Security', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These measures include:\n\n• Encryption of data in transit and at rest\n• Secure authentication through Google OAuth\n• Regular security assessments and updates\n• Access controls and employee training\n• Secure payment processing through certified providers',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Your Rights and Choices', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'You have the following rights regarding your personal information:\n\n• Access: Request a copy of your personal data\n• Correction: Update or correct inaccurate information\n• Deletion: Request deletion of your account and data\n• Portability: Receive your data in a portable format\n• Restriction: Limit how we process your data\n• Objection: Object to certain types of processing\n• Withdraw Consent: Withdraw consent for data processing\n\nTo exercise these rights, please contact us through our support system.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Data Retention', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy. Specifically:\n\n• Account information: Until you delete your account\n• Profile data: Until you remove it or delete your account\n• Payment records: As required by law (typically 7 years)\n• Communications: Until you delete your account\n• Usage data: Anonymized after 2 years',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Cookies and Tracking', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We use cookies and similar technologies to enhance your experience, analyze usage, and provide personalized content. You can control cookie settings through your browser preferences.\n\nTypes of cookies we use include essential cookies (required for functionality), analytics cookies (to understand usage), and preference cookies (to remember your settings).',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Children\'s Privacy', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'SettingWala is not intended for users under 18 years of age. We do not knowingly collect personal information from children under 18. If we become aware that we have collected personal information from a child under 18, we will take steps to delete such information promptly.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Changes to This Policy', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy on this page and updating the "Last updated" date. We encourage you to review this policy periodically for any changes.',
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

  Widget _buildSubSection(
    String title,
    String content,
    AppColorSet colors,
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double titleFontSize,
    required double bodyFontSize,
    required double itemSpacing,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(cardPadding * 0.75),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(cardRadius)),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: itemSpacing),
      ],
    );
  }
}
