import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Pickup request card widget
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
      case WasteCategory.dryWaste:
        return AppColors.dryWaste;
      case WasteCategory.wetWaste:
        return AppColors.wetWaste;
      case WasteCategory.eWaste:
        return AppColors.eWaste;
      case WasteCategory.recyclables:
        return AppColors.recyclables;
      case WasteCategory.hazardous:
        return AppColors.hazardous;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(pickup.category);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingS,
                      vertical: AppDimens.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pickup.category.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pickup.category.displayName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Payment amount
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
                      CurrencyHelper.formatCurrency(pickup.paymentAmount),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.paddingM),

              // User name
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: Text(
                      pickup.userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.paddingS),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: Text(
                      pickup.userAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.paddingM),

              // Info row
              Row(
                children: [
                  // Distance
                  _InfoChip(
                    icon: Icons.directions_walk,
                    label: DistanceHelper.formatDistance(pickup.distance),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  // Weight
                  _InfoChip(
                    icon: Icons.scale,
                    label: WeightHelper.formatWeight(pickup.estimatedWeight),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  // Time
                  _InfoChip(
                    icon: Icons.access_time,
                    label: DateHelper.formatTimeRange(
                      pickup.pickupTimeStart,
                      pickup.pickupTimeEnd,
                    ),
                  ),
                ],
              ),

              // Action buttons
              if (showActions && (onAccept != null || onReject != null)) ...[
                const SizedBox(height: AppDimens.paddingM),
                const Divider(),
                const SizedBox(height: AppDimens.paddingS),
                Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    if (onReject != null && onAccept != null)
                      const SizedBox(width: AppDimens.paddingM),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                  ],
                ),
              ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
