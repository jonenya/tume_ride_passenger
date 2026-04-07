import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/models/user.dart';
import 'package:tume_ride_passenger/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isOnboardingCompleted = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _isOnboardingCompleted = await AuthService.isOnboardingCompleted();
    _isLoggedIn = await AuthService.isLoggedIn();

    if (_isLoggedIn) {
      _user = await AuthService.getUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setOnboardingCompleted() async {
    await AuthService.setOnboardingCompleted();
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(String phone, String firstName, String lastName, {String? email}) async {
    _isLoading = true;
    notifyListeners();
    final response = await AuthService.register(phone, firstName, lastName, email: email);
    _isLoading = false;
    notifyListeners();
    return response;
  }

  // UPDATED: Login with identifier (email or phone)
  Future<Map<String, dynamic>> login(String identifier) async {
    _isLoading = true;
    notifyListeners();
    final response = await AuthService.login(identifier);
    _isLoading = false;
    notifyListeners();
    return response;
  }

  // UPDATED: Verify OTP with identifier (email or phone)
  Future<Map<String, dynamic>> verifyOtp(String identifier, String otp) async {
    _isLoading = true;
    notifyListeners();
    final response = await AuthService.verifyOtp(identifier, otp);

    if (response['status'] == 'success') {
      _isLoggedIn = true;
      _user = await AuthService.getUser();
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await AuthService.logout();
    _isLoggedIn = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    AuthService.saveUser(user);
    notifyListeners();
  }
}