/// API Constants - All API endpoints centralized
/// Base URL and all endpoints for the SettingWala app
class ApiConstants {
  // ══════════════════════════════════════════════════════════════════════════
  // BASE CONFIGURATION
  // ══════════════════════════════════════════════════════════════════════════
  static const String baseUrl = 'https://settingwala.com/api/v1';
  static const String storageUrl = 'https://settingwala.com/storage';
  
  // Google OAuth
  static const String webClientId = '782697591400-9ncotmdr5fibdta2bt7udu4jd89isdgi.apps.googleusercontent.com';

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String authLogout = '$baseUrl/auth/logout';
  static const String authGoogle = '$baseUrl/auth/google';
  static const String googleLogin = '$baseUrl/auth/google';

  // ══════════════════════════════════════════════════════════════════════════
  // FCM ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String fcmToken = '$baseUrl/fcm-token';

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String profile = '$baseUrl/profile';
  static const String profileAvatar = '$baseUrl/profile/avatar';
  static const String profilePrivacySettings = '$baseUrl/profile/privacy-settings';
  static const String profileCompletionStatus = '$baseUrl/profile/completion-status';
  static const String profileTimeSpending = '$baseUrl/profile/time-spending';

  // ══════════════════════════════════════════════════════════════════════════
  // USER ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String users = '$baseUrl/users';
  static String userById(int userId) => '$baseUrl/users/$userId';
  static String userAvailability(String date) => '$baseUrl/users/availability?date=$date';
  static String userReport(int userId) => '$baseUrl/users/$userId/report';

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKING ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String bookings = '$baseUrl/bookings';
  static String bookingById(int bookingId) => '$baseUrl/bookings/$bookingId';
  static String bookingCancel(int bookingId) => '$baseUrl/bookings/$bookingId/cancel';
  static String bookingPayment(int bookingId) => '$baseUrl/bookings/$bookingId/payment';
  static String bookingVerifyPayment(int bookingId) => '$baseUrl/bookings/$bookingId/verify-payment';
  static String bookingPaymentDetails(int bookingId) => '$baseUrl/bookings/$bookingId/payment-details';

  // ══════════════════════════════════════════════════════════════════════════
  // PROVIDER BOOKING ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String providerBookings = '$baseUrl/provider/bookings';
  static const String providerBookingRequests = '$baseUrl/provider/booking-requests';
  static String providerBookingAccept(int bookingId) => '$baseUrl/provider/booking/$bookingId/accept';
  static String providerBookingReject(int bookingId) => '$baseUrl/provider/booking/$bookingId/reject';
  static String providerBookingBlock(int bookingId) => '$baseUrl/provider/booking/$bookingId/block';
  static String providerUserUnblock(int userId) => '$baseUrl/provider/user/$userId/unblock';

  // ══════════════════════════════════════════════════════════════════════════
  // MEETING VERIFICATION ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static String meetingVerificationStartPhoto(int bookingId) => '$baseUrl/meeting-verification/$bookingId/start-photo';
  static String meetingVerificationEndPhoto(int bookingId) => '$baseUrl/meeting-verification/$bookingId/end-photo';
  static String meetingVerificationStatus(int bookingId) => '$baseUrl/meeting-verification/$bookingId/status';

  // ══════════════════════════════════════════════════════════════════════════
  // GALLERY ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String gallery = '$baseUrl/gallery';
  static const String galleryUpload = '$baseUrl/gallery/upload';
  static const String galleryReorder = '$baseUrl/gallery/reorder';
  static String galleryDelete(int imageId) => '$baseUrl/gallery/$imageId';

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String chat = '$baseUrl/chat';
  static const String chatUnreadCount = '$baseUrl/chat/unread-count';
  static const String chatBlockedUsers = '$baseUrl/chat/blocked-users';
  static String chatStart(int userId) => '$baseUrl/chat/start/$userId';
  static String chatBookingMessages(int bookingId) => '$baseUrl/chat/booking/$bookingId/messages';
  static String chatBookingSend(int bookingId) => '$baseUrl/chat/booking/$bookingId/send';
  static String chatBookingMarkRead(int bookingId) => '$baseUrl/chat/booking/$bookingId/mark-read';
  static String chatMessageDelete(int messageId) => '$baseUrl/chat/message/$messageId';
  static String chatBlock(int userId) => '$baseUrl/chat/block/$userId';

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String notifications = '$baseUrl/notifications';
  static const String notificationsUnreadCount = '$baseUrl/notifications/unread-count';
  static const String notificationsMarkAllRead = '$baseUrl/notifications/mark-all-read';
  static const String notificationsClearAll = '$baseUrl/notifications/clear-all';
  static const String notificationsPreferences = '$baseUrl/notifications/preferences';
  static const String notificationsFcmToken = '$baseUrl/notifications/fcm-token';
  static String notificationMarkRead(int notificationId) => '$baseUrl/notifications/$notificationId/mark-read';
  static String notificationDelete(int notificationId) => '$baseUrl/notifications/$notificationId';

