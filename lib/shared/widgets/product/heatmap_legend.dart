import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/mini_heatmap_cell.dart';

/// Shared activity-intensity legend used alongside year and month heatmaps.
///
/// Renders the four canonical [MiniHeatmapCell] intensity levels (0 / 1 / 2 / 3+)
/// with a leading "少" and trailing "多" label so Habits and Goals year
/// heatmaps can present a single, consistent legend instead of separate
/// inline implementations.
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({
    this.accentColor,
    this.leadingLabel = '少',
    this.trailingLabel = '多',
    this.cellSize = 12,
    this.cellRadius = AppThemeTokens.radiusPill,
    super.key,
  });

  final Color? accentColor;
  final String leadingLabel;
  final String trailingLabel;
  final double cellSize;
  final double cellRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppThemeTokens.secondaryTextTone(colorScheme),
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(leadingLabel, style: labelStyle),
        const SizedBox(width: AppThemeTokens.spaceXs),
        for (final intensity in const <int>[0, 1, 2, 3]) ...[
          SizedBox(
            width: cellSize,
            child: MiniHeatmapCell(
              count: intensity,
              height: cellSize,
              borderRadius: cellRadius,
              accentColor: accentColor,
            ),
          ),
          if (intensity != 3) const SizedBox(width: AppThemeTokens.space2xs),
        ],
        const SizedBox(width: AppThemeTokens.spaceXs),
        Text(trailingLabel, style: labelStyle),
      ],
    );
  }
}
