import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/collector_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';

/// Become a Rider registration screen - Makeover
class BecomeRiderScreen extends StatefulWidget {
  const BecomeRiderScreen({super.key});

  @override
  State<BecomeRiderScreen> createState() => _BecomeRiderScreenState();
}

class _BecomeRiderScreenState extends State<BecomeRiderScreen> {
  bool _isLoading = false;

  // Step 1: Email + Password
  final _emailRegController = TextEditingController();
  final _passwordRegController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailRegFocus = FocusNode();
  final _passwordRegFocus = FocusNode();
  final _phoneFocus = FocusNode();
  bool _obscureRegPassword = true;

  // Step 2: Personal details
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCity;
  final _nameFocus = FocusNode();
  final _addressFocus = FocusNode();

  // Indian cities list (alphabetically sorted)
  static const List<String> _indianCities = [
    'Agra', 'Ahmedabad', 'Ajmer', 'Akola', 'Aligarh', 'Allahabad', 'Ambattur',
    'Amravati', 'Amritsar', 'Asansol', 'Aurangabad', 'Bangalore', 'Bareilly',
    'Belgaum', 'Bhavnagar', 'Bhilai', 'Bhiwandi', 'Bhopal', 'Bhubaneswar',
    'Bikaner', 'Chandigarh', 'Chennai', 'Coimbatore', 'Cuttack', 'Dehradun',
    'Delhi', 'Dhanbad', 'Durgapur', 'Erode', 'Faridabad', 'Firozabad', 'Gaya',
    'Ghaziabad', 'Gorakhpur', 'Gulbarga', 'Guntur', 'Guwahati', 'Gwalior',
    'Howrah', 'Hubli', 'Hyderabad', 'Indore', 'Jabalpur', 'Jaipur', 'Jalandhar',
    'Jammu', 'Jamnagar', 'Jamshedpur', 'Jhansi', 'Jodhpur', 'Kanpur', 'Kochi',
    'Kolhapur', 'Kolkata', 'Kota', 'Kozhikode', 'Kurnool', 'Loni', 'Lucknow',
    'Ludhiana', 'Madurai', 'Malegaon', 'Mangalore', 'Meerut', 'Moradabad',
    'Mumbai', 'Mysore', 'Nagpur', 'Nanded', 'Nashik', 'Nellore', 'Noida',
    'Patna', 'Pune', 'Raipur', 'Rajahmundry', 'Rajkot', 'Ranchi', 'Rourkela',
    'Saharanpur', 'Salem', 'Sangli', 'Siliguri', 'Solapur', 'Srinagar', 'Thane',
    'Thiruvananthapuram', 'Thrissur', 'Tiruchirappalli', 'Tirunelveli',
    'Tiruppur', 'Udaipur', 'Ujjain', 'Ulhasnagar', 'Vadodara', 'Varanasi',
    'Vijayawada', 'Visakhapatnam', 'Warangal',
  ];

  // Step 3: Work details
  String _vehicleType = 'two_wheeler';
  final _experienceController = TextEditingController();
  final _experienceFocus = FocusNode();
  bool _hasLicense = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailRegController.dispose();
    _passwordRegController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _emailRegFocus.dispose();
    _passwordRegFocus.dispose();
    _phoneFocus.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _experienceFocus.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    final email = _emailRegController.text.trim();
    final password = _passwordRegController.text.trim();
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final city = _selectedCity;
    final experience = _experienceController.text.trim();

    if (email.isEmpty || !email.contains('@') || password.length < 6 || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid email, password, and phone number.'), backgroundColor: Colors.red));
      return;
    }

    if (name.isEmpty || address.isEmpty || city == null || experience.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all personal and work details.'), backgroundColor: Colors.red));
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to the Terms & Conditions.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create account
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) throw Exception('Failed to create account');

      await user.updateDisplayName(name);

