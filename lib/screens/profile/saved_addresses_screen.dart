import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/widgets/confirmation_dialog.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  Map<String, dynamic>? _addresses;
  List<dynamic> _customAddresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    final response = await api.get(ApiConstants.profile, queryParams: {
      'action': ApiConstants.addresses,
    });
    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        _addresses = response['data'];
        _customAddresses = response['data']['custom'] ?? [];
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteAddress(int addressId) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Address',
      message: 'Are you sure you want to delete this address?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    final api = ApiService();
    final response = await api.post(ApiConstants.profile, data: {
      'action': ApiConstants.deleteAddress,
      'address_id': addressId,
    });
    if (response['status'] == 'success') {
      showSnackBar(context, message: 'Address deleted successfully');
      _loadAddresses();
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to delete address',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-address'),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_addresses?['home'] != null)
            _AddressCard(
              title: 'Home',
              icon: Icons.home,
              color: AppColors.primary,
              address: _addresses!['home'],
              isEditable: true,
              onEdit: () => context.push('/add-address', extra: {
                'type': 'home',
                'address': _addresses!['home'],
              }),
            ),
          const SizedBox(height: 12),
          if (_addresses?['work'] != null)
            _AddressCard(
              title: 'Work',
              icon: Icons.work,
              color: AppColors.secondary,
              address: _addresses!['work'],
              isEditable: true,
              onEdit: () => context.push('/add-address', extra: {
                'type': 'work',
                'address': _addresses!['work'],
              }),
            ),
          const SizedBox(height: 12),
          if (_customAddresses.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Saved Places',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._customAddresses.map((address) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AddressCard(
                title: address['name'],
                icon: Icons.place,
                color: AppColors.accent,
                address: address['address'],
                isEditable: true,
                onEdit: () => context.push('/add-address', extra: {
                  'address_id': address['id'],
                  'name': address['name'],
                  'address': address['address'],
                  'lat': address['lat'],
                  'lng': address['lng'],
                }),
                onDelete: () => _deleteAddress(address['id']),
              ),
            )),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/add-address'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text('Add New Address'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String address;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AddressCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.address,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isEditable)
            Row(
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}