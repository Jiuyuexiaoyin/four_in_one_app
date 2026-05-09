import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:four_in_one_app/features/focus/data/focus_local_storage.dart';
import 'package:four_in_one_app/features/focus/data/focus_notification_service.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_active_session.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';

enum FocusStatus { idle, running, paused }

typedef FocusNowProvider = DateTime Function();
typedef FocusPeriodicTimerFactory =
    FocusTimerHandle Function(Duration interval, VoidCallback onTick);

abstract interface class FocusTimerHandle {
  void cancel();
}

class FocusStore extends ChangeNotifier {
  FocusStore._({
    required this.defaultDurationSeconds,
    required FocusStorage storage,
    required FocusNotificationService notificationService,
    required List<FocusSessionItem> initialSessions,
    required FocusActiveSession? initialActiveSession,
    required int initialSelectedDurationSeconds,
    required int nextSessionId,
    required FocusNowProvider nowProvider,
    required FocusPeriodicTimerFactory timerFactory,
  }) : _storage = storage,
       _notificationService = notificationService,
       _sessions = List<FocusSessionItem>.of(initialSessions),
       _nextSessionId = nextSessionId,
       _nowProvider = nowProvider,
       _timerFactory = timerFactory,
       _remainingSeconds = initialSelectedDurationSeconds,
       _selectedDurationSeconds = initialSelectedDurationSeconds,
       _activeDurationSeconds = initialSelectedDurationSeconds {
    _normalizeSessions();
    _restoreActiveSession(initialActiveSession);
  }

  static const durationChoicesSeconds = <int>[
    5 * 60,
    15 * 60,
    25 * 60,
    45 * 60,
  ];
  static const minDurationMinutes = 1;
  static const maxDurationMinutes = 180;

  static Future<FocusStore> load(
    FocusStorage storage, {
    int defaultDurationSeconds = 25 * 60,
    FocusNotificationService? notificationService,
    FocusNowProvider? nowProvider,
    FocusPeriodicTimerFactory? timerFactory,
  }) async {
    final effectiveNowProvider = nowProvider ?? DateTime.now;
    final effectiveNotificationService =
        notificationService ?? NoopFocusNotificationService();
    var savedSessions = await _loadSessionsSafely(storage);
    final savedSelectedDurationSeconds = await _loadSelectedDurationSafely(
      storage,
      defaultDurationSeconds,
    );
    var savedActiveSession = await _loadActiveSessionSafely(storage);
    var nextSessionId = _deriveNextSessionId(savedSessions);

    if (savedActiveSession != null) {
      final elapsedSession = _completedSessionFromElapsedActiveSession(
        activeSession: savedActiveSession,
        now: effectiveNowProvider(),
        nextSessionId: nextSessionId,
      );

      if (elapsedSession != null) {
        nextSessionId += 1;
        savedActiveSession = null;
        await _clearActiveSessionSafely(storage);
        savedSessions = FocusLocalStorage.normalizeSessions([
          elapsedSession,
          ...savedSessions,
        ]);
        await _saveSessionsSafely(storage, savedSessions);
        await _clearNotificationsSafely(effectiveNotificationService);
      }
    }

    final store = FocusStore._(
      defaultDurationSeconds: defaultDurationSeconds,
      storage: storage,
      notificationService: effectiveNotificationService,
      initialSessions: savedSessions,
      initialActiveSession: savedActiveSession,
      initialSelectedDurationSeconds: savedSelectedDurationSeconds,
      nextSessionId: nextSessionId,
      nowProvider: effectiveNowProvider,
      timerFactory: timerFactory ?? _createSystemPeriodicTimer,
    );

    await store._syncRestoredNotificationState();

    return store;
  }

