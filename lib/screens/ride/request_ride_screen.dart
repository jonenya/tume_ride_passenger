import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/providers/promo_provider.dart';
import 'package:tume_ride_passenger/providers/location_provider.dart';
import 'package:tume_ride_passenger/models/ride_category.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/utils/formatters.dart';

class RequestRideScreen extends StatefulWidget {
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? destinationAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? category;

  const RequestRideScreen({
    super.key,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.destinationAddress,
    this.destinationLat,
    this.destinationLng,
    this.category,
  });

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  RideCategory? _selectedCategory;
  String? _selectedPaymentMethod = 'app';
  double? _fareEstimate;
  bool _isLoading = false;

  // Promo code related
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isApplyingPromo = false;
  double _discount = 0;
  double _finalFare = 0;
  String? _appliedPromoCode;

  final List<String> _paymentMethods = ['app', 'mpesa_direct', 'cash'];
  final Map<String, String> _paymentMethodNames = {
    'app': 'Pay via App',
    'mpesa_direct': 'M-Pesa Direct',
    'cash': 'Cash'
  };

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedCategory = RideCategory.getCategories()
          .firstWhere((c) => c.code == widget.category);
    }
    _calculateFare();
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _calculateFare() async {
    if (_selectedCategory == null) return;

    double distance = 4.2;
    if (widget.pickupLat != null && widget.pickupLng != null &&
        widget.destinationLat != null && widget.destinationLng != null) {
      distance = _calculateDistance(
        widget.pickupLat!,
        widget.pickupLng!,
        widget.destinationLat!,
        widget.destinationLng!,
      );
    }

    int duration = (distance * 2).ceil();

    Map<String, Map<String, double>> pricing = {
      'bikes': {'base': 50, 'per_km': 30, 'per_min': 10, 'min': 80},
      'electric_bikes': {'base': 60, 'per_km': 35, 'per_min': 12, 'min': 100},
      'tuktuk': {'base': 70, 'per_km': 40, 'per_min': 14, 'min': 120},
      'basic_car': {'base': 100, 'per_km': 50, 'per_min': 10, 'min': 150},
      'basic_electric': {'base': 110, 'per_km': 55, 'per_min': 11, 'min': 165},
      'women_only': {'base': 100, 'per_km': 50, 'per_min': 10, 'min': 150},
      'send_parcel': {'base': 80, 'per_km': 45, 'per_min': 8, 'min': 130},
      'comfort': {'base': 150, 'per_km': 70, 'per_min': 15, 'min': 200},
      'comfort_electric': {'base': 160, 'per_km': 75, 'per_min': 16, 'min': 220},
      'xl_7_seater': {'base': 200, 'per_km': 90, 'per_min': 20, 'min': 300},
    };

    final catPricing = pricing[_selectedCategory!.code] ?? pricing['basic_car'];

    double fare = catPricing!['base']! +
        (distance * catPricing['per_km']!) +
        (duration * catPricing['per_min']!);
    fare = fare < catPricing['min']! ? catPricing['min']! : fare;

    setState(() {
      _fareEstimate = fare;
      _finalFare = fare;
      _discount = 0;
    });
  }

  Future<void> _applyPromo() async {
    final promoCode = _promoCodeController.text.trim().toUpperCase();
    if (promoCode.isEmpty) {
      showSnackBar(context, message: 'Enter promo code', isError: true);
      return;
    }

    setState(() => _isApplyingPromo = true);

    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    final response = await promoProvider.validatePromo(promoCode, _fareEstimate ?? 0);

    print('📡 Promo validation response: $response');

    setState(() => _isApplyingPromo = false);

    if (response['status'] == 'success') {
      final data = response['data'];
      double discount = 0;
      double newFare = _fareEstimate ?? 0;

      if (data != null) {
        discount = data['discount'] is double
            ? data['discount']
            : double.tryParse(data['discount'].toString()) ?? 0;
        newFare = data['new_fare'] is double
            ? data['new_fare']
            : double.tryParse(data['new_fare'].toString()) ?? (_fareEstimate ?? 0);
      }

      setState(() {
        _discount = discount;
        _finalFare = newFare;
        _appliedPromoCode = promoCode;
      });
      showSnackBar(context, message: 'Promo applied! You saved KES ${_discount.toStringAsFixed(0)}');
    } else {
      showSnackBar(context, message: response['message'] ?? 'Invalid promo code', isError: true);
    }
  }

  Future<void> _removePromo() async {
    setState(() {
      _discount = 0;
      _finalFare = _fareEstimate ?? 0;
      _appliedPromoCode = null;
      _promoCodeController.clear();
    });
    Provider.of<PromoProvider>(context, listen: false).clearAppliedPromo();
    showSnackBar(context, message: 'Promo removed');
  }

  Future<void> _requestRide() async {
    if (_selectedCategory == null) {
      showSnackBar(context, message: 'Select a ride category', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    String categoryCode = _selectedCategory!.code;
    Map<String, String> categoryMapping = {
      'bike': 'bikes',
      'electric_bike': 'electric_bikes',
    };

    if (categoryMapping.containsKey(categoryCode)) {
      categoryCode = categoryMapping[categoryCode]!;
    }

    final requestData = {
      'pickup_lat': widget.pickupLat ?? locationProvider.currentPosition?.latitude,
      'pickup_lng': widget.pickupLng ?? locationProvider.currentPosition?.longitude,
      'pickup_address': widget.pickupAddress ?? locationProvider.currentAddress ?? 'Current Location',
      'destination_lat': widget.destinationLat,
      'destination_lng': widget.destinationLng,
      'destination_address': widget.destinationAddress ?? 'Destination',
      'category': categoryCode,
      'payment_method': _selectedPaymentMethod,
    };

    // Add promo code if applied
    if (_appliedPromoCode != null && _appliedPromoCode!.isNotEmpty) {
      requestData['promo_code'] = _appliedPromoCode;
    }

    print('📡 Requesting ride with data: $requestData');

    final response = await rideProvider.requestRide(requestData);

    setState(() => _isLoading = false);

    print('📦 Ride request response: $response');

    if (response['status'] == 'success') {
      final rideData = response['data'];
      if (mounted) {
        rideProvider.startPolling();
        context.pushReplacement(
            AppRoutes.tracking,
            extra: {
              'ride_id': rideData['ride_id'],
              'ride_code': rideData['ride_code'],
            }
        );
      }
    } else {
      final errorMsg = response['message'] ?? 'Failed to request ride';
      print('❌ Error: $errorMsg');
      if (mounted) {
        showSnackBar(context, message: errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ride'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup and Destination
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pickup',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              widget.pickupAddress ?? 'Select pickup',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Destination',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              widget.destinationAddress ?? 'Select destination',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ride Type Selection
            const Text(
              'Select Ride Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: RideCategory.getCategories().length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = RideCategory.getCategories()[index];
                  final isSelected = _selectedCategory?.code == category.code;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _calculateFare();
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? category.color : AppColors.greyLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(category.icon, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            category.nameEn,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? category.color : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ========== PROMO CODE SECTION ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Promo Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_appliedPromoCode == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoCodeController,
                            decoration: const InputDecoration(
                              hintText: 'Enter promo code',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isApplyingPromo ? null : _applyPromo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(80, 48),
                          ),
                          child: _isApplyingPromo
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Apply'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Applied: $_appliedPromoCode',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          GestureDetector(
                            onTap: _removePromo,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fare Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fare Estimate', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        Formatters.formatCurrency(_fareEstimate ?? 0),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (_discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount', style: TextStyle(color: AppColors.success)),
                        Text(
                          '- ${Formatters.formatCurrency(_discount)}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          Formatters.formatCurrency(_finalFare),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          Formatters.formatCurrency(_fareEstimate ?? 0),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) {
              return RadioListTile<String>(
                title: Text(_paymentMethodNames[method]!),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 24),

            // Request Button
            CustomButton(
              text: 'Request Ride',
              onPressed: _requestRide,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}