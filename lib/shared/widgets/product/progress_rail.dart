import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

class ProgressRail extends StatelessWidget {
  const ProgressRail({
    this.value,
    this.fillColor,
    this.backgroundColor,
    this.height = 6,
    this.neutralLabel,
    this.semanticLabel,
    super.key,
  });

  final double? value;
  final Color? fillColor;
  final Color? backgroundColor;
  final double height;
  final String? neutralLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final boundedValue = value?.clamp(0.0, 1.0).toDouble();
    final rail = ClipRRect(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      child: LinearProgressIndicator(
        minHeight: height,
        value: boundedValue ?? 0,
        backgroundColor: backgroundColor ?? _defaultTrackColor(colorScheme),
        valueColor: AlwaysStoppedAnimation<Color>(
          fillColor ?? colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    );

    final neutralLabel = this.neutralLabel;
    final content = neutralLabel == null || boundedValue != null
        ? rail
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              rail,
              const SizedBox(height: AppThemeTokens.spaceXs),
              Text(
                neutralLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
            ],
          );

    if (semanticLabel == null) {
      return content;
    }

    return Semantics(label: semanticLabel, child: content);
  }

  Color _defaultTrackColor(ColorScheme colorScheme) {
    return AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.36);
  }
}