      final collector = Collector(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        isOnline: false,
        rating: 0.0,
        totalPickups: 0,
        totalHoursToday: 0,
        address: address,
        city: city,
        experience: experience,
        hasLicense: _hasLicense,
        vehicle: VehicleDetails(
          id: 'vehicle_',
          vehicleType: _vehicleType,
          vehicleNumber: '',
        ),
      );

      final profileData = {
        ...collector.toJson(),
        'status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('collectors').doc(user.uid).set(profileData);

      if (mounted) {
        final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
        authProvider.updateCollector(collector);

        final collectorProvider = Provider.of<CollectorProvider>(context, listen: false);
        collectorProvider.setCollector(collector);

        final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
        await onboardingProvider.setRiderRegistered();
        await onboardingProvider.completeOnboarding();

        Navigator.pushReplacementNamed(context, Routes.registrationComplete);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error creating account'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error creating account'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHero(l10n),
            Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusXL),
                  boxShadow: AppDimens.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmailSection(l10n),
                    const SizedBox(height: 48),
                    _buildPersonalSection(l10n),
                    const SizedBox(height: 48),
                    _buildWorkSection(l10n),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (_termsAccepted && !_isLoading) ? _submitApplication : null,
                        child: _isLoading
                            ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
                            : Text(l10n.submitApplication),
                      ),
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

  Widget _buildHero(AppLocalizations l10n) {
    return ClipRRect(
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
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.becomeRider,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
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
    );
  }

  Widget _buildEmailSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Account Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _emailRegController,
          label: l10n.emailAddress,
          hint: 'your@email.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          focusNode: _emailRegFocus,
          nextFocus: _passwordRegFocus,
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.password,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordRegController,
              obscureText: _obscureRegPassword,
              focusNode: _passwordRegFocus,
              onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
              decoration: InputDecoration(
                hintText: 'At least 6 characters',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() => _obscureRegPassword = !_obscureRegPassword);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: l10n.phoneNumber,
          hint: '10-digit number',
          icon: Icons.phone_rounded,
          prefix: '+91 ',
          keyboardType: TextInputType.phone,
          focusNode: _phoneFocus,
          nextFocus: _nameFocus,
        ),
      ],
    );
  }

  Widget _buildPersonalSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. ${l10n.personalDetails}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: l10n.fullName,
          hint: l10n.fullName,
          icon: Icons.person_rounded,
          focusNode: _nameFocus,
          nextFocus: _addressFocus,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: l10n.address,
          hint: l10n.address,
          icon: Icons.home_rounded,
          maxLines: 2,
          focusNode: _addressFocus,
          onSubmit: () => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.city,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                hintText: 'Select your city',
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              isExpanded: true,
              menuMaxHeight: 300,
              items: _indianCities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCity = value);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. ${l10n.workDetails}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.vehicleType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildVehicleOption('two_wheeler', l10n.twoWheeler, Icons.two_wheeler_rounded),
            const SizedBox(width: 12),
            _buildVehicleOption('three_wheeler', l10n.threeWheeler, Icons.electric_rickshaw_rounded),
            const SizedBox(width: 12),
            _buildVehicleOption('truck', l10n.truck, Icons.local_shipping_rounded),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _experienceController,
          label: l10n.experience,
          hint: 'e.g., 2',
          icon: Icons.work_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        CheckboxListTile(
          value: _hasLicense,
          onChanged: (value) {
            setState(() => _hasLicense = value ?? false);
          },
          title: Text(
            l10n.hasLicense,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
        CheckboxListTile(
          value: _termsAccepted,
          onChanged: (value) {
            setState(() => _termsAccepted = value ?? false);
          },
          title: Text(
            l10n.agreeTerms,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildVehicleOption(String value, String label, IconData icon) {
    final isSelected = _vehicleType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vehicleType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppDimens.softShadow : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    VoidCallback? onSubmit,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction: textInputAction ??
              (nextFocus != null
                  ? TextInputAction.next
                  : onSubmit != null
                      ? TextInputAction.done
                      : TextInputAction.next),
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              nextFocus.requestFocus();
            } else if (onSubmit != null) {
              onSubmit();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
