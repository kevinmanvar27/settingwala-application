import 'package:flutter/material.dart';

// Auth & Splash Screens
import '../splashscreen.dart';
import '../firstscreen.dart';
import '../login_screen.dart';
import '../home_screen.dart';

// Main Navigation
import '../screens/main_navigation_screen.dart';
import '../screens/home_page.dart';

// Profile Screens
import '../screens/profile.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/profile_notifications_screen.dart';
import '../screens/privacy_settings_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/user_gallery_screen.dart';

// Booking Screens
import '../screens/book_meeting_screen.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/person_bookings_screen.dart';

// Chat Screens
import '../screens/chat_list_screen.dart';
import '../screens/chat_screen.dart';

// User Discovery Screens
import '../screens/find_person_page.dart';
import '../screens/find_person_screen.dart';
import '../screens/person_profile_screen.dart';

// Review Screens
import '../screens/reviews_screen.dart';
import '../screens/person_reviews_screen.dart';

// Notification Screens
import '../screens/notifications_screen.dart';
import '../screens/notifications_list_screen.dart';

// Wallet & Subscription Screens
import '../screens/wallet_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/subscription_history_screen.dart';

// Event Screens
import '../screens/events_screen.dart';
import '../screens/event_details_screen.dart';
import '../screens/my_events_screen.dart';

// Activity Screens
import '../screens/couple_activity_screen.dart';
import '../screens/time_spending_screen.dart';
import '../screens/sugar_partner_screen.dart';
import '../screens/sugar_partner_exchanges_screen.dart';
import '../screens/sugar_partner_history_screen.dart';
import '../screens/sugar_partner_blocked_users_screen.dart';

// Dispute & Rejection Screens
import '../screens/disputes_screen.dart';
import '../screens/rejections_screen.dart';

// New Screens (APIs without UI)
import '../screens/pending_reviews_screen.dart';
import '../screens/provider_bookings_screen.dart';
import '../screens/sugar_partner_payments_screen.dart';
import '../screens/wallet_transactions_screen.dart';

// Demo & Example Screens
import '../screens/theme_demo_screen.dart';
import '../screens/example_screen.dart';
import '../screens/slider_demo_screen.dart';
import '../screens/location_map_screen.dart';
import '../screens/location_demo_screen.dart';
// Import for gallery check before Sugar Partner navigation
import '../Service/gallery_service.dart';
import '../utils/snackbar_utils.dart';


// Seven Screens (Info pages)
import '../screens/seven/About.dart';
import '../screens/seven/Journey.dart';
import '../screens/seven/Contact.dart';
import '../screens/seven/Privacypolicy.dart';
import '../screens/seven/Safety.dart';
import '../screens/seven/Termsofservice.dart';
import '../screens/seven/refand.dart';

// Services (for models)
import '../Service/event_service.dart';

/// Route Names - All route names as constants
class AppRoutes {
  // ══════════════════════════════════════════════════════════════════════════
  // ROUTE NAMES
  // ══════════════════════════════════════════════════════════════════════════
  
  // Auth & Splash
  static const String splash = '/';
  static const String firstScreen = '/first';
  static const String login = '/login';
  static const String home = '/home';
  
  // Main Navigation
  static const String mainNavigation = '/main';
  static const String homePage = '/home-page';
  
  // Profile
  static const String profile = '/profile';
  static const String profileSettings = '/profile/settings';
  static const String profileNotifications = '/profile/notifications';
  static const String privacySettings = '/privacy-settings';
  static const String gallery = '/gallery';
  static const String userGallery = '/user-gallery';
  
  // Booking
  static const String bookMeeting = '/book-meeting';
  static const String myBookings = '/my-bookings';
  static const String personBookings = '/person-bookings';
  
  // Chat
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  
  // User Discovery
  static const String findPerson = '/find-person';
  static const String findPersonPage = '/find-person-page';
  static const String personProfile = '/person-profile';
  
  // Reviews
  static const String reviews = '/reviews';
  static const String personReviews = '/person-reviews';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsList = '/notifications-list';
  
  // Wallet & Subscription
  static const String wallet = '/wallet';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  
  // Events
  static const String events = '/events';
  static const String eventDetails = '/event-details';
  static const String myEvents = '/my-events-history';
  
  // Activities
  static const String coupleActivity = '/couple-activity';
  static const String timeSpending = '/time-spending';
  static const String sugarPartner = '/sugar-partner';
  static const String sugarPartnerExchanges = '/sugar-partner-exchanges';
  static const String sugarPartnerHistory = '/sugar-partner-history';
  static const String sugarPartnerBlockedUsers = '/sugar-partner-blocked-users';
  
  // Disputes & Rejections
  static const String disputes = '/disputes';
  static const String rejections = '/rejections';
  
