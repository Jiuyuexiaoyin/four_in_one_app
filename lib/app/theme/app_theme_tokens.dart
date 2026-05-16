import 'package:flutter/material.dart';

abstract final class AppThemeTokens {
  static const double spaceXs = 4;
  static const double space2xs = 6;
  static const double spaceSm = 8;
  static const double spaceSm2 = 10;
  static const double spaceMd = 12;
  static const double spaceMd2 = 14;
  static const double spaceLg = 16;
  static const double spaceLg2 = 18;
  static const double spaceXl = 20;
  static const double pagePadding = 22;

  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  static const Color premiumGraphite = Color(0xFF06080B);
  static const Color premiumCanvas = Color(0xFF090D11);
  static const Color premiumSurface = Color(0xFF11161C);
  static const Color premiumSurfaceHigh = Color(0xFF171D24);
  static const Color premiumSurfacePeak = Color(0xFF202832);
  static const Color premiumAccent = Color(0xFF8FE6D3);
  static const Color premiumSecondary = Color(0xFFE5F477);

  static Color borderTone(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return Colors.white.withValues(alpha: 0.105);
    }

    return colorScheme.outlineVariant.withValues(alpha: 0.48);
  }

  static Color secondaryTextTone(ColorScheme colorScheme) {
    return colorScheme.onSurfaceVariant.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.80 : 0.72,
    );
  }

  static Color selectedStateTone(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return colorScheme.primary.withValues(alpha: 0.16);
    }

    return colorScheme.primaryContainer.withValues(alpha: 0.34);
  }

  static Color softSurfaceTone(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return colorScheme.surface;
    }

    return colorScheme.surfaceContainerLow.withValues(alpha: 0.66);
  }

  static Color elevatedSurfaceTone(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surface;
  }

  static Color heroSurfaceTone(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerLow;
  }

  static LinearGradient pageBackgroundGradient(ColorScheme colorScheme) {
    if (colorScheme.brightness != Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colorScheme.surface, colorScheme.surfaceContainerLowest],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
              colorScheme.surfaceContainerLowest,
              colorScheme.primary,
              0.08,
            ) ??
            colorScheme.surfaceContainerLowest,
        colorScheme.surfaceContainerLowest,
        colorScheme.surface,
      ],
      stops: const [0.0, 0.54, 1.0],
    );
  }

  static LinearGradient premiumPanelGradient(ColorScheme colorScheme) {
    if (colorScheme.brightness != Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surfaceContainerHigh,
        colorScheme.surface,
        colorScheme.surfaceContainerLowest,
      ],
      stops: const [0.0, 0.62, 1.0],
    );
  }

  static LinearGradient premiumHeroGradient(ColorScheme colorScheme) {
    if (colorScheme.brightness != Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primaryContainer, colorScheme.surface],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withValues(alpha: 0.20),
        colorScheme.surfaceContainerHighest,
        colorScheme.surfaceContainerLowest,
      ],
      stops: const [0.0, 0.36, 1.0],
    );
  }

  static Color accentChartLine(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(alpha: 0.72);
  }

  static Color accentChartFill(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(alpha: 0.14);
  }

  static Color accentHeroHalo(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.28 : 0.18,
    );
  }

  static Color quietDividerTone(ColorScheme colorScheme) {
    return colorScheme.onSurface.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.08 : 0.06,
    );
  }
}
