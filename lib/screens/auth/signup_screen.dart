import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Signup screen — name + phone → send OTP
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phone = _phoneController.text.trim();

    final result = await authProvider.sendOtp(phone: phone);

    if (result['success'] == true && mounted) {
      // Navigate to OTP verification, passing phone number
      Navigator.pushNamed(
        context,
        Routes.otpVerification,
        arguments: {'phone': phone},
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppDimens.paddingS),
                      Text(
                        'Join our network of waste collectors',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),

                      const SizedBox(height: AppDimens.paddingXL),

                      // Name field
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        focusNode: _nameFocus,
                        nextFocus: _phoneFocus,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: ValidationHelper.validateName,
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Phone field
                      CustomTextField(
                        label: 'Phone Number',
                        hint: '9876543210',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        focusNode: _phoneFocus,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: ValidationHelper.validatePhone,
                      ),

                      const SizedBox(height: AppDimens.paddingXL),

                      // Signup button — sends OTP
                      CustomButton(
                        text: 'Continue with OTP',
                        onPressed: _handleSignup,
                        isLoading: authProvider.isLoading,
                      ),

                      const SizedBox(height: AppDimens.paddingL),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
