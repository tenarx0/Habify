import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Ask for general notification permission (Android 13+)
      await androidImplementation.requestNotificationsPermission();

      // Ask for exact alarm permission (Android 14+)
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String emoji,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      '$emoji Time for your habit!',
      'Keep your streak alive — complete "$habitName" today.',
      _nextOccurrence(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habify_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders to complete your habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var target =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }
}
