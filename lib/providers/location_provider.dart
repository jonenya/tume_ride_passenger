import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  bool get hasLocation => _currentPosition != null;
  String? get error => _error;

  static const double defaultLat = -1.2921;
  static const double defaultLng = 36.8219;
  static const String defaultAddress = 'Nairobi, Kenya';

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permission denied';
          _currentPosition = null;
          _currentAddress = defaultAddress;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled';
        _currentPosition = null;
        _currentAddress = defaultAddress;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final List<String> parts = [];
          if (place.name != null && place.name!.isNotEmpty) parts.add(place.name!);
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) parts.add(place.thoroughfare!);
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) parts.add(place.subThoroughfare!);
          if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
          _currentAddress = parts.isNotEmpty ? parts.join(', ') : defaultAddress;
        } else {
          _currentAddress = defaultAddress;
        }
      } catch (e) {
        print('Geocoding error: $e');
        _currentAddress = defaultAddress;
      }

    } catch (e) {
      print('Location error: $e');
      _error = 'Unable to get location';
      _currentPosition = null;
      _currentAddress = defaultAddress;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}