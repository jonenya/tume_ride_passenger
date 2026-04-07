import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/providers/location_provider.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/providers/promo_provider.dart';  // ← ADD THIS IMPORT
import 'package:tume_ride_passenger/screens/home/widgets/category_grid.dart';
import 'package:tume_ride_passenger/screens/home/widgets/location_search_bar.dart';
import 'package:tume_ride_passenger/screens/home/widgets/promo_banner.dart';
import 'package:tume_ride_passenger/screens/home/map/custom_map.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/utils/formatters.dart';
import 'package:tume_ride_passenger/models/ride.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
      await Provider.of<RideProvider>(context, listen: false).getActiveRide();
      await Provider.of<RideProvider>(context, listen: false).getRideHistory(page: 1, limit: 5);
      await Provider.of<PromoProvider>(context, listen: false).loadPromos();  // ← ADD THIS LINE
    } catch (e) {
      print('Error loading data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final loc = Provider.of<LocationProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);

    if (_isLoading) return const Scaffold(body: Center(child: LoadingIndicator()));

    return Scaffold(
      body: Stack(children: [
        CustomMap(initialLat: loc.currentPosition?.latitude ?? -1.2921, initialLng: loc.currentPosition?.longitude ?? 36.8219, onMapCreated: (c) {}),
        SafeArea(child: Column(children: [
          Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]), child: Row(children: [
            CircleAvatar(backgroundImage: auth.user?.profilePic != null ? NetworkImage(auth.user!.profilePic!) : null, backgroundColor: AppColors.primaryLight, child: auth.user?.profilePic == null ? Text(auth.user?.firstName[0].toUpperCase() ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)) : null),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hello, ${auth.user?.firstName ?? 'Guest'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(loc.currentAddress ?? 'Nairobi, Kenya', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)])),
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push(AppRoutes.notifications)),
          ])),
          const LocationSearchBar(),
          const SizedBox(height: 16),
          const PromoBanner(),
        ])),
        DraggableScrollableSheet(
          initialChildSize: 0.52,
          minChildSize: 0.48,
          maxChildSize: 0.85,
          builder: (c, sc) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildTab('Ride Types', 0),
                      const SizedBox(width: 16),
                      _buildTab('Recent Rides', 1),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _selectedIndex = i),
                    children: [
                      CategoryGrid(
                        scrollController: sc,
                        onCategorySelected: (cat) => context.push(
                          AppRoutes.requestRide,
                          extra: {'category': cat.code},
                        ),
                      ),
                      _buildHistory(sc, rideProvider),
                    ],
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        ),
        if (rideProvider.hasActiveRide && rideProvider.activeRide != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => context.push(
                AppRoutes.tracking,
                extra: {
                  'ride_id': rideProvider.activeRide?.id,
                  'ride_code': rideProvider.activeRide?.rideCode,
                },
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Ride',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${rideProvider.activeRide?.status ?? 'In Progress'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildTab(String label, int index) => Expanded(
    child: GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedIndex == index
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: _selectedIndex == index
                ? FontWeight.w600
                : FontWeight.normal,
            color: _selectedIndex == index
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    ),
  );

  Widget _buildHistory(ScrollController sc, RideProvider rideProvider) {
    final recentRides = rideProvider.rides.take(5).toList();

    return ListView(
      controller: sc,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Rides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.rideHistory),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rideProvider.isLoading && recentRides.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (recentRides.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.history, size: 48, color: AppColors.grey),
                SizedBox(height: 12),
                Text(
                  'No recent rides yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Book a ride to see your history here',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentRides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = recentRides[index];
              return _buildRecentRideCard(ride);
            },
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRecentRideCard(Ride ride) {
    Color statusColor;
    switch (ride.status) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return GestureDetector(
      onTap: () => context.push(AppRoutes.rideDetails, extra: {'ride_id': ride.id}),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ride.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ride.pickupAddress,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ride.destinationAddress,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatDate(ride.requestedAt),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                Text(
                  Formatters.formatCurrency(ride.finalFare),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.greyLight)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(Icons.home, 'Home', 0),
        _navItem(Icons.history, 'History', 1),
        _navItem(Icons.wallet, 'Wallet', 2,
            onTap: () => context.push(AppRoutes.wallet)),
        _navItem(Icons.card_giftcard, 'Promos', 3,
            onTap: () => context.push(AppRoutes.promos)),
        _navItem(Icons.person, 'Profile', 4,
            onTap: () => context.push(AppRoutes.profile)),
      ],
    ),
  );

  Widget _navItem(IconData icon, String label, int index,
      {VoidCallback? onTap}) =>
      GestureDetector(
        onTap: () => onTap != null
            ? onTap()
            : _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index
                  ? AppColors.primary
                  : AppColors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == index
                    ? AppColors.primary
                    : AppColors.grey,
                fontWeight: _selectedIndex == index
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}