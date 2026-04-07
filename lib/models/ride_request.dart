// lib/screens/ride/request_ride_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/providers/promo_provider.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
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
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isApplyingPromo = false;
  double _fareEstimate = 0;
  double _discount = 0;
  double _finalFare = 0;
  String? _appliedPromoCode;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _calculateFare();
  }

  Future<void> _calculateFare() async {
    // TODO: Call backend to calculate fare based on distance and category
    // For now using placeholder
    setState(() {
      _fareEstimate = 350.00;
      _finalFare = _fareEstimate;
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
    final response = await promoProvider.validatePromo(promoCode, _fareEstimate);

    setState(() => _isApplyingPromo = false);

    if (response['status'] == 'success') {
      final data = response['data'];
      setState(() {
        _discount = data['discount'] ?? 0;
        _finalFare = data['new_fare'] ?? _fareEstimate;
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
      _finalFare = _fareEstimate;
      _appliedPromoCode = null;
      _promoCodeController.clear();
    });
    Provider.of<PromoProvider>(context, listen: false).clearAppliedPromo();
    showSnackBar(context, message: 'Promo removed');
  }

  Future<void> _requestRide() async {
    setState(() => _isRequesting = true);

    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    final data = {
      'pickup_lat': widget.pickupLat,
      'pickup_lng': widget.pickupLng,
      'pickup_address': widget.pickupAddress,
      'destination_lat': widget.destinationLat,
      'destination_lng': widget.destinationLng,
      'destination_address': widget.destinationAddress,
      'category': widget.category ?? 'basic_car',
      'payment_method': 'mpesa',
    };

    // Add promo code if applied
    if (_appliedPromoCode != null) {
      data['promo_code'] = _appliedPromoCode;
    }

    print('📡 Requesting ride with data: $data');

    final response = await rideProvider.requestRide(data);

    setState(() => _isRequesting = false);

    if (response['status'] == 'success') {
      final rideData = response['data'];
      if (mounted) {
        context.pushReplacement('/tracking', extra: {
          'ride_id': rideData['ride_id'],
          'ride_code': rideData['ride_code'],
        });
      }
    } else {
      showSnackBar(context, message: response['message'] ?? 'Failed to request ride', isError: true);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 12, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pickup', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(widget.pickupAddress ?? 'Not selected'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destination', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(widget.destinationAddress ?? 'Not selected'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Category'),
                  Text(
                    widget.category?.toUpperCase() ?? 'BASIC CAR',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Promo Code Section - ADD THIS
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
            const SizedBox(height: 16),

            // Fare Breakdown
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
                      const Text('Fare Estimate'),
                      Text(Formatters.formatCurrency(_fareEstimate)),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          Formatters.formatCurrency(_finalFare),
                          style: const TextStyle(
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          Formatters.formatCurrency(_finalFare),
                          style: const TextStyle(
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

            // Request Button
            CustomButton(
              text: 'Request Ride',
              onPressed: _requestRide,
              isLoading: _isRequesting,
            ),
          ],
        ),
      ),
    );
  }
}