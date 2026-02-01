import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/pickup_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

/// Pickup requests screen with filters
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
    await provider.fetchIncomingRequests();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Requests'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      body: Consumer<PickupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ErrorState(
              message: provider.error!,
              onAction: _loadRequests,
            );
          }

          final requests = provider.incomingRequests;

          if (requests.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No Pickup Requests',
              subtitle: 'New pickup requests will appear here when available',
              actionLabel: 'Refresh',
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
                return PickupRequestCard(
                  pickup: request,
                  onAccept: () => _acceptPickup(request.id),
                  onReject: () => _rejectPickup(request.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _acceptPickup(String pickupId) async {
    final provider = Provider.of<PickupProvider>(context, listen: false);
    final success = await provider.acceptPickup(pickupId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Pickup accepted!' : 'Failed to accept pickup',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectPickup(String pickupId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Pickup?'),
        content: const Text(
          'Are you sure you want to reject this pickup request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<PickupProvider>(context, listen: false);
      final success = await provider.rejectPickup(pickupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Pickup rejected' : 'Failed to reject pickup',
            ),
            backgroundColor: success ? AppColors.info : AppColors.error,
          ),
        );
      }
    }
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  WasteCategory? _selectedCategory;
  double? _maxDistance;
  bool _sortByNearest = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PickupProvider>(context, listen: false);
    _selectedCategory = provider.filter.category;
    _maxDistance = provider.filter.maxDistance;
    _sortByNearest = provider.filter.sortByNearest ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Requests',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _maxDistance = null;
                    _sortByNearest = false;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Waste category
          Text(
            'Waste Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.paddingS),
          Wrap(
            spacing: AppDimens.paddingS,
            runSpacing: AppDimens.paddingS,
            children: WasteCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text('${category.icon} ${category.displayName}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Max distance
          Text(
            'Maximum Distance: ${_maxDistance?.toStringAsFixed(1) ?? "Any"} km',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _maxDistance ?? 10,
            min: 1,
            max: 20,
            divisions: 19,
            label: '${_maxDistance?.toStringAsFixed(1) ?? "Any"} km',
            onChanged: (value) {
              setState(() {
                _maxDistance = value;
              });
            },
          ),
          const SizedBox(height: AppDimens.paddingM),

          // Sort by nearest
          SwitchListTile(
            title: const Text('Sort by Nearest'),
            value: _sortByNearest,
            onChanged: (value) {
              setState(() {
                _sortByNearest = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Apply button
          CustomButton(
            text: 'Apply Filters',
            onPressed: () {
              final provider = Provider.of<PickupProvider>(
                context,
                listen: false,
              );
              provider.setFilter(
                PickupFilter(
                  category: _selectedCategory,
                  maxDistance: _maxDistance,
                  sortByNearest: _sortByNearest,
                ),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppDimens.paddingM),
        ],
      ),
    );
  }
}