  factory FocusStore.inMemory({
    int defaultDurationSeconds = 25 * 60,
    List<FocusSessionItem>? initialSessions,
    FocusActiveSession? initialActiveSession,
    int? initialSelectedDurationSeconds,
    FocusNotificationService? notificationService,
    FocusNowProvider? nowProvider,
    FocusPeriodicTimerFactory? timerFactory,
  }) {
    final sessions = List<FocusSessionItem>.of(
      initialSessions ?? const <FocusSessionItem>[],
    );

    return FocusStore._(
      defaultDurationSeconds: defaultDurationSeconds,
      storage: _InMemoryFocusStorage(),
      notificationService:
          notificationService ?? NoopFocusNotificationService(),
      initialSessions: sessions,
      initialActiveSession: initialActiveSession,
      initialSelectedDurationSeconds:
          initialSelectedDurationSeconds ?? defaultDurationSeconds,
      nextSessionId: _deriveNextSessionId(sessions),
      nowProvider: nowProvider ?? DateTime.now,
      timerFactory: timerFactory ?? _createSystemPeriodicTimer,
    );
  }

  final int defaultDurationSeconds;
  final FocusStorage _storage;
  final FocusNotificationService _notificationService;
  final List<FocusSessionItem> _sessions;
  final FocusNowProvider _nowProvider;
  final FocusPeriodicTimerFactory _timerFactory;

  FocusStatus _status = FocusStatus.idle;
  int _remainingSeconds;
  int _selectedDurationSeconds;
  int _activeDurationSeconds;
  int _nextSessionId;
  DateTime? _startedAt;
  DateTime? _targetEndTime;
  FocusTargetSnapshot? _selectedTarget;
  FocusTargetSnapshot? _activeTarget;
  FocusTimerHandle? _timerHandle;

  FocusStatus get status => _status;
  int get remainingSeconds => _remainingSeconds;
  int get selectedDurationSeconds => _selectedDurationSeconds;
  int get activeDurationSeconds => _activeDurationSeconds;
  bool get hasCustomSelectedDuration =>
      !durationChoicesSeconds.contains(_selectedDurationSeconds);

  UnmodifiableListView<FocusSessionItem> get sessions {
    return UnmodifiableListView(_sessions);
  }

  int get completedSessionCount => _sessions.length;
  FocusTargetSnapshot? get selectedTarget => _selectedTarget;
  FocusTargetSnapshot? get activeTarget => _activeTarget;
  FocusTargetSnapshot? get currentTarget =>
      isIdle ? _selectedTarget : _activeTarget;

  bool get isIdle => _status == FocusStatus.idle;
  bool get isRunning => _status == FocusStatus.running;
  bool get isPaused => _status == FocusStatus.paused;

  bool get canStart => !isRunning;
  bool get canPause => isRunning;
  bool get canReset =>
      _remainingSeconds != _selectedDurationSeconds ||
      _status != FocusStatus.idle;

