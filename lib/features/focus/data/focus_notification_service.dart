import 'package:flutter/foundation.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';

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

/// Schedules only the completion event. The running countdown remains an
/// in-app concern reconstructed from FocusStore's persisted end timestamp.
class FocusLocalNotificationService implements FocusNotificationService {
  FocusLocalNotificationService({
    AppLocalNotificationService? appNotificationService,
    DateTime Function()? nowProvider,
  }) : _appNotifications =
           appNotificationService ?? AppLocalNotificationService(),
       _nowProvider = nowProvider ?? DateTime.now;

  static const activeNotificationId = 4101;
  static const legacyCompletionReminderId = 4102;
  static const _completionIdBase = 1500000000;
  static const _completionIdRange = 400000000;

  final AppLocalNotificationService _appNotifications;
  final DateTime Function() _nowProvider;
  Future<void> _operationTail = Future<void>.value();
  DateTime? _desiredTargetEndAt;
  int _desiredBaselineRevision = 0;
  bool _desiredOperationFailed = false;
  final List<int> _dueCleanupPreserveIds = <int>[];

  @override
  Future<void> initialize() => _appNotifications.initialize();

  @override
  Future<void> showRunning({
    required int remainingSeconds,
    required DateTime targetEndAt,
  }) async {
    final normalizedTarget = targetEndAt.toUtc();
    final previousTarget = _desiredTargetEndAt;
    if (previousTarget != null &&
        !previousTarget.isAtSameMomentAs(normalizedTarget) &&
        !_nowProvider().toUtc().isBefore(previousTarget)) {
      final previousId = completionReminderIdForTarget(previousTarget);
      if (!_dueCleanupPreserveIds.contains(previousId)) {
        _dueCleanupPreserveIds.add(previousId);
      }
    }
    _desiredTargetEndAt = normalizedTarget;
    _desiredBaselineRevision = _appNotifications.schedulingErrorRevision;
    _desiredOperationFailed = false;

    // Remove a stale notification left by versions that displayed an ongoing
    // drawer countdown. No foreground service or replacement is created.
    await _enqueue(() async {
      final result = await _appNotifications.cancel(activeNotificationId);
      if (_isDesiredTarget(normalizedTarget) && !result.isCompleted) {
        _desiredOperationFailed = true;
      }
    });
  }

  @override
  Future<void> showPaused({required int remainingSeconds}) async {
    _desiredTargetEndAt = null;
    await _enqueue(() async {
      await _appNotifications.cancel(activeNotificationId);
    });
  }

  @override
  Future<void> scheduleCompletionReminder({
    required DateTime targetEndAt,
  }) async {
    final normalizedTarget = targetEndAt.toUtc();
    if (!_isDesiredTarget(normalizedTarget)) {
      return;
    }

    await _enqueue(() async {
      if (!_isDesiredTarget(normalizedTarget)) {
        return;
      }

      final payload = AppNotificationPayload(
        type: AppNotificationType.focusCompletion,
        entityId: 'focus-${normalizedTarget.millisecondsSinceEpoch}',
        route: AppNotificationPayload.focusRoute,
      );
      final result = await _appNotifications.scheduleFocusCompletion(
        id: completionReminderIdForTarget(normalizedTarget),
        targetEndAt: normalizedTarget,
        payload: payload.encode(),
      );
      if (!_isDesiredTarget(normalizedTarget)) {
        return;
      }
      if (!result.isCompleted) {
        _desiredOperationFailed = true;
      }
      final currentId = completionReminderIdForTarget(normalizedTarget);
      final reconciled = await _cancelCompletionRequests(
        preserveIds: <int>{currentId, ..._dueCleanupPreserveIds},
      );
      if (!reconciled) {
        _desiredOperationFailed = true;
      }
      if (!_desiredOperationFailed) {
        _appNotifications.markSchedulingHealthy(_desiredBaselineRevision);
      }
    });
  }

  @override
  Future<void> cancelActiveNotification() async {
    await _enqueue(() async {
      await _appNotifications.cancel(activeNotificationId);
    });
  }

  @override
  Future<void> cancelCompletionReminder() async {
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final target = _desiredTargetEndAt;
    _desiredTargetEndAt = null;
    _dueCleanupPreserveIds.clear();
    await _enqueue(() async {
      final completedWithoutError = await _cancelCompletionRequests(
        explicitIds: <int>{
          if (target != null) completionReminderIdForTarget(target),
        },
      );
      if (completedWithoutError) {
        _appNotifications.markSchedulingHealthy(baselineRevision);
      }
    });
  }

  @override
  Future<void> clearFocusNotifications() async {
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final target = _desiredTargetEndAt;
    final now = _nowProvider().toUtc();
    if (target != null &&
        now.isBefore(target) &&
        _dueCleanupPreserveIds.isNotEmpty) {
      _dueCleanupPreserveIds.removeAt(0);
      await _enqueue(() async {
        await _appNotifications.cancel(activeNotificationId);
      });
      return;
    }

    final preserveId = target != null && !now.isBefore(target)
        ? completionReminderIdForTarget(target)
        : null;
    _desiredTargetEndAt = null;
    _dueCleanupPreserveIds.clear();

    await _enqueue(() async {
      var completedWithoutError = true;
      final activeResult = await _appNotifications.cancel(activeNotificationId);
      completedWithoutError &= activeResult.isCompleted;
      completedWithoutError &= await _cancelCompletionRequests(
        preserveIds: <int>{?preserveId},
        explicitIds: <int>{
          if (target != null && preserveId == null)
            completionReminderIdForTarget(target),
        },
      );
      if (completedWithoutError) {
        _appNotifications.markSchedulingHealthy(baselineRevision);
      }
    });
    // At/after the target, leave that round's completion alarm intact. Each
    // round has a target-derived ID, so a new round cannot be cancelled by
    // cleanup from the previous one.
  }

  @visibleForTesting
  static int completionReminderIdForTarget(DateTime targetEndAt) {
    final entityId = 'focus-${targetEndAt.toUtc().millisecondsSinceEpoch}';
    return _completionIdBase + (_stableHash(entityId) % _completionIdRange);
  }

  Future<bool> _cancelCompletionRequests({
    Set<int> preserveIds = const <int>{},
    Set<int> explicitIds = const <int>{},
  }) async {
    final baselineRevision = _appNotifications.schedulingErrorRevision;
    final pending = await _appNotifications.pendingRequests(
      recordSchedulingFailure: true,
    );
    var completedWithoutError =
        _appNotifications.schedulingErrorRevision == baselineRevision;
    final idsToCancel = <int>{legacyCompletionReminderId, ...explicitIds};

    for (final request in pending) {
      final payload = AppNotificationPayload.tryParse(request.payload);
      final isOwnedFocusRequest =
          payload?.type == AppNotificationType.focusCompletion ||
          request.id == legacyCompletionReminderId ||
          (request.id >= _completionIdBase &&
              request.id < _completionIdBase + _completionIdRange);
      if (isOwnedFocusRequest) {
        idsToCancel.add(request.id);
      }
    }
    idsToCancel.removeAll(preserveIds);

    for (final id in idsToCancel) {
      final result = await _appNotifications.cancel(id);
      completedWithoutError &= result.isCompleted;
    }
    return completedWithoutError;
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _operationTail.then((_) => operation());
    _operationTail = next.catchError((Object _) {});
    return next;
  }

  bool _isDesiredTarget(DateTime target) {
    final desired = _desiredTargetEndAt;
    return desired != null && desired.isAtSameMomentAs(target);
  }

  static int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}
