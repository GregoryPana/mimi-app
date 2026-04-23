import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int dailyLetterNotificationId = 2001;
  static const int valentinesNotificationId = 2002;
  static const String dailyLetterChannelId = 'daily_letters';
  static const String valentinesChannelId = 'valentines_day';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    await _requestPermissions();
    _initTimezone();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _initTimezone() {
    tz.initializeTimeZones();
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final sign = hours <= 0 ? '+' : '-';
    final name = 'Etc/GMT$sign${hours.abs()}';
    if (tz.timeZoneDatabase.locations.containsKey(name)) {
      tz.setLocalLocation(tz.getLocation(name));
    }
  }

  Future<void> cancelDailyLetterReminder() async {
    await _plugin.cancel(dailyLetterNotificationId);
  }

  Future<void> cancelValentinesReminder() async {
    await _plugin.cancel(valentinesNotificationId);
    await _plugin.cancel(valentinesNotificationId + 1);
    await _plugin.cancel(valentinesNotificationId + 2);
    await _plugin.cancel(valentinesNotificationId + 3);
  }

  Future<void> scheduleDailyLetterReminder({
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      dailyLetterChannelId,
      'Daily Love Letters',
      channelDescription: 'Reminders to read today\'s love letter',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    final scheduledUtc = scheduledDate.toUtc();
    await _plugin.zonedSchedule(
      dailyLetterNotificationId,
      'Mimi, your love letter is waiting 💌',
      'Open the app to read today\'s message.',
      tz.TZDateTime.utc(
        scheduledUtc.year,
        scheduledUtc.month,
        scheduledUtc.day,
        scheduledUtc.hour,
        scheduledUtc.minute,
      ),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleValentinesReminder({
    required DateTime scheduledDate,
    required int notificationId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      valentinesChannelId,
      'Valentine\'s Day',
      channelDescription: 'Valentine\'s Day reminder',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      notificationId,
      'Happy Valentine\'s Day, Mimi ❤️',
      'Open your love letters and surprises today.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
