import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/widgets/confirmation_dialog.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final response = await api.get(ApiConstants.profile, queryParams: {
      'action': ApiConstants.emergencyContacts,
    });
    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        _contacts = response['data']['contacts'] ?? [];
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteContact(int contactId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Contact',
      message: 'Are you sure you want to remove this emergency contact?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    final api = ApiService();
    final response = await api.post(ApiConstants.profile, data: {
      'action': ApiConstants.deleteEmergencyContact,
      'contact_id': contactId,
    });
    if (response['status'] == 'success') {
      showSnackBar(context, message: 'Contact deleted successfully');
      _loadContacts();
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to delete contact',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/add-emergency-contact').then((_) => _loadContacts());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _contacts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No emergency contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Add contacts to share your ride location',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/add-emergency-contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Contact'),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return _EmergencyContactCard(
            contact: contact,
            onDelete: () => _deleteContact(contact['id']),
          );
        },
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final dynamic contact;
  final VoidCallback onDelete;

  const _EmergencyContactCard({
    required this.contact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  contact['phone'],
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.call, color: AppColors.primary),
                onPressed: () {
                  // TODO: Make phone call
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}