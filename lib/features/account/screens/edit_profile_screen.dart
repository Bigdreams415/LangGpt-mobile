import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _countryController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);

    // Only send fields that actually changed.
    final newFullName = _fullNameController.text.trim();
    final newUsername = _usernameController.text.trim();
    final newCountry = _countryController.text.trim();

    final fullNameChanged = newFullName != (user?.fullName ?? '');
    final usernameChanged = newUsername != (user?.username ?? '');
    final countryChanged = newCountry != (user?.country ?? '');

    if (!fullNameChanged && !usernameChanged && !countryChanged) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);

    final error = await ref.read(authProvider.notifier).updateProfile(
          fullName: fullNameChanged ? newFullName : null,
          username: usernameChanged ? newUsername : null,
          country: countryChanged ? newCountry : null,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: AppTextStyles.headlineMedium),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _FieldLabel('Full name'),
              const SizedBox(height: 8),
              _ProfileField(
                controller: _fullNameController,
                hint: 'Your full name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Username'),
              const SizedBox(height: 8),
              _ProfileField(
                controller: _usernameController,
                hint: 'your_username',
                prefix: '@',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username cannot be empty';
                  if (v.trim().length < 3) return 'At least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Country'),
              const SizedBox(height: 8),
              _ProfileField(
                controller: _countryController,
                hint: 'e.g. Nigeria',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelMedium);
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.prefix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        prefixStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
    );
  }
}
