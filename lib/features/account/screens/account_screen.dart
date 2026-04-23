import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Center(
                        child: Text('CO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Chukwuemeka Obi', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
                    Text('@chukwuemeka_99', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const _ProfileStat('7', '🔥 Streak'),
                        _VerticalDivider(),
                        const _ProfileStat('340', '⚡ XP'),
                        _VerticalDivider(),
                        const _ProfileStat('12', '📚 Lessons'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Language progress
              const _SectionHeader('My language'),
              const SizedBox(height: 12),
              _LanguageProgressCard(),
              const SizedBox(height: 24),

              // Settings
              const _SectionHeader('Settings'),
              const SizedBox(height: 12),
              _SettingsGroup(items: [
                const _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', color: AppColors.primarySurface, iconColor: AppColors.primary),
                const _SettingsItem(icon: Icons.language_outlined, label: 'App language', color: AppColors.accentBlueSurface, iconColor: AppColors.accentBlue),
                _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Dark mode', color: AppColors.surfaceVariant, iconColor: AppColors.textSecondary, trailing: Switch(value: false, onChanged: (_) {}, activeThumbColor: AppColors.primary)),
              ]),
              const SizedBox(height: 16),
              const _SettingsGroup(items: [
                _SettingsItem(icon: Icons.help_outline_rounded, label: 'Help & Support', color: AppColors.accentYellowSurface, iconColor: Color(0xFFB8860B)),
                _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', color: AppColors.surfaceVariant, iconColor: AppColors.textSecondary),
                _SettingsItem(icon: Icons.info_outline_rounded, label: 'About NaijaLingo', color: AppColors.surfaceVariant, iconColor: AppColors.textSecondary),
              ]),
              const SizedBox(height: 16),
              const _SettingsGroup(items: [
                _SettingsItem(icon: Icons.logout_rounded, label: 'Log out', color: AppColors.secondarySurface, iconColor: AppColors.secondary, isDestructive: true),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white.withOpacity(0.2));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.headlineMedium),
    );
  }
}

class _LanguageProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('🇳🇬', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Igbo', style: AppTextStyles.headlineSmall),
                const Text('Beginner · 12 lessons done', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: AppColors.divider,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('35%', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                const Padding(
                  padding: EdgeInsets.only(left: 62),
                  child: Divider(height: 1, thickness: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDestructive ? AppColors.secondary : AppColors.textPrimary,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}