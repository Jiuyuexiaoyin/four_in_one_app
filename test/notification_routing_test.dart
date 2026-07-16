import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/core/notifications/app_notification_routing.dart';

void main() {
  group('AppNotificationPayload', () {
    test('round-trips the versioned JSON schema', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.habitReminder,
        entityId: 'habit-42',
        route: AppNotificationPayload.habitsRoute,
        action: AppNotificationAction.habitOpen,
      );

      final decoded = jsonDecode(payload.encode()) as Map<String, dynamic>;

      expect(decoded['schemaVersion'], AppNotificationPayload.schemaVersion);
      expect(AppNotificationPayload.tryParse(payload.encode()), payload);
    });

    test('rejects malformed, unknown, and incomplete JSON', () {
      expect(AppNotificationPayload.tryParse(null), isNull);
      expect(AppNotificationPayload.tryParse(''), isNull);
      expect(AppNotificationPayload.tryParse('{broken'), isNull);
      expect(AppNotificationPayload.tryParse('[]'), isNull);
      expect(
        AppNotificationPayload.tryParse(_encodedPayload(schemaVersion: 2)),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(_encodedPayload(type: 'unknownType')),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          jsonEncode(<String, Object>{
            'schemaVersion': 1,
            'type': 'habitReminder',
            'route': '/habits',
          }),
        ),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          _encodedPayload(extra: const <String, Object>{'debug': true}),
        ),
        isNull,
      );
    });

    test('rejects empty, oversized, and unsafe entity IDs', () {
      expect(
        AppNotificationPayload.tryParse(_encodedPayload(entityId: '')),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          _encodedPayload(
            entityId: List<String>.filled(
              AppNotificationPayload.maxEntityIdLength + 1,
              'a',
            ).join(),
          ),
        ),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          _encodedPayload(entityId: '../habit/42?route=/settings'),
        ),
        isNull,
      );
    });

    test('rejects mismatched routes and actions', () {
      expect(
        AppNotificationPayload.tryParse(_encodedPayload(route: '/focus')),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(_encodedPayload(route: '/review')),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          _encodedPayload(action: AppNotificationAction.focusViewRecords),
        ),
        isNull,
      );
      expect(
        AppNotificationPayload.tryParse(
          _encodedPayload(action: 'unknownAction'),
        ),
        isNull,
      );
    });
  });

  group('AppNotificationRouter', () {
    test('resolves a habit reminder and its open action to Habits', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.habitReminder,
        entityId: 'habit-42',
        route: AppNotificationPayload.habitsRoute,
      );

      expect(
        AppNotificationRouter.resolve(payload),
        const AppNotificationDestination(
          route: '/habits',
          entityId: 'habit-42',
          action: null,
        ),
      );
      expect(
        AppNotificationRouter.resolve(
          payload,
          actionId: AppNotificationAction.habitOpen,
        ),
        const AppNotificationDestination(
          route: '/habits',
          entityId: 'habit-42',
          action: 'open',
        ),
      );
    });

    test('resolves focus body taps to Focus and its action to Review', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.focusCompletion,
        entityId: 'focus-session-9',
        route: AppNotificationPayload.focusRoute,
      );

      expect(AppNotificationRouter.resolve(payload)?.route, '/focus');
      expect(
        AppNotificationRouter.resolve(
          payload,
          actionId: AppNotificationAction.focusViewRecords,
        )?.route,
        '/review',
      );
      expect(
        AppNotificationRouter.resolve(payload, actionId: 'restart'),
        isNull,
      );
    });

    test('routes test notifications to Settings', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.test,
        entityId: 'notification-test-1',
        route: AppNotificationPayload.settingsRoute,
      );

      expect(AppNotificationRouter.resolve(payload)?.route, '/settings');
    });

    test('rejects unknown and type-mismatched action IDs', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.habitReminder,
        entityId: 'habit-42',
        route: AppNotificationPayload.habitsRoute,
      );

      expect(
        AppNotificationRouter.resolve(payload, actionId: 'unknownAction'),
        isNull,
      );
      expect(
        AppNotificationRouter.resolve(
          payload,
          actionId: AppNotificationAction.focusViewRecords,
        ),
        isNull,
      );
    });
  });

  group('NotificationResponseDeduplicator', () {
    test('cold-start destination is handled exactly once', () {
      final payload = AppNotificationPayload(
        type: AppNotificationType.habitReminder,
        entityId: 'habit-42',
        route: AppNotificationPayload.habitsRoute,
      );
      final responses = NotificationResponseDeduplicator();

      expect(responses.add(payload), isTrue);
      expect(responses.add(payload), isFalse);
      expect(responses.pendingInitialCount, 1);
      expect(responses.takeInitial()?.route, '/habits');
      expect(responses.takeInitial(), isNull);
      expect(responses.resolveOnce(payload), isNull);
    });

    test('duplicate callback events are ignored within the safety window', () {
      var now = DateTime.utc(2026, 7, 13, 9);
      final responses = NotificationResponseDeduplicator(
        duplicateWindow: const Duration(seconds: 5),
        now: () => now,
      );
      final payload = AppNotificationPayload(
        type: AppNotificationType.focusCompletion,
        entityId: 'focus-session-9',
        route: AppNotificationPayload.focusRoute,
      );

      expect(responses.resolveOnce(payload)?.route, '/focus');
      expect(responses.resolveOnce(payload), isNull);

      now = now.add(const Duration(seconds: 5));

      expect(responses.resolveOnce(payload)?.route, '/focus');
    });
  });
}

String _encodedPayload({
  int schemaVersion = 1,
  String type = 'habitReminder',
  String entityId = 'habit-42',
  String route = '/habits',
  String? action,
  Map<String, Object> extra = const <String, Object>{},
}) {
  return jsonEncode(<String, Object>{
    'schemaVersion': schemaVersion,
    'type': type,
    'entityId': entityId,
    'route': route,
    'action': ?action,
    ...extra,
  });
}
