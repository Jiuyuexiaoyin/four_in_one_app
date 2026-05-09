import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

int activityIntensityLevel(int count) {
  if (count <= 0) {
    return 0;
  }

  if (count == 1) {
    return 1;
  }

  if (count == 2) {
    return 2;
  }

  return 3;
}

class MiniHeatmapCell extends StatelessWidget {
  const MiniHeatmapCell({
    required this.count,
    this.dateLabel,
    this.today = false,
    this.height = 16,
    this.borderRadius = AppThemeTokens.radiusPill,
    this.accentColor,
    this.semanticLabel,
    super.key,
  });

  final int count;
  final String? dateLabel;
  final bool today;
  final double height;
  final double borderRadius;
  final Color? accentColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = dateLabel;
    final cell = Container(
      height: height,
      alignment: Alignment.center,
      padding: label == null
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: _activityFillColor(colorScheme, count, accentColor),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: today
              ? (accentColor ?? colorScheme.primary)
              : _activityBorderColor(colorScheme, count, accentColor),
          width: today ? 1.4 : 1,
        ),
      ),
      child: label == null
          ? null
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _activityTextColor(colorScheme, count, accentColor),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
    );

    if (semanticLabel == null) {
      return cell;
    }

    return Semantics(label: semanticLabel, child: cell);
  }
}

Color _activityFillColor(
  ColorScheme colorScheme,
  int count,
  Color? accentColor,
) {
  final accent = accentColor ?? colorScheme.primary;

  return switch (activityIntensityLevel(count)) {
    0 => colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
    1 => accent.withValues(alpha: 0.18),
    2 => accent.withValues(alpha: 0.42),
    _ => accent.withValues(alpha: 0.68),
  };
}

Color _activityBorderColor(
  ColorScheme colorScheme,
  int count,
  Color? accentColor,
) {
  final accent = accentColor ?? colorScheme.primary;

  return switch (activityIntensityLevel(count)) {
    0 => AppThemeTokens.borderTone(colorScheme),
    1 => accent.withValues(alpha: 0.26),
    2 => accent.withValues(alpha: 0.42),
    _ => accent.withValues(alpha: 0.56),
  };
}

Color _activityTextColor(
  ColorScheme colorScheme,
  int count,
  Color? accentColor,
) {
  final accent = accentColor ?? colorScheme.primary;

  return switch (activityIntensityLevel(count)) {
    0 => AppThemeTokens.secondaryTextTone(colorScheme),
    1 => accent,
    _ => _readableTextOn(accent),
  };
}

Color _readableTextOn(Color color) {
  final base = color.computeLuminance() > 0.48 ? Colors.black : Colors.white;
  return base.withValues(alpha: 0.86);
}
