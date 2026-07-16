import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/core/notifications/device_time_zone_provider.dart';
import 'package:four_in_one_app/core/notifications/local_notifications_gateway.dart';
import 'package:four_in_one_app/features/focus/data/focus_notification_service.dart';
import 'package:four_in_one_app/features/habits/data/habit_reminder_notification_service.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('AppLocalNotificationService', () {
    test('initializes exactly once and creates only real channels', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final service = _service(gateway);

      await service.initialize();
      await service.initialize();

      expect(gateway.initializeCalls, 1);
      expect(gateway.channels.map((channel) => channel.id), <String>[
        AppLocalNotificationService.habitChannelId,
        AppLocalNotificationService.focusChannelId,
      ]);
    });

    test('schedule creates one pending inexact-while-idle reminder', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final service = _service(gateway);
      await service.initialize();
      final payload = _habitPayload('habit-1');

      final result = await service.scheduleHabitReminder(
        id: 1200001,
        habitName: '喝水',
        scheduledDate: tz.TZDateTime(tz.local, 2026, 7, 14, 8, 30),
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      expect(result.isCompleted, isTrue);
      expect(gateway.pending, hasLength(1));
      expect(
        gateway.lastScheduleMode,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
      expect(gateway.lastScheduledDetails?.android?.icon, 'ic_stat_getready');
      expect(
        gateway.lastScheduledDetails?.android?.visibility,
        NotificationVisibility.private,
      );
      final habitActions = gateway.lastScheduledDetails?.android?.actions;
      expect(habitActions, hasLength(1));
      expect(habitActions?.single.id, AppNotificationAction.habitOpen);
      expect(habitActions?.single.title, '去打卡');
      expect(habitActions?.single.showsUserInterface, isTrue);
      expect(habitActions?.single.cancelNotification, isTrue);
    });

    test(
      'Focus completion uses its private channel and truthful action',
      () async {
        final gateway = _FakeLocalNotificationsGateway();
        final service = _service(gateway);
        await service.initialize();
        final target = DateTime.utc(2026, 7, 14, 8, 30);
        final payload = AppNotificationPayload(
          type: AppNotificationType.focusCompletion,
          entityId: 'focus-${target.millisecondsSinceEpoch}',
          route: AppNotificationPayload.focusRoute,
        ).encode();

        final result = await service.scheduleFocusCompletion(
          id: FocusLocalNotificationService.completionReminderIdForTarget(
            target,
          ),
          targetEndAt: target,
          payload: payload,
        );

        expect(result.isCompleted, isTrue);
        final details = gateway.lastScheduledDetails?.android;
        expect(details?.channelId, AppLocalNotificationService.focusChannelId);
        expect(details?.icon, AppLocalNotificationService.notificationIcon);
        expect(details?.visibility, NotificationVisibility.private);
        final focusActions = details?.actions;
        expect(focusActions, hasLength(1));
        final focusAction = focusActions!.single;
        expect(focusAction.id, AppNotificationAction.focusViewRecords);
        expect(focusAction.title, '查看记录');
        expect(focusAction.showsUserInterface, isTrue);
        expect(focusAction.cancelNotification, isTrue);
      },
    );

    test(
      'reschedule replaces the previous reminder with the same ID',
      () async {
        final gateway = _FakeLocalNotificationsGateway();
        final service = _service(gateway);
        await service.initialize();

        for (final hour in <int>[8, 21]) {
          await service.scheduleHabitReminder(
            id: 1200001,
            habitName: '喝水',
            scheduledDate: tz.TZDateTime(tz.local, 2026, 7, 14, hour, 30),
            matchDateTimeComponents: DateTimeComponents.time,
            payload: _habitPayload('habit-1'),
          );
        }

        expect(gateway.pending, hasLength(1));
        expect(gateway.scheduleCalls, 2);
        expect(gateway.cancelCalls.where((id) => id == 1200001), hasLength(2));
      },
    );

    test('deletion cancels the pending reminder', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final service = _service(gateway);
      await service.initialize();
      await service.scheduleHabitReminder(
        id: 1200001,
        habitName: '喝水',
        scheduledDate: tz.TZDateTime(tz.local, 2026, 7, 14, 8, 30),
        matchDateTimeComponents: DateTimeComponents.time,
        payload: _habitPayload('habit-1'),
      );

      await service.cancel(1200001);

      expect(gateway.pending, isEmpty);
    });

    test(
      'test notification is immediate and never enters pending list',
      () async {
        final gateway = _FakeLocalNotificationsGateway();
        final service = _service(gateway);
        await service.initialize();
        final payload = AppNotificationPayload(
          type: AppNotificationType.test,
          entityId: 'notification-test-1',
          route: AppNotificationPayload.settingsRoute,
        ).encode();

        final result = await service.sendTestNotification(payload: payload);

        expect(result.isCompleted, isTrue);
        expect(gateway.showCalls, 1);
        expect(gateway.pending, isEmpty);
      },
    );

    test('initialization retries after a transient gateway failure', () async {
      final gateway = _FakeLocalNotificationsGateway(
        initializeFailuresRemaining: 1,
      );
      final service = _service(gateway);

      await service.initialize();
      expect(service.isInitialized, isFalse);
      await service.initialize();

      expect(gateway.initializeCalls, 2);
      expect(gateway.channels, hasLength(2));
      expect(service.isInitialized, isTrue);
    });

    test('disabled Habit channel blocks test delivery truthfully', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final service = _service(gateway);
      await service.initialize();
      gateway.channels
        ..removeWhere(
          (channel) => channel.id == AppLocalNotificationService.habitChannelId,
        )
        ..add(
          const AndroidNotificationChannel(
            AppLocalNotificationService.habitChannelId,
            AppLocalNotificationService.habitChannelName,
            importance: Importance.none,
          ),
        );
      final payload = AppNotificationPayload(
        type: AppNotificationType.test,
        entityId: 'notification-test-disabled-channel',
        route: AppNotificationPayload.settingsRoute,
      ).encode();

      final result = await service.sendTestNotification(payload: payload);
      final health = await service.health();

      expect(result.status, NotificationOperationStatus.unavailable);
      expect(result.errorCode, 'habit_channel_disabled');
      expect(gateway.showCalls, 0);
      expect(health.habitChannelAvailable, isFalse);
      expect(health.focusChannelAvailable, isTrue);
      expect(health.channelsAvailable, isFalse);
    });

    test('pre-Android 8 test delivery skips channel preflight', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final service = _service(gateway);
      await service.initialize();
      gateway.channels.clear();
      final payload = AppNotificationPayload(
        type: AppNotificationType.test,
        entityId: 'notification-test-pre-o',
        route: AppNotificationPayload.settingsRoute,
      ).encode();

      final result = await service.sendTestNotification(
        payload: payload,
        channelsApplicable: false,
      );

      expect(result.isCompleted, isTrue);
      expect(gateway.showCalls, 1);
    });

    test(
      'later successes do not erase an unacknowledged schedule error',
      () async {
        final gateway = _FakeLocalNotificationsGateway(failNextSchedule: true);
        final service = _service(gateway);
        await service.initialize();

        final failed = await service.scheduleHabitReminder(
          id: 1200001,
          habitName: '喝水',
          scheduledDate: tz.TZDateTime(tz.local, 2026, 7, 14, 8, 30),
          matchDateTimeComponents: DateTimeComponents.time,
          payload: _habitPayload('habit-1'),
        );
        await service.cancel(1200002);

        expect(failed.status, NotificationOperationStatus.failed);
        expect((await service.health()).lastErrorCode, isNotNull);

        final baseline = service.schedulingErrorRevision;
        await service.cancel(1200002);
        service.markSchedulingHealthy(baseline);

        expect((await service.health()).lastErrorCode, isNull);
      },
    );
  });

  group('Habit reminder reconciliation', () {
    test(
      'removes typed or legacy orphans and replaces desired reminder',
      () async {
        final gateway = _FakeLocalNotificationsGateway();
        final appNotifications = _service(gateway);
        final reminders = HabitReminderLocalNotificationService(
          appNotificationService: appNotifications,
        );
        final desiredHabit = _habitWithDailyReminder('habit-7', '08:30');
        final desiredId =
            HabitReminderLocalNotificationService.reminderRuleIdForHabitSlot(
              habitId: desiredHabit.id,
              ruleIndex: 0,
              weekday: 0,
            );
        final typedOrphanPayload = AppNotificationPayload(
          type: AppNotificationType.habitReminder,
          entityId: 'habit-deleted',
          route: AppNotificationPayload.habitsRoute,
        ).encode();
        final unrelatedFocusPayload = AppNotificationPayload(
          type: AppNotificationType.focusCompletion,
          entityId: 'focus-1770000000000',
          route: AppNotificationPayload.focusRoute,
        ).encode();
        gateway.pending[720123] = PendingNotificationRequest(
          720123,
          'legacy',
          'legacy',
          null,
        );
        gateway.pending[1200001] = PendingNotificationRequest(
          1200001,
          'orphan',
          'orphan',
          typedOrphanPayload,
        );
        gateway.pending[1600000000] = PendingNotificationRequest(
          1600000000,
          'focus',
          'focus',
          unrelatedFocusPayload,
        );

        await reminders.resyncReminders(<HabitItem>[desiredHabit]);

        expect(gateway.pending.keys, contains(desiredId));
        expect(gateway.pending.keys, contains(1600000000));
        expect(gateway.pending.keys, isNot(contains(720123)));
        expect(gateway.pending.keys, isNot(contains(1200001)));
        expect(
          AppNotificationPayload.tryParse(
            gateway.pending[desiredId]?.payload,
          )?.entityId,
          desiredHabit.id,
        );
      },
    );

    test('calendar construction preserves wall-clock time across DST', () {
      tzdata.initializeTimeZones();
      final originalLocation = tz.local;
      final newYork = tz.getLocation('America/New_York');
      tz.setLocalLocation(newYork);
      addTearDown(() => tz.setLocalLocation(originalLocation));
      const reminderTime = HabitReminderTime(hour: 8, minute: 30);

      final springResult =
          HabitReminderLocalNotificationService.nextReminderDate(
            reminderTime,
            now: tz.TZDateTime(newYork, 2026, 3, 7, 22),
          );
      final fallResult =
          HabitReminderLocalNotificationService.nextWeeklyReminderDate(
            reminderTime,
            DateTime.sunday,
            now: tz.TZDateTime(newYork, 2026, 10, 31, 22),
          );

      expect(
        (springResult.year, springResult.month, springResult.day),
        (2026, 3, 8),
      );
      expect((springResult.hour, springResult.minute), (8, 30));
      expect(
        (fallResult.year, fallResult.month, fallResult.day),
        (2026, 11, 1),
      );
      expect((fallResult.hour, fallResult.minute), (8, 30));
    });
  });

  group('Focus notification intent serialization', () {
    test('a stale running continuation cannot schedule after pause', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final appNotifications = _service(gateway);
      final focus = FocusLocalNotificationService(
        appNotificationService: appNotifications,
        nowProvider: () => DateTime.utc(2026, 7, 13, 9),
      );
      final cancelStarted = Completer<void>();
      final cancelGate = Completer<void>();
      gateway
        ..delayedCancelId = FocusLocalNotificationService.activeNotificationId
        ..cancelStarted = cancelStarted
        ..cancelGate = cancelGate;
      final target = DateTime.utc(2026, 7, 13, 9, 25);

      final showRunning = focus.showRunning(
        remainingSeconds: 25 * 60,
        targetEndAt: target,
      );
      await cancelStarted.future;
      final pauseCancellation = focus.cancelCompletionReminder();
      cancelGate.complete();
      await showRunning;
      await focus.scheduleCompletionReminder(targetEndAt: target);
      await pauseCancellation;

      expect(gateway.scheduleCalls, 0);
      expect(gateway.pending, isEmpty);
    });

    test('in-flight old schedule is cancelled before a newer round', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final appNotifications = _service(gateway);
      final focus = FocusLocalNotificationService(
        appNotificationService: appNotifications,
        nowProvider: () => DateTime.utc(2026, 7, 13, 9),
      );
      final firstTarget = DateTime.utc(2026, 7, 13, 9, 25);
      final secondTarget = DateTime.utc(2026, 7, 13, 9, 50);
      await focus.showRunning(
        remainingSeconds: 25 * 60,
        targetEndAt: firstTarget,
      );
      final scheduleStarted = Completer<void>();
      final scheduleGate = Completer<void>();
      gateway
        ..scheduleStarted = scheduleStarted
        ..scheduleGate = scheduleGate;

      final oldSchedule = focus.scheduleCompletionReminder(
        targetEndAt: firstTarget,
      );
      await scheduleStarted.future;
      final pauseCancellation = focus.cancelCompletionReminder();
      final showNewRound = focus.showRunning(
        remainingSeconds: 25 * 60,
        targetEndAt: secondTarget,
      );
      scheduleGate.complete();
      await oldSchedule;
      await pauseCancellation;
      await showNewRound;
      await focus.scheduleCompletionReminder(targetEndAt: secondTarget);

      final firstId =
          FocusLocalNotificationService.completionReminderIdForTarget(
            firstTarget,
          );
      final secondId =
          FocusLocalNotificationService.completionReminderIdForTarget(
            secondTarget,
          );
      expect(gateway.pending.keys, isNot(contains(firstId)));
      expect(gateway.pending.keys, contains(secondId));
      expect(gateway.pending, hasLength(1));
    });

    test(
      'delayed completed-round cleanup preserves an immediate new round',
      () async {
        var now = DateTime.utc(2026, 7, 13, 9);
        final gateway = _FakeLocalNotificationsGateway();
        final appNotifications = _service(gateway);
        final focus = FocusLocalNotificationService(
          appNotificationService: appNotifications,
          nowProvider: () => now,
        );
        final firstTarget = DateTime.utc(2026, 7, 13, 9, 25);
        final secondTarget = DateTime.utc(2026, 7, 13, 9, 50);
        await focus.showRunning(
          remainingSeconds: 25 * 60,
          targetEndAt: firstTarget,
        );
        await focus.scheduleCompletionReminder(targetEndAt: firstTarget);
        now = firstTarget;

        await focus.showRunning(
          remainingSeconds: 25 * 60,
          targetEndAt: secondTarget,
        );
        await focus.scheduleCompletionReminder(targetEndAt: secondTarget);
        await focus.clearFocusNotifications();

        final secondId =
            FocusLocalNotificationService.completionReminderIdForTarget(
              secondTarget,
            );
        expect(gateway.pending.keys, contains(secondId));

        await focus.clearFocusNotifications();

        expect(gateway.pending.keys, isNot(contains(secondId)));
      },
    );

    test(
      'pause cancellation uses the current ID if pending lookup fails',
      () async {
        final gateway = _FakeLocalNotificationsGateway();
        final appNotifications = _service(gateway);
        final focus = FocusLocalNotificationService(
          appNotificationService: appNotifications,
          nowProvider: () => DateTime.utc(2026, 7, 13, 9),
        );
        final target = DateTime.utc(2026, 7, 13, 9, 25);
        final targetId =
            FocusLocalNotificationService.completionReminderIdForTarget(target);
        await focus.showRunning(remainingSeconds: 25 * 60, targetEndAt: target);
        await focus.scheduleCompletionReminder(targetEndAt: target);
        gateway.failNextPending = true;

        await focus.cancelCompletionReminder();

        expect(gateway.pending.keys, isNot(contains(targetId)));
        expect(gateway.cancelCalls, contains(targetId));
      },
    );

    test('successful schedule removes an owned stale completion', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final appNotifications = _service(gateway);
      final focus = FocusLocalNotificationService(
        appNotificationService: appNotifications,
        nowProvider: () => DateTime.utc(2026, 7, 13, 9),
      );
      final orphanTarget = DateTime.utc(2026, 7, 12, 9, 25);
      final currentTarget = DateTime.utc(2026, 7, 13, 9, 25);
      final orphanId =
          FocusLocalNotificationService.completionReminderIdForTarget(
            orphanTarget,
          );
      final currentId =
          FocusLocalNotificationService.completionReminderIdForTarget(
            currentTarget,
          );
      gateway.pending[orphanId] = PendingNotificationRequest(
        orphanId,
        'orphan',
        'orphan',
        null,
      );

      await focus.showRunning(
        remainingSeconds: 25 * 60,
        targetEndAt: currentTarget,
      );
      await focus.scheduleCompletionReminder(targetEndAt: currentTarget);

      expect(gateway.pending.keys, isNot(contains(orphanId)));
      expect(gateway.pending.keys, contains(currentId));
      expect(gateway.pending, hasLength(1));
    });

    test('idle cleanup removes target-derived orphan requests', () async {
      final gateway = _FakeLocalNotificationsGateway();
      final appNotifications = _service(gateway);
      final focus = FocusLocalNotificationService(
        appNotificationService: appNotifications,
      );
      final orphanId =
          FocusLocalNotificationService.completionReminderIdForTarget(
            DateTime.utc(2026, 7, 13, 9, 25),
          );
      gateway.pending[orphanId] = PendingNotificationRequest(
        orphanId,
        'orphan',
        'orphan',
        null,
      );

      await focus.clearFocusNotifications();

      expect(gateway.pending, isEmpty);
    });
  });
}

