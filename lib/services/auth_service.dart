import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';
import 'package:tume_ride_passenger/models/user.dart';
import 'package:tume_ride_passenger/services/api_service.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';

  // Token Management
  static Future<void> saveToken(String token) async {
    try {
      print('📝 Saving token...');
      await _storage.write(key: _tokenKey, value: token);
      final saved = await _storage.read(key: _tokenKey);
      print('✅ Token saved: ${saved != null ? "Yes (length: ${saved.length})" : "No"}');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      print('🔑 Token: ${token != null ? "Present (length: ${token.length})" : "Not found"}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      print('✅ Token deleted');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }

  // User Management
  static Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
      await _storage.write(key: _userIdKey, value: user.id.toString());
      await _storage.write(key: _userTypeKey, value: 'passenger');
      print('✅ User saved: ${user.fullName} (ID: ${user.id})');
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  static Future<User?> getUser() async {
    try {
      final userStr = await _storage.read(key: _userKey);
      if (userStr != null) {
        final Map<String, dynamic> userMap = jsonDecode(userStr);
        print('✅ User retrieved: ${userMap['first_name']} ${userMap['last_name']}');
        return User.fromJson(userMap);
      }
      print('⚠️ No user found');
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  static Future<int?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      return userId != null ? int.tryParse(userId) : null;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  static Future<String?> getUserType() async {
    try {
      return await _storage.read(key: _userTypeKey);
    } catch (e) {
      print('❌ Error getting user type: $e');
      return null;
    }
  }

  // Onboarding Management
  static Future<void> setOnboardingCompleted() async {
    try {
      await _storage.write(key: _onboardingKey, value: 'true');
      print('✅ Onboarding completed saved');
    } catch (e) {
      print('❌ Error saving onboarding status: $e');
    }
  }

  static Future<bool> isOnboardingCompleted() async {
    try {
      final value = await _storage.read(key: _onboardingKey);
      return value == 'true';
    } catch (e) {
      print('❌ Error getting onboarding status: $e');
      return false;
    }
  }

  // Auth Status
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔐 Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  // Clear All Auth Data
  static Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userTypeKey);
      print('✅ All auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  // API Calls
  static Future<Map<String, dynamic>> register(
      String phone,
      String firstName,
      String lastName, {
        String? email,
      }) async {
    print('📝 Registering user: $phone');
    final api = ApiService();
    return await api.post(ApiConstants.auth, data: {
      'action': ApiConstants.register,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    });
  }

  // UPDATED: Login with identifier (email or phone)
  static Future<Map<String, dynamic>> login(String identifier) async {
    print('📝 Logging in with: $identifier');
    final api = ApiService();
    return await api.post(ApiConstants.auth, data: {
      'action': ApiConstants.login,
      'identifier': identifier,  // Can be email or phone
    });
  }

  // UPDATED: Verify OTP with identifier (email or phone)
  static Future<Map<String, dynamic>> verifyOtp(String identifier, String otp) async {
    print('📝 Verifying OTP for: $identifier');
    final api = ApiService();
    final response = await api.post(ApiConstants.auth, data: {
      'action': ApiConstants.verifyOtp,
      'identifier': identifier,
      'otp': otp,
    });

    print('📡 Verify OTP Response Status: ${response['status']}');

    if (response['status'] == 'success' && response['data'] != null) {
      final data = response['data'];

      // Save token
      if (data['token'] != null) {
        await saveToken(data['token']);
        print('✅ Token saved from OTP verification');
      } else {
        print('⚠️ No token in response');
      }

      // Save user data
      if (data['user'] != null) {
        final user = User.fromJson(data['user']);
        await saveUser(user);
        print('✅ User saved from OTP verification: ${user.fullName}');
      } else if (data['user_id'] != null) {
        final user = User(
          id: data['user_id'],
          phone: data['phone'] ?? identifier,
          email: data['email'],
          firstName: data['first_name'] ?? '',
          lastName: data['last_name'] ?? '',
          profilePic: data['profile_pic'],
          language: data['language'] ?? 'en',
          status: data['status'] ?? 'active',
          totalRides: data['total_rides'] ?? 0,
          totalSpent: (data['total_spent'] ?? 0).toDouble(),
          ratingAvg: (data['rating_avg'] ?? 5.0).toDouble(),
          walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
          homeAddress: data['home_address'],
          workAddress: data['work_address'],
        );
        await saveUser(user);
        print('✅ Minimal user saved');
      }
    } else {
      print('❌ OTP verification failed: ${response['message']}');
    }

    return response;
  }

  static Future<Map<String, dynamic>> logout() async {
    print('📝 Logging out...');
    final api = ApiService();

    try {
      final response = await api.post(ApiConstants.auth, data: {
        'action': ApiConstants.logout,
      });
      print('📡 Logout response: ${response['status']}');
    } catch (e) {
      print('⚠️ Logout API error (ignored): $e');
    }

    await clearAuth();
    print('✅ Logout complete');

    return {'status': 'success', 'message': 'Logged out successfully'};
  }

  static Future<Map<String, dynamic>> testLogin() async {
    print('📝 Test login');
    final api = ApiService();
    return await api.post(ApiConstants.auth, data: {
      'action': ApiConstants.testLogin,
    });
  }
}