  // New Screens (APIs without UI)
  static const String pendingReviews = '/pending-reviews';
  static const String providerBookings = '/provider-bookings';
  static const String sugarPartnerPayments = '/sugar-partner-payments';
  static const String walletTransactions = '/wallet-transactions';
  
  // Demo & Examples
  static const String themeDemo = '/theme-demo';
  static const String example = '/example';
  static const String sliderDemo = '/slider-demo';
  static const String locationMap = '/location-map';
  static const String locationDemo = '/location-demo';

  
  // Seven Screens (Info pages)
  static const String about = '/about';
  static const String journey = '/journey';
  static const String contact = '/contact';
  static const String privacyPolicy = '/privacy-policy';
  static const String safety = '/safety';
  static const String termsOfService = '/terms-of-service';
  static const String refundPolicy = '/refund-policy';

  // ══════════════════════════════════════════════════════════════════════════
  // ROUTE MAP (for screens without required arguments)
  // ══════════════════════════════════════════════════════════════════════════
  
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const Splashscreen(),
    firstScreen: (context) => const Firstscreen(),
    login: (context) => const LoginScreen(),
    home: (context) => HomeScreen(),
    mainNavigation: (context) => MainNavigationScreen(),
    homePage: (context) => const HomePage(),
    profile: (context) => const ProfileScreen(),
    profileSettings: (context) => const ProfileSettingsScreen(),
    profileNotifications: (context) => const ProfileNotificationsScreen(),
    privacySettings: (context) => const PrivacySettingsScreen(),
    gallery: (context) => const GalleryScreen(),
    chatList: (context) => const ChatListScreen(),
    myBookings: (context) => const MyBookingsScreen(),
    notifications: (context) => const NotificationsScreen(),
    notificationsList: (context) => const NotificationsListScreen(),
    wallet: (context) => const WalletScreen(),
    subscription: (context) => const SubscriptionScreen(),
    subscriptionHistory: (context) => const SubscriptionHistoryScreen(),
    events: (context) => const EventsScreen(),
    myEvents: (context) => const MyEventsScreen(),
    coupleActivity: (context) => const CoupleActivityScreen(),
    timeSpending: (context) => const TimeSpendingScreen(),
    sugarPartner: (context) => const SugarPartnerScreen(),
    sugarPartnerExchanges: (context) => const SugarPartnerExchangesScreen(),
    sugarPartnerHistory: (context) => const SugarPartnerHistoryScreen(),
    sugarPartnerBlockedUsers: (context) => const SugarPartnerBlockedUsersScreen(),
    disputes: (context) => const DisputesScreen(),
    rejections: (context) => const RejectionsScreen(),
    reviews: (context) => const ReviewsScreen(),
    pendingReviews: (context) => const PendingReviewsScreen(),
    providerBookings: (context) => const ProviderBookingsScreen(),
    sugarPartnerPayments: (context) => const SugarPartnerPaymentsScreen(),
    walletTransactions: (context) => const WalletTransactionsScreen(),
    findPerson: (context) => const FindPersonScreen(),
    findPersonPage: (context) => const FindPersonPage(),
    themeDemo: (context) => const ThemeDemoScreen(),
    example: (context) => const ExampleScreen(),
    sliderDemo: (context) => const SliderDemoScreen(),
    locationMap: (context) => const LocationMapScreen(),
    locationDemo: (context) => const LocationDemoScreen(),

    // Seven Screens (Info pages)
    about: (context) => const AboutScreen(),
    journey: (context) => const JourneyScreen(),
    contact: (context) => const ContactScreen(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    safety: (context) => const SafetyScreen(),
    termsOfService: (context) => const TermsofServiceScreen(),
    refundPolicy: (context) => const RefundScreen(),
  };

