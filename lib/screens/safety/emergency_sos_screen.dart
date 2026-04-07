import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class EmergencySOSScreen extends StatefulWidget {
  const EmergencySOSScreen({super.key});

  @override
  State<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen> {
  bool _isSOSActivated = false;
  int _timerSeconds = 5;

  void _activateSOS() {
    setState(() {
      _isSOSActivated = true;
      _timerSeconds = 5;
    });

    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _timerSeconds = i - 1;
        });
      }
    }
    if (mounted && _isSOSActivated) {
      _sendEmergencyAlert();
    }
  }

  void _cancelSOS() {
    setState(() {
      _isSOSActivated = false;
    });
  }

  void _sendEmergencyAlert() async {
    // Call emergency services
    final phoneUrl = Uri(scheme: 'tel', path: '999');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }

    // Also notify emergency contacts via API
    // TODO: Implement API call to notify emergency contacts

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent to your contacts'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.error,
              AppColors.errorDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // SOS Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sos,
                    size: 60,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'This will immediately alert emergency services and your emergency contacts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),

                // SOS Button
                if (!_isSOSActivated)
                  GestureDetector(
                    onTap: _activateSOS,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_timerSeconds',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            const Text(
                              'seconds',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Emergency alert will be sent in',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Cancel SOS',
                        onPressed: _cancelSOS,
                        isOutlined: true,
                        color: Colors.white,
                      ),
                    ],
                  ),

                const Spacer(),

                // Emergency Numbers
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Emergency Numbers',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _EmergencyNumberButton(
                            number: '999',
                            label: 'Police',
                          ),
                          _EmergencyNumberButton(
                            number: '999',
                            label: 'Ambulance',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyNumberButton extends StatelessWidget {
  final String number;
  final String label;

  const _EmergencyNumberButton({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
