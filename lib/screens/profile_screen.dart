import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../main.dart' show languageService;
import 'login_screen.dart';
import 'manage_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isEditing = false;
  bool _isSaving = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(languageService.t('logout'), style: AppTheme.headingSmall),
        content: Text(
          languageService.t('logout_confirm'),
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(languageService.t('cancel'),
                style: const TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(languageService.t('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> userData) async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await _authService.updateUserData({
        'fullName': _nameController.text.trim(),
      });
      await _authService.currentUser
          ?.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageService.t('profile_updated')),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestoreService.getUserProfileStream(),
            builder: (context, snapshot) {
              final userData =
                  snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final fullName =
                  userData['fullName'] ?? _authService.currentUser?.displayName ?? 'User';
              final email =
                  userData['email'] ?? _authService.currentUser?.email ?? '';
              final plan = userData['subscriptionPlan'] ?? 'Free';
              final ecoPoints = (userData['ecoPoints'] as num?)?.toInt() ?? 0;
              final totalWaste = (userData['totalWasteRecycled'] as num?)?.toDouble() ?? 0.0;
              final co2Saved = (userData['co2Saved'] as num?)?.toDouble() ?? 0.0;
              final totalPickups = (userData['totalPickups'] as num?)?.toInt() ?? 0;
              final createdAt = userData['createdAt'] as Timestamp?;
              final profileImage = userData['profileImageUrl'] ?? '';

              if (!_isEditing) {
                _nameController.text = fullName;
              }

              return Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildProfileHeader(
                              fullName, email, plan, profileImage),
                          const SizedBox(height: 24),
                          _buildProfileDetails(
                              fullName, email, plan, createdAt, userData),
                          const SizedBox(height: 20),
                          _buildEcoStats(
                              ecoPoints, totalWaste, co2Saved, totalPickups),
                          const SizedBox(height: 20),
                          _buildSubscriptionCard(plan),
                          const SizedBox(height: 20),
                          _buildSettingsSection(),
                          const SizedBox(height: 20),
                          _buildLogoutButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              languageService.t('profile'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (!_isEditing)
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 20, color: AppTheme.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      String name, String email, String plan, String profileImage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 3,
                ),
              ),
              child: profileImage.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPlanIcon(plan),
                    color: const Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$plan Plan',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  IconData _getPlanIcon(String plan) {
    switch (plan) {
      case 'Pro':
        return Icons.workspace_premium_rounded;
      case 'Premium':
        return Icons.diamond_rounded;
      case 'Basic':
        return Icons.eco_rounded;
      default:
        return Icons.eco_outlined;
    }
  }

  Widget _buildProfileDetails(String name, String email, String plan,
      Timestamp? createdAt, Map<String, dynamic> userData) {
    final joinDate = createdAt != null
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account Details', style: AppTheme.headingSmall),
            const SizedBox(height: 16),

            // Name field (editable)
            if (_isEditing) ...[
              TextFormField(
                controller: _nameController,
                style: AppTheme.bodyLarge,
                decoration: AppTheme.inputDecoration(
                  hintText: languageService.t('full_name'),
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _isEditing = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textLight,
                        side: const BorderSide(color: AppTheme.dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(languageService.t('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isSaving ? null : () => _saveProfile(userData),
                      style: AppTheme.primaryButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            _profileDetailRow(
                Icons.person_outline_rounded, 'Name', name),
            _profileDetailRow(
                Icons.email_outlined, 'Email', email),
            _profileDetailRow(
                Icons.card_membership_rounded, 'Plan', plan),
            _profileDetailRow(
                Icons.calendar_today_rounded, 'Member Since', joinDate),
            if (_authService.currentUser != null)
              _profileDetailRow(
                Icons.verified_user_outlined,
                'Email Verified',
                _authService.isEmailVerified ? 'Yes ✓' : 'No',
              ),
          ],
        ),
      ),
    );
  }

  Widget _profileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoStats(
      int ecoPoints, double totalWaste, double co2Saved, int totalPickups) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eco Impact', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                _ecoStatCard('$ecoPoints', 'Eco Points', Icons.star_rounded,
                    const Color(0xFFFF9800)),
                const SizedBox(width: 12),
                _ecoStatCard(
                    '${totalWaste.toStringAsFixed(1)} Kg',
                    'Recycled',
                    Icons.recycling_rounded,
                    const Color(0xFF4CAF50)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ecoStatCard(
                    '${co2Saved.toStringAsFixed(1)} Kg',
                    'CO₂ Saved',
                    Icons.cloud_done_rounded,
                    const Color(0xFF2196F3)),
                const SizedBox(width: 12),
                _ecoStatCard('$totalPickups', 'Pickups',
                    Icons.local_shipping_rounded, const Color(0xFF9C27B0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ecoStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
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

  Widget _buildSubscriptionCard(String plan) {
    final isPro = plan == 'Pro' || plan == 'Premium';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPro
              ? const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPro ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isPro
                  ? const Color(0xFF7B1FA2).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPro
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getPlanIcon(plan),
                color: isPro ? Colors.white : AppTheme.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro
                        ? '$plan Plan Active'
                        : languageService.t('upgrade_eco_pro'),
                    style: TextStyle(
                      color: isPro ? Colors.white : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPro
                        ? 'Enjoy unlimited pickups & priority features'
                        : languageService.t('unlimited_pickups'),
                    style: TextStyle(
                      color: isPro
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPro)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textLight, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _settingsTile(
              Icons.language_rounded,
              languageService.t('language'),
              languageService.currentLanguage.nativeName,
              const Color(0xFF2196F3),
              () {}, // Navigate to language settings
            ),
            _settingsDivider(),
            _settingsTile(
              Icons.notifications_outlined,
              languageService.t('notifications'),
              'Enabled',
              const Color(0xFFFF9800),
              () {},
            ),
            _settingsDivider(),
            _settingsTile(
              Icons.location_on_outlined,
              'Manage Addresses',
              'Saved Locations',
              AppTheme.primaryGreen,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageAddressesScreen()),
                );
              },
            ),
            _settingsDivider(),
            _settingsTile(
              Icons.help_outline_rounded,
              'Help & Support',
              '',
              const Color(0xFF4CAF50),
              () {},
            ),
            _settingsDivider(),
            _settingsTile(
              Icons.info_outline_rounded,
              'About',
              'v1.0.0',
              const Color(0xFF9C27B0),
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppTheme.textLight),
        ],
      ),
    );
  }

  Widget _settingsDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: AppTheme.dividerColor.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _handleLogout,
          icon:
              const Icon(Icons.logout_rounded, size: 20, color: AppTheme.errorColor),
          label: Text(
            languageService.t('logout'),
            style: const TextStyle(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
