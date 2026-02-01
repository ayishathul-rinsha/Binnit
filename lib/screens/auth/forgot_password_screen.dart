import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Forgot password screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
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
                child: _emailSent
                    ? _buildSuccessState()
                    : _buildForm(authProvider),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 50,
                color: AppColors.warning,
              ),
            ),
          ),

          const SizedBox(height: AppDimens.paddingL),

          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            "Don't worry! Enter your email and we'll send you a link to reset your password.",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimens.paddingXL),

          // Email field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your registered email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: ValidationHelper.validateEmail,
            onSubmitted: (_) => _handleForgotPassword(),
          ),

          const SizedBox(height: AppDimens.paddingL),

          // Submit button
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _handleForgotPassword,
            isLoading: authProvider.isLoading,
          ),

          const SizedBox(height: AppDimens.paddingL),

          // Back to login
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimens.paddingXL),

        // Success icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 60,
              color: AppColors.success,
            ),
          ),
        ),

        const SizedBox(height: AppDimens.paddingL),

        // Success message
        Text(
          'Email Sent!',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingS),
        Text(
          'We have sent a password reset link to:',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingS),
        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimens.paddingXL),

        // Instructions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingM),
            child: Column(
              children: [
                _buildInstructionItem('1', 'Check your email inbox'),
                const Divider(),
                _buildInstructionItem('2', 'Click on the reset link'),
                const Divider(),
                _buildInstructionItem('3', 'Create a new password'),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimens.paddingXL),

        // Back to login button
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        const SizedBox(height: AppDimens.paddingM),

        // Resend email
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
              });
            },
            child: const Text("Didn't receive the email? Resend"),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
