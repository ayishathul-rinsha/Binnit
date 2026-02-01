import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Signup screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectorProvider = Provider.of<CollectorProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Set collector data
      if (authProvider.collector != null) {
        collectorProvider.setCollector(authProvider.collector!);
      }
      Navigator.pushReplacementNamed(context, Routes.main);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Signup failed'),
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
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: ValidationHelper.validateName,
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Email field
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: ValidationHelper.validateEmail,
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Phone field
                      CustomTextField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: ValidationHelper.validatePhone,
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Create a password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: ValidationHelper.validatePassword,
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Confirm Password field
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) =>
                            ValidationHelper.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),

                      const SizedBox(height: AppDimens.paddingM),

                      // Terms checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptedTerms = !_acceptedTerms;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimens.paddingL),

                      // Signup button
                      CustomButton(
                        text: 'Create Account',
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
