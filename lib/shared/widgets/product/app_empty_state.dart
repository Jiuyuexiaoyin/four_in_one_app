import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/theme/app_text_styles.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

/// Shared empty-state surface for "Dark Premium Productivity" pages.
///
/// Honest by design: no fabricated counts, no fake activity. The supporting
/// line should read like a calm coach line, not a sad "no data" badge.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.supporting,
    this.icon,
    this.action,
    super.key,
  });

  final String title;
  final String supporting;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = this.icon;
    final action = this.action;

    return SoftSurface(
      tone: SoftSurfaceTone.flat,
      padding: const EdgeInsets.all(AppThemeTokens.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 28,
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
          ],
          Text(
            title,
            style: AppTextStyles.sectionTitle(
              context,
            )?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(supporting, style: AppTextStyles.supportingText(context)),
          if (action != null) ...[
            const SizedBox(height: AppThemeTokens.spaceLg),
            action,
          ],
        ],
      ),
    );
  }
}
