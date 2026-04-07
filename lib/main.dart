import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tume_ride_passenger/app.dart';
import 'package:tume_ride_passenger/config/app_config.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/providers/location_provider.dart';
import 'package:tume_ride_passenger/providers/wallet_provider.dart';
import 'package:tume_ride_passenger/providers/promo_provider.dart';
import 'package:tume_ride_passenger/providers/theme_provider.dart';
import 'package:tume_ride_passenger/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiService
  final apiService = ApiService();
  await apiService.init();
  print('✅ ApiService initialized');

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TumeRideApp());
}

class TumeRideApp extends StatelessWidget {
  const TumeRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PromoProvider()),
      ],
      child: AppRouter(),
    );
  }
}