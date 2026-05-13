import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/theme/app_text_styles.dart';

enum AppChipTone { neutral, accent, info, quiet }

class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.tone = AppChipTone.neutral,
    this.leadingIcon,
    this.trailingIcon,
    this.value,
    this.identityColor,
    this.onTap,
    super.key,
  });

  final String label;
  final AppChipTone tone;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? value;
  final Color? identityColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = _resolvePalette(colorScheme);
    final labelStyle = AppTextStyles.chipLabel(
      context,
    )?.copyWith(color: palette.foreground);
    final valueStyle = labelStyle?.copyWith(fontWeight: FontWeight.w800);

    final leadingIcon = this.leadingIcon;
    final trailingIcon = this.trailingIcon;
    final value = this.value;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 14, color: palette.foreground),
          const SizedBox(width: AppThemeTokens.spaceXs),
        ],
        if (value != null) ...[
          Text(value, style: valueStyle),
          const SizedBox(width: AppThemeTokens.spaceXs),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppThemeTokens.spaceXs),
          Icon(trailingIcon, size: 14, color: palette.foreground),
        ],
      ],
    );

    const padding = EdgeInsets.symmetric(
      horizontal: AppThemeTokens.spaceMd,
      vertical: AppThemeTokens.space2xs,
    );

    if (onTap == null) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          border: palette.border == null
              ? null
              : Border.all(color: palette.border!),
        ),
        child: content,
      );
    }

    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      side: palette.border == null
          ? BorderSide.none
          : BorderSide(color: palette.border!),
    );

    return Material(
      color: palette.background,
      shape: pillShape,
      child: InkWell(
        onTap: onTap,
        customBorder: pillShape,
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  _AppChipPalette _resolvePalette(ColorScheme colorScheme) {
    final identity = identityColor;
    if (identity != null) {
      return _AppChipPalette(
        background: identity.withValues(alpha: 0.12),
        border: identity.withValues(alpha: 0.20),
        foreground: identity,
      );
    }
    switch (tone) {
      case AppChipTone.neutral:
        return _AppChipPalette(
          background: AppThemeTokens.softSurfaceTone(colorScheme),
          border: AppThemeTokens.borderTone(colorScheme),
          foreground: AppThemeTokens.secondaryTextTone(colorScheme),
        );
      case AppChipTone.accent:
        return _AppChipPalette(
          background: colorScheme.primary.withValues(alpha: 0.10),
          border: colorScheme.primary.withValues(alpha: 0.20),
          foreground: colorScheme.primary,
        );
      case AppChipTone.info:
        return _AppChipPalette(
          background: colorScheme.tertiary.withValues(alpha: 0.10),
          border: colorScheme.tertiary.withValues(alpha: 0.20),
          foreground: colorScheme.tertiary,
        );
      case AppChipTone.quiet:
        return _AppChipPalette(
          background: Colors.transparent,
          border: null,
          foreground: AppThemeTokens.secondaryTextTone(colorScheme),
        );
    }
  }
}

class _AppChipPalette {
  const _AppChipPalette({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color? border;
  final Color foreground;
}
