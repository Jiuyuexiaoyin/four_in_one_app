import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/progress_rail.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

class PlanGoalCard extends StatelessWidget {
  const PlanGoalCard({
    required this.goalId,
    required this.title,
    required this.icon,
    required this.colorValue,
    required this.projectCount,
    required this.subprojectCount,
    required this.actionCount,
    required this.completedActionCount,
    required this.progressLabel,
    required this.hasActions,
    required this.onOpenTree,
    required this.onAddProject,
    required this.child,
    this.description = '',
    this.progressValue,
    this.progressTextKey,
    this.openTreeKey,
    this.editGoalKey,
    this.addProjectKey,
    this.onEditGoal,
    super.key,
  });

  final String goalId;
  final String title;
  final String icon;
  final String description;
  final int colorValue;
  final int projectCount;
  final int subprojectCount;
  final int actionCount;
  final int completedActionCount;
  final String progressLabel;
  final bool hasActions;
  final double? progressValue;
  final Key? progressTextKey;
  final Key? openTreeKey;
  final Key? editGoalKey;
  final Key? addProjectKey;
  final VoidCallback? onEditGoal;
  final VoidCallback onOpenTree;
  final VoidCallback onAddProject;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final identityColor = Color(colorValue);

    return SoftSurface(
      padding: const EdgeInsets.all(18),
      borderColor: hasActions
          ? identityColor.withValues(alpha: 0.14)
          : AppThemeTokens.borderTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 5,
            decoration: BoxDecoration(
              color: identityColor.withValues(alpha: hasActions ? 0.42 : 0.16),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlanVisualMarker(
                markerKey: ValueKey('goal-identity-icon-$goalId'),
                iconLabel: icon,
                colorValue: colorValue,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _PlanIdentityPill(label: '目标'),
                      ],
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description.trim(),
                        key: ValueKey('goal-description-$goalId'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '项目 $projectCount · 行动 $actionCount · $progressLabel',
                      key: progressTextKey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasActions
                            ? identityColor
                            : AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onEditGoal != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  key: editGoalKey,
                  onPressed: onEditGoal,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('编辑目标'),
                ),
                Text(
                  '标题、图标、颜色、描述',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _PlanCountBadge(label: '项目', value: '$projectCount'),
              _PlanCountBadge(label: '子项目', value: '$subprojectCount'),
              _PlanCountBadge(
                label: '行动',
                value: '$completedActionCount/$actionCount',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressRail(
            value: hasActions ? progressValue : null,
            height: 6,
            fillColor: identityColor.withValues(alpha: 0.72),
            backgroundColor: AppThemeTokens.borderTone(
              colorScheme,
            ).withValues(alpha: 0.42),
          ),
          const SizedBox(height: 8),
          _PlanProgressDots(
            activeCount: hasActions
                ? ((progressValue ?? 0) * 5).ceil().clamp(1, 5)
                : 0,
            color: identityColor,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                key: openTreeKey,
                onPressed: onOpenTree,
                icon: const Icon(Icons.account_tree_outlined, size: 16),
                label: const Text('查看目标树'),
              ),
              TextButton.icon(
                key: addProjectKey,
                onPressed: onAddProject,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('添加项目'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  const _PlanCountBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppThemeTokens.spaceXs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanIdentityPill extends StatelessWidget {
  const _PlanIdentityPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlanProgressDots extends StatelessWidget {
  const _PlanProgressDots({required this.activeCount, required this.color});

  final int activeCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(5, (index) {
        final active = index < activeCount;

        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: active ? 18 : 8,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.48)
                  : AppThemeTokens.borderTone(
                      colorScheme,
                    ).withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
        );
      }),
    );
  }
}

class _PlanVisualMarker extends StatelessWidget {
  const _PlanVisualMarker({
    required this.iconLabel,
    required this.colorValue,
    required this.size,
    this.markerKey,
  });

  final String iconLabel;
  final int colorValue;
  final double size;
  final Key? markerKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final identityColor = Color(colorValue);
    final markerText = iconLabel.trim().isEmpty ? '🎯' : iconLabel.trim();

    return Container(
      key: markerKey,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: identityColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: identityColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        String.fromCharCodes(markerText.runes.take(2)),
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.brightness == Brightness.dark
              ? identityColor.withValues(alpha: 0.92)
              : identityColor,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
