import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleExpiryAlert({
    required int id,
    required String meatType,
    required DateTime expiryDate,
  }) async {
    final notifyDate = expiryDate.subtract(const Duration(days: 10));
    final now = DateTime.now();

    if (!notifyDate.isAfter(now)) return;

    await _plugin.zonedSchedule(
      id,
      'Validade próxima',
      '$meatType vence em ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
      tz.TZDateTime.from(notifyDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          'Validade de carnes',
          channelDescription: 'Notificações de validade próxima',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
