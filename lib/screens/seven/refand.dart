import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> with TickerProviderStateMixin {
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
      title: 'Refund Policy',
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
                    'Refund Policy', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'Thank you for using SettingWala. We value your trust and satisfaction. This Refund Policy outlines the conditions under which refunds may be available for payments made through our platform.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Event Payment Refunds', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'For event participation fees:\n\n• Refunds are available if you cancel your event registration at least 48 hours before the event starts\n• A cancellation fee of 10% may apply to cover processing costs\n• No refunds will be issued for cancellations made less than 48 hours before the event\n• Refunds will be processed to the original payment method within 5-7 business days\n• Events cancelled by SettingWala will receive a full refund',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Subscription Refunds', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'Currently, SettingWala operates on a pay-per-event model rather than subscriptions. However, if subscription services are introduced in the future:\n\n• Refunds may be available during a trial period\n• Subscription cancellations will be processed according to the terms at the time of purchase\n• No refunds will be provided for partial months of subscription use',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Refund Process', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'To request a refund:\n\n• Contact our support team through the app\n• Provide your order details and reason for refund request\n• Include any relevant information to support your request\n• Our team will review your request within 24-48 hours\n• You will receive a notification about the status of your refund request\n• Approved refunds will be processed to your original payment method',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Non-Refundable Items', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'The following items and services are non-refundable:\n\n• Event participation fees for events that have already occurred\n• Payments made for premium features that have been used\n• Donations or voluntary contributions\n• Any services provided before a refund request\n• Charges related to fraudulent or unauthorized transactions',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Refund Timeframes', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'Refund processing timeframes:\n\n• Credit/Debit Cards: 5-10 business days\n• Bank Transfers: 3-7 business days\n• UPI Payments: 1-3 business days\n• Net Banking: 5-7 business days\n\nPlease note that the actual time may vary depending on your financial institution.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Disputed Charges', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'If you believe there has been a mistaken charge to your account:\n\n• Contact our support team immediately\n• Provide transaction details and explanation\n• We will investigate the matter within 48 hours\n• If a mistake is confirmed, we will process a refund promptly\n• In cases of unauthorized charges, we recommend also contacting your bank',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Changes to Refund Policy', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'We reserve the right to modify this Refund Policy at any time. Changes will be effective immediately upon posting to the app. Your continued use of SettingWala after changes to this policy constitutes acceptance of those changes. We recommend reviewing this policy periodically.',
                    colors,
                    primaryColor,
                    cardRadius: cardRadius,
                    cardPadding: horizontalPadding,
                    fontSize: bodyFontSize,
                    itemSpacing: itemSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Contact Us', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                    verticalPadding: 0,
                  ),
                  _buildPolicyContent(
                    'For questions about our Refund Policy or to submit a refund request, please contact our support team:\n\n• Through the Contact Us section in the app\n• Via email at support@settingwala.com\n• During business hours: Monday to Friday, 9 AM to 6 PM IST',
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
