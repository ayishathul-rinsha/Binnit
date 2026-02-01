import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collector_provider.dart';
import '../../providers/pickup_provider.dart';
import '../../providers/earnings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Dashboard - Warm, earthy, balanced creativity
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
            // Header with gradient
            _buildHeader(),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Earnings highlight card
                  _buildEarningsCard(),
                  const SizedBox(height: 24),

                  // Stats row
                  _buildStatsRow(),
                  const SizedBox(height: 28),

                  // Quick actions
                  _buildQuickActions(),
                  const SizedBox(height: 28),

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
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A5D23),
                Color(0xFF5E7A29),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative shape
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: -60,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              // Content - Centered toggle
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.dashboard,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
          onTap: () => provider.toggleOnlineStatus(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Text(isOnline ? 'You are online' : 'You are offline'),
              ),
              const SizedBox(height: 14),

              // Toggle switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: 80,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: isOnline
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: isOnline
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Toggle knob
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutBack,
                      left: isOnline ? 38 : 4,
                      top: 4,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isOnline
                                  ? Icons.check_rounded
                                  : Icons.power_settings_new_rounded,
                              key: ValueKey(isOnline),
                              color:
                                  isOnline ? Colors.white : AppColors.textLight,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Status text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isOnline ? AppColors.accent : Colors.white,
                ),
                child: Text(isOnline ? 'Online' : 'Offline'),
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Earnings",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                CurrencyHelper.formatCurrency(earnings?.todayEarnings ?? 0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEarningMini(
                      'Weekly',
                      CurrencyHelper.formatCompact(
                          earnings?.weeklyEarnings ?? 0),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  Expanded(
                    child: _buildEarningMini(
                      'Monthly',
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
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
                icon: Icons.local_shipping_outlined,
                label: 'Pickups',
                value: '${collector?.totalPickups ?? 0}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_outline_rounded,
                label: 'Rating',
                value: (collector?.rating ?? 0).toStringAsFixed(1),
                color: AppColors.ochre,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.schedule_outlined,
                label: 'Hours',
                value:
                    '${(collector?.totalHoursToday ?? 0).toStringAsFixed(1)}h',
                color: AppColors.primaryLight,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.list_alt_rounded,
                label: 'Requests',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history_rounded,
                label: 'History',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Earnings',
                color: AppColors.secondary,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
                  'Active Pickups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (activePickups.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${activePickups.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (activePickups.isEmpty)
              _buildEmptyState()
            else
              ...activePickups.take(2).map(
                    (pickup) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PickupRequestCard(
                        pickup: pickup,
                        showActions: false,
                        onTap: () {},
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No active pickups',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Stay online to receive new pickup requests',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
