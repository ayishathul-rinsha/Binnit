import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import '../pickups/pickup_requests_screen.dart';
import '../pickups/active_pickups_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';

/// Main navigation - Warm, balanced bottom nav
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PickupRequestsScreen(),
    ActivePickupsScreen(),
    EarningsScreen(),
    ProfileScreen(),
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
