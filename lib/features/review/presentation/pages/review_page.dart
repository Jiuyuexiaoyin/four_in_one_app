import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/app_section_panel.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final reviewData = _ReviewData.fromStores(
      habitsStore: habitsStore,
      goalsStore: goalsStore,
      focusStore: focusStore,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageTop,
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageBottomSecondary,
      ),
      children: [
        StitchExactCommandHeader(
          eyebrow: '复盘',
          title: '今日回看',
          subtitle: '复盘只读取本地真实记录。',
          leadingIcon: Icons.insights_rounded,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StitchExactStatusPill(
              label: '打卡',
              value: '${reviewData.habitCheckInsToday}',
              selected: reviewData.habitCheckInsToday > 0,
            ),
            StitchExactStatusPill(
              label: '行动',
              value:
                  '${reviewData.completedActionCount}/${reviewData.actionCount}',
              selected: reviewData.actionCount > 0,
            ),
            StitchExactStatusPill(
              label: '专注',
              value: '${reviewData.focusCompletedSessions}',
              selected: reviewData.focusCompletedSessions > 0,
            ),
          ],
        ),
        const SizedBox(height: 26),
        _ReviewOverviewHero(data: reviewData),
        const SizedBox(height: 26),
        _ReviewHabitsSection(data: reviewData),
        const SizedBox(height: 26),
        _ReviewPlanSection(data: reviewData),
        const SizedBox(height: 26),
        _ReviewFocusSection(
          sectionKey: const ValueKey('review-focus-section'),
          data: reviewData,
          focusStore: focusStore,
        ),
        const SizedBox(height: 26),
        const _ReviewNote(note: '复盘只展示真实记录，不补假趋势。'),
      ],
    );
  }
}

class _ReviewData {
  const _ReviewData({
    required this.habitTotalCount,
    required this.habitCompletedCount,
    required this.habitCheckInsToday,
    required this.habitRecentCheckIns,
    required this.habitRecentActiveDays,
    required this.habitRecentDayCounts,
    required this.goalCount,
    required this.projectCount,
    required this.subprojectCount,
    required this.actionCount,
    required this.completedActionCount,
    required this.focusCompletedSessions,
    required this.focusCompletedMinutes,
    required this.latestFocusTargetTitle,
    required this.focusRecentDayCounts,
  });

  final int habitTotalCount;
  final int habitCompletedCount;
  final int habitCheckInsToday;
  final int habitRecentCheckIns;
  final int habitRecentActiveDays;
  final List<int> habitRecentDayCounts;
  final int goalCount;
  final int projectCount;
  final int subprojectCount;
  final int actionCount;
  final int completedActionCount;
  final int focusCompletedSessions;
  final int focusCompletedMinutes;
  final String? latestFocusTargetTitle;
  final List<int> focusRecentDayCounts;

  int? get habitCompletionRate => habitTotalCount > 0
      ? ((habitCompletedCount / habitTotalCount) * 100).round()
      : null;

  int? get planProgressRate => actionCount > 0
      ? ((completedActionCount / actionCount) * 100).round()
      : null;

  bool get hasAnyRealData =>
      habitTotalCount > 0 ||
      goalCount > 0 ||
      actionCount > 0 ||
      focusCompletedSessions > 0;

  static _ReviewData fromStores({
    required HabitsStore habitsStore,
    required GoalsStore goalsStore,
    required FocusStore focusStore,
  }) {
    final recentDayCounts = _recentHabitDayCounts(habitsStore);
    final completedActions = goalsStore.tasks
        .where((task) => task.isCompleted)
        .length;
    final focusCompletedSeconds = focusStore.sessions.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );

