import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

class StitchMetric {
  const StitchMetric({
    required this.label,
    required this.value,
    this.detail,
    this.accent,
    this.valueKey,
  });

  final String label;
  final String value;
  final String? detail;
  final Color? accent;
  final String? valueKey;
}

class StitchPanel extends StatelessWidget {
  const StitchPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
    this.glow = false,
    this.borderRadius = 12,
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
        color: Color.lerp(colorScheme.surface, Colors.black, 0.18),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glow
              ? accentColor.withValues(alpha: 0.34)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.14),
              blurRadius: 26,
              spreadRadius: -12,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -16,
          ),
        ],
      ),
      child: child,
    );
  }
}

class StitchCapsLabel extends StatelessWidget {
  const StitchCapsLabel({
    required this.text,
    this.accent,
    this.textAlign,
    super.key,
  });

  final String text;
  final Color? accent;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: accent ?? AppThemeTokens.secondaryTextTone(colorScheme),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        height: 1.25,
      ),
    );
  }
}

class StitchCommandHeader extends StatelessWidget {
  const StitchCommandHeader({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          StitchIconPill(icon: leadingIcon!, selected: true),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                StitchCapsLabel(text: eyebrow!, accent: colorScheme.primary),
                const SizedBox(height: 6),
              ],
              Text(
                title,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                          letterSpacing: 0,
                        ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 7),
                Text(
                  subtitle!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w600,
                    height: 1.36,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class StitchIconPill extends StatelessWidget {
  const StitchIconPill({
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
    final foreground = selected ? accentColor : colorScheme.onSurfaceVariant;
    final child = IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        foregroundColor: foreground,
        backgroundColor: selected
            ? accentColor.withValues(alpha: 0.13)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected
                ? accentColor.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
    );

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

class StitchStatusPill extends StatelessWidget {
  const StitchStatusPill({
    required this.label,
    this.value,
    this.selected = false,
    this.accent,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final String? value;
  final bool selected;
  final Color? accent;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final foreground = selected ? accentColor : colorScheme.onSurfaceVariant;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? accentColor.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? accentColor.withValues(alpha: 0.34)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 7),
            Text(
              value!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? accentColor : colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
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
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class StitchMetricGrid extends StatelessWidget {
  const StitchMetricGrid({
    required this.metrics,
    this.minHeight = 78,
    super.key,
  });

  final List<StitchMetric> metrics;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 360
            ? 2
            : 1;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _StitchMetricTile(metric: metric, minHeight: minHeight),
              ),
          ],
        );
      },
    );
  }
}

class StitchProgressRail extends StatelessWidget {
  const StitchProgressRail({
    required this.value,
    this.label,
    this.detail,
    this.accent,
    this.height = 3,
    this.valueKey,
    super.key,
  });

  final double value;
  final String? label;
  final String? detail;
  final Color? accent;
  final double height;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final bounded = value.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || detail != null) ...[
          Row(
            children: [
              if (label != null)
                Expanded(child: StitchCapsLabel(text: label!))
              else
                const Spacer(),
              Text(
                '${(bounded * 100).round()}%',
                key: valueKey == null ? null : ValueKey<String>(valueKey!),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: bounded,
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 7),
          Text(
            detail!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

class StitchMiniBars extends StatelessWidget {
  const StitchMiniBars({
    required this.values,
    this.labels = const <String>[],
    this.accent,
    this.height = 96,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final List<String> labels;
  final Color? accent;
  final double height;
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
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: values[index] == 0
                                ? colorScheme.surfaceContainerHigh
                                : accentColor.withValues(alpha: 0.86),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                            boxShadow: values[index] == 0
                                ? const []
                                : [
                                    BoxShadow(
                                      color: accentColor.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (labels.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: index < values.length && values[index] > 0
                            ? accentColor
                            : AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (index != values.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class StitchHeatmap extends StatelessWidget {
  const StitchHeatmap({
    required this.values,
    this.columns = 12,
    this.accent,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final int columns;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 5.0;
        final effectiveColumns = math.max(1, columns);
        final cellSize =
            (constraints.maxWidth - gap * (effectiveColumns - 1)) /
            effectiveColumns;

        return Wrap(
          key: valueKey == null ? null : ValueKey<String>(valueKey!),
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final value in values)
              SizedBox.square(
                dimension: cellSize.clamp(4.0, 28.0).toDouble(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: value == 0
                        ? colorScheme.surfaceContainerHigh
                        : accentColor.withValues(
                            alpha: 0.20 + (value / maxValue) * 0.72,
                          ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: value == maxValue && value > 0
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : const [],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class StitchCircularMetric extends StatelessWidget {
  const StitchCircularMetric({
    required this.label,
    required this.value,
    required this.center,
    this.detail,
    this.accent,
    this.size = 64,
    super.key,
  });

  final String label;
  final double value;
  final Widget center;
  final String? detail;
  final Color? accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _StitchRingPainter(
              value: value.clamp(0.0, 1.0).toDouble(),
              accent: accentColor,
              track: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
            ),
            child: Center(child: center),
          ),
        ),
        const SizedBox(height: 8),
        StitchCapsLabel(text: label, textAlign: TextAlign.center),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(
                colorScheme,
              ).withValues(alpha: 0.72),
            ),
          ),
        ],
      ],
    );
  }
}

class StitchLineChart extends StatelessWidget {
  const StitchLineChart({
    required this.values,
    this.labels = const <String>[],
    this.accent,
    this.height = 156,
    this.valueKey,
    super.key,
  });

  final List<int> values;
  final List<String> labels;
  final Color? accent;
  final double height;
  final String? valueKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;

    return Container(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _StitchLinePainter(
                values: values,
                accent: accentColor,
                gridColor: Colors.white.withValues(alpha: 0.05),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final label in labels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(
                          colorScheme,
                        ).withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
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

class StitchTimelineRow extends StatelessWidget {
  const StitchTimelineRow({
    required this.title,
    this.time,
    this.subtitle,
    this.meta,
    this.icon,
    this.active = false,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String? time;
  final String title;
  final String? subtitle;
  final String? meta;
  final IconData? icon;
  final bool active;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = active ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: active
            ? colorScheme.surfaceContainerLow.withValues(alpha: 0.76)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          left: BorderSide(
            color: active ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time ?? '--',
              style: theme.textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
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
                if (meta != null) ...[
                  const SizedBox(height: 8),
                  StitchStatusPill(label: meta!, selected: active),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing ??
              StitchIconPill(
                icon: icon ?? Icons.arrow_forward_rounded,
                selected: active,
              ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class StitchProtocolCard extends StatelessWidget {
  const StitchProtocolCard({
    required this.title,
    required this.subtitle,
    required this.sequenceValues,
    this.icon = Icons.bolt_rounded,
    this.countLabel,
    this.countValue,
    this.accent,
    this.completed = false,
    this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<int> sequenceValues;
  final IconData icon;
  final String? countLabel;
  final String? countValue;
  final Color? accent;
  final bool completed;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    final body = StitchPanel(
      glow: completed,
      accent: accentColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (countValue != null) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      countValue!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    StitchCapsLabel(text: countLabel ?? '连续'),
                  ],
                ),
              ],
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          StitchSequenceDots(values: sequenceValues, accent: accentColor),
        ],
      ),
    );

    if (onTap == null) {
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class StitchSequenceDots extends StatelessWidget {
  const StitchSequenceDots({required this.values, this.accent, super.key});

  final List<int> values;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = accent ?? colorScheme.primary;
    const labels = ['一', '二', '三', '四', '五', '六', '日'];

    return Row(
      children: [
        for (var index = 0; index < labels.length; index += 1) ...[
          Expanded(
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index < values.length && values[index] > 0
                      ? accentColor
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index < values.length && values[index] > 0
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: index < values.length && values[index] > 0
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.22),
                            blurRadius: 8,
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: index < values.length && values[index] > 0
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class StitchUtilityRow extends StatelessWidget {
  const StitchUtilityRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.value,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                StitchCapsLabel(text: subtitle),
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 10),
            StitchStatusPill(label: value!, selected: true),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.outline,
            size: 22,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _StitchMetricTile extends StatelessWidget {
  const _StitchMetricTile({required this.metric, required this.minHeight});

  final StitchMetric metric;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = metric.accent ?? colorScheme.primary;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StitchCapsLabel(text: metric.label),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              metric.value,
              key: metric.valueKey == null
                  ? null
                  : ValueKey<String>(metric.valueKey!),
              style: theme.textTheme.titleLarge?.copyWith(
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
                color: accent,
                fontWeight: FontWeight.w800,
                height: 1.24,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StitchRingPainter extends CustomPainter {
  const _StitchRingPainter({
    required this.value,
    required this.accent,
    required this.track,
  });

  final double value;
  final Color accent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = track;
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = accent;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _StitchRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.accent != accent ||
        oldDelegate.track != track;
  }
}

class _StitchLinePainter extends CustomPainter {
  const _StitchLinePainter({
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

    for (var row = 1; row < 4; row += 1) {
      final y = size.height * row / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var column = 1; column < 5; column += 1) {
      final x = size.width * column / 5;
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
      final x = size.width * index / (values.length - 1);
      final y = size.height - (values[index] / maxValue) * size.height;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = accent;

    canvas.drawPath(path, linePaint);
    final points = <Offset>[];
    for (var index = 0; index < values.length; index += 1) {
      final x = size.width * index / (values.length - 1);
      final y = size.height - (values[index] / maxValue) * size.height;
      points.add(Offset(x, y));
    }
    if (points.isNotEmpty) {
      final peak = points.reduce((a, b) => a.dy < b.dy ? a : b);
      canvas.drawCircle(peak, 3.2, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(covariant _StitchLinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor;
  }
}
