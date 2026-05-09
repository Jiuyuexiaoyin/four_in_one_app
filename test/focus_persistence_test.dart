import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/data/focus_local_storage.dart';
import 'package:four_in_one_app/features/focus/data/focus_notification_service.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_active_session.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';

void main() {
  test('natural countdown completion records exactly one session', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 1);
    final intendedEndTime = fakeNow.add(const Duration(seconds: 3));
    final storage = _FakeFocusStorage();
    final notifications = _FakeFocusNotificationService();
    final timerFactory = _FakeTimerFactory();
    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 3,
      notificationService: notifications,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    store.start();
    await _flushAsync();
    expect(timerFactory.records.length, 1);

    fakeNow = fakeNow.add(const Duration(seconds: 7));
    timerFactory.records.single.tick();
    await _flushAsync();

    expect(store.completedSessionCount, 1);
    expect(store.sessions.single.completedAt, intendedEndTime);
    expect(store.sessions.single.durationSeconds, 3);
    expect(storage.saveHistoryCalls, 1);
    expect(storage.lastSavedSessions!.single.completedAt, intendedEndTime);
    expect(storage.activeSession, isNull);
    expect(notifications.clearAllCalls, 1);

    timerFactory.records.single.tick();
    await _flushAsync();

    expect(store.completedSessionCount, 1);
    expect(storage.saveHistoryCalls, 1);
  });

  test('running session restores with recomputed remaining time', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 9);
    final startedAt = fakeNow.subtract(const Duration(seconds: 4));
    final targetEndAt = fakeNow.add(const Duration(seconds: 6));
    const target = FocusTargetSnapshot(
      taskId: 'task-1',
      title: '写产品说明',
      context: '目标 / 项目',
    );
    final storage = _FakeFocusStorage(
      activeSession: FocusActiveSession(
        status: FocusActiveSessionStatus.running,
        startedAt: startedAt,
        targetEndAt: targetEndAt,
        remainingSeconds: 10,
        durationSeconds: 10,
        target: target,
      ),
    );
    final notifications = _FakeFocusNotificationService();
    final timerFactory = _FakeTimerFactory();

    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 10,
      notificationService: notifications,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    expect(store.status, FocusStatus.running);
    expect(store.remainingSeconds, 6);
    expect(store.selectedDurationSeconds, 10);
    expect(store.activeDurationSeconds, 10);
    expect(store.currentTarget?.taskId, 'task-1');
    expect(store.currentTarget?.title, '写产品说明');
    expect(timerFactory.records.length, 1);
    expect(notifications.runningShows, 1);
    expect(notifications.scheduledTargetEndAt, targetEndAt);

    fakeNow = fakeNow.add(const Duration(seconds: 2));
    timerFactory.records.single.tick();

    expect(store.remainingSeconds, 4);
  });

  test('paused session restores without starting a timer', () async {
    final fakeNow = DateTime.utc(2026, 4, 24, 9);
    const target = FocusTargetSnapshot(
      taskId: 'task-2',
      title: '整理大纲',
      context: '目标 / 项目 / 子项目',
    );
    final storage = _FakeFocusStorage(
      activeSession: FocusActiveSession(
        status: FocusActiveSessionStatus.paused,
        startedAt: fakeNow.subtract(const Duration(seconds: 4)),
        targetEndAt: null,
        remainingSeconds: 6,
        durationSeconds: 10,
        target: target,
      ),
    );
    final notifications = _FakeFocusNotificationService();
    final timerFactory = _FakeTimerFactory();

    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 10,
      notificationService: notifications,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    expect(store.status, FocusStatus.paused);
    expect(store.remainingSeconds, 6);
    expect(store.selectedDurationSeconds, 10);
    expect(store.activeDurationSeconds, 10);
    expect(store.currentTarget?.taskId, 'task-2');
    expect(store.currentTarget?.context, '目标 / 项目 / 子项目');
    expect(timerFactory.records, isEmpty);
    expect(notifications.completionCancelCalls, 1);
    expect(notifications.pausedShows, 1);
  });

  test(
    'elapsed running session records once and clears active state',
    () async {
      final targetEndAt = DateTime.utc(2026, 4, 24, 9, 0, 10);
      const target = FocusTargetSnapshot(
        taskId: 'task-3',
        title: '完成草稿',
        context: '目标 / 项目',
      );
      final storage = _FakeFocusStorage(
        activeSession: FocusActiveSession(
          status: FocusActiveSessionStatus.running,
          startedAt: DateTime.utc(2026, 4, 24, 9),
          targetEndAt: targetEndAt,
          remainingSeconds: 10,
          durationSeconds: 10,
          target: target,
        ),
      );
      final notifications = _FakeFocusNotificationService();

      final firstStore = await FocusStore.load(
        storage,
        defaultDurationSeconds: 10,
        notificationService: notifications,
        nowProvider: () => DateTime.utc(2026, 4, 24, 9, 0, 20),
      );

      expect(firstStore.status, FocusStatus.idle);
      expect(firstStore.remainingSeconds, 10);
      expect(firstStore.completedSessionCount, 1);
      expect(firstStore.sessions.single.completedAt, targetEndAt);
      expect(firstStore.sessions.single.target?.taskId, 'task-3');
      expect(firstStore.sessions.single.target?.title, '完成草稿');
      expect(storage.activeSession, isNull);
      expect(storage.clearActiveCalls, 1);
      expect(storage.saveHistoryCalls, 1);

      final secondStore = await FocusStore.load(
        storage,
        defaultDurationSeconds: 10,
        notificationService: notifications,
        nowProvider: () => DateTime.utc(2026, 4, 24, 9, 0, 30),
      );

      expect(secondStore.completedSessionCount, 1);
      expect(storage.saveHistoryCalls, 1);
    },
  );

  test('pause and reset do not record sessions', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 9);
    final storage = _FakeFocusStorage();
    final timerFactory = _FakeTimerFactory();
    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 3,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    store.start();
    fakeNow = fakeNow.add(const Duration(seconds: 4));
    store.pause();
    await _flushAsync();

    expect(store.completedSessionCount, 0);
    expect(storage.saveHistoryCalls, 0);

    store.start();
    fakeNow = fakeNow.add(const Duration(seconds: 1));
    store.reset();
    timerFactory.records.last.tick();
    await _flushAsync();

    expect(store.completedSessionCount, 0);
    expect(storage.saveHistoryCalls, 0);
  });

  test('completed history stores the selected round duration', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 9);
    final storage = _FakeFocusStorage();
    final timerFactory = _FakeTimerFactory();
    final store = await FocusStore.load(
      storage,
      notificationService: _FakeFocusNotificationService(),
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    store.selectDuration(5 * 60);
    store.start();

    fakeNow = fakeNow.add(const Duration(minutes: 5));
    timerFactory.records.single.tick();
    store.selectDuration(15 * 60);
    await _flushAsync();

    expect(store.completedSessionCount, 1);
    expect(store.sessions.single.durationSeconds, 5 * 60);
    expect(storage.lastSavedSessions!.single.durationSeconds, 5 * 60);
  });

  test('completed history stores selected target snapshot', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 9);
    const target = FocusTargetSnapshot(
      taskId: 'task-4',
      title: '复核计划',
      context: '目标 / 项目 / 子项目',
    );
    final storage = _FakeFocusStorage();
    final timerFactory = _FakeTimerFactory();
    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 3,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    store.selectTarget(target);
    store.start();

    fakeNow = fakeNow.add(const Duration(seconds: 3));
    timerFactory.records.single.tick();
    await _flushAsync();

    expect(store.completedSessionCount, 1);
    expect(store.sessions.single.target?.taskId, 'task-4');
    expect(store.sessions.single.target?.title, '复核计划');
    expect(store.sessions.single.target?.context, '目标 / 项目 / 子项目');
    expect(storage.lastSavedSessions!.single.target?.taskId, 'task-4');
  });

  test(
    'local storage persists active and completed target snapshots',
    () async {
      const target = FocusTargetSnapshot(
        taskId: 'task-5',
        title: '推进行动',
        context: '目标 / 项目',
      );
      final keyValueStore = _FakeFocusKeyValueStore();
      final storage = FocusLocalStorage(store: keyValueStore);
      final startedAt = DateTime.utc(2026, 4, 24, 9);
      final targetEndAt = DateTime.utc(2026, 4, 24, 9, 25);

      await storage.saveActiveSession(
        FocusActiveSession(
          status: FocusActiveSessionStatus.running,
          startedAt: startedAt,
          targetEndAt: targetEndAt,
          remainingSeconds: 1500,
          durationSeconds: 1500,
          target: target,
        ),
      );

      final activePayload =
          jsonDecode(keyValueStore.values[FocusLocalStorage.activeStorageKey]!)
              as Map<String, dynamic>;
      expect(activePayload['target']['taskId'], 'task-5');
      expect(activePayload['target']['title'], '推进行动');

      final loadedActiveSession = await storage.loadActiveSession();
      expect(loadedActiveSession?.target?.context, '目标 / 项目');

      await storage.saveSessions([
        FocusSessionItem(
          id: 'focus-session-1',
          completedAt: targetEndAt,
          durationSeconds: 1500,
          target: target,
        ),
      ]);

      final historyPayload =
          jsonDecode(keyValueStore.values[FocusLocalStorage.storageKey]!)
              as List<dynamic>;
      expect(historyPayload.single['target']['taskId'], 'task-5');

      final loadedSessions = await storage.loadSessions();
      expect(loadedSessions.single.target?.title, '推进行动');
    },
  );

  test('reset clears active state and notifications', () async {
    final storage = _FakeFocusStorage();
    final notifications = _FakeFocusNotificationService();
    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 10,
      notificationService: notifications,
      nowProvider: () => DateTime.utc(2026, 4, 24, 9),
      timerFactory: _FakeTimerFactory().call,
    );

    store.start();
    await _flushAsync();

    expect(storage.activeSession, isNotNull);
    expect(notifications.runningShows, 1);
    expect(notifications.scheduleCalls, 1);

    store.reset();
    await _flushAsync();

    expect(storage.activeSession, isNull);
    expect(storage.clearActiveCalls, 1);
    expect(notifications.clearAllCalls, 1);
  });

  test('notification schedule and cancel follows focus lifecycle', () async {
    var fakeNow = DateTime.utc(2026, 4, 24, 9);
    final storage = _FakeFocusStorage();
    final notifications = _FakeFocusNotificationService();
    final store = await FocusStore.load(
      storage,
      defaultDurationSeconds: 10,
      notificationService: notifications,
      nowProvider: () => fakeNow,
      timerFactory: _FakeTimerFactory().call,
    );

    store.start();
    await _flushAsync();

    expect(notifications.runningShows, 1);
    expect(notifications.scheduleCalls, 1);
    expect(
      notifications.scheduledTargetEndAt,
      fakeNow.add(const Duration(seconds: 10)),
    );

    fakeNow = fakeNow.add(const Duration(seconds: 4));
    store.pause();
    await _flushAsync();

    expect(notifications.completionCancelCalls, 1);
    expect(notifications.pausedShows, 1);

    store.start();
    await _flushAsync();

    expect(notifications.runningShows, 2);
    expect(notifications.scheduleCalls, 2);

    store.reset();
    await _flushAsync();

    expect(notifications.clearAllCalls, 1);
  });

  test('notification target timing uses selected custom duration', () async {
    final fakeNow = DateTime.utc(2026, 4, 24, 9);
    final notifications = _FakeFocusNotificationService();
    final store = await FocusStore.load(
      _FakeFocusStorage(),
      notificationService: notifications,
      nowProvider: () => fakeNow,
      timerFactory: _FakeTimerFactory().call,
    );

    store.selectDuration(37 * 60);
    store.start();
    await _flushAsync();

    expect(
      notifications.scheduledTargetEndAt,
      fakeNow.add(const Duration(minutes: 37)),
    );
  });

  test('selected duration persists and restores', () async {
    final storage = _FakeFocusStorage();
    final firstStore = await FocusStore.load(storage);

    firstStore.selectDuration(37 * 60);
    await _flushAsync();

    final secondStore = await FocusStore.load(storage);

    expect(secondStore.selectedDurationSeconds, 37 * 60);
    expect(secondStore.activeDurationSeconds, 37 * 60);
    expect(secondStore.remainingSeconds, 37 * 60);
  });

  test(
    'invalid persisted selected duration falls back to 25 minutes',
    () async {
      final storage = _FakeFocusStorage(selectedDurationSeconds: 181 * 60);

      final store = await FocusStore.load(storage);

      expect(store.selectedDurationSeconds, 25 * 60);
      expect(store.activeDurationSeconds, 25 * 60);
      expect(store.remainingSeconds, 25 * 60);
    },
  );

  test(
    'malformed local history and active data fall back safely to empty state',
    () async {
      final keyValueStore = _FakeFocusKeyValueStore(
        values: {
          FocusLocalStorage.storageKey: '{not valid json',
          FocusLocalStorage.selectedDurationStorageKey: 'not a duration',
          FocusLocalStorage.activeStorageKey: jsonEncode({
            'status': 'running',
            'startedAt': 'not a date',
            'targetEndAt': null,
            'remainingSeconds': 'bad',
            'durationSeconds': 10,
          }),
        },
      );
      final storage = FocusLocalStorage(store: keyValueStore);

      final store = await FocusStore.load(storage);

      expect(store.completedSessionCount, 0);
      expect(store.sessions, isEmpty);
      expect(store.status, FocusStatus.idle);
      expect(store.selectedDurationSeconds, 25 * 60);
    },
  );

  test(
    'malformed active target data is ignored without breaking restore',
    () async {
      final keyValueStore = _FakeFocusKeyValueStore(
        values: {
          FocusLocalStorage.activeStorageKey: jsonEncode({
            'status': 'paused',
            'startedAt': DateTime.utc(2026, 4, 24, 9).toIso8601String(),
            'targetEndAt': null,
            'remainingSeconds': 60,
            'durationSeconds': 120,
            'target': {'taskId': '', 'title': 7, 'context': null},
          }),
        },
      );
      final storage = FocusLocalStorage(store: keyValueStore);

      final store = await FocusStore.load(storage);

      expect(store.status, FocusStatus.paused);
      expect(store.remainingSeconds, 60);
      expect(store.currentTarget, isNull);
    },
  );

  test('old focus history without target still loads safely', () async {
    final completedAt = DateTime.utc(2026, 4, 24, 9);
    final keyValueStore = _FakeFocusKeyValueStore(
      values: {
        FocusLocalStorage.storageKey: jsonEncode([
          {
            'id': 'focus-session-1',
            'completedAt': completedAt.toIso8601String(),
            'durationSeconds': 1500,
          },
        ]),
      },
    );
    final storage = FocusLocalStorage(store: keyValueStore);

    final store = await FocusStore.load(storage);

    expect(store.completedSessionCount, 1);
    expect(store.sessions.single.target, isNull);
  });

  test(
    'focus history is saved newest first and capped to 100 sessions',
    () async {
      final keyValueStore = _FakeFocusKeyValueStore();
      final storage = FocusLocalStorage(store: keyValueStore);
      final baseTime = DateTime.utc(2026, 4, 24);
      final sessions = List<FocusSessionItem>.generate(105, (index) {
        return FocusSessionItem(
          id: 'focus-session-$index',
          completedAt: baseTime.add(Duration(minutes: index)),
          durationSeconds: 1500,
        );
      });

      await storage.saveSessions(sessions);

      final payload =
          jsonDecode(keyValueStore.values[FocusLocalStorage.storageKey]!)
              as List<dynamic>;
      expect(payload.length, FocusLocalStorage.maxSessions);
      expect(payload.first['id'], 'focus-session-104');
      expect(payload.last['id'], 'focus-session-5');
      expect(
        payload.first['completedAt'],
        baseTime.add(const Duration(minutes: 104)).toIso8601String(),
      );

      final loadedSessions = await storage.loadSessions();
      expect(loadedSessions.length, FocusLocalStorage.maxSessions);
      expect(loadedSessions.first.id, 'focus-session-104');
      expect(loadedSessions.last.id, 'focus-session-5');
    },
  );
}

