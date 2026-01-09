import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:settingwala/Service/fcm_service.dart';
import 'package:settingwala/utils/permission_helper.dart';
import 'package:settingwala/providers/chat_icon_provider.dart';
import 'package:settingwala/providers/notification_provider.dart';
import 'firebase_options.dart';
import 'firstscreen.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FcmService().initialize();

  await PermissionHelper.requestAllAppPermissions();

  // Wrap with DevicePreview if needed
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeNotifier _themeNotifier;
  late final ChatIconNotifier _chatIconNotifier;
  late final NotificationNotifier _notificationNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
    _chatIconNotifier = ChatIconNotifier();
    _notificationNotifier = NotificationNotifier();
    
    // Connect FCM service to notification provider for real-time badge updates
    FcmService().onForegroundMessage = (message) {
      // Increment notification count when new notification arrives
      _notificationNotifier.incrementCount();
    };
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    _chatIconNotifier.dispose();
    _notificationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _themeNotifier,
      child: ChatIconProvider(
        notifier: _chatIconNotifier,
        child: NotificationProvider(
          notifier: _notificationNotifier,
          child: AnimatedBuilder(
            animation: _themeNotifier,
            builder: (context, child) {
              return MaterialApp(
                title: 'SettingWala',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: _themeNotifier.materialThemeMode,
                // Use initialRoute instead of home when using routes
                initialRoute: AppRoutes.splash,
                routes: AppRoutes.routes,
                onGenerateRoute: AppRoutes.onGenerateRoute,
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }
        return const Firstscreen();
      },
    );
  }
}
