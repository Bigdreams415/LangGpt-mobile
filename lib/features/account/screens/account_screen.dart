import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.flutterThemeMode == ThemeMode.dark ||
        (themeState.mode == AppThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Profile Header
              _ProfileHeader(user: user),
              const SizedBox(height: 20),

              // Stats Row
              _StatsRow(user: user),
              const SizedBox(height: 28),

              // Language Progress
              const _SectionHeader('My language'),
              const SizedBox(height: 12),
              _LanguageProgressCard(user: user),
              const SizedBox(height: 28),

              // Settings
              const _SectionHeader('Settings'),
              const SizedBox(height: 12),
              _SettingsGroup(
                items: [
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    color: AppColors.primarySurface,
                    iconColor: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    label: 'App language',
                    color: AppColors.accentBlueSurface,
                    iconColor: AppColors.accentBlue,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.languageSelect),
                  ),
                  _SettingsItem(
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    label: 'Dark mode',
                    color: AppColors.surfaceVariant,
                    iconColor: AppColors.textSecondary,
                    trailing: _ThemeSwitcher(
                    themeState: themeState,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setMode(mode),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsGroup(
                items: [
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    color: AppColors.accentYellowSurface,
                    iconColor: const Color(0xFFB8860B),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport),
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    color: AppColors.surfaceVariant,
                    iconColor: AppColors.textSecondary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                  ),
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About NaijaLingo',
                    color: AppColors.surfaceVariant,
                    iconColor: AppColors.textSecondary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aboutNaijaLingo),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Delete Account
              _SettingsGroup(
                items: [
                  _SettingsItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Account',
                    color: AppColors.secondarySurface,
                    iconColor: AppColors.secondary,
                    isDestructive: true,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.deleteAccount),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Logout
              _SettingsGroup(
                items: [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Log out',
                    color: AppColors.secondarySurface,
                    iconColor: AppColors.secondary,
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.getStarted,
                (route) => false,
              );
            },
            child: Text(
              'Log out',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Profile Header ----

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({required this.user});

  String get _initials {
    if (user?.fullName != null && (user!.fullName as String).isNotEmpty) {
      final parts = (user!.fullName as String).trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Avatar with edit badge
        GestureDetector(
          onTap: () {
            // TODO: implement avatar picker
          },
          child: Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(44),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user?.fullName ?? 'User',
          style: AppTextStyles.headlineLarge,
        ),
        const SizedBox(height: 4),
        Text(
          user?.username != null ? '@${user!.username}' : '@user',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

// ---- Stats Row ----

class _StatsRow extends StatelessWidget {
  final dynamic user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: '${user?.streakCount ?? 0}',
            label: 'Streak',
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.secondary,
          ),
          _StatDivider(isDark: isDark),
          _StatItem(
            value: '${user?.totalXp ?? 0}',
            label: 'XP',
            icon: Icons.bolt_rounded,
            iconColor: AppColors.accentYellow,
          ),
          _StatDivider(isDark: isDark),
          _StatItem(
            value: '12',
            label: 'Lessons',
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.headlineMedium),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: (isDark ? AppColors.darkDivider : AppColors.divider).withValues(alpha: 0.6),
    );
  }
}

// ---- Theme Switcher ----

class _ThemeSwitcher extends StatelessWidget {
  final ThemeState themeState;
  final ValueChanged<AppThemeMode> onChanged;
  const _ThemeSwitcher({required this.themeState, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppThemeMode>(
      padding: EdgeInsets.zero,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurfaceVariant
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _modeLabel(themeState.mode),
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppThemeMode.system,
          child: _PopupItem(
            label: 'System default',
            isSelected: themeState.mode == AppThemeMode.system,
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.light,
          child: _PopupItem(
            label: 'Light',
            isSelected: themeState.mode == AppThemeMode.light,
          ),
        ),
        PopupMenuItem(
          value: AppThemeMode.dark,
          child: _PopupItem(
            label: 'Dark',
            isSelected: themeState.mode == AppThemeMode.dark,
          ),
        ),
      ],
    );
  }

  String _modeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

class _PopupItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _PopupItem({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (isSelected)
          const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
      ],
    );
  }
}

// ---- Section Header ----

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

// ---- Language Progress Card ----

class _LanguageProgressCard extends StatelessWidget {
  final dynamic user;
  const _LanguageProgressCard({required this.user});

  String get _languageName {
    final lang = user?.selectedLanguage as String?;
    if (lang == null) return 'Not set';
    return lang[0].toUpperCase() + lang.substring(1);
  }

  String get _flag {
    final lang = user?.selectedLanguage as String?;
    switch (lang) {
      case 'igbo':
        return '🇳🇬';
      case 'yoruba':
        return '🇳🇬';
      case 'hausa':
        return '🇳🇬';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_flag, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_languageName, style: AppTextStyles.headlineSmall),
                Text(
                  'Beginner · 12 lessons done',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: isDark ? AppColors.darkDivider : AppColors.divider,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '35%',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Settings Group ----

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 62),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---- Settings Item ----

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final bool isDestructive;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.isDestructive = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? color.withValues(alpha: 0.15)
                    : color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDestructive ? AppColors.secondary : null,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}
