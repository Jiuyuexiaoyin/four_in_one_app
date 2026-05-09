import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppSettingsKeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<int?> getInt(String key);

  Future<void> setInt(String key, int value);

  Future<void> remove(String key);
}

class AppSettingsLocalStorage implements AppSettingsStorage {
  AppSettingsLocalStorage({AppSettingsKeyValueStore? store})
    : _store = store ?? _SharedPreferencesAsyncStore();

  static const themeModeKey = 'app.theme_mode';
  static const accentColorKey = 'app.accent_color';
  static const backgroundColorKey = 'app.background_color';
  static const surfaceColorKey = 'app.surface_color';

  final AppSettingsKeyValueStore _store;

  @override
  Future<AppSettingsSnapshot> loadSettings() async {
    try {
      final themeModeValue = await _store.getString(themeModeKey);
      final accentColorValue = await _store.getInt(accentColorKey);
      final backgroundColorValue = await _store.getInt(backgroundColorKey);
      final surfaceColorValue = await _store.getInt(surfaceColorKey);

      return AppSettingsSnapshot(
        themeMode: AppThemeMode.fromStorageValue(themeModeValue),
        accentColorValue: AppSettingsStore.normalizeColorValue(
          accentColorValue,
        ),
        backgroundColorValue: AppSettingsStore.normalizeColorValue(
          backgroundColorValue,
        ),
        surfaceColorValue: AppSettingsStore.normalizeColorValue(
          surfaceColorValue,
        ),
      );
    } catch (_) {
      return AppSettingsSnapshot.defaults;
    }
  }

  @override
  Future<void> saveSettings(AppSettingsSnapshot settings) async {
    await _store.setString(themeModeKey, settings.themeMode.storageValue);
    await _saveNullableInt(accentColorKey, settings.accentColorValue);
    await _saveNullableInt(backgroundColorKey, settings.backgroundColorValue);
    await _saveNullableInt(surfaceColorKey, settings.surfaceColorValue);
  }

  Future<void> _saveNullableInt(String key, int? value) async {
    final normalizedValue = AppSettingsStore.normalizeColorValue(value);
    if (normalizedValue == null) {
      await _store.remove(key);
      return;
    }

    await _store.setInt(key, normalizedValue);
  }
}

class _SharedPreferencesAsyncStore implements AppSettingsKeyValueStore {
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
  Future<int?> getInt(String key) {
    return _preferences.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(key);
  }
}
