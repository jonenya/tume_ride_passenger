import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class ShareTripScreen extends StatefulWidget {
  const ShareTripScreen({super.key});

  @override
  State<ShareTripScreen> createState() => _ShareTripScreenState();
}

class _ShareTripScreenState extends State<ShareTripScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  bool _isSharing = false;
  List<int> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    // TODO: Load emergency contacts from API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _contacts = [
        {'id': 1, 'name': 'Jane Doe', 'phone': '0712345678', 'selected': false},
        {'id': 2, 'name': 'John Smith', 'phone': '0723456789', 'selected': false},
        {'id': 3, 'name': 'Mary Wanjiku', 'phone': '0734567890', 'selected': false},
      ];
      _isLoading = false;
    });
  }

  Future<void> _shareTrip() async {
    if (_selectedContacts.isEmpty) {
      showSnackBar(context, message: 'Please select at least one contact', isError: true);
      return;
    }

    setState(() => _isSharing = true);

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final activeRide = rideProvider.activeRide;

    if (activeRide == null) {
      showSnackBar(context, message: 'No active ride to share', isError: true);
      setState(() => _isSharing = false);
      return;
    }

    // Create share message
    final shareMessage = '''
🚗 Tume Ride Trip Sharing

I'm currently on a ride with Tume Ride!

Ride Code: ${activeRide.rideCode}
Pickup: ${activeRide.pickupAddress}
Destination: ${activeRide.destinationAddress}
Driver: ${activeRide.driverName ?? 'Assigned soon'}

Track my ride live: https://tumeride.com/track/${activeRide.rideCode}
''';

    // Share via SMS for selected contacts
    for (final contactId in _selectedContacts) {
      final contact = _contacts.firstWhere((c) => c['id'] == contactId);
      // TODO: Send SMS via API
    }

    // Also share via share sheet
    await Share.share(shareMessage);

    // TODO: Notify backend that trip was shared

    setState(() => _isSharing = false);

    if (mounted) {
      showSnackBar(context, message: 'Trip shared with selected contacts');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final activeRide = rideProvider.activeRide;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Trip'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Column(
        children: [
          // Active Ride Info
          if (activeRide != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.ride_share, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Active Ride',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeRide.rideCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeRide.pickupAddress,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(Icons.arrow_downward, size: 16),
                  Text(
                    activeRide.destinationAddress,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No active ride. Share trip only works during an active ride.',
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Contacts List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select contacts to share with',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _contacts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No emergency contacts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add contacts in profile settings',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/emergency-contacts');
                    },
                    child: const Text('Add Contacts'),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                final isSelected = _selectedContacts.contains(contact['id']);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedContacts.add(contact['id']);
                      } else {
                        _selectedContacts.remove(contact['id']);
                      }
                    });
                  },
                  title: Text(contact['name']),
                  subtitle: Text(contact['phone']),
                  secondary: const Icon(Icons.person, color: AppColors.primary),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),

          // Share Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Share Trip',
              onPressed: _shareTrip,
              isLoading: _isSharing,
              disabled: activeRide == null,
            ),
          ),
        ],
      ),
    );
  }
}
