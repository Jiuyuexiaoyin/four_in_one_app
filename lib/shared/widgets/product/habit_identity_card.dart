import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/activity_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/progress_rail.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

final ButtonStyle _compactSecondaryActionStyle = TextButton.styleFrom(
  minimumSize: const Size(44, 36),
  padding: const EdgeInsets.symmetric(horizontal: 8),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

class HabitIdentityCard extends StatelessWidget {
  const HabitIdentityCard({
    required this.habitId,
    required this.emoji,
    required this.name,
    required this.todayCount,
    required this.targetCount,
    required this.targetReached,
    required this.recentActivityItems,
    required this.onCheckIn,
    required this.onEdit,
    required this.onReminderTap,
    required this.onMonthView,
    required this.onRecordDetails,
    required this.onStatistics,
    required this.onLifecycleTap,
    this.description,
    this.reminderSummary = '未设置提醒',
    this.hasReminder = false,
    this.skippedToday = false,
    this.accentColor,
    this.lifecycleLabel,
    this.lifecycleDescription,
    this.planLinkSummary,
    this.planLinkUnavailable = false,
    super.key,
  });

  final String habitId;
  final String emoji;
  final String name;
  final String? description;
  final int todayCount;
  final int targetCount;
  final bool targetReached;
  final bool skippedToday;
  final String reminderSummary;
  final bool hasReminder;
  final Color? accentColor;
  final String? lifecycleLabel;
  final String? lifecycleDescription;
  final String? planLinkSummary;
  final bool planLinkUnavailable;
  final List<ActivityStripItem> recentActivityItems;
  final VoidCallback? onCheckIn;
  final VoidCallback onEdit;
  final VoidCallback onReminderTap;
  final VoidCallback onMonthView;
  final VoidCallback? onRecordDetails;
  final VoidCallback onStatistics;
  final VoidCallback onLifecycleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccentColor = accentColor ?? colorScheme.primary;
    final backgroundColor = AppThemeTokens.softSurfaceTone(colorScheme);

    return SoftSurface(
      backgroundColor: backgroundColor,
      borderColor: targetReached
          ? effectiveAccentColor.withValues(alpha: 0.16)
          : AppThemeTokens.borderTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final identity = _HabitIdentityHeader(
                emoji: emoji,
                name: name,
                description: description,
                lifecycleLabel: lifecycleLabel,
                lifecycleDescription: lifecycleDescription,
                planLinkSummary: planLinkSummary,
                planLinkUnavailable: planLinkUnavailable,
                habitId: habitId,
                accentColor: effectiveAccentColor,
              );
              final actions = _HabitCardActionCluster(
                habitId: habitId,
                onCheckIn: onCheckIn,
                onEdit: onEdit,
                onLifecycleTap: onLifecycleTap,
              );

              if (constraints.maxWidth < 330) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: AppThemeTokens.spaceMd),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: AppThemeTokens.spaceMd),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: AppThemeTokens.spaceLg),
          _CheckInProgressPanel(
            todayCount: todayCount,
            targetCount: targetCount,
            targetReached: targetReached,
            skippedToday: skippedToday,
            accentColor: effectiveAccentColor,
          ),
          if (skippedToday) ...[
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              '今天已跳过',
              key: ValueKey<String>('habit-skip-state-$habitId'),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppThemeTokens.spaceMd),
          _HabitReminderChip(
            habitId: habitId,
            reminderSummary: reminderSummary,
            hasReminder: hasReminder,
            onTap: onReminderTap,
            accentColor: effectiveAccentColor,
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          Wrap(
            spacing: AppThemeTokens.spaceSm,
            runSpacing: AppThemeTokens.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '最近 7 天',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                key: ValueKey<String>('habit-records-$habitId'),
                onPressed: onRecordDetails,
                style: _compactSecondaryActionStyle,
                child: const Text('记录'),
              ),
              TextButton(
                key: ValueKey<String>('habit-stats-$habitId'),
                onPressed: onStatistics,
                style: _compactSecondaryActionStyle,
                child: const Text('统计'),
              ),
              TextButton(
                key: ValueKey<String>('habit-activity-month-$habitId'),
                onPressed: onMonthView,
                style: _compactSecondaryActionStyle,
                child: const Text('月视图'),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          ActivityStrip(
            items: recentActivityItems,
            accentColor: effectiveAccentColor,
          ),
        ],
      ),
    );
  }
}

class _HabitIdentityHeader extends StatelessWidget {
  const _HabitIdentityHeader({
    required this.emoji,
    required this.name,
    required this.description,
    required this.lifecycleLabel,
    required this.lifecycleDescription,
    required this.planLinkSummary,
    required this.planLinkUnavailable,
    required this.habitId,
    required this.accentColor,
  });

