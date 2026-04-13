import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/routing_service.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Pickup details screen with dynamic map
class PickupDetailsScreen extends StatefulWidget {
  final PickupRequest? pickup;

  const PickupDetailsScreen({super.key, this.pickup});

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  List<LatLng> _routePoints = [];
  LatLng? _driverPos;

  @override
  void initState() {
    super.initState();
    _fetchLiveRoute();
  }

  void _fetchLiveRoute() async {
    if (widget.pickup == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition();
      final start = LatLng(pos.latitude, pos.longitude);
      final dest = LatLng(widget.pickup!.userLatitude, widget.pickup!.userLongitude);
      
      if (mounted) setState(() => _driverPos = start);
      
      final pts = await RoutingService.getRoute(start, dest);
      if (mounted) setState(() => _routePoints = pts);
    } catch (_) {}
  }

  Future<void> _launchMaps() async {
    if (widget.pickup == null) return;
    final lat = widget.pickup!.userLatitude;
    final lng = widget.pickup!.userLongitude;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pickup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pickup Details')),
        body: const Center(child: Text('Error: No pickup data provided')),
      );
    }

    final pickup = widget.pickup!;
    final destPos = LatLng(pickup.userLatitude, pickup.userLongitude);
    // Use driverPos as center if available, else destPos
    final centerPos = _driverPos ?? destPos;

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Section
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: centerPos,
                      initialZoom: 13.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.binnit.collector',
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              strokeWidth: 5.0,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: destPos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.home,
                              color: AppColors.error,
                              size: 40,
                            ),
                          ),
                          if (_driverPos != null)
                            Marker(
                              point: _driverPos!,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _launchMaps,
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingM),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: pickup.status == PickupStatus.completed 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              pickup.status == PickupStatus.completed 
                                ? Icons.check_circle
                                : Icons.local_shipping,
                              color: pickup.status == PickupStatus.completed 
                                ? AppColors.success 
                                : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppDimens.paddingM),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickup.status.displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Order #${pickup.id.substring(0, 8).toUpperCase()}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.paddingM),

                  // Customer details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(pickup.userName),
                            subtitle: Text(pickup.userPhone),
                            contentPadding: EdgeInsets.zero,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppDimens.paddingS),
                              Expanded(
                                child: Text(
                                  pickup.userAddress,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.paddingM),

                  // Pickup details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _DetailRow(label: 'Waste Type', value: '${pickup.category.icon} ${pickup.category.displayName}'),
                          _DetailRow(label: 'Weight', value: '${pickup.estimatedWeight} kg'),
                          _DetailRow(
                            label: 'Date',
                            value: DateHelper.formatDate(pickup.pickupTimeStart),
                          ),
                          if (pickup.proofPhotoUrl != null) ...[
                            const SizedBox(height: AppDimens.paddingM),
                            Text('Proof of Completion', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: AppDimens.paddingS),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                pickup.proofPhotoUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Center(child: Icon(Icons.broken_image, size: 40)),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 150,
                                    color: Colors.grey.shade100,
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimens.paddingM),

                  // Payment details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          _DetailRow(
                            label: 'Total Earned',
                            value: CurrencyHelper.formatCurrency(pickup.paymentAmount),
                            isHighlighted: true,
                          ),
                        ],
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
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: isHighlighted
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
