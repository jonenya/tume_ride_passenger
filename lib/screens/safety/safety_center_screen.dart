
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/screens/safety/emergency_sos_screen.dart';
import 'package:tume_ride_passenger/screens/safety/share_trip_screen.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SOS Button
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                context.push('/emergency-sos');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sos, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'SOS EMERGENCY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Share Trip
          _SafetyCard(
            icon: Icons.share_location,
            title: 'Share Trip Status',
            subtitle: 'Share your ride location with trusted contacts',
            color: AppColors.primary,
            onTap: () {
              context.push('/share-trip');
            },
          ),
          const SizedBox(height: 12),

          // Trusted Contacts
          _SafetyCard(
            icon: Icons.people,
            title: 'Trusted Contacts',
            subtitle: 'Manage your emergency contacts',
            color: AppColors.secondary,
            onTap: () {
              context.push('/emergency-contacts');
            },
          ),
          const SizedBox(height: 12),

          // Safety Tips
          _SafetyCard(
            icon: Icons.tips_and_updates,
            title: 'Safety Tips',
            subtitle: 'Learn how to stay safe while riding',
            color: AppColors.info,
            onTap: () {
              _showSafetyTips(context);
            },
          ),
          const SizedBox(height: 12),

          // RideCheck
          _SafetyCard(
            icon: Icons.check_circle,
            title: 'RideCheck',
            subtitle: 'Automatic ride monitoring for your safety',
            color: AppColors.success,
            onTap: () {
              _showRideCheckInfo(context);
            },
          ),
          const SizedBox(height: 24),

          // Safety Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Tume Ride Safety Commitment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'All drivers are vetted, rides are tracked, and we have 24/7 support to ensure your safety.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SafetyStat(
                      value: '100%',
                      label: 'Vetted Drivers',
                    ),
                    _SafetyStat(
                      value: '24/7',
                      label: 'Support',
                    ),
                    _SafetyStat(
                      value: 'Live',
                      label: 'Tracking',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSafetyTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Safety Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    _TipItem(
                      icon: Icons.verified_user,
                      title: 'Verify Your Driver',
                      description: 'Check the vehicle plate number and driver photo before getting in.',
                    ),
                    SizedBox(height: 16),
                    _TipItem(
                      icon: Icons.share,
                      title: 'Share Your Trip',
                      description: 'Always share your trip details with a trusted contact.',
                    ),
                    SizedBox(height: 16),
                    _TipItem(
                      icon: Icons.location_on,
                      title: 'Stay Aware',
                      description: 'Follow the route on your app and stay alert.',
                    ),
                    SizedBox(height: 16),
                    _TipItem(
                      icon: Icons.emergency,
                      title: 'Use SOS Button',
                      description: 'Press SOS if you feel unsafe. We\'ll alert authorities and your contacts.',
                    ),
                    SizedBox(height: 16),
                    _TipItem(
                      icon: Icons.star,
                      title: 'Rate Your Ride',
                      description: 'Your feedback helps maintain safety standards.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRideCheckInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What is RideCheck?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RideCheck uses sensors in your phone to detect potential issues during your ride:',
            ),
            SizedBox(height: 12),
            Text('• Unexpected long stops'),
            Text('• Route deviations'),
            Text('• Potential accidents'),
            SizedBox(height: 12),
            Text(
              'If detected, we\'ll check in with you to make sure you\'re safe.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SafetyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

class _SafetyStat extends StatelessWidget {
  final String value;
  final String label;

  const _SafetyStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}