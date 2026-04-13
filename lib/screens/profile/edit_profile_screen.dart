import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/collector_provider.dart';
import '../../services/firestore_service.dart';
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
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _experienceController;
  bool _isLoading = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final collector = Provider.of<CollectorProvider>(
      context,
      listen: false,
    ).collector;
    _nameController = TextEditingController(text: collector?.name ?? '');
    _phoneController = TextEditingController(text: collector?.phone ?? '');
    _addressController = TextEditingController(text: collector?.address ?? '');
    _cityController = TextEditingController(text: collector?.city ?? '');
    _experienceController = TextEditingController(text: collector?.experience ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<CollectorProvider>(context, listen: false);
    String? photoUrl;

    try {
      if (_selectedImage != null) {
        final collectorId = provider.collector?.id ?? 'unknown';
        final extension = _selectedImage!.path.split('.').last.toLowerCase();
        final bytes = await _selectedImage!.readAsBytes();

        photoUrl = await FirestoreService.uploadImageBytes(
            bytes, 'profile_$collectorId', extension);
      }

      final success = await provider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: photoUrl ?? provider.collector?.photoUrl,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        experience: _experienceController.text.trim(),
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
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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
                          final hasNetworkImage =
                              (collector?.photoUrl ?? '').isNotEmpty;

                          // 1. Show newly picked image via MemoryBytes (Safe for Web + Mobile)
                          if (_selectedImage != null) {
                            return FutureBuilder<Uint8List>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundImage:
                                        MemoryImage(snapshot.data!),
                                  );
                                }
                                return const CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey,
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          }

                          // 2. Fallback to existing network image
                          if (hasNetworkImage) {
                            return CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(collector!.photoUrl),
                            );
                          }

                          // 3. Fallback to Initial Letter
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              (collector?.name ?? 'U')[0].toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
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
                            onPressed: () async {
                              try {
                                final pickedFile = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70, // Compress slightly
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    _selectedImage = pickedFile;
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to pick image: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
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

                // Address field
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: AppDimens.paddingM),

                // City field
                CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
                const SizedBox(height: AppDimens.paddingM),

                // Experience field
                CustomTextField(
                  label: 'Experience (Years)',
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.work_outline),
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
