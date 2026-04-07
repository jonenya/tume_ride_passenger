import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/providers/ride_provider.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/widgets/custom_text_field.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';
import 'package:tume_ride_passenger/config/api_constants.dart';

class RateDriverScreen extends StatefulWidget {
  final int rideId;
  final String driverName;
  final String? driverPhoto;
  final String vehicleModel;
  final String vehiclePlate;

  const RateDriverScreen({
    super.key,
    required this.rideId,
    required this.driverName,
    this.driverPhoto,
    required this.vehicleModel,
    required this.vehiclePlate,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  final List<String> _ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      showSnackBar(context, message: 'Please select a rating', isError: true);
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);

      final response = await rideProvider.rateRide(
        widget.rideId,
        _rating,
        feedback: _feedbackController.text.trim().isEmpty
            ? null
            : _feedbackController.text.trim(),
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        showSnackBar(context, message: 'Thank you for your feedback!');

        // Navigate to home after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Clear any active ride from provider
          rideProvider.clearActiveRide();
          rideProvider.stopPolling();
          context.go('/home');
        }
      } else {
        showSnackBar(
          context,
          message: response['message'] ?? 'Failed to submit rating',
          isError: true,
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          message: 'Network error. Please try again.',
          isError: true,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Driver'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to home instead of pop to avoid state issues
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Driver Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: widget.driverPhoto != null
                        ? NetworkImage(widget.driverPhoto!)
                        : null,
                    child: widget.driverPhoto == null
                        ? Text(
                      widget.driverName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 28),
                    )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.driverName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.vehicleModel} • ${widget.vehiclePlate}',
                          style: TextStyle(
                            fontSize: 14,
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

            // Rating Stars
            const Text(
              'How was your ride?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _rating = starIndex;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star
                          : Icons.star_border,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _rating > 0 ? _ratingLabels[_rating - 1] : 'Tap to rate',
              style: TextStyle(
                fontSize: 14,
                color: _rating > 0 ? AppColors.accent : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Feedback Text Field
            const Text(
              'Share your experience (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _feedbackController,
              hint: 'What did you like about the ride?',
              maxLines: 4,
              prefixIcon: Icons.message,
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Submit Rating',
              onPressed: _submitRating,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Skip Button
            TextButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Skip'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}