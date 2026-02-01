import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Login screen - Warm, welcoming, balanced design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final collectorProvider = Provider.of<CollectorProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      if (authProvider.collector != null) {
        collectorProvider.setCollector(authProvider.collector!);
      }
      Navigator.pushReplacementNamed(context, Routes.main);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Unable to sign in'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),

                      // Header with logo
                      _buildHeader(),

                      const SizedBox(height: 48),

                      // Welcome section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to continue making a difference',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email address',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationHelper.validateEmail,
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        validator: ValidationHelper.validatePassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.forgotPassword);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.primary.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'New here?',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.signup);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Collector',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                icon,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.secondary.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}
