import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collector_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/widgets.dart';

/// Edit profile screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final collector = Provider.of<CollectorProvider>(
      context,
      listen: false,
    ).collector;
    _nameController = TextEditingController(text: collector?.name ?? '');
    _phoneController = TextEditingController(text: collector?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<CollectorProvider>(context, listen: false);
    final success = await provider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingM),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      Consumer<CollectorProvider>(
                        builder: (context, provider, child) {
                          final collector = provider.collector;
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              (collector?.name ?? 'U')[0].toUpperCase(),
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Photo picker
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingXL),

                // Name field
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: ValidationHelper.validateName,
                ),
                const SizedBox(height: AppDimens.paddingM),

                // Phone field
                CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: ValidationHelper.validatePhone,
                ),
                const SizedBox(height: AppDimens.paddingM),

                // Email (read-only)
                Consumer<CollectorProvider>(
                  builder: (context, provider, child) {
                    return CustomTextField(
                      label: 'Email',
                      hint: provider.collector?.email ?? '',
                      enabled: false,
                      prefixIcon: const Icon(Icons.email_outlined),
                    );
                  },
                ),
                const SizedBox(height: AppDimens.paddingXL),

                // Save button
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
