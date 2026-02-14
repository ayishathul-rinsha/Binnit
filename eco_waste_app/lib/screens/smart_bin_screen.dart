import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SmartBinScreen extends StatefulWidget {
  const SmartBinScreen({super.key});

  @override
  State<SmartBinScreen> createState() => _SmartBinScreenState();
}

class _SmartBinScreenState extends State<SmartBinScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _bins = [
    {
      'name': 'Kitchen Waste Bin',
      'type': 'Wet Waste',
      'fillLevel': 0.82,
      'capacity': '30L',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFF6B6B),
      'lastPickup': '2 days ago',
      'autoScheduled': true,
      'nextPickup': 'Tomorrow, 9 AM',
      'temperature': '28°C',
      'status': 'Near Full',
    },
    {
      'name': 'Recyclables Bin',
      'type': 'Dry Waste',
      'fillLevel': 0.45,
      'capacity': '50L',
      'icon': Icons.recycling_rounded,
      'color': const Color(0xFF4CAF50),
      'lastPickup': '5 days ago',
      'autoScheduled': true,
      'nextPickup': 'In 3 days',
      'temperature': '25°C',
      'status': 'Normal',
    },
    {
      'name': 'E-Waste Bin',
      'type': 'Electronics',
      'fillLevel': 0.20,
      'capacity': '20L',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF9C27B0),
      'lastPickup': '10 days ago',
      'autoScheduled': false,
      'nextPickup': 'Not scheduled',
      'temperature': '26°C',
      'status': 'Low',
    },
    {
      'name': 'Glass & Metal',
      'type': 'Recyclable',
      'fillLevel': 0.65,
      'capacity': '40L',
      'icon': Icons.local_drink_rounded,
      'color': const Color(0xFF00BCD4),
      'lastPickup': '3 days ago',
      'autoScheduled': true,
      'nextPickup': 'In 2 days',
      'temperature': '25°C',
      'status': 'Moderate',
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 8),
                _buildOverviewCard(),
                const SizedBox(height: 24),
                _buildAutoScheduleInfo(),
                const SizedBox(height: 24),
                _buildBinList(),
                const SizedBox(height: 24),
                _buildWeeklyStats(),
                const SizedBox(height: 100),
              ],
            ),
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
                  'Smart Bin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time bin monitoring & auto-scheduling',
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
            child: const Icon(Icons.settings_outlined,
                color: AppTheme.textPrimary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final avgFill = _bins.fold<double>(0, (sum, bin) => sum + bin['fillLevel']) / _bins.length;
    final highFillCount = _bins.where((b) => b['fillLevel'] >= 0.75).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _overviewStat(
                    '${_bins.length}',
                    'Active Bins',
                    Icons.delete_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _overviewStat(
                    '${(avgFill * 100).toInt()}%',
                    'Avg Fill',
                    Icons.bar_chart_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _overviewStat(
                    '$highFillCount',
                    'Needs Pickup',
                    Icons.warning_rounded,
                  ),
                ),
              ],
            ),
            if (highFillCount > 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$highFillCount bin(s) auto-scheduled for pickup',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _overviewStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoScheduleInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFE082).withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFFF9A825),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Schedule Active 🤖',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bins reaching 80% will automatically schedule a pickup. You can disable this per bin.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF795548),
                      height: 1.4,
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

  Widget _buildBinList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Bins', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          ...List.generate(_bins.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildBinCard(_bins[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBinCard(Map<String, dynamic> bin) {
    final fillLevel = bin['fillLevel'] as double;
    final color = bin['color'] as Color;
    final isHigh = fillLevel >= 0.75;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isHigh
            ? Border.all(color: color.withOpacity(0.3), width: 1.5)
            : null,
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
          Row(
            children: [
              // Bin fill visualization
              SizedBox(
                width: 60,
                height: 80,
                child: CustomPaint(
                  painter: _BinFillPainter(fillLevel: fillLevel, color: color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bin['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHigh
                                ? color.withOpacity(0.1)
                                : AppTheme.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bin['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isHigh ? color : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bin['type']} • ${bin['capacity']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Fill level bar
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.inputBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: fillLevel,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isHigh
                                    ? [color, color.withOpacity(0.7)]
                                    : [color.withOpacity(0.6), color],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(fillLevel * 100).toInt()}% Full',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.thermostat_rounded, size: 14, color: AppTheme.textLight),
                            const SizedBox(width: 2),
                            Text(
                              bin['temperature'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  bin['autoScheduled'] ? Icons.auto_awesome_rounded : Icons.schedule_rounded,
                  size: 16,
                  color: bin['autoScheduled']
                      ? const Color(0xFFF9A825)
                      : AppTheme.textLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bin['autoScheduled']
                            ? 'Auto-scheduled pickup'
                            : 'Manual scheduling',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        bin['nextPickup'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Last: ${bin['lastPickup']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _binActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: bin['autoScheduled'] ? 'Auto: ON' : 'Auto: OFF',
                  isActive: bin['autoScheduled'],
                  onTap: () {
                    setState(() {
                      bin['autoScheduled'] = !bin['autoScheduled'];
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _binActionButton(
                  icon: Icons.local_shipping_rounded,
                  label: 'Request Pickup',
                  isActive: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _binActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  isActive: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _binActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppTheme.primaryGreen.withOpacity(0.3))
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppTheme.primaryGreen : AppTheme.textLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Fill History', style: AppTheme.headingSmall),
          const SizedBox(height: 14),
          Container(
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
              children: [
                SizedBox(
                  height: 150,
                  child: CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: _WeeklyChartPainter(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Text(
                            day,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textLight,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bin Fill Painter ────────────────────────────────────────────────────────
class _BinFillPainter extends CustomPainter {
  final double fillLevel;
  final Color color;

  _BinFillPainter({required this.fillLevel, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bin outline
    final binPath = Path()
      ..moveTo(w * 0.15, h * 0.15)
      ..lineTo(w * 0.1, h * 0.9)
      ..quadraticBezierTo(w * 0.1, h, w * 0.2, h)
      ..lineTo(w * 0.8, h)
      ..quadraticBezierTo(w * 0.9, h, w * 0.9, h * 0.9)
      ..lineTo(w * 0.85, h * 0.15)
      ..close();

    // Fill
    final fillH = h * fillLevel;
    final fillPath = Path()
      ..moveTo(w * 0.1 + (w * 0.05 * (1 - fillLevel)), h - fillH + h * 0.1)
      ..lineTo(w * 0.1, h * 0.9)
      ..quadraticBezierTo(w * 0.1, h, w * 0.2, h)
      ..lineTo(w * 0.8, h)
      ..quadraticBezierTo(w * 0.9, h, w * 0.9, h * 0.9)
      ..lineTo(w * 0.9 - (w * 0.05 * (1 - fillLevel)), h - fillH + h * 0.1)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = color.withOpacity(0.2),
    );

    canvas.drawPath(
      binPath,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.08),
        const Radius.circular(4),
      ),
      Paint()..color = color.withOpacity(0.6),
    );

    // Handle
    canvas.drawLine(
      Offset(w * 0.4, h * 0.08),
      Offset(w * 0.4, h * 0.02),
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.4, h * 0.02),
      Offset(w * 0.6, h * 0.02),
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.6, h * 0.02),
      Offset(w * 0.6, h * 0.08),
      Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BinFillPainter oldDelegate) =>
      fillLevel != oldDelegate.fillLevel || color != oldDelegate.color;
}

// ─── Weekly Chart Painter ────────────────────────────────────────────────────
class _WeeklyChartPainter extends CustomPainter {
  final List<double> data = [0.4, 0.6, 0.75, 0.5, 0.8, 0.65, 0.45];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0).withOpacity(0.5)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points & line
    final path = Path();
    final fillPath = Path();
    final spacing = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = spacing * i;
      final y = size.height * (1 - data[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = spacing * (i - 1);
        final prevY = size.height * (1 - data[i - 1]);
        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }

      // Data dots
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppTheme.primaryGreen,
      );
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppTheme.primaryGreen.withOpacity(0.15),
        AppTheme.primaryGreen.withOpacity(0.02),
      ],
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );

    paint.color = AppTheme.primaryGreen;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
