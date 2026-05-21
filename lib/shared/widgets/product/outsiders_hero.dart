import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

/// Outsiders-inspired editorial hero used as the lead element on a page.
///
/// Composition: small uppercase eyebrow → optional anchor metric (with halo
/// glow tinted by `colorScheme.primary` so Theme Studio drives atmosphere) →
/// large editorial headline → optional status word → optional supporting
/// paragraph → optional rhythm row below.
///
/// Designed for `Brightness.light` and `Brightness.dark` and for the user's
/// Theme Studio accent. No hardcoded brand colors.
class OutsidersHero extends StatelessWidget {
  const OutsidersHero({
    required this.headline,
    this.eyebrow,
    this.anchor,
    this.anchorSuffix,
    this.status,
    this.supporting,
    this.rhythm,
    super.key,
  });

  final String headline;
  final String? eyebrow;
  final String? anchor;
  final String? anchorSuffix;
  final String? status;
  final String? supporting;
  final Widget? rhythm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final eyebrow = this.eyebrow;
    final anchor = this.anchor;
    final anchorSuffix = this.anchorSuffix;
    final status = this.status;
    final supporting = this.supporting;
    final rhythm = this.rhythm;

    final eyebrowStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.4,
    );
    final anchorStyle = theme.textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -2.0,
      height: 1.0,
      color: colorScheme.onSurface,
    );
    final headlineStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.15,
      color: colorScheme.onSurface,
    );
    final statusStyle = theme.textTheme.titleLarge?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    );
    final supportingStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppThemeTokens.secondaryTextTone(colorScheme),
      height: 1.4,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -56,
          right: -56,
          child: IgnorePointer(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(
                      alpha: colorScheme.brightness == Brightness.dark
                          ? 0.22
                          : 0.18,
                    ),
                    colorScheme.primary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppThemeTokens.spaceSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow.toUpperCase(), style: eyebrowStyle),
                const SizedBox(height: AppThemeTokens.spaceMd),
              ],
              if (anchor != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Text(anchor, maxLines: 1, style: anchorStyle),
                      ),
                    ),
                    if (anchorSuffix != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppThemeTokens.spaceSm,
                          bottom: AppThemeTokens.spaceSm,
                        ),
                        child: Text(
                          anchorSuffix,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppThemeTokens.secondaryTextTone(
                              colorScheme,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppThemeTokens.spaceSm),
              ],
              Text(headline, style: headlineStyle),
              if (status != null) ...[
                const SizedBox(height: AppThemeTokens.spaceMd),
                Text(status, style: statusStyle),
              ],
              if (supporting != null) ...[
                const SizedBox(height: AppThemeTokens.spaceSm),
                Text(supporting, style: supportingStyle),
              ],
              if (rhythm != null) ...[
                const SizedBox(height: AppThemeTokens.spaceLg),
                rhythm,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
