import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collector_provider.dart';
import '../../providers/pickup_provider.dart';
import '../../providers/earnings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../pickups/history_screen.dart';

/// Dashboard - Radical Modern Makeover
class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final pickupProvider = Provider.of<PickupProvider>(context, listen: false);
    final earningsProvider =
        Provider.of<EarningsProvider>(context, listen: false);

    await Future.wait([
      pickupProvider.fetchActivePickups(),
      earningsProvider.fetchEarnings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sweeping header with organic mesh gradient
            _buildHeader(),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 140), // Extra padding for the floating nav bar
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Premium sweeping earnings card
                  _buildEarningsCard(),
                  const SizedBox(height: 32),

                  // Floating Stats row
                  _buildStatsRow(),
                  const SizedBox(height: 32),

                  // Premium quick actions
                  _buildQuickActions(),
                  const SizedBox(height: 32),

                  // Active pickups
                  _buildActivePickupsSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Deep organic solid base
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
              // Content - Centered toggle
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: _buildStatusToggle(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const ClipOval(
              child: Image(
                image: AssetImage('assets/images/emptyko_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            AppLocalizations.of(context).dashboard,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Consumer<CollectorProvider>(
      builder: (context, provider, child) {
        final isOnline = provider.isOnline;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => provider.toggleOnlineStatus(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle switch (Plump & Smooth)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 90,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isOnline
                      ? AppColors.background
                      : Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: isOnline
                        ? AppColors.background
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Toggle knob
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: isOnline ? 42 : 4,
                      top: 4,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.95),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isOnline
                                ? Icons.check_rounded
                                : Icons.power_settings_new_rounded,
                            color:
                                isOnline ? Colors.white : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Status text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isOnline ? Colors.white : Colors.white.withOpacity(0.8),
                ),
                child: Text(isOnline
                    ? AppLocalizations.of(context).online.toUpperCase()
                    : AppLocalizations.of(context).offline.toUpperCase()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsCard() {
    return Consumer<EarningsProvider>(
      builder: (context, provider, child) {
        final earnings = provider.earnings;

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusXL),
            boxShadow: AppDimens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).todaysEarnings,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onNavigateTab?.call(3),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        AppLocalizations.of(context).viewDetails,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                CurrencyHelper.formatCurrency(earnings?.todayEarnings ?? 0),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildEarningMini(
                      AppLocalizations.of(context).weekly,
                      CurrencyHelper.formatCompact(
                          earnings?.weeklyEarnings ?? 0),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: _buildEarningMini(
                      AppLocalizations.of(context).monthly,
                      CurrencyHelper.formatCompact(
                          earnings?.monthlyEarnings ?? 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningMini(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<CollectorProvider>(
      builder: (context, provider, child) {
        final collector = provider.collector;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_shipping_rounded,
                label: AppLocalizations.of(context).pickups,
                value: '${collector?.totalPickups ?? 0}',
                color: AppColors.primary,
                onTap: () => widget.onNavigateTab?.call(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_rounded,
                label: AppLocalizations.of(context).rating,
                value: (collector?.rating ?? 0).toStringAsFixed(1),
                color: AppColors.ochre,
                onTap: () => widget.onNavigateTab?.call(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.schedule_rounded,
                label: AppLocalizations.of(context).hours,
                value: '${(collector?.totalHoursToday ?? 0).toStringAsFixed(1)}h',
                color: AppColors.primaryLight,
                onTap: () => Navigator.pushNamed(context, Routes.hours),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          boxShadow: AppDimens.softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.list_alt_rounded,
                label: AppLocalizations.of(context).requests,
                color: AppColors.primary,
                onTap: () => widget.onNavigateTab?.call(1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history_rounded,
                label: AppLocalizations.of(context).history,
                color: AppColors.textSecondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_balance_wallet_rounded,
                label: AppLocalizations.of(context).earnings,
                color: AppColors.secondary,
                onTap: () => widget.onNavigateTab?.call(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          boxShadow: AppDimens.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePickupsSection() {
    return Consumer<PickupProvider>(
      builder: (context, provider, child) {
        final activePickups = provider.activePickups;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).activePickups,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (activePickups.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activePickups.length} Active',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (activePickups.isEmpty)
              _buildEmptyState()
            else
              ...activePickups.take(2).map(
                    (pickup) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: AppDimens.softShadow,
                          borderRadius: BorderRadius.circular(AppDimens.radiusL),
                        ),
                        // Soft shadow applied, card assumes widget handles its own clipping
                        child: PickupRequestCard(
                          pickup: pickup,
                          showActions: false,
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusXL),
        boxShadow: AppDimens.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).noActivePickups,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).stayOnline,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
