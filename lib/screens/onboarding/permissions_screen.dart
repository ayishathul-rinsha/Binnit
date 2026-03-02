import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/animations.dart';

/// Permissions screen with noticeable animations
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Pop-in icon
              PopInAnimation(
                delay: 100,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Slide-in title
              FadeSlideAnimation(
                delay: 300,
                child: Text(
                  l10n.appPermissions,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Slide-in subtitle
              FadeSlideAnimation(
                delay: 450,
                child: Text(
                  l10n.permissionsDesc,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Animated permission cards
              FadeSlideAnimation(
                delay: 600,
                child: _buildPermissionCard(
                  icon: Icons.location_on_rounded,
                  title: l10n.locationAccess,
                  description: l10n.locationDesc,
                  isGranted: _locationGranted,
                  onRequest: _requestLocation,
                  allowText: l10n.allow,
                ),
              ),
              const SizedBox(height: 18),

              FadeSlideAnimation(
                delay: 800,
                child: _buildPermissionCard(
                  icon: Icons.notifications_rounded,
                  title: l10n.pushNotifications,
                  description: l10n.notificationDesc,
                  isGranted: _notificationGranted,
                  onRequest: _requestNotifications,
                  allowText: l10n.allow,
                ),
              ),
              const Spacer(),

              // Animated continue button
              FadeSlideAnimation(
                delay: 1000,
                child: BounceButton(
                  onTap: _allPermissionsGranted ? _continue : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: _allPermissionsGranted
                          ? AppColors.primaryGradient
                          : null,
                      color: _allPermissionsGranted ? null : AppColors.disabled,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _allPermissionsGranted
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.continueText,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _allPermissionsGranted
                                    ? Colors.white
                                    : AppColors.textLight,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Skip button
              FadeSlideAnimation(
                delay: 1100,
                child: Center(
                  child: TextButton(
                    onPressed: _continue,
                    child: Text(
                      l10n.skipForNow,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
    required String allowText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      transform: Matrix4.identity()..scale(isGranted ? 1.02 : 1.0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted ? AppColors.primaryLight : AppColors.border,
          width: isGranted ? 2.5 : 1.5,
        ),
        boxShadow: isGranted
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: isGranted ? AppColors.primaryLightGradient : null,
              color: isGranted ? null : AppColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isGranted ? Colors.white : AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.elasticOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: isGranted
                ? TweenAnimationBuilder<double>(
                    key: const ValueKey('granted'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  )
                : BounceButton(
                    key: const ValueKey('allow'),
                    onTap: onRequest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        allowText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
