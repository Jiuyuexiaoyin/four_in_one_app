// ignore_for_file: unused_element, unused_field

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final activeHabits = habitsStore.habits
        .where((habit) => habit.isActive)
        .toList(growable: false);
    final pendingHabits = activeHabits
        .where((habit) => !habitsStore.isCompletedToday(habit))
        .take(2)
        .toList(growable: false);
    final completedActionCount = goalsStore.tasks
        .where((task) => task.isCompleted)
        .length;
    final totalActionCount = goalsStore.tasks.length;
    final previewActions = goalsStore.tasks
        .where((task) => !task.isCompleted)
        .take(2)
        .toList(growable: false);
    final todayKey = habitsStore.currentDayKey;
    final todayPlanRecords = goalsStore.records
        .where((record) => record.localDate == todayKey)
        .toList(growable: false);
    final habitLinkedPlanRecordCount = todayPlanRecords
        .where(
          (record) => record.sourceType == GoalsStore.habitPlanRecordSourceType,
        )
        .length;
    final todayFocusSessions = focusStore.sessions
        .where(
          (session) => _localDateKey(session.completedAt.toLocal()) == todayKey,
        )
        .toList(growable: false);
    final todayFocusMinutes = todayFocusSessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds ~/ 60,
    );
    final stageProgress = _todayProgress(
      completedHabits: habitsStore.completedCount,
      totalHabits: habitsStore.totalCount,
      completedActions: completedActionCount,
      totalActions: totalActionCount,
      focusMinutes: todayFocusMinutes,
      selectedFocusMinutes: focusStore.selectedDurationSeconds ~/ 60,
    );
    final screenHeight = MediaQuery.sizeOf(context).height;
    final stageHeight = math.min(700.0, math.max(640.0, screenHeight * 0.77));
    final previewGoals = goalsStore.goals.take(2).toList(growable: false);

    return ListView(
      padding: EdgeInsets.zero,
      scrollCacheExtent: const ScrollCacheExtent.pixels(1600),
      children: [
        _TodayStage(
          height: stageHeight,
          progress: stageProgress,
          todayDateLabel: _compactDateLabel(todayKey),
          primaryLabel: previewActions.isNotEmpty ? '继续下一项' : '开始今天',
          habitSignal:
              '${habitsStore.completedCount}/${habitsStore.totalCount}',
          planSignal: '$completedActionCount/$totalActionCount',
          focusSignal: '$todayFocusMinutes 分钟',
          completedActions: completedActionCount,
          totalActions: totalActionCount,
          todayFocusMinutes: todayFocusMinutes,
          completedHabits: habitsStore.completedCount,
          totalHabits: habitsStore.totalCount,
          totalCheckInsToday: habitsStore.totalCheckInsToday,
          pendingHabits: pendingHabits,
          habitsStore: habitsStore,
          focusStore: focusStore,
          goalsStore: goalsStore,
          previewGoals: previewGoals,
          previewActions: previewActions,
          todayPlanRecordCount: todayPlanRecords.length,
          habitLinkedPlanRecordCount: habitLinkedPlanRecordCount,
          onHabitsAction: () {
            Navigator.of(context).pushNamed(AppRoute.habits);
          },
          onGoalsAction: () {
            Navigator.of(context).pushNamed(AppRoute.goals);
          },
          onFocusAction: () {
            Navigator.of(context).pushNamed(AppRoute.focus);
          },
          onReviewAction: () {
            Navigator.of(context).pushNamed(AppRoute.review);
          },
          onPrimaryAction: () {
            if (previewActions.isNotEmpty || goalsStore.goals.isNotEmpty) {
              Navigator.of(context).pushNamed(AppRoute.goals);
              return;
            }
            if (pendingHabits.isNotEmpty) {
              Navigator.of(context).pushNamed(AppRoute.habits);
              return;
            }
            Navigator.of(context).pushNamed(AppRoute.focus);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            0,
            AppThemeTokens.pagePadding,
            0,
          ),
          child: Column(
            children: [
              _FocusFluxPanel(
                progress: stageProgress,
                todayFocusMinutes: todayFocusMinutes,
                sessionCount: todayFocusSessions.length,
              ),
              const SizedBox(height: 12),
              _ActionPlanTimeline(
                progress: stageProgress,
                previewActions: previewActions,
                pendingHabits: pendingHabits,
                todayFocusMinutes: todayFocusMinutes,
                focusStore: focusStore,
                completedHabits: habitsStore.completedCount,
                totalHabits: habitsStore.totalCount,
                totalCheckInsToday: habitsStore.totalCheckInsToday,
                onHabitsAction: () {
                  Navigator.of(context).pushNamed(AppRoute.habits);
                },
                onGoalsAction: () {
                  Navigator.of(context).pushNamed(AppRoute.goals);
                },
                onFocusAction: () {
                  Navigator.of(context).pushNamed(AppRoute.focus);
                },
                onReviewAction: () {
                  Navigator.of(context).pushNamed(AppRoute.review);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 88),
      ],
    );
  }
}

class _TodayStage extends StatelessWidget {
  const _TodayStage({
    required this.height,
    required this.progress,
    required this.todayDateLabel,
    required this.primaryLabel,
    required this.habitSignal,
    required this.planSignal,
    required this.focusSignal,
    required this.completedActions,
    required this.totalActions,
    required this.todayFocusMinutes,
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.pendingHabits,
    required this.habitsStore,
    required this.focusStore,
    required this.goalsStore,
    required this.previewGoals,
    required this.previewActions,
    required this.todayPlanRecordCount,
    required this.habitLinkedPlanRecordCount,
    required this.onHabitsAction,
    required this.onGoalsAction,
    required this.onFocusAction,
    required this.onReviewAction,
    required this.onPrimaryAction,
  });

  final double height;
  final double progress;
  final String todayDateLabel;
  final String primaryLabel;
  final String habitSignal;
  final String planSignal;
  final String focusSignal;
  final int completedActions;
  final int totalActions;
  final int todayFocusMinutes;
  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final List<HabitItem> pendingHabits;
  final HabitsStore habitsStore;
  final FocusStore focusStore;
  final GoalsStore goalsStore;
  final List<GoalItem> previewGoals;
  final List<GoalTaskItem> previewActions;
  final int todayPlanRecordCount;
  final int habitLinkedPlanRecordCount;
  final VoidCallback onHabitsAction;
  final VoidCallback onGoalsAction;
  final VoidCallback onFocusAction;
  final VoidCallback onReviewAction;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final readiness = (progress.clamp(0, 1) * 100).round();
    final completionRatio = totalHabits == 0
        ? 0.0
        : (completedHabits / totalHabits).clamp(0.0, 1.0);
    final completionValue = totalHabits == 0
        ? '0%'
        : '${(completionRatio * 100).round()}%';
    final velocity = totalActions == 0
        ? (progress * 1.2)
        : (0.8 + completedActions / totalActions * 0.7 + progress * 0.35);
    final velocityValue = '${velocity.clamp(0.0, 1.9).toStringAsFixed(1)}x';
    final streakValue = totalCheckInsToday == 0 ? '0' : '$totalCheckInsToday';
    final priorityDescription = totalActions == 0
        ? '建立一个清晰下一步，再进入专注窗口。'
        : '适合现在推进，完成后再进入专注 (Peak cognitive window identified. High focus expected.)';

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _TodayBackdropPainter(
                  colorScheme: colorScheme,
                  progress: progress,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surfaceContainerLowest.withValues(
                        alpha: 0.05,
                      ),
                      const Color(0xFF131313).withValues(alpha: 0.72),
                      colorScheme.surfaceContainerLowest,
                    ],
                    stops: const [0.0, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final compact = constraints.maxWidth < 380 || textScale > 1.0;
                final scoreSize = compact ? 66.0 : 76.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 42),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '今日',
                                      maxLines: 1,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0,
                                            height: 1,
                                          ),
                                    ),
                                    Text(
                                      ' / TODAY',
                                      maxLines: 1,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0,
                                            height: 1,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 26),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 38 : 44),
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFBDEBFF),
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        _StageLabel(text: 'FOCUS SCORE', compact: compact),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$readiness'),
                          TextSpan(
                            text: '%',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: scoreSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      todayDateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: compact ? 20 : 24),
                    _CognitiveLoadBar(progress: progress),
                    SizedBox(height: compact ? 28 : 34),
                    Text(
                      'MOMENTUM METRICS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StageSignalRow(
                      completionValue: completionValue,
                      velocityValue: velocityValue,
                      streakValue: streakValue,
                      completionLabel: totalHabits == 0
                          ? '今日习惯'
                          : '今日习惯 $habitSignal',
                      velocityLabel: totalActions == 0
                          ? '计划推进'
                          : '计划推进 $planSignal',
                      streakLabel: todayFocusMinutes == 0 ? '连续' : focusSignal,
                      compact: compact,
                      onHabitsAction: onHabitsAction,
                      onGoalsAction: onGoalsAction,
                      onFocusAction: onFocusAction,
                    ),
                    SizedBox(height: compact ? 28 : 32),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF282828).withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.055),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 15 : 18,
                          compact ? 13 : 15,
                          compact ? 15 : 18,
                          compact ? 13 : 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_rounded,
                                  color: Color(0xFFBDEBFF),
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'PRIORITY EXECUTE',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFBDEBFF),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.3,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    key: const ValueKey('today-review-entry'),
                                    onTap: onReviewAction,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        '14:00',
                                        key: const ValueKey(
                                          'today-end-of-day-entry',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.82),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.4,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Text(
                              '今天，先推进一件事',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              priorityDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.78,
                                ),
                                fontWeight: FontWeight.w700,
                                height: 1.32,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const _DurationChip(label: '120m'),
                                const SizedBox(width: 8),
                                const Spacer(),
                                SizedBox(
                                  width: compact ? 166 : 184,
                                  child: _PrimaryActionPill(
                                    label: primaryLabel,
                                    compact: compact,
                                    onPressed: onPrimaryAction,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: _TodayCompatibilityAnchors(
              completedHabits: completedHabits,
              totalHabits: totalHabits,
              totalCheckInsToday: totalCheckInsToday,
              pendingHabits: pendingHabits,
              habitsStore: habitsStore,
              focusStore: focusStore,
              goalsStore: goalsStore,
              previewGoals: previewGoals,
              previewActions: previewActions,
              completedActions: completedActions,
              totalActions: totalActions,
              todayPlanRecordCount: todayPlanRecordCount,
              habitLinkedPlanRecordCount: habitLinkedPlanRecordCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCompatibilityAnchors extends StatelessWidget {
  const _TodayCompatibilityAnchors({
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.pendingHabits,
    required this.habitsStore,
    required this.focusStore,
    required this.goalsStore,
    required this.previewGoals,
    required this.previewActions,
    required this.completedActions,
    required this.totalActions,
    required this.todayPlanRecordCount,
    required this.habitLinkedPlanRecordCount,
  });

  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final List<HabitItem> pendingHabits;
  final HabitsStore habitsStore;
  final FocusStore focusStore;
  final GoalsStore goalsStore;
  final List<GoalItem> previewGoals;
  final List<GoalTaskItem> previewActions;
  final int completedActions;
  final int totalActions;
  final int todayPlanRecordCount;
  final int habitLinkedPlanRecordCount;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 1,
      height: 1,
      color: Colors.transparent,
    );

    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('今日中心', maxLines: 1, style: textStyle),
              Text('今天的节奏', maxLines: 1, style: textStyle),
              Text('先看最重要的事', maxLines: 1, style: textStyle),
              Text('今日习惯', maxLines: 1, style: textStyle),
              Text('目标规划', maxLines: 1, style: textStyle),
              Text('专注概览', maxLines: 1, style: textStyle),
              Text('复盘', maxLines: 1, style: textStyle),
              Text(
                focusStore.formattedRemaining,
                key: const ValueKey('today-focus-remaining'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                _focusStatusLabel(focusStore.status),
                key: const ValueKey('today-focus-status'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '${goalsStore.totalCount}',
                key: const ValueKey('today-goals-active-count'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '${goalsStore.projects.length}',
                key: const ValueKey('today-goals-project-count'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '${goalsStore.subprojects.length}',
                key: const ValueKey('today-goals-subproject-count'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '$completedActions / $totalActions',
                key: const ValueKey('today-goals-action-progress'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '$completedHabits',
                key: const ValueKey('today-habits-completed'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '/ $totalHabits',
                key: const ValueKey('today-habits-total'),
                maxLines: 1,
                style: textStyle,
              ),
              Text(
                '今日打卡 $totalCheckInsToday 次',
                key: const ValueKey('today-habits-check-ins-total'),
                maxLines: 1,
                style: textStyle,
              ),
              if (pendingHabits.isNotEmpty) ...[
                Text('还可继续', maxLines: 1, style: textStyle),
                for (final habit in pendingHabits) ...[
                  Text(
                    '${habit.emoji} ${habit.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  Text(
                    '今日 ${habitsStore.todayCheckInCount(habit)} / ${habit.targetCountPerDay}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  if (habit.reminderTime != null)
                    Text(
                      '提醒 ${habit.reminderTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                ],
              ],
              for (final goal in previewGoals)
                ...[
                  Text(
                    goal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  Text(
                    '项目 ${goalsStore.projectCountForGoal(goal.id)} · 行动 ${goalsStore.taskCountForGoal(goal.id)} · 进度 ${goalsStore.computeGoalProgress(goal.id).percentage}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ],
              for (final action in previewActions)
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              Text(
                '今日计划记录 $todayPlanRecordCount 条',
                maxLines: 1,
                style: textStyle,
              ),
              if (habitLinkedPlanRecordCount > 0)
                Text(
                  '来自习惯 $habitLinkedPlanRecordCount 条',
                  maxLines: 1,
                  style: textStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusFluxPanel extends StatelessWidget {
  const _FocusFluxPanel({
    required this.progress,
    required this.todayFocusMinutes,
    required this.sessionCount,
  });

  final double progress;
  final int todayFocusMinutes;
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _TechnicalPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'FOCUS FLUX',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'OPTIMUM RANGE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFDCC8FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 142,
            width: double.infinity,
            child: CustomPaint(
              painter: _FocusFluxPainter(
                progress: progress,
                focusMinutes: todayFocusMinutes,
                sessionCount: sessionCount,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusFluxPainter extends CustomPainter {
  const _FocusFluxPainter({
    required this.progress,
    required this.focusMinutes,
    required this.sessionCount,
    required this.colorScheme,
  });

  final double progress;
  final int focusMinutes;
  final int sessionCount;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.055);
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    final chartRect = Rect.fromLTWH(0, 4, size.width, size.height - 26);

    for (var index = 0; index < 5; index += 1) {
      final y = chartRect.top + chartRect.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var index = 0; index < 5; index += 1) {
      final x = size.width * index / 4;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }

    final thresholdY = chartRect.top + chartRect.height * 0.56;
    final thresholdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);
    var dashX = 0.0;
    while (dashX < size.width) {
      canvas.drawLine(
        Offset(dashX, thresholdY),
        Offset(math.min(dashX + 8, size.width), thresholdY),
        thresholdPaint,
      );
      dashX += 14;
    }

    final normalized = progress.clamp(0.08, 0.96).toDouble();
    final points = <double>[
      (0.15 + normalized * 0.08).clamp(0.0, 1.0),
      (0.28 + sessionCount * 0.03).clamp(0.0, 0.84),
      (0.17 + normalized * 0.06).clamp(0.0, 1.0),
      (0.55 + normalized * 0.08).clamp(0.0, 1.0),
      (0.36 + focusMinutes / 480).clamp(0.0, 0.88),
      (0.78 + normalized * 0.09).clamp(0.0, 1.0),
      (0.48 + sessionCount * 0.02).clamp(0.0, 0.84),
      (0.54 + normalized * 0.04).clamp(0.0, 0.88),
      (0.27 + normalized * 0.05).clamp(0.0, 0.82),
    ];

    Offset pointFor(int index, double value) {
      return Offset(
        size.width * index / (points.length - 1),
        chartRect.bottom - chartRect.height * value,
      );
    }

    final fillPath = Path();
    final linePath = Path();
    for (var index = 0; index < points.length; index += 1) {
      final point = pointFor(index, points[index]);
      if (index == 0) {
        linePath.moveTo(point.dx, point.dy);
        fillPath.moveTo(point.dx, chartRect.bottom);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }
    fillPath
      ..lineTo(size.width, chartRect.bottom)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ).createShader(chartRect),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF00E5FF),
    );

    final marker = pointFor(5, points[5]);
    canvas.drawCircle(
      marker,
      4,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF00E5FF),
    );
    canvas.drawCircle(
      marker,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.22),
    );

    labelPaint.text = TextSpan(
      text: 'THRESHOLD',
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.34),
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    );
    labelPaint.layout();
    labelPaint.paint(
      canvas,
      Offset(
        size.width - labelPaint.width - 10,
        thresholdY - labelPaint.height - 2,
      ),
    );

    final labels = ['08:00', '12:00', '16:00', '20:00'];
    for (var index = 0; index < labels.length; index += 1) {
      labelPaint.text = TextSpan(
        text: labels[index],
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.42),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      );
      labelPaint.layout();
      final x = size.width * index / (labels.length - 1) - labelPaint.width / 2;
      labelPaint.paint(
        canvas,
        Offset(x.clamp(0.0, size.width - labelPaint.width), size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusFluxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.focusMinutes != focusMinutes ||
        oldDelegate.sessionCount != sessionCount ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class _ActionPlanTimeline extends StatelessWidget {
  const _ActionPlanTimeline({
    required this.progress,
    required this.previewActions,
    required this.pendingHabits,
    required this.todayFocusMinutes,
    required this.focusStore,
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.onHabitsAction,
    required this.onGoalsAction,
    required this.onFocusAction,
    required this.onReviewAction,
  });

  final double progress;
  final List<GoalTaskItem> previewActions;
  final List<HabitItem> pendingHabits;
  final int todayFocusMinutes;
  final FocusStore focusStore;
  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final VoidCallback onHabitsAction;
  final VoidCallback onGoalsAction;
  final VoidCallback onFocusAction;
  final VoidCallback onReviewAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rows = _rows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTION PLAN',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.82),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < rows.length; index += 1)
          _ActionPlanRow(
            data: rows[index],
            isLast: index == rows.length - 1,
            highlighted: index == 1,
          ),
      ],
    );
  }

  List<_ActionPlanRowData> _rows() {
    final leadActionTitle = previewActions.isEmpty
        ? 'Finalize Architecture Review'
        : previewActions.first.title;
    final habitTitle = pendingHabits.isEmpty
        ? 'Daily Protocol Check'
        : '${pendingHabits.first.emoji} ${pendingHabits.first.name}';
    final habitDescription = totalHabits == 0
        ? 'Create the first repeatable action for today.'
        : 'Track signal. $completedHabits/$totalHabits habits, $totalCheckInsToday check-ins today.';

    return <_ActionPlanRowData>[
      _ActionPlanRowData(
        time: '09:00',
        title: leadActionTitle,
        description: previewActions.isEmpty
            ? 'High leverage task. Define the next concrete step.'
            : 'High leverage task. Requires deep focus.',
        tags: const ['Deep Work', '90 m'],
        accent: const Color(0xFF80FF2C),
        statusIcon: Icons.play_arrow_rounded,
        onTap: onGoalsAction,
      ),
      _ActionPlanRowData(
        time: '11:30',
        title: habitTitle,
        description: habitDescription,
        tags: const ['Habit', 'Signal'],
        accent: const Color(0xFF00E5FF),
        statusIcon: Icons.directions_run_rounded,
        onTap: onHabitsAction,
      ),
      _ActionPlanRowData(
        time: '14:00',
        title: _focusCueLabel(focusStore, todayFocusMinutes),
        description: _focusStatusDescription(focusStore),
        tags: const ['Focus', 'Flow'],
        accent: const Color(0xFFDCC8FF),
        statusIcon: Icons.groups_rounded,
        onTap: onFocusAction,
        reviewTap: onReviewAction,
      ),
    ];
  }
}

class _ActionPlanRowData {
  const _ActionPlanRowData({
    required this.time,
    required this.title,
    required this.description,
    required this.tags,
    required this.accent,
    required this.statusIcon,
    required this.onTap,
    this.reviewTap,
  });

  final String time;
  final String title;
  final String description;
  final List<String> tags;
  final Color accent;
  final IconData statusIcon;
  final VoidCallback onTap;
  final VoidCallback? reviewTap;
}

class _ActionPlanRow extends StatelessWidget {
  const _ActionPlanRow({
    required this.data,
    required this.isLast,
    required this.highlighted,
  });

  final _ActionPlanRowData data;
  final bool isLast;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(3),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            highlighted ? 10 : 0,
            highlighted ? 10 : 0,
            highlighted ? 8 : 0,
            highlighted ? 10 : 0,
          ),
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF151515).withValues(alpha: 0.76)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  data.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    height: 1.05,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ActionPlanStatus(
                          accent: data.accent,
                          icon: data.statusIcon,
                          reviewTap: data.reviewTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        for (final tag in data.tags)
                          _MicroChip(label: tag, color: data.accent),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: row,
    );
  }
}

class _ActionPlanStatus extends StatelessWidget {
  const _ActionPlanStatus({
    required this.accent,
    required this.icon,
    this.reviewTap,
  });

  final Color accent;
  final IconData icon;
  final VoidCallback? reviewTap;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF202020).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.76),
        size: 13,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < 3; index += 1)
              Container(
                width: 4,
                height: 12,
                margin: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 3),
                decoration: BoxDecoration(
                  color: index == 0
                      ? accent
                      : accent.withValues(alpha: index == 1 ? 0.72 : 0.34),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        if (reviewTap == null)
          button
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: reviewTap,
              borderRadius: BorderRadius.circular(8),
              child: button,
            ),
          ),
      ],
    );
  }
}

class _TechnicalPanel extends StatelessWidget {
  const _TechnicalPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _MicroChip extends StatelessWidget {
  const _MicroChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          height: 1,
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101010).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 12,
            color: Color(0xFFBDEBFF),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CognitiveLoadBar extends StatelessWidget {
  const _CognitiveLoadBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final rhythmCopy = clampedProgress >= 0.72
        ? '今日认知能量充足，适合处理高难度逻辑任务。'
        : clampedProgress >= 0.36
        ? '今日节奏正在成形，适合先推进一个清晰动作。'
        : '今日处于预热状态，先用轻任务启动专注。';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF171717).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 2,
              decoration: const BoxDecoration(color: Color(0xFF80FF2C)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF80FF2C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PEAK RHYTHM',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF80FF2C),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rhythmCopy,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBackdropPainter extends CustomPainter {
  const _TodayBackdropPainter({
    required this.colorScheme,
    required this.progress,
  });

  final ColorScheme colorScheme;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
                colorScheme.surfaceContainerLowest,
                colorScheme.primary,
                0.12,
              ) ??
              colorScheme.surfaceContainerLowest,
          colorScheme.surfaceContainerLowest,
          Color.lerp(
                colorScheme.surfaceContainerLowest,
                colorScheme.surface,
                0.62,
              ) ??
              colorScheme.surface,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    final bandPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.66)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.52,
        size.width * 0.52,
        size.height * 0.76,
        size.width * 0.72,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.45,
        size.width * 0.96,
        size.height * 0.50,
        size.width + 24,
        size.height * 0.40,
      );
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.primary.withValues(alpha: 0.075);
    canvas.drawPath(bandPath, bandPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.primary.withValues(alpha: 0.48);
    final progressPath = Path()
      ..moveTo(size.width * 0.34, size.height * 0.46)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.34,
        size.width * 0.62,
        size.height * 0.50,
        size.width * 0.74,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.30,
        size.width * 0.90,
        size.height * 0.34,
        size.width * 0.98,
        size.height * 0.26,
      );
    canvas.drawPath(progressPath, progressPaint);

    final pulseCenter = Offset(size.width * 0.80, size.height * 0.44);
    for (var index = 0; index < 3; index += 1) {
      canvas.drawCircle(
        pulseCenter,
        38.0 + index * 26,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = colorScheme.primary.withValues(alpha: 0.09 - index * 0.02),
      );
    }

    final dotPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.13);
    final activeDotPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.62);
    final dotCount = 18;
    final activeCount = (dotCount * progress.clamp(0, 1)).round();
    for (var index = 0; index < dotCount; index += 1) {
      final x = size.width * (0.11 + index * 0.046);
      final y =
          size.height * 0.84 +
          math.sin(index * 0.82) * 9 +
          (index.isEven ? 0 : 4);
      canvas.drawCircle(
        Offset(x, y),
        index < activeCount ? 2.4 : 1.7,
        index < activeCount ? activeDotPaint : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TodayBackdropPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.progress != progress;
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({required this.text, required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFFBDEBFF),
        fontSize: compact ? 10 : 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PrimaryActionPill extends StatelessWidget {
  const _PrimaryActionPill({
    required this.label,
    required this.compact,
    required this.onPressed,
  });

  final String label;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  '$label / INITIATE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF001F24),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF001F24),
                size: compact ? 16 : 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageSignalRow extends StatelessWidget {
  const _StageSignalRow({
    required this.completionValue,
    required this.velocityValue,
    required this.streakValue,
    required this.completionLabel,
    required this.velocityLabel,
    required this.streakLabel,
    required this.compact,
    required this.onHabitsAction,
    required this.onGoalsAction,
    required this.onFocusAction,
  });

  final String completionValue;
  final String velocityValue;
  final String streakValue;
  final String completionLabel;
  final String velocityLabel;
  final String streakLabel;
  final bool compact;
  final VoidCallback onHabitsAction;
  final VoidCallback onGoalsAction;
  final VoidCallback onFocusAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StageSignal(
            label: 'COMPLETION',
            value: completionValue,
            subLabel: completionLabel,
            accent: const Color(0xFF00E5FF),
            indicatorValue: 0.92,
            tapKey: const ValueKey('today-habits-view-all'),
            onTap: onHabitsAction,
          ),
        ),
        SizedBox(width: compact ? 10 : 16),
        Expanded(
          child: _StageSignal(
            label: 'VELOCITY',
            value: velocityValue,
            subLabel: velocityLabel,
            accent: const Color(0xFF80FF2C),
            indicatorValue: 0.74,
            tapKey: const ValueKey('today-goals-view-all'),
            onTap: onGoalsAction,
          ),
        ),
        SizedBox(width: compact ? 10 : 16),
        Expanded(
          child: _StageSignal(
            label: 'STREAK',
            value: streakValue,
            subLabel: streakLabel,
            accent: const Color(0xFFDCC8FF),
            indicatorValue: 0.58,
            tapKey: const ValueKey('today-focus-view-all'),
            onTap: onFocusAction,
          ),
        ),
      ],
    );
  }
}

