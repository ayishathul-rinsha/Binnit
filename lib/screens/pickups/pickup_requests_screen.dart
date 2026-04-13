import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/pickup_provider.dart';
import '../../services/pickup_service.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Pickup requests screen — shows pickups assigned by admin
class PickupRequestsScreen extends StatefulWidget {
  const PickupRequestsScreen({super.key});

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    final provider = Provider.of<PickupProvider>(context, listen: false);
    await provider.fetchAssignedPickups();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assignedToYou),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body: Consumer<PickupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const SkeletonLoader();
          }

          if (provider.error != null) {
            return ErrorState(
              message: provider.error!,
              onAction: _loadRequests,
            );
          }

          final requests = provider.assignedPickups;

          if (requests.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: l10n.noAssignedPickups,
              actionLabel: l10n.refresh,
              onAction: _loadRequests,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _AssignedPickupCard(
                  pickup: request,
                  onAccept: () => _acceptPickup(request.id),
                  onReject: () => _rejectPickup(request.id),
                  onTimerExpired: () => _autoReject(request.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _acceptPickup(String pickupId) async {
    final result = await PickupService.collectorAcceptPickup(pickupId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? AppLocalizations.of(context).pickupAccepted
                : AppLocalizations.of(context).failedAccept,
          ),
          backgroundColor: result['success'] == true ? AppColors.success : AppColors.error,
        ),
      );
      if (result['success'] == true) {
        _loadRequests();
        // Also refresh active pickups so the accepted pickup appears in the Active tab
        if (mounted) {
          Provider.of<PickupProvider>(context, listen: false).fetchActivePickups();
        }
      }
    }
  }

  Future<void> _rejectPickup(String pickupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.rejectPickup),
          content: Text(l10n.rejectPickupConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.reject),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final result = await PickupService.collectorRejectPickup(pickupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? AppLocalizations.of(context).pickupReturnedAdmin
                  : AppLocalizations.of(context).failedReject,
            ),
            backgroundColor: result['success'] == true ? AppColors.info : AppColors.error,
          ),
        );
        if (result['success'] == true) _loadRequests();
      }
    }
  }

  Future<void> _autoReject(String pickupId) async {
    if (!mounted) return;
    await PickupService.collectorRejectPickup(pickupId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).timeExpired),
          backgroundColor: AppColors.error,
        ),
      );
      _loadRequests();
    }
  }
}

/// Card for an admin-assigned pickup with countdown timer
class _AssignedPickupCard extends StatefulWidget {
  final PickupRequest pickup;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTimerExpired;

  const _AssignedPickupCard({
    required this.pickup,
    required this.onAccept,
    required this.onReject,
    required this.onTimerExpired,
  });

  @override
  State<_AssignedPickupCard> createState() => _AssignedPickupCardState();
}

class _AssignedPickupCardState extends State<_AssignedPickupCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  /// 10-minute window for the collector to respond
  static const _responseWindow = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final assignedAt = widget.pickup.assignedAt ?? widget.pickup.createdAt;
    final deadline = assignedAt.add(_responseWindow);
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      _timer?.cancel();
      widget.onTimerExpired();
    } else {
      if (mounted) {
        setState(() {
          _remaining = diff;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color get _timerColor {
    if (_remaining.inMinutes < 2) return AppColors.error;
    if (_remaining.inMinutes < 5) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.pickupDetails,
            arguments: {'pickup': widget.pickup},
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer bar + category
            Row(
              children: [
                // Countdown badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    border: Border.all(color: _timerColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 16, color: _timerColor),
                      const SizedBox(width: 4),
                      Text(
                        _timerText,
                        style: TextStyle(
                          color: _timerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Category badge
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
                    '${widget.pickup.category.icon} ${widget.pickup.category.displayName}',
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
                        widget.pickup.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.pickup.userAddress,
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

            // Info chips
            Row(
              children: [
                _InfoChip(
                  icon: Icons.directions_walk,
                  label: DistanceHelper.formatDistance(widget.pickup.distance),
                ),
                const SizedBox(width: AppDimens.paddingM),
                _InfoChip(
                  icon: Icons.scale,
                  label: WeightHelper.formatWeight(widget.pickup.estimatedWeight),
                ),
                const SizedBox(width: AppDimens.paddingM),
                _InfoChip(
                  icon: Icons.payments,
                  label: CurrencyHelper.formatCurrency(widget.pickup.paymentAmount),
                ),
              ],
            ),

            const Divider(height: AppDimens.paddingL * 2),

            // Accept / Reject buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onReject,
                    icon: const Icon(Icons.close, color: AppColors.error),
                    label: Text(AppLocalizations.of(context).reject,
                        style: const TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: widget.onAccept,
                    icon: const Icon(Icons.check_circle),
                    label: Text(AppLocalizations.of(context).acceptPickup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Small info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
