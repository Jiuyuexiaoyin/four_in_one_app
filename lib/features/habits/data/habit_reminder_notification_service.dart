// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

abstract interface class HabitReminderNotificationService {
  Future<void> initialize();

  Future<void> resyncReminders(List<HabitItem> habits);

  Future<void> scheduleDailyReminder(
    HabitItem habit, {
    required bool requestPermission,
  });

  Future<void> cancelReminder(String habitId);
}

class HabitReminderLocalNotificationService
    implements HabitReminderNotificationService {
  HabitReminderLocalNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'habit_daily_reminders';
  static const _channelName = 'Habit reminders';
  static const _numericIdBase = 720000;
  static const _hashIdBase = 920000;
  static const _idRange = 90000;
  static const _ruleIdBase = 1200000;
  static const _ruleHabitSlotRange = 20000;
  static const _ruleSlotStride = 8;

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _configureLocalTimezone();

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
  Future<void> resyncReminders(List<HabitItem> habits) async {
    await initialize();
    final canSchedule = await _ensurePermissions(requestPermission: false);

    for (final habit in habits) {
      await _cancelAllReminderIdsForHabit(habit.id);

      if (!habit.isActive ||
          habit.enabledReminderRules.isEmpty ||
          !canSchedule) {
        continue;
      }

      await _scheduleRules(habit);
    }
  }

  @override
  Future<void> scheduleDailyReminder(
    HabitItem habit, {
    required bool requestPermission,
  }) async {
    await initialize();
    await _cancelAllReminderIdsForHabit(habit.id);

    if (!habit.isActive ||
        habit.enabledReminderRules.isEmpty ||
        !await _ensurePermissions(requestPermission: requestPermission)) {
      return;
    }

    await _scheduleRules(habit);
  }

  @override
  Future<void> cancelReminder(String habitId) async {
    await initialize();
    await _cancelAllReminderIdsForHabit(habitId);
  }

  Future<void> _cancelAllReminderIdsForHabit(String habitId) async {
    await _notificationsPlugin.cancel(id: reminderIdForHabitId(habitId));

    for (
      var ruleIndex = 0;
      ruleIndex < HabitReminderRule.maxRulesPerHabit;
      ruleIndex += 1
    ) {
      for (var weekdaySlot = 0; weekdaySlot <= 7; weekdaySlot += 1) {
        await _notificationsPlugin.cancel(
          id: reminderRuleIdForHabitSlot(
            habitId: habitId,
            ruleIndex: ruleIndex,
            weekday: weekdaySlot,
          ),
        );
      }
    }
  }

  Future<void> _scheduleRules(HabitItem habit) async {
    final enabledRules = habit.enabledReminderRules
        .take(HabitReminderRule.maxRulesPerHabit)
        .toList(growable: false);

    for (var ruleIndex = 0; ruleIndex < enabledRules.length; ruleIndex += 1) {
      final rule = enabledRules[ruleIndex];
      final reminderTime = parseReminderTime(rule.time);
      if (reminderTime == null || rule.weekdays.isEmpty) {
        continue;
      }

      if (rule.isEveryDay) {
        await _schedule(
          id: reminderRuleIdForHabitSlot(
            habitId: habit.id,
            ruleIndex: ruleIndex,
            weekday: 0,
          ),
          habit: habit,
          scheduledDate: nextReminderDate(reminderTime),
          matchDateTimeComponents: DateTimeComponents.time,
        );
        continue;
      }

      for (final weekday in rule.weekdays) {
        await _schedule(
          id: reminderRuleIdForHabitSlot(
            habitId: habit.id,
            ruleIndex: ruleIndex,
            weekday: weekday,
          ),
          habit: habit,
          scheduledDate: nextWeeklyReminderDate(reminderTime, weekday),
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required HabitItem habit,
    required tz.TZDateTime scheduledDate,
    required DateTimeComponents matchDateTimeComponents,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: '涔犳儻鎻愰啋',
      body: reminderBodyForHabit(habit),
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Habit reminder notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  Future<bool> _ensurePermissions({required bool requestPermission}) async {
    if (kIsWeb) {
      return false;
    }

    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation == null) {
        return true;
      }

      final enabled = await androidImplementation.areNotificationsEnabled();
      if (enabled ?? true) {
        return true;
      }

      if (!requestPermission) {
        return false;
      }

      return await androidImplementation.requestNotificationsPermission() ??
          false;
    }

    if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation == null) {
        return true;
      }

      final permissions = await iosImplementation.checkPermissions();
      if ((permissions?.isEnabled ?? false) ||
          (permissions?.isProvisionalEnabled ?? false)) {
        return true;
      }

      if (!requestPermission) {
        return false;
      }

      return await iosImplementation.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  @visibleForTesting
  static int reminderIdForHabitId(String habitId) {
    final numericId = RegExp(r'^habit-(\d+)$').firstMatch(habitId);
    final parsedId = int.tryParse(numericId?.group(1) ?? '');
    if (parsedId != null) {
      return _numericIdBase + (parsedId % _idRange);
    }

    return _hashIdBase + (_stableHash(habitId) % _idRange);
  }

  @visibleForTesting
  static int reminderRuleIdForHabitSlot({
    required String habitId,
    required int ruleIndex,
    required int weekday,
  }) {
    final normalizedRuleIndex = ruleIndex
        .clamp(0, HabitReminderRule.maxRulesPerHabit - 1)
        .toInt();
    final normalizedWeekday = weekday.clamp(0, 7).toInt();

    return _ruleIdBase +
        (_habitSlotForRuleIds(habitId) *
            HabitReminderRule.maxRulesPerHabit *
            _ruleSlotStride) +
        (normalizedRuleIndex * _ruleSlotStride) +
        normalizedWeekday;
  }

  @visibleForTesting
  static String reminderBodyForHabit(HabitItem habit) {
    return '该打卡了：${habit.emoji} ${habit.name}';
  }

  @visibleForTesting
  static HabitReminderTime? parseReminderTime(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
    final hour = int.tryParse(match?.group(1) ?? '');
    final minute = int.tryParse(match?.group(2) ?? '');

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return HabitReminderTime(hour: hour, minute: minute);
  }

  @visibleForTesting
  static tz.TZDateTime nextReminderDate(HabitReminderTime reminderTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  @visibleForTesting
  static tz.TZDateTime nextWeeklyReminderDate(
    HabitReminderTime reminderTime,
    int weekday,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    final normalizedWeekday = weekday.clamp(1, 7).toInt();
    final daysUntilWeekday = (normalizedWeekday - scheduledDate.weekday) % 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntilWeekday));

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  static void _configureLocalTimezone() {
    tzdata.initializeTimeZones();

    final now = DateTime.now();
    final localOffset = now.timeZoneOffset;
    final localName = now.timeZoneName.isEmpty ? 'Local' : now.timeZoneName;
    tz.setLocalLocation(
      tz.Location('device-local', [tz.minTime], [0], [
        tz.TimeZone(localOffset, isDst: false, abbreviation: localName),
      ]),
    );
  }

  static int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  static int _habitSlotForRuleIds(String habitId) {
    final numericId = RegExp(r'^habit-(\d+)$').firstMatch(habitId);
    final parsedId = int.tryParse(numericId?.group(1) ?? '');
    if (parsedId != null) {
      return parsedId % _ruleHabitSlotRange;
    }

    return _stableHash(habitId) % _ruleHabitSlotRange;
  }
}

class HabitReminderTime {
  const HabitReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

class NoopHabitReminderNotificationService
    implements HabitReminderNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> resyncReminders(List<HabitItem> habits) async {}

  @override
  Future<void> scheduleDailyReminder(
    HabitItem habit, {
    required bool requestPermission,
  }) async {}

  @override
  Future<void> cancelReminder(String habitId) async {}
}
