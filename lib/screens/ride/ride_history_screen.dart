import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/screens/ride/ride_details_screen.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/widgets/empty_state.dart';
import 'package:tume_ride_passenger/utils/formatters.dart';  // ← MAKE SURE THIS IS HERE
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/models/ride.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      setState(() {});
    }

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.getRideHistory(page: _currentPage);

    if (refresh && mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        _currentPage++;
        _loadData().then((_) {
          if (mounted) {
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final rides = rideProvider.rides;

    print('📊 Building RideHistoryScreen with ${rides.length} rides');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(refresh: true),
          ),
        ],
      ),
      body: rideProvider.isLoading && rides.isEmpty
          ? const LoadingIndicator()
          : RefreshIndicator(
        onRefresh: () => _loadData(refresh: true),
        child: rides.isEmpty
            ? EmptyState(
          icon: Icons.history,
          title: 'No Rides Yet',
          message: 'Your ride history will appear here',
          actionText: 'Book a Ride',
          onAction: () {
            context.go('/home');
          },
        )
            : ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: rides.length + (_isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == rides.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final ride = rides[index];
            return _RideHistoryCard(
              ride: ride,
              onTap: () {
                context.push('/ride-details', extra: {
                  'ride_id': ride.id,
                });
              },
            );
          },
        ),
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;

  const _RideHistoryCard({
    required this.ride,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'started':
        return AppColors.primary;
      case 'accepted':
        return AppColors.info;
      case 'requested':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'started':
        return 'In Progress';
      case 'accepted':
        return 'Driver Assigned';
      case 'requested':
        return 'Finding Driver';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride.rideCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(ride.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(ride.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.pickupAddress,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.destinationAddress,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.greyLight),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatDate(ride.requestedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(ride.finalFare),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            // Show distance if available
            if (ride.distanceKm != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.straighten, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDistance(ride.distanceKm!),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}