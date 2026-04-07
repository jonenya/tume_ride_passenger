import 'package:flutter/material.dart';

class Ride {
  final int id;
  final String rideCode;
  final String status;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final double fareEstimate;
  final double fareActual;
  final double? distanceKm;
  final int? durationMin;
  final String passengerName;
  final String passengerPhone;
  final int passengerId;
  final int? driverId;
  final double? passengerRating;
  final double? driverRating;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String paymentMethod;
  final String paymentStatus;
  final bool isPaid;
  final String category;

  // Driver fields
  final String? driverName;
  final String? driverPhone;
  final String? driverProfilePic;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;
  final double? driverLat;
  final double? driverLng;

  Ride({
    required this.id,
    required this.rideCode,
    required this.status,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.fareEstimate,
    required this.fareActual,
    this.distanceKm,
    this.durationMin,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerId,
    this.driverId,
    this.passengerRating,
    this.driverRating,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.isPaid,
    this.category = 'basic_car',
    this.driverName,
    this.driverPhone,
    this.driverProfilePic,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
    this.driverLat,
    this.driverLng,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => ['requested', 'accepted', 'arrived', 'started'].contains(status);
  bool get hasDriver => driverId != null;
  bool get isRated => passengerRating != null;

  double get finalFare {
    // Use fareActual if it's greater than 0, otherwise use fareEstimate
    if (fareActual > 0) return fareActual;
    if (fareEstimate > 0) return fareEstimate;
    return 0.0;
  }

  // Helper function to safely convert to double - IMPROVED
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove quotes and trim whitespace
      String cleaned = value.replaceAll('"', '').trim();
      // Try to parse as double
      final parsed = double.tryParse(cleaned);
      if (parsed != null) return parsed;
      // If that fails, try to extract numbers (e.g., "KES 1148.16")
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleaned);
      if (match != null) {
        return double.tryParse(match.group(1)!) ?? 0.0;
      }
      return 0.0;
    }
    return 0.0;
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    // Debug print to see what we're getting
    print('📦 Building Ride from JSON:');
    print('  fare_estimate: ${json['fare_estimate']} (${json['fare_estimate'].runtimeType})');
    print('  fare_actual: ${json['fare_actual']} (${json['fare_actual'].runtimeType})');

    return Ride(
      id: json['id'] ?? 0,
      rideCode: json['ride_code'] ?? '',
      status: json['status'] ?? 'requested',
      pickupAddress: json['pickup_address'] ?? '',
      destinationAddress: json['destination_address'] ?? '',
      pickupLat: _toDouble(json['pickup_lat']),
      pickupLng: _toDouble(json['pickup_lng']),
      destinationLat: _toDouble(json['destination_lat']),
      destinationLng: _toDouble(json['destination_lng']),
      fareEstimate: _toDouble(json['fare_estimate']),
      fareActual: _toDouble(json['fare_actual'] ?? json['fare_estimate']),
      distanceKm: json['distance_km'] != null ? _toDouble(json['distance_km']) : null,
      durationMin: json['duration_min'] != null ? int.tryParse(json['duration_min'].toString()) : null,
      passengerName: json['passenger_name'] ?? json['name'] ?? '',
      passengerPhone: json['passenger_phone'] ?? json['phone'] ?? '',
      passengerId: json['passenger_id'] ?? 0,
      driverId: json['driver_id'] != null ? int.tryParse(json['driver_id'].toString()) : null,
      passengerRating: json['passenger_rating'] != null ? _toDouble(json['passenger_rating']) : null,
      driverRating: json['driver_rating'] != null ? _toDouble(json['driver_rating']) : null,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'])
          : DateTime.now(),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      paymentMethod: json['payment_method'] ?? 'mpesa',
      paymentStatus: json['payment_status'] ?? 'pending',
      isPaid: (json['is_paid'] ?? 0) == 1,
      category: json['category'] ?? 'basic_car',
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverProfilePic: json['driver_profile_pic'],
      vehicleModel: json['vehicle_model'],
      vehiclePlate: json['vehicle_plate'],
      vehicleColor: json['vehicle_color'],
      driverLat: json['driver_lat'] != null ? _toDouble(json['driver_lat']) : null,
      driverLng: json['driver_lng'] != null ? _toDouble(json['driver_lng']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_code': rideCode,
      'status': status,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'fare_estimate': fareEstimate,
      'fare_actual': fareActual,
      'distance_km': distanceKm,
      'duration_min': durationMin,
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'passenger_rating': passengerRating,
      'driver_rating': driverRating,
      'requested_at': requestedAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'is_paid': isPaid ? 1 : 0,
      'category': category,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'driver_profile_pic': driverProfilePic,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
      'vehicle_color': vehicleColor,
      'driver_lat': driverLat,
      'driver_lng': driverLng,
    };
  }
}