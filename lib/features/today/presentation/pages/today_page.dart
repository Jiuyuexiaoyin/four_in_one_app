import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_tile.dart';
import 'package:four_in_one_app/shared/widgets/product/product_page_header.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final pendingHabits = habitsStore.habits
        .where((habit) => !habitsStore.isCompletedToday(habit))
        .take(2)
        .toList(growable: false);
    final completedActionCount = goalsStore.tasks
        .where((task) => task.isCompleted)
        .length;
    final totalActionCount = goalsStore.tasks.length;
    final todayKey = habitsStore.currentDayKey;
    final todayPlanRecords = goalsStore.records
        .where((record) => record.localDate == todayKey)
        .toList(growable: false);
    final habitLinkedPlanRecordCount = todayPlanRecords
        .where(
          (record) => record.sourceType == GoalsStore.habitPlanRecordSourceType,
        )
        .length;
    final bestHabitStreak = _bestHabitStreak(habitsStore);
    final todayReminderCount = _todayReminderCount(habitsStore);
    final recentHabitActivityCount = _recentHabitActivityCount(habitsStore);
    final previewActions = goalsStore.tasks
        .where((task) => !task.isCompleted)
        .take(2)
        .toList(growable: false);
    final todayFocusSessions = focusStore.sessions
        .where(
          (session) => _localDateKey(session.completedAt.toLocal()) == todayKey,
        )
        .toList(growable: false);
    final todayFocusMinutes = todayFocusSessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds ~/ 60,
    );

    return ListView(
      padding: const EdgeInsets.all(AppThemeTokens.pagePadding),
      children: [
        const ProductPageHeader(title: '今日中心', subtitle: '先看今天要养成、要推进、要专注的事。'),
        const SizedBox(height: 20),
        _TodayRhythmSurface(
          completedHabits: habitsStore.completedCount,
          totalHabits: habitsStore.totalCount,
          totalCheckInsToday: habitsStore.totalCheckInsToday,
          completedActions: completedActionCount,
          totalActions: totalActionCount,
          bestHabitStreak: bestHabitStreak,
          todayPlanRecordCount: todayPlanRecords.length,
          remainingHabits: habitsStore.remainingCount,
          planCueLabel: _planCueLabel(goalsStore, previewActions),
          focusCueLabel: _focusCueLabel(focusStore, todayFocusMinutes),
          todayFocusMinutes: todayFocusMinutes,
          onViewHabits: () {
            Navigator.of(context).pushNamed(AppRoute.habits);
          },
        ),
        const SizedBox(height: 18),
        _TodayHabitsSummaryCard(
          completedCount: habitsStore.completedCount,
          totalCount: habitsStore.totalCount,
          remainingCount: habitsStore.remainingCount,
          totalCheckInsToday: habitsStore.totalCheckInsToday,
          bestStreakDays: bestHabitStreak,
          todayReminderCount: todayReminderCount,
          recentActivityCount: recentHabitActivityCount,
          pendingPreviewHabits: pendingHabits,
          habitsStore: habitsStore,
          onViewAll: () {
            Navigator.of(context).pushNamed(AppRoute.habits);
          },
        ),
        const SizedBox(height: 16),
        _TodayGoalsSummaryCard(
          previewGoals: goalsStore.goals.take(2).toList(growable: false),
          previewActions: previewActions,
          goalsStore: goalsStore,
          todayPlanRecordCount: todayPlanRecords.length,
          habitLinkedPlanRecordCount: habitLinkedPlanRecordCount,
          onViewAll: () {
            Navigator.of(context).pushNamed(AppRoute.goals);
          },
        ),
        const SizedBox(height: 16),
        _TodayFocusSummaryCard(
          focusStore: focusStore,
          todaySessionCount: todayFocusSessions.length,
          todayFocusMinutes: todayFocusMinutes,
          onViewAll: () {
            Navigator.of(context).pushNamed(AppRoute.focus);
          },
        ),
        const SizedBox(height: 16),
        _TodayReviewPreviewCard(
          totalCheckInsToday: habitsStore.totalCheckInsToday,
          completedActions: completedActionCount,
          todayPlanRecordCount: todayPlanRecords.length,
          todayFocusSessionCount: todayFocusSessions.length,
        ),
      ],
    );
  }
}

