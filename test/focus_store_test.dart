import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/data/focus_notification_service.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';

void main() {
  test(
    'keeps timer lifecycle safe across start, pause, reset, and dispose',
    () {
      var fakeNow = DateTime(2026, 4, 23, 9);
      final timerFactory = _FakeTimerFactory();
      final store = FocusStore.inMemory(
        defaultDurationSeconds: 3,
        nowProvider: () => fakeNow,
        timerFactory: timerFactory.call,
      );

      store.start();
      expect(timerFactory.records.length, 1);

      store.start();
      expect(timerFactory.records.length, 1);

      fakeNow = fakeNow.add(const Duration(seconds: 1));
      timerFactory.records.single.tick();
      expect(store.remainingSeconds, 2);

      store.pause();
      expect(timerFactory.records.single.cancelled, isTrue);

      store.start();
      expect(timerFactory.records.length, 2);

      store.reset();
      expect(timerFactory.records.last.cancelled, isTrue);
      expect(store.remainingSeconds, 3);
      expect(store.status, FocusStatus.idle);

      store.start();
      expect(timerFactory.records.length, 3);

      store.dispose();
      expect(timerFactory.records.last.cancelled, isTrue);
    },
  );

  test('pause at the target end records the completed session', () async {
    var fakeNow = DateTime(2026, 4, 23, 9);
    final timerFactory = _FakeTimerFactory();
    final store = FocusStore.inMemory(
      defaultDurationSeconds: 3,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );
    addTearDown(store.dispose);

    store.start();
    final expectedCompletedAt = fakeNow.add(const Duration(seconds: 3));
    fakeNow = fakeNow.add(const Duration(seconds: 4));

    store.pause();

    expect(store.status, FocusStatus.idle);
    expect(store.remainingSeconds, 0);
    expect(store.completedSessionCount, 1);
    expect(store.sessions.single.completedAt, expectedCompletedAt.toUtc());
    expect(store.sessions.single.durationSeconds, 3);
    expect(timerFactory.records.single.cancelled, isTrue);

    await _flushAsyncWork();
    expect(store.completedSessionCount, 1);
  });

  test(
    'idle completion notification already includes completed history',
    () async {
      var fakeNow = DateTime(2026, 4, 23, 9);
      final timerFactory = _FakeTimerFactory();
      final store = FocusStore.inMemory(
        defaultDurationSeconds: 3,
        nowProvider: () => fakeNow,
        timerFactory: timerFactory.call,
      );
      addTearDown(store.dispose);
      final idleHistoryCounts = <int>[];
      store.addListener(() {
        if (store.isIdle && store.remainingSeconds == 0) {
          idleHistoryCounts.add(store.completedSessionCount);
        }
      });

      store.start();
      fakeNow = fakeNow.add(const Duration(seconds: 4));
      timerFactory.records.single.tick();

      expect(store.status, FocusStatus.idle);
      expect(store.completedSessionCount, 1);
      expect(idleHistoryCounts, <int>[1]);

      await _flushAsyncWork();
      expect(store.completedSessionCount, 1);
      expect(idleHistoryCounts, <int>[1]);
    },
  );

  test('selected duration changes remaining time while idle', () {
    final store = FocusStore.inMemory();

    store.selectDuration(15 * 60);

    expect(store.selectedDurationSeconds, 15 * 60);
    expect(store.activeDurationSeconds, 15 * 60);
    expect(store.remainingSeconds, 15 * 60);
  });

  test('reconciles an idle selected target with current Plan options', () {
    final store = FocusStore.inMemory();
    addTearDown(store.dispose);
    const original = FocusTargetSnapshot(
      taskId: 'task-1',
      title: '旧标题',
      context: '旧计划',
    );
    const refreshed = FocusTargetSnapshot(
      taskId: 'task-1',
      title: '新标题',
      context: '新计划 / 新项目',
    );

    store.selectTarget(original);
    store.reconcileSelectedTarget(const [refreshed]);

    expect(store.selectedTarget?.title, '新标题');
    expect(store.selectedTarget?.context, '新计划 / 新项目');

    store.reconcileSelectedTarget(const <FocusTargetSnapshot>[]);
    expect(store.selectedTarget, isNull);
  });

  test('keeps an active target snapshot when Plan options change', () {
    final store = FocusStore.inMemory(defaultDurationSeconds: 60);
    addTearDown(store.dispose);
    const target = FocusTargetSnapshot(
      taskId: 'task-1',
      title: '本轮行动',
      context: '计划 / 项目',
    );

    store.selectTarget(target);
    store.start();
    store.reconcileSelectedTarget(const <FocusTargetSnapshot>[]);

    expect(store.activeTarget?.taskId, 'task-1');
    expect(store.currentTarget?.title, '本轮行动');
  });

  test('custom duration changes remaining time while idle', () {
    final store = FocusStore.inMemory();

    store.selectDuration(37 * 60);

    expect(store.selectedDurationSeconds, 37 * 60);
    expect(store.activeDurationSeconds, 37 * 60);
    expect(store.remainingSeconds, 37 * 60);
    expect(store.hasCustomSelectedDuration, isTrue);
  });

  test('selected duration is ignored during a running round', () {
    final store = FocusStore.inMemory();

    store.selectDuration(15 * 60);
    store.start();
    store.selectDuration(45 * 60);

    expect(store.selectedDurationSeconds, 15 * 60);
    expect(store.activeDurationSeconds, 15 * 60);
  });

  test('selected duration is ignored during a paused round', () {
    final store = FocusStore.inMemory();

    store.selectDuration(15 * 60);
    store.start();
    store.pause();
    store.selectDuration(45 * 60);

    expect(store.selectedDurationSeconds, 15 * 60);
    expect(store.activeDurationSeconds, 15 * 60);
  });

  test('reset uses the selected duration', () {
    var fakeNow = DateTime(2026, 4, 23, 9);
    final timerFactory = _FakeTimerFactory();
    final store = FocusStore.inMemory(
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    store.selectDuration(5 * 60);
    store.start();

    fakeNow = fakeNow.add(const Duration(seconds: 12));
    timerFactory.records.single.tick();
    expect(store.remainingSeconds, (5 * 60) - 12);

    store.reset();

    expect(store.remainingSeconds, 5 * 60);
    expect(store.activeDurationSeconds, 5 * 60);
    expect(store.status, FocusStatus.idle);
  });

  test('target selection is locked during running and paused rounds', () {
    final firstTarget = FocusTargetSnapshot(
      taskId: 'task-1',
      title: '写产品说明',
      context: '目标 / 项目',
    );
    final secondTarget = FocusTargetSnapshot(
      taskId: 'task-2',
      title: '整理材料',
      context: '目标 / 项目',
    );
    final store = FocusStore.inMemory();

    store.selectTarget(firstTarget);
    expect(store.selectedTarget, firstTarget);
    expect(store.currentTarget, firstTarget);

    store.start();
    store.selectTarget(secondTarget);
    store.clearSelectedTarget();

    expect(store.activeTarget, firstTarget);
    expect(store.currentTarget, firstTarget);

    store.pause();
    store.selectTarget(secondTarget);

    expect(store.activeTarget, firstTarget);
    expect(store.currentTarget, firstTarget);

    store.reset();
    store.clearSelectedTarget();

    expect(store.status, FocusStatus.idle);
    expect(store.selectedTarget, isNull);
    expect(store.currentTarget, isNull);
  });

  test('Android Focus completion uses ordinary inexact scheduling', () {
    expect(
      AppLocalNotificationService.scheduleMode,
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
    expect(FocusLocalNotificationService.activeNotificationId, 4101);
    expect(FocusLocalNotificationService.legacyCompletionReminderId, 4102);
    final firstId = FocusLocalNotificationService.completionReminderIdForTarget(
      DateTime.utc(2026, 7, 13, 9, 25),
    );
    final secondId =
        FocusLocalNotificationService.completionReminderIdForTarget(
          DateTime.utc(2026, 7, 13, 9, 50),
        );
    expect(firstId, isNot(secondId));
    expect(
      FocusLocalNotificationService.completionReminderIdForTarget(
        DateTime.utc(2026, 7, 13, 9, 25),
      ),
      firstId,
    );
    expect(firstId, greaterThan(4102));
  });
}

class _FakeTimerFactory {
  final List<_FakeTimerRecord> records = <_FakeTimerRecord>[];

  FocusTimerHandle call(Duration interval, void Function() onTick) {
    final record = _FakeTimerRecord(interval: interval, onTick: onTick);
    records.add(record);
    return record;
  }
}

Future<void> _flushAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeTimerRecord implements FocusTimerHandle {
  _FakeTimerRecord({required this.interval, required this.onTick});

  final Duration interval;
  final void Function() onTick;
  bool cancelled = false;

  void tick() {
    if (!cancelled) {
      onTick();
    }
  }

  @override
  void cancel() {
    cancelled = true;
  }
}
