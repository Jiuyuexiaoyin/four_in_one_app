import 'package:flutter/material.dart';

/// Reference palette for the "Dark Premium Productivity" visual direction
/// described in `.claude/skills/premium-minimal-ui-polish/SKILL.md`.
///
/// These constants are reference-only guidance values. They are NOT consumed
/// by `AppTheme.dark` or by any widget in P1. Theme Studio remains the
/// authoritative source of the live theme's accent, background, and surface
/// colors.
///
/// Future page polish phases (P3 onward) may opt into these constants for
/// decorative-only sub-surfaces — for example, a fixed graphite anchor behind
/// a hero metric, or a one-accent-per-surface tag — when the user's chosen
/// `colorScheme` would not produce the same visual restraint.
///
/// The accent ramp encodes the "one accent per surface" rule from
/// `SKILL.md` section 11: a page may pick exactly one of these accents for a
/// specific decorative role, never two on the same surface.
abstract final class AppDarkPalette {
  static const Color canvasBlack = Color(0xFF0A0A0B);
  static const Color canvasGraphite = Color(0xFF101114);
  static const Color surfaceGraphite = Color(0xFF15171C);
  static const Color surfaceGraphiteElevated = Color(0xFF1C1F25);
  static const Color surfaceGraphiteInset = Color(0xFF111317);
  static const Color dividerSubtle = Color(0xFF272A30);
  static const Color borderQuiet = Color(0xFF24272D);
  static const Color textOnGraphite = Color(0xFFF2F3F5);
  static const Color textSecondaryOnGraphite = Color(0xFFA7AAB0);
  static const Color textMutedOnGraphite = Color(0xFF6B6E73);

  static const Color accentReadinessGreen = Color(0xFF00E785);
  static const Color accentRankPink = Color(0xFFEB1F5C);
  static const Color accentProgressBlue = Color(0xFF1F9CFF);
  static const Color accentSleepPurple = Color(0xFF9D5EFF);
  static const Color accentWarningAmber = Color(0xFFFFA94D);
}
