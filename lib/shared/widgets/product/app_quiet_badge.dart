import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

/// Small quiet pill badge for low-emphasis labels ("后续", "测试中", "本地").
///
/// Hoisted from the previous settings-only `_QuietBadge` so any surface
/// across the app can reach for the same minimal pill.
class AppQuietBadge extends StatelessWidget {
  const AppQuietBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeTokens.spaceSm,
          vertical: AppThemeTokens.spaceXs,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
