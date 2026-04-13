import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import '../pickups/pickup_requests_screen.dart';
import '../pickups/active_pickups_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';

/// Main navigation - Floating Premium Liquid Nav Bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    DashboardScreen(
      onNavigateTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const PickupRequestsScreen(),
    const ActivePickupsScreen(),
    const EarningsScreen(),
    const ProfileScreen(),
  ];

  List<_NavItem> _getNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: l10n.home),
      _NavItem(
          icon: Icons.list_alt_outlined,
          activeIcon: Icons.list_alt_rounded,
          label: l10n.requests),
      _NavItem(
          icon: Icons.local_shipping_outlined,
          activeIcon: Icons.local_shipping_rounded,
          label: l10n.active),
      _NavItem(
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
          label: l10n.earnings),
      _NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person_rounded,
          label: l10n.profile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Content smoothly underlaps the transparent island
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppDimens.radiusXL),
            boxShadow: AppDimens.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusXL),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = _currentIndex == index;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 18 : 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimens.radiusXL),
                          boxShadow: isSelected ? AppDimens.glowShadow : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 72),
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