    return _ReviewData(
      habitTotalCount: habitsStore.totalCount,
      habitCompletedCount: habitsStore.completedCount,
      habitCheckInsToday: _todayHabitCheckIns(habitsStore),
      habitRecentCheckIns: recentDayCounts.fold<int>(
        0,
        (total, count) => total + count,
      ),
      habitRecentActiveDays: recentDayCounts.where((count) => count > 0).length,
      habitRecentDayCounts: recentDayCounts,
      goalCount: goalsStore.totalCount,
      projectCount: goalsStore.projects.length,
      subprojectCount: goalsStore.subprojects.length,
      actionCount: goalsStore.tasks.length,
      completedActionCount: completedActions,
      focusCompletedSessions: focusStore.completedSessionCount,
      focusCompletedMinutes: focusCompletedSeconds ~/ 60,
      latestFocusTargetTitle: _latestFocusTargetTitle(focusStore),
      focusRecentDayCounts: focusStore.recentDayCounts(focusStore.now),
    );
  }

  static List<int> _recentHabitDayCounts(HabitsStore habitsStore) {
    final retainedHabits = habitsStore.storedHabits
        .where((habit) => !habit.isDeleted)
        .toList(growable: false);
    if (retainedHabits.isEmpty) {
      return List<int>.filled(7, 0, growable: false);
    }

    final totals = List<int>.filled(7, 0);
    for (final habit in retainedHabits) {
      final activityDays = habitsStore.recentActivityDays(habit).reversed;
      for (var index = 0; index < activityDays.length && index < 7; index++) {
        totals[index] += activityDays.elementAt(index).count;
      }
    }

    return totals;
  }

  static int _todayHabitCheckIns(HabitsStore habitsStore) {
    final retainedHabitIds = habitsStore.storedHabits
        .where((habit) => !habit.isDeleted)
        .map((habit) => habit.id)
        .toSet();
    return habitsStore.records
        .where(
          (record) =>
              retainedHabitIds.contains(record.habitId) &&
              record.localDate == habitsStore.currentDayKey &&
              record.type != HabitRecordType.skip,
        )
        .length;
  }

  static String? _latestFocusTargetTitle(FocusStore focusStore) {
    for (final session in focusStore.sessions) {
      final targetTitle = session.target?.title;
      if (targetTitle != null && targetTitle.isNotEmpty) {
        return targetTitle;
      }
    }

    return null;
  }
}

class _ReviewOverviewHero extends StatelessWidget {
  const _ReviewOverviewHero({required this.data});

