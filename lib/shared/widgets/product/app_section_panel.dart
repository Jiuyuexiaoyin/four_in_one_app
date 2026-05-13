import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

/// Shared section panel used by Review-style sectional content.
///
/// Mirrors the existing `_ReviewPanel` pattern (icon badge + title/subtitle
/// header + body) so multiple pages can compose from a single source.
class AppSectionPanel extends StatelessWidget {
  const AppSectionPanel({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.trailing,
    this.tone = SoftSurfaceTone.standard,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final SoftSurfaceTone tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitle = this.subtitle;
    final icon = this.icon;
    final trailing = this.trailing;

    return SoftSurface(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppThemeTokens.selectedStateTone(colorScheme),
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusMd,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 21),
                ),
                const SizedBox(width: AppThemeTokens.spaceMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppThemeTokens.spaceSm),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceLg2),
          child,
        ],
      ),
    );
  }
}
