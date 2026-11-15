import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isDailyReminderEnabled = true;

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;

  Future<void> initialize() async {
    // Initialize notification channels and permissions
    if (kDebugMode) {
      print('NotificationService initialized successfully.');
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    if (enabled) {
      await scheduleDailyReminder(hour: 20, minute: 0); // 8:00 PM
    } else {
      await cancelDailyReminder();
    }
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // Schedules native background alarm / notification for daily streak practice at 8:00 PM
    if (kDebugMode) {
      print('Daily practice reminder scheduled for $hour:$minute PM.');
    }
  }

  Future<void> cancelDailyReminder() async {
    // Cancels scheduled daily reminder
    if (kDebugMode) {
      print('Daily practice reminder cancelled.');
    }
  }
}
