import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

abstract final class AppTheme {
  static ThemeData light({
    Color accentColor = const Color(0xFF2E6B5A),
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    final scaffoldBackgroundColor = _resolveCanvasColor(
      color: backgroundColor,
      fallback: const Color(0xFFFBFAF7),
      brightness: Brightness.light,
    );
    final resolvedSurfaceColor = _resolveSurfaceColor(
      color: surfaceColor,
      fallback: const Color(0xFFF7F5EF),
      brightness: Brightness.light,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
      surface: resolvedSurfaceColor,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
    );
  }

  static ThemeData dark({
    Color accentColor = const Color(0xFF2E6B5A),
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    final scaffoldBackgroundColor = _resolveCanvasColor(
      color: backgroundColor,
      fallback: const Color(0xFF101311),
      brightness: Brightness.dark,
    );
    final resolvedSurfaceColor = _resolveSurfaceColor(
      color: surfaceColor,
      fallback: const Color(0xFF171A18),
      brightness: Brightness.dark,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      surface: resolvedSurfaceColor,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
  }) {
    final borderTone = AppThemeTokens.borderTone(colorScheme);
    final selectedTone = AppThemeTokens.selectedStateTone(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: scaffoldBackgroundColor,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
          side: BorderSide(color: borderTone),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: selectedTone,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0.1,
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          ),
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.36)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: selectedTone,
        checkmarkColor: colorScheme.primary,
        side: BorderSide(color: borderTone.withValues(alpha: 0.72)),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeTokens.softSurfaceTone(colorScheme),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          borderSide: BorderSide(color: borderTone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: colorScheme.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppThemeTokens.radiusXl),
          ),
        ),
      ),
    );
  }

  static Color _resolveCanvasColor({
    required Color? color,
    required Color fallback,
    required Brightness brightness,
  }) {
    return _restrainedThemeColor(
      color: color,
      fallback: fallback,
      brightness: brightness,
      lightBlend: 0.82,
      darkBlend: 0.82,
    );
  }

  static Color _resolveSurfaceColor({
    required Color? color,
    required Color fallback,
    required Brightness brightness,
  }) {
    return _restrainedThemeColor(
      color: color,
      fallback: fallback,
      brightness: brightness,
      lightBlend: 0.7,
      darkBlend: 0.72,
    );
  }

  static Color _restrainedThemeColor({
    required Color? color,
    required Color fallback,
    required Brightness brightness,
    required double lightBlend,
    required double darkBlend,
  }) {
    if (color == null) {
      return fallback;
    }

    final anchor = brightness == Brightness.light ? Colors.white : Colors.black;
    final amount = brightness == Brightness.light ? lightBlend : darkBlend;
    return Color.lerp(color, anchor, amount) ?? fallback;
  }
}
