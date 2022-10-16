import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    // Android initialization
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    // the initialization settings are initialized after they are setted
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(
      int id, String title, String body, int time) async {
    var timestamp1 = time; // timestamp in seconds
    DateTime date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1 * 1000);

    Duration diff = date1.difference(DateTime.now());
    bool toshow2sec = false;

    if (diff.isNegative) {
      body = body + 'Already started Please Refresh!';
    
      toshow2sec = true;
    } else if (diff.inHours == 0) {
      body = body + 'Starts in ${diff.inMinutes}m ${diff.inSeconds}s';
      toshow2sec = true;
    } else {
      timestamp1 = time - 3500; // timestamp in seconds
      date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1 * 1000);
      diff = date1.difference(DateTime.now());
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(
          seconds: toshow2sec
              ? 2
              : diff
                  .inSeconds)), //schedule the notification to show after 2 seconds.
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelShowBadge: true,
            channelDescription: "rohit",
            importance: Importance.max,
            priority: Priority.max),
      ),

      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle:
          true, // To show notification even when the app is closed
    );
  }

  Future cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
