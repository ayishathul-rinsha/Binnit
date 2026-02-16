import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'This Week', 'This Month', 'Last 3 Months'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPickupHistory(),
                  _buildRecyclingHistory(),
                  _buildTransactionHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6741), Color(0xFF6B8E5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your eco journey',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildSummaryBadge(),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Text(
            '45',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          Text(
            'Total',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Pickups'),
          Tab(text: 'Recycling'),
          Tab(text: 'Transactions'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.dividerColor.withOpacity(0.5),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── PICKUP HISTORY ──────────────────────────────────────────────────────────

  Widget _buildPickupHistory() {
    final pickups = [
      _PickupData(
        date: 'Feb 15, 2026',
        time: '10:00 AM - 12:00 PM',
        status: 'Completed',
        wasteType: 'Kitchen Waste',
        weight: '3.5 Kg',
        amount: '₹32',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFFF6B6B),
      ),
      _PickupData(
        date: 'Feb 12, 2026',
        time: '9:00 AM - 11:00 AM',
        status: 'Completed',
        wasteType: 'Recyclables',
        weight: '5.2 Kg',
        amount: '₹78',
        icon: Icons.recycling_rounded,
        color: const Color(0xFF4CAF50),
      ),
      _PickupData(
        date: 'Feb 8, 2026',
        time: '2:00 PM - 4:00 PM',
        status: 'Completed',
        wasteType: 'E-Waste',
        weight: '2.1 Kg',
        amount: '₹120',
        icon: Icons.devices_rounded,
        color: const Color(0xFF2196F3),
      ),
      _PickupData(
        date: 'Feb 4, 2026',
        time: '9:00 AM - 11:00 AM',
        status: 'Completed',
        wasteType: 'Mixed Waste',
        weight: '4.8 Kg',
        amount: '₹45',
        icon: Icons.delete_rounded,
        color: const Color(0xFFFF9800),
      ),
      _PickupData(
        date: 'Jan 30, 2026',
        time: '10:00 AM - 12:00 PM',
        status: 'Cancelled',
        wasteType: 'Kitchen Waste',
        weight: '—',
        amount: '—',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFFF6B6B),
      ),
      _PickupData(
        date: 'Jan 25, 2026',
        time: '3:00 PM - 5:00 PM',
        status: 'Completed',
        wasteType: 'Recyclables',
        weight: '6.0 Kg',
        amount: '₹95',
        icon: Icons.recycling_rounded,
        color: const Color(0xFF4CAF50),
      ),
      _PickupData(
        date: 'Jan 20, 2026',
        time: '9:00 AM - 11:00 AM',
        status: 'Completed',
        wasteType: 'Hazardous',
        weight: '1.2 Kg',
        amount: '₹55',
        icon: Icons.warning_rounded,
        color: const Color(0xFFE91E63),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: pickups.length,
      itemBuilder: (context, index) {
        final pickup = pickups[index];
        return _buildPickupCard(pickup, index, pickups.length);
      },
    );
  }

  Widget _buildPickupCard(_PickupData pickup, int index, int total) {
    final isCancelled = pickup.status == 'Cancelled';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppTheme.errorColor
                      : AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isCancelled
                              ? AppTheme.errorColor
                              : AppTheme.primaryGreen)
                          .withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (index < total - 1)
                Container(
                  width: 2,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.3),
                        AppTheme.primaryGreen.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: isCancelled
                    ? Border.all(
                        color: AppTheme.errorColor.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: pickup.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(pickup.icon, color: pickup.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickup.wasteType,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pickup.date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(pickup.status),
                    ],
                  ),
                  if (!isCancelled) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildInfoChip(Icons.access_time_rounded, pickup.time),
                          Container(
                            width: 1,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: AppTheme.dividerColor.withOpacity(0.3),
                          ),
                          _buildInfoChip(Icons.scale_rounded, pickup.weight),
                          Container(
                            width: 1,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: AppTheme.dividerColor.withOpacity(0.3),
                          ),
                          _buildInfoChip(Icons.payments_rounded, pickup.amount),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isCompleted = status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 12,
            color: isCompleted
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECYCLING HISTORY ────────────────────────────────────────────────────────

  Widget _buildRecyclingHistory() {
    final items = [
      _RecyclingData('Plastic Bottles', '2.5 Kg', 'Feb 15, 2026', Icons.local_drink_rounded,
          const Color(0xFF2196F3), '+25 pts'),
      _RecyclingData('Newspapers', '3.8 Kg', 'Feb 12, 2026', Icons.newspaper_rounded,
          const Color(0xFF795548), '+38 pts'),
      _RecyclingData('Glass Jars', '1.2 Kg', 'Feb 10, 2026', Icons.wine_bar_rounded,
          const Color(0xFF009688), '+18 pts'),
      _RecyclingData('Cardboard Boxes', '4.5 Kg', 'Feb 7, 2026', Icons.inventory_2_rounded,
          const Color(0xFFFF9800), '+45 pts'),
      _RecyclingData('Metal Cans', '0.8 Kg', 'Feb 5, 2026', Icons.circle_outlined,
          const Color(0xFF607D8B), '+12 pts'),
      _RecyclingData('Old Clothes', '2.0 Kg', 'Feb 2, 2026', Icons.checkroom_rounded,
          const Color(0xFF9C27B0), '+30 pts'),
      _RecyclingData('Electronics', '1.5 Kg', 'Jan 28, 2026', Icons.devices_rounded,
          const Color(0xFFE91E63), '+50 pts'),
      _RecyclingData('Plastic Bags', '0.5 Kg', 'Jan 24, 2026', Icons.shopping_bag_rounded,
          const Color(0xFF03A9F4), '+8 pts'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.scale_rounded,
                              size: 13, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(
                            item.weight,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today_rounded,
                              size: 13, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.points,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── TRANSACTION HISTORY ──────────────────────────────────────────────────────

  Widget _buildTransactionHistory() {
    final transactions = [
      _TransactionData('Pickup Payment', '₹78', 'Feb 15, 2026', 'credit',
          Icons.local_shipping_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Marketplace Sale', '₹250', 'Feb 13, 2026', 'credit',
          Icons.storefront_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Pro Subscription', '₹199', 'Feb 10, 2026', 'debit',
          Icons.workspace_premium_rounded, const Color(0xFFFF5722)),
      _TransactionData('Pickup Payment', '₹120', 'Feb 8, 2026', 'credit',
          Icons.local_shipping_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Eco Points Redeemed', '₹100', 'Feb 5, 2026', 'credit',
          Icons.star_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Pickup Payment', '₹45', 'Feb 4, 2026', 'credit',
          Icons.local_shipping_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Marketplace Sale', '₹180', 'Jan 30, 2026', 'credit',
          Icons.storefront_rounded, const Color(0xFF4CAF50)),
      _TransactionData('Pickup Payment', '₹95', 'Jan 25, 2026', 'credit',
          Icons.local_shipping_rounded, const Color(0xFF4CAF50)),
    ];

    return Column(
      children: [
        // Summary card
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A6741), Color(0xFF2D5016)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTransSummary('₹868', 'Earned', Icons.trending_up_rounded),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildTransSummary('₹199', 'Spent', Icons.trending_down_rounded),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildTransSummary('₹669', 'Net', Icons.account_balance_wallet_rounded),
              ],
            ),
          ),
        ),
        // Transaction list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tx.type == 'credit'
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tx.icon,
                          color: tx.type == 'credit'
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tx.date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        tx.type == 'credit' ? '+${tx.amount}' : '-${tx.amount}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tx.type == 'credit'
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransSummary(String amount, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 6),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// ─── DATA MODELS ──────────────────────────────────────────────────────────────

class _PickupData {
  final String date;
  final String time;
  final String status;
  final String wasteType;
  final String weight;
  final String amount;
  final IconData icon;
  final Color color;

  _PickupData({
    required this.date,
    required this.time,
    required this.status,
    required this.wasteType,
    required this.weight,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

class _RecyclingData {
  final String name;
  final String weight;
  final String date;
  final IconData icon;
  final Color color;
  final String points;

  _RecyclingData(this.name, this.weight, this.date, this.icon, this.color, this.points);
}

class _TransactionData {
  final String name;
  final String amount;
  final String date;
  final String type;
  final IconData icon;
  final Color color;

  _TransactionData(this.name, this.amount, this.date, this.type, this.icon, this.color);
}
