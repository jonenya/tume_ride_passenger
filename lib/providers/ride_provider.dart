import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/models/ride.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';

class RideProvider extends ChangeNotifier {
  List<Ride> _rides = [];
  Ride? _activeRide;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  bool _isPolling = false;

  List<Ride> get rides => _rides;
  Ride? get activeRide => _activeRide;
  bool get isLoading => _isLoading;
  bool get hasActiveRide => _activeRide != null;
  String? get error => _error;
  bool get isPolling => _isPolling;

  final ApiService _api = ApiService();

  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      getActiveRide();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  void clearActiveRide() {
    _activeRide = null;
    stopPolling();
    notifyListeners();
  }

  Future<Map<String, dynamic>> requestRide(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(ApiConstants.rides, data: {
        'action': ApiConstants.requestRide,
        ...data,
      });

      if (response['status'] == 'success' && response['data'] != null) {
        final rideData = response['data'];
        _activeRide = Ride.fromJson(rideData);
        _error = null;
        startPolling();
      } else {
        _error = response['message'] ?? 'Failed to request ride';
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> getActiveRide() async {
    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.activeRide,
      });

      if (response['status'] == 'success') {
        final rideData = response['data']?['active_ride'];
        final previousRide = _activeRide;

        if (rideData != null && rideData['id'] != null) {
          final newRide = Ride.fromJson(rideData);
          _activeRide = newRide;

          if (previousRide?.status != newRide.status) {
            print('🚗 Ride status changed: ${previousRide?.status} → ${newRide.status}');
            notifyListeners();

            if (newRide.status == 'completed' || newRide.status == 'cancelled') {
              stopPolling();
            }
          } else {
            notifyListeners();
          }
        } else {
          if (_activeRide != null) {
            print('🚗 No active ride, stopping polling');
            _activeRide = null;
            stopPolling();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error getting active ride: $e');
    }
  }

  // Safe type conversion helper
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<Map<String, dynamic>> checkRideStatus(int rideId) async {
    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.rideStatus,
        'ride_id': rideId,
      });

      // Convert string numbers to doubles in response
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        data['fare_actual'] = _toDouble(data['fare_actual']);
        data['fare_estimate'] = _toDouble(data['fare_estimate']);
        if (data['driver'] != null) {
          // Any other numeric fields in driver can be converted here
        }
      }

      return response;
    } catch (e) {
      print('Error checking ride status: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getRideById(int rideId) async {
    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.getRide,
        'ride_id': rideId,
      });
      return response;
    } catch (e) {
      print('Error getting ride by ID: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getActiveRideDetails() async {
    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.activeDetails,
      });
      return response;
    } catch (e) {
      print('Error getting active ride details: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAvailableCategories() async {
    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.categories,
      });
      return response;
    } catch (e) {
      print('Error getting categories: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> confirmRideCompletion(int rideId) async {
    try {
      final response = await _api.post(ApiConstants.rides, data: {
        'action': ApiConstants.confirmCompletion,
        'ride_id': rideId,
      });
      return response;
    } catch (e) {
      print('Error confirming ride completion: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> trackActiveRide() async {
    if (_activeRide == null) return;

    try {
      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.trackRide,
        'id': _activeRide!.id,
      });

      if (response['status'] == 'success' && response['data'] != null) {
        final rideData = response['data']['ride'];
        if (rideData != null) {
          final previousStatus = _activeRide?.status;
          _activeRide = Ride.fromJson(rideData);

          if (previousStatus != _activeRide?.status) {
            print('🚗 Tracked ride status changed: $previousStatus → ${_activeRide?.status}');
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error tracking ride: $e');
    }
  }

  Future<Map<String, dynamic>> cancelRide(int rideId, {String? reason}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(ApiConstants.rides, data: {
        'action': ApiConstants.cancelRide,
        'ride_id': rideId,
        'reason': reason,
      });

      if (response['status'] == 'success') {
        _activeRide = null;
        stopPolling();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rateRide(int rideId, int rating, {String? feedback}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Submitting rating - Ride ID: $rideId, Rating: $rating, Feedback: $feedback');

      final response = await _api.post(ApiConstants.rides, data: {
        'action': ApiConstants.rateRide,
        'ride_id': rideId,
        'rating': rating,
        'feedback': feedback,
      });

      print('📡 Rate ride response: $response');

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print('❌ Error rating ride: $e');
      _isLoading = false;
      notifyListeners();
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> getRideHistory({int page = 1, int limit = 20}) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Fetching ride history - Page: $page, Limit: $limit');

      final response = await _api.get(ApiConstants.rides, queryParams: {
        'action': ApiConstants.rideHistory,
        'page': page,
        'limit': limit,
      });

      print('📡 Ride History Response Status: ${response['status']}');
      print('📡 Full Response: $response');

      if (response['status'] == 'success') {
        List ridesData = [];

        // Handle different response structures
        if (response['data'] != null) {
          if (response['data'] is List) {
            ridesData = response['data'];
            print('📡 Data is a List with ${ridesData.length} items');
          } else if (response['data']['rides'] != null) {
            ridesData = response['data']['rides'];
            print('📡 Data.rides is a List with ${ridesData.length} items');
          } else {
            // Try to get values if it's a map
            ridesData = response['data'].values.whereType<List>().expand((i) => i).toList();
            print('📡 Extracted ${ridesData.length} items from data map');
          }
        } else if (response['rides'] != null) {
          ridesData = response['rides'];
          print('📡 Rides is a List with ${ridesData.length} items');
        }

        print('📡 Found ${ridesData.length} rides in response');

        // Print each ride for debugging
        for (var i = 0; i < ridesData.length; i++) {
          final ride = ridesData[i];
          print('  - Ride ${i + 1}: ID=${ride['id']}, Status=${ride['status']}, Code=${ride['ride_code']}');
        }

        // Clear rides if page is 1 (fresh load)
        if (page == 1) {
          _rides = [];
        }

        // Parse and add rides
        final newRides = ridesData.map((r) => Ride.fromJson(r)).toList();
        _rides.addAll(newRides);

        final completedCount = _rides.where((r) => r.status == 'completed').length;
        print('✅ Total rides: ${_rides.length}, Completed: $completedCount');

      } else {
        print('❌ Error getting ride history: ${response['message']}');
        _error = response['message'];
      }
    } catch (e) {
      print('❌ Error getting ride history: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}