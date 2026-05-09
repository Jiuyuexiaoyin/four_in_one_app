import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

class MySettingsSection extends StatelessWidget {
  const MySettingsSection({
    required this.title,
    required this.rows,
    this.subtitle,
    this.leadingIcon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final leadingIcon = this.leadingIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18, color: colorScheme.primary),
              const SizedBox(width: AppThemeTokens.spaceSm),
            ],
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: AppThemeTokens.spaceSm),
        SoftSurface(
          padding: EdgeInsets.zero,
          borderRadius: AppThemeTokens.radiusXl,
          tone: SoftSurfaceTone.plain,
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index += 1) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: AppThemeTokens.borderTone(colorScheme),
                  ),
                rows[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MySettingsRow extends StatelessWidget {
  const MySettingsRow({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.content,
    this.enabled = true,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final Widget? content;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final leadingIcon = this.leadingIcon;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final content = this.content;
    final effectiveOnTap = enabled ? onTap : null;
    final foregroundColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.58);
    final helperColor = enabled
        ? AppThemeTokens.secondaryTextTone(colorScheme)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.48);

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20, color: helperColor),
                const SizedBox(width: AppThemeTokens.spaceMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppThemeTokens.spaceXs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: helperColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppThemeTokens.spaceMd),
                Flexible(
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: AppThemeTokens.spaceMd),
            content,
          ],
        ],
      ),
    );

    if (effectiveOnTap == null) {
      return rowContent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: effectiveOnTap, child: rowContent),
    );
  }
}
