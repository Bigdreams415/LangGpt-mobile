import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Warning icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Delete your account?',
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'This action is permanent and cannot be undone. '
              'All your data, progress, and achievements will be permanently deleted.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Consequences list
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
              ),
              child: Column(
                children: [
                  _ConsequenceItem(
                    icon: Icons.close_rounded,
                    text: 'Your account will be permanently removed',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _ConsequenceItem(
                    icon: Icons.close_rounded,
                    text: 'All learning progress and XP will be lost',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _ConsequenceItem(
                    icon: Icons.close_rounded,
                    text: 'Your streak and achievements will be erased',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _ConsequenceItem(
                    icon: Icons.close_rounded,
                    text: 'This action cannot be reversed',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Delete button
            AppButton(
              label: 'Delete My Account',
              variant: AppButtonVariant.danger,
              onPressed: () => _showConfirmDialog(context),
            ),
            const SizedBox(height: 12),

            // Cancel button
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'This will immediately and permanently delete your account. '
          'You will not be able to recover any of your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: implement actual account deletion API call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion will be implemented soon.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _ConsequenceItem({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.secondarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 14,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
