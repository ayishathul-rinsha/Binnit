import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/animations.dart';

/// User Type selection screen — New User or Existing User
class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

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
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              FadeSlideAnimation(
                delay: 300,
                child: Text(
                  l10n.get('userTypeTitle'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              FadeSlideAnimation(
                delay: 450,
                child: Text(
                  l10n.get('userTypeSubtitle'),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(),

              // New User card
              FadeSlideAnimation(
                delay: 600,
                child: _buildOptionCard(
                  context: context,
                  icon: Icons.person_add_rounded,
                  title: l10n.get('newUser'),
                  description: l10n.get('newUserDesc'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.becomeRider);
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Existing User card
              FadeSlideAnimation(
                delay: 800,
                child: _buildOptionCard(
                  context: context,
                  icon: Icons.login_rounded,
                  title: l10n.get('existingUser'),
                  description: l10n.get('existingUserDesc'),
                  onTap: () async {
                    // Mark onboarding steps as done for existing users
                    final onboardingProvider =
                        Provider.of<OnboardingProvider>(context, listen: false);
                    await onboardingProvider.setRiderRegistered();
                    await onboardingProvider.completeOnboarding();

                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, Routes.login);
                    }
                  },
                  isOutlined: true,
                ),
              ),

              const Spacer(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : AppColors.primaryGradient,
          color: isOutlined ? Colors.white : null,
          borderRadius: BorderRadius.circular(20),
          border: isOutlined
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isOutlined
                  ? Colors.black.withOpacity(0.05)
                  : AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isOutlined
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isOutlined ? AppColors.primary : Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isOutlined ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isOutlined
                          ? AppColors.textSecondary
                          : Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: isOutlined
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
