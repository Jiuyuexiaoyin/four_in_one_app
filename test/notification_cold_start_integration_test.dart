import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/core/notifications/device_time_zone_provider.dart';
import 'package:four_in_one_app/core/notifications/local_notifications_gateway.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/presentation/pages/habits_page.dart';
import 'package:four_in_one_app/features/today/presentation/pages/today_page.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  test('controller retries a failed notification initialization', () async {
    final payload = AppNotificationPayload(
      type: AppNotificationType.habitReminder,
      entityId: 'habit-retry',
      route: AppNotificationPayload.habitsRoute,
    ).encode();
    final gateway = _ColdStartGateway(
      NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: payload,
      ),
      initializeFailuresRemaining: 1,
    );
    final runtime = _runtimeFor(gateway);
    addTearDown(runtime.dispose);

    await runtime.initialize();
    expect(gateway.initializeCalls, 1);
    expect(runtime.takeInitialDestination(), isNull);

    await runtime.initialize();
    expect(gateway.initializeCalls, 2);
    expect(runtime.takeInitialDestination()?.entityId, 'habit-retry');
  });

  test(
    'live response is buffered until a destination listener attaches',
    () async {
      final coldPayload = AppNotificationPayload(
        type: AppNotificationType.habitReminder,
        entityId: 'habit-cold',
        route: AppNotificationPayload.habitsRoute,
      ).encode();
      final gateway = _ColdStartGateway(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: coldPayload,
        ),
      );
      final runtime = _runtimeFor(gateway);
      addTearDown(runtime.dispose);
      await runtime.initialize();
      expect(runtime.takeInitialDestination()?.entityId, 'habit-cold');

      final livePayload = AppNotificationPayload(
        type: AppNotificationType.focusCompletion,
        entityId: 'focus-live',
        route: AppNotificationPayload.focusRoute,
      ).encode();
      gateway.emit(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: AppNotificationAction.focusViewRecords,
          payload: livePayload,
        ),
      );

      final buffered = runtime.takeInitialDestination();
      expect(buffered?.route, AppRoute.review);
      expect(buffered?.entityId, 'focus-live');
    },
  );

  testWidgets('cold-start notification opens one destination exactly once', (
    tester,
  ) async {
    final payload = AppNotificationPayload(
      type: AppNotificationType.habitReminder,
      entityId: 'habit-42',
      route: AppNotificationPayload.habitsRoute,
    ).encode();
    final response = NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      id: 1200042,
      payload: payload,
    );
    final gateway = _ColdStartGateway(response);
    final runtime = _runtimeFor(gateway);
    await runtime.initialize();
    expect(gateway.initializeCalls, 1);
    expect(gateway.launchDetailsCalls, 1);

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
        notificationRuntimeController: runtime,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HabitsPage), findsOneWidget);
    final habitContext = tester.element(find.byType(HabitsPage));
    expect(ModalRoute.of(habitContext)?.settings.name, AppRoute.habits);
    expect(ModalRoute.of(habitContext)?.settings.arguments, 'habit-42');

    gateway.emit(response);
    await runtime.initialize();
    await tester.pumpAndSettle();
    expect(gateway.initializeCalls, 1);
    expect(gateway.launchDetailsCalls, 1);

    Navigator.of(habitContext).pop();
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
    expect(find.byType(HabitsPage), findsNothing);
  });
}

NotificationRuntimeController _runtimeFor(_ColdStartGateway gateway) {
  final notificationService = AppLocalNotificationService(
    gateway: gateway,
    timeZoneProvider: const _TimeZoneProvider(),
    isWeb: false,
    platform: TargetPlatform.android,
  );
  return NotificationRuntimeController(
    permissionCoordinator: AndroidPermissionCoordinator(
      isWeb: true,
      platform: TargetPlatform.android,
    ),
    notificationService: notificationService,
  );
}

class _TimeZoneProvider implements DeviceTimeZoneProvider {
  const _TimeZoneProvider();

  @override
  Future<String?> getTimeZoneId() async => 'Asia/Shanghai';
}

class _ColdStartGateway implements LocalNotificationsGateway {
  _ColdStartGateway(
    this.launchResponse, {
    this.initializeFailuresRemaining = 0,
  });

  final NotificationResponse launchResponse;
  int initializeFailuresRemaining;
  int initializeCalls = 0;
  int launchDetailsCalls = 0;
  LocalNotificationResponseHandler? _onResponse;

  void emit(NotificationResponse response) {
    _onResponse?.call(response);
  }

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
    _onResponse = onResponse;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    launchDetailsCalls += 1;
    return NotificationAppLaunchDetails(
      true,
      notificationResponse: launchResponse,
    );
  }

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {}

  @override
  Future<List<AndroidNotificationChannel>?> getAndroidChannels() async {
    return const <AndroidNotificationChannel>[];
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payload,
  }) async {}

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
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    return const <PendingNotificationRequest>[];
  }
}