  // ══════════════════════════════════════════════════════════════════════════
  // REVIEW ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String reviews = '$baseUrl/reviews';
  static const String reviewsPending = '$baseUrl/reviews/pending';
  static const String reviewsMyReviews = '$baseUrl/reviews/my-reviews';
  static const String reviewsReceived = '$baseUrl/reviews/received';
  static String reviewsCanReview(int bookingId) => '$baseUrl/reviews/can-review/$bookingId';
  static String reviewsByUser(int userId) => '$baseUrl/reviews/user/$userId';

  // ══════════════════════════════════════════════════════════════════════════
  // WALLET ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String wallet = '$baseUrl/wallet';
  static const String walletBalance = '$baseUrl/wallet/balance';
  static const String walletTransactions = '$baseUrl/wallet/transactions';
  static const String walletGpayAccounts = '$baseUrl/wallet/gpay-accounts';
  static const String walletWithdrawGpay = '$baseUrl/wallet/withdraw/gpay';
  static String walletGpayAccountById(int accountId) => '$baseUrl/wallet/gpay-accounts/$accountId';

  // ══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String subscriptionPlans = '$baseUrl/subscription-plans';
  static const String subscriptionPurchase = '$baseUrl/subscription/purchase';
  static const String subscriptionVerifyPayment = '$baseUrl/subscription/verify-payment';
  static const String subscriptionStatus = '$baseUrl/subscription/status';

  // ══════════════════════════════════════════════════════════════════════════
  // EVENT ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String events = '$baseUrl/events';
  static String eventById(int eventId) => '$baseUrl/events/$eventId';
  static String eventJoin(int eventId) => '$baseUrl/events/$eventId/join';

  // ══════════════════════════════════════════════════════════════════════════
  // DISPUTE ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String disputes = '$baseUrl/disputes';
  static const String disputesRaise = '$baseUrl/disputes/raise';
  static String disputeDetails(int bookingId) => '$baseUrl/disputes/$bookingId/details';
  static String disputeMessage(int disputeId) => '$baseUrl/disputes/$disputeId/message';
  static String disputeCancel(int disputeId) => '$baseUrl/disputes/$disputeId/cancel';

  // ══════════════════════════════════════════════════════════════════════════
  // SUGAR PARTNER ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String sugarPartnerExchanges = '$baseUrl/sugar-partner/exchanges';
  static const String sugarPartnerPendingCount = '$baseUrl/sugar-partner/pending-count';
  static const String sugarPartnerHistory = '$baseUrl/sugar-partner/history';
  static const String sugarPartnerHardRejects = '$baseUrl/sugar-partner/hard-rejects';
  static const String sugarPartnerPayments = '$baseUrl/sugar-partner/payments';
  static String sugarPartnerExchangeById(int exchangeId) => '$baseUrl/sugar-partner/exchange/$exchangeId';
  static String sugarPartnerExchangeViewProfiles(int exchangeId) => '$baseUrl/sugar-partner/exchange/$exchangeId/view-profiles';
  static String sugarPartnerExchangeRespond(int exchangeId) => '$baseUrl/sugar-partner/exchange/$exchangeId/respond';
  static String sugarPartnerExchangePayment(int exchangeId) => '$baseUrl/sugar-partner/exchange/$exchangeId/payment';
  static String sugarPartnerHardReject(int userId) => '$baseUrl/sugar-partner/hard-reject/$userId';

  // ══════════════════════════════════════════════════════════════════════════
  // COUPLE ACTIVITY ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String coupleActivityRequests = '$baseUrl/couple-activity/requests';
  static const String coupleActivityRequest = '$baseUrl/couple-activity/request';
  static String coupleActivityRequestAccept(int requestId) => '$baseUrl/couple-activity/request/$requestId/accept';
  static String coupleActivityRequestReject(int requestId) => '$baseUrl/couple-activity/request/$requestId/reject';
  static String coupleActivityRequestCancel(int requestId) => '$baseUrl/couple-activity/request/$requestId';

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCKED USERS ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String blockedUsers = '$baseUrl/blocked-users';

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  
  /// Get full storage URL for images
  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    // Already a full URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Clean the path
    String cleanPath = path;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.substring(8);
    }
    
    return '$storageUrl/$cleanPath';
  }

  /// Add pagination query params
  static String withPagination(String url, {int page = 1, int perPage = 15}) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}page=$page&per_page=$perPage';
  }
}
