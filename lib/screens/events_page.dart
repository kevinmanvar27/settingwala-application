// import 'package:flutter/material.dart';
// import 'event_details_screen.dart';
// import '../theme/app_colors.dart';

// class EventsPage extends StatefulWidget {
//   const EventsPage({super.key});

//   @override
//   State<EventsPage> createState() => _EventsPageState();
// }

// class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOut,
//       ),
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
//     // Responsive breakpoints
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
//     final isTablet = screenWidth >= 600;
//     final isDesktop = screenWidth >= 1024;
    
//     // Responsive padding
//     final screenPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
//     final sectionSpacing = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
//     // Responsive search bar
//     final searchBarPaddingH = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
//     final searchBarRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
//     final searchHintSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
//     final searchIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    
//     // Grid columns for tablet/desktop
//     final gridCrossAxisCount = isDesktop ? 3 : isTablet ? 2 : 1;
//     final useGrid = isTablet || isDesktop;
//     final gridSpacing = isDesktop ? 20.0 : isTablet ? 16.0 : 16.0;
    
//     // For desktop/tablet, use a max width container
//     final maxContentWidth = isDesktop ? 1200.0 : isTablet ? 900.0 : double.infinity;
    
//     return Scaffold(
//       backgroundColor: colors.background,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: Container(
//             constraints: BoxConstraints(maxWidth: maxContentWidth),
//             padding: EdgeInsets.all(screenPadding),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Search Bar
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: searchBarPaddingH),
//                     decoration: BoxDecoration(
//                       color: colors.surface,
//                       borderRadius: BorderRadius.circular(searchBarRadius),
//                       border: Border.all(color: colors.border),
//                     ),
//                     child: TextField(
//                       style: TextStyle(fontSize: searchHintSize),
//                       decoration: InputDecoration(
//                         hintText: 'Search events...',
//                         hintStyle: TextStyle(color: colors.textTertiary, fontSize: searchHintSize),
//                         prefixIcon: Icon(Icons.search, color: colors.textTertiary, size: searchIconSize),
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: sectionSpacing),

//                   // Available Events Header
//                   _buildAvailableEventsHeader(context, colors, primaryColor),
//                   SizedBox(height: sectionSpacing * 0.8),
                  
//                   // Events List or Grid
//                   useGrid
//                       ? GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: gridCrossAxisCount,
//                             crossAxisSpacing: gridSpacing,
//                             mainAxisSpacing: gridSpacing,
//                             childAspectRatio: isDesktop ? 1.6 : 1.5,
//                           ),
//                           itemCount: 10,
//                           itemBuilder: (context, index) => _buildEventCard(context, index, colors, primaryColor, isDark),
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: 10,
//                           itemBuilder: (context, index) => _buildEventCard(context, index, colors, primaryColor, isDark),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEventCard(BuildContext context, int index, AppColorSet colors, Color primaryColor, bool isDark) {
//     // Responsive breakpoints
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
//     final isTablet = screenWidth >= 600;
//     final isDesktop = screenWidth >= 1024;
    
//     // Responsive card values
//     final cardMarginBottom = isDesktop ? 0.0 : isTablet ? 0.0 : isSmallScreen ? 12.0 : 16.0;
//     final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
//     // Responsive date box
//     final dateBoxWidth = isDesktop ? 120.0 : isTablet ? 110.0 : isSmallScreen ? 80.0 : 100.0;
//     final dateBoxHeight = isDesktop ? 120.0 : isTablet ? 110.0 : isSmallScreen ? 80.0 : 100.0;
//     final dateDaySize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
//     final dateMonthSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
//     // Responsive content
//     final contentPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
//     final titleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
//     final infoTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
//     final infoIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
//     final infoIconSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
//     final infoRowSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
//     final titleInfoSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
//     final buttonSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
    
//     // Responsive button
//     final buttonRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
//     final buttonPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
//     final buttonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
//     final eventNames = ['Coffee Meetup', 'Sports Day', 'Movie Night', 'Music Festival', 'Dinner Party'];
//     final eventLocations = ['Central Park', 'Sports Club', 'City Cinema', 'Beach Arena', 'Luxury Restaurant'];
//     final eventName = eventNames[index % 5];
//     final eventLocation = eventLocations[index % 5];
//     final eventDate = '${18 + index} DEC';
//     final eventTime = '${6 + (index % 12)}:00 ${(index % 12) < 6 ? 'PM' : 'AM'}';
    
