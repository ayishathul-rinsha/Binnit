import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// This screen is no longer needed — OTP login replaces password auth.
/// Kept as a placeholder to avoid breaking any stale deep-links.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Password reset is no longer needed.\n\nThis app now uses phone number + OTP for authentication.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
