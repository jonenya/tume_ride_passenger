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

  @override
  void initState() {
    super.initState();
    // Start polling when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      rideProvider.startPolling();
    });
    _startTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Stop polling when screen closes
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.stopPolling();
    super.dispose();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateRideStatus();
    });
    _updateRideStatus();
  }

  Future<void> _updateRideStatus() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.getActiveRide();

    final ride = rideProvider.activeRide;
    if (ride != null && mounted) {
      // Check if status changed
      if (_currentStatus != ride.status) {
        print('🚗 Status changed: $_currentStatus → ${ride.status}');
        setState(() {
          _currentStatus = ride.status;
        });

        // Show notification for status change
        if (ride.status == 'accepted') {
          showSnackBar(context, message: 'Driver has accepted your ride!');
        } else if (ride.status == 'arrived') {
          showSnackBar(context, message: 'Driver has arrived at your location');
        } else if (ride.status == 'started') {
          showSnackBar(context, message: 'Trip has started!');
        } else if (ride.status == 'completed') {
          showSnackBar(context, message: 'Trip completed!');
          _timer?.cancel();
          rideProvider.stopPolling();
          if (mounted) {
            context.pushReplacement(AppRoutes.rideCompleted, extra: {
              'ride_id': ride.id,
              'fare': ride.finalFare,
              'driver_name': ride.driverName,
              'vehicle_model': ride.vehicleModel,
              'vehicle_plate': ride.vehiclePlate,
            });
          }
        } else if (ride.status == 'cancelled') {
          showSnackBar(context, message: 'Ride has been cancelled', isError: true);
          _timer?.cancel();
          rideProvider.stopPolling();
          if (mounted) {
            context.go(AppRoutes.home);
          }
        }
      }

      _updateMarkers(ride);

      // Animate camera to driver if trip started
      if ((ride.status == 'accepted' || ride.status == 'started') &&
          ride.driverLat != null && ride.driverLng != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(ride.driverLat!, ride.driverLng!),
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  void _updateMarkers(dynamic ride) {
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

    setState(() => _isCancelling = true);

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final response = await rideProvider.cancelRide(widget.rideId);

    setState(() => _isCancelling = false);

    if (response['status'] == 'success') {
      rideProvider.stopPolling();
      showSnackBar(context, message: 'Ride cancelled successfully');
      context.go(AppRoutes.home);
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
    final ride = rideProvider.activeRide;

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
                          _getStatusText(ride.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(ride.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (ride.status == 'requested' || ride.status == 'accepted')
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
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.6,
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
                      _buildStatusTimeline(ride.status),
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
                      if (ride.status == 'requested')
                        CustomButton(
                          text: 'Cancel Ride',
                          onPressed: _cancelRide,
                          isLoading: _isCancelling,
                          isOutlined: true,
                          backgroundColor: AppColors.error,
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

  Widget _buildDriverCard(dynamic ride) {
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
                if (ride.status == 'accepted')
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
              // Call driver
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
}