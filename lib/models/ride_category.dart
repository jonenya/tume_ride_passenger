import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class RideCategory {
  final String code;
  final String nameEn;
  final String nameSw;
  final String icon;
  final int maxPassengers;
  final double? basePrice;
  final double? pricePerKm;
  final double? pricePerMin;
  final bool isActive;

  RideCategory({
    required this.code,
    required this.nameEn,
    required this.nameSw,
    required this.icon,
    required this.maxPassengers,
    this.basePrice,
    this.pricePerKm,
    this.pricePerMin,
    this.isActive = true,
  });

  String getName(String language) => language == 'sw' ? nameSw : nameEn;

  Color get color => AppColors.getCategoryColor(code);

  static List<RideCategory> getCategories() {
    return [
      RideCategory(code: 'bike', nameEn: 'Bikes (Boda)', nameSw: 'Boda', icon: '🏍️', maxPassengers: 1),
      RideCategory(code: 'electric_bike', nameEn: 'Electric Bike', nameSw: 'Boda ya Umeme', icon: '⚡🏍️', maxPassengers: 1),
      RideCategory(code: 'tuktuk', nameEn: 'Tuktuk', nameSw: 'Tuktuk', icon: '🛺', maxPassengers: 3),
      RideCategory(code: 'basic_car', nameEn: 'Basic Car', nameSw: 'Gari ya Kawaida', icon: '🚗', maxPassengers: 4),
      RideCategory(code: 'basic_electric', nameEn: 'Basic Electric', nameSw: 'Gari ya Umeme', icon: '⚡🚗', maxPassengers: 4),
      RideCategory(code: 'women_only', nameEn: 'Women Only', nameSw: 'Wanawake Pekee', icon: '👩', maxPassengers: 4),
      RideCategory(code: 'send', nameEn: 'Send (Parcel)', nameSw: 'Tuma Mzigo', icon: '📦', maxPassengers: 0),
      RideCategory(code: 'comfort', nameEn: 'Comfort', nameSw: 'Faraja', icon: '🚙', maxPassengers: 4),
      RideCategory(code: 'comfort_electric', nameEn: 'Comfort Electric', nameSw: 'Faraja Umeme', icon: '⚡🚙', maxPassengers: 4),
      RideCategory(code: 'xl', nameEn: 'XL (7 Seater)', nameSw: 'XL (Watoto 7)', icon: '🚐', maxPassengers: 7),
    ];
  }
}