import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/mini_heatmap_cell.dart';

class ActivityStripItem {
  const ActivityStripItem({
    required this.count,
    this.label,
    this.cellKey,
    this.semanticLabel,
    this.labelEmphasized = false,
  });

  final int count;
  final String? label;
  final Key? cellKey;
  final String? semanticLabel;
  final bool labelEmphasized;
}

class ActivityStrip extends StatelessWidget {
  const ActivityStrip({
    required this.items,
    this.dayCount = 7,
    this.valueKey,
    this.cellHeight = 16,
    this.cellBorderRadius = AppThemeTokens.radiusPill,
    this.spacing = AppThemeTokens.spaceXs,
    this.accentColor,
    super.key,
  });

  final List<ActivityStripItem> items;
  final int dayCount;
  final String? valueKey;
  final double cellHeight;
  final double cellBorderRadius;
  final double spacing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(dayCount).toList(growable: false);
    final showLabels = visibleItems.any((item) => item.label != null);

    return Row(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      children: [
        for (var index = 0; index < visibleItems.length; index += 1) ...[
          Expanded(
            child: _ActivityStripCell(
              item: visibleItems[index],
              showLabel: showLabels,
              cellHeight: cellHeight,
              cellBorderRadius: cellBorderRadius,
              accentColor: accentColor,
            ),
          ),
          if (index != visibleItems.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _ActivityStripCell extends StatelessWidget {
  const _ActivityStripCell({
    required this.item,
    required this.showLabel,
    required this.cellHeight,
    required this.cellBorderRadius,
    required this.accentColor,
  });

  final ActivityStripItem item;
  final bool showLabel;
  final double cellHeight;
  final double cellBorderRadius;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final label = item.label;
    final cell = MiniHeatmapCell(
      key: item.cellKey,
      count: item.count,
      height: cellHeight,
      borderRadius: cellBorderRadius,
      accentColor: accentColor,
      semanticLabel: item.semanticLabel,
    );

    if (!showLabel) {
      return cell;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        cell,
        const SizedBox(height: AppThemeTokens.spaceXs),
        Text(
          label ?? '',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: item.labelEmphasized
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
