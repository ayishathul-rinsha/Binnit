import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';

/// Registration complete screen
class RegistrationCompleteScreen extends StatelessWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryLight,
                  size: 56,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Thank you for registering as a rider.\nYour application is under review.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.ochre.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            color: AppColors.ochre,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Application Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pending Review',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We\'ll notify you once your application is approved. This usually takes 1-2 business days.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Go to login button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
