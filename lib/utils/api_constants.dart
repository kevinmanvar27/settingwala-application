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
  static const String authRegister = '$baseUrl/auth/register';
  static const String authLogin = '$baseUrl/auth/login';
  static const String authLogout = '$baseUrl/auth/logout';
  static const String authGoogle = '$baseUrl/auth/google';
  // Alias for backward compatibility
  static const String googleLogin = authGoogle;
  static const String authForgotPassword = '$baseUrl/auth/forgot-password';
  static const String authResetPassword = '$baseUrl/auth/reset-password';
  static const String authVerifyOtp = '$baseUrl/auth/verify-otp';
  static const String authResendOtp = '$baseUrl/auth/resend-otp';
  static const String authRefreshToken = '$baseUrl/auth/refresh-token';
  static const String authDeleteAccount = '$baseUrl/auth/delete-account';
  static const String appSettings = '$baseUrl/app-settings';

  // ══════════════════════════════════════════════════════════════════════════
  // PROFILE ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String profile = '$baseUrl/profile';
  static const String profileAvatar = '$baseUrl/profile/avatar';
  static const String profilePrivacySettings = '$baseUrl/profile/privacy-settings';
  static const String profileCompletionStatus = '$baseUrl/profile/completion-status';
  static const String profileTimeSpending = '$baseUrl/profile/time-spending';
  static const String profileCoupleActivity = '$baseUrl/profile/couple-activity';
  static const String profileSugarPartner = '$baseUrl/profile/sugar-partner';

  // ══════════════════════════════════════════════════════════════════════════
  // USER ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String users = '$baseUrl/users';
  static String userById(int userId) => '$baseUrl/users/$userId';
  static String userAvailability(int userId) => '$baseUrl/users/$userId/availability';
  static String userReviews(int userId) => '$baseUrl/users/$userId/reviews';
  static String userReport(int userId) => '$baseUrl/users/$userId/report';

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKING ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String bookings = '$baseUrl/bookings';
  static String bookingById(int bookingId) => '$baseUrl/bookings/$bookingId';
  static String bookingCancel(int bookingId) => '$baseUrl/bookings/$bookingId/cancel';
  static String bookingAccept(int bookingId) => '$baseUrl/bookings/$bookingId/accept';
  static String bookingReject(int bookingId) => '$baseUrl/bookings/$bookingId/reject';
  static String bookingChatDetails(int bookingId) => '$baseUrl/bookings/$bookingId/chat-details';
  
  // Booking Payment Endpoints
  static String bookingPayment(int bookingId) => '$baseUrl/bookings/$bookingId/payment';
  static String bookingProcessPayment(int bookingId) => '$baseUrl/bookings/$bookingId/process-payment';
  static String bookingProcessDifferencePayment(int bookingId) => '$baseUrl/bookings/$bookingId/process-difference-payment';
  static String bookingWalletPayment(int bookingId) => '$baseUrl/bookings/$bookingId/wallet-payment';
  
  // Provider Available Slots & Status
  static String providerAvailableSlots(int providerId) => '$baseUrl/bookings/provider/$providerId/available-slots';
  static String providerBookingStatus(int providerId) => '$baseUrl/bookings/provider/$providerId/status';

  // ══════════════════════════════════════════════════════════════════════════
  // PROVIDER BOOKING MANAGEMENT ENDPOINTS
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
  static String chatUnblock(int userId) => '$baseUrl/chat/block/$userId'; // DELETE method

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
  static String reviewsCanReview(int bookingId) => '$baseUrl/reviews/can-review/$bookingId';

  // ══════════════════════════════════════════════════════════════════════════
  // WALLET ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String wallet = '$baseUrl/wallet';
  static const String walletBalance = '$baseUrl/wallet/balance';
  static const String walletTransactions = '$baseUrl/wallet/transactions';
  static const String walletAddBankAccount = '$baseUrl/wallet/add-bank-account';
  static const String walletRequestWithdrawal = '$baseUrl/wallet/request-withdrawal';
  static const String walletCheckAffordability = '$baseUrl/wallet/check-affordability';
  static String walletBankAccount(int accountId) => '$baseUrl/wallet/bank-account/$accountId';
  static String walletCancelWithdrawal(int withdrawalId) => '$baseUrl/wallet/cancel-withdrawal/$withdrawalId';

  // ══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String subscriptionPlans = '$baseUrl/subscription-plans';
  static const String subscriptionStatus = '$baseUrl/subscription/status';
  static const String subscriptionPurchase = '$baseUrl/subscription/purchase';
  static const String subscriptionVerifyPayment = '$baseUrl/subscription/verify-payment';
  static const String subscriptionCancel = '$baseUrl/subscription/cancel';
  static const String subscriptionHistory = '$baseUrl/subscription/history';

  // ══════════════════════════════════════════════════════════════════════════
  // EVENT ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String events = '$baseUrl/events';
  static String eventById(int eventId) => '$baseUrl/events/$eventId';
  static String eventJoin(int eventId) => '$baseUrl/events/$eventId/join';
  // Event Payment Endpoints (Cashfree)
  static String eventCreatePaymentOrder(int eventPaymentId) => '$baseUrl/events/payment/$eventPaymentId/create-order';
  static String eventVerifyPayment(int eventPaymentId) => '$baseUrl/events/payment/$eventPaymentId/verify';
  static String eventPaymentStatus(int eventPaymentId) => '$baseUrl/events/payment/$eventPaymentId/status';

  // ══════════════════════════════════════════════════════════════════════════
  // DISPUTE ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static const String disputes = '$baseUrl/disputes';
  static const String disputesRaise = '$baseUrl/disputes/raise';
  static String disputeDetails(int bookingId) => '$baseUrl/disputes/$bookingId/details';

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
  static const String coupleActivityPartnership = '$baseUrl/couple-activity/partnership';
  static const String coupleActivityHistory = '$baseUrl/couple-activity/history';
  static String coupleActivityRequestAccept(int requestId) => '$baseUrl/couple-activity/request/$requestId/accept';
  static String coupleActivityRequestReject(int requestId) => '$baseUrl/couple-activity/request/$requestId/reject';
  static String coupleActivityRequestCancel(int requestId) => '$baseUrl/couple-activity/request/$requestId';
  static String coupleActivityBlock(int userId) => '$baseUrl/couple-activity/block/$userId';

  // ══════════════════════════════════════════════════════════════════════════
  // CALENDAR ENDPOINTS
  // ══════════════════════════════════════════════════════════════════════════
  static String calendarBookings(String date) => '$baseUrl/calendar/bookings/$date';

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
