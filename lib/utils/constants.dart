class AppConstants {
  static const String appName = 'Tume Ride';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String prefToken = 'auth_token';
  static const String prefUser = 'user_data';
  static const String prefOnboarding = 'onboarding_completed';
  static const String prefTheme = 'theme_mode';

  // Ride Statuses
  static const String rideStatusRequested = 'requested';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusArrived = 'arrived';
  static const String rideStatusStarted = 'started';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentApp = 'app';
  static const String paymentMpesaDirect = 'mpesa_direct';
  static const String paymentCash = 'cash';

  // Transaction Types
  static const String transactionTopup = 'topup';
  static const String transactionRidePayment = 'ride_payment';
  static const String transactionRefund = 'refund';
  static const String transactionPromoCredit = 'promo_credit';
  static const String transactionPayout = 'payout';
  static const String transactionCommission = 'commission_payment';

  // Notification Types
  static const String notificationRide = 'ride';
  static const String notificationPayment = 'payment';
  static const String notificationPromo = 'promo';
  static const String notificationSystem = 'system';
  static const String notificationCommission = 'commission';

  // Socket Events
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketNewRide = 'new_ride';
  static const String socketRideAccepted = 'ride_accepted';
  static const String socketDriverLocation = 'driver_location';
  static const String socketRideCancelled = 'ride_cancelled';
  static const String socketRideCompleted = 'ride_completed';
}
