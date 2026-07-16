import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

class VisualDnaPageHeader extends StatelessWidget {
  const VisualDnaPageHeader({
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.trailing,
    super.key,
  });

  final String? eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.82),
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class VisualDnaPanel extends StatelessWidget {
  const VisualDnaPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.glow = false,
    this.borderRadius = AppThemeTokens.radiusXl,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final bool glow;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: AppThemeTokens.premiumPanelGradient(colorScheme),
        border: Border.all(
          color: glow
              ? accentColor.withValues(alpha: 0.42)
              : AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: glow ? 0.16 : 0.05),
            blurRadius: glow ? 30 : 14,
            spreadRadius: glow ? -9 : -12,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 18,
            offset: const Offset(0, 12),
            spreadRadius: -18,
          ),
        ],
      ),
      child: child,
    );
  }
}

class VisualDnaMetric {
  const VisualDnaMetric({
    required this.label,
    required this.value,
    this.detail,
    this.valueKey,
    this.accent,
  });

  final String label;
  final String value;
  final String? detail;
  final String? valueKey;
  final Color? accent;
}

class VisualDnaMetricGrid extends StatelessWidget {
  const VisualDnaMetricGrid({
    required this.metrics,
    this.minTileHeight = 82,
    super.key,
  });

  final List<VisualDnaMetric> metrics;
  final double minTileHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columnCount = maxWidth >= 720 ? 4 : (maxWidth >= 360 ? 2 : 1);
        const spacing = 9.0;
        final tileWidth =
            (maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: _VisualDnaMetricTile(
                  metric: metric,
                  minHeight: minTileHeight,
                ),
              ),
          ],
        );
      },
    );
  }
}

class VisualDnaProgressBar extends StatelessWidget {
  const VisualDnaProgressBar({
    required this.value,
    this.height = 8,
    this.accent,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final double height;
  final Color? accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bounded = value.clamp(0.0, 1.0).toDouble();
    final accentColor = accent ?? colorScheme.primary;

    final bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: bounded,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.92),
                colorScheme.secondary.withValues(alpha: 0.86),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.16),
                blurRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );

    return semanticLabel == null
        ? bar
        : Semantics(label: semanticLabel, child: bar);
  }
}

class VisualDnaMiniBars extends StatelessWidget {
  const VisualDnaMiniBars({
    required this.values,
    this.labels = const [],
    this.height = 52,
    this.accent,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final List<String> labels;
  final double height;
  final Color? accent;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final maxValue = math.max(
      1,
      values.fold<int>(0, (current, value) => math.max(current, value)),
    );

    return SizedBox(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      height: labels.isEmpty ? height : height + 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index += 1) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: values[index] / maxValue,
                        widthFactor: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: values[index] == 0
                                ? colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.38)
                                : accentColor.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: values[index] == 0
                                  ? AppThemeTokens.borderTone(colorScheme)
                                  : accentColor.withValues(alpha: 0.26),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (labels.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (index != values.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class VisualDnaHeatmap extends StatelessWidget {
  const VisualDnaHeatmap({
    required this.values,
    this.accent,
    this.cellCount,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final Color? accent;
  final int? cellCount;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final visibleCount = cellCount ?? values.length;
    final visibleValues = values.take(visibleCount).toList(growable: false);
    final maxValue = math.max(
      1,
      visibleValues.fold<int>(0, (current, value) => math.max(current, value)),
    );

    return Wrap(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final value in visibleValues)
          _HeatmapCell(
            value: value,
            intensity: value / maxValue,
            accent: accent,
          ),
      ],
    );
  }
}

class VisualDnaCommandHeader extends StatelessWidget {
  const VisualDnaCommandHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.pills = const <Widget>[],
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final List<Widget> pills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return VisualDnaPanel(
      glow: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                VisualDnaIconPill(icon: leadingIcon!, selected: true),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: pills),
          ],
        ],
      ),
    );
  }
}

