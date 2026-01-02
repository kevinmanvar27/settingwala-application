import 'package:flutter/material.dart';
import '../../widgets/base_screen.dart';
import '../../theme/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() { _animationController.dispose(); super.dispose(); }

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
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final headerTitleFontSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final headerSubtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final cardTitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final cardBodyFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final headerIconSize = isDesktop ? 64.0 : isTablet ? 56.0 : isSmallScreen ? 40.0 : 48.0;
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;

    return BaseScreen(
      title: 'Contact Us',
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(headerIconSize * 0.3),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.support_agent, size: headerIconSize, color: primaryColor),
                        ),
                        SizedBox(height: itemSpacing),
                        Text('Get in Touch', style: TextStyle(fontSize: headerTitleFontSize, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                        SizedBox(height: itemSpacing * 0.5),
                        Text('We are here to help you', style: TextStyle(fontSize: headerSubtitleFontSize, color: colors.textSecondary), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildContactForm(colors, primaryColor, cardRadius, cardTitleFontSize, cardBodyFontSize, itemSpacing),
                  
                  SizedBox(height: sectionSpacing),
                  
                  _buildEmergencyContacts(colors, primaryColor, cardRadius, cardTitleFontSize, cardBodyFontSize, itemSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm(AppColorSet colors, Color primaryColor, double cardRadius, 
      double titleFontSize, double bodyFontSize, double itemSpacing) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    final List<String> subjects = ['General Inquiry', 'Technical Support', 'Account Issue', 'Feedback', 'Report Problem'];
    String? selectedSubject;

    return Card(
      elevation: 2,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a Message',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing),
            Text(
              'Fill out the form below and we\'ll get back to you within 24 hours',
              style: TextStyle(
                fontSize: bodyFontSize,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: itemSpacing * 1.5),
            
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: itemSpacing),
            
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: itemSpacing),
            
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: itemSpacing),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: colors.textSecondary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: DropdownButton<String>(
                value: selectedSubject,
                hint: Text('Select a subject'),
                isExpanded: true,
                underline: Container(),
                items: subjects.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubject = newValue;
                  });
                },
              ),
            ),
            SizedBox(height: itemSpacing),
            
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${messageController.text.length}/2000 characters',
                  style: TextStyle(
                    fontSize: bodyFontSize * 0.8,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: itemSpacing),
            
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (bool? value) {},
                  activeColor: primaryColor,
                ),
                Expanded(
                  child: Text(
                    'I agree to the Privacy Policy and consent to the processing of my personal data.',
                    style: TextStyle(
                      fontSize: bodyFontSize * 0.9,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: itemSpacing),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message sent successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts(AppColorSet colors, Color primaryColor, double cardRadius, 
      double titleFontSize, double bodyFontSize, double itemSpacing) {
    return Card(
      elevation: 2,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: bodyFontSize * 1.1,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            _buildContactItem('Police', '100', Icons.call, colors, primaryColor),
            _buildContactItem('Ambulance', '108', Icons.local_hospital, colors, primaryColor),
            _buildContactItem('Women\'s Helpline', '1091', Icons.woman, colors, primaryColor),
            SizedBox(height: itemSpacing),
            Text(
              '24/7 Support',
              style: TextStyle(
                fontSize: bodyFontSize * 1.1,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: itemSpacing * 0.5),
            _buildContactItem('Customer Support', 'Contact via app', Icons.headset_mic, colors, primaryColor),
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