class _TodayRhythmSurface extends StatelessWidget {
  const _TodayRhythmSurface({
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.completedActions,
    required this.totalActions,
    required this.bestHabitStreak,
    required this.todayPlanRecordCount,
    required this.remainingHabits,
    required this.planCueLabel,
    required this.focusCueLabel,
    required this.todayFocusMinutes,
    required this.onViewHabits,
  });

  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final int completedActions;
  final int totalActions;
  final int bestHabitStreak;
  final int todayPlanRecordCount;
  final int remainingHabits;
  final String planCueLabel;
  final String focusCueLabel;
  final int todayFocusMinutes;
  final VoidCallback onViewHabits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      backgroundColor: AppThemeTokens.selectedStateTone(colorScheme).withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.28 : 0.44,
      ),
      borderColor: colorScheme.primary.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '今天的节奏',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                key: const ValueKey('today-habits-view-all'),
                onPressed: onViewHabits,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('查看习惯'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '今日优先：养成、推进、专注',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '先看最重要的事',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          MetricStrip(
            tileWidth: 118,
            metrics: [
              MetricTileData(
                value: '$completedHabits/$totalHabits',
                label: '今日达标',
              ),
              MetricTileData(
                value: '$completedActions/$totalActions',
                label: '计划推进',
              ),
              MetricTileData(
                value: todayFocusMinutes > 0 ? '$todayFocusMinutes 分' : '待开始',
                label: '专注状态',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TodaySignalChips(
            labels: [
              totalHabits == 0
                  ? '先建立一项习惯'
                  : remainingHabits == 0
                  ? '习惯已达标'
                  : '习惯待达标 $remainingHabits',
              '打卡 $totalCheckInsToday',
              '计划记录 $todayPlanRecordCount',
              todayFocusMinutes > 0 ? focusCueLabel : '连续 $bestHabitStreak 天',
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayHabitsSummaryCard extends StatelessWidget {
  const _TodayHabitsSummaryCard({
    required this.completedCount,
    required this.totalCount,
    required this.remainingCount,
    required this.totalCheckInsToday,
    required this.bestStreakDays,
    required this.todayReminderCount,
    required this.recentActivityCount,
    required this.pendingPreviewHabits,
    required this.habitsStore,
    required this.onViewAll,
  });

  final int completedCount;
  final int totalCount;
  final int remainingCount;
  final int totalCheckInsToday;
  final int bestStreakDays;
  final int todayReminderCount;
  final int recentActivityCount;
  final List<HabitItem> pendingPreviewHabits;
  final HabitsStore habitsStore;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allCompleted = totalCount > 0 && remainingCount == 0;

    return _TodayModuleCard(
      title: '今日习惯',
      subtitle: '每天重复的小事，轻一点完成。',
      viewAllKey: const ValueKey('today-habits-card-view-all'),
      onViewAll: onViewAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodayMetricRow(
            completedCount: completedCount,
            totalCount: totalCount,
            completedKey: 'today-habits-completed',
            totalKey: 'today-habits-total',
            caption: '达到今日目标的习惯',
          ),
          const SizedBox(height: 8),
          Text(
            '今日打卡 $totalCheckInsToday 次',
            key: const ValueKey('today-habits-check-ins-total'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _TodaySignalChips(
            labels: [
              '连续 $bestStreakDays 天',
              '今日提醒 $todayReminderCount 个',
              '近 7 天 $recentActivityCount 次',
            ],
          ),
          const SizedBox(height: 16),
          _TodaySummaryCallout(
            backgroundColor: allCompleted
                ? AppThemeTokens.selectedStateTone(colorScheme)
                : AppThemeTokens.softSurfaceTone(colorScheme),
            borderColor: allCompleted
                ? colorScheme.primary.withValues(alpha: 0.18)
                : AppThemeTokens.borderTone(colorScheme),
            icon: allCompleted
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            iconColor: allCompleted
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            text: totalCount == 0
                ? '还没有习惯，去习惯页创建第一项。'
                : allCompleted
                ? '今天的习惯目标都已达成。'
                : '还有 $remainingCount 项习惯未达到今日目标。',
          ),
          const SizedBox(height: 18),
          if (totalCount == 0)
            const _TodayEmptyState(
              emptyKey: ValueKey('today-habits-empty-state'),
              title: '还没有习惯',
              description: '去习惯页添加后，这里会自动同步摘要。',
            )
          else if (pendingPreviewHabits.isEmpty)
            const _TodayEmptyState(
              emptyKey: ValueKey('today-habits-all-complete-state'),
              title: '今天都已达标',
              description: '保持轻一点，明天继续。',
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '还可继续',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...pendingPreviewHabits.map(
                  (habit) => _TodayPreviewRow(
                    title: '${habit.emoji} ${habit.name}',
                    detailLabel:
                        '今日 ${habitsStore.todayCheckInCount(habit)} / ${habit.targetCountPerDay}',
                    completed: habitsStore.isCompletedToday(habit),
                    completedLabel: '已达标',
                    pendingLabel: '继续',
                    supportingLabel: _joinNonEmpty([
                      _habitReminderSummary(habit),
                      _habitTodayRecordSignal(habit),
                    ]),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String? _habitReminderSummary(HabitItem habit) {
    final enabledRules = habit.enabledReminderRules;
    if (enabledRules.isEmpty) {
      return habit.reminderTime == null ? null : '提醒 ${habit.reminderTime}';
    }

    final times = enabledRules
        .map((rule) => rule.time)
        .toSet()
        .take(2)
        .join('、');
    return enabledRules.length > 2
        ? '提醒 $times 等 ${enabledRules.length} 个'
        : '提醒 $times';
  }

  String? _habitTodayRecordSignal(HabitItem habit) {
    final records = habitsStore.recordsForHabitDate(
      habit,
      habitsStore.currentDayKey,
    );
    final noteCount = records
        .where((record) => record.note?.trim().isNotEmpty ?? false)
        .length;
    final imageCount = records.fold<int>(
      0,
      (sum, record) => sum + habitsStore.attachmentsForRecord(record.id).length,
    );

    return _joinNonEmpty([
      noteCount == 0 ? null : '备注 $noteCount',
      imageCount == 0 ? null : '图片 $imageCount',
    ]);
  }
}

class _TodayGoalsSummaryCard extends StatelessWidget {
  const _TodayGoalsSummaryCard({
    required this.previewGoals,
    required this.previewActions,
    required this.goalsStore,
    required this.todayPlanRecordCount,
    required this.habitLinkedPlanRecordCount,
    required this.onViewAll,
  });

  final List<GoalItem> previewGoals;
  final List<GoalTaskItem> previewActions;
  final GoalsStore goalsStore;
  final int todayPlanRecordCount;
  final int habitLinkedPlanRecordCount;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalCount = goalsStore.totalCount;
    final projectCount = goalsStore.projects.length;
    final subprojectCount = goalsStore.subprojects.length;
    final actionCount = goalsStore.tasks.length;
    final completedActionCount = goalsStore.tasks
        .where((task) => task.isCompleted)
        .length;

    return _TodayModuleCard(
      title: '目标规划',
      subtitle: '把目标拆成今天能走的一步。',
      viewAllKey: const ValueKey('today-goals-view-all'),
      onViewAll: onViewAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricStrip(
            metrics: [
              MetricTileData(
                label: '当前推进目标',
                value: '$goalCount',
                valueKey: 'today-goals-active-count',
              ),
              MetricTileData(
                label: '项目',
                value: '$projectCount',
                valueKey: 'today-goals-project-count',
              ),
              MetricTileData(
                label: '子项目',
                value: '$subprojectCount',
                valueKey: 'today-goals-subproject-count',
              ),
              MetricTileData(
                label: '已完成行动',
                value: '$completedActionCount / $actionCount',
                valueKey: 'today-goals-action-progress',
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TodaySignalChips(
            labels: [
              '今日计划记录 $todayPlanRecordCount 条',
              '来自习惯 $habitLinkedPlanRecordCount 条',
            ],
          ),
          const SizedBox(height: 16),
          _TodaySummaryCallout(
            backgroundColor:
                actionCount > 0 && completedActionCount == actionCount
                ? AppThemeTokens.selectedStateTone(colorScheme)
                : AppThemeTokens.softSurfaceTone(colorScheme),
            borderColor: actionCount > 0 && completedActionCount == actionCount
                ? colorScheme.primary.withValues(alpha: 0.16)
                : AppThemeTokens.borderTone(colorScheme),
            icon: actionCount > 0 && completedActionCount == actionCount
                ? Icons.flag_circle_rounded
                : Icons.flag_outlined,
            iconColor: actionCount > 0 && completedActionCount == actionCount
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            text: goalCount == 0
                ? '还没有计划，先去计划页写下长期结果。'
                : actionCount == 0
                ? '先把目标拆成项目和行动。'
                : '已完成 $completedActionCount / $actionCount 个行动。',
          ),
          const SizedBox(height: 18),
          if (previewGoals.isEmpty)
            const _TodayEmptyState(
              emptyKey: ValueKey('today-goals-empty-state'),
              title: '还没有计划',
              description: '去计划页创建长期目标后，这里会显示规划摘要。',
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previewActions.isNotEmpty) ...[
                  Text(
                    '今日可推进',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...previewActions.map(
                    (task) => _TodayPreviewRow(
                      title: task.title,
                      detailLabel: _taskContextLabel(task),
                      completed: task.isCompleted,
                      completedLabel: '已完成',
                      pendingLabel: '行动',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '目标概览',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...previewGoals.map((goal) {
                  final progress = goalsStore.computeGoalProgress(goal.id);

                  return _TodayPreviewRow(
                    title: goal.title,
                    detailLabel:
                        '项目 ${goalsStore.projectCountForGoal(goal.id)} · 行动 ${goalsStore.taskCountForGoal(goal.id)} · ${progress.label}',
                    completed: progress.isComplete,
                    completedLabel: '已达成',
                    pendingLabel: progress.hasTasks ? '推进中' : '待拆解',
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  String? _taskContextLabel(GoalTaskItem task) {
    ProjectItem? project;
    for (final candidate in goalsStore.projects) {
      if (candidate.id == task.projectId) {
        project = candidate;
        break;
      }
    }

    SubprojectItem? subproject;
    if (task.subprojectId != null) {
      for (final candidate in goalsStore.subprojects) {
        if (candidate.id == task.subprojectId) {
          subproject = candidate;
          break;
        }
      }
    }

    return _joinNonEmpty([
      project == null ? null : '项目 ${project.title}',
      subproject == null ? null : '分组 ${subproject.title}',
    ]);
  }
}

class _TodayFocusSummaryCard extends StatelessWidget {
  const _TodayFocusSummaryCard({
    required this.focusStore,
    required this.todaySessionCount,
    required this.todayFocusMinutes,
    required this.onViewAll,
  });

  final FocusStore focusStore;
  final int todaySessionCount;
  final int todayFocusMinutes;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stateStyle = _resolveStateStyle(colorScheme, focusStore.status);
    final currentTarget = focusStore.currentTarget;

    return _TodayModuleCard(
      title: '专注概览',
      subtitle: '准备好，就进入一轮推进。',
      viewAllKey: const ValueKey('today-focus-view-all'),
      onViewAll: onViewAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  focusStore.formattedRemaining,
                  key: const ValueKey('today-focus-remaining'),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppThemeTokens.softSurfaceTone(colorScheme),
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusPill,
                  ),
                  border: Border.all(color: stateStyle.borderColor),
                ),
                child: Text(
                  _statusLabel(focusStore.status),
                  key: const ValueKey('today-focus-status'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: stateStyle.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentTarget == null
                ? '本轮 ${focusStore.selectedDurationSeconds ~/ 60} 分钟 · 未绑定行动'
                : '绑定：${_focusTargetLabel(currentTarget)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _TodaySignalChips(
            labels: [
              '今日专注 $todaySessionCount 轮',
              '今日 $todayFocusMinutes 分钟',
              '本轮 ${focusStore.selectedDurationSeconds ~/ 60} 分钟',
            ],
          ),
          const SizedBox(height: 16),
          _TodaySummaryCallout(
            backgroundColor: stateStyle.backgroundColor,
            borderColor: stateStyle.borderColor,
            icon: stateStyle.icon,
            iconColor: stateStyle.accentColor,
            text: _statusDescription(focusStore),
          ),
        ],
      ),
    );
  }

  _FocusStateStyle _resolveStateStyle(
    ColorScheme colorScheme,
    FocusStatus status,
  ) {
    switch (status) {
      case FocusStatus.running:
        return _FocusStateStyle(
          backgroundColor: AppThemeTokens.selectedStateTone(colorScheme),
          borderColor: colorScheme.primary.withValues(alpha: 0.16),
          accentColor: colorScheme.primary,
          icon: Icons.play_circle_rounded,
        );
      case FocusStatus.paused:
        return _FocusStateStyle(
          backgroundColor: colorScheme.secondaryContainer.withValues(
            alpha: 0.4,
          ),
          borderColor: colorScheme.secondary.withValues(alpha: 0.16),
          accentColor: colorScheme.secondary,
          icon: Icons.pause_circle_rounded,
        );
      case FocusStatus.idle:
        return _FocusStateStyle(
          backgroundColor: AppThemeTokens.softSurfaceTone(colorScheme),
          borderColor: AppThemeTokens.borderTone(colorScheme),
          accentColor: colorScheme.onSurfaceVariant,
          icon: Icons.hourglass_bottom_rounded,
        );
    }
  }

  String _statusLabel(FocusStatus status) {
    return _focusStatusLabel(status);
  }

  String _statusDescription(FocusStore focusStore) {
    final target = focusStore.currentTarget;

    if (focusStore.isRunning) {
      return target == null
          ? '专注正在进行，保持当下节奏。'
          : '正在推进「${target.title}」，保持当下节奏。';
    }

    if (focusStore.isPaused) {
      return target == null
          ? '这一轮已暂停，可去专注页继续。'
          : '「${target.title}」这一轮已暂停，可去专注页继续。';
    }

    if (focusStore.remainingSeconds == 0) {
      return '这一轮已完成，可去专注页开始下一轮。';
    }

    return target == null
        ? '准备好后去专注页开始一轮安静推进。'
        : '准备好后去专注页推进「${target.title}」。';
  }
}

class _TodayModuleCard extends StatelessWidget {
  const _TodayModuleCard({
    required this.title,
    required this.subtitle,
    required this.viewAllKey,
    required this.onViewAll,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Key viewAllKey;
  final VoidCallback onViewAll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      height: 1.35,
                    ),
                  ),
                ],
              );
              final action = TextButton.icon(
                key: viewAllKey,
                onPressed: onViewAll,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('查看全部'),
              );

              if (constraints.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: action),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  action,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _TodayMetricRow extends StatelessWidget {
  const _TodayMetricRow({
    required this.completedCount,
    required this.totalCount,
    required this.completedKey,
    required this.totalKey,
    required this.caption,
  });

  final int completedCount;
  final int totalCount;
  final String completedKey;
  final String totalKey;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$completedCount',
              key: ValueKey<String>(completedKey),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '/ $totalCount',
                key: ValueKey<String>(totalKey),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryCallout extends StatelessWidget {
  const _TodaySummaryCallout({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TodayPreviewRow extends StatelessWidget {
  const _TodayPreviewRow({
    required this.title,
    required this.completed,
    required this.completedLabel,
    required this.pendingLabel,
    this.detailLabel,
    this.supportingLabel,
  });

  final String title;
  final bool completed;
  final String completedLabel;
  final String pendingLabel;
  final String? detailLabel;
  final String? supportingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: completed
              ? AppThemeTokens.selectedStateTone(
                  colorScheme,
                ).withValues(alpha: 0.62)
              : AppThemeTokens.softSurfaceTone(colorScheme),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          border: Border.all(
            color: completed
                ? colorScheme.primary.withValues(alpha: 0.10)
                : AppThemeTokens.borderTone(
                    colorScheme,
                  ).withValues(alpha: 0.74),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 38,
              decoration: BoxDecoration(
                color: completed
                    ? colorScheme.primary.withValues(alpha: 0.46)
                    : colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: completed
                    ? colorScheme.primary.withValues(alpha: 0.92)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed
                      ? colorScheme.primary.withValues(alpha: 0.28)
                      : AppThemeTokens.borderTone(colorScheme),
                ),
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: completed
                    ? colorScheme.onPrimary
                    : AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: completed
                          ? AppThemeTokens.secondaryTextTone(colorScheme)
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  if (detailLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detailLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (supportingLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      supportingLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 0,
              child: Text(
                completed ? completedLabel : pendingLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: completed
                      ? colorScheme.primary
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySignalChips extends StatelessWidget {
  const _TodaySignalChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final visibleLabels = labels
        .where((label) => label.trim().isNotEmpty)
        .toList(growable: false);

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (var index = 0; index < visibleLabels.length; index += 1)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppThemeTokens.secondaryTextTone(
                        colorScheme,
                      ).withValues(alpha: 0.58),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(
                visibleLabels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

int _bestHabitStreak(HabitsStore habitsStore) {
  var best = 0;
  for (final habit in habitsStore.habits) {
    final streak = habitsStore.statisticsForHabit(habit).currentStreakDays;
    if (streak > best) {
      best = streak;
    }
  }

  return best;
}

int _todayReminderCount(HabitsStore habitsStore) {
  return habitsStore.habits.fold<int>(
    0,
    (sum, habit) =>
        sum +
        (habit.enabledReminderRules.isNotEmpty
            ? habit.enabledReminderRules.length
            : (habit.reminderTime == null ? 0 : 1)),
  );
}

int _recentHabitActivityCount(HabitsStore habitsStore) {
  return habitsStore.habits.fold<int>(
    0,
    (sum, habit) =>
        sum +
        habitsStore
            .recentActivityDays(habit)
            .fold<int>(0, (daySum, day) => daySum + day.count),
  );
}

String _planCueLabel(GoalsStore goalsStore, List<GoalTaskItem> previewActions) {
  if (previewActions.isNotEmpty) {
    return '推进 ${previewActions.first.title}';
  }

  if (goalsStore.records.isNotEmpty) {
    return '已有 ${goalsStore.records.length} 条计划记录';
  }

  if (goalsStore.tasks.isNotEmpty) {
    return '行动都已完成';
  }

  return goalsStore.totalCount == 0 ? '先写下一个目标' : '先拆解一个行动';
}

String _focusCueLabel(FocusStore focusStore, int todayFocusMinutes) {
  final target = focusStore.currentTarget;
  if (target != null) {
    return '推进 ${target.title}';
  }

  if (focusStore.isRunning) {
    return '专注进行中';
  }

  if (todayFocusMinutes > 0) {
    return '今日已专注 $todayFocusMinutes 分钟';
  }

  return '准备一轮 ${focusStore.selectedDurationSeconds ~/ 60} 分钟';
}

String _focusStatusLabel(FocusStatus status) {
  switch (status) {
    case FocusStatus.idle:
      return '空闲中';
    case FocusStatus.running:
      return '专注中';
    case FocusStatus.paused:
      return '已暂停';
  }
}

String _localDateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _focusTargetLabel(FocusTargetSnapshot target) {
  return _joinNonEmpty([target.title, target.context]) ?? target.title;
}

String? _joinNonEmpty(List<String?> values) {
  final joined = values
      .where((value) => value != null && value.trim().isNotEmpty)
      .map((value) => value!.trim())
      .join(' · ');
  return joined.isEmpty ? null : joined;
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState({
    required this.emptyKey,
    required this.title,
    required this.description,
  });

  final Key emptyKey;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: emptyKey,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayReviewPreviewCard extends StatelessWidget {
  const _TodayReviewPreviewCard({
    required this.totalCheckInsToday,
    required this.completedActions,
    required this.todayPlanRecordCount,
    required this.todayFocusSessionCount,
  });

  final int totalCheckInsToday;
  final int completedActions;
  final int todayPlanRecordCount;
  final int todayFocusSessionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日回看', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '复盘保持只读，只收束今天已经发生的真实记录。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: 10),
          _TodaySignalChips(
            labels: [
              '打卡 $totalCheckInsToday 次',
              '计划记录 $todayPlanRecordCount 条',
              '完成行动 $completedActions 个',
              '专注 $todayFocusSessionCount 轮',
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusStateStyle {
  const _FocusStateStyle({
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