class VisualDnaStatusPill extends StatelessWidget {
  const VisualDnaStatusPill({
    required this.label,
    this.value,
    this.icon,
    this.selected = false,
    this.accent,
    this.onTap,
    super.key,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final bool selected;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final foreground = selected ? accentColor : colorScheme.onSurfaceVariant;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? accentColor.withValues(alpha: 0.13)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: selected
              ? accentColor.withValues(alpha: 0.36)
              : AppThemeTokens.borderTone(colorScheme),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? accentColor : colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class VisualDnaIconPill extends StatelessWidget {
  const VisualDnaIconPill({
    required this.icon,
    this.selected = false,
    this.accent,
    this.onTap,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final bool selected;
  final Color? accent;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        foregroundColor: selected ? accentColor : colorScheme.onSurfaceVariant,
        backgroundColor: selected
            ? accentColor.withValues(alpha: 0.14)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          side: BorderSide(
            color: selected
                ? accentColor.withValues(alpha: 0.38)
                : AppThemeTokens.borderTone(colorScheme),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class VisualDnaCommandCard extends StatelessWidget {
  const VisualDnaCommandCard({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.icon,
    this.trailing,
    this.child,
    this.footer,
    this.onTap,
    this.glow = false,
    this.accent,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget? child;
  final Widget? footer;
  final VoidCallback? onTap;
  final bool glow;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = accent ?? colorScheme.primary;

    final body = VisualDnaPanel(
      glow: glow,
      accent: accentColor,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                VisualDnaIconPill(icon: icon!, selected: glow, accent: accent),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                          height: 1.38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          if (child != null) ...[const SizedBox(height: 14), child!],
          if (footer != null) ...[const SizedBox(height: 14), footer!],
        ],
      ),
    );

    if (onTap == null) {
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class VisualDnaProgressRow extends StatelessWidget {
  const VisualDnaProgressRow({
    required this.label,
    required this.value,
    this.detail,
    this.accent,
    this.valueKey,
    super.key,
  });

  final String label;
  final double value;
  final String? detail;
  final Color? accent;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bounded = value.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Text(
              '${(bounded * 100).round()}%',
              key: valueKey == null ? null : ValueKey<String>(valueKey!),
              style: theme.textTheme.labelMedium?.copyWith(
                color: accent ?? colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        VisualDnaProgressBar(value: bounded, accent: accent),
        if (detail != null) ...[
          const SizedBox(height: 6),
          Text(
            detail!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class VisualDnaLineChart extends StatelessWidget {
  const VisualDnaLineChart({
    required this.values,
    this.labels = const <String>[],
    this.height = 116,
    this.accent,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final List<String> labels;
  final double height;
  final Color? accent;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _VisualDnaLineChartPainter(
                values: values,
                accent: accent ?? colorScheme.primary,
                gridColor: colorScheme.onSurface.withValues(alpha: 0.05),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (var index = 0; index < labels.length; index += 1)
                  Expanded(
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class VisualDnaRingGauge extends StatelessWidget {
  const VisualDnaRingGauge({
    required this.value,
    required this.center,
    this.label,
    this.size = 184,
    this.accent,
    this.trackColor,
    this.strokeWidth = 10,
    super.key,
  });

  final double value;
  final Widget center;
  final String? label;
  final double size;
  final Color? accent;
  final Color? trackColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bounded = value.clamp(0.0, 1.0).toDouble();
    final ring = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VisualDnaRingPainter(
          value: bounded,
          accent: accent ?? colorScheme.primary,
          track:
              trackColor ??
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
          strokeWidth: strokeWidth,
        ),
        child: Center(child: center),
      ),
    );

    if (label == null) {
      return ring;
    }

    return Semantics(
      label: label,
      value: '${(bounded * 100).round()}%',
      child: ring,
    );
  }
}

class VisualDnaSegment {
  const VisualDnaSegment({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
}

class VisualDnaSegmentedActions extends StatelessWidget {
  const VisualDnaSegmentedActions({required this.segments, super.key});

  final List<VisualDnaSegment> segments;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var index = 0; index < segments.length; index += 1) ...[
          Expanded(child: _VisualDnaSegmentButton(segment: segments[index])),
          if (index != segments.length - 1)
            Container(
              width: 1,
              height: 34,
              color: AppThemeTokens.borderTone(colorScheme),
            ),
        ],
      ],
    );
  }
}

class VisualDnaSwatchRow extends StatelessWidget {
  const VisualDnaSwatchRow({
    required this.colors,
    this.selectedColor,
    this.onSelected,
    super.key,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in colors)
          InkWell(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            onTap: onSelected == null ? null : () => onSelected!(color),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                border: Border.all(
                  color:
                      selectedColor != null &&
                          selectedColor!.toARGB32() == color.toARGB32()
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.18),
                  width:
                      selectedColor != null &&
                          selectedColor!.toARGB32() == color.toARGB32()
                      ? 2
                      : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class VisualDnaMetricStrip extends StatelessWidget {
  const VisualDnaMetricStrip({required this.metrics, super.key});

  final List<VisualDnaMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < metrics.length; index += 1) ...[
          Expanded(
            child: _VisualDnaMetricTile(metric: metrics[index], minHeight: 76),
          ),
          if (index != metrics.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class VisualDnaActionRow extends StatelessWidget {
  const VisualDnaActionRow({
    required this.title,
    this.time,
    this.subtitle,
    this.meta,
    this.icon,
    this.onTap,
    this.trailing,
    this.valueKey,
    super.key,
  });

  final String? time;
  final String title;
  final String? subtitle;
  final String? meta;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Container(
      key: valueKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (time != null) ...[
            SizedBox(
              width: 46,
              child: Text(
                time!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          if (icon != null) ...[
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (meta != null) ...[
            const SizedBox(width: 8),
            VisualDnaStatusPill(label: meta!),
          ],
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _VisualDnaMetricTile extends StatelessWidget {
  const _VisualDnaMetricTile({required this.metric, required this.minHeight});

  final VisualDnaMetric metric;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = metric.accent ?? colorScheme.primary;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(
          colorScheme.surfaceContainerHigh,
          accentColor,
          0.026,
        )!.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 14,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              key: metric.valueKey == null
                  ? null
                  : ValueKey<String>(metric.valueKey!),
              maxLines: 1,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          if (metric.detail != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.detail!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor.withValues(alpha: 0.82),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisualDnaSegmentButton extends StatelessWidget {
  const _VisualDnaSegmentButton({required this.segment});

  final VisualDnaSegment segment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = segment.selected;

    return TextButton.icon(
      onPressed: segment.onPressed,
      icon: Icon(segment.icon, size: 17),
      label: Text(segment.label),
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
          alpha: 0.42,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        ),
      ),
    );
  }
}

class _VisualDnaRingPainter extends CustomPainter {
  const _VisualDnaRingPainter({
    required this.value,
    required this.accent,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color accent;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = track;
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          accent.withValues(alpha: 0.22),
          accent,
          accent.withValues(alpha: 0.72),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _VisualDnaRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.accent != accent ||
        oldDelegate.track != track ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _VisualDnaLineChartPainter extends CustomPainter {
  const _VisualDnaLineChartPainter({
    required this.values,
    required this.accent,
    required this.gridColor,
  });

  final List<int> values;
  final Color accent;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    for (var i = 1; i < 4; i += 1) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var i = 1; i < 5; i += 1) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (values.length < 2) {
      return;
    }

    final maxValue = math.max(
      1,
      values.fold<int>(0, (current, value) => math.max(current, value)),
    );
    final path = Path();
    for (var index = 0; index < values.length; index += 1) {
      final x = values.length == 1
          ? 0.0
          : size.width * index / (values.length - 1);
      final y = size.height - (values[index] / maxValue) * size.height;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accent.withValues(alpha: 0.22), Colors.transparent],
      ).createShader(Offset.zero & size);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = accent;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _VisualDnaLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor;
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.value,
    required this.intensity,
    required this.accent,
  });

  final int value;
  final double intensity;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final alpha = value == 0 ? 0.08 : 0.18 + intensity.clamp(0.0, 1.0) * 0.64;

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: value == 0
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.34)
            : accentColor.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: value == 0
              ? AppThemeTokens.borderTone(colorScheme)
              : accentColor.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}
