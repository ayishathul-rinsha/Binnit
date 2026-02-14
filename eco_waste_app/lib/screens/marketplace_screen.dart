import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'color': AppTheme.primaryGreen},
    {'name': 'Paper', 'icon': Icons.description_rounded, 'color': const Color(0xFFFF9800)},
    {'name': 'Plastic', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF2196F3)},
    {'name': 'Metal', 'icon': Icons.settings_rounded, 'color': const Color(0xFF607D8B)},
    {'name': 'Glass', 'icon': Icons.local_drink_rounded, 'color': const Color(0xFF00BCD4)},
    {'name': 'E-Waste', 'icon': Icons.devices_rounded, 'color': const Color(0xFF9C27B0)},
  ];

  final List<Map<String, dynamic>> _recyclables = [
    {
      'name': 'Old Newspapers',
      'category': 'Paper',
      'weight': '5 Kg',
      'price': '₹75',
      'pricePerKg': '₹15/Kg',
      'icon': Icons.newspaper_rounded,
      'color': const Color(0xFFFF9800),
      'seller': 'You',
      'status': 'Listed',
      'buyers': 3,
    },
    {
      'name': 'PET Bottles',
      'category': 'Plastic',
      'weight': '3 Kg',
      'price': '₹60',
      'pricePerKg': '₹20/Kg',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF2196F3),
      'seller': 'You',
      'status': 'Offers',
      'buyers': 5,
    },
    {
      'name': 'Aluminum Cans',
      'category': 'Metal',
      'weight': '2 Kg',
      'price': '₹200',
      'pricePerKg': '₹100/Kg',
      'icon': Icons.settings_rounded,
      'color': const Color(0xFF607D8B),
      'seller': 'Nearby Seller',
      'status': 'Available',
      'buyers': 0,
    },
    {
      'name': 'Cardboard Boxes',
      'category': 'Paper',
      'weight': '10 Kg',
      'price': '₹120',
      'pricePerKg': '₹12/Kg',
      'icon': Icons.inventory_2_rounded,
      'color': const Color(0xFFFF9800),
      'seller': 'Nearby Seller',
      'status': 'Available',
      'buyers': 0,
    },
    {
      'name': 'Glass Bottles',
      'category': 'Glass',
      'weight': '8 Kg',
      'price': '₹80',
      'pricePerKg': '₹10/Kg',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF00BCD4),
      'seller': 'You',
      'status': 'Listed',
      'buyers': 1,
    },
    {
      'name': 'Old Phone',
      'category': 'E-Waste',
      'weight': '0.2 Kg',
      'price': '₹500',
      'pricePerKg': '—',
      'icon': Icons.smartphone_rounded,
      'color': const Color(0xFF9C27B0),
      'seller': 'You',
      'status': 'Sold',
      'buyers': 0,
    },
    {
      'name': 'Copper Wire',
      'category': 'Metal',
      'weight': '1.5 Kg',
      'price': '₹750',
      'pricePerKg': '₹500/Kg',
      'icon': Icons.cable_rounded,
      'color': const Color(0xFF607D8B),
      'seller': 'Nearby Seller',
      'status': 'Available',
      'buyers': 0,
    },
    {
      'name': 'HDPE Containers',
      'category': 'Plastic',
      'weight': '4 Kg',
      'price': '₹100',
      'pricePerKg': '₹25/Kg',
      'icon': Icons.takeout_dining_rounded,
      'color': const Color(0xFF2196F3),
      'seller': 'Nearby Seller',
      'status': 'Available',
      'buyers': 0,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 0) return _recyclables;
    final cat = _categories[_selectedCategory]['name'];
    return _recyclables.where((item) => item['category'] == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildEarningsBanner(),
                      const SizedBox(height: 24),
                      _buildMarketRates(),
                      const SizedBox(height: 24),
                      _buildCategoryFilter(),
                      const SizedBox(height: 20),
                      _buildItemsList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSellDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Sell Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Buy & sell recyclable materials',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: AppTheme.textPrimary, size: 22),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.textLight, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search recyclables...',
                  hintStyle: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Icon(Icons.tune_rounded, color: AppTheme.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE65100), Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Earnings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        '₹2,450',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '↑ 15% this month',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Withdraw',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Today\'s Market Rates', style: AppTheme.headingSmall),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _rateChip('Paper', '₹15/Kg', '↑ 5%', const Color(0xFFFF9800), true),
              _rateChip('Plastic', '₹22/Kg', '↑ 8%', const Color(0xFF2196F3), true),
              _rateChip('Metal', '₹110/Kg', '↓ 2%', const Color(0xFF607D8B), false),
              _rateChip('Glass', '₹10/Kg', '—', const Color(0xFF00BCD4), true),
              _rateChip('E-Waste', 'Varies', '↑ 12%', const Color(0xFF9C27B0), true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rateChip(String name, String rate, String change, Color color, bool isUp) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rate,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFf44336),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          cat['color'],
                          (cat['color'] as Color).withOpacity(0.7),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? null
                    : Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (cat['color'] as Color).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'],
                    size: 16,
                    color: isSelected ? Colors.white : cat['color'],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsList() {
    final items = _filteredItems;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${items.length} Items',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Sort by: Price ↓',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(items.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildItemCard(items[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final isSold = item['status'] == 'Sold';
    final isYours = item['seller'] == 'You';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSold ? AppTheme.inputBackground : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isYours
            ? Border.all(color: color.withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item['icon'], color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSold
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                          decoration: isSold
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(item['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['weight']} • ${item['pricePerKg']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if ((item['buyers'] as int) > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item['buyers']} buyer(s)',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['price'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSold ? AppTheme.textLight : AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isYours ? 'Your listing' : item['seller'],
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Listed':
        return const Color(0xFF2196F3);
      case 'Offers':
        return const Color(0xFFFF9800);
      case 'Sold':
        return AppTheme.textLight;
      case 'Available':
        return const Color(0xFF4CAF50);
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showSellDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Sell Recyclables',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    _sellDialogField('Item Name', 'e.g., Old Newspapers', Icons.label_rounded),
                    const SizedBox(height: 14),
                    _sellDialogField('Category', 'Select category', Icons.category_rounded),
                    const SizedBox(height: 14),
                    _sellDialogField('Weight (Kg)', 'e.g., 5', Icons.scale_rounded),
                    const SizedBox(height: 14),
                    _sellDialogField('Price (₹)', 'e.g., 75', Icons.payments_rounded),
                    const SizedBox(height: 14),
                    _sellDialogField('Description', 'Describe your items...', Icons.notes_rounded),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'List for Sale',
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
          ],
        ),
      ),
    );
  }

  Widget _sellDialogField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppTheme.textLight, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}
