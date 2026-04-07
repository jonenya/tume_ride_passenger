import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/config/app_routes.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/providers/promo_provider.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    await promoProvider.loadPromos();
  }

  String _getPromoText(Map<String, dynamic> promo) {
    final type = promo['promo_type'];
    final value = promo['value'];

    if (type == 'percentage') {
      return '${value.toStringAsFixed(0)}% OFF';
    } else if (type == 'fixed') {
      return 'KES ${value.toStringAsFixed(0)} OFF';
    } else if (type == 'free_ride') {
      return 'FREE RIDE';
    }
    return 'Special Offer';
  }

  String _getPromoCode(Map<String, dynamic> promo) {
    return promo['promo_code'] ?? 'PROMO';
  }

  @override
  Widget build(BuildContext context) {
    final promoProvider = Provider.of<PromoProvider>(context);
    final activePromos = promoProvider.activePromos;

    // Show loading or nothing while loading
    if (promoProvider.isLoading) {
      return const SizedBox.shrink();
    }

    // Don't show banner if no active promos
    if (activePromos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the first active promo
    final promo = activePromos.first;
    final promoText = _getPromoText(promo);
    final promoCode = _getPromoCode(promo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(AppRoutes.promos);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get $promoText',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use code: $promoCode',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}