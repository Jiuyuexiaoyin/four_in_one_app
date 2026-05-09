import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

enum SoftSurfaceTone { standard, accent, plain }

class SoftSurface extends StatelessWidget {
  const SoftSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.tone = SoftSurfaceTone.standard,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppThemeTokens.radiusXl,
    this.width,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final SoftSurfaceTone tone;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? _backgroundColor(colorScheme),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? _borderColor(colorScheme)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.10 : 0.035,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    switch (tone) {
      case SoftSurfaceTone.standard:
        return AppThemeTokens.softSurfaceTone(colorScheme);
      case SoftSurfaceTone.accent:
        return AppThemeTokens.selectedStateTone(colorScheme);
      case SoftSurfaceTone.plain:
        return colorScheme.surface;
    }
  }

  Color _borderColor(ColorScheme colorScheme) {
    switch (tone) {
      case SoftSurfaceTone.accent:
        return colorScheme.primary.withValues(alpha: 0.10);
      case SoftSurfaceTone.standard:
      case SoftSurfaceTone.plain:
        return AppThemeTokens.borderTone(colorScheme);
    }
  }
}
