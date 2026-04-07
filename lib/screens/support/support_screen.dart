import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/screens/support/chat_support_screen.dart';
import 'package:tume_ride_passenger/screens/support/report_issue_screen.dart';
import 'package:tume_ride_passenger/screens/support/faq_screen.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FAQ Section
          _SupportCard(
            icon: Icons.help_outline,
            title: 'Frequently Asked Questions',
            subtitle: 'Find answers to common questions',
            color: AppColors.primary,
            onTap: () {
              context.push('/faq');
            },
          ),
          const SizedBox(height: 12),

          // Chat Support
          _SupportCard(
            icon: Icons.chat,
            title: 'Live Chat Support',
            subtitle: 'Chat with our support team',
            color: AppColors.success,
            onTap: () {
              context.push('/chat-support');
            },
          ),
          const SizedBox(height: 12),

          // Report Issue
          _SupportCard(
            icon: Icons.report_problem,
            title: 'Report an Issue',
            subtitle: 'Report ride or payment issues',
            color: AppColors.warning,
            onTap: () {
              context.push('/report-issue');
            },
          ),
          const SizedBox(height: 12),

          // Call Support
          _SupportCard(
            icon: Icons.call,
            title: 'Call Support',
            subtitle: 'Talk to a support agent',
            color: AppColors.secondary,
            onTap: () {
              // TODO: Make phone call
            },
          ),
          const SizedBox(height: 12),

          // Email Support
          _SupportCard(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@tumeride.com',
            color: AppColors.info,
            onTap: () {
              // TODO: Open email
            },
          ),
          const SizedBox(height: 24),

          // Emergency Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Emergency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you are in immediate danger, please contact local emergency services.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Call police
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Police: 999'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Call ambulance
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Ambulance: 999'),
                      ),
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
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportCard({
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
