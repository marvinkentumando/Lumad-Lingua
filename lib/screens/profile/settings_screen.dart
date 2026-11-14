import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _dailyReminder = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: ListView(
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Notifications',
            style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: SwitchListTile(
              title: Text('Daily Practice Reminders', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Remind me to maintain my streak at 8:00 PM', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
              value: _dailyReminder,
              activeThumbColor: AppColors.gold500,
              onChanged: (val) => setState(() => _dailyReminder = val),
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
                  title: Text('Preserving Mansaka Language', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Built for cultural heritage and learning', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
