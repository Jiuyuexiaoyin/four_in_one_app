import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/device_time_zone_provider.dart';
import 'package:four_in_one_app/core/notifications/local_notifications_gateway.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/core/permissions/app_permission.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';
import 'package:four_in_one_app/features/settings/presentation/widgets/notification_permissions_section.dart';
import 'package:four_in_one_app/shared/widgets/product/my_settings_section.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  testWidgets('status rows reflect the real coordinator and health state', (
    tester,
  ) async {
    final fixture = await _Fixture.create(status: AppPermissionStatus.granted);
    addTearDown(fixture.controller.dispose);
    fixture.gateway.pending[1200001] = const PendingNotificationRequest(
      1200001,
      '该打卡了',
      '今天的「喝水」还未完成',
      '{}',
    );

    await _pumpSection(tester, fixture.controller);

    expect(find.text('通知与权限'), findsOneWidget);
    expect(find.text('已开启'), findsWidgets);
    expect(find.text('普通提醒'), findsOneWidget);
    expect(find.textContaining('系统照片选择器'), findsOneWidget);

    await _tapSettingRow(tester, 'settings-notification-health');

    expect(find.text('1 条'), findsOneWidget);
    expect(find.text('可用'), findsNWidgets(2));
    expect(find.text('普通提醒（无需精确闹钟权限）'), findsOneWidget);
  });

  testWidgets('denied permission uses explanation then structured request', (
    tester,
  ) async {
    final fixture = await _Fixture.create(
      status: AppPermissionStatus.denied,
      requestStatus: AppPermissionStatus.denied,
    );
    addTearDown(fixture.controller.dispose);
    await _pumpSection(tester, fixture.controller);

    expect(find.text('未开启'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('settings-notification-permission')),
    );
    await tester.pumpAndSettle();

    expect(find.text('开启通知'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('notification-permission-continue')),
    );
    await tester.pumpAndSettle();

    expect(fixture.permissions.requestCalls, 1);
    expect(find.text('未开启'), findsWidgets);
  });

  testWidgets('initial status check keeps Android actions disabled', (
    tester,
  ) async {
    final permissions = _DeferredPermissionCoordinator();
    final gateway = _FakeGateway();
    final controller = NotificationRuntimeController(
      permissionCoordinator: permissions,
      notificationService: AppLocalNotificationService(
        gateway: gateway,
        timeZoneProvider: const _TimeZoneProvider(),
        isWeb: false,
        platform: TargetPlatform.android,
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationRuntimeScope(
          notifier: controller,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: NotificationPermissionsSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    for (final key in const <String>[
      'settings-notification-permission',
      'settings-test-notification',
      'settings-notification-settings',
      'settings-channel-settings',
      'settings-focus-channel-settings',
    ]) {
      expect(
        tester.widget<MySettingsRow>(find.byKey(ValueKey<String>(key))).enabled,
        isFalse,
      );
    }
    expect(find.text('正在确认当前平台是否支持本地通知测试。'), findsOneWidget);

    permissions.complete(AppPermissionStatus.granted, apiLevel: 35);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MySettingsRow>(
            find.byKey(const ValueKey('settings-test-notification')),
          )
          .enabled,
      isTrue,
    );
  });

  testWidgets('settings and test actions use their abstractions', (
    tester,
  ) async {
    final fixture = await _Fixture.create(status: AppPermissionStatus.granted);
    addTearDown(fixture.controller.dispose);
    await _pumpSection(tester, fixture.controller);

    await _tapSettingRow(tester, 'settings-notification-settings');
    expect(fixture.permissions.openSettingsCalls, 1);

    await _tapSettingRow(tester, 'settings-channel-settings');
    await _tapSettingRow(tester, 'settings-focus-channel-settings');
    expect(fixture.permissions.openedChannelIds, <String>[
      AppLocalNotificationService.habitChannelId,
      AppLocalNotificationService.focusChannelId,
    ]);

    await _tapSettingRow(tester, 'settings-test-notification');

    expect(fixture.gateway.showCalls, 1);
    expect(fixture.gateway.pending, isEmpty);
    expect(find.text('测试通知已提交，请查看通知栏。'), findsOneWidget);
  });

  testWidgets('web status disables Android-only Settings rows', (tester) async {
    final fixture = await _Fixture.create(
      status: AppPermissionStatus.notApplicable,
      apiLevel: null,
      isWeb: true,
    );
    addTearDown(fixture.controller.dispose);
    await _pumpSection(tester, fixture.controller);

    for (final key in const <String>[
      'settings-notification-permission',
      'settings-notification-settings',
      'settings-channel-settings',
      'settings-focus-channel-settings',
      'settings-test-notification',
    ]) {
      final row = tester.widget<MySettingsRow>(
        find.byKey(ValueKey<String>(key)),
      );
      expect(row.enabled, isFalse, reason: '$key should be non-Android safe');
    }

    expect(find.text('当前平台不提供 Android 应用通知设置。'), findsOneWidget);
    expect(find.text('当前平台不提供 Android 通知渠道。'), findsNWidgets(2));
    expect(fixture.permissions.openSettingsCalls, 0);
    expect(fixture.permissions.openedChannelIds, isEmpty);
    expect(fixture.gateway.showCalls, 0);
  });

  testWidgets('Android 7 keeps app settings but disables channel settings', (
    tester,
  ) async {
    final fixture = await _Fixture.create(
      status: AppPermissionStatus.granted,
      apiLevel: 25,
    );
    addTearDown(fixture.controller.dispose);
    await _pumpSection(tester, fixture.controller);

    expect(
      tester
          .widget<MySettingsRow>(
            find.byKey(const ValueKey('settings-notification-settings')),
          )
          .enabled,
      isTrue,
    );
    for (final key in const <String>[
      'settings-channel-settings',
      'settings-focus-channel-settings',
    ]) {
      expect(
        tester.widget<MySettingsRow>(find.byKey(ValueKey<String>(key))).enabled,
        isFalse,
      );
    }
    expect(find.text('Android 8 以下没有独立通知渠道。'), findsNWidgets(2));
    expect(find.textContaining('渠道需检查'), findsNothing);

    await _tapSettingRow(tester, 'settings-notification-health');
    expect(find.text('不适用'), findsWidgets);
    expect(fixture.permissions.openedChannelIds, isEmpty);
  });

  testWidgets('disabled Habit channel never claims test delivery', (
    tester,
  ) async {
    final fixture = await _Fixture.create(status: AppPermissionStatus.granted);
    addTearDown(fixture.controller.dispose);
    fixture.gateway.channels.removeWhere(
      (channel) => channel.id == AppLocalNotificationService.habitChannelId,
    );
    fixture.gateway.channels.add(
      const AndroidNotificationChannel(
        AppLocalNotificationService.habitChannelId,
        AppLocalNotificationService.habitChannelName,
        importance: Importance.none,
      ),
    );
    await _pumpSection(tester, fixture.controller);

    await _tapSettingRow(tester, 'settings-test-notification');

    expect(fixture.gateway.showCalls, 0);
    expect(find.text('“习惯提醒”渠道未开启，测试通知未发送。'), findsOneWidget);
    expect(find.text('渠道设置'), findsOneWidget);

    await tester.tap(find.text('渠道设置'));
    await tester.pump();
    expect(fixture.permissions.openedChannelIds, <String>[
      AppLocalNotificationService.habitChannelId,
    ]);
  });
}

Future<void> _pumpSection(
  WidgetTester tester,
  NotificationRuntimeController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationRuntimeScope(
        notifier: controller,
        child: const Scaffold(
          body: SingleChildScrollView(child: NotificationPermissionsSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapSettingRow(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _Fixture {
  const _Fixture({
    required this.controller,
    required this.permissions,
    required this.gateway,
  });

  final NotificationRuntimeController controller;
  final _FakePermissionCoordinator permissions;
  final _FakeGateway gateway;

  static Future<_Fixture> create({
    required AppPermissionStatus status,
    AppPermissionStatus requestStatus = AppPermissionStatus.granted,
    int? apiLevel = 35,
    bool isWeb = false,
  }) async {
    final permissions = _FakePermissionCoordinator(
      status: status,
      requestStatus: requestStatus,
      apiLevel: apiLevel,
    );
    final gateway = _FakeGateway();
    final notificationService = AppLocalNotificationService(
      gateway: gateway,
      timeZoneProvider: const _TimeZoneProvider(),
      isWeb: isWeb,
      platform: TargetPlatform.android,
    );
    final controller = NotificationRuntimeController(
      permissionCoordinator: permissions,
      notificationService: notificationService,
    );
    await controller.initialize();
    return _Fixture(
      controller: controller,
      permissions: permissions,
      gateway: gateway,
    );
  }
}

class _FakePermissionCoordinator implements AppPermissionCoordinator {
  _FakePermissionCoordinator({
    required AppPermissionStatus status,
    required this.requestStatus,
    required this.apiLevel,
  }) : _status = status;

  AppPermissionStatus _status;
  final AppPermissionStatus requestStatus;
  final int? apiLevel;
  int requestCalls = 0;
  int openSettingsCalls = 0;
  final List<String> openedChannelIds = <String>[];

  @override
  Future<AppPermissionResult> check(AppPermission permission) async {
    return AppPermissionResult(
      permission: permission,
      status: _status,
      apiLevel: apiLevel,
    );
  }

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    requestCalls += 1;
    _status = requestStatus;
    return AppPermissionResult(
      permission: permission,
      status: _status,
      apiLevel: apiLevel,
      didRequest: true,
    );
  }

  @override
  Future<bool> openSettings(AppPermission permission) async {
    openSettingsCalls += 1;
    return true;
  }

  @override
  Future<bool> openNotificationChannelSettings(String channelId) async {
    openedChannelIds.add(channelId);
    return true;
  }
}

class _DeferredPermissionCoordinator implements AppPermissionCoordinator {
  final Completer<AppPermissionResult> _status =
      Completer<AppPermissionResult>();

  void complete(AppPermissionStatus status, {int? apiLevel}) {
    _status.complete(
      AppPermissionResult(
        permission: AppPermission.notifications,
        status: status,
        apiLevel: apiLevel,
      ),
    );
  }

  @override
  Future<AppPermissionResult> check(AppPermission permission) => _status.future;

  @override
  Future<AppPermissionResult> request(AppPermission permission) =>
      _status.future;

  @override
  Future<bool> openSettings(AppPermission permission) async => false;

  @override
  Future<bool> openNotificationChannelSettings(String channelId) async => false;
}

class _TimeZoneProvider implements DeviceTimeZoneProvider {
  const _TimeZoneProvider();

  @override
  Future<String?> getTimeZoneId() async => 'Asia/Shanghai';
}

class _FakeGateway implements LocalNotificationsGateway {
  final List<AndroidNotificationChannel> channels =
      <AndroidNotificationChannel>[];
  final Map<int, PendingNotificationRequest> pending =
      <int, PendingNotificationRequest>{};
  int showCalls = 0;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    required LocalNotificationResponseHandler onResponse,
  }) async => true;

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
    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  Future<void> cancel(int id) async {
    pending.remove(id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    return pending.values.toList(growable: false);
  }
}
