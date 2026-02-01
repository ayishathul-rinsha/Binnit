import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../providers/pickup_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Active pickups screen
class ActivePickupsScreen extends StatefulWidget {
  const ActivePickupsScreen({super.key});

  @override
  State<ActivePickupsScreen> createState() => _ActivePickupsScreenState();
}

class _ActivePickupsScreenState extends State<ActivePickupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPickups();
    });
  }

  Future<void> _loadPickups() async {
    if (!mounted) return;
    final provider = Provider.of<PickupProvider>(context, listen: false);
    await provider.fetchActivePickups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Pickups'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPickups),
        ],
      ),
      body: Consumer<PickupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ErrorState(message: provider.error!, onAction: _loadPickups);
          }

          final pickups = provider.activePickups;

          if (pickups.isEmpty) {
            return EmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'No Active Pickups',
              subtitle: 'Accept a pickup request to see it here',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPickups,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              itemCount: pickups.length,
              itemBuilder: (context, index) {
                final pickup = pickups[index];
                return _ActivePickupCard(
                  pickup: pickup,
                  onStatusUpdate: (status) => _updateStatus(pickup.id, status),
                  onCall: () => _callUser(pickup.userPhone),
                  onNavigate: () => _navigateToLocation(
                    pickup.userLatitude,
                    pickup.userLongitude,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(String pickupId, PickupStatus status) async {
    final provider = Provider.of<PickupProvider>(context, listen: false);
    final success = await provider.updatePickupStatus(pickupId, status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Status updated to ${status.displayName}'
                : 'Failed to update status',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _callUser(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _navigateToLocation(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Active pickup card with status controls
class _ActivePickupCard extends StatelessWidget {
  final PickupRequest pickup;
  final Function(PickupStatus) onStatusUpdate;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const _ActivePickupCard({
    required this.pickup,
    required this.onStatusUpdate,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge and category
            Row(
              children: [
                _StatusBadge(status: pickup.status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingS,
                    vertical: AppDimens.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Text(
                    '${pickup.category.icon} ${pickup.category.displayName}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.paddingM),

            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.userName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        pickup.userAddress,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.paddingM),

            // Info row
            Row(
              children: [
                _InfoItem(
                  icon: Icons.directions_walk,
                  value: DistanceHelper.formatDistance(pickup.distance),
                ),
                const SizedBox(width: AppDimens.paddingL),
                _InfoItem(
                  icon: Icons.scale,
                  value: WeightHelper.formatWeight(pickup.estimatedWeight),
                ),
                const SizedBox(width: AppDimens.paddingL),
                _InfoItem(
                  icon: Icons.payments,
                  value: CurrencyHelper.formatCurrency(pickup.paymentAmount),
                ),
              ],
            ),

            const Divider(height: AppDimens.paddingL * 2),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.paddingM),

            // Status update button
            _StatusUpdateButton(
              currentStatus: pickup.status,
              onStatusUpdate: onStatusUpdate,
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final PickupStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case PickupStatus.accepted:
        return AppColors.info;
      case PickupStatus.onTheWay:
        return AppColors.warning;
      case PickupStatus.reached:
        return AppColors.secondary;
      case PickupStatus.pickedUp:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
          ),
          const SizedBox(width: AppDimens.paddingS),
          Text(
            status.displayName,
            style: TextStyle(color: _color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Info item widget
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Status update button
class _StatusUpdateButton extends StatelessWidget {
  final PickupStatus currentStatus;
  final Function(PickupStatus) onStatusUpdate;

  const _StatusUpdateButton({
    required this.currentStatus,
    required this.onStatusUpdate,
  });

  PickupStatus? get _nextStatus {
    switch (currentStatus) {
      case PickupStatus.accepted:
        return PickupStatus.onTheWay;
      case PickupStatus.onTheWay:
        return PickupStatus.reached;
      case PickupStatus.reached:
        return PickupStatus.pickedUp;
      case PickupStatus.pickedUp:
        return PickupStatus.completed;
      default:
        return null;
    }
  }

  String get _buttonText {
    switch (currentStatus) {
      case PickupStatus.accepted:
        return "I'm On the Way";
      case PickupStatus.onTheWay:
        return "I've Reached";
      case PickupStatus.reached:
        return 'Start Pickup';
      case PickupStatus.pickedUp:
        return 'Complete Pickup';
      default:
        return 'Update Status';
    }
  }

  IconData get _buttonIcon {
    switch (currentStatus) {
      case PickupStatus.accepted:
        return Icons.directions_car;
      case PickupStatus.onTheWay:
        return Icons.location_on;
      case PickupStatus.reached:
        return Icons.handshake;
      case PickupStatus.pickedUp:
        return Icons.check_circle;
      default:
        return Icons.update;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nextStatus == null) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: () => onStatusUpdate(_nextStatus!),
      icon: Icon(_buttonIcon),
      label: Text(_buttonText),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
        backgroundColor:
            currentStatus == PickupStatus.pickedUp ? AppColors.success : null,
      ),
    );
  }
}
