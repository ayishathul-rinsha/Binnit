import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Pickup request card widget - Redesigned
class PickupRequestCard extends StatelessWidget {
  final PickupRequest pickup;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final bool showActions;

  const PickupRequestCard({
    super.key,
    required this.pickup,
    this.onAccept,
    this.onReject,
    this.onTap,
    this.showActions = true,
  });

  Color _getCategoryColor(WasteCategory category) {
    switch (category) {
      case WasteCategory.plastic:
        return AppColors.dryWaste; 
      case WasteCategory.paper:
        return AppColors.recyclables;
      case WasteCategory.organic:
        return AppColors.wetWaste;
      case WasteCategory.metal:
        return AppColors.hazardous;
      case WasteCategory.ewaste:
        return AppColors.eWaste;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(pickup.category);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: AppDimens.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!();
            } else {
              Navigator.pushNamed(
                context,
                '/pickup-details',
                arguments: {'pickup': pickup},
              );
            }
          },
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pickup.category.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pickup.category.displayName,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Payment amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        CurrencyHelper.formatCurrency(pickup.paymentAmount),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // User name
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pickup.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          pickup.userAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Soft Info Tags row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Distance
                      _InfoChip(
                        icon: Icons.directions_walk_rounded,
                        label: DistanceHelper.formatDistance(pickup.distance),
                      ),
                      const SizedBox(width: 8),
                      // Weight
                      _InfoChip(
                        icon: Icons.scale_rounded,
                        label: WeightHelper.formatWeight(pickup.estimatedWeight),
                      ),
                      const SizedBox(width: 8),
                      // Time
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        label: DateHelper.formatTimeRange(
                          pickup.pickupTimeStart,
                          pickup.pickupTimeEnd,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (showActions && (onAccept != null || onReject != null)) ...[
                  const SizedBox(height: 28),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (onReject != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                      if (onReject != null && onAccept != null)
                        const SizedBox(width: 16),
                      if (onAccept != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Accept Pickup'),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium pill info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
