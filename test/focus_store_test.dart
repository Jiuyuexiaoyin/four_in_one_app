import 'package:flutter_test/flutter_test.dart';
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

  test('selected duration changes remaining time while idle', () {
    final store = FocusStore.inMemory();

    store.selectDuration(15 * 60);

    expect(store.selectedDurationSeconds, 15 * 60);
    expect(store.activeDurationSeconds, 15 * 60);
    expect(store.remainingSeconds, 15 * 60);
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

  test('Android running notification uses target end time countdown', () {
    final targetEndAt = DateTime.utc(2026, 4, 24, 9, 25);

    final details = FocusLocalNotificationService.buildRunningAndroidDetails(
      targetEndAt,
    );

    expect(details.when, targetEndAt.millisecondsSinceEpoch);
    expect(details.showWhen, isTrue);
    expect(details.usesChronometer, isTrue);
    expect(details.chronometerCountDown, isTrue);
    expect(details.ongoing, isTrue);
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
