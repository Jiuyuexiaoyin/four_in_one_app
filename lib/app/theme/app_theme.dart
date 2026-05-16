import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

abstract final class AppTheme {
  static ThemeData light({
    Color accentColor = AppThemeTokens.premiumAccent,
    Color? backgroundColor,
    Color? surfaceColor,
  }) {
    final scaffoldBackgroundColor = _resolveCanvasColor(
      color: backgroundColor,
      fallback: AppThemeTokens.premiumCanvas,
      brightness: Brightness.dark,
    );
    final resolvedSurfaceColor = _resolveSurfaceColor(
      color: surfaceColor,
      fallback: AppThemeTokens.premiumSurface,
      brightness: Brightness.dark,
    );
    final colorScheme = _premiumDarkScheme(
      accentColor: accentColor,
      canvasColor: scaffoldBackgroundColor,
      surfaceColor: resolvedSurfaceColor,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
    );
  }

  static ThemeData dark({
    Color accentColor = AppThemeTokens.premiumAccent,
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
    final colorScheme = _premiumDarkScheme(
      accentColor: accentColor,
      canvasColor: scaffoldBackgroundColor,
      surfaceColor: resolvedSurfaceColor,
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

    final textTheme =
        Typography.material2021(
          platform: TargetPlatform.android,
          colorScheme: colorScheme,
        ).white.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.24,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
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
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.10),
        height: 56,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            letterSpacing: 0,
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
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
        backgroundColor: AppThemeTokens.elevatedSurfaceTone(colorScheme),
        disabledColor: colorScheme.surfaceContainer.withValues(alpha: 0.48),
        side: BorderSide(color: borderTone.withValues(alpha: 0.90)),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeTokens.elevatedSurfaceTone(colorScheme),
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
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
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

  static ColorScheme _premiumDarkScheme({
    required Color accentColor,
    required Color canvasColor,
    required Color surfaceColor,
  }) {
    final surfaceLow = Color.lerp(canvasColor, surfaceColor, 0.36)!;
    final surfaceHigh = Color.lerp(surfaceColor, Colors.white, 0.06)!;
    final surfacePeak = Color.lerp(surfaceColor, Colors.white, 0.10)!;

    return ColorScheme(
      brightness: Brightness.dark,
      primary: accentColor,
      onPrimary: const Color(0xFF03110F),
      primaryContainer: accentColor.withValues(alpha: 0.22),
      onPrimaryContainer: const Color(0xFFE9FFF9),
      secondary: AppThemeTokens.premiumSecondary,
      onSecondary: const Color(0xFF151701),
      secondaryContainer: AppThemeTokens.premiumSecondary.withValues(
        alpha: 0.18,
      ),
      onSecondaryContainer: const Color(0xFFF7FFD4),
      tertiary: const Color(0xFFB6A7FF),
      onTertiary: const Color(0xFF100B2D),
      tertiaryContainer: const Color(0xFF292345),
      onTertiaryContainer: const Color(0xFFF0ECFF),
      error: const Color(0xFFFF8C8C),
      onError: const Color(0xFF250000),
      errorContainer: const Color(0xFF431414),
      onErrorContainer: const Color(0xFFFFDADA),
      surface: surfaceColor,
      onSurface: const Color(0xFFECEFF2),
      onSurfaceVariant: const Color(0xFFA8B2BD),
      outline: Colors.white.withValues(alpha: 0.22),
      outlineVariant: Colors.white.withValues(alpha: 0.12),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFECEFF2),
      onInverseSurface: const Color(0xFF11161C),
      inversePrimary: const Color(0xFF0E6D60),
      surfaceTint: accentColor,
      surfaceContainerLowest: canvasColor,
      surfaceContainerLow: surfaceLow,
      surfaceContainer: surfaceColor,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfacePeak,
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