  String get formattedRemaining {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void selectDuration(int durationSeconds) {
    if (!isIdle ||
        _selectedDurationSeconds == durationSeconds ||
        !isValidDurationSeconds(durationSeconds)) {
      return;
    }

    _selectedDurationSeconds = durationSeconds;
    _activeDurationSeconds = durationSeconds;
    _remainingSeconds = durationSeconds;
    notifyListeners();

    unawaited(_persistSelectedDurationSnapshot());
  }

  void selectTarget(FocusTargetSnapshot target) {
    if (!isIdle) {
      return;
    }

    _selectedTarget = target;
    notifyListeners();
  }

  void clearSelectedTarget() {
    if (!isIdle || _selectedTarget == null) {
      return;
    }

    _selectedTarget = null;
    notifyListeners();
  }

  void start() {
    if (isRunning) {
      return;
    }

    if (isIdle && _remainingSeconds == 0) {
      _remainingSeconds = _selectedDurationSeconds;
    }

    if (isIdle) {
      _activeDurationSeconds = _remainingSeconds;
      _activeTarget = _selectedTarget;
    }

    _startedAt ??= _nowProvider().toUtc();
    _targetEndTime = _nowProvider()
        .add(Duration(seconds: _remainingSeconds))
        .toUtc();
    _status = FocusStatus.running;
    _cancelTimer();
    _timerHandle = _timerFactory(const Duration(seconds: 1), _handleTick);
    notifyListeners();

    unawaited(_persistActiveSnapshot());
    unawaited(_syncRunningNotifications());
  }

  void pause() {
    if (!isRunning) {
      return;
    }

    final computedRemaining = _computeRemainingSeconds();
    if (computedRemaining == 0) {
      _finishCountdown(recordSession: false);
      return;
    }

    _remainingSeconds = computedRemaining;
    _status = FocusStatus.paused;
    _targetEndTime = null;
    _cancelTimer();
    notifyListeners();

    unawaited(_persistActiveSnapshot());
    unawaited(_syncPausedNotifications());
  }

  void reset() {
    _cancelTimer();
    _startedAt = null;
    _targetEndTime = null;
    _activeDurationSeconds = _selectedDurationSeconds;
    _remainingSeconds = _selectedDurationSeconds;
    _activeTarget = null;
    _status = FocusStatus.idle;
    notifyListeners();

    unawaited(_clearActiveSnapshot());
    unawaited(_clearFocusNotifications());
  }

  void _restoreActiveSession(FocusActiveSession? activeSession) {
    if (activeSession == null) {
      return;
    }

    _startedAt = activeSession.startedAt.toUtc();
    _activeDurationSeconds = activeSession.durationSeconds;
    _selectedDurationSeconds = activeSession.durationSeconds;
    _activeTarget = activeSession.target;
    _selectedTarget = activeSession.target;

    switch (activeSession.status) {
      case FocusActiveSessionStatus.running:
        _targetEndTime = activeSession.targetEndAt?.toUtc();
        _status = FocusStatus.running;
        _remainingSeconds = _computeRemainingSeconds();
        if (_remainingSeconds == 0) {
          _status = FocusStatus.idle;
          _targetEndTime = null;
          _startedAt = null;
          return;
        }
        _timerHandle = _timerFactory(const Duration(seconds: 1), _handleTick);
      case FocusActiveSessionStatus.paused:
        _targetEndTime = null;
        _remainingSeconds = activeSession.remainingSeconds;
        _status = FocusStatus.paused;
    }
  }

  void _handleTick() {
    if (!isRunning || _targetEndTime == null) {
      return;
    }

    final computedRemaining = _computeRemainingSeconds();
    if (computedRemaining == 0) {
      _finishCountdown(recordSession: true);
      return;
    }

    if (computedRemaining == _remainingSeconds) {
      return;
    }

    _remainingSeconds = computedRemaining;
    notifyListeners();
  }

  int _computeRemainingSeconds() {
    final targetEndTime = _targetEndTime;
    if (targetEndTime == null) {
      return _remainingSeconds;
    }

    final differenceMs = targetEndTime
        .difference(_nowProvider().toUtc())
        .inMilliseconds;
    if (differenceMs <= 0) {
      return 0;
    }

    return (differenceMs / 1000).ceil();
  }

  void _finishCountdown({required bool recordSession}) {
    final completedAt = _targetEndTime;
    final completedDurationSeconds = _activeDurationSeconds;
    final completedTarget = _activeTarget;

    _cancelTimer();
    _startedAt = null;
    _targetEndTime = null;
    _activeTarget = null;
    _remainingSeconds = 0;
    _status = FocusStatus.idle;
    notifyListeners();

    unawaited(
      _completeFinishedRound(
        recordSession: recordSession,
        completedAt: completedAt,
        durationSeconds: completedDurationSeconds,
        target: completedTarget,
      ),
    );
  }

  Future<void> _completeFinishedRound({
    required bool recordSession,
    required DateTime? completedAt,
    required int durationSeconds,
    required FocusTargetSnapshot? target,
  }) async {
    await _clearActiveSnapshot();
    await _clearFocusNotifications();

    if (recordSession && completedAt != null) {
      await _recordCompletedSession(completedAt, durationSeconds, target);
    }
  }

  Future<void> _recordCompletedSession(
    DateTime completedAt,
    int durationSeconds,
    FocusTargetSnapshot? target,
  ) async {
    _sessions.insert(
      0,
      FocusSessionItem(
        id: 'focus-session-${_nextSessionId++}',
        completedAt: completedAt.toUtc(),
        durationSeconds: durationSeconds,
        target: target,
      ),
    );
    _normalizeSessions();
    notifyListeners();

    await _persistHistorySnapshot();
  }

  Future<void> _persistHistorySnapshot() async {
    final snapshot = List<FocusSessionItem>.of(_sessions);

    try {
      await _storage.saveSessions(snapshot);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription('while persisting focus history locally'),
        ),
      );
    }
  }

  Future<void> _persistActiveSnapshot() async {
    final activeSession = _buildActiveSession();
    if (activeSession == null) {
      await _clearActiveSnapshot();
      return;
    }

    try {
      await _storage.saveActiveSession(activeSession);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription(
            'while persisting active focus session locally',
          ),
        ),
      );
    }
  }

  Future<void> _persistSelectedDurationSnapshot() async {
    try {
      await _storage.saveSelectedDurationSeconds(_selectedDurationSeconds);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription(
            'while persisting selected focus duration locally',
          ),
        ),
      );
    }
  }

  Future<void> _clearActiveSnapshot() async {
    try {
      await _storage.clearActiveSession();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription('while clearing active focus session'),
        ),
      );
    }
  }

  FocusActiveSession? _buildActiveSession() {
    final startedAt = _startedAt;
    if (startedAt == null) {
      return null;
    }

    if (isRunning && _targetEndTime != null) {
      return FocusActiveSession(
        status: FocusActiveSessionStatus.running,
        startedAt: startedAt,
        targetEndAt: _targetEndTime,
        remainingSeconds: _remainingSeconds,
        durationSeconds: _activeDurationSeconds,
        target: _activeTarget,
      );
    }

    if (isPaused) {
      return FocusActiveSession(
        status: FocusActiveSessionStatus.paused,
        startedAt: startedAt,
        targetEndAt: null,
        remainingSeconds: _remainingSeconds,
        durationSeconds: _activeDurationSeconds,
        target: _activeTarget,
      );
    }

    return null;
  }

  Future<void> _syncRestoredNotificationState() async {
    if (isRunning) {
      await _syncRunningNotifications();
      return;
    }

    if (isPaused) {
      await _syncPausedNotifications();
    }
  }

  Future<void> _syncRunningNotifications() async {
    final targetEndAt = _targetEndTime;
    if (targetEndAt == null) {
      return;
    }

    await _runNotificationSafely(() async {
      await _notificationService.showRunning(
        remainingSeconds: _remainingSeconds,
        targetEndAt: targetEndAt,
      );
      await _notificationService.scheduleCompletionReminder(
        targetEndAt: targetEndAt,
      );
    });
  }

  Future<void> _syncPausedNotifications() async {
    await _runNotificationSafely(() async {
      await _notificationService.cancelCompletionReminder();
      await _notificationService.showPaused(
        remainingSeconds: _remainingSeconds,
      );
    });
  }

  Future<void> _clearFocusNotifications() async {
    await _runNotificationSafely(_notificationService.clearFocusNotifications);
  }

  Future<void> _runNotificationSafely(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription('while updating focus notifications'),
        ),
      );
    }
  }

  void _normalizeSessions() {
    final normalizedSessions = FocusLocalStorage.normalizeSessions(_sessions);
    _sessions
      ..clear()
      ..addAll(normalizedSessions);
  }

  void _cancelTimer() {
    _timerHandle?.cancel();
    _timerHandle = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  static Future<List<FocusSessionItem>> _loadSessionsSafely(
    FocusStorage storage,
  ) async {
    try {
      return await storage.loadSessions();
    } catch (_) {
      return const <FocusSessionItem>[];
    }
  }

  static Future<FocusActiveSession?> _loadActiveSessionSafely(
    FocusStorage storage,
  ) async {
    try {
      return await storage.loadActiveSession();
    } catch (_) {
      return null;
    }
  }

  static Future<int> _loadSelectedDurationSafely(
    FocusStorage storage,
    int fallbackDurationSeconds,
  ) async {
    try {
      final selectedDurationSeconds = await storage
          .loadSelectedDurationSeconds();
      if (selectedDurationSeconds == null ||
          !isValidDurationSeconds(selectedDurationSeconds)) {
        return fallbackDurationSeconds;
      }

      return selectedDurationSeconds;
    } catch (_) {
      return fallbackDurationSeconds;
    }
  }

  static bool isValidDurationSeconds(int durationSeconds) {
    return durationSeconds >= minDurationMinutes * 60 &&
        durationSeconds <= maxDurationMinutes * 60 &&
        durationSeconds % 60 == 0;
  }

  static bool isValidDurationMinutes(int durationMinutes) {
    return durationMinutes >= minDurationMinutes &&
        durationMinutes <= maxDurationMinutes;
  }

  static FocusSessionItem? _completedSessionFromElapsedActiveSession({
    required FocusActiveSession activeSession,
    required DateTime now,
    required int nextSessionId,
  }) {
    if (activeSession.status != FocusActiveSessionStatus.running) {
      return null;
    }

    final targetEndAt = activeSession.targetEndAt;
    if (targetEndAt == null || targetEndAt.isAfter(now.toUtc())) {
      return null;
    }

    return FocusSessionItem(
      id: 'focus-session-$nextSessionId',
      completedAt: targetEndAt.toUtc(),
      durationSeconds: activeSession.durationSeconds,
      target: activeSession.target,
    );
  }

  static Future<void> _saveSessionsSafely(
    FocusStorage storage,
    List<FocusSessionItem> sessions,
  ) async {
    try {
      await storage.saveSessions(sessions);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'focus_store',
          context: ErrorDescription(
            'while persisting elapsed focus completion',
          ),
        ),
      );
    }
  }

  static Future<void> _clearActiveSessionSafely(FocusStorage storage) async {
    try {
      await storage.clearActiveSession();
    } catch (_) {
      // Startup must remain fail-safe even if clearing the stale active state
      // fails; the user should still reach the app.
    }
  }

  static Future<void> _clearNotificationsSafely(
    FocusNotificationService notificationService,
  ) async {
    try {
      await notificationService.clearFocusNotifications();
    } catch (_) {
      // Notification cleanup should never block app startup.
    }
  }

  static int _deriveNextSessionId(List<FocusSessionItem> sessions) {
    final matcher = RegExp(r'^focus-session-(\d+)$');

    final maxId = sessions.fold<int>(0, (currentMax, session) {
      final match = matcher.firstMatch(session.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static FocusTimerHandle _createSystemPeriodicTimer(
    Duration interval,
    VoidCallback onTick,
  ) {
    final timer = Timer.periodic(interval, (_) => onTick());
    return _SystemFocusTimerHandle(timer);
  }
}

class _InMemoryFocusStorage implements FocusStorage {
  @override
  Future<List<FocusSessionItem>> loadSessions() async {
    return const <FocusSessionItem>[];
  }

  @override
  Future<void> saveSessions(List<FocusSessionItem> sessions) async {}

  int? _selectedDurationSeconds;

  @override
  Future<int?> loadSelectedDurationSeconds() async {
    return _selectedDurationSeconds;
  }

  @override
  Future<void> saveSelectedDurationSeconds(int durationSeconds) async {
    _selectedDurationSeconds = durationSeconds;
  }

  @override
  Future<FocusActiveSession?> loadActiveSession() async {
    return null;
  }

  @override
  Future<void> saveActiveSession(FocusActiveSession session) async {}

  @override
  Future<void> clearActiveSession() async {}
}

class NoopFocusNotificationService implements FocusNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showRunning({
    required int remainingSeconds,
    required DateTime targetEndAt,
  }) async {}

  @override
  Future<void> showPaused({required int remainingSeconds}) async {}

  @override
  Future<void> scheduleCompletionReminder({
    required DateTime targetEndAt,
  }) async {}

  @override
  Future<void> cancelActiveNotification() async {}

  @override
  Future<void> cancelCompletionReminder() async {}

  @override
  Future<void> clearFocusNotifications() async {}
}

class _SystemFocusTimerHandle implements FocusTimerHandle {
  _SystemFocusTimerHandle(this._timer);

  final Timer _timer;

  @override
  void cancel() {
    _timer.cancel();
  }
}
