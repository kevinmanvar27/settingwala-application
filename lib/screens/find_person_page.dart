import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/user_service.dart';
import '../model/getusersmodel.dart';
import 'package:settingwala/utils/api_constants.dart';

class FindPersonPage extends StatefulWidget {
  const FindPersonPage({super.key});

  @override
  State<FindPersonPage> createState() => _FindPersonPageState();
}

class _FindPersonPageState extends State<FindPersonPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? _selectedGender;
  String? _selectedLocation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  RangeValues _priceRange = const RangeValues(0, 1000);

  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> _genders = ['All', 'Male', 'Female', 'Other'];
  final List<String> _locations = ['All', 'Ahmedabad', 'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata'];

  List<Map<String, dynamic>> _people = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get _filteredPeople {
    return _people.where((person) {
      if (_selectedGender != null && _selectedGender != 'All' && person['gender'] != _selectedGender) {
        return false;
      }
      if (_selectedLocation != null && _selectedLocation != 'All' && person['location'] != _selectedLocation) {
        return false;
      }
      if (person['price'] < _priceRange.start || person['price'] > _priceRange.end) {
        return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilters {
    return (_selectedGender != null && _selectedGender != 'All') ||
           (_selectedLocation != null && _selectedLocation != 'All') ||
           _selectedDate != null ||
           _selectedTime != null ||
           _priceRange.start != 0 ||
           _priceRange.end != 1000;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await UserService.getUsers();
      if (response != null && response.success) {
        setState(() {
          _people = response.data.users.map((user) => _userToMap(user)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load users';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _userToMap(User user) {
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      String cleanUrl = url.replaceAll(r'\/', '/');
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        return cleanUrl;
      }
      return ApiConstants.getStorageUrl(cleanUrl);
    }

    return {
      'id': user.id,
      'name': user.name,
      'age': user.age ?? 0,
      'location': user.city ?? 'Unknown',
      'gender': user.gender ?? 'Female',
      'price': double.tryParse(user.hourlyRate) ?? 0,
      'dob': '',
      'hobbies': <String>[],
      'interests': <String>[],
      'expectations': <String>[], 
      'gallery': user.firstGalleryImage != null && user.firstGalleryImage!.isNotEmpty 
          ? [getFullImageUrl(user.firstGalleryImage)] 
          : <String>[],
      'rating': 4.0 + (user.id % 10) * 0.1,
      'reviews': user.galleryCount * 3,
      'isOnline': user.isOnline,
      'image': getFullImageUrl(user.profilePicture.isNotEmpty ? user.profilePicture : null),
      'bio': user.bio ?? 'No bio available',
      'isVerified': user.isVerified,
      'galleryCount': user.galleryCount,
      'isTimeSpendingEnabled': user.isTimeSpendingEnabled,
      'hourlyRate': user.hourlyRate,
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _genderController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Safely converts a double to int, handling Infinity and NaN cases
  int _safeToInt(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0;
    }
    return value.toInt();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final mainPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final countFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    final filterButtonPaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final filterButtonPaddingV = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final filterButtonRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final filterIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final filterTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final filterBadgeSize = isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 8.0 : 10.0;
    final filterBadgePadding = isDesktop ? 5.0 : isTablet ? 4.5 : isSmallScreen ? 3.0 : 4.0;
    
    final gridCrossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final gridCrossAxisSpacing = isDesktop ? 20.0 : isTablet ? 16.0 : isSmallScreen ? 8.0 : 12.0;
    final gridMainAxisSpacing = isDesktop ? 20.0 : isTablet ? 16.0 : isSmallScreen ? 8.0 : 12.0;
    final gridChildAspectRatio = isDesktop ? 0.72 : isTablet ? 0.73 : isSmallScreen ? 0.72 : 0.75;

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(mainPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors, primaryColor, isDark),
              SizedBox(height: sectionSpacing),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Profiles',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_filteredPeople.length} found',
                        style: TextStyle(
                          fontSize: countFontSize,
                          color: colors.textTertiary,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      GestureDetector(
                        onTap: _showFiltersBottomSheet,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: filterButtonPaddingH, vertical: filterButtonPaddingV),
                          decoration: BoxDecoration(
                            color: _hasActiveFilters ? primaryColor : primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(filterButtonRadius),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: filterIconSize,
                                color: _hasActiveFilters ? (isDark ? AppColors.black : AppColors.white) : primaryColor,
                              ),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: filterTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: _hasActiveFilters ? (isDark ? AppColors.black : AppColors.white) : primaryColor,
                                ),
                              ),
                              if (_hasActiveFilters) ...[
                                SizedBox(width: isSmallScreen ? 2 : 4),
                                Container(
                                  padding: EdgeInsets.all(filterBadgePadding),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.black : AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '!',
                                    style: TextStyle(
                                      fontSize: filterBadgeSize,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),

              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchUsers,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_filteredPeople.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_off, size: 48, color: colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          'No profiles found',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCrossAxisCount,
                    childAspectRatio: gridChildAspectRatio,
                    crossAxisSpacing: gridCrossAxisSpacing,
                    mainAxisSpacing: gridMainAxisSpacing,
                  ),
                  itemCount: _filteredPeople.length,
                  itemBuilder: (context, index) {
                    final person = _filteredPeople[index];
                    return ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildPersonCard(person, colors, primaryColor, isDark),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final headerPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final headerRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final iconSize = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 22.0 : 28.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final iconTextSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final titleSubtitleSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    return Container(
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.primaryLight.withOpacity(0.8), AppColors.primaryLight]
              : [AppColors.primary.withOpacity(0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(headerRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: isDesktop ? 14 : isTablet ? 12 : 10,
            offset: Offset(0, isDesktop ? 6 : 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: AppColors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: iconTextSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Perfect Match',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: titleSubtitleSpacing),
                Text(
                  'Browse profiles and connect with amazing people',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final bottomSheetHeight = isDesktop ? 0.65 : isTablet ? 0.70 : 0.75;
    final bottomSheetRadius = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    final handleWidth = isDesktop ? 50.0 : isTablet ? 45.0 : 40.0;
    final handleHeight = isDesktop ? 5.0 : isTablet ? 4.5 : 4.0;
    final headerPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final headerIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final headerTitleSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final fieldSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final buttonPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final buttonVerticalPadding = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    final buttonRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final buttonFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;

    String? tempGender = _selectedGender;
    String? tempLocation = _selectedLocation;
    DateTime? tempDate = _selectedDate;
    TimeOfDay? tempTime = _selectedTime;
    RangeValues tempPriceRange = _priceRange;

    final tempGenderController = TextEditingController(text: tempGender ?? '');
    final tempLocationController = TextEditingController(text: tempLocation ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * bottomSheetHeight,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(bottomSheetRadius),
                  topRight: Radius.circular(bottomSheetRadius),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: isDesktop ? 16 : 12),
                    width: handleWidth,
                    height: handleHeight,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(handleHeight / 2),
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(headerPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_list, color: primaryColor, size: headerIconSize),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              'Set Filters',
                              style: TextStyle(
                                fontSize: headerTitleSize,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: colors.textTertiary, size: headerIconSize),
                        ),
                      ],
                    ),
                  ),
                  
                  Divider(height: 1, color: colors.divider),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(contentPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBottomSheetTextFormField(
                            'Gender',
                            tempGenderController,
                            _genders,
                            (val) {
                              setBottomSheetState(() {
                                tempGender = val;
                                tempGenderController.text = val ?? '';
                              });
                            },
                            colors,
                            primaryColor,
                            Icons.person_outline,
                          ),
                          SizedBox(height: fieldSpacing),

                          _buildBottomSheetTextFormField(
                            'Location',
                            tempLocationController,
                            _locations,
                            (val) {
                              setBottomSheetState(() {
                                tempLocation = val;
                                tempLocationController.text = val ?? '';
                              });
                            },
                            colors,
                            primaryColor,
                            Icons.location_on_outlined,
                          ),
                          SizedBox(height: fieldSpacing),

                          _buildBottomSheetDatePicker(
                            context,
                            tempDate,
                            (date) => setBottomSheetState(() {
                              tempDate = date;
                              if (date == null) tempTime = null;
                            }),
                            colors,
                            primaryColor,
                          ),
                          SizedBox(height: fieldSpacing),

                          _buildBottomSheetTimePicker(
                            context,
                            tempDate,
                            tempTime,
                            (time) => setBottomSheetState(() => tempTime = time),
                            colors,
                            primaryColor,
                          ),
                          SizedBox(height: fieldSpacing + 4),

                          _buildBottomSheetPriceSlider(
                            context,
                            tempPriceRange,
                            (values) => setBottomSheetState(() => tempPriceRange = values),
                            colors,
                            primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.all(buttonPadding),
                    decoration: BoxDecoration(
                      color: colors.card,
                      boxShadow: [
                        BoxShadow(
                          color: colors.divider,
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setBottomSheetState(() {
                                tempGender = null;
                                tempLocation = null;
                                tempDate = null;
                                tempTime = null;
                                tempPriceRange = const RangeValues(0, 1000);
                                tempGenderController.clear();
                                tempLocationController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor.withOpacity(0.3)),
                              padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(buttonRadius),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGender = tempGender;
                                _selectedLocation = tempLocation;
                                _selectedDate = tempDate;
                                _selectedTime = tempTime;
                                _priceRange = tempPriceRange;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDark ? AppColors.black : AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(buttonRadius),
                              ),
                            ),
                            child: Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
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
        );
      },
    );
  }

  Widget _buildBottomSheetTextFormField(
    String label, 
    TextEditingController controller,
    List<String> items, 
    Function(String?) onChanged,
    AppColorSet colors,
    Color primaryColor,
    IconData icon,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final clearIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final fieldPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final fieldPaddingV = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 10.0 : 14.0;
    final fieldRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final labelFieldSpacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: labelFieldSpacing),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () {
            _showSelectionDialog(label, items, controller.text, (selected) {
              onChanged(selected);
            }, colors, primaryColor);
          },
          style: TextStyle(fontSize: hintFontSize),
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(fontSize: hintFontSize, color: colors.textTertiary),
            prefixIcon: Icon(icon, color: primaryColor, size: iconSize),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged(null);
                    },
                    child: Icon(Icons.clear, size: clearIconSize, color: colors.textTertiary),
                  ),
                Icon(Icons.keyboard_arrow_down, color: primaryColor, size: iconSize),
              ],
            ),
            filled: true,
            fillColor: primaryColor.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(horizontal: fieldPaddingH, vertical: fieldPaddingV),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionDialog(
    String title,
    List<String> items,
    String? currentValue,
    Function(String?) onSelected,
    AppColorSet colors,
    Color primaryColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final itemFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 14.0;
    final checkIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final tileRadius = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
          title: Text(
            'Select $title',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == currentValue;
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: itemFontSize,
                      color: isSelected ? primaryColor : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: primaryColor, size: checkIconSize)
                      : null,
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tileRadius),
                  ),
                  tileColor: isSelected ? primaryColor.withOpacity(0.1) : null,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetDatePicker(
    BuildContext ctx, 
    DateTime? selectedDate, 
    Function(DateTime?) onDateChanged,
    AppColorSet colors,
    Color primaryColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final clearIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final fieldPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final fieldPaddingV = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 10.0 : 14.0;
    final fieldRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final labelFieldSpacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Date (Optional)',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: labelFieldSpacing),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(primary: primaryColor),
                  ),
                  child: child!,
                );
              },
            );
            onDateChanged(date);
          },
          style: TextStyle(fontSize: hintFontSize),
          decoration: InputDecoration(
            hintText: selectedDate != null
                ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                : 'Select Date',
            hintStyle: TextStyle(
              fontSize: hintFontSize,
              color: selectedDate != null ? colors.textPrimary : colors.textTertiary,
            ),
            prefixIcon: Icon(Icons.calendar_today, color: primaryColor, size: iconSize),
            suffixIcon: selectedDate != null
                ? GestureDetector(
                    onTap: () => onDateChanged(null),
                    child: Icon(Icons.clear, size: clearIconSize, color: colors.textTertiary),
                  )
                : null,
            filled: true,
            fillColor: primaryColor.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(horizontal: fieldPaddingH, vertical: fieldPaddingV),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetTimePicker(
    BuildContext ctx, 
    DateTime? selectedDate, 
    TimeOfDay? selectedTime, 
    Function(TimeOfDay?) onTimeChanged,
    AppColorSet colors,
    Color primaryColor,
  ) {
    final isEnabled = selectedDate != null;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final clearIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final fieldPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final fieldPaddingV = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 10.0 : 14.0;
    final fieldRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final labelFieldSpacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Time (Optional)',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: labelFieldSpacing),
        TextFormField(
          readOnly: true,
          enabled: isEnabled,
          onTap: isEnabled ? () async {
            final time = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay.now(),
              initialEntryMode: TimePickerEntryMode.input,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(primary: primaryColor),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      alwaysUse24HourFormat: false,
                    ),
                    child: child!,
                  ),
                );
              },
            );
            if (time != null) {
              onTimeChanged(time);
            }
          } : null,
          style: TextStyle(fontSize: hintFontSize),
          decoration: InputDecoration(
            hintText: selectedTime != null
                ? selectedTime.format(ctx)
                : !isEnabled ? 'Set date first' : 'Select Time',
            hintStyle: TextStyle(
              fontSize: hintFontSize,
              color: selectedTime != null 
                  ? colors.textPrimary 
                  : !isEnabled ? colors.textTertiary.withOpacity(0.6) : colors.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.access_time, 
              color: isEnabled ? primaryColor : colors.textTertiary, 
              size: iconSize,
            ),
            suffixIcon: selectedTime != null
                ? GestureDetector(
                    onTap: () => onTimeChanged(null),
                    child: Icon(Icons.clear, size: clearIconSize, color: colors.textTertiary),
                  )
                : null,
            filled: true,
            fillColor: isEnabled ? primaryColor.withOpacity(0.1) : colors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: fieldPaddingH, vertical: fieldPaddingV),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(
                color: isEnabled ? primaryColor.withOpacity(0.3) : colors.divider,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(
                color: isEnabled ? primaryColor.withOpacity(0.3) : colors.divider,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(fieldRadius),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetPriceSlider(
    BuildContext ctx, 
    RangeValues priceRange, 
    Function(RangeValues) onChanged,
    AppColorSet colors,
    Color primaryColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final valueFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final badgePaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final badgePaddingV = isDesktop ? 8.0 : isTablet ? 7.0 : isSmallScreen ? 4.0 : 6.0;
    final badgeRadius = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    final labelSliderSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    final thumbRadius = isDesktop ? 14.0 : isTablet ? 12.0 : 10.0;
    final trackHeight = isDesktop ? 8.0 : isTablet ? 7.0 : 6.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range (₹/hour)',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(badgeRadius),
              ),
              child: Text(
                '₹${_safeToInt(priceRange.start)} - ₹${_safeToInt(priceRange.end)}',
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: labelSliderSpacing),
        SliderTheme(
          data: SliderTheme.of(ctx).copyWith(
            activeTrackColor: primaryColor,
            inactiveTrackColor: primaryColor.withOpacity(0.2),
            thumbColor: primaryColor,
            overlayColor: primaryColor.withOpacity(0.2),
            rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: thumbRadius),
            trackHeight: trackHeight,
          ),
          child: RangeSlider(
            values: priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person, AppColorSet colors, Color primaryColor, bool isDark) {
    final isOnline = person['isOnline'] ?? false;
    final isFemale = person['gender'] == 'Female';
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final imageHeight = isDesktop ? 160.0 : isTablet ? 140.0 : isSmallScreen ? 100.0 : 120.0;
    final imageIconSize = isDesktop ? 80.0 : isTablet ? 70.0 : isSmallScreen ? 45.0 : 60.0;
    
    final genderBadgePaddingH = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
    final genderBadgePaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    final genderBadgeRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final genderIconSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 9.0 : 12.0;
    final genderTextSize = isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 8.0 : 10.0;
    
    final onlineBadgePaddingH = isDesktop ? 10.0 : isTablet ? 8.0 : isSmallScreen ? 4.0 : 6.0;
    final onlineBadgePaddingV = isDesktop ? 5.0 : isTablet ? 4.0 : isSmallScreen ? 2.0 : 3.0;
    final onlineBadgeRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final onlineTextSize = isDesktop ? 11.0 : isTablet ? 10.0 : isSmallScreen ? 7.0 : 9.0;
    
    final detailsPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final nameFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final detailIconSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final detailTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final detailSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    final buttonPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
    final buttonRadius = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final buttonFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: isDesktop ? 12 : 8,
            offset: Offset(0, isDesktop ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(cardRadius),
                  topRight: Radius.circular(cardRadius),
                ),
                child: Container(
                  height: imageHeight,
                  width: double.infinity,
                  color: isFemale ? Colors.pink.shade100 : Colors.blue.shade100,
                  child: Center(
                    child: Icon(
                      isFemale ? Icons.face_3 : Icons.face,
                      size: imageIconSize,
                      color: isFemale ? Colors.pink.shade300 : Colors.blue.shade300,
                    ),
                  ),
                ),
              ),
              
              Positioned(
                top: isSmallScreen ? 4 : 8,
                left: isSmallScreen ? 4 : 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: genderBadgePaddingH, vertical: genderBadgePaddingV),
                  decoration: BoxDecoration(
                    color: isFemale ? Colors.pink.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(genderBadgeRadius),
                    border: Border.all(
                      color: isFemale ? Colors.pink.shade300 : Colors.blue.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFemale ? Icons.female : Icons.male,
                        size: genderIconSize,
                        color: isFemale ? Colors.pink.shade600 : Colors.blue.shade600,
                      ),
                      SizedBox(width: isSmallScreen ? 1 : 2),
                      Text(
                        person['gender'],
                        style: TextStyle(
                          fontSize: genderTextSize,
                          fontWeight: FontWeight.bold,
                          color: isFemale ? Colors.pink.shade600 : Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (isOnline)
                Positioned(
                  top: isSmallScreen ? 4 : 8,
                  right: isSmallScreen ? 4 : 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: onlineBadgePaddingH, vertical: onlineBadgePaddingV),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(onlineBadgeRadius),
                    ),
                    child: Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: onlineTextSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(detailsPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${person['name']}, ${person['age']}',
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: detailSpacing),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: detailIconSize,
                        color: colors.textTertiary,
                      ),
                      SizedBox(width: isSmallScreen ? 1 : 2),
                      Expanded(
                        child: Text(
                          person['location'],
                          style: TextStyle(
                            fontSize: detailTextSize,
                            color: colors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: detailSpacing),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        size: detailIconSize,
                        color: AppColors.success,
                      ),
                      SizedBox(width: isSmallScreen ? 1 : 2),
                      Text(
                        '${person['price']}/hr',
                        style: TextStyle(
                          fontSize: detailTextSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AppRoutes.toPersonProfile(context, person);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                        textStyle: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('View Details', style: TextStyle(fontSize: buttonFontSize)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
