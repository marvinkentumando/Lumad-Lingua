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
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Play audio feedback on lesson actions'),
                  value: _soundEffects,
                  onChanged: (val) => setState(() => _soundEffects = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibrate on correct/incorrect answers'),
                  value: _hapticFeedback,
                  onChanged: (val) => setState(() => _hapticFeedback = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme palette'),
                  value: isDarkMode,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).toggleTheme(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: SwitchListTile(
              title: const Text('Daily Practice Reminders'),
              subtitle: const Text('Remind me to maintain my streak at 8:00 PM'),
              value: _dailyReminder,
              onChanged: (val) => setState(() => _dailyReminder = val),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'About Lumad Lingua',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            child: Column(
              children: const [
                ListTile(
                  title: Text('Version'),
                  trailing: Text('1.0.0+1', style: TextStyle(color: Colors.grey)),
                ),
                Divider(),
                ListTile(
                  title: Text('Preserving Mansaka Language'),
                  subtitle: Text('Built for cultural heritage and learning'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
