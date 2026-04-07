import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable()
class PaymentMethod {
  final String id;
  final String name;
  final String type;
  final String? details;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.details,
    required this.isDefault,
  });

  String get icon {
    switch (type) {
      case 'mpesa':
        return '📱';
      case 'wallet':
        return '💳';
      default:
        return '💵';
    }
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}
