import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get formattedBalance => 'KES ${_balance.toStringAsFixed(2)}';

  final ApiService _api = ApiService();

  Future<void> getBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Getting wallet balance...');
      final response = await _api.get(ApiConstants.wallet, queryParams: {
        'action': ApiConstants.walletBalance,
      });

      print('📡 Balance response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        _balance = (response['data']['balance'] ?? 0.0).toDouble();
      } else {
        _error = response['message'];
      }
    } catch (e) {
      print('❌ Error getting balance: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> topUp(double amount, {String? phone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Topping up KES $amount');

      final requestData = {
        'action': ApiConstants.topup,
        'amount': amount,
      };

      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }

      final response = await _api.post(ApiConstants.wallet, data: requestData);

      print('📡 Top-up response: $response');

      if (response['status'] == 'success') {
        // Refresh balance after successful top-up
        await getBalance();
        await getTransactionHistory();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print('❌ Error during top-up: $e');
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> getTransactionHistory({int page = 1, int limit = 20}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Getting transaction history...');
      final response = await _api.get(ApiConstants.wallet, queryParams: {
        'action': ApiConstants.walletHistory,
        'page': page,
        'limit': limit,
      });

      print('📡 Transaction history response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        _transactions = List<Map<String, dynamic>>.from(response['data']['transactions'] ?? []);
        // Also update balance from response
        if (response['data']['balance'] != null) {
          _balance = (response['data']['balance'] ?? _balance).toDouble();
        }
      } else {
        _error = response['message'];
      }
    } catch (e) {
      print('❌ Error getting transactions: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}