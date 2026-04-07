import 'package:json_annotation/json_annotation.dart';

part 'promo.g.dart';

@JsonSerializable()
class Promo {
  final int id;
  final String promoCode;
  final String promoType;
  final double value;
  final double? maxDiscount;
  final double? minFare;
  final String? userType;
  final List<String>? rideCategories;
  final int? usageLimit;
  final int usageCount;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;

  Promo({
    required this.id,
    required this.promoCode,
    required this.promoType,
    required this.value,
    this.maxDiscount,
    this.minFare,
    this.userType,
    this.rideCategories,
    this.usageLimit,
    required this.usageCount,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
  });

  bool get isPercentage => promoType == 'percentage';
  bool get isFixed => promoType == 'fixed';
  bool get isFreeRide => promoType == 'free_ride';
  bool get isValid => isActive && validFrom.isBefore(DateTime.now()) && validTo.isAfter(DateTime.now());
  bool get isExpired => validTo.isBefore(DateTime.now());
  bool get isUpcoming => validFrom.isAfter(DateTime.now());

  double calculateDiscount(double fare) {
    if (isPercentage) {
      double discount = fare * (value / 100);
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
      return discount;
    } else if (isFixed) {
      return value;
    } else if (isFreeRide) {
      return fare;
    }
    return 0;
  }

  factory Promo.fromJson(Map<String, dynamic> json) => _$PromoFromJson(json);
  Map<String, dynamic> toJson() => _$PromoToJson(this);
}
