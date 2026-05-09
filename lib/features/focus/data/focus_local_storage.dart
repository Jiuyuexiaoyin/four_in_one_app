import 'dart:convert';

import 'package:four_in_one_app/features/focus/domain/models/focus_active_session.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FocusStorage {
  Future<List<FocusSessionItem>> loadSessions();

  Future<void> saveSessions(List<FocusSessionItem> sessions);

  Future<int?> loadSelectedDurationSeconds();

  Future<void> saveSelectedDurationSeconds(int durationSeconds);

  Future<FocusActiveSession?> loadActiveSession();

  Future<void> saveActiveSession(FocusActiveSession session);

  Future<void> clearActiveSession();
}

abstract interface class FocusKeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

class FocusLocalStorage implements FocusStorage {
  FocusLocalStorage({FocusKeyValueStore? store})
    : _store = store ?? _SharedPreferencesAsyncStore();

  static const storageKey = 'focus.history.json';
  static const activeStorageKey = 'focus.active.json';
  static const selectedDurationStorageKey = 'focus.selected_duration_seconds';
  static const maxSessions = 100;
  static const minDurationSeconds = 60;
  static const maxDurationSeconds = 180 * 60;

  final FocusKeyValueStore _store;

  @override
  Future<List<FocusSessionItem>> loadSessions() async {
    try {
      final payload = await _store.getString(storageKey);
      if (payload == null || payload.isEmpty) {
        return const <FocusSessionItem>[];
      }

      final decoded = jsonDecode(payload);
      if (decoded is! List<dynamic>) {
        return const <FocusSessionItem>[];
      }

      final sessions = decoded
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Focus history contains an invalid item.',
              );
            }

            return FocusSessionItem.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);

      return normalizeSessions(sessions);
    } catch (_) {
      return const <FocusSessionItem>[];
    }
  }

  @override
  Future<void> saveSessions(List<FocusSessionItem> sessions) async {
    final normalizedSessions = normalizeSessions(sessions);
    final payload = jsonEncode(
      normalizedSessions
          .map((session) => session.toJson())
          .toList(growable: false),
    );

    await _store.setString(storageKey, payload);
  }

  @override
  Future<int?> loadSelectedDurationSeconds() async {
    try {
      final payload = await _store.getString(selectedDurationStorageKey);
      final durationSeconds = int.tryParse(payload ?? '');

      if (durationSeconds == null ||
          durationSeconds < minDurationSeconds ||
          durationSeconds > maxDurationSeconds ||
          durationSeconds % 60 != 0) {
        return null;
      }

      return durationSeconds;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSelectedDurationSeconds(int durationSeconds) {
    return _store.setString(
      selectedDurationStorageKey,
      durationSeconds.toString(),
    );
  }

  @override
  Future<FocusActiveSession?> loadActiveSession() async {
    try {
      final payload = await _store.getString(activeStorageKey);
      if (payload == null || payload.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return null;
      }

      return FocusActiveSession.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveActiveSession(FocusActiveSession session) async {
    await _store.setString(activeStorageKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clearActiveSession() {
    return _store.remove(activeStorageKey);
  }

  static List<FocusSessionItem> normalizeSessions(
    List<FocusSessionItem> sessions,
  ) {
    final sortedSessions = List<FocusSessionItem>.of(sessions)
      ..sort((a, b) {
        final timeComparison = b.completedAt.compareTo(a.completedAt);
        if (timeComparison != 0) {
          return timeComparison;
        }

        return b.id.compareTo(a.id);
      });

    return sortedSessions.take(maxSessions).toList(growable: false);
  }
}

class _SharedPreferencesAsyncStore implements FocusKeyValueStore {
  _SharedPreferencesAsyncStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(key);
  }
}
