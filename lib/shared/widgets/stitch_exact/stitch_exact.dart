import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class StitchExactColors {
  static const background = Color(0xFF131313);
  static const black = Color(0xFF000000);
  static const surface = Color(0xFF121212);
  static const surfaceLow = Color(0xFF1C1B1B);
  static const surfaceContainer = Color(0xFF201F1F);
  static const surfaceHigh = Color(0xFF2A2A2A);
  static const surfaceHighest = Color(0xFF353534);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFBAC9CC);
  static const outline = Color(0xFF849396);
  static const outlineVariant = Color(0xFF3B494C);
  static const cyan = Color(0xFF00DAF3);
  static const cyanBright = Color(0xFF00E5FF);
  static const green = Color(0xFF6CEC00);
  static const greenBright = Color(0xFF80FF2C);
  static const purple = Color(0xFFDCB8FF);
  static const red = Color(0xFFFFB4AB);
}

abstract final class StitchExactSpacing {
  static const pageX = 22.0;
  static const navHeight = 80.0;
  static const panelPadding = 24.0;
  static const cardRadius = 12.0;
  static const smallRadius = 8.0;
}

abstract final class StitchExactPremiumSpacing {
  static const pageX = 22.0;
  static const pageTop = 28.0;
  static const pageBottom = 128.0;
  static const pageBottomSecondary = 56.0;
  static const section = 30.0;
  static const sectionTight = 24.0;
  static const card = 18.0;
  static const cardLarge = 24.0;
  static const cardGap = 16.0;
  static const cardGapRelaxed = 22.0;
  static const titleGap = 10.0;
  static const subtitleGap = 8.0;
  static const metricGap = 14.0;
  static const metricRunGap = 14.0;
  static const silent = 36.0;
}

abstract final class StitchExactMotion {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const emphasis = Duration(milliseconds: 360);

  static const fastCurve = Curves.easeOutCubic;
  static const standardCurve = Curves.easeOutCubic;
  static const emphasisCurve = Curves.easeInOutCubic;
}

Color _stitchPanelColor(ColorScheme colorScheme) {
  return Color.lerp(
        colorScheme.surfaceContainerHigh,
        colorScheme.surfaceContainerHighest,
        0.45,
      ) ??
      colorScheme.surfaceContainerHigh;
}

Color _stitchRaisedSurface(ColorScheme colorScheme) {
  return Color.lerp(
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        0.08,
      ) ??
      colorScheme.surfaceContainerHighest;
}

Color _stitchGridSurface(ColorScheme colorScheme) {
  return Color.lerp(colorScheme.surfaceContainerLowest, Colors.black, 0.78) ??
      colorScheme.surfaceContainerLowest;
}

class StitchExactPage extends StatelessWidget {
  const StitchExactPage({
    required this.children,
    this.paddingTop = StitchExactPremiumSpacing.pageTop,
    this.paddingBottom = StitchExactPremiumSpacing.pageBottom,
    this.grid = false,
    super.key,
  });

  final List<Widget> children;
  final double paddingTop;
  final double paddingBottom;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageColor = grid
        ? _stitchGridSurface(theme.colorScheme)
        : theme.scaffoldBackgroundColor;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: pageColor)),
        if (grid) const Positioned.fill(child: _ExactGridBackground()),
        ListView(
          padding: EdgeInsets.fromLTRB(
            StitchExactSpacing.pageX,
            paddingTop,
            StitchExactSpacing.pageX,
            paddingBottom,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StitchExactGridBackground extends StatelessWidget {
  const StitchExactGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _stitchGridSurface(Theme.of(context).colorScheme),
      child: const CustomPaint(painter: _ExactGridPainter()),
    );
  }
}

class _ExactGridBackground extends StatelessWidget {
  const _ExactGridBackground();

  @override
  Widget build(BuildContext context) => const StitchExactGridBackground();
}

class _ExactGridPainter extends CustomPainter {
  const _ExactGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExactGridPainter oldDelegate) => false;
}

class StitchExactHeader extends StatelessWidget {
  const StitchExactHeader({
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.onLeading,
    this.onTrailing,
    this.centerTitle = true,
    super.key,
  });

  final String title;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onLeading;
  final VoidCallback? onTrailing;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleWidget = Text(
      title,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
      child: Row(
        children: [
          StitchExactIconPill(
            icon: leadingIcon ?? Icons.bolt_rounded,
            selected: leadingIcon == Icons.bolt_rounded,
            onTap: onLeading,
          ),
          const SizedBox(width: 12),
          Expanded(child: titleWidget),
          const SizedBox(width: 12),
          StitchExactIconPill(
            icon: trailingIcon ?? Icons.person_outline_rounded,
            onTap: onTrailing,
          ),
        ],
      ),
    );
  }
}

