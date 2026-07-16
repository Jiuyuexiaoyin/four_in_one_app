import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

typedef LocalNotificationResponseHandler =
    void Function(NotificationResponse response);

/// Narrow, injectable boundary around flutter_local_notifications.
abstract interface class LocalNotificationsGateway {
  Future<bool?> initialize({
    required InitializationSettings settings,
    required LocalNotificationResponseHandler onResponse,
  });

  Future<NotificationAppLaunchDetails?> getLaunchDetails();

  Future<void> createAndroidChannel(AndroidNotificationChannel channel);

  Future<List<AndroidNotificationChannel>?> getAndroidChannels();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payload,
  });

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required AndroidScheduleMode androidScheduleMode,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  });

  Future<void> cancel(int id);

  Future<List<PendingNotificationRequest>> pendingRequests();
}

class FlutterLocalNotificationsGateway implements LocalNotificationsGateway {
  FlutterLocalNotificationsGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    required LocalNotificationResponseHandler onResponse,
  }) {
    return _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onResponse,
    );
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<List<AndroidNotificationChannel>?> getAndroidChannels() async {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.getNotificationChannels();
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required AndroidScheduleMode androidScheduleMode,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() {
    return _plugin.pendingNotificationRequests();
  }
}
