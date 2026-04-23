import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'signup_step1_screen.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedCountry;

  final List<String> _countries = [
    'Nigeria', 'Ghana', 'United Kingdom', 'United States',
    'Canada', 'South Africa', 'Kenya', 'Other',
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    final data = ModalRoute.of(context)!.settings.arguments as SignupData;
    data.password = _passwordController.text;
    data.dateOfBirth = _dobController.text;
    data.country = _selectedCountry;
    Navigator.pushNamed(context, AppRoutes.signupStep3, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Top bar 
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  const Expanded(child: _StepIndicator(currentStep: 2, totalSteps: 3)),
                ],
              ),
              const SizedBox(height: 36),

              // Header
              const Text('Secure your\naccount', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              const Text(
                'Step 2 of 3 — Set your password and location.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: AppStrings.password,
                      hint: 'Create a strong password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 8) return 'Password must be at least 8 characters';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) {
                          return 'Include at least one uppercase letter';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(v)) {
                          return 'Include at least one number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _PasswordStrengthIndicator(password: _passwordController.text),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.confirmPassword,
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.dateOfBirth,
                      hint: 'DD/MM/YYYY',
                      controller: _dobController,
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Date of birth is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.country,
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCountry,
                          hint: Text('Select your country', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.public_outlined, size: 20, color: AppColors.textHint),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider, width: 1.5)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider, width: 1.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCountry = v),
                          validator: (v) => v == null ? 'Please select your country' : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Continue',
                onPressed: _handleNext,
                suffixIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Password Strength Widget 

class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const _PasswordStrengthIndicator({required this.password});

  int get _strength {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  String get _label {
    final s = _strength;
    if (s <= 1) return 'Weak';
    if (s <= 3) return 'Fair';
    if (s == 4) return 'Good';
    return 'Strong';
  }

  Color get _color {
    final s = _strength;
    if (s <= 1) return AppColors.error;
    if (s <= 3) return AppColors.accentYellow;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _strength / 5,
              backgroundColor: AppColors.divider,
              color: _color,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _label,
          style: AppTextStyles.labelSmall.copyWith(color: _color),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        );
      }),
    );
  }
}