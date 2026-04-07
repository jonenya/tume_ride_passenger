import 'package:tume_ride_passenger/config/app_config.dart';

class ApiConstants {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // Passenger Endpoints
  static const String auth = '/passenger/auth.php';
  static const String rides = '/passenger/rides.php';
  static const String wallet = '/passenger/wallet.php';
  static const String profile = '/passenger/profile.php';
  static const String promos = '/passenger/promos.php';
  static const String payments = '/passenger/payments.php';
  static const String notifications = '/passenger/notifications.php';
  static const String support = '/passenger/support.php';

  // Auth Actions
  static const String register = 'register';
  static const String login = 'login';
  static const String verifyOtp = 'verify-otp';
  static const String logout = 'logout';
  static const String testLogin = 'test-login';

  // Ride Actions
  static const String requestRide = 'request';
  static const String trackRide = 'track';
  static const String cancelRide = 'cancel';
  static const String rateRide = 'rate';
  static const String rideHistory = 'history';
  static const String activeRide = 'active';
  static const String rideStatus = 'status';           // NEW: Check ride status
  static const String getRide = 'get_ride';            // NEW: Get ride by ID
  static const String activeDetails = 'active_details'; // NEW: Full active ride details
  static const String confirmCompletion = 'confirm_completion'; // NEW: Confirm ride completion
  static const String categories = 'categories';       // NEW: Get available categories

  // Wallet Actions
  static const String walletBalance = 'balance';
  static const String topup = 'topup';
  static const String walletHistory = 'history';
  static const String withdraw = 'withdraw';           // NEW: Withdraw to M-Pesa

  // Profile Actions
  static const String getProfile = 'get';
  static const String updateProfile = 'update';
  static const String addresses = 'addresses';
  static const String addAddress = 'add-address';
  static const String deleteAddress = 'delete-address';
  static const String emergencyContacts = 'emergency-contacts';
  static const String addEmergencyContact = 'add-emergency-contact';
  static const String deleteEmergencyContact = 'delete-emergency-contact';
  static const String updateLanguage = 'language';
  static const String savedAddresses = 'saved-addresses';  // NEW: Get saved addresses
  static const String updatePassword = 'update-password';  // NEW: Change password

  // Promo Actions
  static const String listPromos = 'list';
  static const String validatePromo = 'validate';
  static const String referral = 'referral';
  static const String shareReferral = 'share';
  static const String applyPromo = 'apply';            // NEW: Apply promo code to ride

  // Payment Actions
  static const String mpesaStkPush = 'stk-push';       // NEW: Initiate M-Pesa payment
  static const String mpesaStatus = 'status';          // NEW: Check payment status
  static const String paymentMethods = 'methods';      // NEW: Get available payment methods

  // Notification Actions
  static const String getNotifications = 'list';
  static const String markAsRead = 'mark-read';
  static const String markAllRead = 'mark-all-read';
  static const String deleteNotification = 'delete';

  // Support Actions
  static const String createTicket = 'create';
  static const String getTickets = 'list';
  static const String getTicket = 'get';
  static const String replyTicket = 'reply';
  static const String closeTicket = 'close';

  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorUnknown = 'An unknown error occurred.';
}