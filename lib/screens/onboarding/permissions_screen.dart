import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';

/// Permissions screen - Request location, background location, notifications
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _isLoading = false;

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);

    // Simulating permission request - in real app use permission_handler
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _locationGranted = true;
      _isLoading = false;
    });
  }

  Future<void> _requestNotifications() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _notificationGranted = true;
      _isLoading = false;
    });
  }

  bool get _allPermissionsGranted => _locationGranted && _notificationGranted;

  Future<void> _continue() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    await onboardingProvider.setPermissionsGranted();

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.languageSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'App Permissions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We need a few permissions to provide you the best experience',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Location permission
              _buildPermissionCard(
                icon: Icons.location_on_rounded,
                title: 'Location Access',
                description:
                    'Required to find nearby pickup requests and navigate to locations',
                isGranted: _locationGranted,
                onRequest: _requestLocation,
              ),

              const SizedBox(height: 16),

              // Notification permission
              _buildPermissionCard(
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                description:
                    'Get notified about new pickup requests and important updates',
                isGranted: _notificationGranted,
                onRequest: _requestNotifications,
              ),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _allPermissionsGranted ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabled,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip for now
              Center(
                child: TextButton(
                  onPressed: _continue,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppColors.primaryLight : AppColors.border,
          width: isGranted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.primaryLight.withOpacity(0.15)
                  : AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  isGranted ? AppColors.primaryLight : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isGranted)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            )
          else
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
