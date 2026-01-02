import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isLoading = true;

  bool _isPublicProfile = false;
  bool _showContactNumber = false;
  bool _showDateOfBirth = true;
  bool _hideDobYear = false;
  bool _showInterestsHobbies = true;
  bool _showExpectations = true;
  bool _showGalleryImages = true;
  bool _isTimeSpendingEnabled = false;
  bool _interestedInSugarPartner = false;
  bool _hideSugarPartnerNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = await ProfileService.getProfile();

      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        setState(() {
          _isPublicProfile = user.isPublicProfile ?? prefs.getBool('is_public_profile') ?? false;
          _showContactNumber = user.showContactNumber ?? prefs.getBool('show_contact_number') ?? false;
          _showDateOfBirth = user.showDateOfBirth ?? prefs.getBool('show_date_of_birth') ?? true;
          _hideDobYear = user.hideDobYear ?? prefs.getBool('hide_dob_year') ?? false;
          _showInterestsHobbies = user.showInterestsHobbies ?? prefs.getBool('show_interests_hobbies') ?? true;
          _showExpectations = user.showExpectations ?? prefs.getBool('show_expectations') ?? true;
          _showGalleryImages = user.showGalleryImages ?? prefs.getBool('show_gallery_images') ?? true;
          _isTimeSpendingEnabled = user.isTimeSpendingEnabled ?? prefs.getBool('is_time_spending_enabled') ?? false;
          _interestedInSugarPartner = user.interestedInSugarPartner ?? prefs.getBool('interested_in_sugar_partner') ?? false;
          _hideSugarPartnerNotifications = user.hideSugarPartnerNotifications ?? prefs.getBool('hide_sugar_partner_notifications') ?? false;
        });
      } else {
        setState(() {
          _isPublicProfile = prefs.getBool('is_public_profile') ?? false;
          _showContactNumber = prefs.getBool('show_contact_number') ?? false;
          _showDateOfBirth = prefs.getBool('show_date_of_birth') ?? true;
          _hideDobYear = prefs.getBool('hide_dob_year') ?? false;
          _showInterestsHobbies = prefs.getBool('show_interests_hobbies') ?? true;
          _showExpectations = prefs.getBool('show_expectations') ?? true;
          _showGalleryImages = prefs.getBool('show_gallery_images') ?? true;
          _isTimeSpendingEnabled = prefs.getBool('is_time_spending_enabled') ?? false;
          _interestedInSugarPartner = prefs.getBool('interested_in_sugar_partner') ?? false;
          _hideSugarPartnerNotifications = prefs.getBool('hide_sugar_partner_notifications') ?? false;
        });
      }
    } catch (e) {
      
      _showErrorSnackBar('Failed to load settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePrivacySetting({
    bool? isPublicProfile,
    bool? showContactNumber,
    bool? showDateOfBirth,
    bool? hideDobYear,
    bool? showInterestsHobbies,
    bool? showExpectations,
    bool? showGalleryImages,
    bool? isTimeSpendingEnabled,
    bool? interestedInSugarPartner,
    bool? hideSugarPartnerNotifications,
  }) async {
    final oldIsPublicProfile = _isPublicProfile;
    final oldShowContactNumber = _showContactNumber;
    final oldShowDateOfBirth = _showDateOfBirth;
    final oldHideDobYear = _hideDobYear;
    final oldShowInterestsHobbies = _showInterestsHobbies;
    final oldShowExpectations = _showExpectations;
    final oldShowGalleryImages = _showGalleryImages;
    final oldIsTimeSpendingEnabled = _isTimeSpendingEnabled;
    final oldInterestedInSugarPartner = _interestedInSugarPartner;
    final oldHideSugarPartnerNotifications = _hideSugarPartnerNotifications;

    try {
      final result = await ProfileService.updatePrivacySettings(
        isPublicProfile: isPublicProfile,
        showContactNumber: showContactNumber,
        showDateOfBirth: showDateOfBirth,
        hideDobYear: hideDobYear,
        showInterestsHobbies: showInterestsHobbies,
        showExpectations: showExpectations,
        showGalleryImages: showGalleryImages,
        isTimeSpendingEnabled: isTimeSpendingEnabled,
        interestedInSugarPartner: interestedInSugarPartner,
        hideSugarPartnerNotifications: hideSugarPartnerNotifications,
      );

      if (result != null && result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (isPublicProfile != null) await prefs.setBool('is_public_profile', isPublicProfile);
        if (showContactNumber != null) await prefs.setBool('show_contact_number', showContactNumber);
        if (showDateOfBirth != null) await prefs.setBool('show_date_of_birth', showDateOfBirth);
        if (hideDobYear != null) await prefs.setBool('hide_dob_year', hideDobYear);
        if (showInterestsHobbies != null) await prefs.setBool('show_interests_hobbies', showInterestsHobbies);
        if (showExpectations != null) await prefs.setBool('show_expectations', showExpectations);
        if (showGalleryImages != null) await prefs.setBool('show_gallery_images', showGalleryImages);
        if (isTimeSpendingEnabled != null) await prefs.setBool('is_time_spending_enabled', isTimeSpendingEnabled);
        if (interestedInSugarPartner != null) await prefs.setBool('interested_in_sugar_partner', interestedInSugarPartner);
        if (hideSugarPartnerNotifications != null) await prefs.setBool('hide_sugar_partner_notifications', hideSugarPartnerNotifications);

        _showSuccessSnackBar('Setting saved!');
      } else {
        _restoreOldValues(
          oldIsPublicProfile,
          oldShowContactNumber,
          oldShowDateOfBirth,
          oldHideDobYear,
          oldShowInterestsHobbies,
          oldShowExpectations,
          oldShowGalleryImages,
          oldIsTimeSpendingEnabled,
          oldInterestedInSugarPartner,
          oldHideSugarPartnerNotifications,
        );
        _showErrorSnackBar('Failed to update setting');
      }
    } catch (e) {
      
      _restoreOldValues(
        oldIsPublicProfile,
        oldShowContactNumber,
        oldShowDateOfBirth,
        oldHideDobYear,
        oldShowInterestsHobbies,
        oldShowExpectations,
        oldShowGalleryImages,
        oldIsTimeSpendingEnabled,
        oldInterestedInSugarPartner,
        oldHideSugarPartnerNotifications,
      );
      _showErrorSnackBar('Error: $e');
    }
  }

  void _restoreOldValues(
      bool oldIsPublicProfile,
      bool oldShowContactNumber,
      bool oldShowDateOfBirth,
      bool oldHideDobYear,
      bool oldShowInterestsHobbies,
      bool oldShowExpectations,
      bool oldShowGalleryImages,
      bool oldIsTimeSpendingEnabled,
      bool oldInterestedInSugarPartner,
      bool oldHideSugarPartnerNotifications,
      ) {
    if (mounted) {
      setState(() {
        _isPublicProfile = oldIsPublicProfile;
        _showContactNumber = oldShowContactNumber;
        _showDateOfBirth = oldShowDateOfBirth;
        _hideDobYear = oldHideDobYear;
        _showInterestsHobbies = oldShowInterestsHobbies;
        _showExpectations = oldShowExpectations;
        _showGalleryImages = oldShowGalleryImages;
        _isTimeSpendingEnabled = oldIsTimeSpendingEnabled;
        _interestedInSugarPartner = oldInterestedInSugarPartner;
        _hideSugarPartnerNotifications = oldHideSugarPartnerNotifications;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    final cardRadius = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 16.0;

    final titleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final sectionHeaderFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;

    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;

    final maxContentWidth = isDesktop ? 800.0 : double.infinity;

    return BaseScreen(
      title: 'Privacy Settings',
      showBackButton: true,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: primaryColor),
      )
          : RefreshIndicator(
        onRefresh: _loadPrivacySettings,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    subtitleFontSize: subtitleFontSize,
                    iconSize: iconSize,
                  ),

                  SizedBox(height: sectionSpacing),

                  _buildSectionCard(
                    title: 'Profile Visibility',
                    icon: Icons.visibility_outlined,
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    children: [
                      _buildSwitchTile(
                        title: 'Public Profile',
                        subtitle: 'Allow others to view your profile',
                        icon: Icons.public_outlined,
                        value: _isPublicProfile,
                        onChanged: (value) {
                          setState(() => _isPublicProfile = value);
                          _updatePrivacySetting(isPublicProfile: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                    ],
                  ),

                  SizedBox(height: itemSpacing),

                  _buildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone_outlined,
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    children: [
                      _buildSwitchTile(
                        title: 'Show Contact Number',
                        subtitle: 'Display your phone number on profile',
                        icon: Icons.phone_outlined,
                        value: _showContactNumber,
                        onChanged: (value) {
                          setState(() => _showContactNumber = value);
                          _updatePrivacySetting(showContactNumber: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                    ],
                  ),

                  SizedBox(height: itemSpacing),

                  _buildSectionCard(
                    title: 'Date of Birth',
                    icon: Icons.cake_outlined,
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    children: [
                      _buildSwitchTile(
                        title: 'Show Date of Birth',
                        subtitle: 'Display your birthday on profile',
                        icon: Icons.calendar_today_outlined,
                        value: _showDateOfBirth,
                        onChanged: (value) {
                          setState(() => _showDateOfBirth = value);
                          _updatePrivacySetting(showDateOfBirth: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                      Divider(color: colors.divider, height: 1),
                      _buildSwitchTile(
                        title: 'Hide Birth Year',
                        subtitle: 'Show only day and month',
                        icon: Icons.visibility_off_outlined,
                        value: _hideDobYear,
                        onChanged: _showDateOfBirth
                            ? (value) {
                          setState(() => _hideDobYear = value);
                          _updatePrivacySetting(hideDobYear: value);
                        }
                            : null,
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                        enabled: _showDateOfBirth,
                      ),
                    ],
                  ),

                  SizedBox(height: itemSpacing),

                  _buildSectionCard(
                    title: 'Profile Content',
                    icon: Icons.article_outlined,
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    children: [
                      _buildSwitchTile(
                        title: 'Show Interests & Hobbies',
                        subtitle: 'Display your interests on profile',
                        icon: Icons.interests_outlined,
                        value: _showInterestsHobbies,
                        onChanged: (value) {
                          setState(() => _showInterestsHobbies = value);
                          _updatePrivacySetting(showInterestsHobbies: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                      Divider(color: colors.divider, height: 1),
                      _buildSwitchTile(
                        title: 'Show Expectations',
                        subtitle: 'Display partner expectations',
                        icon: Icons.favorite_outline,
                        value: _showExpectations,
                        onChanged: (value) {
                          setState(() => _showExpectations = value);
                          _updatePrivacySetting(showExpectations: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                      Divider(color: colors.divider, height: 1),
                      _buildSwitchTile(
                        title: 'Show Gallery Images',
                        subtitle: 'Display your photo gallery',
                        icon: Icons.photo_library_outlined,
                        value: _showGalleryImages,
                        onChanged: (value) {
                          setState(() => _showGalleryImages = value);
                          _updatePrivacySetting(showGalleryImages: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                    ],
                  ),

                  SizedBox(height: itemSpacing),

                  _buildSectionCard(
                    title: 'Services',
                    icon: Icons.miscellaneous_services_outlined,
                    colors: colors,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    cardRadius: cardRadius,
                    sectionHeaderFontSize: sectionHeaderFontSize,
                    children: [
                      _buildSwitchTile(
                        title: 'Time Spending Service',
                        subtitle: 'Enable time spending feature',
                        icon: Icons.access_time_outlined,
                        value: _isTimeSpendingEnabled,
                        onChanged: (value) {
                          setState(() => _isTimeSpendingEnabled = value);
                          _updatePrivacySetting(isTimeSpendingEnabled: value);
                        },
                        colors: colors,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        titleFontSize: titleFontSize,
                        subtitleFontSize: subtitleFontSize,
                        iconSize: iconSize,
                      ),
                    ],
                  ),

                  SizedBox(height: itemSpacing),

                  _buildSectionCard(
                    title: 'Sugar Partner Service',
                      icon: Icons.card_giftcard_outlined,
                      colors: colors,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      cardRadius: cardRadius,
                      sectionHeaderFontSize: sectionHeaderFontSize,
                      children: [
                        _buildSwitchTile(
                          title: 'Enable Sugar Partner Service',
                          subtitle: 'Allow participation in sugar partner relationships',
                          icon: Icons.favorite_outline,
                          value: _interestedInSugarPartner,
                          onChanged: (value) {
                            setState(() {
                              _interestedInSugarPartner = value;
                              if (!value) {
                                _hideSugarPartnerNotifications = false;
                              }
                            });
                            if (!value) {
                              _updatePrivacySetting(
                                interestedInSugarPartner: value,
                                hideSugarPartnerNotifications: false,
                              );
                            } else {
                              _updatePrivacySetting(interestedInSugarPartner: value);
                            }
                          },
                          colors: colors,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          titleFontSize: titleFontSize,
                          subtitleFontSize: subtitleFontSize,
                          iconSize: iconSize,
                        ),
                        _buildSwitchTile(
                          title: 'Hide Sugar Partner Notifications',
                          subtitle: 'Hide transaction notifications related to Sugar Partner profile exchanges',
                          icon: Icons.notifications_off_outlined,
                          value: _hideSugarPartnerNotifications,
                          onChanged: _interestedInSugarPartner
                              ? (value) {
                            setState(() => _hideSugarPartnerNotifications = value);
                            _updatePrivacySetting(hideSugarPartnerNotifications: value);
                          }
                              : null,
                          enabled: _interestedInSugarPartner,
                          colors: colors,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          titleFontSize: titleFontSize,
                          subtitleFontSize: subtitleFontSize,
                          iconSize: iconSize,
                        ),
                      ],
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

  Widget _buildHeaderSection({
    required dynamic colors,
    required bool isDark,
    required Color primaryColor,
    required double sectionHeaderFontSize,
    required double subtitleFontSize,
    required double iconSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.1)]
              : [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: primaryColor,
              size: iconSize + 4,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control Your Privacy',
                  style: TextStyle(
                    fontSize: sectionHeaderFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage what others can see on your profile',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required dynamic colors,
    required bool isDark,
    required Color primaryColor,
    required double cardRadius,
    required double sectionHeaderFontSize,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sectionHeaderFontSize - 2,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.divider, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool)? onChanged,
    required dynamic colors,
    required bool isDark,
    required Color primaryColor,
    required double titleFontSize,
    required double subtitleFontSize,
    required double iconSize,
    bool enabled = true,
  }) {
    final opacity = enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (value && enabled)
                    ? primaryColor.withOpacity(0.15)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: (value && enabled) ? primaryColor : colors.textSecondary,
                size: iconSize - 4,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: primaryColor,
              activeTrackColor: primaryColor.withOpacity(0.3),
              inactiveThumbColor: colors.textTertiary,
              inactiveTrackColor: colors.surfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
