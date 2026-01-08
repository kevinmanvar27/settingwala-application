import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../theme/theme.dart';
import '../providers/chat_icon_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Service/profile_service.dart';
import '../Service/avatar_service.dart';
import '../utils/auth_helper.dart';
// Removed BookingService import - chat icon visibility is now handled by ChatIconProvider

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> with SingleTickerProviderStateMixin {
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//+'), '/');
    return cleaned;
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  final TextEditingController _occupationController = TextEditingController();
  
  final TextEditingController _interestController = TextEditingController();
  
  final TextEditingController _expectationController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedBodyType;
  String? _selectedEducation;
  String? _selectedIncome;
  String? _selectedRelationshipStatus;
  String? _selectedSmoking;
  String? _selectedDrinking;
  
  final List<String> _genderOptions = ['male', 'female', 'other'];
  final List<String> _bodyTypeOptions = ['Slim', 'Average', 'Athletic', 'Curvy', 'Stocky'];
  final List<String> _educationOptions = ['High School', 'Bachelor', 'Master', 'PhD', 'Other'];
  final List<String> _incomeOptions = ['< \$25K', '\$25K - \$50K', '\$50K - \$100K', '\$100K - \$150K', '\$150K+'];
  final List<String> _relationshipStatusOptions = ['Single', 'Married', 'Divorced', 'Widowed', 'Complicated'];
  final List<String> _smokingOptions = ['Yes', 'No', 'Occasionally'];
  final List<String> _drinkingOptions = ['Yes', 'No', 'Occasionally'];
  
  List<String> _selectedInterests = [];
  
  List<String> _selectedLanguages = [];
  
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _currentAvatarUrl;
  
  DateTime _selectedDate = DateTime(1990, 5, 15);
  
  int? _calculatedAge;
  
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isValidating = true;
  
  final ScrollController _scrollController = ScrollController();
  
  // Removed _showChatIcon - now handled by ChatIconProvider globally


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
    _validateAndLoadData();
    // Removed _checkChatIconVisibility() - now handled by ChatIconProvider
  }

  // Validate user first, then load data if valid
  Future<void> _validateAndLoadData() async {
    final isValid = await AuthHelper.validateUserOrRedirect(context);
    
    if (!mounted) return;
    
    if (isValid) {
      setState(() {
        _isValidating = false;
      });
      _loadProfile();
    }
    // If not valid, AuthHelper already redirected to login
  }

  // Removed _checkChatIconVisibility() method - now handled by ChatIconProvider globally
  // Chat icon visibility is managed by ChatIconProvider in main.dart

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

  List<String> _parseListField(dynamic field) {
    if (field == null) return [];
    
    if (field is List) {
      return field.map((e) => _cleanInterestString(e.toString())).where((s) => s.isNotEmpty).toList();
    }
    
    String str = field.toString();
    
    str = str.trim();
    
    while (str.startsWith('[') && str.endsWith(']')) {
      str = str.substring(1, str.length - 1).trim();
    }
    
    str = str.replaceAll(r'\"', '"').replaceAll(r'\\', '');
    
    str = str.replaceAll('"', '').replaceAll("'", '');
    
    if (str.contains(',')) {
      return str.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
    }
    
    if (str.isNotEmpty) {
      return [str];
    }
    
    return [];
  }

  String _cleanInterestString(String s) {
    String cleaned = s.trim();
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
        
        
        
        
        
        
        
        
        
        
        
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();
        
        setState(() {
          _nameController.text = user.name ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.contactNumber?.toString() ?? '';
          _currentAvatarUrl = _cleanImageUrl(avatarUrl);
          
          if (user.dateOfBirth != null) {
            try {
              _selectedDate = DateTime.parse(user.dateOfBirth.toString());
              _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
              _calculatedAge = _calculateAge(_selectedDate);
            } catch (e) {
              _dobController.text = '';
            }
          }
          
          if (user.gender != null && user.gender.toString().isNotEmpty) {
            final gender = user.gender.toString();
            if (_genderOptions.contains(gender)) {
              _selectedGender = gender;
            }
          }
          
          
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
          
          if (user.relationshipStatus != null && user.relationshipStatus.toString().isNotEmpty) {
            final status = user.relationshipStatus.toString();
            if (_relationshipStatusOptions.contains(status)) {
              _selectedRelationshipStatus = status;
            }
          }
          
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
          
          if (user.interests != null) {
            _selectedInterests = _parseListField(user.interests);
          }
          
          if (user.languages != null) {
            _selectedLanguages = _parseListField(user.languages);
          }
          
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
      
      setState(() {
        _isLoadingProfile = false;
      });
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

    // Show loading while validating user
    if (_isValidating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: colors.card,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    // Get chat notifier for ListenableBuilder
    final chatNotifier = ChatIconProvider.maybeOf(context);
    
    return ListenableBuilder(
      listenable: chatNotifier ?? ChangeNotifier(),
      builder: (context, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: 'Edit Profile',
            scaffoldKey: _scaffoldKey,
            showBackButton: true,  // Add back button for navigation
            // showChatIcon not passed - uses ChatIconProvider automatically
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
                      _buildAvatarSection(colors, primaryColor, isDark),
                      SizedBox(height: isTablet ? 32 : 24),
                      
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
                        maxLength: 10,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length != 10) {
                              return 'Phone number must be exactly 10 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Phone number must contain only digits';
                            }
                          }
                          return null;
                        },
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
      },
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
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: CircleAvatar(
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
    String? Function(String?)? validator,
    int? maxLength,
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
        maxLength: maxLength,
        validator: validator,
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
          counterText: '',
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: isSmallScreen ? 10 : isTablet ? 12 : 11,
          ),
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

}
