import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class DeviceTimeZoneProvider {
  Future<String?> getTimeZoneId();
}

class AndroidMethodChannelTimeZoneProvider implements DeviceTimeZoneProvider {
  AndroidMethodChannelTimeZoneProvider({
    MethodChannel channel = const MethodChannel(
      'four_in_one_app/android_permissions',
    ),
    bool? isWeb,
    TargetPlatform? platform,
  }) : _channel = channel,
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  final MethodChannel _channel;
  final bool _isWeb;
  final TargetPlatform _platform;

  @override
  Future<String?> getTimeZoneId() async {
    if (_isWeb || _platform != TargetPlatform.android) {
      return null;
    }

    try {
      final value = await _channel.invokeMethod<String>('getTimeZoneId');
      final normalized = value?.trim();
      return normalized == null || normalized.isEmpty ? null : normalized;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
