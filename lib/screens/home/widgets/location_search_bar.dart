import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/screens/search_location_screen.dart';

class LocationSearchBar extends StatefulWidget {
  final Function(String, double, double)? onPickupSelected;
  final Function(String, double, double)? onDestinationSelected;

  const LocationSearchBar({
    super.key,
    this.onPickupSelected,
    this.onDestinationSelected,
  });

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  String? _pickupAddress;
  String? _destinationAddress;
  double? _pickupLat;
  double? _pickupLng;
  double? _destinationLat;
  double? _destinationLng;

  Future<void> _selectPickup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationScreen(
          type: 'pickup',
          onLocationSelected: (address, lat, lng) {
            // This callback is called from the search screen
            // We need to pop with the result
            Navigator.pop(context, {
              'address': address,
              'lat': lat,
              'lng': lng,
            });
          },
        ),
      ),
    );

    if (result != null && mounted) {
      final data = result as Map<String, dynamic>;
      setState(() {
        _pickupAddress = data['address'];
        _pickupLat = data['lat'];
        _pickupLng = data['lng'];
      });
      if (widget.onPickupSelected != null) {
        widget.onPickupSelected!(
          data['address'],
          data['lat'],
          data['lng'],
        );
      }
    }
  }

  Future<void> _selectDestination() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationScreen(
          type: 'destination',
          onLocationSelected: (address, lat, lng) {
            Navigator.pop(context, {
              'address': address,
              'lat': lat,
              'lng': lng,
            });
          },
        ),
      ),
    );

    if (result != null && mounted) {
      final data = result as Map<String, dynamic>;
      setState(() {
        _destinationAddress = data['address'];
        _destinationLat = data['lat'];
        _destinationLng = data['lng'];
      });
      if (widget.onDestinationSelected != null) {
        widget.onDestinationSelected!(
          data['address'],
          data['lat'],
          data['lng'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _selectPickup,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _pickupAddress ?? 'Where are you?',
                    style: TextStyle(
                      color: _pickupAddress != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, size: 20, color: AppColors.grey),
              ],
            ),
          ),
          const Divider(height: 24),
          GestureDetector(
            onTap: _selectDestination,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _destinationAddress ?? 'Where to?',
                    style: TextStyle(
                      color: _destinationAddress != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_destinationAddress != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        _destinationAddress = null;
                        _destinationLat = null;
                        _destinationLng = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_pickupAddress != null && _destinationAddress != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.requestRide, extra: {
                    'pickup_address': _pickupAddress,
                    'pickup_lat': _pickupLat,
                    'pickup_lng': _pickupLng,
                    'destination_address': _destinationAddress,
                    'destination_lat': _destinationLat,
                    'destination_lng': _destinationLng,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Request Ride',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}