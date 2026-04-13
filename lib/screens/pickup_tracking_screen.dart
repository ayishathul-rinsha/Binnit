import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../main.dart' show languageService;
import '../services/routing_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Distance;
import 'package:latlong2/latlong.dart' as latlong2;

class PickupTrackingScreen extends StatefulWidget {
  final String? pickupId;
  const PickupTrackingScreen({super.key, this.pickupId});

  @override
  State<PickupTrackingScreen> createState() => _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends State<PickupTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  final MapController _mapController = MapController();

  Stream<DocumentSnapshot>? _liveLocationStream;
  String? _lastDriverId;
  late Animation<double> _fadeAnim;
  int _etaMinutes = 0;  // Real ETA from OSRM
  bool _hasEta = false;

  List<LatLng> _routePoints = [];
  bool _isFetchingRoute = false;
  LatLng? _lastKnownDriverPos;

  void _checkAndFetchRoute(double? driverLat, double? driverLng, double? destLat, double? destLng) async {
    debugPrint('[ROUTE] Checking: driver=($driverLat, $driverLng) dest=($destLat, $destLng)');
    if (driverLat == null || driverLng == null || destLat == null || destLng == null) {
      debugPrint('[ROUTE] ❌ Skipping — null coordinates');
      return;
    }
    
    if (_lastKnownDriverPos != null && _routePoints.isNotEmpty) {
      final moved = const latlong2.Distance().as(latlong2.LengthUnit.Meter, _lastKnownDriverPos!, LatLng(driverLat, driverLng));
      if (moved < 100) return;
    }

    if (_isFetchingRoute) return;
    _isFetchingRoute = true;
    _lastKnownDriverPos = LatLng(driverLat, driverLng);

    try {
      debugPrint('[ROUTE] 🔄 Fetching route from OSRM...');
      final result = await RoutingService.getRouteWithETA(
         LatLng(driverLat, driverLng), 
         LatLng(destLat, destLng)
      );
      debugPrint('[ROUTE] ✅ Got ${result.points.length} points, ETA=${result.durationMinutes}min');
      if (mounted) {
        setState(() {
          _routePoints = result.points;
          if (result.durationMinutes > 0) {
            _etaMinutes = result.durationMinutes.ceil();
            _hasEta = true;
          }
        });
      }
    } catch (e) {
      debugPrint('[ROUTE] ❌ Error: $e');
    } finally {
      if (mounted) _isFetchingRoute = false;
    }
  }

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
  }



  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Determine pickup status from Firestore data
  String _getStatus(Map<String, dynamic>? data) {
    if (data == null) return 'pending';
    return (data['status'] as String?)?.toLowerCase() ?? 'pending';
  }

  bool _isApproved(String status) {
    return status == 'approved' || status == 'assigned' ||
        status == 'accepted' || status == 'on_the_way' ||
        status == 'reached' || status == 'picked_up' ||
        status == 'arriving' || status == 'completed';
  }

  bool _isCollectorAssigned(Map<String, dynamic>? data) {
    if (data == null) return false;
    final collector = data['collectorId'] ?? data['collectorName'] ?? data['collector'] ?? data['assignedCollector'] ?? data['driverName'];
    return collector != null && collector.toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // If no pickupId, show pending state
    if (widget.pickupId == null || widget.pickupId!.isEmpty) {
      return _buildPendingScreen();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickupRequests')
          .doc(widget.pickupId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final status = _getStatus(data);
        final approved = _isApproved(status);
        final collectorAssigned = _isCollectorAssigned(data);

        // Removed fake ETA hook

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
                          if (approved && collectorAssigned) ...[
                            _buildLiveMap(data),
                            const SizedBox(height: 20),
                            _buildETABanner(),
                          ] else ...[
                            _buildPendingBanner(status),
                          ],
                          const SizedBox(height: 20),
                          _buildTrackingTimeline(status, collectorAssigned),
                          const SizedBox(height: 24),
                          if (approved && collectorAssigned)
                            _buildDriverCard(data)
                          else
                            _buildAwaitingDriverCard(),
                          const SizedBox(height: 24),
                          _buildPickupDetails(data),
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
      },
    );
  }

  Widget _buildPendingScreen() {
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
                      _buildPendingBanner('pending'),
                      const SizedBox(height: 20),
                      _buildTrackingTimeline('pending', false),
                      const SizedBox(height: 24),
                      _buildAwaitingDriverCard(),
                      const SizedBox(height: 24),
                      _buildPickupDetails(null),
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
                border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              languageService.t('track_pickup'),
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
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
                SizedBox(width: 6),
                Text(
                  languageService.t('live'),
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

  Widget _buildLiveMap(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();

    final double? destLat = (data['latitude'] ?? data['userLatitude'])?.toDouble();
    final double? destLng = (data['longitude'] ?? data['userLongitude'])?.toDouble();
    final String? driverId = data['collectorId'] ?? data['driverId'];

    debugPrint('[MAP] destLat=$destLat, destLng=$destLng, collectorId=$driverId');

    // If we don't have collector ID, just show standard fallback map
    if (driverId == null || driverId.isEmpty) {
       debugPrint('[MAP] ❌ No collector ID — showing fallback map');
       return _buildFallbackMap(destLat, destLng);
    }

    if (_lastDriverId != driverId || _liveLocationStream == null) {
      _lastDriverId = driverId;
      _liveLocationStream = FirebaseFirestore.instance.collection('collectorLocations').doc(driverId).snapshots();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _liveLocationStream,
      builder: (context, snapshot) {
        double? driverLat;
        double? driverLng;
        
        if (snapshot.hasData && snapshot.data!.exists) {
           final locData = snapshot.data!.data() as Map<String, dynamic>?;
           driverLat = locData?['latitude']?.toDouble();
           driverLng = locData?['longitude']?.toDouble();
           debugPrint('[MAP] ✅ Collector location: ($driverLat, $driverLng)');
           
           // Automatically pan the map to follow the driver
           if (driverLat != null && driverLng != null) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               try {
                 _mapController.move(LatLng(driverLat!, driverLng!), _mapController.camera.zoom);
               } catch (e) {
                 // Controller might not be ready yet
               }
             });
           }
        } else {
           debugPrint('[MAP] ⚠️ collectorLocations/$driverId not found or empty');
        }

        return _buildMapContainer(destLat, destLng, driverLat, driverLng);
      }
    );
  }

  Widget _buildFallbackMap(double? destLat, double? destLng) {
    return _buildMapContainer(destLat, destLng, null, null);
  }

  Widget _buildMapContainer(double? destLat, double? destLng, double? driverLat, double? driverLng) {
    // Default to Bangalore if nothing is available
    final LatLng center = destLat != null && destLng != null 
        ? LatLng(destLat, destLng) 
        : const LatLng(12.9716, 77.5946);
        
    // Trigger async fetch loop without blocking UI
    Future.microtask(() => _checkAndFetchRoute(driverLat, driverLng, destLat, destLng));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.binnit.ecowasteapp',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.8),
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Destination Marker
                      if (destLat != null && destLng != null)
                        Marker(
                          point: LatLng(destLat, destLng),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.home_rounded,
                            color: Color(0xFFE53935),
                            size: 30,
                          ),
                        ),
                      // Driver Marker
                      if (driverLat != null && driverLng != null)
                        Marker(
                          point: LatLng(driverLat, driverLng),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
            color: Colors.black.withValues(alpha: 0.1),
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
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.15),
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
                  Text(
                    _hasEta ? 'Arriving in' : 'Collector en route',
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
                        _hasEta ? '$_etaMinutes' : '...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          _hasEta ? 'min' : 'calculating',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: _hasEta ? 16 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Share tracking link coming soon!'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBanner(String status) {
    final isPending = status == 'pending' || status == 'submitted';
    final statusLabel = isPending ? 'Awaiting Collector' : 'Request ${status[0].toUpperCase()}${status.substring(1)}';
    final statusIcon = isPending ? Icons.hourglass_top_rounded : Icons.check_circle_outline_rounded;
    final statusColor = isPending ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPending
                ? [const Color(0xFFF57C00), const Color(0xFFFFB74D)]
                : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPending
                  ? 'Your pickup request has been submitted.\nWaiting for a collector to be assigned.'
                  : 'Your request has been processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(String status, bool collectorAssigned) {
    // Status progression: pending → assigned → accepted → on_the_way → reached → picked_up → completed
    const statusOrder = ['pending', 'assigned', 'accepted', 'on_the_way', 'reached', 'picked_up', 'completed'];
    final currentIndex = statusOrder.indexOf(status);
    
    final isApprovedStatus = currentIndex >= 1; // assigned or beyond
    final isAccepted = currentIndex >= 2;       // accepted or beyond
    final isOnTheWay = currentIndex >= 3;       // on_the_way or beyond
    final isReached = currentIndex >= 4;         // reached or beyond
    final isCompleted = currentIndex >= 6;       // completed

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
              'Request Submitted',
              '✓',
              true,
              isApprovedStatus,
              const Color(0xFF4CAF50),
              Icons.check_circle_rounded,
            ),
            _timelineStep(
              'Waiting for Collector',
              isApprovedStatus ? '✓' : 'Pending',
              isApprovedStatus,
              isAccepted,
              isApprovedStatus ? const Color(0xFF4CAF50) : AppTheme.textLight,
              isApprovedStatus ? Icons.verified_user_rounded : Icons.hourglass_top_rounded,
            ),
            _timelineStep(
              'Collector Assigned',
              isAccepted ? '✓' : '—',
              isAccepted,
              isOnTheWay,
              isAccepted ? const Color(0xFF4CAF50) : AppTheme.textLight,
              Icons.person_pin_rounded,
            ),
            _timelineStep(
              'On the Way',
              isOnTheWay ? '✓' : '—',
              isOnTheWay,
              isReached,
              isOnTheWay ? const Color(0xFFFF9800) : AppTheme.textLight,
              Icons.local_shipping_rounded,
            ),
            _timelineStep(
              'Pickup Complete',
              isCompleted ? '✓' : '—',
              isCompleted,
              false,
              isCompleted ? const Color(0xFF4CAF50) : AppTheme.textLight,
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
                color: isDone ? color.withValues(alpha: 0.15) : AppTheme.inputBackground,
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
                color: isLineDone ? const Color(0xFF4CAF50).withValues(alpha: 0.3) : AppTheme.dividerColor.withValues(alpha: 0.3),
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

  Widget _buildAwaitingDriverCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collector Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search_rounded, color: AppTheme.textLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Awaiting collector assignment',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic>? data) {
    final driverName = data?['collectorName'] ?? data?['driverName'] ?? data?['assignedCollector'] ?? '—';
    final initials = driverName != '—' && driverName.toString().isNotEmpty
        ? driverName.toString().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '—';
    final collectorPhone = data?['collectorPhone'] ?? data?['userPhone'] ?? '';
    final collectorId = data?['collectorId'] ?? '';
    final statusRaw = (data?['status'] ?? '').toString().toUpperCase();
    String statusLabel = 'Assigned';
    if (statusRaw == 'ACCEPTED') statusLabel = 'Accepted';
    if (statusRaw == 'ON_THE_WAY') statusLabel = 'On the Way';
    if (statusRaw == 'REACHED') statusLabel = 'Reached';
    if (statusRaw == 'PICKED_UP') statusLabel = 'Picked Up';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collector Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
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
                      Text(
                        driverName.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Direct driver calling coming soon!'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.call_rounded,
                        color: Color(0xFF4CAF50), size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('In-app driver messaging coming soon!'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_rounded,
                        color: Color(0xFF2196F3), size: 22),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: $statusLabel',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (collectorId.toString().isNotEmpty)
                          Text(
                            'ID: ${collectorId.toString().substring(0, collectorId.toString().length > 8 ? 8 : collectorId.toString().length)}...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                      ],
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

  Widget _buildPickupDetails(Map<String, dynamic>? data) {
    String dateStr = '—';
    if (data?['date'] != null) {
      if (data!['date'] is Timestamp) {
        final dt = (data['date'] as Timestamp).toDate();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } else {
        dateStr = data['date'].toString();
      }
    }
    
    final time = data?['time'] ?? '—';
    final address = data?['address'] ?? '—';
    
    String wasteTypeStr = '—';
    if (data?['wasteTypes'] != null) {
      if (data!['wasteTypes'] is List) {
        wasteTypeStr = (data['wasteTypes'] as List).join(', ');
      } else {
        wasteTypeStr = data['wasteTypes'].toString();
      }
    }

    final weight = data?['weightKg'] != null ? '${data!['weightKg']} Kg' : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                dateStr, const Color(0xFF2196F3)),
            const SizedBox(height: 10),
            _infoRow(Icons.access_time_rounded, 'Time',
                time.toString(), const Color(0xFFFF9800)),
            const SizedBox(height: 10),
            _infoRow(Icons.location_on_rounded, 'Address',
                address.toString(), const Color(0xFFE53935)),
            const SizedBox(height: 10),
            _infoRow(Icons.delete_outline_rounded, 'Waste Type',
                wasteTypeStr, const Color(0xFF4CAF50)),
            const SizedBox(height: 10),
            _infoRow(Icons.scale_rounded, 'Weight',
                weight, AppTheme.primaryGreen),
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
            color: color.withValues(alpha: 0.1),
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

