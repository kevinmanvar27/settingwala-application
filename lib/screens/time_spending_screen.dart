import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../routes/app_routes.dart';  // Add route-based navigation
import '../utils/responsive.dart';
import '../Service/subscription_service.dart';
import '../Service/time_spending_service.dart';
import '../Service/profile_service.dart';
import '../Service/location_service.dart';
import '../model/getpaymentstatusmodel.dart';
import '../model/PuttimespendingModel.dart';

class TimeSpendingScreen extends StatefulWidget {
  const TimeSpendingScreen({super.key});

  @override
  State<TimeSpendingScreen> createState() => _TimeSpendingScreenState();
}

class _TimeSpendingScreenState extends State<TimeSpendingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasSubscription = false;
  Subscription? _subscriptionDetails;
  final SubscriptionService _subscriptionService = SubscriptionService();
  final TimeSpendingService _timeSpendingService = TimeSpendingService();
  
  final TextEditingController _hourRateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  List<LocationSuggestion> _locationSuggestions = [];
  bool _isSearchingLocation = false;
  Timer? _debounceTimer;
  final FocusNode _locationFocusNode = FocusNode();
  final LayerLink _locationLayerLink = LayerLink();
  OverlayEntry? _locationOverlayEntry;
  
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  
  Map<String, bool> _availability = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  
  Map<String, Map<String, String>> _dayTimeSlots = {
    'Monday': {'start': '09:00', 'end': '17:00'},
    'Tuesday': {'start': '09:00', 'end': '17:00'},
    'Wednesday': {'start': '09:00', 'end': '17:00'},
    'Thursday': {'start': '09:00', 'end': '17:00'},
    'Friday': {'start': '09:00', 'end': '17:00'},
    'Saturday': {'start': '09:00', 'end': '17:00'},
    'Sunday': {'start': '09:00', 'end': '17:00'},
  };

  Map<String, List<String>> _timeSlots = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _locationFocusNode.addListener(_onLocationFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationFocusNode.removeListener(_onLocationFocusChange);
    _locationFocusNode.dispose();
    _removeLocationOverlay();
    _hourRateController.dispose();
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _onLocationFocusChange() {
    if (!_locationFocusNode.hasFocus) {
      _removeLocationOverlay();
    }
  }

  void _removeLocationOverlay() {
    _locationOverlayEntry?.remove();
    _locationOverlayEntry = null;
  }

  void _searchLocations(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().length < 2) {
      setState(() {
        _locationSuggestions = [];
      });
      _removeLocationOverlay();
      return;
    }

    setState(() => _isSearchingLocation = true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final suggestions = await LocationService.searchLocations(query);
        if (mounted) {
          setState(() {
            _locationSuggestions = suggestions;
            _isSearchingLocation = false;
          });
          if (suggestions.isNotEmpty) {
            _showLocationOverlay();
          } else {
            _removeLocationOverlay();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearchingLocation = false;
          });
        }
      }
    });
  }

  void _selectLocation(LocationSuggestion suggestion) {
    setState(() {
      _locationController.text = suggestion.apiValue;
      _locationSuggestions = [];
    });
    _removeLocationOverlay();
    _locationFocusNode.unfocus();
  }

  void _showLocationOverlay() {
    _removeLocationOverlay();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;

    _locationOverlayEntry = OverlayEntry(
      builder: (context) => _buildLocationOverlay(),
    );

    overlay.insert(_locationOverlayEntry!);
  }

  Widget _buildLocationOverlay() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Positioned(
      width: MediaQuery.of(context).size.width - 32,
      child: CompositedTransformFollower(
        link: _locationLayerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 60),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: colors.card,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: _isSearchingLocation
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Searching locations...',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _locationSuggestions[index];
                      return _buildSuggestionTile(suggestion, colors, primaryColor);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(LocationSuggestion suggestion, AppColorSet colors, Color primaryColor) {
    IconData icon;
    switch (suggestion.type) {
      case LocationType.city:
        icon = Icons.location_city;
        break;
      case LocationType.district:
        icon = Icons.map;
        break;
      case LocationType.landmark:
        icon = Icons.place;
        break;
      case LocationType.area:
      case LocationType.locality:
        icon = Icons.location_on;
        break;
    }

    return InkWell(
      onTap: () => _selectLocation(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.mainText,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.secondaryText,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    await _checkSubscription();
    if (_hasSubscription) {
      await _loadTimeSpendingData();
    }
  }

  Future<void> _loadTimeSpendingData() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      if (!mounted) return;
      
      
      
      
      
      if (profileData != null && profileData.success == true) {
        final user = profileData.data?.user;
        
        
        
        
        
        
        if (user != null) {
          setState(() {
            final hourlyRateValue = user.hourlyRate;
            if (hourlyRateValue != null) {
              int? rate;
              if (hourlyRateValue is int) {
                rate = hourlyRateValue;
              } else if (hourlyRateValue is double) {
                rate = hourlyRateValue.toInt();
              } else if (hourlyRateValue is String) {
                final parsed = double.tryParse(hourlyRateValue);
                rate = parsed?.toInt();
              }
              
              if (rate != null && rate > 0) {
                _hourRateController.text = rate.toString();
              } else {
                _hourRateController.text = '';
              }
            } else {
              _hourRateController.text = '';
            }
            
            _locationController.text = user.serviceLocation?.toString() ?? '';
            
            final schedule = user.availabilitySchedule;
            if (schedule != null && schedule is Map<String, dynamic>) {
              _parseAvailabilitySchedule(schedule);
            }
          });
        }
      }
    } catch (e) {
      
    }
  }

  void _parseAvailabilitySchedule(Map<String, dynamic> schedule) {
    final dayMapping = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };

    dayMapping.forEach((apiKey, displayKey) {
      final dayData = schedule[apiKey];
      if (dayData != null) {
        final isHoliday = dayData['is_holiday'] == true || dayData['is_holiday'] == 1;
        _availability[displayKey] = !isHoliday;
        
        final startTime = dayData['start_time']?.toString() ?? '09:00';
        final endTime = dayData['end_time']?.toString() ?? '17:00';
        
        _dayTimeSlots[displayKey] = {
          'start': startTime,
          'end': endTime,
        };
        
        if (!isHoliday && startTime.isNotEmpty && endTime.isNotEmpty) {
          _timeSlots[displayKey] = ['${_formatTime24To12(startTime)} - ${_formatTime24To12(endTime)}'];
        } else {
          _timeSlots[displayKey] = [];
        }
      }
    });
  }

  String _formatTime24To12(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  String _formatTime12To24(String time12) {
    try {
      final parts = time12.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final isPM = parts[1].toUpperCase() == 'PM';
      
      if (isPM && hour < 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
      
      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return time12;
    }
  }

  // Generate 30-minute interval time slots in 24-hour format
  List<String> _generate30MinuteTimeSlots() {
    List<String> slots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      }
    }
    return slots;
  }

  // Get valid end times (must be after start time)
  List<String> _getValidEndTimesForTimeSpending() {
    final allSlots = _generate30MinuteTimeSlots();
    if (_startTimeController.text.isEmpty) return allSlots;
    
    final startParts = _startTimeController.text.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    
    return allSlots.where((slot) {
      final slotParts = slot.split(':');
      final slotMinutes = int.parse(slotParts[0]) * 60 + int.parse(slotParts[1]);
      return slotMinutes > startMinutes;
    }).toList();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final currentController = isStartTime ? _startTimeController : _endTimeController;
    final List<String> timeSlots = isStartTime 
        ? _generate30MinuteTimeSlots() 
        : _getValidEndTimesForTimeSpending();
    
    // Find current selected index (no default - starts at 00:00)
    int initialIndex = 0;
    if (currentController.text.isNotEmpty) {
      final index = timeSlots.indexOf(currentController.text);
      if (index >= 0) initialIndex = index;
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final itemFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final itemHeight = isDesktop ? 50.0 : isTablet ? 45.0 : isSmallScreen ? 36.0 : 40.0;
    final wheelHeight = isDesktop ? 250.0 : isTablet ? 220.0 : isSmallScreen ? 160.0 : 180.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final buttonPaddingH = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 16.0 : 24.0;
    final buttonPaddingV = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    
    String? selectedTime;
    final scrollController = FixedExtentScrollController(initialItem: initialIndex);
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(isTablet ? 24 : 20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  // Title
                  Text(
                    isStartTime ? 'Select Start Time' : 'Select End Time',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  // Time wheel picker
                  SizedBox(
                    height: wheelHeight,
                    child: Stack(
                      children: [
                        // Center selection indicator
                        Positioned(
                          top: (wheelHeight - itemHeight) / 2,
                          left: 0,
                          right: 0,
                          height: itemHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        // Wheel scroll view
                        ListWheelScrollView.useDelegate(
                          itemExtent: itemHeight,
                          diameterRatio: 1.5,
                          perspective: 0.003,
                          physics: const FixedExtentScrollPhysics(),
                          controller: scrollController,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedTime = timeSlots[index];
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: timeSlots.length,
                            builder: (context, index) {
                              final isSelected = index == scrollController.selectedItem;
                              return Center(
                                child: Text(
                                  timeSlots[index],
                                  style: TextStyle(
                                    fontSize: isSelected ? itemFontSize + 2 : itemFontSize,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? primaryColor : colors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final finalTime = selectedTime ?? timeSlots[initialIndex];
                        Navigator.pop(context, finalTime);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        padding: EdgeInsets.symmetric(horizontal: buttonPaddingH, vertical: buttonPaddingV),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          if (isStartTime) {
            _startTimeController.text = result;
            // Reset end time if it's now invalid
            if (_endTimeController.text.isNotEmpty) {
              final validEndTimes = _getValidEndTimesForTimeSpending();
              if (!validEndTimes.contains(_endTimeController.text)) {
                _endTimeController.text = '';
              }
            }
          } else {
            _endTimeController.text = result;
          }
        });
      }
    });
  }

  Future<void> _checkSubscription() async {
    try {
      final result = await _subscriptionService.getSubscriptionStatus();
      
      if (!mounted) return;
      
      if (result != null && result.success) {
        setState(() {
          _isLoading = false;
          _hasSubscription = result.data.hasSubscription;
          _subscriptionDetails = result.data.subscription;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasSubscription = false;
        });
      }
    } catch (e) {
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasSubscription = false;
      });
    }
  }

  Future<void> _saveTimeSpending() async {
    if (!_formKey.currentState!.validate()) return;

    List<String> daysWithoutSlots = [];
    for (String day in _availability.keys) {
      if (_availability[day]! && _timeSlots[day]!.isEmpty) {
        daysWithoutSlots.add(day);
      }
    }

    if (daysWithoutSlots.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            daysWithoutSlots.length == 1
                ? '${daysWithoutSlots.first} is enabled but has no time slot. Please add at least one time slot.'
                : 'The following days are enabled but have no time slots: ${daysWithoutSlots.join(", ")}. Please add at least one time slot for each.',
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final rateText = _hourRateController.text.trim();
      final hourlyRate = (double.tryParse(rateText) ?? 0).toInt();
      
      
      
      
      

      final schedule = AvailabilitySchedule(
        monday: Day(
          startTime: _dayTimeSlots['Monday']!['start']!,
          endTime: _dayTimeSlots['Monday']!['end']!,
          isHoliday: !_availability['Monday']!,
        ),
        tuesday: Day(
          startTime: _dayTimeSlots['Tuesday']!['start']!,
          endTime: _dayTimeSlots['Tuesday']!['end']!,
          isHoliday: !_availability['Tuesday']!,
        ),
        wednesday: Day(
          startTime: _dayTimeSlots['Wednesday']!['start']!,
          endTime: _dayTimeSlots['Wednesday']!['end']!,
          isHoliday: !_availability['Wednesday']!,
        ),
        thursday: Day(
          startTime: _dayTimeSlots['Thursday']!['start']!,
          endTime: _dayTimeSlots['Thursday']!['end']!,
          isHoliday: !_availability['Thursday']!,
        ),
        friday: Day(
          startTime: _dayTimeSlots['Friday']!['start']!,
          endTime: _dayTimeSlots['Friday']!['end']!,
          isHoliday: !_availability['Friday']!,
        ),
        saturday: Day(
          startTime: _dayTimeSlots['Saturday']!['start']!,
          endTime: _dayTimeSlots['Saturday']!['end']!,
          isHoliday: !_availability['Saturday']!,
        ),
        sunday: Day(
          startTime: _dayTimeSlots['Sunday']!['start']!,
          endTime: _dayTimeSlots['Sunday']!['end']!,
          isHoliday: !_availability['Sunday']!,
        ),
      );

      final result = await _timeSpendingService.updateTimeSpending(
        hourlyRate: hourlyRate,
        serviceLocation: _locationController.text,
        availabilitySchedule: schedule,
      );

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (result != null && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty ? result.message : 'Availability settings saved!',
              style: const TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );

        AppRoutes.navigateAndClearStack(context, AppRoutes.mainNavigation);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to save settings. Please try again.',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }
    } catch (e) {
      
      if (!mounted) return;
      
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong. Please try again.',
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    return BaseScreen(
      title: 'Time & Availability',
      showBackButton: true,
      body: _isLoading 
          ? _buildLoadingWidget(colors, isSmallScreen, isTablet, isDesktop)
          : _hasSubscription 
              ? _buildTimeSpendingContent(colors, isDark, primaryColor, isSmallScreen, isTablet, isDesktop)
              : _buildSubscriptionRequiredWidget(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
    );
  }

  Widget _buildLoadingWidget(AppColorSet colors, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final indicatorSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final spacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
              strokeWidth: isSmallScreen ? 2.0 : 3.0,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            'Checking subscription status...',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRequiredWidget(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 16.0 : 24.0;
    final iconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 48.0 : 64.0;
    final titleFontSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final descFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final buttonHeight = isDesktop ? 56.0 : isTablet ? 54.0 : isSmallScreen ? 44.0 : 50.0;
    final buttonFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final buttonRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 25.0 : 30.0;
    final spacingLarge = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final spacingMedium = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final spacingXLarge = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 24.0 : 32.0;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: iconSize,
            color: primaryColor,
          ),
          SizedBox(height: spacingLarge),
          Text(
            'Subscription Required',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingMedium),
          Text(
            'You need an active subscription to access time spending features.',
            style: TextStyle(
              fontSize: descFontSize,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingXLarge),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                AppRoutes.navigateTo(context, AppRoutes.subscription);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Subscription',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpendingContent(AppColorSet colors, bool isDark, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final headerSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bottomSpacing = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 32.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_subscriptionDetails != null)
            _buildSubscriptionInfoCard(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
          SizedBox(height: sectionSpacing),
          
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Rate & Location', colors, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: headerSpacing),
                _buildRateAndLocationSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: sectionSpacing),
                
                _buildSectionHeader('Weekly Availability', colors, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: headerSpacing),
                _buildWeeklyAvailabilitySection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: bottomSpacing),
                
                _buildSaveButton(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
                SizedBox(height: sectionSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoCard(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final iconContainerPadding = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final spacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified,
              color: primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active ${_subscriptionDetails!.planName ?? 'Premium'} Subscription',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontSize: titleFontSize,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  '${(_subscriptionDetails!.daysRemaining ?? 0).toInt()} days remaining',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: subtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColorSet colors, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final fontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildRateAndLocationSection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final fieldSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    return Column(
      children: [
        _buildTextFormField(
          controller: _hourRateController,
          label: 'Hourly Rate',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixText: '₹ ',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your hourly rate';
            }
            final rate = (double.tryParse(value.trim()) ?? 0).toInt();
            if (rate < 1) {
              return 'Hourly rate must be at least ₹1';
            }
            return null;
          },
          colors: colors,
          primaryColor: primaryColor,
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SizedBox(height: fieldSpacing),
        _buildLocationField(
          colors: colors,
          primaryColor: primaryColor,
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildWeeklyAvailabilitySection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final blurRadius = isDesktop ? 7.0 : isTablet ? 6.0 : isSmallScreen ? 4.0 : 5.0;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: blurRadius,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _availability.keys.map((day) {
          return _buildDayRow(day, colors, primaryColor, isSmallScreen, isTablet, isDesktop);
        }).toList(),
      ),
    );
  }

  Widget _buildDayRow(String day, AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final verticalPadding = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final dayFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final slotFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final editFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final switchScale = isDesktop ? 1.0 : isTablet ? 0.95 : isSmallScreen ? 0.8 : 0.9;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
                fontSize: dayFontSize,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _availability[day]! 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._timeSlots[day]!.map((slot) => Text(
                        slot,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: slotFontSize,
                        ),
                      )),
                      if (_timeSlots[day]!.isEmpty)
                        Text(
                          'No time slots added (required)',
                          style: TextStyle(
                            color: AppColors.error,
                            fontStyle: FontStyle.italic,
                            fontSize: slotFontSize,
                          ),
                        ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      GestureDetector(
                        onTap: () => _showTimeSlotDialog(day, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
                        child: Text(
                          'Edit Time Slots',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: editFontSize,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Not Available',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontStyle: FontStyle.italic,
                      fontSize: slotFontSize,
                    ),
                  ),
          ),
          Transform.scale(
            scale: switchScale,
            child: Switch(
              value: _availability[day]!,
              onChanged: (value) {
                setState(() {
                  _availability[day] = value;
                  
                  if (value) {
                    _timeSlots[day] = [];
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showTimeSlotDialog(day, colors, primaryColor, isSmallScreen, isTablet, isDesktop);
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeSlotDialog(String day, AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final dialogRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final slotFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final buttonFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final buttonRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final buttonPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 8.0 : 10.0;
    final deleteIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 18.0 : 20.0;
    final spacing = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final spacingMedium = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final spacingLarge = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    _startTimeController.text = '';
    _endTimeController.text = '';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text(
            'Set Time Slots for $day', 
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: titleFontSize,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current time slots:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontSize: labelFontSize,
                  ),
                ),
                SizedBox(height: spacing),
                if (_timeSlots[day]!.isEmpty)
                  Text(
                    'No time slots added',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontStyle: FontStyle.italic,
                      fontSize: slotFontSize,
                    ),
                  )
                else
                  Column(
                    children: _timeSlots[day]!.map((slot) => Padding(
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2.0 : 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              slot, 
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: slotFontSize,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: AppColors.error, size: deleteIconSize),
                            onPressed: () {
                              setState(() {
                                _timeSlots[day]!.remove(slot);
                                if (_timeSlots[day]!.isEmpty) {
                                  _dayTimeSlots[day] = {'start': '09:00', 'end': '17:00'};
                                }
                              });
                              Navigator.pop(context);
                              _showTimeSlotDialog(day, colors, primaryColor, isSmallScreen, isTablet, isDesktop);
                            },
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                SizedBox(height: spacingLarge),
                
                Text(
                  'Add new time slot:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontSize: labelFontSize,
                  ),
                ),
                SizedBox(height: spacingMedium),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeInputField(
                        controller: _startTimeController,
                        label: 'Start Time',
                        onTap: () => _selectTime(context, true),
                        colors: colors,
                        primaryColor: primaryColor,
                        isSmallScreen: isSmallScreen,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Text(
                      'to', 
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: slotFontSize,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _buildTimeInputField(
                        controller: _endTimeController,
                        label: 'End Time',
                        onTap: () => _selectTime(context, false),
                        colors: colors,
                        primaryColor: primaryColor,
                        isSmallScreen: isSmallScreen,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacingLarge),
                
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select both start and end times',
                              style: TextStyle(color: AppColors.white),
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      
                      final String newTimeSlot = '${_startTimeController.text} - ${_endTimeController.text}';
                      setState(() {
                        _timeSlots[day]!.clear();
                        _timeSlots[day]!.add(newTimeSlot);
                        _dayTimeSlots[day] = {
                          'start': _formatTime12To24(_startTimeController.text),
                          'end': _formatTime12To24(_endTimeController.text),
                        };
                      });
                      Navigator.pop(context);
                      _showTimeSlotDialog(day, colors, primaryColor, isSmallScreen, isTablet, isDesktop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? AppColors.black : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: buttonPaddingH, vertical: buttonPaddingV),
                    ),
                    child: Text(
                      'Add Time Slot',
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: buttonFontSize,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
        );
      },
    );
  }
  
  Widget _buildTimeInputField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final labelFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final inputFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final iconSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final paddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final paddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final borderRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    final iconSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    
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
        SizedBox(height: isSmallScreen ? 2 : 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: iconSize,
                  color: primaryColor,
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: 'Select time',
                      hintStyle: TextStyle(
                        color: colors.textTertiary,
                        fontSize: inputFontSize * 0.9,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: inputFontSize,
                      color: colors.textPrimary,
                    ),
                    readOnly: true,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? prefixText,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final borderRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final blurRadius = isDesktop ? 7.0 : isTablet ? 6.0 : isSmallScreen ? 4.0 : 5.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final inputFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final paddingH = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final paddingV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: blurRadius,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: inputFontSize,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: labelFontSize,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryColor,
            size: iconSize,
          ),
          prefixText: prefixText,
          prefixStyle: TextStyle(
            color: colors.textPrimary,
            fontSize: inputFontSize,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: labelFontSize * 0.85,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  Widget _buildLocationField({
    required AppColorSet colors,
    required Color primaryColor,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final borderRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final blurRadius = isDesktop ? 7.0 : isTablet ? 6.0 : isSmallScreen ? 4.0 : 5.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final inputFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final paddingH = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final paddingV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;

    return CompositedTransformTarget(
      link: _locationLayerLink,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: blurRadius,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: _locationController,
          focusNode: _locationFocusNode,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: inputFontSize,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: 'Location',
            labelStyle: TextStyle(
              color: colors.textSecondary,
              fontSize: labelFontSize,
            ),
            hintText: 'Type city name (e.g., Rajkot)',
            hintStyle: TextStyle(
              color: colors.textTertiary,
              fontSize: inputFontSize - 2,
            ),
            prefixIcon: Icon(
              Icons.location_on,
              color: primaryColor,
              size: iconSize,
            ),
            suffixIcon: _isSearchingLocation
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  )
                : _locationController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.textTertiary, size: 20),
                        onPressed: () {
                          setState(() {
                            _locationController.clear();
                            _locationSuggestions = [];
                          });
                          _removeLocationOverlay();
                        },
                      )
                    : null,
            border: InputBorder.none,
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: labelFontSize * 0.85,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          ),
          onChanged: (value) {
            _searchLocations(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your location';
            }
            return null;
          },
        ),
      ),
    );
  }

  bool _hasValidSlots() {
    for (String day in _availability.keys) {
      if (_availability[day]! && _timeSlots[day]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  List<String> _getDaysWithoutSlots() {
    List<String> daysWithoutSlots = [];
    for (String day in _availability.keys) {
      if (_availability[day]! && _timeSlots[day]!.isEmpty) {
        daysWithoutSlots.add(day);
      }
    }
    return daysWithoutSlots;
  }

  Widget _buildSaveButton(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final buttonHeight = isDesktop ? 56.0 : isTablet ? 54.0 : isSmallScreen ? 44.0 : 50.0;
    final buttonRadius = isDesktop ? 35.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final buttonFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final errorFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    final hasValidSlots = _hasValidSlots();
    final daysWithoutSlots = _getDaysWithoutSlots();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasValidSlots && daysWithoutSlots.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error, size: isSmallScreen ? 18 : 22),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    daysWithoutSlots.length == 1
                        ? '${daysWithoutSlots.first} needs a time slot'
                        : '${daysWithoutSlots.join(", ")} need time slots',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: errorFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: (_isSaving || !hasValidSlots) ? null : () => _saveTimeSpending(),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasValidSlots ? primaryColor : colors.textTertiary,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              disabledBackgroundColor: colors.textTertiary.withOpacity(0.5),
              disabledForegroundColor: colors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.black : AppColors.white,
                      ),
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
