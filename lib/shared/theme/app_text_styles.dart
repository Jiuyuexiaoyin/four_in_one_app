import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

/// Named text role styles for four_in_one_app.
///
/// Each helper returns a `TextStyle?` derived from the active [Theme.textTheme]
/// so that the user's Theme Studio color and font choices remain authoritative.
/// Styles are passive: they do not subscribe to the theme or rebuild on their
/// own; callers compose them inside a [Text] widget.
///
/// These styles encode the "Dark Premium Productivity" hierarchy described in
/// `.claude/skills/premium-minimal-ui-polish/SKILL.md`. They are designed to
/// look correct in both `Brightness.light` and `Brightness.dark`.
abstract final class AppTextStyles {
  static TextStyle? pageEyebrow(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
  }

  static TextStyle? pageTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.7,
    );
  }

  static TextStyle? heroMetricValue(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      height: 1.0,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle? heroMetricLabel(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelSmall?.copyWith(
      color: AppThemeTokens.secondaryTextTone(theme.colorScheme),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
  }

  static TextStyle? statusHeadline(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle? statusSupporting(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      color: AppThemeTokens.secondaryTextTone(theme.colorScheme),
      height: 1.35,
    );
  }

  static TextStyle? sectionTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );
  }

  static TextStyle? cardTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
    );
  }

  static TextStyle? metricValue(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.55,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle? metricLabel(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
      color: AppThemeTokens.secondaryTextTone(theme.colorScheme),
      fontWeight: FontWeight.w600,
      height: 1.15,
    );
  }

  static TextStyle? chipLabel(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle? supportingText(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      color: AppThemeTokens.secondaryTextTone(theme.colorScheme),
      height: 1.35,
    );
  }
}
