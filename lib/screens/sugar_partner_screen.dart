import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/sugar_partner_service.dart';
import '../routes/app_routes.dart';

class SugarPartnerScreen extends StatefulWidget {
  const SugarPartnerScreen({super.key});

  @override
  State<SugarPartnerScreen> createState() => _SugarPartnerScreenState();
}

class _SugarPartnerScreenState extends State<SugarPartnerScreen> {
  String? _whatIAm;
  
  final Set<String> _whatIWant = {};
  
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _expectationsController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {

    
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _whatIAm = prefs.getString('sugar_partner_what_i_am');
      
      final savedWhatIWant = prefs.getStringList('sugar_partner_what_i_want');
      if (savedWhatIWant != null) {
        _whatIWant.addAll(savedWhatIWant);
      }
      
      _bioController.text = prefs.getString('sugar_partner_bio') ?? '';
      _expectationsController.text = prefs.getString('sugar_partner_expectations') ?? '';
    });
    
    
    
    
    try {
      final response = await SugarPartnerService.getPreferences();
      if (response.success && mounted) {
        setState(() {
          if (response.whatIAm != null) _whatIAm = response.whatIAm;
          if (response.whatIWant != null) {
            _whatIWant.clear();
            _whatIWant.addAll(response.whatIWant!);
          }
          if (response.bio != null) _bioController.text = response.bio!;
          if (response.expectations != null) _expectationsController.text = response.expectations!;
        });
        
        await _saveToPrefs();
      }
    } catch (e) {
      
    }
    

  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_whatIAm != null) {
      await prefs.setString('sugar_partner_what_i_am', _whatIAm!);
    }
    await prefs.setStringList('sugar_partner_what_i_want', _whatIWant.toList());
    await prefs.setString('sugar_partner_bio', _bioController.text);
    await prefs.setString('sugar_partner_expectations', _expectationsController.text);
  }

  final List<String> _whatIAmOptions = [
    'I am Sugar Boy',
    'I am Sugar Baby',
    'I am Sugar Mummy',
    'I am Sugar Daddy',
  ];

  final List<String> _whatIWantOptions = [
    'I want Sugar Daddy',
    'I want Sugar Mummy',
    'I want Sugar Baby',
    'I want Sugar Boy',
  ];

  List<String> get _filteredWhatIWantOptions {
    if (_whatIAm == null) return _whatIWantOptions;
    
    final Map<String, String> excludeMap = {
      'I am Sugar Boy': 'I want Sugar Boy',
      'I am Sugar Baby': 'I want Sugar Baby',
      'I am Sugar Mummy': 'I want Sugar Mummy',
      'I am Sugar Daddy': 'I want Sugar Daddy',
    };
    
    final excludeOption = excludeMap[_whatIAm];
    return _whatIWantOptions.where((option) => option != excludeOption).toList();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _expectationsController.dispose();
    super.dispose();
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
    
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final headerSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final bottomSpacing = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 32.0;
    
    return BaseScreen(
      title: 'Sugar Partner',
      showBackButton: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: sectionSpacing),

            _buildSectionTitle('Relationship Preferences', Icons.favorite, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: headerSpacing),

            _buildWhatIAmSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0),

            _buildWhatIWantSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: sectionSpacing),

            _buildSectionTitle('Profile Bio', Icons.edit_note, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
            _buildBioSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: sectionSpacing),

            _buildSectionTitle('Expectations & Boundaries', Icons.handshake, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
            _buildExpectationsSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: bottomSpacing),

            _buildSaveButton(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
            
            _buildViewExchangesButton(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: sectionSpacing),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 250 : 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 14.0 : 20.0;
    final cardRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final blurRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final iconSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 24.0 : 32.0;
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final subtitleFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 11.0 : 13.0;
    final spacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: blurRadius,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerPadding),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: isDark ? AppColors.black : AppColors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sugar Partner Settings',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.black : AppColors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  'Define your relationship preferences and find your perfect match',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final iconContainerPadding = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final iconContainerRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final spacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconContainerPadding),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(iconContainerRadius),
          ),
          child: Icon(icon, color: primaryColor, size: iconSize),
        ),
        SizedBox(width: spacing),
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatIAmSection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final blurRadius = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final dropdownPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final dropdownRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final dropdownIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 18.0 : 20.0;
    final optionIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final optionFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    final optionSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What I Am',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            'Select your role in the relationship',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: dropdownPaddingH),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(dropdownRadius),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _whatIAm,
                dropdownColor: colors.card,
                hint: Text(
                  'Select your role',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: optionFontSize,
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: primaryColor, size: dropdownIconSize),
                items: _whatIAmOptions.map((option) {
                  final isSelected = option == _whatIAm;
                  IconData icon;
                  Color color;
                  
                  switch (option) {
                    case 'I am Sugar Boy':
                      icon = Icons.face;
                      color = Colors.blue;
                      break;
                    case 'I am Sugar Baby':
                      icon = Icons.face_3;
                      color = Colors.pink;
                      break;
                    case 'I am Sugar Mummy':
                      icon = Icons.face_3;
                      color = Colors.purple;
                      break;
                    case 'I am Sugar Daddy':
                      icon = Icons.face;
                      color = Colors.indigo;
                      break;
                    default:
                      icon = Icons.person;
                      color = colors.textTertiary;
                  }
                  
                  return DropdownMenuItem(
                    value: option,
                    child: Row(
                      children: [
                        Icon(icon, size: optionIconSize, color: color),
                        SizedBox(width: optionSpacing),
                        Text(
                          option, 
                          style: TextStyle(
                            fontSize: optionFontSize,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? colors.textPrimary : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _whatIAm = value;
                    final excludeMap = {
                      'I am Sugar Boy': 'I want Sugar Boy',
                      'I am Sugar Baby': 'I want Sugar Baby',
                      'I am Sugar Mummy': 'I want Sugar Mummy',
                      'I am Sugar Daddy': 'I want Sugar Daddy',
                    };
                    final excludeOption = excludeMap[value];
                    if (excludeOption != null) {
                      _whatIWant.remove(excludeOption);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIWantSection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final blurRadius = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final optionRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final optionMargin = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final optionIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final optionFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    final optionSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final checkboxPaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final checkboxPaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    final warningPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final warningRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final warningIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final warningFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What I Want',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            'Select what you are looking for (multiple selection allowed)',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
          ..._filteredWhatIWantOptions.map((option) {
            IconData icon;
            Color color;
            
            switch (option) {
              case 'I want Sugar Daddy':
                icon = Icons.face;
                color = Colors.indigo;
                break;
              case 'I want Sugar Mummy':
                icon = Icons.face_3;
                color = Colors.purple;
                break;
              case 'I want Sugar Baby':
                icon = Icons.face_3;
                color = Colors.pink;
                break;
              case 'I want Sugar Boy':
                icon = Icons.face;
                color = Colors.blue;
                break;
              default:
                icon = Icons.person;
                color = colors.textTertiary;
            }
            
            final isSelected = _whatIWant.contains(option);
            
            return Container(
              margin: EdgeInsets.only(bottom: optionMargin),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.1) : colors.background,
                borderRadius: BorderRadius.circular(optionRadius),
                border: Border.all(
                  color: isSelected ? primaryColor.withOpacity(0.5) : colors.divider,
                ),
              ),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _whatIWant.add(option);
                    } else {
                      _whatIWant.remove(option);
                    }
                  });
                },
                title: Row(
                  children: [
                    Icon(icon, size: optionIconSize, color: color),
                    SizedBox(width: optionSpacing),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: optionFontSize,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? colors.textPrimary : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                activeColor: primaryColor,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: checkboxPaddingH, vertical: checkboxPaddingV),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(optionRadius),
                ),
              ),
            );
          }),
          if (_whatIAm == null)
            Container(
              padding: EdgeInsets.all(warningPadding),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(warningRadius),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: warningIconSize),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      'Please select "What I Am" first to see available options',
                      style: TextStyle(
                        fontSize: warningFontSize,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBioSection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final blurRadius = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final inputFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final inputRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final inputPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: labelFontSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
          TextFormField(
            controller: _bioController,
            enabled: true,
            readOnly: false,
            autofocus: false,
            maxLines: isSmallScreen ? 3 : 4,
            minLines: 2,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: inputFontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Write a brief description about yourself, your interests, and what makes you unique...',
              hintStyle: TextStyle(
                color: colors.textTertiary, 
                fontSize: hintFontSize,
              ),
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.all(inputPadding),
              counterStyle: TextStyle(
                color: colors.textTertiary,
                fontSize: isSmallScreen ? 10.0 : 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationsSection(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final blurRadius = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final inputFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final hintFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final inputRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final inputPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your expectations and boundaries?',
            style: TextStyle(
              fontSize: labelFontSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
          TextFormField(
            controller: _expectationsController,
            enabled: true,
            readOnly: false,
            autofocus: false,
            maxLines: isSmallScreen ? 3 : 4,
            minLines: 2,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: inputFontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Describe what you expect from a relationship, your boundaries, and any specific requirements...',
              hintStyle: TextStyle(
                color: colors.textTertiary, 
                fontSize: hintFontSize,
              ),
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(inputRadius),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.all(inputPadding),
              counterStyle: TextStyle(
                color: colors.textTertiary,
                fontSize: isSmallScreen ? 10.0 : 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final buttonPaddingV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final buttonIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final buttonSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => _saveSettings(isSmallScreen, isTablet, isDesktop),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          disabledBackgroundColor: primaryColor.withOpacity(0.6),
          padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 2,
        ),
        child: _isSaving
          ? SizedBox(
              height: buttonIconSize,
              width: buttonIconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.black : AppColors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: buttonIconSize),
                SizedBox(width: buttonSpacing),
                Text(
                  'Save Sugar Partner Settings',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildViewExchangesButton(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final buttonPaddingV = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final buttonRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final buttonIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final buttonSpacing = isDesktop ? 10.0 : isTablet ? 8.0 : isSmallScreen ? 4.0 : 6.0;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.sugarPartnerExchanges);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: buttonIconSize),
            SizedBox(width: buttonSpacing),
            Text(
              'View My Exchanges',
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings(bool isSmallScreen, bool isTablet, bool isDesktop) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final dialogTitleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : isSmallScreen ? 16.0 : 18.0;
    final dialogContentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final dialogIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final dialogButtonRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final dialogButtonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final snackbarRadius = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 8.0 : 10.0;
    final snackbarFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    
    if (_whatIAm == null) {
      _showSnackBar('Please select "What I Am"', AppColors.warning, colors, snackbarRadius, snackbarFontSize);
      return;
    }
    
    if (_whatIWant.isEmpty) {
      _showSnackBar('Please select at least one option in "What I Want"', AppColors.warning, colors, snackbarRadius, snackbarFontSize);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink, size: dialogIconSize),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'Save Settings', 
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: dialogTitleFontSize,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Sugar Partner preferences:', 
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: dialogContentFontSize,
              ),
            ),
            SizedBox(height: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
            _buildSummaryItem('Role', _whatIAm!, colors, dialogContentFontSize),
            _buildSummaryItem('Looking for', _whatIWant.join(', '), colors, dialogContentFontSize),
            if (_bioController.text.isNotEmpty)
              _buildSummaryItem('Bio', '${_bioController.text.substring(0, _bioController.text.length > 50 ? 50 : _bioController.text.length)}...', colors, dialogContentFontSize),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel', 
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: dialogButtonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _savePreferencesToApi(colors, snackbarRadius, snackbarFontSize);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogButtonRadius)),
            ),
            child: Text(
              'Save',
              style: TextStyle(fontSize: dialogButtonFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferencesToApi(AppColorSet colors, double snackbarRadius, double snackbarFontSize) async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      await _saveToPrefs();
      
      final response = await SugarPartnerService.updatePreferences(
        whatIAm: _whatIAm!,
        whatIWant: _whatIWant.toList(),
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        expectations: _expectationsController.text.isNotEmpty ? _expectationsController.text : null,
      );
      
      if (response.success) {
        _showSnackBar('Sugar Partner settings saved successfully!', AppColors.success, colors, snackbarRadius, snackbarFontSize);
      } else {
        _showSnackBar(response.message.isNotEmpty ? response.message : 'Failed to save settings', AppColors.error, colors, snackbarRadius, snackbarFontSize);
      }
    } catch (e) {
      _showSnackBar('Failed to save settings. Please try again.', AppColors.error, colors, snackbarRadius, snackbarFontSize);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSummaryItem(String label, String value, AppColorSet colors, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: fontSize * 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: colors.textPrimary,
              fontSize: fontSize,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color, AppColorSet colors, double radius, double fontSize) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: TextStyle(
            color: AppColors.white,
            fontSize: fontSize,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
