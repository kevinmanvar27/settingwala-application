import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import 'home_page.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _inAppNotificationsEnabled = true;
  
  final Map<String, bool> _pushNotifications = {
    'General': true,
    'Payment': true,
    'Matches': true,
    'Activity Partner Exchanges': true,
    'Booking Appointment': true,
    'Meeting Reminder': true,
    'Subscriptions & Account': true,
  };
  
  final Map<String, bool> _emailNotifications = {
    'General': true,
    'Payment': true,
    'Matches': true,
    'Activity Partner Exchanges': true,
    'Booking Appointment': true,
    'Meeting Reminder': true,
    'Subscriptions & Account': true,
  };
  
  final Map<String, bool> _inAppNotifications = {
    'General': true,
    'Payment': true,
    'Matches': true,
    'Activity Partner Exchanges': true,
    'Booking Appointment': true,
    'Meeting Reminder': true,
    'Subscriptions & Account': true,
  };
  
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);
  String _timeZone = 'Asia/Kolkata (GMT+5:30)';
  bool _quietHoursEnabled = true;

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
    final itemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final cardRadius = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final sectionHeaderFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final categoryTitleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final itemFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    final masterIconSize = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 22.0 : 28.0;
    final smallIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    
    final buttonHeight = isDesktop ? 60.0 : isTablet ? 56.0 : isSmallScreen ? 44.0 : 50.0;
    final buttonFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Notifications',
      showBackButton: true,
      body: Center(
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
                _buildMasterToggle(
                  colors, 
                  primaryColor,
                  cardRadius: cardRadius,
                  titleFontSize: titleFontSize,
                  subtitleFontSize: subtitleFontSize,
                  iconSize: masterIconSize,
                  horizontalPadding: horizontalPadding,
                ),
                SizedBox(height: sectionSpacing),
                
                if (_notificationsEnabled) ...[
                  _buildCategoryToggle(
                    title: 'Push Notifications',
                    isEnabled: _pushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                    },
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    titleFontSize: categoryTitleFontSize,
                    horizontalPadding: horizontalPadding,
                  ),
                  SizedBox(height: itemSpacing),
                  if (_pushNotificationsEnabled)
                    _buildNotificationSection(
                      _pushNotifications, 
                      colors, 
                      primaryColor,
                      cardRadius: cardRadius,
                      itemFontSize: itemFontSize,
                      horizontalPadding: horizontalPadding,
                    ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildCategoryToggle(
                    title: 'Email Notifications',
                    isEnabled: _emailNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _emailNotificationsEnabled = value;
                      });
                    },
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    titleFontSize: categoryTitleFontSize,
                    horizontalPadding: horizontalPadding,
                  ),
                  SizedBox(height: itemSpacing),
                  if (_emailNotificationsEnabled)
                    _buildNotificationSection(
                      _emailNotifications, 
                      colors, 
                      primaryColor,
                      cardRadius: cardRadius,
                      itemFontSize: itemFontSize,
                      horizontalPadding: horizontalPadding,
                    ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildCategoryToggle(
                    title: 'In-App Notifications',
                    isEnabled: _inAppNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _inAppNotificationsEnabled = value;
                      });
                    },
                    colors: colors,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    titleFontSize: categoryTitleFontSize,
                    horizontalPadding: horizontalPadding,
                  ),
                  SizedBox(height: itemSpacing),
                  if (_inAppNotificationsEnabled)
                    _buildNotificationSection(
                      _inAppNotifications, 
                      colors, 
                      primaryColor,
                      cardRadius: cardRadius,
                      itemFontSize: itemFontSize,
                      horizontalPadding: horizontalPadding,
                    ),
                  SizedBox(height: sectionSpacing),
                  
                  _buildSectionHeader(
                    'Quiet Hours', 
                    colors,
                    fontSize: sectionHeaderFontSize,
                  ),
                  SizedBox(height: itemSpacing),
                  _buildQuietHoursSection(
                    colors, 
                    primaryColor,
                    cardRadius: cardRadius,
                    titleFontSize: titleFontSize,
                    labelFontSize: subtitleFontSize,
                    iconSize: smallIconSize,
                    horizontalPadding: horizontalPadding,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: sectionSpacing + 8),
                ],
                
                _buildSaveButton(
                  colors, 
                  primaryColor, 
                  isDark,
                  buttonHeight: buttonHeight,
                  buttonFontSize: buttonFontSize,
                  cardRadius: cardRadius,
                ),
                SizedBox(height: sectionSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterToggle(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double titleFontSize,
    required double subtitleFontSize,
    required double iconSize,
    required double horizontalPadding,
  }) {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            color: primaryColor,
            size: iconSize,
          ),
          SizedBox(width: horizontalPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Turn on/off all notifications',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryToggle({
    required String title, 
    required bool isEnabled,
    required Function(bool) onChanged,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double titleFontSize,
    required double horizontalPadding,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: horizontalPadding * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, 
    AppColorSet colors, {
    required double fontSize,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildNotificationSection(
    Map<String, bool> notificationSettings, 
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double itemFontSize,
    required double horizontalPadding,
  }) {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
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
        children: notificationSettings.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: horizontalPadding * 0.5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: itemFontSize,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: entry.value,
                  onChanged: (value) {
                    setState(() {
                      notificationSettings[entry.key] = value;
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuietHoursSection(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double titleFontSize,
    required double labelFontSize,
    required double iconSize,
    required double horizontalPadding,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Enable Quiet Hours',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: _quietHoursEnabled,
                onChanged: (value) {
                  setState(() {
                    _quietHoursEnabled = value;
                  });
                },
              ),
            ],
          ),
          if (_quietHoursEnabled) ...[
            SizedBox(height: horizontalPadding),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () => _selectTime(context, true),
                    colors: colors,
                    primaryColor: primaryColor,
                    labelFontSize: labelFontSize,
                    iconSize: iconSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: horizontalPadding),
                Expanded(
                  child: _buildTimeSelector(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () => _selectTime(context, false),
                    colors: colors,
                    primaryColor: primaryColor,
                    labelFontSize: labelFontSize,
                    iconSize: iconSize,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),
            SizedBox(height: horizontalPadding),
            _buildDropdown(
              label: 'Time Zone',
              value: _timeZone,
              items: const [
                'Asia/Kolkata (GMT+5:30)',
                'America/New_York (GMT-5:00)',
                'Europe/London (GMT+0:00)',
                'Australia/Sydney (GMT+10:00)',
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _timeZone = value;
                  });
                }
              },
              colors: colors,
              primaryColor: primaryColor,
              labelFontSize: labelFontSize,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: horizontalPadding),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startTime = const TimeOfDay(hour: 22, minute: 0);
                    _endTime = const TimeOfDay(hour: 7, minute: 0);
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: primaryColor,
                  size: iconSize,
                ),
                label: Text(
                  'Reset to Default',
                  style: TextStyle(
                    fontSize: labelFontSize + 2,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required AppColorSet colors,
    required Color primaryColor,
    required double labelFontSize,
    required double iconSize,
    required bool isSmallScreen,
  }) {
    final timeSelectorRadius = isSmallScreen ? 16.0 : 20.0;
    final timeSelectorPaddingH = isSmallScreen ? 12.0 : 16.0;
    final timeSelectorPaddingV = isSmallScreen ? 10.0 : 12.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6.0 : 8.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: timeSelectorPaddingH, 
              vertical: timeSelectorPaddingV,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(timeSelectorRadius),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: iconSize,
                  color: primaryColor,
                ),
                SizedBox(width: isSmallScreen ? 6.0 : 8.0),
                Text(
                  _formatTimeOfDay(time),
                  style: TextStyle(
                    fontSize: labelFontSize + 2,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required AppColorSet colors,
    required Color primaryColor,
    required double labelFontSize,
    required bool isSmallScreen,
  }) {
    final dropdownRadius = isSmallScreen ? 16.0 : 20.0;
    final dropdownPaddingH = isSmallScreen ? 12.0 : 16.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6.0 : 8.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: dropdownPaddingH),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(dropdownRadius),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: colors.card,
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            style: TextStyle(
              fontSize: labelFontSize + 2,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontSize: labelFontSize + 2),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final TimeOfDay initialTime = isStartTime ? _startTime : _endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: AppColors.black,
                    onSurface: colors.textPrimary,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: AppColors.white,
                    onSurface: colors.textPrimary,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildSaveButton(
    AppColorSet colors, 
    Color primaryColor, 
    bool isDark, {
    required double buttonHeight,
    required double buttonFontSize,
    required double cardRadius,
  }) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notification settings saved!', 
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: buttonFontSize - 2,
                ),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
            ),
          );
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: buttonFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
