import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Pickup details screen
class PickupDetailsScreen extends StatelessWidget {
  final String? pickupId;

  const PickupDetailsScreen({super.key, this.pickupId});

  @override
  Widget build(BuildContext context) {
    // In a real app, fetch pickup details by ID
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingL),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingM),
                    Text(
                      'Pickup Completed',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                    Text(
                      'Order #${pickupId ?? "1234"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimens.paddingM),

            // User details
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
                      title: const Text('John Doe'),
                      subtitle: const Text('+91 98765 43210'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
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
                            '123, Green Park, Sector 15, Delhi - 110001',
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
                    _DetailRow(label: 'Waste Type', value: '📦 Dry Waste'),
                    _DetailRow(label: 'Weight', value: '5.0 kg'),
                    _DetailRow(
                      label: 'Date',
                      value: DateHelper.formatDate(DateTime.now()),
                    ),
                    _DetailRow(label: 'Time', value: '10:00 AM - 12:00 PM'),
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
                      label: 'Collection Fee',
                      value: CurrencyHelper.formatCurrency(100),
                    ),
                    _DetailRow(
                      label: 'Bonus',
                      value: CurrencyHelper.formatCurrency(20),
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Total Earned',
                      value: CurrencyHelper.formatCurrency(120),
                      isHighlighted: true,
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
