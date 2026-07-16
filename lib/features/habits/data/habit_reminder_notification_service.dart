import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
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
    AppLocalNotificationService? appNotificationService,
  }) : _appNotifications =
           appNotificationService ?? AppLocalNotificationService();

  static const _numericIdBase = 720000;
  static const _hashIdBase = 920000;
  static const _idRange = 90000;
  static const _ruleIdBase = 1200000;
  static const _ruleHabitSlotRange = 20000;
  static const _ruleSlotStride = 8;

  final AppLocalNotificationService _appNotifications;

  @override
  Future<void> initialize() => _appNotifications.initialize();

  @override
  Future<void> resyncReminders(List<HabitItem> habits) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final pending = await _appNotifications.pendingRequests(
      recordSchedulingFailure: true,
    );
    var completedWithoutError =
        _appNotifications.schedulingErrorRevision == baselineRevision;
    final desiredById = <int, _HabitReminderSchedule>{};
    for (final habit in habits) {
      for (final schedule in _desiredSchedulesForHabit(habit)) {
        desiredById[schedule.id] = schedule;
      }
    }

    if (completedWithoutError) {
      for (final request in pending) {
        if (!_isAppOwnedHabitRequest(request) ||
            desiredById.containsKey(request.id)) {
          continue;
        }
        final result = await _appNotifications.cancel(request.id);
        completedWithoutError &= result.isCompleted;
      }
    } else {
      for (final habit in habits) {
        completedWithoutError &= await _cancelIds(
          _allReminderIdsForHabit(habit.id),
        );
      }
    }

    for (final schedule in desiredById.values) {
      final result = await _schedule(schedule);
      completedWithoutError &= result.isCompleted;
    }

    if (completedWithoutError) {
      _appNotifications.markSchedulingHealthy(baselineRevision);
    }
  }

  @override
  Future<void> scheduleDailyReminder(
    HabitItem habit, {
    required bool requestPermission,
  }) async {
    if (kIsWeb) {
      return;
    }

    // Permission prompting belongs to the user-facing Habit flow. Scheduling
    // is intentionally preserved after denial so a later grant can take effect.
    await initialize();
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final pending = await _appNotifications.pendingRequests(
      recordSchedulingFailure: true,
    );
    var completedWithoutError =
        _appNotifications.schedulingErrorRevision == baselineRevision;
    final desiredById = <int, _HabitReminderSchedule>{
      for (final schedule in _desiredSchedulesForHabit(habit))
        schedule.id: schedule,
    };

    if (completedWithoutError) {
      final ownedIds = _allReminderIdsForHabit(habit.id);
      for (final request in pending) {
        if (!_requestBelongsToHabit(request, habit.id, ownedIds) ||
            desiredById.containsKey(request.id)) {
          continue;
        }
        final result = await _appNotifications.cancel(request.id);
        completedWithoutError &= result.isCompleted;
      }
    } else {
      completedWithoutError &= await _cancelIds(
        _allReminderIdsForHabit(habit.id),
      );
    }

    for (final schedule in desiredById.values) {
      final result = await _schedule(schedule);
      completedWithoutError &= result.isCompleted;
    }

    if (completedWithoutError) {
      _appNotifications.markSchedulingHealthy(baselineRevision);
    }
  }

  @override
  Future<void> cancelReminder(String habitId) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final pending = await _appNotifications.pendingRequests(
      recordSchedulingFailure: true,
    );
    var completedWithoutError =
        _appNotifications.schedulingErrorRevision == baselineRevision;
    final ownedIds = _allReminderIdsForHabit(habitId);

    if (completedWithoutError) {
      for (final request in pending) {
        if (!_requestBelongsToHabit(request, habitId, ownedIds)) {
          continue;
        }
        final result = await _appNotifications.cancel(request.id);
        completedWithoutError &= result.isCompleted;
      }
    } else {
      completedWithoutError &= await _cancelIds(ownedIds);
    }

    if (completedWithoutError) {
      _appNotifications.markSchedulingHealthy(baselineRevision);
    }
  }

  List<_HabitReminderSchedule> _desiredSchedulesForHabit(HabitItem habit) {
    if (!habit.isActive || habit.enabledReminderRules.isEmpty) {
      return const <_HabitReminderSchedule>[];
    }

    final enabledRules = habit.enabledReminderRules
        .take(HabitReminderRule.maxRulesPerHabit)
        .toList(growable: false);
    final schedules = <_HabitReminderSchedule>[];

    for (var ruleIndex = 0; ruleIndex < enabledRules.length; ruleIndex += 1) {
      final rule = enabledRules[ruleIndex];
      final reminderTime = parseReminderTime(rule.time);
      if (reminderTime == null || rule.weekdays.isEmpty) {
        continue;
      }

      if (rule.isEveryDay) {
        schedules.add(
          _HabitReminderSchedule(
            id: reminderRuleIdForHabitSlot(
              habitId: habit.id,
              ruleIndex: ruleIndex,
              weekday: 0,
            ),
            habit: habit,
            scheduledDate: nextReminderDate(reminderTime),
            matchDateTimeComponents: DateTimeComponents.time,
          ),
        );
        continue;
      }

      for (final weekday in rule.weekdays) {
        schedules.add(
          _HabitReminderSchedule(
            id: reminderRuleIdForHabitSlot(
              habitId: habit.id,
              ruleIndex: ruleIndex,
              weekday: weekday,
            ),
            habit: habit,
            scheduledDate: nextWeeklyReminderDate(reminderTime, weekday),
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          ),
        );
      }
    }

    return schedules;
  }

  Future<NotificationOperationResult> _schedule(
    _HabitReminderSchedule schedule,
  ) async {
    final habit = schedule.habit;
    final payload = AppNotificationPayload(
      type: AppNotificationType.habitReminder,
      entityId: habit.id,
      route: AppNotificationPayload.habitsRoute,
    );

    return _appNotifications.scheduleHabitReminder(
      id: schedule.id,
      habitName: habit.name,
      scheduledDate: schedule.scheduledDate,
      matchDateTimeComponents: schedule.matchDateTimeComponents,
      payload: payload.encode(),
    );
  }

  Future<bool> _cancelIds(Iterable<int> ids) async {
    var completedWithoutError = true;
    for (final id in ids) {
      final result = await _appNotifications.cancel(id);
      completedWithoutError &= result.isCompleted;
    }
    return completedWithoutError;
  }

  static Set<int> _allReminderIdsForHabit(String habitId) {
    final ids = <int>{reminderIdForHabitId(habitId)};
    for (
      var ruleIndex = 0;
      ruleIndex < HabitReminderRule.maxRulesPerHabit;
      ruleIndex += 1
    ) {
      for (var weekdaySlot = 0; weekdaySlot <= 7; weekdaySlot += 1) {
        ids.add(
          reminderRuleIdForHabitSlot(
            habitId: habitId,
            ruleIndex: ruleIndex,
            weekday: weekdaySlot,
          ),
        );
      }
    }
    return ids;
  }

  static bool _requestBelongsToHabit(
    PendingNotificationRequest request,
    String habitId,
    Set<int> ownedIds,
  ) {
    final payload = AppNotificationPayload.tryParse(request.payload);
    return ownedIds.contains(request.id) ||
        (payload?.type == AppNotificationType.habitReminder &&
            payload?.entityId == habitId);
  }

  static bool _isAppOwnedHabitRequest(PendingNotificationRequest request) {
    final payload = AppNotificationPayload.tryParse(request.payload);
    return payload?.type == AppNotificationType.habitReminder ||
        _isLegacyOrRuleReminderId(request.id);
  }

  static bool _isLegacyOrRuleReminderId(int id) {
    final ruleIdEndExclusive =
        _ruleIdBase +
        (_ruleHabitSlotRange *
            HabitReminderRule.maxRulesPerHabit *
            _ruleSlotStride);
    return (id >= _numericIdBase && id < _numericIdBase + _idRange) ||
        (id >= _hashIdBase && id < _hashIdBase + _idRange) ||
        (id >= _ruleIdBase && id < ruleIdEndExclusive);
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
    final name = habit.name.trim();
    return name.isEmpty ? '今天还有一个习惯等待完成' : '今天的「$name」还未完成';
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
  static tz.TZDateTime nextReminderDate(
    HabitReminderTime reminderTime, {
    tz.TZDateTime? now,
  }) {
    final current = now ?? tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      current.year,
      current.month,
      current.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (!scheduledDate.isAfter(current)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        current.year,
        current.month,
        current.day + 1,
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    return scheduledDate;
  }

  @visibleForTesting
  static tz.TZDateTime nextWeeklyReminderDate(
    HabitReminderTime reminderTime,
    int weekday, {
    tz.TZDateTime? now,
  }) {
    final current = now ?? tz.TZDateTime.now(tz.local);
    final normalizedWeekday = weekday.clamp(1, 7).toInt();
    var daysUntilWeekday = (normalizedWeekday - current.weekday) % 7;
    var scheduledDate = tz.TZDateTime(
      tz.local,
      current.year,
      current.month,
      current.day + daysUntilWeekday,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (!scheduledDate.isAfter(current)) {
      daysUntilWeekday += 7;
      scheduledDate = tz.TZDateTime(
        tz.local,
        current.year,
        current.month,
        current.day + daysUntilWeekday,
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    return scheduledDate;
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

class _HabitReminderSchedule {
  const _HabitReminderSchedule({
    required this.id,
    required this.habit,
    required this.scheduledDate,
    required this.matchDateTimeComponents,
  });

  final int id;
  final HabitItem habit;
  final tz.TZDateTime scheduledDate;
  final DateTimeComponents matchDateTimeComponents;
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