Future<void> _flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeFocusStorage implements FocusStorage {
  _FakeFocusStorage({
    List<FocusSessionItem>? storedSessions,
    FocusActiveSession? activeSession,
    int? selectedDurationSeconds,
  }) : _storedSessions = storedSessions
           ?.map((session) => session.copyWith())
           .toList(growable: false),
       _activeSession = activeSession,
       _selectedDurationSeconds = selectedDurationSeconds;

  List<FocusSessionItem>? _storedSessions;
  FocusActiveSession? _activeSession;
  int? _selectedDurationSeconds;
  int saveHistoryCalls = 0;
  int saveActiveCalls = 0;
  int saveSelectedDurationCalls = 0;
  int clearActiveCalls = 0;

  List<FocusSessionItem>? get lastSavedSessions => _storedSessions
      ?.map((session) => session.copyWith())
      .toList(growable: false);

  FocusActiveSession? get activeSession => _activeSession;

  @override
  Future<List<FocusSessionItem>> loadSessions() async {
    return lastSavedSessions ?? const <FocusSessionItem>[];
  }

  @override
  Future<void> saveSessions(List<FocusSessionItem> sessions) async {
    saveHistoryCalls += 1;
    _storedSessions = sessions
        .map((session) => session.copyWith())
        .toList(growable: false);
  }

  @override
  Future<int?> loadSelectedDurationSeconds() async {
    return _selectedDurationSeconds;
  }

  @override
  Future<void> saveSelectedDurationSeconds(int durationSeconds) async {
    saveSelectedDurationCalls += 1;
    _selectedDurationSeconds = durationSeconds;
  }

  @override
  Future<FocusActiveSession?> loadActiveSession() async {
    return _activeSession;
  }

  @override
  Future<void> saveActiveSession(FocusActiveSession session) async {
    saveActiveCalls += 1;
    _activeSession = session;
  }

  @override
  Future<void> clearActiveSession() async {
    clearActiveCalls += 1;
    _activeSession = null;
  }
}

class _FakeFocusNotificationService implements FocusNotificationService {
  int runningShows = 0;
  int pausedShows = 0;
  int scheduleCalls = 0;
  int completionCancelCalls = 0;
  int clearAllCalls = 0;
  DateTime? scheduledTargetEndAt;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showRunning({
    required int remainingSeconds,
    required DateTime targetEndAt,
  }) async {
    runningShows += 1;
  }

  @override
  Future<void> showPaused({required int remainingSeconds}) async {
    pausedShows += 1;
  }

  @override
  Future<void> scheduleCompletionReminder({
    required DateTime targetEndAt,
  }) async {
    scheduleCalls += 1;
    scheduledTargetEndAt = targetEndAt;
  }

  @override
  Future<void> cancelActiveNotification() async {}

  @override
  Future<void> cancelCompletionReminder() async {
    completionCancelCalls += 1;
  }

  @override
  Future<void> clearFocusNotifications() async {
    clearAllCalls += 1;
  }
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

class _FakeFocusKeyValueStore implements FocusKeyValueStore {
  _FakeFocusKeyValueStore({Map<String, String>? values})
    : values = values ?? <String, String>{};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async {
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}
