import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PickupTrackingScreen extends StatefulWidget {
  const PickupTrackingScreen({super.key});

  @override
  State<PickupTrackingScreen> createState() => _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends State<PickupTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _truckController;
  late Animation<double> _truckProgress;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int _etaMinutes = 10;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Truck animation - moves from start to near the destination
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _truckProgress = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _truckController, curve: Curves.easeInOut),
    );
    _truckController.forward();

    // Pulse animation for location pin
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.repeat();

    // Simulate ETA countdown
    _startETACountdown();
  }

  void _startETACountdown() {
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && _etaMinutes > 1) {
        setState(() => _etaMinutes--);
        _startETACountdown();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _truckController.dispose();
    _pulseController.dispose();
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
                      _buildLiveMap(),
                      const SizedBox(height: 20),
                      _buildETABanner(),
                      const SizedBox(height: 20),
                      _buildTrackingTimeline(),
                      const SizedBox(height: 24),
                      _buildDriverCard(),
                      const SizedBox(height: 24),
                      _buildPickupDetails(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              'Live Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Map background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFB2DFDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CustomPaint(
                  size: const Size(double.infinity, 260),
                  painter: _TrackingMapPainter(),
                ),
              ),
              // Route path + animated truck
              AnimatedBuilder(
                animation: _truckProgress,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 260),
                    painter: _RoutePainter(progress: _truckProgress.value),
                  );
                },
              ),
              // Destination - fixed home icon with animated pulse ring
              Positioned(
                right: 40,
                bottom: 60,
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Animated pulse ring (grows/fades around icon)
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) {
                          return Container(
                            width: 30 * _pulseAnim.value,
                            height: 30 * _pulseAnim.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE53935).withOpacity(
                                0.2 * (1 - (_pulseAnim.value - 1) / 0.8),
                              ),
                            ),
                          );
                        },
                      ),
                      // Fixed home icon (does not move)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE53935),
                        ),
                        child: const Icon(Icons.home_rounded,
                            size: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              // Your location label
              Positioned(
                right: 22,
                bottom: 94,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Your Location',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              // Animated Truck
              AnimatedBuilder(
                animation: _truckProgress,
                builder: (context, child) {
                  final progress = _truckProgress.value;
                  // Route: from top-left area to bottom-right area
                  final startX = 30.0;
                  final startY = 60.0;
                  final endX = 260.0;
                  final endY = 175.0;
                  // Curved path
                  final midX = (startX + endX) / 2 + 30;
                  final midY = startY - 20;
                  final t = progress;
                  final x = (1 - t) * (1 - t) * startX +
                      2 * (1 - t) * t * midX +
                      t * t * endX;
                  final y = (1 - t) * (1 - t) * startY +
                      2 * (1 - t) * t * midY +
                      t * t * endY;

                  return Positioned(
                    left: x - 18,
                    top: y - 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
              // Driver start label
              Positioned(
                left: 10,
                top: 38,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Driver',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Map controls
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    _mapBtn(Icons.add_rounded),
                    const SizedBox(height: 4),
                    _mapBtn(Icons.remove_rounded),
                    const SizedBox(height: 4),
                    _mapBtn(Icons.my_location_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: AppTheme.textPrimary),
    );
  }

  Widget _buildETABanner() {
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
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arriving in',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_etaMinutes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'min',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Share',
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

  Widget _buildTrackingTimeline() {
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
              'Tracking Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _timelineStep(
              'Pickup Confirmed',
              '3:30 PM',
              true,
              true,
              const Color(0xFF4CAF50),
              Icons.check_circle_rounded,
            ),
            _timelineStep(
              'Driver Assigned',
              '3:32 PM',
              true,
              true,
              const Color(0xFF4CAF50),
              Icons.person_pin_rounded,
            ),
            _timelineStep(
              'On the Way',
              '3:45 PM',
              true,
              false,
              const Color(0xFFFF9800),
              Icons.local_shipping_rounded,
            ),
            _timelineStep(
              'Arriving Soon',
              'ETA $_etaMinutes min',
              false,
              false,
              AppTheme.textLight,
              Icons.location_on_rounded,
            ),
            _timelineStep(
              'Pickup Complete',
              '—',
              false,
              false,
              AppTheme.textLight,
              Icons.done_all_rounded,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineStep(
    String title,
    String time,
    bool isDone,
    bool isLineDone,
    Color color,
    IconData icon, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? color.withOpacity(0.15) : AppTheme.inputBackground,
                shape: BoxShape.circle,
                border: isDone
                    ? null
                    : Border.all(color: AppTheme.dividerColor, width: 1.5),
              ),
              child: Icon(icon, size: 16, color: isDone ? color : AppTheme.textLight),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: isLineDone ? const Color(0xFF4CAF50).withOpacity(0.3) : AppTheme.dividerColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                    color: isDone ? AppTheme.textPrimary : AppTheme.textLight,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone ? AppTheme.textSecondary : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
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
              'Driver Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Driver avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A6741), Color(0xFF6B8E5F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'RS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rahul Sharma',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(342 trips)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.call_rounded,
                        color: Color(0xFF4CAF50), size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                // Chat button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_rounded,
                        color: Color(0xFF2196F3), size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Vehicle info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: AppTheme.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tata Ace - Green',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'KA-01-AB-1234',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Verified ✓',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPickupDetails() {
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
              'Pickup Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _infoRow(Icons.calendar_today_rounded, 'Date',
                'Today, 14 Feb 2026', const Color(0xFF2196F3)),
            const SizedBox(height: 10),
            _infoRow(Icons.access_time_rounded, 'Time',
                '4:00 PM', const Color(0xFFFF9800)),
            const SizedBox(height: 10),
            _infoRow(Icons.location_on_rounded, 'Address',
                '123, 5th Cross, Koramangala', const Color(0xFFE53935)),
            const SizedBox(height: 10),
            _infoRow(Icons.delete_outline_rounded, 'Waste Type',
                'Paper, Plastic', const Color(0xFF4CAF50)),
            const SizedBox(height: 10),
            _infoRow(Icons.scale_rounded, 'Weight',
                '5 Kg (estimated)', AppTheme.primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:  ',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Route & Map Painters ───────────────────────────────────────────────────

class _TrackingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFB9D4B3).withOpacity(0.35)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw some blocks / buildings
    final blockPaint = Paint()..color = const Color(0xFFA5D6A7).withOpacity(0.45);
    final blocks = [
      const Rect.fromLTWH(15, 15, 55, 35),
      const Rect.fromLTWH(100, 20, 70, 45),
      Rect.fromLTWH(size.width - 90, 15, 60, 40),
      Rect.fromLTWH(20, size.height - 65, 90, 35),
      Rect.fromLTWH(size.width - 120, size.height - 70, 80, 45),
      Rect.fromLTWH(size.width * 0.4, size.height * 0.45, 50, 40),
    ];
    for (final r in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        blockPaint,
      );
    }

    // Streets
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.35),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.72),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, 0),
      Offset(size.width * 0.28, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, 0),
      Offset(size.width * 0.62, size.height),
      streetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final startX = 30.0;
    final startY = 60.0;
    final endX = size.width - 60;
    final endY = size.height - 80;
    final midX = (startX + endX) / 2 + 30;
    final midY = startY - 20;

    final path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(midX, midY, endX, endY);

    // Draw background route (dashed)
    final routePaint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.25)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, routePaint);

    // Draw completed route portion
    final completedPaint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw path up to current progress
    final metrics = path.computeMetrics().first;
    final completedPath = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(completedPath, completedPaint);

    // Draw small dots along the path
    final dotPaint = Paint()..color = AppTheme.primaryGreen.withOpacity(0.3);
    for (double i = 0; i <= 1.0; i += 0.1) {
      final t = i;
      final x = (1 - t) * (1 - t) * startX +
          2 * (1 - t) * t * midX +
          t * t * endX;
      final y = (1 - t) * (1 - t) * startY +
          2 * (1 - t) * t * midY +
          t * t * endY;
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
