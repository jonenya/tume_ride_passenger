import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/screens/auth/login_screen.dart';
import 'package:tume_ride_passenger/screens/auth/otp_verification_screen.dart';
import 'package:tume_ride_passenger/screens/auth/register_screen.dart';
import 'package:tume_ride_passenger/screens/home/home_screen.dart';
import 'package:tume_ride_passenger/screens/onboarding/onboarding_screen.dart';
import 'package:tume_ride_passenger/screens/payment/wallet_screen.dart';
import 'package:tume_ride_passenger/screens/payment/topup_screen.dart';
import 'package:tume_ride_passenger/screens/profile/profile_screen.dart';
import 'package:tume_ride_passenger/screens/promo/promos_screen.dart';
import 'package:tume_ride_passenger/screens/ride/ride_history_screen.dart';
import 'package:tume_ride_passenger/screens/ride/request_ride_screen.dart';
import 'package:tume_ride_passenger/screens/ride/tracking_screen.dart';
import 'package:tume_ride_passenger/screens/ride/ride_completed_screen.dart';
import 'package:tume_ride_passenger/screens/ride/rate_driver_screen.dart';
import 'package:tume_ride_passenger/screens/support/support_screen.dart';
import 'package:tume_ride_passenger/screens/notifications/notifications_screen.dart';
import 'package:tume_ride_passenger/screens/splash/splash_screen.dart';
import 'package:tume_ride_passenger/screens/search_location_screen.dart';
import 'package:tume_ride_passenger/screens/profile/edit_profile_screen.dart';
import 'package:tume_ride_passenger/screens/profile/saved_addresses_screen.dart';
import 'package:tume_ride_passenger/screens/profile/emergency_contacts_screen.dart';
import 'package:tume_ride_passenger/screens/profile/settings_screen.dart';
import 'package:tume_ride_passenger/screens/promo/referral_screen.dart';

class AppRouter extends StatelessWidget {
  AppRouter({super.key});

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Public routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OTPVerificationScreen(
            identifier: extra?['identifier'] ?? '',  // ← FIXED: changed from 'phone'
            isLogin: extra?['isLogin'] ?? true,
            testOtp: extra?['testOtp'],
          );
        },
      ),
      GoRoute(
        path: '/search-location',
        name: 'search-location',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final type = args?['type'] ?? 'pickup';
          return SearchLocationScreen(
            type: type,
            onLocationSelected: (address, lat, lng) {},
          );
        },
      ),
      // Protected routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/request-ride',
        name: 'request-ride',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RequestRideScreen(
            pickupAddress: extra?['pickup_address'],
            pickupLat: extra?['pickup_lat'],
            pickupLng: extra?['pickup_lng'],
            destinationAddress: extra?['destination_address'],
            destinationLat: extra?['destination_lat'],
            destinationLng: extra?['destination_lng'],
            category: extra?['category'],
          );
        },
      ),
      GoRoute(
        path: '/tracking',
        name: 'tracking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TrackingScreen(
            rideId: extra?['ride_id'] ?? 0,
            rideCode: extra?['ride_code'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/ride-completed',
        name: 'ride-completed',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RideCompletedScreen(
            rideId: extra?['ride_id'] ?? 0,
            fare: extra?['fare'] ?? 0.0,
            driverName: extra?['driver_name'] ?? '',
            driverPhoto: extra?['driver_photo'],
            vehicleModel: extra?['vehicle_model'] ?? '',
            vehiclePlate: extra?['vehicle_plate'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/rate-driver',
        name: 'rate-driver',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RateDriverScreen(
            rideId: extra?['ride_id'] ?? 0,
            driverName: extra?['driver_name'] ?? '',
            driverPhoto: extra?['driver_photo'],
            vehicleModel: extra?['vehicle_model'] ?? '',
            vehiclePlate: extra?['vehicle_plate'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/ride-history',
        name: 'ride-history',
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/topup',
        name: 'topup',
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/promos',
        name: 'promos',
        builder: (context, state) => const PromosScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/saved-addresses',
        name: 'saved-addresses',
        builder: (context, state) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: '/emergency-contacts',
        name: 'emergency-contacts',
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;
      final isOnboardingCompleted = authProvider.isOnboardingCompleted;

      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp-verification';

      if (!isOnboardingCompleted && !isOnboardingRoute) {
        return '/onboarding';
      }

      if (isOnboardingCompleted && !isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      if (isLoggedIn && isOnboardingRoute) {
        return '/home';
      }

      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tume Ride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}