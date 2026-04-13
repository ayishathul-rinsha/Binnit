import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../models/collector_model.dart';
import '../../routes/app_routes.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

/// Profile screen - Premium Overlapping Header Makeover
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<CollectorProvider>(
        builder: (context, provider, child) {
          final collector = provider.collector;
          final l10n = AppLocalizations.of(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              children: [
                _buildProfileHeader(context, collector),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Stats Row
                      _buildStatsCard(context, collector),
                      const SizedBox(height: 32),

                      // Account section
                      _buildMenuSection(
                        context,
                        title: l10n.account,
                        items: [
                          _MenuItem(
                            icon: Icons.directions_car_rounded,
                            title: l10n.vehicleDetails,
                            subtitle: collector?.vehicle?.vehicleNumber ?? l10n.notAdded,
                            color: AppColors.primary,
                            onTap: () => _showEditVehicleSheet(context, collector?.vehicle),
                          ),
                          _MenuItem(
                            icon: Icons.description_rounded,
                            title: l10n.documents,
                            subtitle: (collector?.idProofUrl ?? '').isNotEmpty
                                ? l10n.uploaded
                                : l10n.notUploaded,
                            color: AppColors.ochre,
                            onTap: () => _showDocuments(context, collector),
                          ),
                          _MenuItem(
                            icon: Icons.account_balance_rounded,
                            title: l10n.bankDetails,
                            subtitle: collector?.bankDetails?.bankName ?? l10n.notAdded,
                            color: AppColors.primaryLight,
                            onTap: () => _showEditBankSheet(context, collector?.bankDetails),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Settings section
                      _buildMenuSection(
                        context,
                        title: l10n.settings,
                        items: [
                          _MenuItem(
                            icon: Icons.my_location_rounded,
                            title: 'Set Live Location',
                            subtitle: 'Manual override for GPS',
                            color: AppColors.primaryDark,
                            onTap: () => Navigator.pushNamed(context, Routes.setLocation),
                          ),
                          _MenuItem(
                            icon: Icons.notifications_rounded,
                            title: l10n.notifications,
                            color: const Color(0xFF6B705C),
                            onTap: () => _showNotificationSettings(context),
                          ),
                          _MenuItem(
                            icon: Icons.language_rounded,
                            title: l10n.language,
                            subtitle: l10n.changeLanguage,
                            color: const Color(0xFF6B705C),
                            onTap: () => _showLanguageSelection(context),
                          ),
                          _MenuItem(
                            icon: Icons.help_rounded,
                            title: l10n.helpSupport,
                            color: const Color(0xFF6B705C),
                            onTap: () => _showHelpSupport(context),
                          ),
                          _MenuItem(
                            icon: Icons.privacy_tip_rounded,
                            title: l10n.privacyPolicy,
                            color: const Color(0xFF6B705C),
                            onTap: () => _openPrivacyPolicy(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildLogoutButton(context),
                      const SizedBox(height: 32),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight.withOpacity(0.5),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Profile Header (Overlapping Aesthetic) ───
  Widget _buildProfileHeader(BuildContext context, collector) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Sweeping Gradient Base
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          child: Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Top Action Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.editProfile),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Overlapping Avatar & Info Panel
        Container(
          margin: const EdgeInsets.only(top: 140, left: 24, right: 24),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusXL),
            boxShadow: AppDimens.softShadow,
          ),
          child: Column(
            children: [
              Text(
                collector?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                collector?.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if ((collector?.phone ?? '').isNotEmpty)
                _buildInfoBadge(Icons.phone_rounded, collector?.phone ?? ''),
              if ((collector?.city ?? '').isNotEmpty)
                _buildInfoBadge(Icons.location_on_rounded,
                    '${collector?.address}, ${collector?.city}'),
              if ((collector?.experience ?? '').isNotEmpty)
                _buildInfoBadge(
                    Icons.work_rounded, '${collector?.experience} Years Exp'),
            ],
          ),
        ),

        // The Floating Avatar
        Positioned(
          top: 90,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              backgroundImage: (collector?.photoUrl ?? '').isNotEmpty
                  ? NetworkImage(collector!.photoUrl)
                  : null,
              onBackgroundImageError: (collector?.photoUrl ?? '').isNotEmpty
                  ? (exception, stackTrace) {}
                  : null,
              child: (collector?.photoUrl ?? '').isEmpty
                  ? Text(
                      (collector?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textLight),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Card ───
  Widget _buildStatsCard(BuildContext context, collector) {
    if (collector == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, dynamic>>(
      future: FirestoreService.getCollectorStats(collector.id),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final pickups = stats?['totalPickups'] ?? collector.totalPickups ?? 0;
        final rating = (stats?['rating'] ?? collector.rating ?? 0.0) as double;
        final todayHours = (stats?['totalHoursToday'] ??
            collector.totalHoursToday ??
            0.0) as double;

        return Row(
          children: [
            Expanded(
              child: _buildStatMiniCard(
                  'Pickups', '$pickups', Icons.local_shipping_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatMiniCard(
                  'Rating',
                  rating > 0 ? rating.toStringAsFixed(1) : '–',
                  Icons.star_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatMiniCard('Today',
                  '${todayHours.toStringAsFixed(1)}h', Icons.schedule_rounded),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatMiniCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: AppDimens.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Menu Section (Super Card) ───
  Widget _buildMenuSection(BuildContext context,
      {required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusXL),
            boxShadow: AppDimens.softShadow,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: _getMenuItemRadius(index, items.length),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child:
                                  Icon(item.icon, color: item.color, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.subtitle!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: AppColors.border),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 80, right: 20),
                      child: Container(
                        height: 1,
                        color: AppColors.divider,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  BorderRadius _getMenuItemRadius(int index, int length) {
    if (length == 1) return BorderRadius.circular(AppDimens.radiusXL);
    if (index == 0) {
      return BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXL));
    }
    if (index == length - 1) {
      return BorderRadius.vertical(bottom: Radius.circular(AppDimens.radiusXL));
    }
    return BorderRadius.zero;
  }

  // ─── Editable Vehicle Details ───
  void _showEditVehicleSheet(BuildContext context, VehicleDetails? vehicle) {
    // Keep internal logic but apply soft borders to text fields implicitly from AppTheme
    final typeController =
        TextEditingController(text: vehicle?.vehicleType ?? '');
    final numberController =
        TextEditingController(text: vehicle?.vehicleNumber ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 32),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                hintText: 'e.g. Auto, Truck, Van',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: numberController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'e.g. KL-07-AB-1234',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (typeController.text.trim().isEmpty ||
                    numberController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                final provider =
                    Provider.of<CollectorProvider>(ctx, listen: false);
                final newVehicle = VehicleDetails(
                  id: vehicle?.id ?? 'v1',
                  vehicleType: typeController.text.trim(),
                  vehicleNumber: numberController.text.trim(),
                  registrationDocUrl: vehicle?.registrationDocUrl ?? '',
                );
                final success = await provider.updateVehicleDetails(newVehicle);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(
                        success ? 'Vehicle details saved!' : 'Failed to save'),
                  ));
                }
              },
              child: Text(vehicle != null ? 'Save Changes' : 'Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Documents ───
  void _showDocuments(BuildContext context, collector) {
    // Basic logic intact, visually updated
    final hasIdProof = (collector?.idProofUrl ?? '').isNotEmpty;
    final hasVehicleReg =
        (collector?.vehicle?.registrationDocUrl ?? '').isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documents',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 32),
            _buildDocStatusItem('ID Proof', Icons.badge_rounded, hasIdProof),
            const SizedBox(height: 20),
            _buildDocStatusItem('Vehicle Registration',
                Icons.directions_car_rounded, hasVehicleReg),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Contact admin to update documents',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatusItem(String title, IconData icon, bool isUploaded) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon,
              color: isUploaded ? AppColors.success : AppColors.error),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text(isUploaded ? 'Uploaded securely' : 'Not uploaded',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isUploaded ? AppColors.success : AppColors.error,
                  )),
            ],
          ),
        ),
        Icon(
          isUploaded ? Icons.verified_rounded : Icons.info_outline_rounded,
          color: isUploaded ? AppColors.success : AppColors.error,
          size: 24,
        )
      ],
    );
  }

  // ─── Editable Bank Details ───
  void _showEditBankSheet(BuildContext context, BankDetails? bank) {
    final bankNameCtrl = TextEditingController(text: bank?.bankName ?? '');
    final accountCtrl = TextEditingController(text: bank?.accountNumber ?? '');
    final ifscCtrl = TextEditingController(text: bank?.ifscCode ?? '');
    final holderCtrl =
        TextEditingController(text: bank?.accountHolderName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 32),
              TextField(
                controller: bankNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g. State Bank of India',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: accountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ifscCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: holderCtrl,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (bankNameCtrl.text.trim().isEmpty ||
                      accountCtrl.text.trim().isEmpty ||
                      ifscCtrl.text.trim().isEmpty ||
                      holderCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('Please fill all fields')));
                    return;
                  }
                  final provider =
                      Provider.of<CollectorProvider>(ctx, listen: false);
                  final newBank = BankDetails(
                    bankName: bankNameCtrl.text.trim(),
                    accountNumber: accountCtrl.text.trim(),
                    ifscCode: ifscCtrl.text.trim(),
                    accountHolderName: holderCtrl.text.trim(),
                  );
                  final success = await provider.updateBankDetails(newBank);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(
                          success ? 'Bank details saved!' : 'Failed to save'),
                    ));
                  }
                },
                child: Text(bank != null ? 'Save Changes' : 'Add Bank Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Language Selection ───
  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (ctx) => const _LanguageSelectionSheet(),
    );
  }

  // ─── Notification Settings ───
  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (ctx) => const _NotificationSheet(),
    );
  }

  // ─── Help & Support ───
  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.email_rounded, color: Colors.blue),
              ),
              title: const Text('Email Support',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('garbo0123garbo@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => launchUrl(Uri.parse('mailto:garbo0123garbo@gmail.com')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Privacy Policy ───
  void _openPrivacyPolicy() {
    launchUrl(
      Uri.parse('https://gigzo.app/privacy-policy'),
      mode: LaunchMode.externalApplication,
    );
  }

  // ─── Logout ───
  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      label: const Text('Logout Extracted'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide.none, // Pure text style but padded
        backgroundColor: AppColors.error.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingM, horizontal: 32),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content:
            const Text('Are you sure you want to securely end your session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final collectorProvider =
                  Provider.of<CollectorProvider>(context, listen: false);
              await authProvider.logout();
              collectorProvider.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Settings Sheet (Stateful) ───
class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  bool _pickupAlerts = true;
  bool _earningsUpdates = true;
  bool _promotions = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pickupAlerts = prefs.getBool('notif_pickup') ?? true;
      _earningsUpdates = prefs.getBool('notif_earnings') ?? true;
      _promotions = prefs.getBool('notif_promos') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_pickup', _pickupAlerts);
    await prefs.setBool('notif_earnings', _earningsUpdates);
    await prefs.setBool('notif_promos', _promotions);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pickup Alerts',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('New assignments & updates',
                style: TextStyle(fontWeight: FontWeight.w500)),
            value: _pickupAlerts,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _pickupAlerts = v);
              _savePrefs();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Earnings Updates',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Payment & wallet notifications',
                style: TextStyle(fontWeight: FontWeight.w500)),
            value: _earningsUpdates,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _earningsUpdates = v);
              _savePrefs();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Promotions',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Offers & announcements',
                style: TextStyle(fontWeight: FontWeight.w500)),
            value: _promotions,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _promotions = v);
              _savePrefs();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _LanguageSelectionSheet extends StatelessWidget {
  const _LanguageSelectionSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseLanguage,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.selectLanguage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
                child: Column(
                  children: LocaleProvider.supportedLanguages.map((lang) {
                    final isSelected = lang.code == currentLocale;
                    return ListTile(
                      onTap: () {
                        localeProvider.setLocale(lang.code);
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          shape: BoxShape.circle,
                          border: isSelected ? null : Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            lang.code.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(lang.name),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
