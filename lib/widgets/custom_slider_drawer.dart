// import 'package:flutter/material.dart';
// // Commenting out the problematic import temporarily
// // import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screens/profile.dart';
// import '../screens/profile_settings_screen.dart';
// import '../screens/my_bookings_screen.dart';
// import '../screens/wallet_screen.dart';
// import '../screens/rejections_screen.dart';
// import '../theme/app_colors.dart';
// import '../widgets/theme_toggle.dart';
//
// // Temporarily replacing SliderDrawer with a standard Drawer implementation
// class CustomSliderDrawer extends StatefulWidget {
//   final Widget child;
//   final String title;
//
//   const CustomSliderDrawer({
//     super.key,
//     required this.child,
//     this.title = 'SettingWala',
//   });
//
//   @override
//   State<CustomSliderDrawer> createState() => _CustomSliderDrawerState();
// }
//
// class _CustomSliderDrawerState extends State<CustomSliderDrawer> {
//   // Using standard ScaffoldKey instead of SliderDrawerState
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // Get current user info
//   String get _userName {
//     final user = FirebaseAuth.instance.currentUser;
//     return user?.displayName ?? 'User';
//   }
//
//   String get _userEmail {
//     final user = FirebaseAuth.instance.currentUser;
//     return user?.email ?? 'user@example.com';
//   }
//
//   String? get _userPhotoUrl {
//     final user = FirebaseAuth.instance.currentUser;
//     return user?.photoURL;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
//
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: colors.card,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: _userPhotoUrl != null
//                 ? CircleAvatar(
//                     backgroundImage: NetworkImage(_userPhotoUrl!),
//                     radius: 16,
//                   )
//                 : CircleAvatar(
//                     backgroundColor: colors.card,
//                     radius: 16,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: primaryColor.withOpacity(0.3)),
//                       ),
//                       child: Icon(
//                         Icons.person,
//                         size: 20,
//                         color: primaryColor,
//                       ),
//                     ),
//                   ),
//             onPressed: () {
//               _scaffoldKey.currentState?.openDrawer();
//             },
//           ),
//         ],
//       ),
//       drawer: _buildDrawerContent(colors, primaryColor),
//       body: widget.child,
//     );
//   }
//
//   Widget _buildDrawerContent(AppColorSet colors, Color primaryColor) {
//     return Drawer(
//       backgroundColor: colors.background,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // Drawer Header with User Info
//           UserAccountsDrawerHeader(
//             decoration: BoxDecoration(
//               color: colors.card,
//               border: Border(
//                 bottom: BorderSide(
//                   color: primaryColor.withOpacity(0.3),
//                   width: 1.0,
//                 ),
//               ),
//             ),
//             accountName: Text(
//               _userName,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: colors.textPrimary,
//               ),
//             ),
//             accountEmail: Text(
//               _userEmail,
//               style: TextStyle(
//                 color: colors.textSecondary,
//               ),
//             ),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: colors.card,
//               child: _userPhotoUrl != null
//                   ? CircleAvatar(
//                       backgroundImage: NetworkImage(_userPhotoUrl!),
//                       radius: 36,
//                     )
//                   : Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: primaryColor.withOpacity(0.3),
//                           width: 2,
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.person,
//                         size: 40,
//                         color: primaryColor,
//                       ),
//                     ),
//             ),
//           ),
//
//           // My Profile
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.account_circle,
//             title: 'My Profile',
//             colors: colors,
//             primaryColor: primaryColor,
//             onTap: () {
//               Navigator.pop(context); // Close drawer
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ProfileScreen(),
//                 ),
//               );
//             },
//           ),
//
//           // My Bookings
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.calendar_today,
//             title: 'My Bookings',
//             colors: colors,
//             primaryColor: primaryColor,
//             onTap: () {
//               Navigator.pop(context); // Close drawer
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const MyBookingsScreen(),
//                 ),
//               );
//             },
//           ),
//
//           // Wallet
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.account_balance_wallet,
//             title: 'Wallet',
//             colors: colors,
//             primaryColor: primaryColor,
//             onTap: () {
//               Navigator.pop(context); // Close drawer
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const WalletScreen(),
//                 ),
//               );
//             },
//           ),
//
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.block,
//             title: 'Manage Rejections',
//             colors: colors,
//             primaryColor: primaryColor,
//             onTap: () {
//               Navigator.pop(context); // Close drawer
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const RejectionsScreen(),
//                 ),
//               );
//             },
//           ),
//
//           // Theme Toggle
//           _buildThemeToggleItem(context, colors, primaryColor),
//
//           const Divider(),
//
//           // Sign Out
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.logout,
//             title: 'Sign Out',
//             colors: colors,
//             primaryColor: primaryColor,
//             isDestructive: true,
//             onTap: () async {
//               Navigator.pop(context); // Close drawer
//               _showSignOutDialog(context, colors, primaryColor);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required AppColorSet colors,
//     required Color primaryColor,
//     required VoidCallback onTap,
//     bool isDestructive = false,
//   }) {
//     final itemColor = isDestructive ? AppColors.error : primaryColor;
//     final textColor = isDestructive ? AppColors.error : colors.textPrimary;
//
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: itemColor.withOpacity(0.1),
//           shape: BoxShape.circle,
//           border: Border.all(color: itemColor.withOpacity(0.3)),
//         ),
//         child: Icon(
//           icon,
//           color: itemColor,
//         ),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(color: textColor),
//       ),
//       onTap: onTap,
//     );
//   }
//
//   Widget _buildThemeToggleItem(BuildContext context, AppColorSet colors, Color primaryColor) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: primaryColor.withOpacity(0.1),
//           shape: BoxShape.circle,
//           border: Border.all(color: primaryColor.withOpacity(0.3)),
//         ),
//         child: Icon(
//           isDark ? Icons.dark_mode : Icons.light_mode,
//           color: primaryColor,
//         ),
//       ),
//       title: Text(
//         'Theme Mode',
//         style: TextStyle(color: colors.textPrimary),
//       ),
//       subtitle: Text(
//         isDark ? 'Dark Mode' : 'Light Mode',
//         style: TextStyle(color: colors.textSecondary),
//       ),
//       trailing: ThemeToggle(showLabel: false),
//       onTap: () => _showThemeBottomSheet(context),
//     );
//   }
//
//   void _showThemeBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 16),
//             Text(
//               'Choose Theme',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             ThemeToggle.segmented(),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showSignOutDialog(BuildContext context, AppColorSet colors, Color primaryColor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: colors.card,
//           title: Text(
//             'Sign Out',
//             style: TextStyle(color: colors.textPrimary),
//           ),
//           content: Text(
//             'Are you sure you want to sign out?',
//             style: TextStyle(color: colors.textSecondary),
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: primaryColor),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 try {
//                   await FirebaseAuth.instance.signOut();
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error signing out: $e'),
//                       backgroundColor: AppColors.error,
//                     ),
//                   );
//                 }
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.error,
//               ),
//               child: const Text('Sign Out'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }