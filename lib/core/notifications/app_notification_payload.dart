import 'dart:convert';

enum AppNotificationType {
  habitReminder('habitReminder'),
  focusCompletion('focusCompletion'),
  test('test');

  const AppNotificationType(this.wireValue);

  final String wireValue;

  static AppNotificationType? tryParse(String value) {
    for (final type in values) {
      if (type.wireValue == value) {
        return type;
      }
    }

    return null;
  }
}

abstract final class AppNotificationAction {
  static const habitOpen = 'open';
  static const focusViewRecords = 'viewRecords';
}

final class AppNotificationPayload {
  factory AppNotificationPayload({
    required AppNotificationType type,
    required String entityId,
    required String route,
    String? action,
  }) {
    if (!_isValidEntityId(entityId)) {
      throw ArgumentError.value(
        entityId,
        'entityId',
        'Must be a safe identifier between 1 and $maxEntityIdLength '
            'characters.',
      );
    }
    if (!_isValidRouteForType(type, route)) {
      throw ArgumentError.value(
        route,
        'route',
        'Route is not valid for ${type.wireValue}.',
      );
    }
    if (!isActionAllowedForType(type, action)) {
      throw ArgumentError.value(
        action,
        'action',
        'Action is not valid for ${type.wireValue}.',
      );
    }

    return AppNotificationPayload._(
      type: type,
      entityId: entityId,
      route: route,
      action: action,
    );
  }

  const AppNotificationPayload._({
    required this.type,
    required this.entityId,
    required this.route,
    required this.action,
  });

  static const schemaVersion = 1;
  static const maxEntityIdLength = 128;
  static const maxEncodedLength = 2048;

  static const habitsRoute = '/habits';
  static const focusRoute = '/focus';
  static const settingsRoute = '/settings';

  static final RegExp _safeEntityIdPattern = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9._:-]*$',
  );

  final AppNotificationType type;
  final String entityId;
  final String route;
  final String? action;

  String encode() => jsonEncode(<String, Object>{
    'schemaVersion': schemaVersion,
    'type': type.wireValue,
    'entityId': entityId,
    'route': route,
    'action': ?action,
  });

  static AppNotificationPayload? tryParse(String? source) {
    if (source == null ||
        source.trim().isEmpty ||
        source.length > maxEncodedLength) {
      return null;
    }

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic> || !_hasOnlyKnownKeys(decoded)) {
        return null;
      }
      if (decoded['schemaVersion'] is! int ||
          decoded['schemaVersion'] != schemaVersion ||
          decoded['type'] is! String ||
          decoded['entityId'] is! String ||
          decoded['route'] is! String) {
        return null;
      }

      final type = AppNotificationType.tryParse(decoded['type'] as String);
      if (type == null) {
        return null;
      }

      final actionValue = decoded['action'];
      if (decoded.containsKey('action') && actionValue is! String) {
        return null;
      }

      return AppNotificationPayload(
        type: type,
        entityId: decoded['entityId'] as String,
        route: decoded['route'] as String,
        action: actionValue as String?,
      );
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    } on TypeError {
      return null;
    }
  }

  static bool isActionAllowedForType(AppNotificationType type, String? action) {
    if (action == null) {
      return true;
    }

    return switch (type) {
      AppNotificationType.habitReminder =>
        action == AppNotificationAction.habitOpen,
      AppNotificationType.focusCompletion =>
        action == AppNotificationAction.focusViewRecords,
      AppNotificationType.test => false,
    };
  }

  static bool _hasOnlyKnownKeys(Map<String, dynamic> value) {
    const requiredKeys = <String>{'schemaVersion', 'type', 'entityId', 'route'};
    const knownKeys = <String>{...requiredKeys, 'action'};

    return value.keys.every(knownKeys.contains) &&
        requiredKeys.every(value.containsKey);
  }

  static bool _isValidEntityId(String value) {
    final match = _safeEntityIdPattern.firstMatch(value);

    return value.isNotEmpty &&
        value.length <= maxEntityIdLength &&
        match != null &&
        match.start == 0 &&
        match.end == value.length;
  }

  static bool _isValidRouteForType(AppNotificationType type, String route) {
    return switch (type) {
      AppNotificationType.habitReminder => route == habitsRoute,
      AppNotificationType.focusCompletion => route == focusRoute,
      AppNotificationType.test => route == settingsRoute,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppNotificationPayload &&
            other.type == type &&
            other.entityId == entityId &&
            other.route == route &&
            other.action == action;
  }

  @override
  int get hashCode => Object.hash(type, entityId, route, action);
}
