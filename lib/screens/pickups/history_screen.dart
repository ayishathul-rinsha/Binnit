import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/pickup_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// History screen with completed pickups
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange? _selectedDateRange;
  WasteCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    final provider = Provider.of<PickupProvider>(context, listen: false);
    await provider.fetchHistory(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      category: _selectedCategory,
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickupHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedDateRange != null || _selectedCategory != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingM,
                vertical: AppDimens.paddingS,
              ),
              child: Row(
                children: [
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppDimens.paddingS),
                      child: Chip(
                        label: Text(
                          '${DateHelper.formatDate(_selectedDateRange!.start)} - ${DateHelper.formatDate(_selectedDateRange!.end)}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                          _loadHistory();
                        },
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                        _selectedCategory = null;
                      });
                      _loadHistory();
                    },
                    child: Text(AppLocalizations.of(context).clearAll),
                  ),
                ],
              ),
            ),

          // History list
          Expanded(
            child: Consumer<PickupProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return ErrorState(
                    message: provider.error!,
                    onAction: _loadHistory,
                  );
                }

                final history = provider.history;

                if (history.isEmpty) {
                  return EmptyState(
                    icon: Icons.history,
                    title: AppLocalizations.of(context).noHistoryYet,
                    subtitle: AppLocalizations.of(context).historySubtitle,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.paddingM),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final pickup = history[index];
                      return _HistoryCard(pickup: pickup);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// History card widget
class _HistoryCard extends StatelessWidget {
  final PickupRequest pickup;

  const _HistoryCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingS,
                    vertical: AppDimens.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).completed,
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateHelper.formatDate(pickup.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.paddingM),

            // User info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.userName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${pickup.category.icon} ${pickup.category.displayName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: AppDimens.paddingM),
                          Text(
                            WeightHelper.formatWeight(pickup.estimatedWeight),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Earnings
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyHelper.formatCurrency(pickup.paymentAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (pickup.userRating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            pickup.userRating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