  // ══════════════════════════════════════════════════════════════════════════
  // ROUTE GENERATOR (for screens with required arguments)
  // ══════════════════════════════════════════════════════════════════════════
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // User Gallery - requires person Map
      case userGallery:
        final person = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => UserGalleryScreen(person: person),
        );
      
      // Chat - requires profileName, profileImage, meetingTime, bookingId, otherUserId
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ChatScreen(
            profileName: args['profileName'] as String,
            profileImage: args['profileImage'] as String?,
            meetingTime: args['meetingTime'] as DateTime,
            bookingId: args['bookingId'] as int,
            otherUserId: args['otherUserId'] as int?,
          ),
        );
      
      // Book Meeting - requires person Map
      case bookMeeting:
        final person = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BookMeetingScreen(person: person),
        );
      
      // Person Profile - requires person Map
      case personProfile:
        final person = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PersonProfileScreen(person: person),
        );
      
      // Person Reviews - requires person Map
      case personReviews:
        final person = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PersonReviewsScreen(person: person),
        );
      
      // Event Details - requires EventModel
      case eventDetails:
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (context) => EventDetailsScreen(event: event),
        );
      
      // Person Bookings - requires person Map
      case personBookings:
        final person = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => PersonBookingsScreen(person: person),
        );
      
      // Location Map - optional latitude, longitude, and title
      case locationMap:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => LocationMapScreen(
            initialLatitude: args?['latitude'] as double?,
            initialLongitude: args?['longitude'] as double?,
            initialTitle: args?['title'] as String?,
          ),
        );
      


      
      default:
        // Check if route exists in simple routes map
        if (routes.containsKey(settings.name)) {
          return MaterialPageRoute(
            builder: routes[settings.name]!,
            settings: settings,
          );
        }
        // Return null for unknown routes (will show error)
        return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Navigate to a route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }
  
  /// Navigate and replace current route
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, routeName, arguments: arguments);
  }
  
  /// Navigate and clear all previous routes
  static Future<T?> navigateAndClearStack<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Go back
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
  
  // ══════════════════════════════════════════════════════════════════════════
  // TYPED NAVIGATION HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Navigate to Person Profile
  static void toPersonProfile(BuildContext context, Map<String, dynamic> person) {
    navigateTo(context, personProfile, arguments: person);
  }
  
  /// Navigate to Chat
  static Future<void> toChat(BuildContext context, {
    required String profileName,
    String? profileImage,
    required DateTime meetingTime,
    required int bookingId,
    int? otherUserId,
  }) {
    return navigateTo(context, chat, arguments: {
      'profileName': profileName,
      'profileImage': profileImage,
      'meetingTime': meetingTime,
      'bookingId': bookingId,
      'otherUserId': otherUserId,
    });
  }
  
  /// Navigate to Book Meeting
  static void toBookMeeting(BuildContext context, Map<String, dynamic> person) {
    navigateTo(context, bookMeeting, arguments: person);
  }
  
  /// Navigate to User Gallery
  static void toUserGallery(BuildContext context, Map<String, dynamic> person) {
    navigateTo(context, userGallery, arguments: person);
  }
  
  /// Navigate to Event Details
  static void toEventDetails(BuildContext context, EventModel event) {
    navigateTo(context, eventDetails, arguments: event);
  }
  
  /// Navigate to My Events (Joined Events History)
  static void toMyEvents(BuildContext context) {
    navigateTo(context, myEvents);
  }
  
  /// Navigate to Person Reviews
  static void toPersonReviews(BuildContext context, Map<String, dynamic> person) {
    navigateTo(context, personReviews, arguments: person);
  }
  
  /// Navigate to Person Bookings
  static void toPersonBookings(BuildContext context, Map<String, dynamic> person) {
    navigateTo(context, personBookings, arguments: person);
  }
  
  /// Navigate to Location Map
  static void toLocationMap(BuildContext context, {double? latitude, double? longitude, String? title}) {
    if (latitude != null && longitude != null) {
      navigateTo(context, locationMap, arguments: {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
      });
    } else {
      navigateTo(context, locationMap);
    }
  }
  
  /// Navigate to Location Demo
  static void toLocationDemo(BuildContext context) {
    navigateTo(context, locationDemo);
  }
  

  
  /// Navigate to Main Navigation (after login)
  static void toMainNavigation(BuildContext context) {
    navigateAndClearStack(context, mainNavigation);
  }
  
  /// Navigate to First Screen (after logout)
  static void toFirstScreen(BuildContext context) {
    navigateAndClearStack(context, firstScreen);
  }
  
  /// Navigate to Login
  static void toLogin(BuildContext context) {
    navigateTo(context, login);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUGAR PARTNER NAVIGATION WITH GALLERY CHECK
  // ══════════════════════════════════════════════════════════════════════════

  /// Navigate to Sugar Partner screen with gallery photo check
  /// If user has no photos in gallery, redirects to Gallery screen first
  static Future<void> toSugarPartnerWithGalleryCheck(BuildContext context) async {
    try {
      // Fetch user's gallery
      final galleryResult = await GalleryService.getGallery();
      
      // Check if gallery has at least one photo
      final hasPhotos = galleryResult?.data?.gallery?.isNotEmpty ?? false;
      
      if (hasPhotos) {
        // User has photos, navigate to Sugar Partner
        navigateTo(context, sugarPartner);
      } else {
        // No photos, show warning and redirect to Gallery
        SnackbarUtils.showWarning(
          context,
          'Sugar Partner માટે ઓછામાં ઓછો એક ફોટો જરૂરી છે। કૃપા કરીને પહેલા ગેલેરીમાં ફોટો ઉમેરો।',
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to Gallery screen
        navigateTo(context, gallery);
      }
    } catch (e) {
      // On error, show warning and navigate to gallery
      SnackbarUtils.showWarning(
        context,
        'ગેલેરી ચેક કરવામાં સમસ્યા આવી। કૃપા કરીને ફરી પ્રયાસ કરો।',
      );
      navigateTo(context, gallery);
    }
  }
}
