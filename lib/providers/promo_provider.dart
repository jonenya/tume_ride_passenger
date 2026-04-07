import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';

class PromoProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _promos = [];
  bool _isLoading = false;
  Map<String, dynamic>? _referralData;
  double _appliedDiscount = 0;
  String? _appliedPromoCode;

  List<Map<String, dynamic>> get promos => _promos;
  List<Map<String, dynamic>> get activePromos => _promos.where((p) => p['is_active'] == true).toList();
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get referralData => _referralData;
  double get appliedDiscount => _appliedDiscount;
  String? get appliedPromoCode => _appliedPromoCode;

  final ApiService _api = ApiService();

  Future<void> loadPromos() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Loading promos...');
      final response = await _api.get(ApiConstants.promos, queryParams: {
        'action': ApiConstants.listPromos,
      });

      print('📨 Load promos response: ${response['status']}');

      if (response['status'] == 'success' && response['data'] != null) {
        final promosData = response['data']['promos'];
        if (promosData is List) {
          final List<Map<String, dynamic>> parsedPromos = [];
          for (var promo in promosData) {
            final Map<String, dynamic> parsedPromo = {
              'id': promo['id'],
              'promo_code': promo['promo_code'],
              'promo_type': promo['discount_type'] ?? promo['promo_type'] ?? 'fixed',
              'value': _parseDouble(promo['discount_value'] ?? promo['value']),
              'max_discount': _parseDouble(promo['max_discount']),
              'min_fare': _parseDouble(promo['min_fare']),
              'user_type': promo['user_type'],
              'ride_categories': promo['ride_categories'],
              'usage_limit': promo['usage_limit'],
              'usage_count': promo['used_count'] ?? promo['usage_count'] ?? 0,
              'valid_from': promo['valid_from'],
              'valid_to': promo['valid_to'],
              'is_active': promo['is_active'],
              'created_by': promo['created_by'],
              'created_at': promo['created_at'],
            };
            parsedPromos.add(parsedPromo);
            print('✅ Loaded promo: ${parsedPromo['promo_code']} - ${parsedPromo['value']} ${parsedPromo['promo_type']}');
          }
          _promos = parsedPromos;
          print('✅ Loaded ${_promos.length} promos');
        } else {
          print('❌ promosData is not a List');
          _promos = [];
        }
      } else {
        print('❌ Error loading promos: ${response['message']}');
        _promos = [];
      }
    } catch (e) {
      print('❌ Exception loading promos: $e');
      _promos = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<Map<String, dynamic>> validatePromo(String promoCode, double fareEstimate) async {
    try {
      print('📝 Validating promo: $promoCode for fare: $fareEstimate');

      final response = await _api.post(ApiConstants.promos, data: {
        'action': ApiConstants.validatePromo,
        'promo_code': promoCode.trim().toUpperCase().replaceAll(' ', ''),
        'fare_estimate': fareEstimate,
      });

      print('📡 Validate promo response status: ${response['status']}');
      print('📡 Validate promo response data: ${response['data']}');

      if (response['status'] == 'success') {
        final data = response['data'];
        double discount = 0;
        double newFare = fareEstimate;

        if (data != null) {
          // Parse discount
          if (data['discount'] != null) {
            discount = data['discount'] is double
                ? data['discount']
                : double.tryParse(data['discount'].toString()) ?? 0;
          }

          // Parse new fare
          if (data['new_fare'] != null) {
            newFare = data['new_fare'] is double
                ? data['new_fare']
                : double.tryParse(data['new_fare'].toString()) ?? fareEstimate;
          } else if (discount > 0) {
            newFare = fareEstimate - discount;
          }

          _appliedDiscount = discount;
          _appliedPromoCode = promoCode.trim().toUpperCase().replaceAll(' ', '');
          notifyListeners();

          print('✅ Promo validated: discount=$discount, newFare=$newFare');

          return {
            'status': 'success',
            'data': {
              'discount': discount,
              'new_fare': newFare > 0 ? newFare : 0
            }
          };
        }
      }

      print('❌ Promo validation failed: ${response['message']}');
      return response;
    } catch (e) {
      print('❌ Validate promo error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  void clearAppliedPromo() {
    _appliedDiscount = 0;
    _appliedPromoCode = null;
    notifyListeners();
  }

  Future<void> loadReferralData() async {
    try {
      final response = await _api.get(ApiConstants.promos, queryParams: {
        'action': ApiConstants.referral,
      });

      if (response['status'] == 'success' && response['data'] != null) {
        _referralData = response['data'];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading referral data: $e');
    }
  }

  Future<Map<String, dynamic>> shareReferral() async {
    try {
      final response = await _api.post(ApiConstants.promos, data: {
        'action': ApiConstants.shareReferral,
      });
      return response;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}