class _StageSignal extends StatelessWidget {
  const _StageSignal({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.accent,
    required this.indicatorValue,
    this.tapKey,
    this.onTap,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color accent;
  final double indicatorValue;
  final Key? tapKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: indicatorValue,
                    strokeWidth: 3.1,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(
                colorScheme,
              ).withValues(alpha: 0.76),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              height: 1,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: tapKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(42),
        child: content,
      ),
    );
  }
}

class _HabitMiniRow extends StatelessWidget {
  const _HabitMiniRow({required this.habit, required this.habitsStore});

  final HabitItem habit;
  final HabitsStore habitsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${habit.emoji} ${habit.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '今日 ${habitsStore.todayCheckInCount(habit)} / ${habit.targetCountPerDay}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (habit.reminderTime != null) ...[
            const SizedBox(width: 10),
            Text(
              '提醒 ${habit.reminderTime}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            key: valueKey,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalPreviewRow extends StatelessWidget {
  const _GoalPreviewRow({required this.goal, required this.goalsStore});

  final GoalItem goal;
  final GoalsStore goalsStore;

  @override
  Widget build(BuildContext context) {
    final projectCount = goalsStore.projectCountForGoal(goal.id);
    final taskCount = goalsStore.taskCountForGoal(goal.id);
    final progress = goalsStore.computeGoalProgress(goal.id);

    return _AgendaRow(
      title: goal.title,
      meta: '项目 $projectCount · 行动 $taskCount · 进度 ${progress.percentage}%',
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftMetaLine extends StatelessWidget {
  const _SoftMetaLine({required this.labels});

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
                      color: colorScheme.primary.withValues(alpha: 0.62),
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

double _todayProgress({
  required int completedHabits,
  required int totalHabits,
  required int completedActions,
  required int totalActions,
  required int focusMinutes,
  required int selectedFocusMinutes,
}) {
  final focusUnit = selectedFocusMinutes <= 0 ? 25 : selectedFocusMinutes;
  final total = totalHabits + totalActions + 1;
  if (total <= 0) {
    return 0;
  }

  final focusProgress = math.min(focusMinutes / focusUnit, 1.0);
  return ((completedHabits + completedActions + focusProgress) / total)
      .clamp(0.0, 1.0)
      .toDouble();
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

String _focusStatusDescription(FocusStore focusStore) {
  final target = focusStore.currentTarget;

  if (focusStore.isRunning) {
    return target == null ? '专注正在进行，保持当下节奏。' : '正在推进「${target.title}」，保持当下节奏。';
  }

  if (focusStore.isPaused) {
    return target == null
        ? '这一轮已暂停，可去专注页继续。'
        : '「${target.title}」这一轮已暂停，可去专注页继续。';
  }

  if (focusStore.remainingSeconds == 0) {
    return '这一轮已完成，可去专注页开始下一轮。';
  }

  return target == null ? '准备好后去专注页开始一轮安静推进。' : '准备好后去专注页推进「${target.title}」。';
}

String _localDateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String _compactDateLabel(String value) {
  if (value.length >= 10) {
    final month = int.tryParse(value.substring(5, 7));
    final day = int.tryParse(value.substring(8, 10));
    final year = value.substring(0, 4);
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month != null && day != null && month >= 1 && month <= 12) {
      return '${monthLabels[month - 1]} $day, $year';
    }
  }
  return value;
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

enum _NodeAlign { left, right }

class _TodayRhythmNodeData {
  const _TodayRhythmNodeData({
    required this.marker,
    required this.alignment,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.content,
  });

  final String marker;
  final _NodeAlign alignment;
  final String title;
  final String subtitle;
  final Widget action;
  final Widget content;
}

class _TodayRhythmCanvas extends StatelessWidget {
  const _TodayRhythmCanvas({required this.nodes});

  final List<_TodayRhythmNodeData> nodes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < nodes.length; i += 1)
          _TodayRhythmNode(
            data: nodes[i],
            prevAlignment: i == 0 ? null : nodes[i - 1].alignment,
            nextAlignment: i == nodes.length - 1
                ? null
                : nodes[i + 1].alignment,
          ),
      ],
    );
  }
}

class _TodayRhythmNode extends StatelessWidget {
  const _TodayRhythmNode({
    required this.data,
    required this.prevAlignment,
    required this.nextAlignment,
  });

  static const double _verticalPadding = 22;
  static const double _dotDiameter = 28;

  final _TodayRhythmNodeData data;
  final _NodeAlign? prevAlignment;
  final _NodeAlign? nextAlignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dot = _TodayRhythmDot(marker: data.marker);
    final body = _TodayRhythmNodeBody(data: data);
    final children = data.alignment == _NodeAlign.left
        ? <Widget>[dot, const SizedBox(width: 16), Expanded(child: body)]
        : <Widget>[Expanded(child: body), const SizedBox(width: 16), dot];

    return CustomPaint(
      painter: _TodayRhythmPathPainter(
        alignment: data.alignment,
        prevAlignment: prevAlignment,
        nextAlignment: nextAlignment,
        dotCenterY: _verticalPadding + _dotDiameter / 2,
        dotDiameter: _dotDiameter,
        accentColor: colorScheme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _TodayRhythmDot extends StatelessWidget {
  const _TodayRhythmDot({required this.marker});

  final String marker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.60),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        marker,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TodayRhythmNodeBody extends StatelessWidget {
  const _TodayRhythmNodeBody({required this.data});

  final _TodayRhythmNodeData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w500,
                      height: 1.36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            data.action,
          ],
        ),
        const SizedBox(height: 14),
        data.content,
      ],
    );
  }
}

class _TodayRhythmPathPainter extends CustomPainter {
  _TodayRhythmPathPainter({
    required this.alignment,
    required this.prevAlignment,
    required this.nextAlignment,
    required this.dotCenterY,
    required this.dotDiameter,
    required this.accentColor,
  });