AppLocalNotificationService _service(_FakeLocalNotificationsGateway gateway) {
  return AppLocalNotificationService(
    gateway: gateway,
    timeZoneProvider: const _FakeTimeZoneProvider('Asia/Shanghai'),
    isWeb: false,
    platform: TargetPlatform.android,
  );
}

String _habitPayload(String habitId) {
  return AppNotificationPayload(
    type: AppNotificationType.habitReminder,
    entityId: habitId,
    route: AppNotificationPayload.habitsRoute,
  ).encode();
}

HabitItem _habitWithDailyReminder(String id, String time) {
  final createdAt = DateTime.utc(2026, 7, 13, 8);
  final rule = HabitReminderRule(
    id: 'reminder-$id',
    time: time,
    weekdays: HabitReminderRule.allWeekdays,
    isEnabled: true,
    createdAt: createdAt,
  );
  return HabitItem(
    id: id,
    name: '喝水',
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: 1,
    reminderTime: time,
    reminderRules: <HabitReminderRule>[rule],
    createdAt: createdAt,
  );
}

class _FakeTimeZoneProvider implements DeviceTimeZoneProvider {
  const _FakeTimeZoneProvider(this.value);

  final String value;

  @override
  Future<String?> getTimeZoneId() async => value;
}

class _FakeLocalNotificationsGateway implements LocalNotificationsGateway {
  _FakeLocalNotificationsGateway({
    this.initializeFailuresRemaining = 0,
    this.failNextSchedule = false,
  });

