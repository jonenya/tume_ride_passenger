import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/screens/profile/edit_profile_screen.dart';
import 'package:tume_ride_passenger/screens/profile/saved_addresses_screen.dart';
import 'package:tume_ride_passenger/screens/profile/emergency_contacts_screen.dart';
import 'package:tume_ride_passenger/screens/profile/settings_screen.dart';
import 'package:tume_ride_passenger/widgets/confirmation_dialog.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user?.profilePic != null
                            ? NetworkImage(user!.profilePic!)
                            : null,
                        backgroundColor: AppColors.primaryLight,
                        child: user?.profilePic == null
                            ? Text(
                          user?.firstName[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            context.push('/edit-profile');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _StatsCard(user: user),
                ],
              ),
            ),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.location_on,
                    title: 'Saved Addresses',
                    subtitle: 'Home, Work, and more',
                    onTap: () {
                      context.push('/saved-addresses');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.emergency,
                    title: 'Emergency Contacts',
                    subtitle: 'Share trip with trusted contacts',
                    onTap: () {
                      context.push('/emergency-contacts');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.card_giftcard,
                    title: 'Refer & Earn',
                    subtitle: 'Invite friends, earn rewards',
                    onTap: () {
                      context.push('/referral');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.history,
                    title: 'Ride History',
                    subtitle: 'View all your past rides',
                    onTap: () {
                      context.push('/ride-history');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.wallet,
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    onTap: () {
                      context.push('/payment-methods');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Support
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Language, notifications, privacy',
                    onTap: () {
                      context.push('/settings');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQs, contact us, report issue',
                    onTap: () {
                      context.push('/support');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.security,
                    title: 'Safety Center',
                    subtitle: 'Safety tips and emergency tools',
                    onTap: () {
                      context.push('/safety-center');
                    },
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version, terms, privacy',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () async {
                  final confirmed = await showConfirmationDialog(
                    context,
                    title: 'Logout',
                    message: 'Are you sure you want to logout?',
                    confirmText: 'Logout',
                    cancelText: 'Cancel',
                    isDestructive: true,
                  );
                  if (confirmed) {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Tume Ride',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'T',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        applicationLegalese: '© 2024 Tume Ride. All rights reserved.',
        children: [
          const SizedBox(height: 16),
          const Text('Safe, reliable, and affordable rides in Kenya.'),
          const SizedBox(height: 8),
          Text(
            'Terms of Service | Privacy Policy',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final dynamic user;

  const _StatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: user?.totalRides?.toString() ?? '0',
            label: 'Rides',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.greyLight,
          ),
          _StatItem(
            value: user?.ratingAvg?.toStringAsFixed(1) ?? '5.0',
            label: 'Rating',
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.greyLight,
          ),
          _StatItem(
            value: 'KES ${user?.totalSpent?.toStringAsFixed(0) ?? '0'}',
            label: 'Spent',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.greyLight,
      indent: 56,
    );
  }
}
