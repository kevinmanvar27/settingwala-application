import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../theme/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Service/profile_service.dart';
import '../Service/avatar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> with SingleTickerProviderStateMixin {
  // Helper function to clean URL - removes escaped slashes and double slashes
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    // Fix double slashes (except after http: or https:)
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//'), '/');
    return cleaned;
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Form controllers - Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  // Form controllers - Physical Attributes
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Form controllers - Professional
  final TextEditingController _occupationController = TextEditingController();
  
  // Form controllers - Interests
  final TextEditingController _interestController = TextEditingController();
  
  // Form controllers - Partner Expectations
  final TextEditingController _expectationController = TextEditingController();
  
  // Dropdown selections
  String? _selectedGender;
  String? _selectedBodyType;
  String? _selectedEducation;
  String? _selectedIncome;
  String? _selectedRelationshipStatus;
  String? _selectedSmoking;
  String? _selectedDrinking;
  
  // Dropdown options
  final List<String> _genderOptions = ['male', 'female', 'other'];
  final List<String> _bodyTypeOptions = ['Slim', 'Average', 'Athletic', 'Curvy', 'Stocky'];
  final List<String> _educationOptions = ['High School', 'Bachelor', 'Master', 'PhD', 'Other'];
  final List<String> _incomeOptions = ['< \$25K', '\$25K - \$50K', '\$50K - \$100K', '\$100K - \$150K', '\$150K+'];
  final List<String> _relationshipStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed', 'Complicated'];
  final List<String> _smokingOptions = ['Yes', 'No', 'Occasionally'];
  final List<String> _drinkingOptions = ['Yes', 'No', 'Occasionally'];
  
  // Interest selection
  List<String> _selectedInterests = [];
  
  // Language selection
  List<String> _selectedLanguages = [];
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _currentAvatarUrl;
  
  // Date of birth
  DateTime _selectedDate = DateTime(1990, 5, 15);
  
  // Calculated age
  int? _calculatedAge;
  
  // Loading states
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  
  // Scroll controller to maintain scroll position
  final ScrollController _scrollController = ScrollController();

  // Privacy settings state variables
  bool _publicProfile = false;
  bool _showContactNumber = false;
  bool _showDateOfBirth = true;
  bool _hideBirthYear = false;
  bool _showInterestsHobbies = true;
  bool _showExpectationsFromPartner = true;
  bool _showGalleryImages = true;
  bool _timeSpendingService = false;
  
  // Feature flag for time spending (from features API)
  bool _isTimeSpendingFeatureEnabled = false;
  
  // Privacy section expanded state
  bool _isPrivacySectionExpanded = false;

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
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _occupationController.dispose();
    _interestController.dispose();
    _expectationController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Helper method to parse list fields that may come in various formats
  // Handles: List, String with commas, escaped JSON like "[\"[\\\"love\\\"]\"]"
  List<String> _parseListField(dynamic field) {
    if (field == null) return [];
    
    if (field is List) {
      // If it's already a list, convert items to strings and clean them
      return field.map((e) => _cleanInterestString(e.toString())).where((s) => s.isNotEmpty).toList();
    }
    
    String str = field.toString();
    
    // Remove outer brackets and quotes if present
    str = str.trim();
    
    // Handle escaped JSON format like "[\"[\\\"love\\\"]\"]" or "[[\"love\"]]"
    // Keep removing outer brackets and escapes until we get clean values
    while (str.startsWith('[') && str.endsWith(']')) {
      str = str.substring(1, str.length - 1).trim();
    }
    
    // Remove escaped quotes
    str = str.replaceAll(r'\"', '"').replaceAll(r'\\', '');
    
    // Remove remaining quotes
    str = str.replaceAll('"', '').replaceAll("'", '');
    
    // Split by comma and clean each item
    if (str.contains(',')) {
      return str.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
    }
    
    // Single value
    if (str.isNotEmpty) {
      return [str];
    }
    
    return [];
  }

  String _cleanInterestString(String s) {
    String cleaned = s.trim();
    // Remove brackets and quotes
    cleaned = cleaned.replaceAll('[', '').replaceAll(']', '');
    cleaned = cleaned.replaceAll(r'\"', '').replaceAll('"', '').replaceAll("'", '');
    cleaned = cleaned.replaceAll(r'\\', '');
    return cleaned.trim();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        
        // Debug: Print expectation value
        print('========== DEBUG: Expectation ==========');
        print('expectation raw: ${user.expectation}');
        print('expectation type: ${user.expectation?.runtimeType}');
        print('=========================================');
        
        // Debug avatar URL
        print('========== DEBUG: Avatar URL ==========');
        print('Raw profilePictureUrl: ${user.profilePictureUrl}');
        print('Raw profilePicture: ${user.profilePicture}');
        print('========================================');
        
        // Get avatar URL - try profilePictureUrl first, then profilePicture
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();
        
        setState(() {
          // Basic Info
          _nameController.text = user.name ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.contactNumber?.toString() ?? '';
          _currentAvatarUrl = _cleanImageUrl(avatarUrl);
          
          // Parse date of birth
          if (user.dateOfBirth != null) {
            try {
              _selectedDate = DateTime.parse(user.dateOfBirth.toString());
              _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
              _calculatedAge = _calculateAge(_selectedDate);
            } catch (e) {
              _dobController.text = '';
            }
          }
          
          // Gender
          if (user.gender != null && user.gender.toString().isNotEmpty) {
            final gender = user.gender.toString();
            if (_genderOptions.contains(gender)) {
              _selectedGender = gender;
            }
          }
          
          
          // Physical Attributes
          if (user.height != null) {
            _heightController.text = user.height.toString();
          }
          if (user.weight != null) {
            _weightController.text = user.weight.toString();
          }
          if (user.bodyType != null && user.bodyType.toString().isNotEmpty) {
            final bodyType = user.bodyType.toString();
            if (_bodyTypeOptions.contains(bodyType)) {
              _selectedBodyType = bodyType;
            }
          }
          
          // Professional
          if (user.education != null && user.education.toString().isNotEmpty) {
            final education = user.education.toString();
            if (_educationOptions.contains(education)) {
              _selectedEducation = education;
            }
          }
          _occupationController.text = user.occupation?.toString() ?? '';
          if (user.income != null && user.income.toString().isNotEmpty) {
            final income = user.income.toString();
            if (_incomeOptions.contains(income)) {
              _selectedIncome = income;
            }
          }
          
          // Relationship Status
          if (user.relationshipStatus != null && user.relationshipStatus.toString().isNotEmpty) {
            final status = user.relationshipStatus.toString();
            if (_relationshipStatusOptions.contains(status)) {
              _selectedRelationshipStatus = status;
            }
          }
          
          // Lifestyle
          if (user.smoking != null && user.smoking.toString().isNotEmpty) {
            final smoking = user.smoking.toString();
            if (_smokingOptions.contains(smoking)) {
              _selectedSmoking = smoking;
            }
          }
          if (user.drinking != null && user.drinking.toString().isNotEmpty) {
            final drinking = user.drinking.toString();
            if (_drinkingOptions.contains(drinking)) {
              _selectedDrinking = drinking;
            }
          }
          
          // Parse interests - handle various formats including escaped JSON
          if (user.interests != null) {
            _selectedInterests = _parseListField(user.interests);
          }
          
          // Parse languages - handle various formats including escaped JSON
          if (user.languages != null) {
            _selectedLanguages = _parseListField(user.languages);
          }
          
          // Partner Expectations
          if (user.expectation != null && user.expectation.toString().isNotEmpty) {
            _expectationController.text = user.expectation.toString();
          }
          
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });
    }
    // Load privacy settings after profile
    await _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First try to load from API
      final profileData = await ProfileService.getProfile();
      
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        final features = profileData.data!.features;
        setState(() {
          _publicProfile = user.isPublicProfile ?? prefs.getBool('is_public_profile') ?? false;
          _showContactNumber = user.showContactNumber ?? prefs.getBool('show_contact_number') ?? false;
          _showDateOfBirth = user.showDateOfBirth ?? prefs.getBool('show_date_of_birth') ?? true;
          _hideBirthYear = user.hideDobYear ?? prefs.getBool('hide_dob_year') ?? false;
          _showInterestsHobbies = user.showInterestsHobbies ?? prefs.getBool('show_interests_hobbies') ?? true;
          _showExpectationsFromPartner = user.showExpectations ?? prefs.getBool('show_expectations') ?? true;
          _showGalleryImages = user.showGalleryImages ?? prefs.getBool('show_gallery_images') ?? true;
          _timeSpendingService = user.isTimeSpendingEnabled ?? prefs.getBool('is_time_spending_enabled') ?? false;
          // Load time spending feature flag from features
          _isTimeSpendingFeatureEnabled = features?.timeSpending ?? false;
        });
      } else {
        // Fallback to SharedPreferences
        setState(() {
          _publicProfile = prefs.getBool('is_public_profile') ?? false;
          _showContactNumber = prefs.getBool('show_contact_number') ?? false;
          _showDateOfBirth = prefs.getBool('show_date_of_birth') ?? true;
          _hideBirthYear = prefs.getBool('hide_dob_year') ?? false;
          _showInterestsHobbies = prefs.getBool('show_interests_hobbies') ?? true;
          _showExpectationsFromPartner = prefs.getBool('show_expectations') ?? true;
          _showGalleryImages = prefs.getBool('show_gallery_images') ?? true;
          _timeSpendingService = prefs.getBool('is_time_spending_enabled') ?? false;
          _isTimeSpendingFeatureEnabled = false;
        });
      }
    } catch (e) {
      print('Error loading privacy settings: $e');
    }
  }

  // Helper function to update single privacy setting via PUT Profile API
  Future<void> _updatePrivacySetting({
    bool? isPublicProfile,
    bool? showContactNumber,
    bool? showDateOfBirth,
    bool? hideDobYear,
    bool? showInterestsHobbies,
    bool? showExpectations,
    bool? showGalleryImages,
    bool? isTimeSpendingEnabled,
  }) async {
    // Store old values to restore on failure
    final oldPublicProfile = _publicProfile;
    final oldShowContactNumber = _showContactNumber;
    final oldShowDateOfBirth = _showDateOfBirth;
    final oldHideBirthYear = _hideBirthYear;
    final oldShowInterestsHobbies = _showInterestsHobbies;
    final oldShowExpectationsFromPartner = _showExpectationsFromPartner;
    final oldShowGalleryImages = _showGalleryImages;
    final oldTimeSpendingService = _timeSpendingService;

    try {
      print('========== UPDATING PRIVACY SETTING ==========');
      print('isPublicProfile: $isPublicProfile');
      print('showContactNumber: $showContactNumber');
      print('showDateOfBirth: $showDateOfBirth');
      print('hideDobYear: $hideDobYear');
      print('showInterestsHobbies: $showInterestsHobbies');
      print('showExpectations: $showExpectations');
      print('showGalleryImages: $showGalleryImages');
      print('isTimeSpendingEnabled: $isTimeSpendingEnabled');
      print('===============================================');

      // Use dedicated privacy settings API method
      final result = await ProfileService.updatePrivacySettings(
        isPublicProfile: isPublicProfile,
        showContactNumber: showContactNumber,
        showDateOfBirth: showDateOfBirth,
        hideDobYear: hideDobYear,
        showInterestsHobbies: showInterestsHobbies,
        showExpectations: showExpectations,
        showGalleryImages: showGalleryImages,
        isTimeSpendingEnabled: isTimeSpendingEnabled,
      );

      if (result != null && result['success'] == true) {
        print('Privacy setting updated successfully!');
        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Setting saved!'),
              duration: Duration(milliseconds: 800),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Save to SharedPreferences locally
        final prefs = await SharedPreferences.getInstance();
        if (isPublicProfile != null) await prefs.setBool('is_public_profile', isPublicProfile);
        if (showContactNumber != null) await prefs.setBool('show_contact_number', showContactNumber);
        if (showDateOfBirth != null) await prefs.setBool('show_date_of_birth', showDateOfBirth);
        if (hideDobYear != null) await prefs.setBool('hide_dob_year', hideDobYear);
        if (showInterestsHobbies != null) await prefs.setBool('show_interests_hobbies', showInterestsHobbies);
        if (showExpectations != null) await prefs.setBool('show_expectations', showExpectations);
        if (showGalleryImages != null) await prefs.setBool('show_gallery_images', showGalleryImages);
        if (isTimeSpendingEnabled != null) await prefs.setBool('is_time_spending_enabled', isTimeSpendingEnabled);
      } else {
        print('Failed to update privacy setting');
        // Restore old values on failure
        if (mounted) {
          setState(() {
            _publicProfile = oldPublicProfile;
            _showContactNumber = oldShowContactNumber;
            _showDateOfBirth = oldShowDateOfBirth;
            _hideBirthYear = oldHideBirthYear;
            _showInterestsHobbies = oldShowInterestsHobbies;
            _showExpectationsFromPartner = oldShowExpectationsFromPartner;
            _showGalleryImages = oldShowGalleryImages;
            _timeSpendingService = oldTimeSpendingService;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update setting'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating privacy setting: $e');
      // Restore old values on error
      if (mounted) {
        setState(() {
          _publicProfile = oldPublicProfile;
          _showContactNumber = oldShowContactNumber;
          _showDateOfBirth = oldShowDateOfBirth;
          _hideBirthYear = oldHideBirthYear;
          _showInterestsHobbies = oldShowInterestsHobbies;
          _showExpectationsFromPartner = oldShowExpectationsFromPartner;
          _showGalleryImages = oldShowGalleryImages;
          _timeSpendingService = oldTimeSpendingService;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final result = await ProfileService.updateProfile(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        contactNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        dateOfBirth: _dobController.text.isNotEmpty ? DateFormat('yyyy-MM-dd').format(_selectedDate) : null,
        gender: _selectedGender,
        height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
        bodyType: _selectedBodyType,
        education: _selectedEducation,
        occupation: _occupationController.text.isNotEmpty ? _occupationController.text : null,
        income: _selectedIncome,
        relationshipStatus: _selectedRelationshipStatus,
        smoking: _selectedSmoking,
        drinking: _selectedDrinking,
        interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
        languages: _selectedLanguages.isNotEmpty ? _selectedLanguages : null,
        expectation: _expectationController.text.isNotEmpty ? _expectationController.text : null,
      );
      
      if (result != null && result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isUploadingAvatar = true;
      });
      
      try {
        final result = await AvatarService.uploadAvatar(_imageFile!);
        if (result != null && result.success == true) {
          setState(() {
            _currentAvatarUrl = result.data?.avatarUrl;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Avatar updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        print('Error uploading avatar: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading avatar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingAvatar = false);
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _calculatedAge = _calculateAge(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final colors = context.colors;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const CustomDrawer(),
      body: _isLoadingProfile
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 24 : 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Section
                      _buildAvatarSection(colors, primaryColor, isDark),
                      SizedBox(height: isTablet ? 32 : 24),
                      
                      // Basic Info Section
                      _buildSectionTitle('Basic Information', colors),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextFormField(
                            controller: _dobController,
                            label: 'Date of Birth${_calculatedAge != null ? ' (Age: $_calculatedAge)' : ''}',
                            icon: Icons.cake,
                            colors: colors,
                            primaryColor: primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildDropdownField(
                        label: 'Gender',
                        icon: Icons.wc,
                        value: _selectedGender,
                        items: _genderOptions,
                        onChanged: (value) => setState(() => _selectedGender = value),
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 32 : 24),
                      
                      // Interests Section
                      _buildSectionTitle('Interests & Hobbies', colors),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildChipInputField(
                        controller: _interestController,
                        label: 'Add Interest',
                        icon: Icons.interests,
                        selectedItems: _selectedInterests,
                        onAdd: (value) {
                          if (value.isNotEmpty && !_selectedInterests.contains(value)) {
                            setState(() {
                              _selectedInterests.add(value);
                              _interestController.clear();
                            });
                          }
                        },
                        onRemove: (value) {
                          setState(() => _selectedInterests.remove(value));
                        },
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 32 : 24),
                      
                      // Partner Expectations Section
                      _buildSectionTitle('Partner Expectations', colors),
                      SizedBox(height: isTablet ? 16 : 12),
                      _buildTextFormField(
                        controller: _expectationController,
                        label: 'What do you expect from a partner?',
                        icon: Icons.favorite_border,
                        maxLines: 4,
                        colors: colors,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: isTablet ? 32 : 24),

                      
                      _buildSaveButton(colors, primaryColor, isDark),
                      SizedBox(height: isTablet ? 32 : 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection(AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    
    final avatarRadius = isTablet ? 60.0 : isSmallScreen ? 40.0 : 50.0;
    
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: primaryColor.withOpacity(0.2),
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (_currentAvatarUrl != null
                    ? NetworkImage(_currentAvatarUrl!)
                    : null) as ImageProvider?,
            child: (_imageFile == null && _currentAvatarUrl == null)
                ? Icon(Icons.person, size: avatarRadius, color: primaryColor)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickImage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.card, width: 2),
                ),
                child: _isUploadingAvatar
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? AppColors.black : AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: isTablet ? 24 : 20,
                        color: isDark ? AppColors.black : AppColors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColorSet colors) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallScreen ? 16 : isTablet ? 22 : 18,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required AppColorSet colors,
    required Color primaryColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : isTablet ? 24 : 20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: isSmallScreen ? 14 : isTablet ? 16 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: isSmallScreen ? 12 : isTablet ? 14 : 13,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : isTablet ? 20 : 16,
            vertical: isSmallScreen ? 12 : isTablet ? 18 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required AppColorSet colors,
    required Color primaryColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : isTablet ? 24 : 20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: isSmallScreen ? 12 : isTablet ? 14 : 13,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : isTablet ? 20 : 16,
            vertical: isSmallScreen ? 12 : isTablet ? 18 : 14,
          ),
        ),
        dropdownColor: colors.card,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: isSmallScreen ? 14 : isTablet ? 16 : 15,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildChipInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> selectedItems,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required AppColorSet colors,
    required Color primaryColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : isTablet ? 24 : 20),
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
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: isSmallScreen ? 14 : isTablet ? 16 : 15,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(
                      color: colors.textSecondary,
                      fontSize: isSmallScreen ? 12 : isTablet ? 14 : 13,
                    ),
                    prefixIcon: Icon(icon, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : isTablet ? 20 : 16,
                      vertical: isSmallScreen ? 12 : isTablet ? 18 : 14,
                    ),
                  ),
                  onFieldSubmitted: onAdd,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: primaryColor),
                onPressed: () => onAdd(controller.text),
              ),
            ],
          ),
        ),
        if (selectedItems.isNotEmpty) ...[
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedItems.map((item) {
              return Chip(
                label: Text(
                  item,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                backgroundColor: primaryColor.withOpacity(0.1),
                deleteIcon: Icon(Icons.close, size: 18, color: primaryColor),
                onDeleted: () => onRemove(item),
                side: BorderSide(color: primaryColor.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacySwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColorSet colors,
    required Color primaryColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : isTablet ? 20 : 16,
        vertical: isSmallScreen ? 10 : isTablet ? 14 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : isTablet ? 10 : 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: isSmallScreen ? 18 : isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 14 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : isTablet ? 12 : 11,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyDivider(Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Divider(
      height: 1,
      color: primaryColor.withOpacity(0.15),
      indent: isTablet ? 70 : 55,
    );
  }

  Widget _buildSaveButton(AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : isTablet ? 64 : 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : isTablet ? 35 : 30),
          ),
          elevation: 4,
        ),
        child: _isSaving
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? AppColors.black : AppColors.white,
                ),
              )
            : Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // Time Spending Button - Navigate to Time Spending Screen
}