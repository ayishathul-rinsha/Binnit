import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'payment_screen.dart';

class PickupDetailsScreen extends StatefulWidget {
  const PickupDetailsScreen({super.key});

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen>
    with SingleTickerProviderStateMixin {
  double _weight = 5.0;
  final Set<int> _selectedWasteTypes = {0};
  String _notes = '';
  late TextEditingController _weightController;
  bool _needsBags = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _wasteTypes = [
    {
      'name': 'Kitchen Waste',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFF6B6B),
      'description': 'Food scraps, peels, leftovers',
      'emoji': '🍎',
    },
    {
      'name': 'Plastic',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF2196F3),
      'description': 'Bottles, bags, containers',
      'emoji': '♻️',
    },
    {
      'name': 'Paper',
      'icon': Icons.description_rounded,
      'color': const Color(0xFFFF9800),
      'description': 'Newspapers, cardboard, books',
      'emoji': '📄',
    },
    {
      'name': 'Glass',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF00BCD4),
      'description': 'Bottles, jars, windows',
      'emoji': '🫙',
    },
    {
      'name': 'Metal',
      'icon': Icons.settings_rounded,
      'color': const Color(0xFF607D8B),
      'description': 'Cans, foils, utensils',
      'emoji': '🔩',
    },
    {
      'name': 'E-Waste',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF9C27B0),
      'description': 'Electronics, batteries, wires',
      'emoji': '📱',
    },
    {
      'name': 'Hazardous',
      'icon': Icons.warning_rounded,
      'color': const Color(0xFFf44336),
      'description': 'Chemicals, paint, solvents',
      'emoji': '⚠️',
    },
    {
      'name': 'Textile',
      'icon': Icons.checkroom_rounded,
      'color': const Color(0xFFE91E63),
      'description': 'Old clothes, fabric, shoes',
      'emoji': '👕',
    },
  ];

  // Per-Kg rates for each waste type
  final Map<int, double> _wasteRates = {
    0: 5,   // Kitchen Waste
    1: 8,   // Plastic
    2: 12,  // Paper
    3: 10,  // Glass
    4: 15,  // Metal
    5: 40,  // E-Waste
    6: 50,  // Hazardous
    7: 6,   // Textile
  };

  double get _ratePerKg {
    if (_selectedWasteTypes.isEmpty) return 8;
    double total = 0;
    for (final idx in _selectedWasteTypes) {
      total += _wasteRates[idx] ?? 8;
    }
    return total / _selectedWasteTypes.length;
  }

  double get _estimatedPrice {
    double base = _weight * _ratePerKg;
    if (_selectedWasteTypes.contains(5)) base += 50; // E-Waste surcharge
    if (_selectedWasteTypes.contains(6)) base += 100; // Hazardous surcharge
    if (_needsBags) base += 20;
    return base;
  }

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: _weight.toStringAsFixed(1));
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
    _weightController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _updateWeightFromText(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      setState(() => _weight = parsed);
    }
  }

  void _setQuickWeight(double w) {
    setState(() {
      _weight = w;
      _weightController.text = w.toStringAsFixed(w == w.truncateToDouble() ? 0 : 1);
    });
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
                      _buildPickupSummaryCard(),
                      const SizedBox(height: 24),
                      _buildWeightSection(),
                      const SizedBox(height: 28),
                      _buildWasteTypeSection(),
                      const SizedBox(height: 28),
                      _buildAdditionalOptions(),
                      const SizedBox(height: 28),
                      _buildNotesSection(),
                      const SizedBox(height: 28),
                      _buildPriceBreakdown(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Pickup Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A6741), Color(0xFF2D5016)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tomorrow, Feb 15',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        '9:00 - 11:00 AM',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        'Home',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Edit',
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

  Widget _buildWeightSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Weight', style: AppTheme.headingSmall),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Manual weight input field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.scale_rounded,
                          color: AppTheme.primaryGreen, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                        ],
                        onChanged: _updateWeightFromText,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                          letterSpacing: -1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight.withOpacity(0.3),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Kg',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Rate info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Color(0xFFF9A825)),
                      const SizedBox(width: 8),
                      Text(
                        'Rate: ₹${_ratePerKg.toStringAsFixed(0)}/Kg • Price updates as you type',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF795548),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Quick weight buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1.0, 5.0, 10.0, 20.0, 50.0].map((w) {
                    final isActive = (_weight - w).abs() < 0.1;
                    return GestureDetector(
                      onTap: () => _setQuickWeight(w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryGreen
                              : AppTheme.inputBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: isActive
                              ? null
                              : Border.all(
                                  color: AppTheme.dividerColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${w.toInt()} Kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Waste Type', style: AppTheme.headingSmall),
              Text(
                '${_selectedWasteTypes.length} selected',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemCount: _wasteTypes.length,
            itemBuilder: (context, index) {
              final type = _wasteTypes[index];
              final isSelected = _selectedWasteTypes.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWasteTypes.remove(index);
                    } else {
                      _selectedWasteTypes.add(index);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (type['color'] as Color).withOpacity(0.4)
                          : AppTheme.dividerColor.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (type['color'] as Color).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (type['color'] as Color).withOpacity(0.15)
                              : AppTheme.inputBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type['emoji'],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type['name'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? type['color']
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              type['description'],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Additional Options', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          Container(
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Color(0xFFFF9800),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need Waste Bags?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'We\'ll bring eco-friendly bags (₹20)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _needsBags,
                  onChanged: (val) => setState(() => _needsBags = val),
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Special Instructions', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.dividerColor.withOpacity(0.3)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _notes = val),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'E.g., Ring the doorbell, waste is at the gate...',
                hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Estimate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _priceRow('Base pickup (${_weight.toStringAsFixed(1)} Kg × ₹${_ratePerKg.toStringAsFixed(0)})',
                '₹${(_weight * _ratePerKg).toStringAsFixed(0)}'),
            if (_selectedWasteTypes.contains(5))
              _priceRow('E-Waste surcharge', '₹50'),
            if (_selectedWasteTypes.contains(6))
              _priceRow('Hazardous surcharge', '₹100'),
            if (_needsBags) _priceRow('Eco-friendly bags', '₹20'),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: AppTheme.dividerColor.withOpacity(0.3),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '₹${_estimatedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                  Text(
                    '₹${_estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            amount: _estimatedPrice,
                            wasteTypes: _selectedWasteTypes
                                .map((i) => _wasteTypes[i]['name'] as String)
                                .toList(),
                            weight: _weight,
                          ),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
