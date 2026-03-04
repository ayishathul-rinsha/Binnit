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

/// Become a Rider registration screen
class BecomeRiderScreen extends StatefulWidget {
  const BecomeRiderScreen({super.key});

  @override
  State<BecomeRiderScreen> createState() => _BecomeRiderScreenState();
}

class _BecomeRiderScreenState extends State<BecomeRiderScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
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
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCity;
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();

  // Indian cities list (alphabetically sorted)
  static const List<String> _indianCities = [
    'Agra',
    'Ahmedabad',
    'Ajmer',
    'Akola',
    'Aligarh',
    'Allahabad',
    'Ambattur',
    'Amravati',
    'Amritsar',
    'Asansol',
    'Aurangabad',
    'Bangalore',
    'Bareilly',
    'Belgaum',
    'Bhavnagar',
    'Bhilai',
    'Bhiwandi',
    'Bhopal',
    'Bhubaneswar',
    'Bikaner',
    'Chandigarh',
    'Chennai',
    'Coimbatore',
    'Cuttack',
    'Dehradun',
    'Delhi',
    'Dhanbad',
    'Durgapur',
    'Erode',
    'Faridabad',
    'Firozabad',
    'Gaya',
    'Ghaziabad',
    'Gorakhpur',
    'Gulbarga',
    'Guntur',
    'Guwahati',
    'Gwalior',
    'Howrah',
    'Hubli',
    'Hyderabad',
    'Indore',
    'Jabalpur',
    'Jaipur',
    'Jalandhar',
    'Jammu',
    'Jamnagar',
    'Jamshedpur',
    'Jhansi',
    'Jodhpur',
    'Kanpur',
    'Kochi',
    'Kolhapur',
    'Kolkata',
    'Kota',
    'Kozhikode',
    'Kurnool',
    'Loni',
    'Lucknow',
    'Ludhiana',
    'Madurai',
    'Malegaon',
    'Mangalore',
    'Meerut',
    'Moradabad',
    'Mumbai',
    'Mysore',
    'Nagpur',
    'Nanded',
    'Nashik',
    'Nellore',
    'Noida',
    'Patna',
    'Pune',
    'Raipur',
    'Rajahmundry',
    'Rajkot',
    'Ranchi',
    'Rourkela',
    'Saharanpur',
    'Salem',
    'Sangli',
    'Siliguri',
    'Solapur',
    'Srinagar',
    'Thane',
    'Thiruvananthapuram',
    'Thrissur',
    'Tiruchirappalli',
    'Tirunelveli',
    'Tiruppur',
    'Udaipur',
    'Ujjain',
    'Ulhasnagar',
    'Vadodara',
    'Varanasi',
    'Vijayawada',
    'Visakhapatnam',
    'Warangal',
  ];

  // Step 3: Work details
  String _vehicleType = 'two_wheeler';
  final _experienceController = TextEditingController();
  final _experienceFocus = FocusNode();
  bool _hasLicense = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailRegController.dispose();
    _passwordRegController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _emailRegFocus.dispose();
    _passwordRegFocus.dispose();
    _phoneFocus.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _experienceFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleEmailSignup() async {
    final email = _emailRegController.text.trim();
    final password = _passwordRegController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (phone.length < 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid phone number'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create account with email + password
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Verification email sent.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Pre-fill email in step 2
        _emailController.text = email;
        _nextStep();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'This email is already registered. Please login instead.';
            break;
          case 'invalid-email':
            message = 'Invalid email address.';
            break;
          case 'weak-password':
            message = 'Password is too weak. Use at least 6 characters.';
            break;
          default:
            message = 'Error: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_termsAccepted) return;

    setState(() => _isLoading = true);

    try {
      // Phone should already be verified and user signed in via Firebase Phone Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
            'Phone not verified. Please go back and verify your phone number.');
      }

      // Update display name
      await user.updateDisplayName(_nameController.text.trim());

      // Build collector profile with all form data
      final collector = Collector(
        id: user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isOnline: false,
        rating: 0.0,
        totalPickups: 0,
        totalHoursToday: 0,
        vehicle: VehicleDetails(
          id: 'vehicle_${user.uid}',
          vehicleType: _vehicleType,
          vehicleNumber: '',
        ),
      );

      // Save full profile to Firestore 'users' collection
      final profileData = {
        ...collector.toJson(),
        'address': _addressController.text.trim(),
        'city': _selectedCity ?? '',
        'experience': _experienceController.text.trim(),
        'has_license': _hasLicense,
        'role': 'collector',
        'status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileData);

      // Update providers so the app recognizes the logged-in user
      if (mounted) {
        final authProvider = Provider.of<app_auth.AuthProvider>(
          context,
          listen: false,
        );
        authProvider.updateCollector(collector);

        final collectorProvider = Provider.of<CollectorProvider>(
          context,
          listen: false,
        );
        collectorProvider.setCollector(collector);
      }

      // Mark onboarding as complete
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );
      await onboardingProvider.setRiderRegistered();
      await onboardingProvider.completeOnboarding();

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.registrationComplete);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
                color: AppColors.textPrimary,
              )
            : null,
        title: Text(
          l10n.becomeRider,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildProgressBar(),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEmailStep(l10n),
                _buildPersonalStep(l10n),
                _buildWorkStep(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your details to get started',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _emailRegController,
            label: l10n.emailAddress,
            hint: 'your@email.com',
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordRegController,
                obscureText: _obscureRegPassword,
                focusNode: _passwordRegFocus,
                onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  hintStyle:
                      TextStyle(color: AppColors.textLight, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(
                          () => _obscureRegPassword = !_obscureRegPassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
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
            prefix: '+91 ',
            keyboardType: TextInputType.phone,
            focusNode: _phoneFocus,
            onSubmit: _handleEmailSignup,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Account & Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalDetails,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tellAboutYou,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _nameController,
            label: l10n.fullName,
            hint: l10n.fullName,
            focusNode: _nameFocus,
            nextFocus: _emailFocus,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            label: l10n.emailAddress,
            hint: l10n.email,
            keyboardType: TextInputType.emailAddress,
            focusNode: _emailFocus,
            nextFocus: _addressFocus,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _addressController,
            label: l10n.address,
            hint: l10n.address,
            maxLines: 2,
            focusNode: _addressFocus,
            onSubmit: () => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          // City dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.city,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  hintText: 'Select your city',
                  hintStyle: TextStyle(color: AppColors.textLight),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
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
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.continueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workDetails,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.workPreferences,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.vehicleType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildVehicleOption(
                  'two_wheeler', l10n.twoWheeler, Icons.two_wheeler),
              const SizedBox(width: 12),
              _buildVehicleOption(
                  'three_wheeler', l10n.threeWheeler, Icons.electric_rickshaw),
              const SizedBox(width: 12),
              _buildVehicleOption('truck', l10n.truck, Icons.local_shipping),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _experienceController,
            label: l10n.experience,
            hint: 'e.g., 2',
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _hasLicense,
            onChanged: (value) {
              setState(() => _hasLicense = value ?? false);
            },
            title: Text(
              l10n.hasLicense,
              style: const TextStyle(fontSize: 14),
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
              style: const TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed:
                  (_termsAccepted && !_isLoading) ? _submitApplication : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabled,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.submitApplication,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOption(String value, String label, IconData icon) {
    final isSelected = _vehicleType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vehicleType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
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
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
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
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.accent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
