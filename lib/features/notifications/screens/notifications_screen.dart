import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../presentation/providers/notification_preferences_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationPreferencesProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationPreferencesProvider);
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
        title: const Text('Notifications', style: AppTextStyles.headlineMedium),
        centerTitle: false,
      ),
      body: Builder(
        builder: (context) {
          if (state.loading && state.prefs == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
            children: [
              if (state.error != null && state.prefs == null)
                _ErrorBanner(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(notificationPreferencesProvider.notifier).load(),
                ),

              // Master push switch
              _PreferenceCard(
                children: [
                  _PreferenceRow(
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primarySurface,
                    title: 'Push notifications',
                    subtitle: 'Allow KinSpeak to send notifications',
                    value: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('push_enabled', v),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Per-category toggles
              _PreferenceCard(
                children: [
                  _PreferenceRow(
                    icon: Icons.alarm_rounded,
                    iconColor: AppColors.accentBlue,
                    iconBackground: AppColors.accentBlueSurface,
                    title: 'Daily reminders',
                    subtitle: 'Get a nudge to practice every day',
                    value: state.prefs?.dailyReminders ?? true,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('daily_reminders', v),
                  ),
                  _Divider(),
                  _PreferenceRow(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.secondary,
                    iconBackground: AppColors.secondarySurface,
                    title: 'Streak reminders',
                    subtitle: 'Stay on track — keep your streak alive',
                    value: state.prefs?.streakReminders ?? true,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('streak_reminders', v),
                  ),
                  _Divider(),
                  _PreferenceRow(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primarySurface,
                    title: 'Lesson updates',
                    subtitle: 'Be notified when new lessons drop',
                    value: state.prefs?.lessonUpdates ?? true,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('lesson_updates', v),
                  ),
                  _Divider(),
                  _PreferenceRow(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFB8860B),
                    iconBackground: AppColors.accentYellowSurface,
                    title: 'Achievements',
                    subtitle: 'Celebrate milestones and badges you earn',
                    value: state.prefs?.achievements ?? true,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('achievements', v),
                  ),
                  _Divider(),
                  _PreferenceRow(
                    icon: Icons.new_releases_rounded,
                    iconColor: AppColors.accentBlue,
                    iconBackground: AppColors.accentBlueSurface,
                    title: 'New content',
                    subtitle: 'Know when fresh content is available',
                    value: state.prefs?.newContent ?? true,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('new_content', v),
                  ),
                  _Divider(),
                  _PreferenceRow(
                    icon: Icons.campaign_rounded,
                    iconColor: AppColors.textSecondary,
                    iconBackground: AppColors.surfaceVariant,
                    title: 'Marketing',
                    subtitle: 'Offers, promotions, and announcements',
                    value: state.prefs?.marketing ?? false,
                    enabled: state.prefs?.pushEnabled ?? true,
                    onChanged: (v) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggle('marketing', v),
                  ),
                ],
              ),

              if (state.error != null && state.prefs != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Could not save: ${state.error}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// Card wrapper for a group of preference rows.
class _PreferenceCard extends StatelessWidget {
  final List<Widget> children;
  const _PreferenceCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 62),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? AppColors.darkDivider : AppColors.divider,
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PreferenceRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? iconBackground.withValues(alpha: 0.15)
                  : iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: enabled
                        ? null
                        : (isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
