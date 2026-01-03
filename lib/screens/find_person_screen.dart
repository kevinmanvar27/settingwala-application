import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../routes/app_routes.dart';  // Add route-based navigation
import '../Service/user_service.dart';
import '../model/getusersmodel.dart';
import 'package:settingwala/utils/api_constants.dart';

class FindPersonScreen extends StatefulWidget {
  const FindPersonScreen({super.key});

  @override
  State<FindPersonScreen> createState() => _FindPersonScreenState();
}

class _FindPersonScreenState extends State<FindPersonScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  RangeValues _priceRange = const RangeValues(_defaultPriceMin, _defaultPriceMax);
  List<String> _selectedGenders = ['Male', 'Female'];
  String _locationFilter = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  List<Map<String, dynamic>> _people = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  static const double _defaultPriceMin = 100;
  static const double _defaultPriceMax = 2000;
  
  bool get _isPriceRangeDefault => 
      _priceRange.start == _defaultPriceMin && _priceRange.end == _defaultPriceMax;
  
  List<Map<String, dynamic>> get filteredPeople {
    if (_searchController.text.isEmpty && 
        _selectedGenders.length == 2 && 
        _locationFilter.isEmpty && 
        _selectedDate == null && 
        _selectedTime == null &&
        _isPriceRangeDefault) {
      return _people;
    }
    
    return _people.where((person) {
      bool matchesSearch = _searchController.text.isEmpty || 
          (person['name']?.toString().toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
          (person['location']?.toString().toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      
      bool matchesGender = _selectedGenders.contains(person['gender']);
      
      bool matchesLocation = _locationFilter.isEmpty || 
          (person['location']?.toString().toLowerCase().contains(_locationFilter.toLowerCase()) ?? false);
      
      double personPrice = (person['price'] as num?)?.toDouble() ?? 0;
      bool matchesPrice = _isPriceRangeDefault || 
          (personPrice >= _priceRange.start && personPrice <= _priceRange.end);
      
      bool matchesDateAndTime = true;
      
      return matchesSearch && matchesGender && matchesLocation && matchesPrice && matchesDateAndTime;
    }).toList();
  }

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
    
    String buildLocation() {
      List<String> locationParts = [];
      if (user.city != null && user.city.toString().isNotEmpty) {
        locationParts.add(user.city.toString());
      }
      if (user.state != null && user.state.toString().isNotEmpty) {
        locationParts.add(user.state.toString());
      }
      
      return locationParts.isEmpty ? 'Unknown' : locationParts.join(', ');
    }
    
    return {
      'id': user.id,
      'name': user.name,
      'age': user.age ?? 0,
      'location': buildLocation(),
      'distance': '${(user.id % 5) + 1}.${user.id % 10} km away',
      'bio': user.bio ?? 'No bio available',
      'gender': user.gender ?? 'Female',
      'price': double.tryParse(user.hourlyRate) ?? 0,
      'rating': user.rating?.toDouble() ?? 4.5,
      'reviews': user.reviewsCount ?? 0,
      'isOnline': user.isOnline,
      'dob': '',
      'hobbies': <String>[],
      'expectations': <String>[],
      'gallery': user.firstGalleryImage != null && user.firstGalleryImage!.isNotEmpty 
          ? [getFullImageUrl(user.firstGalleryImage)] 
          : <String>[],
      'image': getFullImageUrl(user.profilePicture.isNotEmpty ? user.profilePicture : null),
      'isVerified': user.isVerified,
      'galleryCount': user.galleryCount,
      'isTimeSpendingEnabled': user.isTimeSpendingEnabled,
      'hourlyRate': user.hourlyRate,
      'timeSpendingServices': user.timeSpendingServices,
      'timeSpendingDescription': user.timeSpendingDescription,
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: colors.card,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, StateSetter setState) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: colors.card,
              onSurface: colors.textPrimary,
            ),
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
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showFilterBottomSheet() {
    final locationController = TextEditingController(text: _locationFilter);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final colors = context.colors;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
          
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isSmallScreen = screenWidth < 360;
          final isTablet = screenWidth >= 600;
          
          final sheetHeight = isTablet ? screenHeight * 0.7 : screenHeight * 0.8;
          final titleSize = isSmallScreen ? 16.0 : (isTablet ? 22.0 : 18.0);
          final filterTitleSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
          final chipLabelSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
          final buttonPadding = isSmallScreen ? 10.0 : (isTablet ? 16.0 : 12.0);
          final contentPadding = isSmallScreen ? 14.0 : (isTablet ? 28.0 : 20.0);
          final inputFontSize = isSmallScreen ? 13.0 : (isTablet ? 16.0 : 14.0);
          final inputHeight = isSmallScreen ? 44.0 : (isTablet ? 54.0 : 48.0);
          
          return Container(
            height: sheetHeight,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSmallScreen ? 16 : 20),
                topRight: Radius.circular(isSmallScreen ? 16 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(contentPadding, isSmallScreen ? 12 : 16, contentPadding, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter People',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: isSmallScreen ? 22 : 24),
                        onPressed: () => Navigator.pop(context),
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                ),
                
                Divider(color: colors.divider),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterTitle('Gender', colors, filterTitleSize),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Wrap(
                          spacing: isSmallScreen ? 8 : 10,
                          children: ['Male', 'Female'].map((gender) {
                            final isSelected = _selectedGenders.contains(gender);
                            return FilterChip(
                              label: Text(gender, style: TextStyle(fontSize: chipLabelSize)),
                              selected: isSelected,
                              selectedColor: primaryColor.withOpacity(0.2),
                              checkmarkColor: primaryColor,
                              backgroundColor: colors.surfaceVariant,
                              labelStyle: TextStyle(
                                color: isSelected ? primaryColor : colors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: chipLabelSize,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedGenders.add(gender);
                                  } else {
                                    if (_selectedGenders.length > 1) {
                                      _selectedGenders.remove(gender);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        
                        _buildFilterTitle('Location', colors, filterTitleSize),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        SizedBox(
                          height: inputHeight,
                          child: TextFormField(
                            controller: locationController,
                            style: TextStyle(fontSize: inputFontSize, color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter location (e.g., Mumbai, Delhi)',
                              hintStyle: TextStyle(fontSize: inputFontSize, color: colors.textTertiary),
                              prefixIcon: Icon(Icons.location_on, color: primaryColor, size: isSmallScreen ? 20 : 24),
                              suffixIcon: locationController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: colors.textTertiary, size: isSmallScreen ? 18 : 20),
                                      onPressed: () {
                                        setState(() {
                                          locationController.clear();
                                          _locationFilter = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: colors.inputBackground,
                              contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                borderSide: BorderSide(color: colors.inputBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                borderSide: BorderSide(color: colors.inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _locationFilter = value;
                              });
                            },
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        
                        _buildFilterTitle('Available Date', colors, filterTitleSize),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        GestureDetector(
                          onTap: () => _selectDate(context, setState),
                          child: Container(
                            height: inputHeight,
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: colors.inputBackground,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                              border: Border.all(color: colors.inputBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: primaryColor, size: isSmallScreen ? 20 : 24),
                                SizedBox(width: isSmallScreen ? 10 : 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null 
                                        ? _formatDate(_selectedDate)
                                        : 'Select date',
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      color: _selectedDate != null ? colors.textPrimary : colors.textTertiary,
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = null;
                                      });
                                    },
                                    child: Icon(Icons.clear, color: colors.textTertiary, size: isSmallScreen ? 18 : 20),
                                  ),
                                if (_selectedDate == null)
                                  Icon(Icons.arrow_drop_down, color: colors.textTertiary, size: isSmallScreen ? 22 : 24),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        
                        _buildFilterTitle('Available Time', colors, filterTitleSize),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, setState),
                          child: Container(
                            height: inputHeight,
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: colors.inputBackground,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                              border: Border.all(color: colors.inputBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: primaryColor, size: isSmallScreen ? 20 : 24),
                                SizedBox(width: isSmallScreen ? 10 : 12),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null 
                                        ? _formatTime(_selectedTime)
                                        : 'Select time',
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      color: _selectedTime != null ? colors.textPrimary : colors.textTertiary,
                                    ),
                                  ),
                                ),
                                if (_selectedTime != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTime = null;
                                      });
                                    },
                                    child: Icon(Icons.clear, color: colors.textTertiary, size: isSmallScreen ? 18 : 20),
                                  ),
                                if (_selectedTime == null)
                                  Icon(Icons.arrow_drop_down, color: colors.textTertiary, size: isSmallScreen ? 22 : 24),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 14 : 20),
                        
                        _buildFilterTitle('Price Range (₹/hr)', colors, filterTitleSize),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${_priceRange.start.round()}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: chipLabelSize,
                              ),
                            ),
                            Text(
                              '₹${_priceRange.end.round()}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: chipLabelSize,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        RangeSlider(
                          values: _priceRange,
                          min: _defaultPriceMin,
                          max: _defaultPriceMax,
                          divisions: 19,
                          activeColor: primaryColor,
                          inactiveColor: colors.divider,
                          labels: RangeLabels(
                            '₹${_priceRange.start.round()}',
                            '₹${_priceRange.end.round()}',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: Border(
                      top: BorderSide(color: colors.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedGenders = ['Male', 'Female'];
                              _locationFilter = '';
                              locationController.clear();
                              _selectedDate = null;
                              _selectedTime = null;
                              _priceRange = const RangeValues(_defaultPriceMin, _defaultPriceMax);
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(color: colors.textSecondary, fontSize: chipLabelSize),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            this.setState(() {
                              _locationFilter = locationController.text;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Apply', style: TextStyle(fontSize: chipLabelSize)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTitle(String title, AppColorSet colors, double fontSize) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
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
    final isDesktop = screenWidth >= 1024;
    
    final searchBarHeight = isSmallScreen ? 42.0 : (isTablet ? 54.0 : 48.0);
    final searchBarPadding = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final searchHintSize = isSmallScreen ? 13.0 : (isTablet ? 16.0 : 14.0);
    final filterButtonPadding = isSmallScreen ? 10.0 : (isTablet ? 14.0 : 12.0);
    final gridPadding = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final gridSpacing = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final emptyIconSize = isSmallScreen ? 48.0 : (isTablet ? 80.0 : 64.0);
    final emptyTitleSize = isSmallScreen ? 16.0 : (isTablet ? 22.0 : 18.0);
    final emptySubtitleSize = isSmallScreen ? 13.0 : (isTablet ? 16.0 : 14.0);
    
    // Tablet ma 4 users per row, mobile ma 2
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 4 : 2);
    
    return BaseScreen(
      title: 'Find Person',
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(searchBarPadding),
              color: colors.card,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: searchBarHeight,
                      decoration: BoxDecoration(
                        color: colors.inputBackground,
                        borderRadius: BorderRadius.circular(searchBarHeight / 2),
                        border: Border.all(color: colors.inputBorder),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _isSearching = value.isNotEmpty;
                          });
                        },
                        style: TextStyle(fontSize: searchHintSize),
                        decoration: InputDecoration(
                          hintText: 'Search people...',
                          hintStyle: TextStyle(color: colors.textTertiary, fontSize: searchHintSize),
                          prefixIcon: Icon(Icons.search, color: primaryColor, size: isSmallScreen ? 20 : 24),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: colors.textTertiary, size: isSmallScreen ? 18 : 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: searchBarHeight / 4),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  
                  InkWell(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: EdgeInsets.all(filterButtonPadding),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: emptyIconSize,
                                color: Colors.red,
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: emptySubtitleSize,
                                  color: colors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              ElevatedButton(
                                onPressed: _fetchUsers,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : filteredPeople.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    size: emptyIconSize,
                                    color: primaryColor.withOpacity(0.7),
                                  ),
                                  SizedBox(height: isSmallScreen ? 12 : 16),
                                  Text(
                                    'No people found',
                                    style: TextStyle(
                                      fontSize: emptyTitleSize,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: gridPadding),
                                    child: Text(
                                      'Try changing your filters or search term',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: emptySubtitleSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(gridPadding),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing,
                                mainAxisExtent: isSmallScreen ? 220 : (isTablet ? 280 : 250),
                              ),
                              itemCount: filteredPeople.length,
                              itemBuilder: (context, index) {
                                final person = filteredPeople[index];
                                return PersonCard(
                                  person: person,
                                  onViewProfile: () {
                                    AppRoutes.toPersonProfile(context, person);
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonCard extends StatelessWidget {
  final Map<String, dynamic> person;
  final VoidCallback onViewProfile;

  const PersonCard({
    super.key,
    required this.person,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final isOnline = person['isOnline'] ?? false;
    final isFemale = person['gender'] == 'Female';
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final cardPadding = isSmallScreen ? 8.0 : (isTablet ? 12.0 : 10.0);
    final iconSize = isSmallScreen ? 40.0 : (isTablet ? 60.0 : 50.0);
    final badgePadding = isSmallScreen 
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) 
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    final badgeIconSize = isSmallScreen ? 10.0 : 12.0;
    final badgeFontSize = isSmallScreen ? 8.0 : 10.0;
    final onlineFontSize = isSmallScreen ? 7.0 : 8.0;
    final nameFontSize = isSmallScreen ? 11.0 : (isTablet ? 14.0 : 12.0);
    final locationFontSize = isSmallScreen ? 9.0 : (isTablet ? 12.0 : 10.0);
    final priceFontSize = isSmallScreen ? 10.0 : (isTablet ? 13.0 : 11.0);
    final ratingFontSize = isSmallScreen ? 9.0 : (isTablet ? 12.0 : 10.0);
    
    return GestureDetector(
      onTap: onViewProfile,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: isFemale ? Colors.pink.shade100 : Colors.blue.shade100,
                      child: person['image'] != null && person['image'].toString().isNotEmpty
                          ? Image.network(
                              person['image'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    isFemale ? Icons.face_3 : Icons.face,
                                    size: iconSize,
                                    color: isFemale ? Colors.pink.shade300 : Colors.blue.shade300,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                isFemale ? Icons.face_3 : Icons.face,
                                size: iconSize,
                                color: isFemale ? Colors.pink.shade300 : Colors.blue.shade300,
                              ),
                            ),
                    ),
                  ),
                  
                  Positioned(
                    top: isSmallScreen ? 4 : 6,
                    left: isSmallScreen ? 4 : 6,
                    child: Container(
                      padding: badgePadding,
                      decoration: BoxDecoration(
                        color: isFemale ? Colors.pink.shade100 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isFemale ? Colors.pink.shade300 : Colors.blue.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFemale ? Icons.female : Icons.male,
                            size: badgeIconSize,
                            color: isFemale ? Colors.pink.shade600 : Colors.blue.shade600,
                          ),
                          SizedBox(width: 2),
                          Text(
                            person['gender'],
                            style: TextStyle(
                              fontSize: badgeFontSize,
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
                      top: isSmallScreen ? 4 : 6,
                      right: isSmallScreen ? 4 : 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 4 : 5, 
                          vertical: isSmallScreen ? 2 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Online',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: onlineFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: locationFontSize,
                          color: primaryColor,
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            person['location'],
                            style: TextStyle(
                              fontSize: locationFontSize,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${person['price']}/hr',
                          style: TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: ratingFontSize,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${person['rating']}',
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