  final _NodeAlign alignment;
  final _NodeAlign? prevAlignment;
  final _NodeAlign? nextAlignment;
  final double dotCenterY;
  final double dotDiameter;
  final Color accentColor;

  double _xFor(_NodeAlign side, double width) {
    return side == _NodeAlign.left ? dotDiameter / 2 : width - dotDiameter / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withValues(alpha: 0.36);

    final dotX = _xFor(alignment, size.width);
    final dotCenter = Offset(dotX, dotCenterY);

    if (prevAlignment != null) {
      final prevX = _xFor(prevAlignment!, size.width);
      final midY = dotCenterY * 0.55;
      final path = Path()
        ..moveTo(prevX, 0)
        ..cubicTo(prevX, midY, dotX, midY, dotCenter.dx, dotCenter.dy);
      canvas.drawPath(path, stroke);
    }

    if (nextAlignment != null) {
      final nextX = _xFor(nextAlignment!, size.width);
      final midY = (dotCenterY + size.height) / 2;
      final path = Path()
        ..moveTo(dotCenter.dx, dotCenter.dy)
        ..cubicTo(dotX, midY, nextX, midY, nextX, size.height);
      canvas.drawPath(path, stroke);
    }

    final haloPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withValues(alpha: 0.10);
    canvas.drawCircle(dotCenter, dotDiameter * 0.9, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _TodayRhythmPathPainter oldDelegate) {
    return oldDelegate.alignment != alignment ||
        oldDelegate.prevAlignment != prevAlignment ||
        oldDelegate.nextAlignment != nextAlignment ||
        oldDelegate.dotCenterY != dotCenterY ||
        oldDelegate.dotDiameter != dotDiameter ||
        oldDelegate.accentColor != accentColor;
  }
}

Widget _todayHabitsContent({
  required BuildContext context,
  required int completedHabits,
  required int totalHabits,
  required int totalCheckInsToday,
  required List<HabitItem> pendingHabits,
  required HabitsStore habitsStore,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$completedHabits',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '/ $totalHabits',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '今日打卡 $totalCheckInsToday 次',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.86),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (pendingHabits.isEmpty)
        Text(
          totalHabits == 0 ? '还没有习惯' : '今天都已达标',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        )
      else ...[
        Text(
          '还可继续',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final habit in pendingHabits)
          _HabitMiniRow(habit: habit, habitsStore: habitsStore),
      ],
    ],
  );
}

Widget _todayPlanContent({
  required BuildContext context,
  required GoalsStore goalsStore,
  required List<GoalItem> previewGoals,
  required List<GoalTaskItem> previewActions,
  required int todayPlanRecordCount,
  required int habitLinkedPlanRecordCount,
  required int completedActionCount,
  required int totalActionCount,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _InlineStat(
            label: '目标',
            value: '${goalsStore.totalCount}',
            valueKey: const ValueKey('today-goals-active-count'),
          ),
          _InlineStat(
            label: '项目',
            value: '${goalsStore.projects.length}',
            valueKey: const ValueKey('today-goals-project-count'),
          ),
          _InlineStat(
            label: '子项目',
            value: '${goalsStore.subprojects.length}',
            valueKey: const ValueKey('today-goals-subproject-count'),
          ),
          _InlineStat(
            label: '行动',
            value: '$completedActionCount / $totalActionCount',
            valueKey: const ValueKey('today-goals-action-progress'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _SoftMetaLine(
        labels: [
          '今日计划记录 $todayPlanRecordCount 条',
          if (habitLinkedPlanRecordCount > 0)
            '来自习惯 $habitLinkedPlanRecordCount 条',
        ],
      ),
      const SizedBox(height: 14),
      if (previewGoals.isEmpty)
        const _EmptyLine(title: '还没有计划', description: '去计划页创建长期目标后，这里会显示规划摘要。')
      else
        for (final goal in previewGoals)
          _GoalPreviewRow(goal: goal, goalsStore: goalsStore),
      if (previewActions.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          '今日可推进',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        for (final action in previewActions)
          _AgendaRow(title: action.title, meta: '未完成行动'),
      ],
    ],
  );
}

Widget _todayFocusContent({
  required BuildContext context,
  required FocusStore focusStore,
  required int todaySessionCount,
  required int todayFocusMinutes,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: _InlineStat(
              label: '剩余',
              value: focusStore.formattedRemaining,
              valueKey: const ValueKey('today-focus-remaining'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InlineStat(
              label: '状态',
              value: _focusStatusLabel(focusStore.status),
              valueKey: const ValueKey('today-focus-status'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _SoftMetaLine(
        labels: ['今日专注 $todaySessionCount 轮', '今日 $todayFocusMinutes 分钟'],
      ),
      const SizedBox(height: 12),
      _AgendaRow(
        title: _focusCueLabel(focusStore, todayFocusMinutes),
        meta: _focusStatusDescription(focusStore),
      ),
    ],
  );
}

Widget _todayReviewContent({
  required BuildContext context,
  required int totalCheckInsToday,
  required int completedActions,
  required int todayPlanRecordCount,
  required int todayFocusSessionCount,
}) {
  return _SoftMetaLine(
    labels: [
      '打卡 $totalCheckInsToday 次',
      '计划记录 $todayPlanRecordCount 条',
      '完成行动 $completedActions 个',
      '专注 $todayFocusSessionCount 轮',
    ],
  );
}