  int initializeCalls = 0;
  int scheduleCalls = 0;
  int showCalls = 0;
  int initializeFailuresRemaining;
  bool failNextSchedule;
  bool failNextPending = false;
  int? delayedCancelId;
  Completer<void>? cancelStarted;
  Completer<void>? cancelGate;
  Completer<void>? scheduleStarted;
  Completer<void>? scheduleGate;
  final List<int> cancelCalls = <int>[];
  final List<AndroidNotificationChannel> channels =
      <AndroidNotificationChannel>[];
  final Map<int, PendingNotificationRequest> pending =
      <int, PendingNotificationRequest>{};
  LocalNotificationResponseHandler? responseHandler;
  AndroidScheduleMode? lastScheduleMode;
  NotificationDetails? lastScheduledDetails;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    required LocalNotificationResponseHandler onResponse,
  }) async {
    initializeCalls += 1;
    if (initializeFailuresRemaining > 0) {
      initializeFailuresRemaining -= 1;
      throw StateError('transient initialization failure');
    }
    responseHandler = onResponse;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async => null;

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    channels.removeWhere((existing) => existing.id == channel.id);
    channels.add(channel);
  }

  @override
  Future<List<AndroidNotificationChannel>?> getAndroidChannels() async {
    return List<AndroidNotificationChannel>.of(channels);
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payload,
  }) async {
    showCalls += 1;
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
  }) async {
    scheduleCalls += 1;
    if (failNextSchedule) {
      failNextSchedule = false;
      throw StateError('schedule failure');
    }
    final started = scheduleStarted;
    final gate = scheduleGate;
    scheduleStarted = null;
    scheduleGate = null;
    if (started != null && !started.isCompleted) {
      started.complete();
    }
    if (gate != null) {
      await gate.future;
    }
    lastScheduleMode = androidScheduleMode;
    lastScheduledDetails = details;
    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  Future<void> cancel(int id) async {
    if (id == delayedCancelId) {
      final started = cancelStarted;
      final gate = cancelGate;
      delayedCancelId = null;
      cancelStarted = null;
      cancelGate = null;
      if (started != null && !started.isCompleted) {
        started.complete();
      }
      if (gate != null) {
        await gate.future;
      }
    }
    cancelCalls.add(id);
    pending.remove(id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    if (failNextPending) {
      failNextPending = false;
      throw StateError('pending lookup failure');
    }
    return pending.values.toList(growable: false);
  }
}