  final _ReviewData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StitchExactPanel(
      key: const ValueKey('review-overview-hero'),
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchExactCommandHeader(
            eyebrow: '进展回顾',
            title: '当前进展',
            subtitle: data.hasAnyRealData ? '来自真实记录' : '开始记录后会在这里汇总',
            leadingIcon: Icons.query_stats_rounded,
            compact: true,
            trailing: StitchExactStatusPill(
              label: data.hasAnyRealData ? '真实记录' : '暂无记录',
              selected: data.hasAnyRealData,
            ),
          ),
          const SizedBox(height: 18),
          StitchExactMetricGrid(
            minHeight: 74,
            metrics: [
              StitchExactMetric(
                valueKey: 'review-hero-habit-checkins',
                value: '${data.habitCheckInsToday}',
                label: '今日打卡',
              ),
              StitchExactMetric(
                valueKey: 'review-hero-completed-actions',
                value: '${data.completedActionCount}',
                label: '已完成行动',
                accent: colorScheme.secondary,
              ),
              StitchExactMetric(
                valueKey: 'review-hero-focus-sessions',
                value: '${data.focusCompletedSessions}',
                label: '专注次数',
                accent: colorScheme.tertiary,
              ),
              StitchExactMetric(
                valueKey: 'review-hero-plan-progress',
                value: data.planProgressRate == null
                    ? '—'
                    : '${data.planProgressRate}%',
                label: '计划进度',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewHabitsSection extends StatelessWidget {
  const _ReviewHabitsSection({required this.data});

  final _ReviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completionRate = data.habitCompletionRate;

    return AppSectionPanel(
      key: const ValueKey('review-habits-section'),
      title: '习惯活动',
      subtitle: data.habitTotalCount == 0 ? '还没有习惯数据。' : '今日目标与近 7 天打卡',
      icon: Icons.spa_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchExactMetricGrid(
            minHeight: 74,
            metrics: [
              StitchExactMetric(
                valueKey: 'review-habits-check-ins-today',
                value: '${data.habitCheckInsToday} 次',
                label: '今日打卡',
              ),
              StitchExactMetric(
                valueKey: 'review-habits-completed',
                value: '${data.habitCompletedCount}',
                label: '今日达标',
                accent: colorScheme.tertiary,
              ),
              StitchExactMetric(
                valueKey: 'review-habits-total',
                value: '${data.habitTotalCount}',
                label: '习惯总数',
              ),
              StitchExactMetric(
                valueKey: 'review-habits-active-days',
                value: '${data.habitRecentActiveDays} 天',
                label: '近 7 天活跃',
                accent: colorScheme.secondary,
              ),
            ],
          ),
          if (completionRate != null) ...[
            const SizedBox(height: 14),
            StitchExactProgressBar(
              value: completionRate / 100,
              semanticLabel: '复盘习惯完成率 $completionRate%',
            ),
            const SizedBox(height: 8),
            Text(
              '完成率 $completionRate%',
              key: const ValueKey<String>('review-habits-rate'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '近 7 天活动',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: 10),
          StitchExactMiniBars(
            values: data.habitRecentDayCounts,
            labels: const ['今', '1', '2', '3', '4', '5', '6'],
            valueKey: 'review-habits-recent-strip',
          ),
          const SizedBox(height: 10),
          Text(
            data.habitRecentCheckIns == 0
                ? '近 7 天还没有打卡记录。'
                : '近 7 天打卡 ${data.habitRecentCheckIns} 次，活跃 ${data.habitRecentActiveDays} 天。',
            key: const ValueKey('review-habits-recent-activity'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPlanSection extends StatelessWidget {
  const _ReviewPlanSection({required this.data});

  final _ReviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressRate = data.planProgressRate;

    return AppSectionPanel(
      key: const ValueKey('review-goals-section'),
      title: '计划推进',
      subtitle: _supportingLine(),
      icon: Icons.account_tree_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchExactMetricGrid(
            minHeight: 74,
            metrics: [
              StitchExactMetric(
                valueKey: 'review-goals-count',
                value: '${data.goalCount}',
                label: '目标',
              ),
              StitchExactMetric(
                valueKey: 'review-goals-projects',
                value: '${data.projectCount}',
                label: '项目',
                accent: colorScheme.secondary,
              ),
              StitchExactMetric(
                valueKey: 'review-goals-subprojects',
                value: '${data.subprojectCount}',
                label: '子项目',
                accent: colorScheme.tertiary,
              ),
              StitchExactMetric(
                valueKey: 'review-goals-tasks',
                value: '${data.actionCount}',
                label: '行动',
              ),
              StitchExactMetric(
                valueKey: 'review-goals-completed-tasks',
                value: '${data.completedActionCount}',
                label: '已完成行动',
                accent: colorScheme.tertiary,
              ),
            ],
          ),
          if (progressRate != null) ...[
            const SizedBox(height: 14),
            StitchExactProgressBar(
              value: progressRate / 100,
              accent: colorScheme.secondary,
              semanticLabel: '复盘计划进度 $progressRate%',
            ),
            const SizedBox(height: 8),
            Text(
              '进度 $progressRate%',
              key: const ValueKey<String>('review-goals-action-rate'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _supportingLine(),
            key: const ValueKey<String>('review-goals-supporting-line'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  String _supportingLine() {
    if (data.goalCount == 0) {
      return '还没有目标规划。';
    }

    if (data.actionCount == 0) {
      return '先把目标拆成项目和行动。';
    }

    return '行动进度来自任务完成。';
  }
}

class _ReviewFocusSection extends StatelessWidget {
  const _ReviewFocusSection({
    required this.sectionKey,
    required this.data,
    required this.focusStore,
  });

  final Key sectionKey;
  final _ReviewData data;
  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final latestTarget = data.latestFocusTargetTitle;

    return AppSectionPanel(
      key: sectionKey,
      title: '专注执行',
      subtitle: data.focusCompletedSessions == 0 ? '还没有完成的专注记录。' : '基于已完成专注',
      icon: Icons.timer_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchExactMetricGrid(
            minHeight: 74,
            metrics: [
              StitchExactMetric(
                valueKey: 'review-focus-completed-sessions',
                value: '${data.focusCompletedSessions} 次',
                label: '完成专注',
              ),
              StitchExactMetric(
                valueKey: 'review-focus-total-minutes',
                value: '${data.focusCompletedMinutes} 分钟',
                label: '累计时长',
                accent: colorScheme.secondary,
              ),
              StitchExactMetric(
                valueKey: 'review-focus-status',
                value: _statusLabel(focusStore.status),
                label: '当前状态',
                accent: colorScheme.tertiary,
              ),
              StitchExactMetric(
                valueKey: 'review-focus-remaining',
                value: focusStore.formattedRemaining,
                label: '剩余时间',
              ),
              StitchExactMetric(
                valueKey: 'review-focus-default-duration',
                value: '${focusStore.defaultDurationSeconds ~/ 60} 分钟',
                label: '默认时长',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '近 7 天活动',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: 10),
          StitchExactMiniBars(
            valueKey: 'review-focus-recent-strip',
            values: data.focusRecentDayCounts,
            labels: const ['今', '1', '2', '3', '4', '5', '6'],
            accent: colorScheme.secondary,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppThemeTokens.selectedStateTone(colorScheme),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最近推进',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latestTarget ?? '暂未绑定行动',
                  key: const ValueKey('review-focus-latest-target'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _supportingLine(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(FocusStatus status) {
    switch (status) {
      case FocusStatus.idle:
        return '空闲中';
      case FocusStatus.running:
        return '专注中';
      case FocusStatus.paused:
        return '已暂停';
    }
  }

  String _supportingLine() {
    if (data.focusCompletedSessions == 0) {
      return '完成专注后会留下记录。';
    }

    if (focusStore.isRunning) {
      return '当前专注正在进行。';
    }

    if (focusStore.isPaused) {
      return '当前专注已暂停。';
    }

    return '专注记录来自完整倒计时。';
  }
}

class _ReviewNote extends StatelessWidget {
  const _ReviewNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StitchExactPanel(
      padding: const EdgeInsets.all(20),
      child: Text(
        note,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
        ),
      ),
    );
  }
}
