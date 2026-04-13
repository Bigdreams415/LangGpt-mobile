import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../presentation/providers/auth_provider.dart';

// Shared data model passed between signup steps
class SignupData {
  String fullName;
  String username;
  String email;
  String password;
  String? dateOfBirth;
  String? country;
  String? selectedLanguage;
  String? selectedLevel;

  SignupData({
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.dateOfBirth,
    this.country,
    this.selectedLanguage,
    this.selectedLevel,
  });
}

class SignupStep1Screen extends ConsumerStatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  ConsumerState<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends ConsumerState<SignupStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).googleSignIn();
    final authState = ref.read(authProvider);
    if (!mounted) return;
    if (authState.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    final data = SignupData(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );
    Navigator.pushNamed(context, AppRoutes.signupStep2, arguments: data);
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

              // ── Top bar ──────────────────────────────────────────────────
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  const Expanded(
                      child: _StepIndicator(currentStep: 1, totalSteps: 3)),
                ],
              ),
              const SizedBox(height: 36),

              // ── Header ───────────────────────────────────────────────────
              const Text(
                'Create your\naccount',
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Step 1 of 3 — Tell us a bit about yourself.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),

              // ── Google Button ─────────────────────────────────────────────
              _GoogleSignInButton(onTap: _handleGoogleSignIn),
              const SizedBox(height: 24),
              _OrDivider(),
              const SizedBox(height: 24),

              // ── Form ──────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: AppStrings.fullName,
                      hint: 'e.g. Chukwuemeka Obi',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (v.trim().length < 2) return 'Name is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.username,
                      hint: 'e.g. chukwuemeka_99',
                      controller: _usernameController,
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (v.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        if (v.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                          return 'Only letters, numbers, and underscores allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: AppStrings.email,
                      hint: 'e.g. you@example.com',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Next Button ───────────────────────────────────────────────
              AppButton(
                label: 'Continue',
                onPressed: _handleNext,
                suffixIcon: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(height: 24),

              // ── Login link ────────────────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    text: AppStrings.alreadyHaveAccount,
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: AppStrings.login,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(100),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleSignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.continueWithGoogle,
              style: AppTextStyles.buttonLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:
              Text(AppStrings.orContinueWith, style: AppTextStyles.labelMedium),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}