class StitchExactBottomNavItem {
  const StitchExactBottomNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class StitchExactBottomNav extends StatelessWidget {
  const StitchExactBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.roundedFull = true,
    super.key,
  });

  final List<StitchExactBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool roundedFull;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedFull ? 28 : 12),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _stitchGridSurface(colorScheme).withValues(alpha: 0.92),
              border: Border(
                top: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: StitchExactSpacing.navHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var index = 0; index < items.length; index += 1)
                    _StitchExactNavButton(
                      item: items[index],
                      selected: index == currentIndex,
                      onTap: () => onSelected(index),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StitchExactNavButton extends StatelessWidget {
  const _StitchExactNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final StitchExactBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.outline;
    return InkResponse(
      key: ValueKey<String>('stitch-nav-${item.route}'),
      onTap: onTap,
      radius: 36,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.primary.withValues(alpha: 0.06),
      child: SizedBox(
        width: 68,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: AnimatedContainer(
                duration: StitchExactMotion.fast,
                curve: StitchExactMotion.fastCurve,
                width: selected ? 34 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(
                    alpha: selected ? 1 : 0,
                  ),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.8),
                            blurRadius: 12,
                          ),
                        ]
                      : const [],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.06 : 1,
                    duration: StitchExactMotion.fast,
                    curve: StitchExactMotion.fastCurve,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: StitchExactMotion.fast,
                      curve: StitchExactMotion.fastCurve,
                      builder: (context, animatedColor, child) {
                        return Icon(
                          item.icon,
                          size: 24,
                          color: animatedColor ?? color,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedDefaultTextStyle(
                    duration: StitchExactMotion.fast,
                    curve: StitchExactMotion.fastCurve,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      height: 1,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StitchExactPanel extends StatelessWidget {
  const StitchExactPanel({
    required this.child,
    this.padding = const EdgeInsets.all(StitchExactSpacing.panelPadding),
    this.glow = false,
    this.accent,
    this.borderRadius = StitchExactSpacing.cardRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool glow;
  final Color? accent;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    return Material(
      color: _stitchPanelColor(colorScheme),
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.055),
          ),
          boxShadow: [
            if (glow)
              BoxShadow(
                color: color.withValues(alpha: 0.14),
                blurRadius: 18,
                spreadRadius: -4,
              ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class StitchExactLabel extends StatelessWidget {
  const StitchExactLabel({
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
      style: TextStyle(
        color: accent ?? colorScheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.3,
        height: 1.25,
      ),
    );
  }
}

class StitchExactCommandHeader extends StatelessWidget {
  const StitchExactCommandHeader({
    this.eyebrow,
    required this.title,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                StitchExactLabel(text: eyebrow!, accent: colorScheme.primary),
                SizedBox(height: compact ? 4 : 8),
              ],
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: compact ? 18 : 24,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class StitchExactIconPill extends StatelessWidget {
  const StitchExactIconPill({
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
    final color = accent ?? colorScheme.primary;
    final child = IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        foregroundColor: selected ? color : colorScheme.onSurfaceVariant,
        backgroundColor: selected
            ? color.withValues(alpha: 0.12)
            : _stitchRaisedSurface(colorScheme).withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

class StitchExactStatusPill extends StatelessWidget {
  const StitchExactStatusPill({
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
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    final content = AnimatedContainer(
      duration: StitchExactMotion.fast,
      curve: StitchExactMotion.fastCurve,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.11)
            : colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected
              ? color.withValues(alpha: 0.34)
              : colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            value == null
                ? label.toUpperCase()
                : '${label.toUpperCase()}: $value',
            style: TextStyle(
              color: selected ? color : colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              height: 1,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class StitchExactMetric {
  const StitchExactMetric({
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

class StitchExactMetricGrid extends StatelessWidget {
  const StitchExactMetricGrid({
    required this.metrics,
    this.minHeight = 78,
    super.key,
  });

  final List<StitchExactMetric> metrics;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420 ? 2 : 4;
        return Wrap(
          spacing: StitchExactPremiumSpacing.metricGap,
          runSpacing: StitchExactPremiumSpacing.metricRunGap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width:
                    (constraints.maxWidth -
                        (columns - 1) * StitchExactPremiumSpacing.metricGap) /
                    columns,
                child: _StitchExactMetricTile(
                  metric: metric,
                  minHeight: minHeight,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StitchExactMetricTile extends StatelessWidget {
  const _StitchExactMetricTile({required this.metric, required this.minHeight});

  final StitchExactMetric metric;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = metric.accent ?? colorScheme.primary;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _stitchGridSurface(colorScheme).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.045),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StitchExactLabel(
            text: metric.label,
            accent: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: StitchExactMotion.fast,
            switchInCurve: StitchExactMotion.fastCurve,
            switchOutCurve: StitchExactMotion.fastCurve,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [...previousChildren, ?currentChild],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(
                '${metric.valueKey ?? metric.label}:${metric.value}',
              ),
              child: Text(
                metric.value,
                key: metric.valueKey == null
                    ? null
                    : ValueKey<String>(metric.valueKey!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          if (metric.detail != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.detail!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StitchExactProgressBar extends StatelessWidget {
  const StitchExactProgressBar({
    required this.value,
    this.label,
    this.detail,
    this.valueKey,
    this.accent,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final String? label;
  final String? detail;
  final String? valueKey;
  final Color? accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bounded = value.clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    final bar = Semantics(
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 2,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: _stitchRaisedSurface(colorScheme)),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: bounded),
                duration: StitchExactMotion.standard,
                curve: StitchExactMotion.standardCurve,
                builder: (context, animatedValue, child) {
                  return FractionallySizedBox(
                    widthFactor: animatedValue,
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (label == null && detail == null) return bar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || detail != null)
          Row(
            children: [
              if (label != null)
                Expanded(child: StitchExactLabel(text: label!)),
              if (detail != null)
                Text(
                  detail!,
                  key: valueKey == null ? null : ValueKey<String>(valueKey!),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 10),
        bar,
      ],
    );
  }
}

class StitchExactMiniBars extends StatelessWidget {
  const StitchExactMiniBars({
    required this.values,
    this.labels,
    this.height = 112,
    this.valueKey,
    this.accent,
    super.key,
  });

  final List<int> values;
  final List<String>? labels;
  final double height;
  final String? valueKey;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(1, values.fold<int>(0, math.max));
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    return SizedBox(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index += 1)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: math.max(
                            0.05,
                            values[index] / maxValue,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  values[index] == maxValue && values[index] > 0
                                  ? color
                                  : _stitchRaisedSurface(colorScheme),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                              boxShadow: [
                                if (values[index] == maxValue &&
                                    values[index] > 0)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                  ),
                              ],
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    if (labels != null && index < labels!.length) ...[
                      const SizedBox(height: 8),
                      Text(
                        labels![index],
                        style: TextStyle(
                          color: values[index] == maxValue && values[index] > 0
                              ? color
                              : colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StitchExactHeatmap extends StatelessWidget {
  const StitchExactHeatmap({
    required this.values,
    this.columns = 12,
    this.valueKey,
    this.accent,
    super.key,
  });

  final List<int> values;
  final int columns;
  final String? valueKey;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(1, values.fold<int>(0, math.max));
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    return GridView.builder(
      key: valueKey == null ? null : ValueKey<String>(valueKey!),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final intensity = values[index] <= 0 ? 0.0 : values[index] / maxValue;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: intensity == 0
                ? _stitchRaisedSurface(colorScheme)
                : color.withValues(alpha: 0.2 + intensity * 0.8),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              if (intensity > 0.75)
                BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 8),
            ],
          ),
        );
      },
    );
  }
}

class StitchExactRingMetric extends StatelessWidget {
  const StitchExactRingMetric({
    required this.label,
    required this.value,
    this.size = 70,
    this.detail,
    this.accent,
    this.center,
    super.key,
  });

  final String label;
  final double value;
  final double size;
  final String? detail;
  final Color? accent;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    final bounded = value.clamp(0.0, 1.0).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: bounded),
                duration: StitchExactMotion.standard,
                curve: StitchExactMotion.standardCurve,
                builder: (context, animatedValue, child) {
                  return CustomPaint(
                    size: Size.square(size),
                    painter: _RingPainter(
                      color: color,
                      trackColor: _stitchRaisedSurface(colorScheme),
                      value: animatedValue,
                    ),
                  );
                },
              ),
              center ??
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        StitchExactLabel(text: label, textAlign: TextAlign.center),
        if (detail != null)
          Text(
            detail!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.color,
    required this.trackColor,
    required this.value,
  });

  final Color color;
  final Color trackColor;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = math.max(3.0, size.width * 0.075);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect.deflate(stroke), -math.pi, math.pi * 2, false, bg);
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi,
      math.pi * 2 * value,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        value != oldDelegate.value;
  }
}

class StitchExactLineChart extends StatelessWidget {
  const StitchExactLineChart({
    required this.values,
    this.labels,
    this.valueKey,
    this.accent,
    super.key,
  });

  final List<int> values;
  final List<String>? labels;
  final String? valueKey;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StitchExactPanel(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        key: valueKey == null ? null : ValueKey<String>(valueKey!),
        height: 168,
        child: CustomPaint(
          painter: _LineChartPainter(
            values: values,
            labels: labels,
            color: accent ?? colorScheme.primary,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  final List<int> values;
  final List<String>? labels;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i += 1) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var i = 1; i < 5; i += 1) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    if (values.isEmpty) return;
    final maxValue = math.max(1, values.fold<int>(0, math.max));
    final path = Path();
    for (var i = 0; i < values.length; i += 1) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / maxValue) * (size.height - 24) - 12;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return values != oldDelegate.values || color != oldDelegate.color;
  }
}

class StitchExactTimelineRow extends StatelessWidget {
  const StitchExactTimelineRow({
    this.time,
    required this.title,
    this.subtitle,
    this.meta,
    this.active = false,
    this.icon,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String? time;
  final String title;
  final String? subtitle;
  final String? meta;
  final bool active;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              child: Text(
                time ?? '',
                style: TextStyle(
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (meta != null) ...[
                    const SizedBox(height: 8),
                    StitchExactStatusPill(
                      label: meta!,
                      selected: active,
                      accent: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing ??
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _stitchRaisedSurface(colorScheme),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Icon(
                    icon ?? Icons.arrow_forward_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 17,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class StitchExactUtilityRow extends StatelessWidget {
  const StitchExactUtilityRow({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _stitchRaisedSurface(colorScheme),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.onSurface, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StitchExactLabel(text: subtitle),
                ],
              ),
            ),
            if (value != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                color: colorScheme.surfaceContainerLowest.withValues(
                  alpha: 0.72,
                ),
                child: Text(
                  value!,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class StitchExactSequenceDots extends StatelessWidget {
  const StitchExactSequenceDots({required this.values, this.accent, super.key});

  final List<bool> values;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = accent ?? colorScheme.primary;
    return Row(
      children: [
        for (var index = 0; index < values.length; index += 1) ...[
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: values[index]
                    ? color
                    : _stitchRaisedSurface(colorScheme),
                border: Border.all(
                  color: values[index]
                      ? color
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  if (values[index])
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 8,
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                const ['一', '二', '三', '四', '五', '六', '日'][index % 7],
                style: TextStyle(
                  color: values[index]
                      ? colorScheme.onPrimary
                      : colorScheme.outline,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (index < values.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class StitchExactActionButton extends StatelessWidget {
  const StitchExactActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
      label: Text(label.toUpperCase()),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.9,
        ),
      ),
    );
  }
}

typedef StitchPanel = StitchExactPanel;
typedef StitchCapsLabel = StitchExactLabel;
typedef StitchCommandHeader = StitchExactCommandHeader;
typedef StitchIconPill = StitchExactIconPill;
typedef StitchStatusPill = StitchExactStatusPill;
typedef StitchMetric = StitchExactMetric;
typedef StitchMetricGrid = StitchExactMetricGrid;
typedef StitchProgressRail = StitchExactProgressBar;
typedef StitchMiniBars = StitchExactMiniBars;
typedef StitchHeatmap = StitchExactHeatmap;
typedef StitchCircularMetric = StitchExactRingMetric;
typedef StitchLineChart = StitchExactLineChart;
typedef StitchTimelineRow = StitchExactTimelineRow;
typedef StitchUtilityRow = StitchExactUtilityRow;
typedef StitchSequenceDots = StitchExactSequenceDots;

typedef StitchExactCapsLabel = StitchExactLabel;
typedef StitchExactProgressRail = StitchExactProgressBar;
typedef StitchExactCircularMetric = StitchExactRingMetric;

typedef VisualDnaPanel = StitchExactPanel;
typedef VisualDnaMetric = StitchExactMetric;
typedef VisualDnaMetricGrid = StitchExactMetricGrid;
typedef VisualDnaProgressBar = StitchExactProgressBar;
typedef VisualDnaMiniBars = StitchExactMiniBars;
