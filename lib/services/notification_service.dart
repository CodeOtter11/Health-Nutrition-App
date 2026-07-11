import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidInit);

    await _notifications.initialize(settings);

    // ✅ TIMEZONE
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    print("🌍 Timezone set to Asia/Kolkata");

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // 🔥 CREATE CHANNEL (VERY IMPORTANT)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Reminder notifications',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(channel);

    // 🔔 PERMISSION (Android 13+)
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(0, title, body, details);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {

    print("📌 scheduleNotification CALLED");
    print("🕒 Scheduled Time: $scheduledTime");

    final duration = scheduledTime.difference(DateTime.now());

    print("⏳ Waiting for: ${duration.inSeconds} seconds");

    if (duration.isNegative) {
      print("❌ Time already passed");
      return;
    }

    Future.delayed(duration, () async {
      print("🚀 Triggering scheduled notification NOW");

      await showNotification(title, body);
    });
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}