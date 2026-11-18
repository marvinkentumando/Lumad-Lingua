import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/lumad_background.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _offlineDictionary = true;
  bool _dailyReminder = NotificationService().isDailyReminderEnabled;
  int _reminderHour = NotificationService().reminderHour;
  int _reminderMinute = NotificationService().reminderMinute;

  String _formatReminderTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold500,
              onPrimary: AppColors.forest900,
              surface: AppColors.forest800,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderHour = picked.hour;
        _reminderMinute = picked.minute;
      });
      await NotificationService().scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily practice reminder set for ${_formatReminderTime(picked.hour, picked.minute)}! ⏰'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final user = ref.watch(authStateProvider).value;
    final hasCustomThemePass = user?.inventory.contains('custom_theme_pass') ?? false;
    final isCustomAccentActive = ref.watch(customThemeAccentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: LumadBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Preferences',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Sound Effects', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Play audio feedback on lesson actions', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    value: _soundEffects,
                    activeThumbColor: AppColors.gold500,
                    onChanged: (val) => setState(() => _soundEffects = val),
                  ),
                  const Divider(color: AppColors.forest700),
                  SwitchListTile(
                    title: Text('Haptic Feedback', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Vibrate on correct/incorrect answers', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    value: _hapticFeedback,
                    activeThumbColor: AppColors.gold500,
                    onChanged: (val) => setState(() => _hapticFeedback = val),
                  ),
                  const Divider(color: AppColors.forest700),
                  SwitchListTile(
                    title: Text('Dark Mode', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Use dark theme palette', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    value: isDarkMode,
                    activeThumbColor: AppColors.gold500,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggleTheme(val);
                    },
                  ),
                  const Divider(color: AppColors.forest700),
                  SwitchListTile(
                    title: Text('Offline Dictionary Mode', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Cache full Mansaka dictionary and audio for offline study', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    value: _offlineDictionary,
                    activeThumbColor: AppColors.gold500,
                    onChanged: (val) {
                      setState(() => _offlineDictionary = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Offline dictionary mode enabled! 📦' : 'Offline dictionary mode disabled.')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Custom Theme Pass Section (Unlocked via Shop)
            if (hasCustomThemePass) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Custom Theme Pass (Unlocked)',
                style: AppTypography.labelBold.copyWith(color: AppColors.gold500, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: SwitchListTile(
                  title: Text('Royal Crimson & Gold Accent', style: AppTypography.h3.copyWith(color: Colors.white)),
                  subtitle: Text('Apply special seasonal UI palette unlocked via Crystal Shop pass', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                  value: isCustomAccentActive,
                  activeThumbColor: AppColors.gold500,
                  onChanged: (val) {
                    ref.read(customThemeAccentProvider.notifier).setAccent(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? 'Royal Crimson & Gold theme accent activated! 🎨' : 'Standard theme restored.')),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notifications',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Daily Practice Reminders', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      _dailyReminder
                          ? 'Remind me to maintain my streak daily at ${_formatReminderTime(_reminderHour, _reminderMinute)}'
                          : 'Daily practice reminders are disabled',
                      style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                    ),
                    value: _dailyReminder,
                    activeThumbColor: AppColors.gold500,
                    onChanged: (val) async {
                      setState(() => _dailyReminder = val);
                      await NotificationService().setDailyReminderEnabled(val);
                    },
                  ),
                  if (_dailyReminder) ...[
                    const Divider(color: AppColors.forest700),
                    ListTile(
                      onTap: _selectReminderTime,
                      title: Text('Reminder Time', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Tap to choose custom daily notification time', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(color: AppColors.gold500),
                        ),
                        child: Text(
                          _formatReminderTime(_reminderHour, _reminderMinute),
                          style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'About Lumad Lingua',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Version', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: Text('1.0.0+1', style: AppTypography.mono.copyWith(color: AppColors.gold500)),
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Preserving Mansaka Language', style: AppTypography.bodyLarge.copyWith(color: AppColors.gold500, fontWeight: FontWeight.bold)),
                    subtitle: Text('Built for cultural heritage and learning', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
