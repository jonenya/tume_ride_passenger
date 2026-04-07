import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tume_ride_passenger/providers/auth_provider.dart';
import 'package:tume_ride_passenger/widgets/custom_button.dart';
import 'package:tume_ride_passenger/utils/snackbar.dart';
import 'package:tume_ride_passenger/config/app_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String identifier;
  final bool isLogin;
  final String? testOtp;

  const OTPVerificationScreen({
    super.key,
    required this.identifier,
    required this.isLogin,
    this.testOtp,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto-fill test OTP if provided
    if (widget.testOtp != null && widget.testOtp!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = widget.testOtp![i];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
        _startTimer();
      } else if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _otp {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      showSnackBar(context, message: 'Please enter the 6-digit code', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.verifyOtp(widget.identifier, _otp);

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      showSnackBar(context, message: 'Login successful!');
      context.go('/home');
    } else {
      showSnackBar(context, message: response['message'] ?? 'Invalid OTP', isError: true);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _canResend = false;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.login(widget.identifier);

    setState(() {
      _isLoading = false;
      _timerSeconds = 60;
    });

    if (response['status'] == 'success') {
      showSnackBar(context, message: 'New OTP sent successfully');
      _startTimer();

      // Show test OTP if in development
      if (response['data']?['otp'] != null) {
        _showTestOtpDialog(response['data']['otp']);
      }
    } else {
      showSnackBar(context, message: response['message'] ?? 'Failed to resend OTP', isError: true);
    }
  }

  void _showTestOtpDialog(String otp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your OTP is:'),
            Text(
              otp,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter Verification Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a code to ${widget.identifier}',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (_otp.length == 6) {
                        _verifyOTP();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Verify Button
            CustomButton(
              text: 'Verify',
              onPressed: _verifyOTP,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _canResend ? "Didn't receive code? " : 'Resend code in ${_timerSeconds}s',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (_canResend)
                  TextButton(
                    onPressed: _resendOTP,
                    child: const Text('Resend'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}