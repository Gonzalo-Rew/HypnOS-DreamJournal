import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyReminderNotificationId = 1001;
  static const String _dailyReminderChannelId = 'dream_reminders';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userSettingsSubscription;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneInfo.identifier);
      tz.setLocalLocation(location);
    } catch (e) {
      // Keep reminders working even if timezone lookup fails on some devices.
      debugPrint('[Reminder] Timezone lookup failed, falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _dailyReminderChannelId,
            'Dream reminders',
            description: 'Daily reminders to log dreams.',
            importance: Importance.defaultImportance,
          ),
        );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    debugPrint(
      '[Reminder][Init] timezone=${tz.local.name} now=${tz.TZDateTime.now(tz.local)}',
    );
  }

  Future<void> startForUser(String userId) async {
    await _userSettingsSubscription?.cancel();
    debugPrint('[Reminder][Start] Listening settings for uid=$userId');
    _userSettingsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
          final data = snapshot.data();
          if (data == null) {
            debugPrint(
              '[Reminder][Snapshot] users/$userId not found, canceling',
            );
            await cancelDailyReminder();
            return;
          }
          debugPrint(
            '[Reminder][Snapshot] enabled=${data['notificationsEnabled']} time=${data['notificationTime']}',
          );
          await _applyReminderSettings(data);
        });
  }

  Future<void> stop() async {
    await _userSettingsSubscription?.cancel();
    _userSettingsSubscription = null;
    await cancelDailyReminder();
  }

  Future<void> _applyReminderSettings(Map<String, dynamic> userData) async {
    final enabled = userData['notificationsEnabled'] as bool? ?? true;
    final time = userData['notificationTime'] as String? ?? '08:00';

    debugPrint(
      '[Reminder][Apply] enabled=$enabled rawTime=$time timezone=${tz.local.name}',
    );

    if (!enabled) {
      await cancelDailyReminder();
      return;
    }

    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    await scheduleDailyReminder(hour: hour, minute: minute);
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    debugPrint(
      '[Reminder][Schedule] now=$now target=${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} next=$next',
    );

    await _localNotifications.zonedSchedule(
      _dailyReminderNotificationId,
      'HypnOS',
      'No olvides registrar tu sueño de hoy.',
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannelId,
          'Dream reminders',
          channelDescription: 'Daily reminders to log dreams.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final pending = await _localNotifications.pendingNotificationRequests();
    final reminder = pending.where(
      (item) => item.id == _dailyReminderNotificationId,
    );
    debugPrint(
      '[Reminder][Schedule] pendingTotal=${pending.length} reminderScheduled=${reminder.isNotEmpty}',
    );
  }

  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(_dailyReminderNotificationId);
    debugPrint('[Reminder][Cancel] canceled id=$_dailyReminderNotificationId');
  }
}
