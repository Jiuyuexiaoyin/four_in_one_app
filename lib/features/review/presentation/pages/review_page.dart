import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/activity_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/app_section_panel.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_tile.dart';
import 'package:four_in_one_app/shared/widgets/product/product_page_header.dart';
import 'package:four_in_one_app/shared/widgets/product/progress_rail.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

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
        AppThemeTokens.spaceXl,
        AppThemeTokens.pagePadding,
        AppThemeTokens.pagePadding,
      ),
      children: [
        const ProductPageHeader(title: '今日回看', subtitle: '基于已有记录，安静看见当前进展。'),
        const SizedBox(height: 24),
        _ReviewOverviewHero(data: reviewData),
        const SizedBox(height: 16),
        _ReviewHabitsSection(data: reviewData),
        const SizedBox(height: 16),
        _ReviewPlanSection(data: reviewData),
        const SizedBox(height: 16),
        _ReviewFocusSection(
          sectionKey: const ValueKey('review-focus-section'),
          data: reviewData,
          focusStore: focusStore,
        ),
        const SizedBox(height: 16),
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
    final focusCompletedMinutes = focusStore.sessions.fold<int>(
      0,
      (total, session) => total + (session.durationSeconds ~/ 60),
    );

    return _ReviewData(
      habitTotalCount: habitsStore.totalCount,
      habitCompletedCount: habitsStore.completedCount,
      habitCheckInsToday: habitsStore.totalCheckInsToday,
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
      focusCompletedMinutes: focusCompletedMinutes,
      latestFocusTargetTitle: _latestFocusTargetTitle(focusStore),
      focusRecentDayCounts: focusStore.recentDayCounts(focusStore.now),
    );
  }

  static List<int> _recentHabitDayCounts(HabitsStore habitsStore) {
    if (habitsStore.habits.isEmpty) {
      return List<int>.filled(7, 0, growable: false);
    }

    final totals = List<int>.filled(7, 0);
    for (final habit in habitsStore.habits) {
      final activityDays = habitsStore.recentActivityDays(habit);
      for (var index = 0; index < activityDays.length && index < 7; index++) {
        totals[index] += activityDays[index].count;
      }
    }

    return totals;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      key: const ValueKey('review-overview-hero'),
      tone: SoftSurfaceTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                ),
                child: Icon(Icons.insights_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前进展', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      data.hasAnyRealData ? '来自真实记录' : '开始记录后会在这里汇总',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          MetricStrip(
            tileWidth: 136,
            tileEmphasis: MetricTileEmphasis.hero,
            tileBackgroundColor: Theme.of(context).scaffoldBackgroundColor
                .withValues(
                  alpha: colorScheme.brightness == Brightness.dark
                      ? 0.22
                      : 0.58,
                ),
            tileBorderColor: colorScheme.primary.withValues(alpha: 0.08),
            metrics: [
              MetricTileData(
                valueKey: 'review-hero-habit-checkins',
                value: '${data.habitCheckInsToday}',
                label: '今日打卡',
              ),
              MetricTileData(
                valueKey: 'review-hero-completed-actions',
                value: '${data.completedActionCount}',
                label: '已完成行动',
              ),
              MetricTileData(
                valueKey: 'review-hero-focus-sessions',
                value: '${data.focusCompletedSessions}',
                label: '专注次数',
              ),
              MetricTileData(
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
          MetricStrip(
            metrics: [
              MetricTileData(
                valueKey: 'review-habits-check-ins-today',
                value: '${data.habitCheckInsToday} 次',
                label: '今日打卡',
              ),
              MetricTileData(
                valueKey: 'review-habits-completed',
                value: '${data.habitCompletedCount}',
                label: '今日达标',
              ),
              MetricTileData(
                valueKey: 'review-habits-total',
                value: '${data.habitTotalCount}',
                label: '习惯总数',
              ),
              MetricTileData(
                valueKey: 'review-habits-active-days',
                value: '${data.habitRecentActiveDays} 天',
                label: '近 7 天活跃',
              ),
            ],
          ),
          if (completionRate != null) ...[
            const SizedBox(height: 14),
            _ReviewSoftProgressBar(value: completionRate / 100),
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
          ActivityStrip(
            items: [
              for (
                var index = 0;
                index < data.habitRecentDayCounts.length;
                index += 1
              )
                ActivityStripItem(
                  count: data.habitRecentDayCounts[index],
                  semanticLabel:
                      '第 ${index + 1} 天打卡 ${data.habitRecentDayCounts[index]} 次',
                ),
            ],
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
          MetricStrip(
            metrics: [
              MetricTileData(
                valueKey: 'review-goals-count',
                value: '${data.goalCount}',
                label: '目标',
              ),
              MetricTileData(
                valueKey: 'review-goals-projects',
                value: '${data.projectCount}',
                label: '项目',
              ),
              MetricTileData(
                valueKey: 'review-goals-subprojects',
                value: '${data.subprojectCount}',
                label: '子项目',
              ),
              MetricTileData(
                valueKey: 'review-goals-tasks',
                value: '${data.actionCount}',
                label: '行动',
              ),
              MetricTileData(
                valueKey: 'review-goals-completed-tasks',
                value: '${data.completedActionCount}',
                label: '已完成行动',
              ),
            ],
          ),
          if (progressRate != null) ...[
            const SizedBox(height: 14),
            _ReviewSoftProgressBar(value: progressRate / 100),
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
          MetricStrip(
            metrics: [
              MetricTileData(
                valueKey: 'review-focus-completed-sessions',
                value: '${data.focusCompletedSessions} 次',
                label: '完成专注',
              ),
              MetricTileData(
                valueKey: 'review-focus-total-minutes',
                value: '${data.focusCompletedMinutes} 分钟',
                label: '累计时长',
              ),
              MetricTileData(
                valueKey: 'review-focus-status',
                value: _statusLabel(focusStore.status),
                label: '当前状态',
              ),
              MetricTileData(
                valueKey: 'review-focus-remaining',
                value: focusStore.formattedRemaining,
                label: '剩余时间',
              ),
              MetricTileData(
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
          ActivityStrip(
            valueKey: 'review-focus-recent-strip',
            items: [
              for (var i = 0; i < data.focusRecentDayCounts.length; i++)
                ActivityStripItem(
                  count: data.focusRecentDayCounts[i],
                  cellKey: ValueKey<String>('review-focus-recent-day-$i'),
                  semanticLabel:
                      '${i == 0 ? '今日' : '$i 天前'} ${data.focusRecentDayCounts[i]} 次',
                ),
            ],
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

class _ReviewSoftProgressBar extends StatelessWidget {
  const _ReviewSoftProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProgressRail(
      value: value,
      fillColor: colorScheme.primary.withValues(alpha: 0.7),
    );
  }
}

class _ReviewNote extends StatelessWidget {
  const _ReviewNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      padding: const EdgeInsets.all(18),
      borderRadius: AppThemeTokens.radiusLg,
      child: Text(
        note,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
        ),
      ),
    );
  }
}
