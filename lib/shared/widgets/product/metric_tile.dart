import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

enum MetricTileEmphasis { standard, hero }

class MetricTileData {
  const MetricTileData({
    required this.value,
    required this.label,
    this.valueKey,
  });

  final String value;
  final String label;
  final String? valueKey;
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.value,
    required this.label,
    this.valueKey,
    this.width = 124,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.emphasis = MetricTileEmphasis.standard,
    super.key,
  });

  final String value;
  final String label;
  final String? valueKey;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final MetricTileEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: backgroundColor ?? _defaultBackground(context, colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color:
              borderColor ??
              AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: valueKey == null ? null : ValueKey<String>(valueKey!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _valueStyle(theme, colorScheme),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Color _defaultBackground(BuildContext context, ColorScheme colorScheme) {
    return Theme.of(context).scaffoldBackgroundColor.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.12 : 0.42,
    );
  }

  TextStyle? _valueStyle(ThemeData theme, ColorScheme colorScheme) {
    switch (emphasis) {
      case MetricTileEmphasis.hero:
        return theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: colorScheme.onSurface,
        );
      case MetricTileEmphasis.standard:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.55,
        );
    }
  }
}
