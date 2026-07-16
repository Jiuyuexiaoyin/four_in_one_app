import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_permission.dart';
import 'app_permission_status.dart';

abstract interface class AppPermissionCoordinator {
  Future<AppPermissionResult> check(AppPermission permission);

  Future<AppPermissionResult> request(AppPermission permission);

  Future<bool> openSettings(AppPermission permission);

  Future<bool> openNotificationChannelSettings(String channelId);
}

class AndroidPermissionBridgeResult {
  const AndroidPermissionBridgeResult({required this.status, this.apiLevel});

  final AppPermissionStatus status;
  final int? apiLevel;
}

abstract interface class AndroidPermissionBridge {
  Future<AndroidPermissionBridgeResult> notificationStatus();

  Future<AndroidPermissionBridgeResult> requestNotificationPermission();

  Future<bool> openNotificationSettings();

  Future<bool> openNotificationChannelSettings(String channelId);
}

class MethodChannelAndroidPermissionBridge implements AndroidPermissionBridge {
  const MethodChannelAndroidPermissionBridge();

  static const MethodChannel _channel = MethodChannel(
    'four_in_one_app/android_permissions',
  );

  @override
  Future<AndroidPermissionBridgeResult> notificationStatus() {
    return _invokeStatus('notificationStatus');
  }

  @override
  Future<AndroidPermissionBridgeResult> requestNotificationPermission() {
    return _invokeStatus('requestNotificationPermission');
  }

  @override
  Future<bool> openNotificationSettings() {
    return _invokeOpen('openNotificationSettings');
  }

  @override
  Future<bool> openNotificationChannelSettings(String channelId) {
    if (channelId.trim().isEmpty) {
      return Future<bool>.value(false);
    }

    return _invokeOpen('openNotificationChannelSettings', <String, Object>{
      'channelId': channelId,
    });
  }

  Future<AndroidPermissionBridgeResult> _invokeStatus(String method) async {
    try {
      final value = await _channel.invokeMethod<Object?>(method);
      return _decodeStatus(value);
    } on MissingPluginException {
      return const AndroidPermissionBridgeResult(
        status: AppPermissionStatus.unavailable,
      );
    } on PlatformException {
      return const AndroidPermissionBridgeResult(
        status: AppPermissionStatus.unavailable,
      );
    } catch (_) {
      return const AndroidPermissionBridgeResult(
        status: AppPermissionStatus.unavailable,
      );
    }
  }

  Future<bool> _invokeOpen(
    String method, [
    Map<String, Object>? arguments,
  ]) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static AndroidPermissionBridgeResult _decodeStatus(Object? value) {
    if (value is bool) {
      return AndroidPermissionBridgeResult(
        status: value
            ? AppPermissionStatus.granted
            : AppPermissionStatus.denied,
      );
    }

    if (value is String) {
      return AndroidPermissionBridgeResult(status: _statusFromName(value));
    }

    if (value is Map<Object?, Object?>) {
      final rawStatus = value['status'];
      final rawApiLevel = value['apiLevel'];
      return AndroidPermissionBridgeResult(
        status: rawStatus is String
            ? _statusFromName(rawStatus)
            : AppPermissionStatus.unavailable,
        apiLevel: rawApiLevel is num ? rawApiLevel.toInt() : null,
      );
    }

    return const AndroidPermissionBridgeResult(
      status: AppPermissionStatus.unavailable,
    );
  }

  static AppPermissionStatus _statusFromName(String value) {
    return switch (value.trim().toLowerCase()) {
      'granted' => AppPermissionStatus.granted,
      'denied' => AppPermissionStatus.denied,
      'settingsrequired' ||
      'settings_required' ||
      'permanentlydenied' ||
      'permanently_denied' => AppPermissionStatus.settingsRequired,
      'restricted' => AppPermissionStatus.restricted,
      'notapplicable' || 'not_applicable' => AppPermissionStatus.notApplicable,
      'unavailable' => AppPermissionStatus.unavailable,
      _ => AppPermissionStatus.unavailable,
    };
  }
}

class AndroidPermissionCoordinator implements AppPermissionCoordinator {
  AndroidPermissionCoordinator({
    AndroidPermissionBridge? bridge,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _bridge = bridge ?? const MethodChannelAndroidPermissionBridge(),
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  final AndroidPermissionBridge _bridge;
  final bool _isWeb;
  final TargetPlatform _platform;

  bool get _supportsAndroidPermissions =>
      !_isWeb && _platform == TargetPlatform.android;

  @override
  Future<AppPermissionResult> check(AppPermission permission) async {
    if (!_supportsAndroidPermissions) {
      return AppPermissionResult(
        permission: permission,
        status: AppPermissionStatus.notApplicable,
      );
    }

    try {
      final bridgeResult = switch (permission) {
        AppPermission.notifications => await _bridge.notificationStatus(),
      };
      return _toResult(permission, bridgeResult);
    } catch (_) {
      return AppPermissionResult(
        permission: permission,
        status: AppPermissionStatus.unavailable,
      );
    }
  }

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    final current = await check(permission);
    if (current.status != AppPermissionStatus.denied) {
      return current;
    }

    try {
      final bridgeResult = switch (permission) {
        AppPermission.notifications =>
          await _bridge.requestNotificationPermission(),
      };
      return _toResult(
        permission,
        bridgeResult,
        didRequest: true,
        fallbackApiLevel: current.apiLevel,
      );
    } catch (_) {
      return AppPermissionResult(
        permission: permission,
        status: AppPermissionStatus.unavailable,
        didRequest: true,
        apiLevel: current.apiLevel,
      );
    }
  }

  @override
  Future<bool> openSettings(AppPermission permission) async {
    if (!_supportsAndroidPermissions) {
      return false;
    }

    try {
      return switch (permission) {
        AppPermission.notifications => await _bridge.openNotificationSettings(),
      };
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openNotificationChannelSettings(String channelId) async {
    if (!_supportsAndroidPermissions || channelId.trim().isEmpty) {
      return false;
    }

    try {
      return await _bridge.openNotificationChannelSettings(channelId);
    } catch (_) {
      return false;
    }
  }

  static AppPermissionResult _toResult(
    AppPermission permission,
    AndroidPermissionBridgeResult bridgeResult, {
    bool didRequest = false,
    int? fallbackApiLevel,
  }) {
    return AppPermissionResult(
      permission: permission,
      status: bridgeResult.status,
      didRequest: didRequest,
      apiLevel: bridgeResult.apiLevel ?? fallbackApiLevel,
    );
  }
}
