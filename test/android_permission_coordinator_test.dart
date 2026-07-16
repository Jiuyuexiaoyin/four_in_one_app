import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/core/permissions/app_permission.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';

void main() {
  group('AndroidPermissionCoordinator', () {
    test('returns granted without opening the request dialog', () async {
      final bridge = _FakeAndroidPermissionBridge(
        statusResult: const AndroidPermissionBridgeResult(
          status: AppPermissionStatus.granted,
          apiLevel: 35,
        ),
      );
      final coordinator = _androidCoordinator(bridge);

      final result = await coordinator.request(AppPermission.notifications);

      expect(result.status, AppPermissionStatus.granted);
      expect(result.apiLevel, 35);
      expect(result.didRequest, isFalse);
      expect(bridge.statusCalls, 1);
      expect(bridge.requestCalls, 0);
    });

    test(
      'requests after a denied status and returns structured result',
      () async {
        final bridge = _FakeAndroidPermissionBridge(
          statusResult: const AndroidPermissionBridgeResult(
            status: AppPermissionStatus.denied,
            apiLevel: 33,
          ),
          requestResult: const AndroidPermissionBridgeResult(
            status: AppPermissionStatus.denied,
          ),
        );
        final coordinator = _androidCoordinator(bridge);

        final result = await coordinator.request(AppPermission.notifications);

        expect(result.status, AppPermissionStatus.denied);
        expect(result.apiLevel, 33);
        expect(result.didRequest, isTrue);
        expect(bridge.statusCalls, 1);
        expect(bridge.requestCalls, 1);
      },
    );

    test('settings-required status is not requested again', () async {
      final bridge = _FakeAndroidPermissionBridge(
        statusResult: const AndroidPermissionBridgeResult(
          status: AppPermissionStatus.settingsRequired,
        ),
      );
      final coordinator = _androidCoordinator(bridge);

      final result = await coordinator.request(AppPermission.notifications);

      expect(result.status, AppPermissionStatus.settingsRequired);
      expect(result.requiresSettings, isTrue);
      expect(result.didRequest, isFalse);
      expect(bridge.requestCalls, 0);
    });

    test('non-Android platform is not applicable', () async {
      final bridge = _FakeAndroidPermissionBridge();
      final coordinator = AndroidPermissionCoordinator(
        bridge: bridge,
        isWeb: false,
        platform: TargetPlatform.iOS,
      );

      final result = await coordinator.check(AppPermission.notifications);

      expect(result.status, AppPermissionStatus.notApplicable);
      expect(result.isApplicable, isFalse);
      expect(bridge.totalCalls, 0);
    });

    test('web is safe and never invokes the Android bridge', () async {
      final bridge = _FakeAndroidPermissionBridge(throwOnEveryCall: true);
      final coordinator = AndroidPermissionCoordinator(
        bridge: bridge,
        isWeb: true,
        platform: TargetPlatform.android,
      );

      final checked = await coordinator.check(AppPermission.notifications);
      final requested = await coordinator.request(AppPermission.notifications);
      final opened = await coordinator.openSettings(
        AppPermission.notifications,
      );
      final channelOpened = await coordinator.openNotificationChannelSettings(
        'habit_reminders_v1',
      );

      expect(checked.status, AppPermissionStatus.notApplicable);
      expect(requested.status, AppPermissionStatus.notApplicable);
      expect(opened, isFalse);
      expect(channelOpened, isFalse);
      expect(bridge.totalCalls, 0);
    });

    test('settings methods invoke the matching bridge operations', () async {
      final bridge = _FakeAndroidPermissionBridge(
        openNotificationSettingsResult: true,
        openChannelSettingsResult: true,
      );
      final coordinator = _androidCoordinator(bridge);

      expect(
        await coordinator.openSettings(AppPermission.notifications),
        isTrue,
      );
      expect(
        await coordinator.openNotificationChannelSettings('habit_reminders_v1'),
        isTrue,
      );
      expect(bridge.openNotificationSettingsCalls, 1);
      expect(bridge.openChannelSettingsCalls, 1);
      expect(bridge.lastChannelId, 'habit_reminders_v1');
    });

    test(
      'bridge failures return unavailable or false without throwing',
      () async {
        final bridge = _FakeAndroidPermissionBridge(throwOnEveryCall: true);
        final coordinator = _androidCoordinator(bridge);

        final result = await coordinator.check(AppPermission.notifications);

        expect(result.status, AppPermissionStatus.unavailable);
        expect(
          await coordinator.openSettings(AppPermission.notifications),
          isFalse,
        );
        expect(
          await coordinator.openNotificationChannelSettings(
            'focus_completion_v1',
          ),
          isFalse,
        );
      },
    );
  });
}

AndroidPermissionCoordinator _androidCoordinator(
  AndroidPermissionBridge bridge,
) {
  return AndroidPermissionCoordinator(
    bridge: bridge,
    isWeb: false,
    platform: TargetPlatform.android,
  );
}

class _FakeAndroidPermissionBridge implements AndroidPermissionBridge {
  _FakeAndroidPermissionBridge({
    this.statusResult = const AndroidPermissionBridgeResult(
      status: AppPermissionStatus.denied,
    ),
    this.requestResult = const AndroidPermissionBridgeResult(
      status: AppPermissionStatus.granted,
    ),
    this.openNotificationSettingsResult = false,
    this.openChannelSettingsResult = false,
    this.throwOnEveryCall = false,
  });

  final AndroidPermissionBridgeResult statusResult;
  final AndroidPermissionBridgeResult requestResult;
  final bool openNotificationSettingsResult;
  final bool openChannelSettingsResult;
  final bool throwOnEveryCall;

  int statusCalls = 0;
  int requestCalls = 0;
  int openNotificationSettingsCalls = 0;
  int openChannelSettingsCalls = 0;
  String? lastChannelId;

  int get totalCalls =>
      statusCalls +
      requestCalls +
      openNotificationSettingsCalls +
      openChannelSettingsCalls;

  @override
  Future<AndroidPermissionBridgeResult> notificationStatus() async {
    statusCalls += 1;
    _throwIfRequested();
    return statusResult;
  }

  @override
  Future<AndroidPermissionBridgeResult> requestNotificationPermission() async {
    requestCalls += 1;
    _throwIfRequested();
    return requestResult;
  }

  @override
  Future<bool> openNotificationSettings() async {
    openNotificationSettingsCalls += 1;
    _throwIfRequested();
    return openNotificationSettingsResult;
  }

  @override
  Future<bool> openNotificationChannelSettings(String channelId) async {
    openChannelSettingsCalls += 1;
    lastChannelId = channelId;
    _throwIfRequested();
    return openChannelSettingsResult;
  }

  void _throwIfRequested() {
    if (throwOnEveryCall) {
      throw StateError('bridge unavailable');
    }
  }
}
