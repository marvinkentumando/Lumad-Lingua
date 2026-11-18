import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefDailyReminderEnabled = 'lumad_pref_reminder_enabled';
const String _prefDailyReminderHour = 'lumad_pref_reminder_hour';
const String _prefDailyReminderMinute = 'lumad_pref_reminder_minute';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isDailyReminderEnabled = true;
  int _reminderHour = 20; // 8:00 PM
  int _reminderMinute = 0;

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDailyReminderEnabled = prefs.getBool(_prefDailyReminderEnabled) ?? true;
      _reminderHour = prefs.getInt(_prefDailyReminderHour) ?? 20;
      _reminderMinute = prefs.getInt(_prefDailyReminderMinute) ?? 0;

      if (_isDailyReminderEnabled) {
        await scheduleDailyReminder(hour: _reminderHour, minute: _reminderMinute);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
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
      await scheduleDailyReminder(hour: _reminderHour, minute: _reminderMinute);
    } else {
      await cancelDailyReminder();
    }
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    _reminderHour = hour;
    _reminderMinute = minute;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefDailyReminderHour, hour);
      await prefs.setInt(_prefDailyReminderMinute, minute);
    } catch (_) {}

    final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    if (kDebugMode) {
      print('Daily practice reminder scheduled for $timeStr PM.');
    }
  }

  Future<void> cancelDailyReminder() async {
    if (kDebugMode) {
      print('Daily practice reminder cancelled.');
    }
  }
}
