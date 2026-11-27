import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/notification_service.dart';
import '../../services/database_service.dart';
import '../../providers/dictionary_provider.dart';
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
    final isElderMode = ref.watch(elderModeProvider);
    final currentLang = ref.watch(localizationProvider);
    final currentPattern = ref.watch(backgroundPatternProvider);
    final culturalSkin = ref.watch(culturalThemeProvider);
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

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Accessibility & Elder Support',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: SwitchListTile(
                title: Text('Elder High-Contrast & Large Text Mode 👁️', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Provides enlarged typography (+25% text scale) and high contrast for tribal elders & visually impaired learners', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                value: isElderMode,
                activeThumbColor: AppColors.gold500,
                onChanged: (val) {
                  ref.read(elderModeProvider.notifier).setElderMode(val);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(val ? 'Elder High-Contrast & Large Text Mode activated! 👁️ (+25% Text Scale)' : 'Standard text scaling restored.')),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Regional UI Language (Lingua Franca)',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('English', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentLang == 'en' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(localizationProvider.notifier).setLanguage('en');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UI Language set to English')));
                    },
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Cebuano (Binisaya)', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentLang == 'ceb' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(localizationProvider.notifier).setLanguage('ceb');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UI Language set to Cebuano (Binisaya)')));
                    },
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Tagalog (Filipino)', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentLang == 'tl' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(localizationProvider.notifier).setLanguage('tl');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UI Language set to Tagalog (Filipino)')));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cultural Textile Theme Skins',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Lumad Ancestral Forest 🌲', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Traditional Mindanao Higaonon & Manobo forest greens', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    trailing: culturalSkin == CulturalThemeSkin.lumadForest ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(culturalThemeProvider.notifier).setThemeSkin(CulturalThemeSkin.lumadForest);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lumad Ancestral Forest theme applied! 🌲')));
                    },
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('T\'boli T\'nalak Weave 🩸', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Sacred crimson red and earth brown dreamweaver motifs', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    trailing: culturalSkin == CulturalThemeSkin.tnalakWeave ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(culturalThemeProvider.notifier).setThemeSkin(CulturalThemeSkin.tnalakWeave);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('T\'boli T\'nalak Weave theme applied! 🩸')));
                    },
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Ilocano Inabel Motif 🌊', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Northern indigo blue and deep teal geometric weaves', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    trailing: culturalSkin == CulturalThemeSkin.inabelMotif ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () {
                      ref.read(culturalThemeProvider.notifier).setThemeSkin(CulturalThemeSkin.inabelMotif);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ilocano Inabel Motif theme applied! 🌊')));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tribal Background Pattern',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Lumad Woven Waves 🌊', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentPattern == 'woven_waves' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () => ref.read(backgroundPatternProvider.notifier).setPattern('woven_waves'),
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Tribal Chevron Geometry 📐', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentPattern == 'tribal_geom' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () => ref.read(backgroundPatternProvider.notifier).setPattern('tribal_geom'),
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Royal Crimson & Gold 🎨', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentPattern == 'royal_crimson' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () => ref.read(backgroundPatternProvider.notifier).setPattern('royal_crimson'),
                  ),
                  const Divider(color: AppColors.forest700),
                  ListTile(
                    title: Text('Solid Forest Gradient 🌲', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: currentPattern == 'solid_forest' ? const Icon(Icons.check_circle, color: AppColors.gold500) : null,
                    onTap: () => ref.read(backgroundPatternProvider.notifier).setPattern('solid_forest'),
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
              'Data & Storage',
              style: AppTypography.labelBold.copyWith(color: AppColors.creamText2, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: ListTile(
                title: Text('Clear Dictionary Cache & Sync 🔄', style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Clear local SQLite cache and fetch latest updates from Firebase', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await DatabaseService().clear();
                  ref.invalidate(dictionaryPaginationProvider);
                  ref.invalidate(partsOfSpeechProvider);
                  if (context.mounted) {
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Dictionary cache cleared! Latest data will be synced. 🔄')),
                    );
                  }
                },
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
