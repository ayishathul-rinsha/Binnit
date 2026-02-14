import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlan = 1; // Pro is default selected
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Basic',
      'price': '₹199',
      'period': '/month',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF607D8B),
      'gradient': [const Color(0xFF455A64), const Color(0xFF78909C)],
      'popular': false,
      'features': [
        {'text': '4 pickups per month', 'included': true},
        {'text': 'Smart bin monitoring', 'included': true},
        {'text': 'Basic marketplace access', 'included': true},
        {'text': 'Priority scheduling', 'included': false},
        {'text': 'E-waste pickup', 'included': false},
        {'text': 'Family plan (up to 5)', 'included': false},
        {'text': '24/7 support', 'included': false},
      ],
    },
    {
      'name': 'Pro',
      'price': '₹499',
      'period': '/month',
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFF4A6741),
      'gradient': [const Color(0xFF2D5016), const Color(0xFF6B8E5F)],
      'popular': true,
      'features': [
        {'text': 'Unlimited pickups', 'included': true},
        {'text': 'Smart bin monitoring', 'included': true},
        {'text': 'Full marketplace access', 'included': true},
        {'text': 'Priority scheduling', 'included': true},
        {'text': 'E-waste pickup', 'included': true},
        {'text': 'Family plan (up to 5)', 'included': false},
        {'text': '24/7 support', 'included': false},
      ],
    },
    {
      'name': 'Premium',
      'price': '₹999',
      'period': '/month',
      'icon': Icons.diamond_rounded,
      'color': const Color(0xFF7B1FA2),
      'gradient': [const Color(0xFF4A148C), const Color(0xFFAB47BC)],
      'popular': false,
      'features': [
        {'text': 'Unlimited pickups', 'included': true},
        {'text': 'Smart bin monitoring', 'included': true},
        {'text': 'Full marketplace access', 'included': true},
        {'text': 'Priority scheduling', 'included': true},
        {'text': 'E-waste pickup', 'included': true},
        {'text': 'Family plan (up to 5)', 'included': true},
        {'text': '24/7 support', 'included': true},
      ],
    },
  ];

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
                      _buildHeaderBanner(),
                      const SizedBox(height: 24),
                      _buildCurrentPlan(),
                      const SizedBox(height: 28),
                      _buildPlanCards(),
                      const SizedBox(height: 28),
                      _buildBenefits(),
                      const SizedBox(height: 28),
                      _buildFAQ(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildSubscribeButton(),
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
              'Subscription Plans',
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

  Widget _buildHeaderBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B1FA2).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Go Premium ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock unlimited pickups, priority scheduling,\nand save more on every collection!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '12,000+ subscribers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE082).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.eco_rounded, color: Color(0xFFF9A825), size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Plan: Basic',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '2 of 4 pickups used this month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF795548),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Your Plan', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          ...List.generate(_plans.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildPlanCard(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlan == index;
    final color = plan['color'] as Color;
    final gradientColors = plan['gradient'] as List<Color>;
    final isPopular = plan['popular'] as bool;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.08),
                    gradientColors[1].withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : AppTheme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: gradientColors)
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    plan['icon'],
                    color: isSelected ? Colors.white : color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : AppTheme.textPrimary,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan['price'],
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            plan['period'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : AppTheme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: AppTheme.dividerColor.withOpacity(0.2),
            ),
            const SizedBox(height: 14),
            // Features list
            ...List.generate(
              (plan['features'] as List).length,
              (fIndex) {
                final feature = plan['features'][fIndex];
                final included = feature['included'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: included
                              ? color.withOpacity(0.1)
                              : AppTheme.inputBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          included ? Icons.check_rounded : Icons.close_rounded,
                          size: 12,
                          color: included ? color : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        feature['text'],
                        style: TextStyle(
                          fontSize: 13,
                          color: included
                              ? AppTheme.textPrimary
                              : AppTheme.textLight,
                          fontWeight: included
                              ? FontWeight.w500
                              : FontWeight.normal,
                          decoration: included
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Why Subscribe?', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              _benefitCard(
                Icons.savings_rounded,
                'Save Money',
                'Up to 40% savings vs pay-per-pickup',
                const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              _benefitCard(
                Icons.speed_rounded,
                'Priority',
                'Get first-pick time slots every time',
                const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _benefitCard(
                Icons.family_restroom_rounded,
                'Family Plan',
                'Add up to 5 family members',
                const Color(0xFFFF9800),
              ),
              const SizedBox(width: 12),
              _benefitCard(
                Icons.nature_people_rounded,
                'Eco Points',
                '2x eco points on all pickups',
                const Color(0xFF9C27B0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _benefitCard(IconData icon, String title, String desc, Color color) {
    return Expanded(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      {
        'q': 'Can I change my plan anytime?',
        'a': 'Yes! You can upgrade or downgrade anytime. Changes take effect from the next billing cycle.',
      },
      {
        'q': 'Is there a free trial?',
        'a': 'Yes, you get a 7-day free trial on Pro and Premium plans.',
      },
      {
        'q': 'How does auto-scheduling work?',
        'a': 'When your smart bin reaches 80% capacity, we automatically schedule a pickup at your preferred time slot.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FAQs', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  faq['q']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                children: [
                  Text(
                    faq['a']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final plan = _plans[_selectedPlan];
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
                  Text(
                    plan['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        plan['price'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: plan['color'],
                        ),
                      ),
                      Text(
                        plan['period'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Subscribed to ${plan['name']} plan! 🎉'),
                        backgroundColor: AppTheme.successColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan['color'],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
