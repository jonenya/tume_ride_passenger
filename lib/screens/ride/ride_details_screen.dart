import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tume_ride_passenger/models/ride.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/utils/formatters.dart';  // ← ADD THIS IMPORT
import 'package:tume_ride_passenger/config/app_colors.dart';
class RideDetailsScreen extends StatefulWidget {
  final int rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  Ride? _ride;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRideDetails();
  }

  Future<void> _loadRideDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final response = await rideProvider.getRideById(widget.rideId);

      print('📡 Ride Details Response: $response');

      if (mounted) {
        if (response['status'] == 'success') {
          // Try different response structures
          dynamic rideData;
          if (response['data'] != null && response['data']['ride'] != null) {
            rideData = response['data']['ride'];
          } else if (response['ride'] != null) {
            rideData = response['ride'];
          } else if (response['data'] != null && response['data']['id'] != null) {
            rideData = response['data'];
          }

          if (rideData != null) {
            _ride = Ride.fromJson(rideData);
            print('✅ Ride loaded: ${_ride!.rideCode}, Status: ${_ride!.status}');
          } else {
            _error = 'Ride data not found';
          }
        } else if (response['status'] == 'error') {
          _error = response['message'] ?? 'Failed to load ride details';
        } else {
          _error = 'Ride not found';
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading ride details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
          ? _buildErrorView()
          : _ride == null
          ? _buildEmptyView()
          : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRideDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ride details not available'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                      Text(
                        Formatters.formatDateTime(_ride!.completedAt ?? _ride!.requestedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Route
          const Text(
            'Route',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _RoutePoint(
                  icon: Icons.circle,
                  color: AppColors.success,
                  label: 'Pickup',
                  address: _ride!.pickupAddress,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 2,
                  height: 30,
                  margin: const EdgeInsets.only(left: 11),
                  color: AppColors.greyLight,
                ),
                const SizedBox(height: 16),
                _RoutePoint(
                  icon: Icons.location_on,
                  color: AppColors.secondary,
                  label: 'Destination',
                  address: _ride!.destinationAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Trip Info
          if (_ride!.distanceKm != null || _ride!.durationMin != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (_ride!.distanceKm != null)
                    Column(
                      children: [
                        const Icon(Icons.straighten, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatDistance(_ride!.distanceKm!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Distance', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  if (_ride!.durationMin != null)
                    Column(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatDuration(_ride!.durationMin!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Duration', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Fare Breakdown
          const Text(
            'Fare Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _FareRow(
                  label: 'Base Fare',
                  amount: _ride!.fareEstimate * 0.3,
                ),
                _FareRow(
                  label: 'Distance (${_ride!.distanceKm?.toStringAsFixed(1) ?? '0'} km)',
                  amount: (_ride!.distanceKm ?? 0) * 50,
                ),
                _FareRow(
                  label: 'Time (${_ride!.durationMin ?? 0} min)',
                  amount: (_ride!.durationMin ?? 0) * 10,
                ),
                const Divider(),
                _FareRow(
                  label: 'Total',
                  amount: _ride!.finalFare,
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Driver Info
          if (_ride!.hasDriver) ...[
            const Text(
              'Driver Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _ride!.driverName?[0].toUpperCase() ?? 'D',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ride!.driverName ?? 'Driver',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_ride!.vehicleModel ?? ''} ${_ride!.vehiclePlate ?? ''}'.trim(),
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (_ride!.vehicleColor != null && _ride!.vehicleColor!.isNotEmpty)
                          Text(
                            'Color: ${_ride!.vehicleColor}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    onPressed: () {
                      final phone = _ride!.driverPhone;
                      if (phone != null && phone.isNotEmpty) {
                        // Use url_launcher to call
                        // launch('tel:$phone');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Payment Info
          const Text(
            'Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_getPaymentIcon(), size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(_getPaymentText()),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _ride!.paymentStatus == 'completed'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _ride!.paymentStatus == 'completed' ? 'Paid' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: _ride!.paymentStatus == 'completed'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_ride!.paymentMethod == 'mpesa' && _ride!.paymentStatus == 'completed')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Paid via M-Pesa',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_ride?.status == 'completed') return AppColors.success;
    if (_ride?.status == 'cancelled') return AppColors.error;
    if (_ride?.status == 'started') return AppColors.primary;
    if (_ride?.status == 'accepted') return AppColors.info;
    return AppColors.warning;
  }

  IconData _getStatusIcon() {
    if (_ride?.status == 'completed') return Icons.check_circle;
    if (_ride?.status == 'cancelled') return Icons.cancel;
    if (_ride?.status == 'started') return Icons.directions_car;
    if (_ride?.status == 'accepted') return Icons.person;
    return Icons.hourglass_empty;
  }

  String _getStatusText() {
    if (_ride?.status == 'completed') return 'Completed';
    if (_ride?.status == 'cancelled') return 'Cancelled';
    if (_ride?.status == 'started') return 'In Progress';
    if (_ride?.status == 'accepted') return 'Driver Assigned';
    if (_ride?.status == 'requested') return 'Finding Driver';
    if (_ride?.status == 'arrived') return 'Driver Arrived';
    return _ride?.status?.toUpperCase() ?? 'Unknown';
  }

  IconData _getPaymentIcon() {
    switch (_ride?.paymentMethod) {
      case 'app':
        return Icons.phone_android;
      case 'mpesa':
        return Icons.phone;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentText() {
    switch (_ride?.paymentMethod) {
      case 'app':
        return 'M-Pesa (App)';
      case 'mpesa':
        return 'M-Pesa Direct';
      case 'cash':
        return 'Cash';
      default:
        return 'Unknown';
    }
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _RoutePoint({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _FareRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}