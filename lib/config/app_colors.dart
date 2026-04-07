import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF009688);
  static const Color primaryLight = Color(0xFF80CBC4);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFFF5252);
  static const Color secondaryLight = Color(0xFFFF8A8A);

  // Accent Colors
  static const Color accent = Color(0xFFFFA000);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Category Colors
  static const Color bike = Color(0xFFFF6B6B);
  static const Color electric = Color(0xFF4CAF50);
  static const Color tuktuk = Color(0xFFFFA000);
  static const Color basic = Color(0xFF2196F3);
  static const Color women = Color(0xFFE91E63);
  static const Color send = Color(0xFF9C27B0);
  static const Color comfort = Color(0xFF673AB7);
  static const Color xl = Color(0xFF3F51B5);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'bike':
      case 'boda':
        return bike;
      case 'electric_bike':
      case 'basic_electric':
      case 'comfort_electric':
        return electric;
      case 'tuktuk':
        return tuktuk;
      case 'basic_car':
        return basic;
      case 'women_only':
        return women;
      case 'send':
        return send;
      case 'comfort':
        return comfort;
      case 'xl':
        return xl;
      default:
        return primary;
    }
  }
}
