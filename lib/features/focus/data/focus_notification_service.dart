// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract interface class FocusNotificationService {
  Future<void> initialize();

  Future<void> showRunning({
    required int remainingSeconds,
    required DateTime targetEndAt,
  });

  Future<void> showPaused({required int remainingSeconds});

  Future<void> scheduleCompletionReminder({required DateTime targetEndAt});

  Future<void> cancelActiveNotification();

  Future<void> cancelCompletionReminder();

  Future<void> clearFocusNotifications();
}

class FocusLocalNotificationService implements FocusNotificationService {
  FocusLocalNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  static const _activeNotificationId = 4101;
  static const _completionReminderId = 4102;
  static const _channelId = 'focus_reliability';
  static const _channelName = 'Focus timer';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;
  bool? _permissionsGranted;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tzdata.initializeTimeZones();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notificationsPlugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  @override
  Future<void> showRunning({
    required int remainingSeconds,
    required DateTime targetEndAt,
  }) async {
    await initialize();
    if (!Platform.isAndroid || !await _ensurePermissions()) {
      return;
    }

    await _notificationsPlugin.show(
      id: _activeNotificationId,
      title: '专注进行中',
      body: '系统会在完成时提醒你',
      notificationDetails: NotificationDetails(
        android: buildRunningAndroidDetails(targetEndAt),
      ),
    );
  }

  @override
  Future<void> showPaused({required int remainingSeconds}) async {
    await initialize();
    if (!Platform.isAndroid || !await _ensurePermissions()) {
      return;
    }

    await _notificationsPlugin.show(
      id: _activeNotificationId,
      title: '专注已暂停',
      body: '剩余 ${_formatDuration(remainingSeconds)}',
      notificationDetails: const NotificationDetails(
        android: _pausedAndroidDetails,
      ),
    );
  }

  @override
  Future<void> scheduleCompletionReminder({
    required DateTime targetEndAt,
  }) async {
    await initialize();
    if (!await _ensurePermissions()) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id: _completionReminderId,
      title: '专注完成',
      body: '这一轮专注已经结束。',
      scheduledDate: tz.TZDateTime.from(targetEndAt.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: _completionAndroidDetails,
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  @override
  Future<void> cancelActiveNotification() async {
    await initialize();
    await _notificationsPlugin.cancel(id: _activeNotificationId);
  }

  @override
  Future<void> cancelCompletionReminder() async {
    await initialize();
    await _notificationsPlugin.cancel(id: _completionReminderId);
  }

  @override
  Future<void> clearFocusNotifications() async {
    await initialize();
    await Future.wait<void>([
      _notificationsPlugin.cancel(id: _activeNotificationId),
      _notificationsPlugin.cancel(id: _completionReminderId),
    ]);
  }

  Future<bool> _ensurePermissions() async {
    if (_permissionsGranted != null) {
      return _permissionsGranted!;
    }

    if (Platform.isAndroid) {
      _permissionsGranted =
          await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
      return _permissionsGranted!;
    }

    if (Platform.isIOS) {
      _permissionsGranted =
          await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: false, sound: true) ??
          true;
      return _permissionsGranted!;
    }

    _permissionsGranted = true;
    return true;
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remainingSeconds';
  }

  @visibleForTesting
  static AndroidNotificationDetails buildRunningAndroidDetails(
    DateTime targetEndAt,
  ) {
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows the current focus timer state.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: true,
      when: targetEndAt.toUtc().millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
    );
  }

  static const _pausedAndroidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Shows the current focus timer state.',
    importance: Importance.low,
    priority: Priority.low,
    ongoing: false,
    onlyAlertOnce: true,
    showWhen: false,
  );

  static const _completionAndroidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Shows the current focus timer state.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    onlyAlertOnce: true,
  );
}
