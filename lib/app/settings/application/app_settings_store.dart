import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  String get storageValue {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  ThemeMode get materialThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromStorageValue(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.themeMode,
    this.accentColorValue,
    this.backgroundColorValue,
    this.surfaceColorValue,
  });

  static const defaults = AppSettingsSnapshot(themeMode: AppThemeMode.system);

  final AppThemeMode themeMode;
  final int? accentColorValue;
  final int? backgroundColorValue;
  final int? surfaceColorValue;

  AppSettingsSnapshot copyWith({
    AppThemeMode? themeMode,
    int? accentColorValue,
    int? backgroundColorValue,
    int? surfaceColorValue,
    bool clearAccentColor = false,
    bool clearBackgroundColor = false,
    bool clearSurfaceColor = false,
  }) {
    return AppSettingsSnapshot(
      themeMode: themeMode ?? this.themeMode,
      accentColorValue: clearAccentColor
          ? null
          : accentColorValue ?? this.accentColorValue,
      backgroundColorValue: clearBackgroundColor
          ? null
          : backgroundColorValue ?? this.backgroundColorValue,
      surfaceColorValue: clearSurfaceColor
          ? null
          : surfaceColorValue ?? this.surfaceColorValue,
    );
  }
}

abstract interface class AppSettingsStorage {
  Future<AppSettingsSnapshot> loadSettings();

  Future<void> saveSettings(AppSettingsSnapshot settings);
}

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._({
    required AppSettingsSnapshot settings,
    AppSettingsStorage? storage,
  }) : _settings = settings,
       _storage = storage;

  factory AppSettingsStore.inMemory({
    AppThemeMode themeMode = AppThemeMode.system,
    Color accentColor = defaultAccentColor,
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    return AppSettingsStore._(
      settings: AppSettingsSnapshot(
        themeMode: themeMode,
        accentColorValue: _normalizeCustomColor(accentColor)?.toARGB32(),
        backgroundColorValue: _normalizeCustomColor(
          backgroundColor,
        )?.toARGB32(),
        surfaceColorValue: _normalizeCustomColor(surfaceColor)?.toARGB32(),
      ),
    );
  }

  static Future<AppSettingsStore> load(AppSettingsStorage storage) async {
    final settings = await storage.loadSettings();

    return AppSettingsStore._(
      settings: _normalizeSnapshot(settings),
      storage: storage,
    );
  }

  static const defaultAccentColor = Color(0xFF2E6B5A);
  static const Color defaultLightBackgroundColor = Color(0xFFFBFAF7);
  static const Color defaultDarkBackgroundColor = Color(0xFF101311);
  static const Color defaultLightSurfaceColor = Color(0xFFF7F5EF);
  static const Color defaultDarkSurfaceColor = Color(0xFF171A18);

  static const accentColorPresets = <Color>[
    Color(0xFF2E6B5A),
    Color(0xFF6F7F69),
    Color(0xFF6E7E9E),
    Color(0xFF8A6F6A),
    Color(0xFF7A6F8F),
  ];

  static const calmColorPresets = <Color>[
    Color(0xFF2E6B5A),
    Color(0xFF6F7F69),
    Color(0xFF6E7E9E),
    Color(0xFF8A6F6A),
    Color(0xFF7A6F8F),
    Color(0xFFB9A26B),
    Color(0xFFD08A52),
    Color(0xFF4F8D8B),
  ];

  final AppSettingsStorage? _storage;
  AppSettingsSnapshot _settings;

  AppThemeMode get themeMode => _settings.themeMode;

  ThemeMode get materialThemeMode => themeMode.materialThemeMode;

  int? get accentColorValue => _settings.accentColorValue;

  int? get backgroundColorValue => _settings.backgroundColorValue;

  int? get surfaceColorValue => _settings.surfaceColorValue;

  Color get accentColor =>
      colorFromValue(accentColorValue) ?? defaultAccentColor;

  Color? get customBackgroundColor => colorFromValue(backgroundColorValue);

  Color? get customSurfaceColor => colorFromValue(surfaceColorValue);

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_settings.themeMode == themeMode) {
      return;
    }

    _settings = _settings.copyWith(themeMode: themeMode);
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> setAccentColor(Color accentColor) async {
    final normalizedAccent = _normalizeCustomColor(accentColor);
    if (normalizedAccent == null) {
      return;
    }
    if (_settings.accentColorValue == normalizedAccent.toARGB32()) {
      return;
    }

    _settings = _settings.copyWith(
      accentColorValue: normalizedAccent.toARGB32(),
    );
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> setBackgroundColor(Color backgroundColor) async {
    final normalizedBackground = _normalizeCustomColor(backgroundColor);
    if (normalizedBackground == null) {
      return;
    }
    if (_settings.backgroundColorValue == normalizedBackground.toARGB32()) {
      return;
    }

    _settings = _settings.copyWith(
      backgroundColorValue: normalizedBackground.toARGB32(),
    );
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> setSurfaceColor(Color surfaceColor) async {
    final normalizedSurface = _normalizeCustomColor(surfaceColor);
    if (normalizedSurface == null) {
      return;
    }
    if (_settings.surfaceColorValue == normalizedSurface.toARGB32()) {
      return;
    }

    _settings = _settings.copyWith(
      surfaceColorValue: normalizedSurface.toARGB32(),
    );
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> resetAccentColor() async {
    if (_settings.accentColorValue == null) {
      return;
    }

    _settings = _settings.copyWith(clearAccentColor: true);
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> resetBackgroundColor() async {
    if (_settings.backgroundColorValue == null) {
      return;
    }

    _settings = _settings.copyWith(clearBackgroundColor: true);
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> resetSurfaceColor() async {
    if (_settings.surfaceColorValue == null) {
      return;
    }

    _settings = _settings.copyWith(clearSurfaceColor: true);
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  Future<void> resetAllColors() async {
    if (_settings.accentColorValue == null &&
        _settings.backgroundColorValue == null &&
        _settings.surfaceColorValue == null) {
      return;
    }

    _settings = _settings.copyWith(
      clearAccentColor: true,
      clearBackgroundColor: true,
      clearSurfaceColor: true,
    );
    notifyListeners();
    await _storage?.saveSettings(_settings);
  }

  static bool isSupportedAccentColor(Color color) {
    return accentColorPresets.any((preset) => _sameColor(preset, color));
  }

  static Color? colorFromValue(int? value) {
    if (value == null || !_isValidColorValue(value)) {
      return null;
    }

    return Color(value);
  }

  static int? normalizeColorValue(int? value) {
    final color = colorFromValue(value);
    return color?.toARGB32();
  }

  static AppSettingsSnapshot _normalizeSnapshot(AppSettingsSnapshot settings) {
    return AppSettingsSnapshot(
      themeMode: settings.themeMode,
      accentColorValue: normalizeColorValue(settings.accentColorValue),
      backgroundColorValue: normalizeColorValue(settings.backgroundColorValue),
      surfaceColorValue: normalizeColorValue(settings.surfaceColorValue),
    );
  }

  static Color? _normalizeCustomColor(Color? color) {
    if (color == null) {
      return null;
    }

    return colorFromValue(color.toARGB32());
  }

  static bool _isValidColorValue(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      return false;
    }

    final alpha = (value >> 24) & 0xFF;
    return alpha >= 0xCC;
  }

  static bool _sameColor(Color a, Color b) {
    return a.toARGB32() == b.toARGB32();
  }
}
