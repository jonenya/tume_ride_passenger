import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/models/ride.dart';

class TrackingScreen extends StatefulWidget {
  final int rideId;
  final String rideCode;

  const TrackingScreen({
    super.key,
    required this.rideId,
    required this.rideCode,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  bool _isCancelling = false;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  String _currentStatus = 'requested';
  bool _isLoading = true;
  bool _rideCompleted = false;
  Ride? _currentRide;

  // Helper function to safely convert to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.getActiveRide();
    if (mounted) {
      _currentRide = rideProvider.activeRide;
      setState(() {
        _isLoading = false;
      });
      _startPolling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.stopPolling();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _updateRideStatus();
      }
    });
    _updateRideStatus();
  }

  Future<void> _updateRideStatus() async {
    if (_rideCompleted) return;
    if (!mounted) return;

    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    try {
      final response = await rideProvider.checkRideStatus(widget.rideId);

      if (!mounted) return;

      if (response['status'] == 'success') {
        final rideData = response['data'];
        final newStatus = rideData['status'];

        print('🚗 Passenger: Ride status = $newStatus');

        if (_currentStatus != newStatus) {
          print('🚗 Status changed: $_currentStatus → $newStatus');

          if (mounted) {
            setState(() {
              _currentStatus = newStatus;
            });
          }

          if (newStatus == 'accepted') {
            showSnackBar(context, message: 'Driver has accepted your ride!');
          } else if (newStatus == 'arrived') {
            showSnackBar(context, message: 'Driver has arrived at your location');
          } else if (newStatus == 'started') {
            showSnackBar(context, message: 'Trip has started!');
          } else if (newStatus == 'completed') {
            showSnackBar(context, message: 'Trip completed!');
            _rideCompleted = true;
            _timer?.cancel();
            rideProvider.stopPolling();

            // Safely extract fare
            double fare = 0.0;
            if (rideData['fare_actual'] != null) {
              fare = _toDouble(rideData['fare_actual']);
            } else if (rideData['fare_estimate'] != null) {
              fare = _toDouble(rideData['fare_estimate']);
            }

            final driverName = rideData['driver']?['driver_name'] ?? 'Driver';
            final driverPhoto = rideData['driver']?['profile_pic'];
            final vehicleModel = rideData['driver']?['vehicle_model'] ?? '';
            final vehiclePlate = rideData['driver']?['vehicle_plate'] ?? '';

            if (mounted) {
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                context.pushReplacement(AppRoutes.rideCompleted, extra: {
                  'ride_id': widget.rideId,
                  'fare': fare,
                  'driver_name': driverName,
                  'driver_photo': driverPhoto,
                  'vehicle_model': vehicleModel,
                  'vehicle_plate': vehiclePlate,
                });
              }
            }
          } else if (newStatus == 'cancelled') {
            showSnackBar(context, message: 'Ride has been cancelled', isError: true);
            _timer?.cancel();
            rideProvider.stopPolling();
            if (mounted) {
              context.go(AppRoutes.home);
            }
          }
        }
      }
    } catch (e) {
      print('Error updating ride status: $e');
    }

    if (!mounted) return;

    await rideProvider.getActiveRide();
    if (mounted && rideProvider.activeRide != null) {
      setState(() {
        _currentRide = rideProvider.activeRide;
      });
      if (rideProvider.activeRide != null) {
        _updateMarkers(rideProvider.activeRide!);
      }
    }
  }

  void _updateMarkers(Ride ride) {
    if (!mounted) return;

    _markers.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(ride.pickupLat, ride.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(ride.destinationLat, ride.destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    );

    if (ride.driverLat != null && ride.driverLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(ride.driverLat!, ride.driverLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      );
    }

    setState(() {});
  }

  Future<void> _cancelRide() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride? A cancellation fee may apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    if (!mounted) return;
    setState(() => _isCancelling = true);

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final response = await rideProvider.cancelRide(widget.rideId);

    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (response['status'] == 'success') {
      _timer?.cancel();
      rideProvider.stopPolling();
      showSnackBar(context, message: 'Ride cancelled successfully');
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to cancel ride',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final ride = rideProvider.activeRide ?? _currentRide;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ride == null && !_rideCompleted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No active ride'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (ride == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(ride.pickupLat, ride.pickupLng),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _updateMarkers(ride);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.home),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride: ${ride.rideCode}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getStatusText(_currentStatus),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(_currentStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentStatus == 'requested' || _currentStatus == 'accepted')
                    TextButton(
                      onPressed: _cancelRide,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      _buildStatusTimeline(_currentStatus),
                      const SizedBox(height: 24),
                      if (ride.hasDriver)
                        _buildDriverCard(ride),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppColors.success),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ride.pickupAddress,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ride.destinationAddress,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyLight),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fare',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'KES ${ride.finalFare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_currentStatus == 'requested')
                        CustomButton(
                          text: 'Cancel Ride',
                          onPressed: _cancelRide,
                          isLoading: _isCancelling,
                          isOutlined: true,
                          color: AppColors.error,
                          textColor: AppColors.error,
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Finding driver...';
      case 'accepted':
        return 'Driver assigned • On the way';
      case 'arrived':
        return 'Driver arrived';
      case 'started':
        return 'Trip in progress';
      case 'completed':
        return 'Trip completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return AppColors.warning;
      case 'accepted':
        return AppColors.info;
      case 'arrived':
        return AppColors.success;
      case 'started':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildStatusTimeline(String status) {
    final List<Map<String, dynamic>> statuses = [
      {'key': 'requested', 'label': 'Requested', 'icon': Icons.search},
      {'key': 'accepted', 'label': 'Driver Assigned', 'icon': Icons.person},
      {'key': 'arrived', 'label': 'Driver Arrived', 'icon': Icons.location_on},
      {'key': 'started', 'label': 'Trip Started', 'icon': Icons.directions_car},
      {'key': 'completed', 'label': 'Trip Completed', 'icon': Icons.flag},
    ];

    int currentIndex = statuses.indexWhere((s) => s['key'] == status);
    if (currentIndex == -1 && status == 'cancelled') {
      currentIndex = 0;
    }

    return Column(
      children: [
        Row(
          children: List.generate(statuses.length, (index) {
            final isCompleted = index <= currentIndex && status != 'cancelled';
            final isLast = index == statuses.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isCompleted ? AppColors.primary : AppColors.greyLight,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      statuses[index]['icon'] as IconData,
                      size: 16,
                      color: isCompleted ? Colors.white : AppColors.grey,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted && index < currentIndex
                            ? AppColors.primary
                            : AppColors.greyLight,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(statuses.length, (index) {
            return Expanded(
              child: Text(
                statuses[index]['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: index <= currentIndex && status != 'cancelled'
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: index == currentIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Ride ride) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              ride.driverName?[0].toUpperCase() ?? 'D',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName ?? 'Driver',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${ride.vehicleModel} • ${ride.vehiclePlate}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (_currentStatus == 'accepted')
                  Text(
                    '${ride.distanceKm?.toStringAsFixed(1) ?? '0'} km away',
                    style: TextStyle(fontSize: 10, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary),
            onPressed: () {
              final phone = ride.driverPhone;
              if (phone != null) {
                // Use url_launcher to call
                // launch('tel:$phone');
              }
            },
          ),
        ],
      ),
    );
  }
}