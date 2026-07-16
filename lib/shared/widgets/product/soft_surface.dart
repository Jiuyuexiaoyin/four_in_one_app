import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

enum SoftSurfaceTone { standard, accent, plain, flat, ghost }

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
    final accentColor = tone == SoftSurfaceTone.accent
        ? colorScheme.primary
        : colorScheme.secondary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: BorderSide(color: borderColor ?? _borderColor(colorScheme)),
    );

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 18,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Material(
          color: backgroundColor ?? _backgroundColor(colorScheme),
          shape: shape,
          elevation: _resolveElevation(colorScheme),
          shadowColor: Colors.black.withValues(
            alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.08,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }

  double _resolveElevation(ColorScheme colorScheme) {
    if (tone == SoftSurfaceTone.flat || tone == SoftSurfaceTone.ghost) {
      return 0;
    }
    return colorScheme.brightness == Brightness.dark ? 2 : 1;
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    switch (tone) {
      case SoftSurfaceTone.standard:
      case SoftSurfaceTone.flat:
        return Color.lerp(
              AppThemeTokens.softSurfaceTone(colorScheme),
              colorScheme.primary,
              colorScheme.brightness == Brightness.dark ? 0.026 : 0.015,
            ) ??
            AppThemeTokens.softSurfaceTone(colorScheme);
      case SoftSurfaceTone.accent:
        return Color.lerp(
              AppThemeTokens.softSurfaceTone(colorScheme),
              colorScheme.primary,
              colorScheme.brightness == Brightness.dark ? 0.08 : 0.05,
            ) ??
            AppThemeTokens.selectedStateTone(colorScheme);
      case SoftSurfaceTone.plain:
        return colorScheme.surfaceContainerLow;
      case SoftSurfaceTone.ghost:
        return Colors.transparent;
    }
  }

  Color _borderColor(ColorScheme colorScheme) {
    switch (tone) {
      case SoftSurfaceTone.accent:
        return colorScheme.primary.withValues(alpha: 0.28);
      case SoftSurfaceTone.standard:
      case SoftSurfaceTone.plain:
      case SoftSurfaceTone.flat:
        return AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.92);
      case SoftSurfaceTone.ghost:
        return Colors.transparent;
    }
  }
}
