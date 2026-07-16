import 'dart:collection';

import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';

final class AppNotificationDestination {
  const AppNotificationDestination({
    required this.route,
    required this.entityId,
    required this.action,
  });

  final String route;
  final String entityId;
  final String? action;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppNotificationDestination &&
            other.route == route &&
            other.entityId == entityId &&
            other.action == action;
  }

  @override
  int get hashCode => Object.hash(route, entityId, action);
}

abstract final class AppNotificationRouter {
  static const reviewRoute = '/review';

  static AppNotificationDestination? resolve(
    AppNotificationPayload payload, {
    String? actionId,
  }) {
    final action = actionId ?? payload.action;
    if (!AppNotificationPayload.isActionAllowedForType(payload.type, action)) {
      return null;
    }

    final route = switch ((payload.type, action)) {
      (
        AppNotificationType.habitReminder,
        null || AppNotificationAction.habitOpen,
      ) =>
        AppNotificationPayload.habitsRoute,
      (AppNotificationType.focusCompletion, null) =>
        AppNotificationPayload.focusRoute,
      (
        AppNotificationType.focusCompletion,
        AppNotificationAction.focusViewRecords,
      ) =>
        reviewRoute,
      (AppNotificationType.test, null) => AppNotificationPayload.settingsRoute,
      _ => null,
    };

    if (route == null) {
      return null;
    }

    return AppNotificationDestination(
      route: route,
      entityId: payload.entityId,
      action: action,
    );
  }
}

final class NotificationResponseDeduplicator {
  NotificationResponseDeduplicator({
    Duration duplicateWindow = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _duplicateWindow = _requirePositiveWindow(duplicateWindow),
       _now = now ?? DateTime.now;

  final Duration _duplicateWindow;
  final DateTime Function() _now;
  final Queue<AppNotificationDestination> _initialDestinations = Queue();
  final Map<String, DateTime> _seenAt = <String, DateTime>{};

  int get pendingInitialCount => _initialDestinations.length;

  bool add(AppNotificationPayload payload, {String? actionId}) {
    final destination = AppNotificationRouter.resolve(
      payload,
      actionId: actionId,
    );
    if (destination == null || !_rememberIfNew(payload, actionId: actionId)) {
      return false;
    }

    _initialDestinations.add(destination);
    return true;
  }

  AppNotificationDestination? takeInitial() {
    if (_initialDestinations.isEmpty) {
      return null;
    }

    return _initialDestinations.removeFirst();
  }

  AppNotificationDestination? resolveOnce(
    AppNotificationPayload payload, {
    String? actionId,
  }) {
    final destination = AppNotificationRouter.resolve(
      payload,
      actionId: actionId,
    );
    if (destination == null || !_rememberIfNew(payload, actionId: actionId)) {
      return null;
    }

    return destination;
  }

  void clear() {
    _initialDestinations.clear();
    _seenAt.clear();
  }

  bool _rememberIfNew(
    AppNotificationPayload payload, {
    required String? actionId,
  }) {
    final current = _now();
    _seenAt.removeWhere((_, seenAt) {
      final elapsed = current.difference(seenAt);
      return !elapsed.isNegative && elapsed.compareTo(_duplicateWindow) >= 0;
    });

    final effectiveAction = actionId ?? payload.action ?? '';
    final key = <String>[
      payload.type.wireValue,
      payload.entityId,
      payload.route,
      effectiveAction,
    ].join('\u001f');
    if (_seenAt.containsKey(key)) {
      return false;
    }

    _seenAt[key] = current;
    return true;
  }

  static Duration _requirePositiveWindow(Duration value) {
    if (value.compareTo(Duration.zero) <= 0) {
      throw ArgumentError.value(
        value,
        'duplicateWindow',
        'Must be greater than zero.',
      );
    }

    return value;
  }
}
