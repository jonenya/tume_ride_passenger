// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promo _$PromoFromJson(Map<String, dynamic> json) => Promo(
      id: (json['id'] as num).toInt(),
      promoCode: json['promoCode'] as String,
      promoType: json['promoType'] as String,
      value: (json['value'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      minFare: (json['minFare'] as num?)?.toDouble(),
      userType: json['userType'] as String?,
      rideCategories: (json['rideCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usageCount: (json['usageCount'] as num).toInt(),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$PromoToJson(Promo instance) => <String, dynamic>{
      'id': instance.id,
      'promoCode': instance.promoCode,
      'promoType': instance.promoType,
      'value': instance.value,
      'maxDiscount': instance.maxDiscount,
      'minFare': instance.minFare,
      'userType': instance.userType,
      'rideCategories': instance.rideCategories,
      'usageLimit': instance.usageLimit,
      'usageCount': instance.usageCount,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo.toIso8601String(),
      'isActive': instance.isActive,
    };
