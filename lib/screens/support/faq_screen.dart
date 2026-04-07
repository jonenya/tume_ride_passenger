import 'package:flutter/material.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FAQItem(
            question: 'How do I book a ride?',
            answer: 'Enter your pickup and destination, select your preferred ride category, and confirm your ride. A nearby driver will be assigned.',
          ),
          _FAQItem(
            question: 'What payment methods are accepted?',
            answer: 'We accept M-Pesa (via app or direct to driver), cash, and wallet balance.',
          ),
          _FAQItem(
            question: 'How is the fare calculated?',
            answer: 'Fare is calculated based on distance, time, and ride category. You\'ll see the estimate before confirming your ride.',
          ),
          _FAQItem(
            question: 'How do I cancel a ride?',
            answer: 'You can cancel from the tracking screen. A cancellation fee may apply if cancelled after the grace period.',
          ),
          _FAQItem(
            question: 'How do I report an issue with my ride?',
            answer: 'Go to Help & Support and select "Report an Issue". Our support team will assist you.',
          ),
          _FAQItem(
            question: 'How does the referral program work?',
            answer: 'Share your referral code with friends. When they sign up and take their first ride, you both earn rewards.',
          ),
          _FAQItem(
            question: 'What is the KES 500 commission limit?',
            answer: 'Drivers must settle their commission when it reaches KES 500 to continue accepting rides. This ensures platform sustainability.',
          ),
          _FAQItem(
            question: 'How do I contact my driver?',
            answer: 'You can call or message your driver through the app during an active ride.',
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
