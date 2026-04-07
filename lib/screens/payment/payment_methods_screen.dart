import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/services/api_service.dart';
import 'package:tume_ride_passenger/widgets/loading_indicator.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _methods = [];
  String? _defaultMethod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);

    final api = ApiService();
    final response = await api.get('/payment/methods.php');

    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        _methods = List<Map<String, dynamic>>.from(response['data']['methods']);
        _defaultMethod = response['data']['default_method'];
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _setDefaultMethod(String methodId) async {
    setState(() {
      _defaultMethod = methodId;
    });

    final api = ApiService();
    final response = await api.post('/payment/set-default.php', data: {
      'method_id': methodId,
    });

    if (response['status'] != 'success') {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to set default',
        isError: true,
      );
      _loadPaymentMethods();
    }
  }

  Future<void> _removeMethod(String methodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final api = ApiService();
    final response = await api.delete('/payment/method.php', queryParams: {
      'method_id': methodId,
    });

    if (response['status'] == 'success') {
      showSnackBar(context, message: 'Payment method removed');
      _loadPaymentMethods();
    } else {
      showSnackBar(
        context,
        message: response['message'] ?? 'Failed to remove method',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Add new payment method
            },
            child: const Text('Add New'),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final method = _methods[index];
          final isDefault = _defaultMethod == method['id'];
          return _PaymentMethodCard(
            method: method,
            isDefault: isDefault,
            onSetDefault: () => _setDefaultMethod(method['id']),
            onRemove: () => _removeMethod(method['id']),
          );
        },
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final Map<String, dynamic> method;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  const _PaymentMethodCard({
    required this.method,
    required this.isDefault,
    required this.onSetDefault,
    required this.onRemove,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'mpesa':
        return Icons.phone_android;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDefault ? AppColors.primary : AppColors.greyLight,
          width: isDefault ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(method['type']),
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (method['details'] != null)
                      Text(
                        method['details'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.greyLight),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isDefault)
                TextButton(
                  onPressed: onSetDefault,
                  child: const Text('Set as Default'),
                ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
