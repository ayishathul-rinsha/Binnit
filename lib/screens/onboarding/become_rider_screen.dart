import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';

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

  // Step 1: Phone
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _phoneVerified = false;

  // Step 2: Personal details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Step 3: Work details
  String _vehicleType = 'two_wheeler';
  final _experienceController = TextEditingController();
  bool _hasLicense = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
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

  Future<void> _sendOtp() async {
    if (_phoneController.text.length < 10) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _otpSent = true;
      _isLoading = false;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 4) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _phoneVerified = true;
      _isLoading = false;
    });
    _nextStep();
  }

  Future<void> _submitApplication() async {
    if (!_termsAccepted) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    await onboardingProvider.setRiderRegistered();
    await onboardingProvider.completeOnboarding();

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.registrationComplete);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Become a Rider',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildProgressBar(),
          ),

          // Steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPhoneStep(),
                _buildPersonalStep(),
                _buildWorkStep(),
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
          final isComplete = index < _currentStep;

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

  Widget _buildPhoneStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your phone number to get started',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Phone field
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter 10-digit number',
            prefix: '+91 ',
            keyboardType: TextInputType.phone,
            enabled: !_otpSent,
          ),

          if (_otpSent) ...[
            const SizedBox(height: 24),

            // OTP field
            _buildTextField(
              controller: _otpController,
              label: 'OTP Code',
              hint: 'Enter 6-digit OTP',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: _sendOtp,
              child: Text(
                'Resend OTP',
                style: TextStyle(color: AppColors.primaryLight),
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
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
                  : Text(
                      _otpSent ? 'Verify OTP' : 'Send OTP',
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

  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your address',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
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
              child: const Text(
                'Continue',
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

  Widget _buildWorkStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your work preferences',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Vehicle type
          const Text(
            'Vehicle Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildVehicleOption(
                  'two_wheeler', 'Two Wheeler', Icons.two_wheeler),
              const SizedBox(width: 12),
              _buildVehicleOption(
                  'three_wheeler', 'Three Wheeler', Icons.electric_rickshaw),
              const SizedBox(width: 12),
              _buildVehicleOption('truck', 'Truck', Icons.local_shipping),
            ],
          ),

          const SizedBox(height: 24),

          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            hint: 'e.g., 2 years',
          ),

          const SizedBox(height: 24),

          // License checkbox
          CheckboxListTile(
            value: _hasLicense,
            onChanged: (value) {
              setState(() => _hasLicense = value ?? false);
            },
            title: const Text(
              'I have a valid driving license',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),

          // Terms checkbox
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() => _termsAccepted = value ?? false);
            },
            title: const Text(
              'I agree to the Terms & Conditions',
              style: TextStyle(fontSize: 14),
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
                  : const Text(
                      'Submit Application',
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
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
