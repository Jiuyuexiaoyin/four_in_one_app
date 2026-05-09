import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

class AnalyticsBarListItem {
  const AnalyticsBarListItem({
    required this.label,
    required this.value,
    this.color,
    this.valueKey,
  });

  final String label;
  final int value;
  final Color? color;
  final String? valueKey;
}

class AnalyticsBarList extends StatelessWidget {
  const AnalyticsBarList({
    required this.items,
    this.accentColor,
    this.maxValue,
    this.emptyText = '暂无数据',
    super.key,
  });

  final List<AnalyticsBarListItem> items;
  final Color? accentColor;
  final int? maxValue;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final safeItems = items
        .where((item) => item.value >= 0)
        .toList(growable: false);
    final largestValue = safeItems.fold<int>(
      maxValue ?? 0,
      (current, item) => math.max(current, item.value),
    );

    if (safeItems.isEmpty || largestValue <= 0) {
      return Text(
        emptyText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: [
        for (final item in safeItems) ...[
          _AnalyticsBarListRow(
            item: item,
            maxValue: largestValue,
            accentColor: accentColor,
          ),
          if (item != safeItems.last)
            const SizedBox(height: AppThemeTokens.spaceSm),
        ],
      ],
    );
  }
}

class _AnalyticsBarListRow extends StatelessWidget {
  const _AnalyticsBarListRow({
    required this.item,
    required this.maxValue,
    required this.accentColor,
  });

  final AnalyticsBarListItem item;
  final int maxValue;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccent = item.color ?? accentColor ?? colorScheme.primary;
    final ratio = maxValue <= 0
        ? 0.0
        : (item.value / maxValue).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppThemeTokens.spaceSm),
            Text(
              '${item.value}',
              key: item.valueKey == null
                  ? null
                  : ValueKey<String>(item.valueKey!),
              style: theme.textTheme.labelMedium?.copyWith(
                color: effectiveAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          child: Container(
            height: 8,
            color: AppThemeTokens.borderTone(colorScheme).withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.32 : 0.46,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(
                    alpha: colorScheme.brightness == Brightness.dark
                        ? 0.74
                        : 0.82,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
