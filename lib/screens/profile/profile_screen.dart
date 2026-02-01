import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

/// Profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, Routes.editProfile);
            },
          ),
        ],
      ),
      body: Consumer<CollectorProvider>(
        builder: (context, provider, child) {
          final collector = provider.collector;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            child: Column(
              children: [
                // Profile header
                _buildProfileHeader(context, collector),
                const SizedBox(height: AppDimens.paddingL),

                // Stats card
                _buildStatsCard(context, collector),
                const SizedBox(height: AppDimens.paddingL),

                // Menu sections
                _buildMenuSection(
                  context,
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.directions_car,
                      title: 'Vehicle Details',
                      subtitle:
                          collector?.vehicle?.vehicleNumber ?? 'Not added',
                      onTap: () =>
                          _showVehicleDetails(context, collector?.vehicle),
                    ),
                    _MenuItem(
                      icon: Icons.description,
                      title: 'Documents',
                      subtitle: 'ID proof, Vehicle registration',
                      onTap: () => _showDocuments(context),
                    ),
                    _MenuItem(
                      icon: Icons.account_balance,
                      title: 'Bank Details',
                      subtitle: collector?.bankDetails?.bankName ?? 'Not added',
                      onTap: () =>
                          _showBankDetails(context, collector?.bankDetails),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingM),

                _buildMenuSection(
                  context,
                  title: 'Settings',
                  items: [
                    _MenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingL),

                // Logout button
                _buildLogoutButton(context),
                const SizedBox(height: AppDimens.paddingL),

                // App version
                Text(
                  'Version 1.0.0',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppDimens.paddingM),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, collector) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                (collector?.name ?? 'U')[0].toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collector?.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collector?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    collector?.phone ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildStatsCard(BuildContext context, collector) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              value: '${collector?.totalPickups ?? 0}',
              label: 'Pickups',
              icon: Icons.local_shipping,
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade200),
            _StatItem(
              value: (collector?.rating ?? 0).toStringAsFixed(1),
              label: 'Rating',
              icon: Icons.star,
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade200),
            _StatItem(
              value: '${(collector?.totalHoursToday ?? 0).toStringAsFixed(0)}h',
              label: 'Today',
              icon: Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.paddingS),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppDimens.paddingS),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusS),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final collectorProvider = Provider.of<CollectorProvider>(
                context,
                listen: false,
              );

              await authProvider.logout();
              collectorProvider.clear();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetails(BuildContext context, vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimens.paddingL),
            if (vehicle != null) ...[
              _DetailRow('Type', vehicle.vehicleType),
              _DetailRow('Number', vehicle.vehicleNumber),
            ] else
              const Center(child: Text('No vehicle details added')),
            const SizedBox(height: AppDimens.paddingL),
            CustomButton(
              text: vehicle != null ? 'Edit Details' : 'Add Vehicle',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocuments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documents', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppDimens.paddingL),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('ID Proof'),
              trailing: const Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicle Registration'),
              trailing: const Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppDimens.paddingL),
            CustomButton(
              text: 'Upload New Document',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBankDetails(BuildContext context, bankDetails) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimens.paddingL),
            if (bankDetails != null) ...[
              _DetailRow('Bank', bankDetails.bankName),
              _DetailRow('Account', bankDetails.accountNumber),
              _DetailRow('IFSC', bankDetails.ifscCode),
              _DetailRow('Name', bankDetails.accountHolderName),
            ] else
              const Center(child: Text('No bank details added')),
            const SizedBox(height: AppDimens.paddingL),
            CustomButton(
              text: bankDetails != null ? 'Edit Details' : 'Add Bank Account',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu item model
class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

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
          Text(value),
        ],
      ),
    );
  }
}
