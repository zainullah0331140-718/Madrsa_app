import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// روزانہ حاضری کی یاد دہانی کے لیے نوٹیفیکیشن سروس
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool get isReady => _ready;

  static const int _dailyReminderId = 1001;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
      } catch (_) {}

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> requestPermission() async {
    if (!_ready) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> scheduleDailyReminder(int minutesAfterMidnight) async {
    if (!_ready) return;
    try {
      final hour = minutesAfterMidnight ~/ 60;
      final minute = minutesAfterMidnight % 60;

      await _plugin.zonedSchedule(
        _dailyReminderId,
        'حاضری کی یاد دہانی',
        'طلبہ کی آج کی حاضری درج کریں۔',
        _nextInstanceOf(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_attendance_reminder',
            'Daily Attendance Reminder',
            channelDescription: 'روزانہ طلبہ کی حاضری کی یاد دہانی',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // کچھ پلیٹ فارمز پر شیڈولنگ دستیاب نہیں ہوتی
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelDailyReminder() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(_dailyReminderId);
    } catch (_) {}
  }
}
