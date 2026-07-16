import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _declaredPermissions(String manifest) {
  return RegExp(
    r'''<uses-permission(?:-sdk-\d+)?\b[^>]*\bandroid:name\s*=\s*["']([^"']+)["']''',
  ).allMatches(manifest).map((match) => match.group(1)!).toSet();
}

String? _androidComponentOpeningTag(
  String manifest, {
  required String element,
  required String className,
}) {
  final namePattern = RegExp(r'''\bandroid:name\s*=\s*["']([^"']+)["']''');
  for (final match in RegExp('<$element\\b[^>]*>').allMatches(manifest)) {
    final openingTag = match.group(0)!;
    if (namePattern.firstMatch(openingTag)?.group(1) == className) {
      return openingTag;
    }
  }
  return null;
}

String? _androidAttribute(String openingTag, String attribute) {
  return RegExp(
    "\\bandroid:${RegExp.escape(attribute)}\\s*=\\s*[\"']([^\"']+)[\"']",
  ).firstMatch(openingTag)?.group(1);
}

String? _receiverBlock(String manifest, String className) {
  final openingTag = _androidComponentOpeningTag(
    manifest,
    element: 'receiver',
    className: className,
  );
  if (openingTag == null || RegExp(r'/\s*>$').hasMatch(openingTag)) {
    return null;
  }
  final blockStart = manifest.indexOf(openingTag);
  final closingTag = '</receiver>';
  final blockEnd = manifest.indexOf(closingTag, blockStart + openingTag.length);
  if (blockStart < 0 || blockEnd < 0) {
    return null;
  }
  return manifest.substring(blockStart, blockEnd + closingTag.length);
}

void main() {
  group('Android notification manifest contract', () {
    final mainManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final debugManifest = File(
      'android/app/src/debug/AndroidManifest.xml',
    ).readAsStringSync();
    final profileManifest = File(
      'android/app/src/profile/AndroidManifest.xml',
    ).readAsStringSync();

    test('declares only app-owned notification and boot permissions', () {
      expect(_declaredPermissions(mainManifest), <String>{
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.RECEIVE_BOOT_COMPLETED',
      });
    });

    test('debug and profile overlays add only Flutter tooling internet', () {
      const expected = <String>{'android.permission.INTERNET'};
      expect(_declaredPermissions(debugManifest), expected);
      expect(_declaredPermissions(profileManifest), expected);
    });

    test('forbidden dangerous and special permissions are absent', () {
      const forbidden = <String>[
        'MANAGE_EXTERNAL_STORAGE',
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
        'READ_MEDIA_IMAGES',
        'READ_MEDIA_VIDEO',
        'RECORD_AUDIO',
        'CAMERA',
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
        'READ_CONTACTS',
        'READ_PHONE_STATE',
        'QUERY_ALL_PACKAGES',
        'REQUEST_INSTALL_PACKAGES',
        'SYSTEM_ALERT_WINDOW',
        'USE_FULL_SCREEN_INTENT',
        'ACCESS_NOTIFICATION_POLICY',
        'REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        'SCHEDULE_EXACT_ALARM',
        'USE_EXACT_ALARM',
        'FOREGROUND_SERVICE',
      ];

      final appSourcePermissions = <String>{
        ..._declaredPermissions(mainManifest),
        ..._declaredPermissions(debugManifest),
        ..._declaredPermissions(profileManifest),
      };
      for (final permission in forbidden) {
        expect(
          appSourcePermissions,
          isNot(contains('android.permission.$permission')),
        );
      }
    });

    test('notification receivers are present and exported false', () {
      for (final receiver in const <String>[
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
        'com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver',
      ]) {
        final openingTag = _androidComponentOpeningTag(
          mainManifest,
          element: 'receiver',
          className: receiver,
        );
        expect(openingTag, isNotNull, reason: '$receiver must be declared');
        expect(_androidAttribute(openingTag!, 'exported'), 'false');
      }

      final bootReceiver = _receiverBlock(
        mainManifest,
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      );
      expect(bootReceiver, isNotNull);
      final bootActions = RegExp(
        r'''<action\b[^>]*\bandroid:name\s*=\s*["']([^"']+)["'][^>]*/?>''',
      ).allMatches(bootReceiver!).map((match) => match.group(1)!).toSet();
      expect(bootActions, <String>{
        'android.intent.action.BOOT_COMPLETED',
        'android.intent.action.MY_PACKAGE_REPLACED',
        'android.intent.action.QUICKBOOT_POWERON',
        'com.htc.intent.action.QUICKBOOT_POWERON',
      });
    });

    test('custom small icon exists and is kept for resource shrinking', () {
      final icon = File(
        'android/app/src/main/res/drawable/ic_stat_getready.xml',
      ).readAsStringSync();
      final keep = File(
        'android/app/src/main/res/raw/keep.xml',
      ).readAsStringSync();
      final notificationService = File(
        'lib/core/notifications/app_local_notification_service.dart',
      ).readAsStringSync();

      expect(icon, contains('<vector'));
      expect(icon, contains('android:fillColor="#FFFFFFFF"'));
      expect(icon, contains('android:pathData='));
      expect(keep, contains('@drawable/ic_stat_getready'));
      expect(
        notificationService,
        contains("static const notificationIcon = 'ic_stat_getready';"),
      );
      expect(
        notificationService,
        contains('AndroidInitializationSettings(notificationIcon)'),
      );
    });

    test('native permission bridge uses only public permission-state APIs', () {
      final activity = File(
        'android/app/src/main/kotlin/com/example/four_in_one_app/MainActivity.kt',
      ).readAsStringSync();

      expect(activity, isNot(contains('getPermissionFlags(')));
      expect(activity, isNot(contains('FLAG_PERMISSION_USER_')));
      expect(activity, contains('isPermissionRevokedByPolicy('));
      expect(activity, contains('shouldShowRequestPermissionRationale('));
      expect(activity, contains('pendingNotificationPermissionResults'));
    });
  });
}
