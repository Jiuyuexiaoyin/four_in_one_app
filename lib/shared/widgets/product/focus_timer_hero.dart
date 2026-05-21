import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

enum FocusTimerHeroState { idle, running, paused }

class FocusTimerHeroTarget {
  const FocusTimerHeroTarget({required this.title, required this.context});

  final String title;
  final String context;
}

class FocusTimerHero extends StatelessWidget {
  const FocusTimerHero({
    required this.remainingTime,
    required this.statusLabel,
    required this.statusDescription,
    required this.durationLabel,
    required this.visualState,
    this.progressValue,
    this.target,
    this.remainingTimeKey,
    super.key,
  });

  final String remainingTime;
  final String statusLabel;
  final String statusDescription;
  final String durationLabel;
  final FocusTimerHeroState visualState;
  final double? progressValue;
  final FocusTimerHeroTarget? target;
  final Key? remainingTimeKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stateStyle = _resolveStateStyle(colorScheme);
    final boundedProgress = progressValue?.clamp(0.0, 1.0).toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.2,
          colors: [
            stateStyle.accentColor.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.12 : 0.08,
            ),
            stateStyle.backgroundColor.withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(
          color: stateStyle.borderColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '专注状态'.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusPill,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: stateStyle.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: 196,
              height: 196,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      value: boundedProgress,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor
                          .withValues(
                            alpha: colorScheme.brightness == Brightness.dark
                                ? 0.16
                                : 0.52,
                          ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        stateStyle.accentColor.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  Container(
                    width: 156,
                    height: 156,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor
                          .withValues(
                            alpha: colorScheme.brightness == Brightness.dark
                                ? 0.18
                                : 0.58,
                          ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stateStyle.borderColor.withValues(alpha: 0.82),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              remainingTime,
                              key: remainingTimeKey,
                              maxLines: 1,
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.8,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            durationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppThemeTokens.secondaryTextTone(
                                colorScheme,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 16),
            _FocusTargetLine(target: target!, visualState: visualState),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.20 : 0.50,
              ),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              border: Border.all(
                color: AppThemeTokens.borderTone(
                  colorScheme,
                ).withValues(alpha: 0.70),
              ),
            ),
            child: Row(
              children: [
                Icon(stateStyle.icon, size: 18, color: stateStyle.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _FocusTimerHeroStyle _resolveStateStyle(ColorScheme colorScheme) {
    switch (visualState) {
      case FocusTimerHeroState.running:
        return _FocusTimerHeroStyle(
          backgroundColor: AppThemeTokens.selectedStateTone(colorScheme),
          borderColor: colorScheme.primary.withValues(alpha: 0.10),
          accentColor: colorScheme.primary,
          icon: Icons.play_circle_rounded,
        );
      case FocusTimerHeroState.paused:
        return _FocusTimerHeroStyle(
          backgroundColor: colorScheme.secondaryContainer.withValues(
            alpha: 0.24,
          ),
          borderColor: colorScheme.secondary.withValues(alpha: 0.10),
          accentColor: colorScheme.secondary,
          icon: Icons.pause_circle_rounded,
        );
      case FocusTimerHeroState.idle:
        return _FocusTimerHeroStyle(
          backgroundColor: AppThemeTokens.softSurfaceTone(colorScheme),
          borderColor: AppThemeTokens.borderTone(colorScheme),
          accentColor: colorScheme.onSurfaceVariant,
          icon: Icons.hourglass_bottom_rounded,
        );
    }
  }
}

class _FocusTargetLine extends StatelessWidget {
  const _FocusTargetLine({required this.target, required this.visualState});

  final FocusTimerHeroTarget target;
  final FocusTimerHeroState visualState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prefix = visualState == FocusTimerHeroState.idle ? '准备推进' : '正在推进';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.22 : 0.58,
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$prefix：${target.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTimerHeroStyle {
  const _FocusTimerHeroStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final IconData icon;
}