  final String emoji;
  final String name;
  final String? description;
  final String? lifecycleLabel;
  final String? lifecycleDescription;
  final String? planLinkSummary;
  final bool planLinkUnavailable;
  final String habitId;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HabitEmojiBadge(emoji: emoji, accentColor: accentColor),
        const SizedBox(width: AppThemeTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: AppThemeTokens.spaceXs),
                Text(
                  description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    height: 1.35,
                  ),
                ),
              ],
              if (lifecycleLabel != null) ...[
                const SizedBox(height: AppThemeTokens.spaceSm),
                _HabitLifecycleChip(
                  label: lifecycleLabel!,
                  description: lifecycleDescription,
                  accentColor: accentColor,
                ),
              ],
              if (planLinkSummary != null) ...[
                const SizedBox(height: AppThemeTokens.spaceSm),
                _HabitPlanLinkChip(
                  habitId: habitId,
                  label: planLinkSummary!,
                  unavailable: planLinkUnavailable,
                  accentColor: accentColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HabitCardActionCluster extends StatelessWidget {
  const _HabitCardActionCluster({
    required this.habitId,
    required this.onCheckIn,
    required this.onEdit,
    required this.onLifecycleTap,
  });

  final String habitId;
  final VoidCallback? onCheckIn;
  final VoidCallback onEdit;
  final VoidCallback onLifecycleTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppThemeTokens.spaceXs,
      runSpacing: AppThemeTokens.spaceXs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          key: ValueKey<String>('habit-check-in-$habitId'),
          onPressed: onCheckIn,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('打卡'),
        ),
        IconButton(
          key: ValueKey<String>('habit-edit-$habitId'),
          tooltip: '编辑习惯',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          color: AppThemeTokens.secondaryTextTone(colorScheme),
        ),
        IconButton(
          key: ValueKey<String>('habit-lifecycle-$habitId'),
          tooltip: '管理习惯状态',
          onPressed: onLifecycleTap,
          icon: const Icon(Icons.more_horiz_rounded),
          color: AppThemeTokens.secondaryTextTone(colorScheme),
        ),
      ],
    );
  }
}

class _HabitLifecycleChip extends StatelessWidget {
  const _HabitLifecycleChip({
    required this.label,
    required this.description,
    required this.accentColor,
  });

  final String label;
  final String? description;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(width: AppThemeTokens.spaceXs),
            Text(
              description!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitPlanLinkChip extends StatelessWidget {
  const _HabitPlanLinkChip({
    required this.habitId,
    required this.label,
    required this.unavailable,
    required this.accentColor,
  });

  final String habitId;
  final String label;
  final bool unavailable;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tone = unavailable ? colorScheme.error : accentColor;

    return Container(
      key: ValueKey<String>('habit-plan-link-$habitId'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unavailable ? Icons.link_off_rounded : Icons.account_tree_outlined,
            size: 14,
            color: tone,
          ),
          const SizedBox(width: AppThemeTokens.spaceXs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: unavailable
                    ? colorScheme.error
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitEmojiBadge extends StatelessWidget {
  const _HabitEmojiBadge({required this.emoji, required this.accentColor});

  final String emoji;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Text(
        emoji,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1),
      ),
    );
  }
}

class _CheckInProgressPanel extends StatelessWidget {
  const _CheckInProgressPanel({
    required this.todayCount,
    required this.targetCount,
    required this.targetReached,
    required this.skippedToday,
    required this.accentColor,
  });

  final int todayCount;
  final int targetCount;
  final bool targetReached;
  final bool skippedToday;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = targetCount <= 0
        ? 0.0
        : (todayCount / targetCount).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppThemeTokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TargetPill(
                count: todayCount,
                target: targetCount,
                completed: targetReached,
                accentColor: accentColor,
              ),
              const Spacer(),
              Text(
                targetReached ? '已达标' : '继续打卡',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: targetReached
                      ? accentColor
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          ProgressRail(
            value: progress,
            height: 6,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.48,
            ),
            fillColor: targetReached
                ? accentColor
                : accentColor.withValues(alpha: 0.62),
          ),
        ],
      ),
    );
  }
}

class _HabitReminderChip extends StatelessWidget {
  const _HabitReminderChip({
    required this.habitId,
    required this.reminderSummary,
    required this.hasReminder,
    required this.onTap,
    required this.accentColor,
  });

  final String habitId;
  final String reminderSummary;
  final bool hasReminder;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      key: ValueKey<String>('habit-reminder-$habitId'),
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeTokens.spaceXs,
          vertical: AppThemeTokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        ),
        child: Row(
          children: [
            Icon(
              hasReminder
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_outlined,
              size: 16,
              color: hasReminder
                  ? accentColor
                  : AppThemeTokens.secondaryTextTone(colorScheme),
            ),
            const SizedBox(width: AppThemeTokens.spaceXs),
            Flexible(
              child: Text(
                hasReminder ? '提醒 $reminderSummary' : '未设置提醒',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasReminder
                      ? AppThemeTokens.secondaryTextTone(colorScheme)
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppThemeTokens.spaceXs),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  const _TargetPill({
    required this.count,
    required this.target,
    required this.completed,
    required this.accentColor,
  });

  final int count;
  final int target;
  final bool completed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      '今日 $count / $target',
      key: ValueKey<String>('habit-today-count-$count-$target'),
      style: theme.textTheme.titleLarge?.copyWith(
        color: completed ? accentColor : colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }
}
