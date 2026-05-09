import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/data/app_settings_local_storage.dart';

void main() {
  test('loads default settings when storage is empty', () async {
    final storage = AppSettingsLocalStorage(
      store: _FakeSettingsKeyValueStore(),
    );

    final store = await AppSettingsStore.load(storage);

    expect(store.themeMode, AppThemeMode.system);
    expect(
      store.accentColor.toARGB32(),
      AppSettingsStore.defaultAccentColor.toARGB32(),
    );
    expect(store.backgroundColorValue, isNull);
    expect(store.surfaceColorValue, isNull);
  });

  test('persists and restores theme mode selection', () async {
    final keyValueStore = _FakeSettingsKeyValueStore();
    final storage = AppSettingsLocalStorage(store: keyValueStore);
    final store = await AppSettingsStore.load(storage);

    await store.setThemeMode(AppThemeMode.dark);

    expect(keyValueStore.strings[AppSettingsLocalStorage.themeModeKey], 'dark');

    final restoredStore = await AppSettingsStore.load(storage);

    expect(restoredStore.themeMode, AppThemeMode.dark);
  });

  test('persists and restores accent color selection', () async {
    final keyValueStore = _FakeSettingsKeyValueStore();
    final storage = AppSettingsLocalStorage(store: keyValueStore);
    final store = await AppSettingsStore.load(storage);
    const accentColor = Color(0xFF6E7E9E);

    await store.setAccentColor(accentColor);

    expect(
      keyValueStore.ints[AppSettingsLocalStorage.accentColorKey],
      accentColor.toARGB32(),
    );

    final restoredStore = await AppSettingsStore.load(storage);

    expect(restoredStore.accentColor.toARGB32(), accentColor.toARGB32());
  });

  test('persists and restores custom color targets', () async {
    final keyValueStore = _FakeSettingsKeyValueStore();
    final storage = AppSettingsLocalStorage(store: keyValueStore);
    final store = await AppSettingsStore.load(storage);
    const accentColor = Color(0xFF123456);
    const backgroundColor = Color(0xFFB9A26B);
    const surfaceColor = Color(0xFF6E7E9E);

    await store.setAccentColor(accentColor);
    await store.setBackgroundColor(backgroundColor);
    await store.setSurfaceColor(surfaceColor);

    expect(
      keyValueStore.ints[AppSettingsLocalStorage.accentColorKey],
      accentColor.toARGB32(),
    );
    expect(
      keyValueStore.ints[AppSettingsLocalStorage.backgroundColorKey],
      backgroundColor.toARGB32(),
    );
    expect(
      keyValueStore.ints[AppSettingsLocalStorage.surfaceColorKey],
      surfaceColor.toARGB32(),
    );

    final restoredStore = await AppSettingsStore.load(storage);

    expect(restoredStore.accentColor.toARGB32(), accentColor.toARGB32());
    expect(
      restoredStore.customBackgroundColor?.toARGB32(),
      backgroundColor.toARGB32(),
    );
    expect(
      restoredStore.customSurfaceColor?.toARGB32(),
      surfaceColor.toARGB32(),
    );
  });

  test('reset colors removes custom color values from storage', () async {
    final keyValueStore = _FakeSettingsKeyValueStore();
    final storage = AppSettingsLocalStorage(store: keyValueStore);
    final store = await AppSettingsStore.load(storage);

    await store.setAccentColor(const Color(0xFF123456));
    await store.setBackgroundColor(const Color(0xFFB9A26B));
    await store.setSurfaceColor(const Color(0xFF6E7E9E));
    await store.resetAllColors();

    expect(
      keyValueStore.ints.containsKey(AppSettingsLocalStorage.accentColorKey),
      isFalse,
    );
    expect(
      keyValueStore.ints.containsKey(
        AppSettingsLocalStorage.backgroundColorKey,
      ),
      isFalse,
    );
    expect(
      keyValueStore.ints.containsKey(AppSettingsLocalStorage.surfaceColorKey),
      isFalse,
    );
  });

  test('falls back to safe defaults for malformed persisted colors', () async {
    final keyValueStore = _FakeSettingsKeyValueStore()
      ..ints[AppSettingsLocalStorage.accentColorKey] = 0x0000FFFF
      ..ints[AppSettingsLocalStorage.backgroundColorKey] = -1
      ..ints[AppSettingsLocalStorage.surfaceColorKey] = 0x12000000;
    final storage = AppSettingsLocalStorage(store: keyValueStore);

    final store = await AppSettingsStore.load(storage);

    expect(
      store.accentColor.toARGB32(),
      AppSettingsStore.defaultAccentColor.toARGB32(),
    );
    expect(store.backgroundColorValue, isNull);
    expect(store.surfaceColorValue, isNull);
  });
}

class _FakeSettingsKeyValueStore implements AppSettingsKeyValueStore {
  final strings = <String, String>{};
  final ints = <String, int>{};

  @override
  Future<String?> getString(String key) async {
    return strings[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    strings[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return ints[key];
  }

  @override
  Future<void> setInt(String key, int value) async {
    ints[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    strings.remove(key);
    ints.remove(key);
  }
}
