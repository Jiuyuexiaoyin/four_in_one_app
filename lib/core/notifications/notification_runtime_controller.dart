import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/core/notifications/app_notification_routing.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/core/permissions/app_permission.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';

class NotificationRuntimeState {
  const NotificationRuntimeState({
    this.permission,
    this.health,
    this.isRefreshing = false,
  });

  final AppPermissionResult? permission;
  final AppNotificationHealth? health;
  final bool isRefreshing;

  NotificationRuntimeState copyWith({
    AppPermissionResult? permission,
    AppNotificationHealth? health,
    bool? isRefreshing,
  }) {
    return NotificationRuntimeState(
      permission: permission ?? this.permission,
      health: health ?? this.health,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class NotificationRuntimeController extends ChangeNotifier {
  NotificationRuntimeController({
    required AppPermissionCoordinator permissionCoordinator,
    required AppLocalNotificationService notificationService,
    NotificationResponseDeduplicator? deduplicator,
  }) : _permissionCoordinator = permissionCoordinator,
       _notificationService = notificationService,
       _deduplicator = deduplicator ?? NotificationResponseDeduplicator() {
    _responseSubscription = _notificationService.responses.listen(
      _handleLiveResponse,
    );
  }

  factory NotificationRuntimeController.noop() {
    return NotificationRuntimeController(
      permissionCoordinator: AndroidPermissionCoordinator(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      notificationService: AppLocalNotificationService(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
    );
  }

  final AppPermissionCoordinator _permissionCoordinator;
  final AppLocalNotificationService _notificationService;
  final NotificationResponseDeduplicator _deduplicator;
  final StreamController<AppNotificationDestination> _destinations =
      StreamController<AppNotificationDestination>.broadcast(sync: true);
  final Queue<AppNotificationDestination> _bufferedDestinations = Queue();
  late final StreamSubscription<NotificationResponse> _responseSubscription;

  NotificationRuntimeState _state = const NotificationRuntimeState();
  bool _initialized = false;
  bool _disposed = false;

  NotificationRuntimeState get state => _state;
  AppPermissionResult? get notificationPermission => _state.permission;
  AppNotificationHealth? get health => _state.health;
  Stream<AppNotificationDestination> get destinations => _destinations.stream;
  AppLocalNotificationService get notificationService => _notificationService;

  Future<void> initialize() async {
    if (_initialized || _disposed) {
      return;
    }

    await _notificationService.initialize();
    if (_disposed || !_notificationService.isInitialized) {
      return;
    }
    final initialResponse = _notificationService.takeInitialResponse();
    if (initialResponse != null) {
      final payload = AppNotificationPayload.tryParse(initialResponse.payload);
      if (payload != null) {
        _deduplicator.add(
          payload,
          actionId: _normalizeActionId(initialResponse.actionId),
        );
      }
    }
    _initialized = true;
  }

  Future<void> refresh() async {
    if (_disposed) {
      return;
    }
    await initialize();
    if (_disposed) {
      return;
    }
    _state = _state.copyWith(isRefreshing: true);
    notifyListeners();

    final permission = await _permissionCoordinator.check(
      AppPermission.notifications,
    );
    if (_disposed) {
      return;
    }
    final health = await _notificationService.health();
    if (_disposed) {
      return;
    }
    if (!_initialized && _notificationService.isInitialized) {
      await initialize();
      if (_disposed) {
        return;
      }
    }
    _state = NotificationRuntimeState(
      permission: permission,
      health: health,
      isRefreshing: false,
    );
    notifyListeners();
  }

  Future<AppPermissionResult> checkNotificationPermission() async {
    if (_disposed) {
      return const AppPermissionResult(
        permission: AppPermission.notifications,
        status: AppPermissionStatus.unavailable,
      );
    }
    final result = await _permissionCoordinator.check(
      AppPermission.notifications,
    );
    if (_disposed) {
      return result;
    }
    _state = _state.copyWith(permission: result);
    notifyListeners();
    return result;
  }

  Future<AppPermissionResult> requestNotificationPermission() async {
    if (_disposed) {
      return const AppPermissionResult(
        permission: AppPermission.notifications,
        status: AppPermissionStatus.unavailable,
      );
    }
    final result = await _permissionCoordinator.request(
      AppPermission.notifications,
    );
    if (_disposed) {
      return result;
    }
    _state = _state.copyWith(permission: result);
    notifyListeners();
    return result;
  }

  Future<bool> openNotificationSettings() {
    if (_disposed) {
      return Future<bool>.value(false);
    }
    return _permissionCoordinator.openSettings(AppPermission.notifications);
  }

  Future<bool> openHabitChannelSettings() {
    if (_disposed) {
      return Future<bool>.value(false);
    }
    return _permissionCoordinator.openNotificationChannelSettings(
      AppLocalNotificationService.habitChannelId,
    );
  }

  Future<bool> openFocusChannelSettings() {
    if (_disposed) {
      return Future<bool>.value(false);
    }
    return _permissionCoordinator.openNotificationChannelSettings(
      AppLocalNotificationService.focusChannelId,
    );
  }

  Future<NotificationOperationResult> sendTestNotification() async {
    if (_disposed) {
      return const NotificationOperationResult.unavailable(
        'controller_disposed',
      );
    }
    final payload = AppNotificationPayload(
      type: AppNotificationType.test,
      entityId:
          'notification-test-${DateTime.now().toUtc().millisecondsSinceEpoch}',
      route: AppNotificationPayload.settingsRoute,
    );
    final result = await _notificationService.sendTestNotification(
      payload: payload.encode(),
      channelsApplicable: (notificationPermission?.apiLevel ?? 26) >= 26,
    );
    await refresh();
    return result;
  }

  Future<bool> refreshTimeZone() {
    if (_disposed) {
      return Future<bool>.value(false);
    }
    return _notificationService.refreshTimeZone();
  }

  AppNotificationDestination? takeInitialDestination() {
    final coldStartDestination = _deduplicator.takeInitial();
    if (coldStartDestination != null) {
      return coldStartDestination;
    }
    return _bufferedDestinations.isEmpty
        ? null
        : _bufferedDestinations.removeFirst();
  }

  void _handleLiveResponse(NotificationResponse response) {
    final payload = AppNotificationPayload.tryParse(response.payload);
    if (payload == null) {
      return;
    }

    final destination = _deduplicator.resolveOnce(
      payload,
      actionId: _normalizeActionId(response.actionId),
    );
    if (destination == null || _disposed || _destinations.isClosed) {
      return;
    }
    if (_destinations.hasListener) {
      _destinations.add(destination);
    } else {
      _bufferedDestinations.add(destination);
    }
  }

  static String? _normalizeActionId(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _bufferedDestinations.clear();
    unawaited(_responseSubscription.cancel());
    unawaited(_destinations.close());
    _notificationService.dispose();
    super.dispose();
  }
}
