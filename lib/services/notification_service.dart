import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefDailyReminderEnabled = 'lumad_pref_reminder_enabled';
const String _prefDailyReminderHour = 'lumad_pref_reminder_hour';
const String _prefDailyReminderMinute = 'lumad_pref_reminder_minute';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isDailyReminderEnabled = true;
  int _reminderHour = 20; // 8:00 PM
  int _reminderMinute = 0;
  bool _isInitialized = false;

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDailyReminderEnabled = prefs.getBool(_prefDailyReminderEnabled) ?? true;
      _reminderHour = prefs.getInt(_prefDailyReminderHour) ?? 20;
      _reminderMinute = prefs.getInt(_prefDailyReminderMinute) ?? 0;

      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(initializationSettings);
      _isInitialized = true;

      if (_isDailyReminderEnabled) {
        await scheduleDailyReminder(hour: _reminderHour, minute: _reminderMinute, showConfirmation: false);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService native initialization error/fallback: $e');
      }
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDailyReminderEnabled, enabled);
    } catch (_) {}

    if (enabled) {
      await scheduleDailyReminder(hour: _reminderHour, minute: _reminderMinute, showConfirmation: true);
    } else {
      await cancelDailyReminder();
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    bool showConfirmation = false,
  }) async {
    _reminderHour = hour;
    _reminderMinute = minute;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefDailyReminderHour, hour);
      await prefs.setInt(_prefDailyReminderMinute, minute);
    } catch (_) {}

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Request notification permissions for Android 13+ / iOS
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      const androidDetails = AndroidNotificationDetails(
        'lumad_reminders_channel',
        'Daily Practice Reminders',
        channelDescription: 'Channel for Lumad Lingua daily streak study reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule offline periodic daily reminder
      await _notificationsPlugin.periodicallyShow(
        101,
        'Madyaw na allaw! 📚',
        'Time for your daily Mansaka language practice! Keep your streak alive! 🔥',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      if (showConfirmation) {
        final period = hour >= 12 ? 'PM' : 'AM';
        final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final m = minute.toString().padLeft(2, '0');
        final timeStr = '$h:$m $period';

        await _notificationsPlugin.show(
          102,
          'Reminder Active! ⏰',
          'Daily practice reminder set for $timeStr. Maintain your streak and preserve Lumad heritage today! 🔥',
          notificationDetails,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Native OS notification schedule fallback: $e');
      }
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _notificationsPlugin.cancel(101);
      await _notificationsPlugin.cancel(102);
    } catch (_) {}
    if (kDebugMode) {
      debugPrint('Daily practice reminder cancelled.');
    }
  }
}