//     return Card(
//       margin: EdgeInsets.only(bottom: cardMarginBottom),
//       elevation: 2,
//       color: colors.card,
//       shadowColor: primaryColor.withOpacity(0.2),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(cardRadius),
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 Container(
//                   width: dateBoxWidth,
//                   height: dateBoxHeight,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(cardRadius),
//                       bottomLeft: Radius.circular(cardRadius),
//                     ),
//                     border: Border.all(color: primaryColor.withOpacity(0.3)),
//                   ),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${18 + index}',
//                           style: TextStyle(
//                             fontSize: dateDaySize,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? AppColors.black : AppColors.white,
//                           ),
//                         ),
//                         Text(
//                           'DEC',
//                           style: TextStyle(
//                             fontSize: dateMonthSize,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? AppColors.black : AppColors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.all(contentPadding),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           eventName,
//                           style: TextStyle(
//                             fontSize: titleSize,
//                             fontWeight: FontWeight.bold,
//                             color: colors.textPrimary,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: titleInfoSpacing),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: infoIconSize,
//                               color: colors.textTertiary,
//                             ),
//                             SizedBox(width: infoIconSpacing),
//                             Text(
//                               eventTime,
//                               style: TextStyle(
//                                 fontSize: infoTextSize,
//                                 color: colors.textTertiary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: infoRowSpacing),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               size: infoIconSize,
//                               color: colors.textTertiary,
//                             ),
//                             SizedBox(width: infoIconSpacing),
//                             Expanded(
//                               child: Text(
//                                 eventLocation,
//                                 style: TextStyle(
//                                   fontSize: infoTextSize,
//                                   color: colors.textTertiary,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: buttonSpacing),
//                         // Join Event Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EventDetailsScreen(
//                                     eventName: eventName,
//                                     eventDate: eventDate,
//                                     eventTime: eventTime,
//                                     eventLocation: eventLocation,
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: isDark ? AppColors.black : AppColors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(buttonRadius),
//                               ),
//                               padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
//                             ),
//                             child: Text(
//                               'Join Event',
//                               style: TextStyle(
//                                 fontSize: buttonTextSize,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAvailableEventsHeader(BuildContext context, AppColorSet colors, Color primaryColor) {
//     // Responsive breakpoints
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
//     final isTablet = screenWidth >= 600;
//     final isDesktop = screenWidth >= 1024;
    
//     // Responsive header values
//     final headerPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
//     final headerRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
//     // Responsive typography
//     final titleSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
//     final subtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
//     final titleSubtitleSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
//     final subtitleBadgeSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
//     final badgeRowSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
//     final badgeSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
    
//     return Container(
//       padding: EdgeInsets.all(headerPadding),
//       decoration: BoxDecoration(
//         color: colors.card,
//         borderRadius: BorderRadius.circular(headerRadius),
//         border: Border.all(color: primaryColor.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Available Events',
//             style: TextStyle(
//               fontSize: titleSize,
//               fontWeight: FontWeight.bold,
//               color: colors.textPrimary,
//             ),
//           ),
//           SizedBox(height: titleSubtitleSpacing),
//           Text(
//             'Choose from our carefully curated events and start your journey to meaningful connections',
//             style: TextStyle(
//               fontSize: subtitleSize,
//               color: colors.textSecondary,
//             ),
//           ),
//           SizedBox(height: subtitleBadgeSpacing),
//           Wrap(
//             spacing: badgeSpacing,
//             runSpacing: badgeRowSpacing,
//             children: [
//               _buildFeatureBadge(context, Icons.verified, 'Verified Events', colors, primaryColor),
//               _buildFeatureBadge(context, Icons.people, 'Like-minded People', colors, primaryColor),
//               _buildFeatureBadge(context, Icons.security, 'Safe Environment', colors, primaryColor),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureBadge(BuildContext context, IconData icon, String text, AppColorSet colors, Color primaryColor) {
//     // Responsive breakpoints
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
//     final isTablet = screenWidth >= 600;
//     final isDesktop = screenWidth >= 1024;
    
//     // Responsive badge values
//     final badgePaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
//     final badgePaddingV = isDesktop ? 10.0 : isTablet ? 8.0 : isSmallScreen ? 4.0 : 6.0;
//     final badgeRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
//     final badgeIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
//     final badgeTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
//     final iconTextSpacing = isDesktop ? 8.0 : isTablet ? 7.0 : isSmallScreen ? 4.0 : 6.0;
    
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
//       decoration: BoxDecoration(
//         color: primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(badgeRadius),
//         border: Border.all(color: primaryColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: badgeIconSize,
//             color: primaryColor,
//           ),
//           SizedBox(width: iconTextSpacing),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: badgeTextSize,
//               fontWeight: FontWeight.w500,
//               color: primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }