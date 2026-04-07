import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tume_ride_passenger/config/app_config.dart';

class CustomMap extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(GoogleMapController) onMapCreated;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final LatLng? centerLocation;

  const CustomMap({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onMapCreated,
    this.markers,
    this.polylines,
    this.centerLocation,
  });

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  bool _mapError = false;

  @override
  Widget build(BuildContext context) {
    // Check if API key is valid
    if (AppConfig.googleMapsApiKey.isEmpty ||
        AppConfig.googleMapsApiKey == 'AIzaSyBAsxRsUOZzuGqkKT9ANtCHOIQqmGyqkJY') {
      return _buildPlaceholder();
    }

    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialLat, widget.initialLng),
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _controller = controller;
          widget.onMapCreated(controller);
        },
        markers: widget.markers ?? {},
        polylines: widget.polylines ?? {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        compassEnabled: true,
        onCameraMove: (position) {
          _currentLocation = position.target;
        },
      );
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Loading Map...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please check your internet connection',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void animateToLocation(LatLng location, {double zoom = 15}) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }
}