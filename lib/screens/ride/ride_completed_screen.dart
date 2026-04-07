import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/screens/ride/rate_driver_screen.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class RideCompletedScreen extends StatelessWidget {
  final int rideId;
  final double fare;
  final String driverName;
  final String? driverPhoto;
  final String vehicleModel;
  final String vehiclePlate;

  const RideCompletedScreen({
    super.key,
    required this.rideId,
    required this.fare,
    required this.driverName,
    this.driverPhoto,
    required this.vehicleModel,
    required this.vehiclePlate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Trip Completed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for riding with Tume Ride',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Paid',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${fare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                      backgroundImage: driverPhoto != null
                          ? NetworkImage(driverPhoto!)
                          : null,
                      child: driverPhoto == null
                          ? Text(
                        driverName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24),
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$vehicleModel • $vehiclePlate',
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
              const SizedBox(height: 32),
              CustomButton(
                text: 'Rate Your Driver',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RateDriverScreen(
                        rideId: rideId,
                        driverName: driverName,
                        driverPhoto: driverPhoto,
                        vehicleModel: vehicleModel,
                        vehiclePlate: vehiclePlate,
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.go('/home');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Maybe Later'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}