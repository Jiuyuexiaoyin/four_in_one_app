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

  static Color borderTone(ColorScheme colorScheme) {
    return colorScheme.outlineVariant.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.36 : 0.48,
    );
  }

  static Color secondaryTextTone(ColorScheme colorScheme) {
    return colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
  }

  static Color selectedStateTone(ColorScheme colorScheme) {
    return colorScheme.primaryContainer.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.34,
    );
  }

  static Color softSurfaceTone(ColorScheme colorScheme) {
    return colorScheme.surfaceContainerLow.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.56 : 0.66,
    );
  }

  static Color accentChartLine(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(alpha: 0.72);
  }

  static Color accentChartFill(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(alpha: 0.14);
  }

  static Color accentHeroHalo(ColorScheme colorScheme) {
    return colorScheme.primary.withValues(alpha: 0.18);
  }

  static Color quietDividerTone(ColorScheme colorScheme) {
    return colorScheme.onSurface.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.08 : 0.06,
    );
  }
}
