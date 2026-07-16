import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
// Today rewrite reads Goals through GoalsScope; no direct GoalsStore import.
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/main_page_header.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final todayKey = habitsStore.currentDayKey;
    final activeHabits = habitsStore.habits
        .where((habit) => habit.isActive)
        .toList(growable: false);
    final pendingHabits = activeHabits
        .where((habit) => !habitsStore.isCompletedToday(habit))
        .toList(growable: false);
    final tasks = goalsStore.tasks;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final openTasks = tasks
        .where((task) => !task.isCompleted)
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
    final habitProgress = habitsStore.totalCount == 0
        ? 0.0
        : habitsStore.completedCount / habitsStore.totalCount;
    final planProgress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;
    final selectedFocusMinutes = math.max(
      1,
      focusStore.selectedDurationSeconds ~/ 60,
    );
    final focusProgress = math.min(
      todayFocusMinutes / selectedFocusMinutes,
      1.0,
    );
    final focusScore =
        ((habitProgress * 0.42 + planProgress * 0.34 + focusProgress * 0.24) *
                100)
            .round()
            .clamp(0, 100);
    final habitRecentCounts = _recentHabitTotals(habitsStore, activeHabits);
    final focusRecentCounts = focusStore
        .recentDayCounts(focusStore.now)
        .reversed
        .toList(growable: false);
    final fluxValues = List<int>.generate(7, (index) {
      final habitCount = index < habitRecentCounts.length
          ? habitRecentCounts[index]
          : 0;
      final focusCount = index < focusRecentCounts.length
          ? focusRecentCounts[index]
          : 0;
      return habitCount + focusCount;
    }, growable: false);
    final activeDays = habitRecentCounts.where((count) => count > 0).length;
    final priority = _TodayPriority.resolve(
      openTasks: openTasks,
      pendingHabits: pendingHabits,
      focusStore: focusStore,
    );
    final actionRows = _buildActionRows(
      openTasks: openTasks,
      pendingHabits: pendingHabits,
      habitsStore: habitsStore,
      focusStore: focusStore,
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        key: const ValueKey('today-page-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          StitchExactPremiumSpacing.pageTop,
          AppThemeTokens.pagePadding,
          StitchExactPremiumSpacing.pageBottom,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StitchExactMainPageHeader(
                    title: '今天',
                    leadingIcon: Icons.calendar_today_outlined,
                    actions: [
                      StitchExactMainHeaderAction(
                        key: const ValueKey('today-header-review'),
                        icon: Icons.insights_rounded,
                        tooltip: '复盘',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoute.review),
                        primary: true,
                      ),
                      StitchExactMainHeaderAction(
                        key: const ValueKey('today-header-settings'),
                        icon: Icons.person_outline_rounded,
                        tooltip: '我的/设置',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoute.settings),
                      ),
                    ],
                  ),
                  _FocusScoreStage(
                    score: focusScore,
                    dateLabel: _formatTodayDate(focusStore.now),
                  ),
                  const SizedBox(height: StitchExactPremiumSpacing.section),
                  _PeakRhythmCard(
                    message: _peakRhythmMessage(
                      score: focusScore,
                      checkIns: habitsStore.totalCheckInsToday,
                      completedTasks: completedTasks,
                      totalTasks: tasks.length,
                      focusMinutes: todayFocusMinutes,
                    ),
                  ),
                  const SizedBox(height: StitchExactPremiumSpacing.section),
                  _MomentumMetrics(
                    habitProgress: habitProgress,
                    completedHabits: habitsStore.completedCount,
                    totalHabits: habitsStore.totalCount,
                    totalCheckInsToday: habitsStore.totalCheckInsToday,
                    planProgress: planProgress,
                    completedTasks: completedTasks,
                    totalTasks: tasks.length,
                    streakProgress: activeDays / 7,
                    activeDays: activeDays,
                    focusMinutes: todayFocusMinutes,
                  ),
                  const SizedBox(height: StitchExactPremiumSpacing.section),
                  _PriorityExecuteCard(
                    priority: priority,
                    durationMinutes: selectedFocusMinutes,
                    onPressed: () async {
                      switch (priority.type) {
                        case _TodayPriorityType.plan:
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoute.goals);
                        case _TodayPriorityType.habit:
                          final habit = priority.habit;
                          if (habit == null) {
                            return;
                          }
                          await habitsStore.checkIn(habit.id);
                        case _TodayPriorityType.focus:
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoute.focus);
                      }
                    },
                  ),
                  const SizedBox(height: StitchExactPremiumSpacing.section),
                  _FocusFluxChart(values: fluxValues),
                  const SizedBox(height: StitchExactPremiumSpacing.section),
                  _ActionPlanSection(
                    rows: actionRows,
                    onPlanTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoute.goals),
                    onHabitsTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoute.habits),
                    onFocusTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoute.focus),
                    onHabitCheckIn: (habit) async {
                      await habitsStore.checkIn(habit.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusScoreStage extends StatelessWidget {
  const _FocusScoreStage({required this.score, required this.dateLabel});

  final int score;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CapsLabel(
          label: '今日评分',
          icon: Icons.bolt_rounded,
          color: _TodayColors.primary,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$score',
              style: const TextStyle(
                color: _TodayColors.onSurface,
                fontFamily: _TodayFonts.headline,
                fontSize: 78,
                fontWeight: FontWeight.w800,
                height: 0.86,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 3, bottom: 6),
              child: Text(
                '%',
                style: TextStyle(
                  color: _TodayColors.onSurfaceVariant,
                  fontFamily: _TodayFonts.headline,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          dateLabel,
          style: const TextStyle(
            color: _TodayColors.onSurfaceVariant,
            fontFamily: _TodayFonts.mono,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _PeakRhythmCard extends StatelessWidget {
  const _PeakRhythmCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: const BoxDecoration(
        color: _TodayColors.surfaceLow,
        border: Border(
          left: BorderSide(color: _TodayColors.tertiary, width: 2),
          top: BorderSide(color: _TodayColors.glassBorder),
          right: BorderSide(color: _TodayColors.glassBorder),
          bottom: BorderSide(color: _TodayColors.glassBorder),
        ),
        // Radius removed: rail border nonuniform color.
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _TodayColors.tertiary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xAA6CEC00),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SizedBox(width: 7, height: 7),
              ),
              SizedBox(width: 8),
              Text(
                '高效节奏',
                style: TextStyle(
                  color: _TodayColors.tertiary,
                  fontFamily: _TodayFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: _TodayColors.onSurface,
              fontFamily: _TodayFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumMetrics extends StatelessWidget {
  const _MomentumMetrics({
    required this.habitProgress,
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.planProgress,
    required this.completedTasks,
    required this.totalTasks,
    required this.streakProgress,
    required this.activeDays,
    required this.focusMinutes,
  });

  final double habitProgress;
  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final double planProgress;
  final int completedTasks;
  final int totalTasks;
  final double streakProgress;
  final int activeDays;
  final int focusMinutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('推进指标'),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _RingMetric(
                label: '完成度',
                detail: '今日习惯',
                progress: habitProgress,
                color: _TodayColors.cyan,
                centerText: totalHabits == 0
                    ? '0%'
                    : '${(habitProgress * 100).round()}%',
                footnote:
                    '$completedHabits/$totalHabits · $totalCheckInsToday 次',
              ),
            ),
            Expanded(
              child: _RingMetric(
                label: '推进率',
                detail: '计划推进',
                progress: planProgress,
                color: _TodayColors.tertiary,
                centerText: totalTasks == 0
                    ? '0/0'
                    : '$completedTasks/$totalTasks',
                footnote: '${(planProgress * 100).round()}% · ${focusMinutes}m',
              ),
            ),
            Expanded(
              child: _RingMetric(
                label: '连续性',
                detail: '连续',
                progress: streakProgress,
                color: _TodayColors.secondary,
                centerIcon: Icons.local_fire_department_rounded,
                footnote: '$activeDays/7 天',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriorityExecuteCard extends StatelessWidget {
  const _PriorityExecuteCard({
    required this.priority,
    required this.durationMinutes,
    required this.onPressed,
  });

  final _TodayPriority priority;
  final int durationMinutes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _TodayColors.surfaceHigh,
        border: Border.all(color: _TodayColors.glassBorder),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_rounded, color: _TodayColors.primary, size: 17),
              SizedBox(width: 8),
              Expanded(child: _CapsText('优先行动', _TodayColors.primary)),
              Text(
                '当前',
                style: TextStyle(
                  color: _TodayColors.onSurfaceVariant,
                  fontFamily: _TodayFonts.mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            priority.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _TodayColors.onSurface,
              fontFamily: _TodayFonts.headline,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            priority.subtitle,
            style: const TextStyle(
              color: _TodayColors.onSurfaceVariant,
              fontFamily: _TodayFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.46,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _DurationChip(minutes: durationMinutes),
              _InitiateButton(
                key: const ValueKey('today-priority-action'),
                label: priority.buttonLabel,
                onPressed: onPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusFluxChart extends StatelessWidget {
  const _FocusFluxChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _SectionTitle('节奏趋势')),
            _CapsText('近 7 天', _TodayColors.secondary),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 168,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _TodayColors.surfaceContainer,
            border: Border.all(color: _TodayColors.glassBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _FluxChartPainter(values: values)),
              ),
              const Positioned(
                left: 20,
                right: 20,
                bottom: 13,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AxisLabel('6 天前'),
                    _AxisLabel('4 天前'),
                    _AxisLabel('2 天前'),
                    _AxisLabel('今天'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPlanSection extends StatelessWidget {
  const _ActionPlanSection({
    required this.rows,
    required this.onPlanTap,
    required this.onHabitsTap,
    required this.onFocusTap,
    required this.onHabitCheckIn,
  });

  final List<_ActionRowData> rows;
  final VoidCallback onPlanTap;
  final VoidCallback onHabitsTap;
  final VoidCallback onFocusTap;
  final ValueChanged<HabitItem> onHabitCheckIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('行动计划'),
        const SizedBox(height: 16),
        for (var index = 0; index < rows.length; index += 1)
          _ActionTimelineRow(
            data: rows[index],
            active: index == 1 || (rows.length == 1 && index == 0),
            isLast: index == rows.length - 1,
            onPlanTap: onPlanTap,
            onHabitsTap: onHabitsTap,
            onFocusTap: onFocusTap,
            onHabitCheckIn: onHabitCheckIn,
          ),
      ],
    );
  }
}

class _ActionTimelineRow extends StatelessWidget {
  const _ActionTimelineRow({
    required this.data,
    required this.active,
    required this.isLast,
    required this.onPlanTap,
    required this.onHabitsTap,
    required this.onFocusTap,
    required this.onHabitCheckIn,
  });

  final _ActionRowData data;
  final bool active;
  final bool isLast;
  final VoidCallback onPlanTap;
  final VoidCallback onHabitsTap;
  final VoidCallback onFocusTap;
  final ValueChanged<HabitItem> onHabitCheckIn;

  @override
  Widget build(BuildContext context) {
    final onRowTap = switch (data.type) {
      _ActionRowType.plan => onPlanTap,
      _ActionRowType.habit => onHabitsTap,
      _ActionRowType.focus => onFocusTap,
    };

    return Material(
      color: active
          ? _TodayColors.surfaceLow.withValues(alpha: 0.5)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        key: ValueKey<String>('today-action-${data.type.name}'),
        borderRadius: BorderRadius.circular(4),
        onTap: onRowTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            active ? 14 : 0,
            16,
            active ? 14 : 0,
            16,
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: _TodayColors.rowDivider),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 58,
                child: Text(
                  data.status,
                  style: TextStyle(
                    color: active
                        ? _TodayColors.primary
                        : _TodayColors.onSurfaceVariant,
                    fontFamily: _TodayFonts.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _TodayColors.onSurface,
                        fontFamily: _TodayFonts.headline,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _TodayColors.onSurfaceVariant,
                        fontFamily: _TodayFonts.body,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.38,
                      ),
                    ),
                    if (data.meta != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _OutlineTag(data.meta!),
                          if (data.secondaryMeta != null)
                            _OutlineTag(data.secondaryMeta!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  _CadenceBars(activeBars: data.activeBars),
                  const SizedBox(height: 12),
                  _RoundActionButton(
                    icon: data.icon,
                    onTap: () {
                      final habit = data.habit;
                      if (habit != null) {
                        onHabitCheckIn(habit);
                        return;
                      }
                      onRowTap();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingMetric extends StatelessWidget {
  const _RingMetric({
    required this.label,
    required this.detail,
    required this.progress,
    required this.color,
    required this.footnote,
    this.centerText,
    this.centerIcon,
  }) : assert(centerText != null || centerIcon != null);

  final String label;
  final String detail;
  final double progress;
  final Color color;
  final String footnote;
  final String? centerText;
  final IconData? centerIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: StitchExactMotion.standard,
                curve: StitchExactMotion.standardCurve,
                builder: (context, animatedProgress, child) => CustomPaint(
                  size: const Size.square(70),
                  painter: _RingPainter(
                    progress: animatedProgress,
                    color: color,
                  ),
                ),
              ),
              if (centerIcon == null)
                AnimatedSwitcher(
                  duration: StitchExactMotion.fast,
                  switchInCurve: StitchExactMotion.fastCurve,
                  switchOutCurve: StitchExactMotion.fastCurve,
                  child: Text(
                    centerText!,
                    key: ValueKey<String>('$label-$centerText'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _TodayColors.onSurface,
                      fontFamily: _TodayFonts.mono,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                )
              else
                Icon(centerIcon, color: color, size: 23),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _TodayColors.onSurfaceVariant,
            fontFamily: _TodayFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0x99BAC9CC),
            fontFamily: _TodayFonts.body,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          footnote,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0x77BAC9CC),
            fontFamily: _TodayFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _InitiateButton extends StatelessWidget {
  const _InitiateButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: _TodayColors.cyan,
          foregroundColor: _TodayColors.onCyan,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontFamily: _TodayFonts.mono,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        label: Text(label),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _TodayColors.background,
        border: Border.all(color: _TodayColors.glassBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            color: _TodayColors.onSurfaceVariant,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '$minutes 分钟',
            style: const TextStyle(
              color: _TodayColors.onSurfaceVariant,
              fontFamily: _TodayFonts.mono,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CadenceBars extends StatelessWidget {
  const _CadenceBars({required this.activeBars});

  final int activeBars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 4; index += 1)
          Container(
            width: 5,
            height: 14,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: index < activeBars
                  ? _TodayColors.tertiary
                  : _TodayColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '执行',
      child: InkResponse(
        radius: 24,
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _TodayColors.surfaceContainer,
            border: Border.all(color: _TodayColors.glassBorder),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _TodayColors.onSurfaceVariant, size: 17),
        ),
      ),
    );
  }
}

class _CapsLabel extends StatelessWidget {
  const _CapsLabel({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
        ],
        _CapsText(label, color),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _TodayColors.onSurfaceVariant,
        fontFamily: _TodayFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        height: 1.2,
      ),
    );
  }
}

class _CapsText extends StatelessWidget {
  const _CapsText(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontFamily: _TodayFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        height: 1.2,
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0x88BAC9CC),
        fontFamily: _TodayFonts.mono,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OutlineTag extends StatelessWidget {
  const _OutlineTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: _TodayColors.glassBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _TodayColors.primary,
          fontFamily: _TodayFonts.mono,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
          height: 1,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(strokeWidth / 2);
    final backgroundPaint = Paint()
      ..color = _TodayColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 1;

    canvas.drawArc(
      insetRect,
      -math.pi / 2,
      math.pi * 2,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      insetRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _FluxChartPainter extends CustomPainter {
  const _FluxChartPainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x10FFFFFF)
      ..strokeWidth = 1;

    for (var index = 1; index < 5; index += 1) {
      final x = size.width * index / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var index = 1; index < 4; index += 1) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final chartValues = values.isEmpty ? const <int>[0, 0] : values;
    final maxValue = math.max(1, chartValues.reduce(math.max));
    final usableHeight = size.height - 52;
    final topPadding = 18.0;
    final points = <Offset>[];
    for (var index = 0; index < chartValues.length; index += 1) {
      final x = chartValues.length == 1
          ? size.width / 2
          : size.width * index / (chartValues.length - 1);
      final normalized = chartValues[index] / maxValue;
      final y = topPadding + usableHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final glowPaint = Paint()
      ..color = _TodayColors.cyan.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final linePaint = Paint()
      ..color = _TodayColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, glowPaint);
    canvas.drawPath(linePath, linePaint);

    if (points.isNotEmpty) {
      final peak = points.reduce(
        (best, point) => point.dy < best.dy ? point : best,
      );
      canvas.drawCircle(peak, 6, Paint()..color = _TodayColors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant _FluxChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _TodayPriority {
  const _TodayPriority({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.habit,
  });

  final _TodayPriorityType type;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final HabitItem? habit;

  static _TodayPriority resolve({
    required List<GoalTaskItem> openTasks,
    required List<HabitItem> pendingHabits,
    required FocusStore focusStore,
  }) {
    if (openTasks.isNotEmpty) {
      return _TodayPriority(
        type: _TodayPriorityType.plan,
        title: openTasks.first.title,
        subtitle: '适合现在推进，完成后再进入专注。',
        buttonLabel: '开始执行',
      );
    }

    if (pendingHabits.isNotEmpty) {
      final habit = pendingHabits.first;
      return _TodayPriority(
        type: _TodayPriorityType.habit,
        title: '${habit.emoji} ${habit.name}',
        subtitle: '今日习惯尚未达标，先记录一次，再把节奏带回主线。',
        buttonLabel: '记录打卡',
        habit: habit,
      );
    }

    return _TodayPriority(
      type: _TodayPriorityType.focus,
      title: focusStore.currentTarget?.title ?? '进入专注',
      subtitle: _focusStatusDescription(focusStore),
      buttonLabel: '开始执行',
    );
  }
}

class _ActionRowData {
  const _ActionRowData({
    required this.type,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activeBars,
    this.meta,
    this.secondaryMeta,
    this.habit,
  });

  final _ActionRowType type;
  final String status;
  final String title;
  final String subtitle;
  final IconData icon;
  final int activeBars;
  final String? meta;
  final String? secondaryMeta;
  final HabitItem? habit;
}

enum _TodayPriorityType { plan, habit, focus }

enum _ActionRowType { plan, habit, focus }

List<_ActionRowData> _buildActionRows({
  required List<GoalTaskItem> openTasks,
  required List<HabitItem> pendingHabits,
  required HabitsStore habitsStore,
  required FocusStore focusStore,
}) {
  final rows = <_ActionRowData>[];

  for (final task in openTasks.take(3)) {
    final index = rows.length;
    rows.add(
      _ActionRowData(
        type: _ActionRowType.plan,
        status: '计划',
        title: task.title,
        subtitle: task.dueDate == null
            ? '计划行动 · 未完成'
            : '计划行动 · ${task.dueDate}',
        icon: Icons.play_arrow_rounded,
        activeBars: index == 0 ? 3 : 2,
        meta: '行动',
        secondaryMeta: focusStore.selectedDurationSeconds <= 0
            ? null
            : '${focusStore.selectedDurationSeconds ~/ 60}m',
      ),
    );
  }

  for (final habit in pendingHabits) {
    if (rows.length >= 3) {
      break;
    }
    rows.add(
      _ActionRowData(
        type: _ActionRowType.habit,
        status: '习惯',
        title: '${habit.emoji} ${habit.name}',
        subtitle:
            '今日 ${habitsStore.todayCheckInCount(habit)} / ${habit.targetCountPerDay}',
        icon: Icons.add_task_rounded,
        activeBars: math.max(
          1,
          math.min(3, habitsStore.todayCheckInCount(habit) + 1),
        ),
        meta: '习惯',
        secondaryMeta: habit.reminderTime,
        habit: habit,
      ),
    );
  }

  if (rows.isEmpty) {
    rows.add(
      _ActionRowData(
        type: _ActionRowType.focus,
        status: '专注',
        title: focusStore.currentTarget?.title ?? '进入专注',
        subtitle: _focusStatusDescription(focusStore),
        icon: Icons.timer_outlined,
        activeBars: focusStore.isRunning ? 3 : 1,
        meta: _focusStatusLabel(focusStore.status),
        secondaryMeta: focusStore.formattedRemaining,
      ),
    );
  }

  return rows;
}

List<int> _recentHabitTotals(HabitsStore habitsStore, List<HabitItem> habits) {
  final totals = List<int>.filled(7, 0);
  for (final habit in habits) {
    final days = habitsStore.recentActivityDays(habit);
    for (var index = 0; index < days.length && index < totals.length; index++) {
      totals[index] += days[index].count;
    }
  }
  return totals;
}

String _peakRhythmMessage({
  required int score,
  required int checkIns,
  required int completedTasks,
  required int totalTasks,
  required int focusMinutes,
}) {
  final actionText = totalTasks == 0
      ? '暂无计划行动'
      : '$completedTasks/$totalTasks 个行动';
  if (score >= 70) {
    return '今日节奏已建立：$checkIns 次打卡、$actionText、$focusMinutes 分钟专注。适合处理高难度逻辑任务。';
  }

  if (checkIns > 0 || completedTasks > 0 || focusMinutes > 0) {
    return '今日节奏正在建立：$checkIns 次打卡、$actionText、$focusMinutes 分钟专注。继续推进一个明确行动。';
  }

  return '尚未形成今日节奏。先完成一次打卡、一个行动，或进入一轮专注。';
}

String _formatTodayDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}年${local.month}月${local.day}日';
}

String _localDateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
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
  if (focusStore.isRunning) {
    final target = focusStore.currentTarget;
    return target == null ? '专注正在进行，保持当下节奏。' : '正在推进「${target.title}」，保持当下节奏。';
  }

  if (focusStore.isPaused) {
    return '这一轮已暂停，可继续，也可重置。';
  }

  if (focusStore.remainingSeconds == 0) {
    return '这一轮已完成，可去专注页开始下一轮。';
  }

  return '准备好后，开始一段安静推进。';
}

abstract final class _TodayColors {
  static const background = Color(0xFF131313);
  static const surfaceContainer = Color(0xFF201F1F);
  static const surfaceLow = Color(0xFF1C1B1B);
  static const surfaceHigh = Color(0xFF2A2A2A);
  static const surfaceVariant = Color(0xFF353534);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFBAC9CC);
  static const primary = Color(0xFFC3F5FF);
  static const cyan = Color(0xFF00E5FF);
  static const onCyan = Color(0xFF00363D);
  static const secondary = Color(0xFFDCB8FF);
  static const tertiary = Color(0xFF6CEC00);
  static const glassBorder = Color(0x14FFFFFF);
  static const rowDivider = Color(0x0FFFFFFF);
}

abstract final class _TodayFonts {
  static const headline = 'Hanken Grotesk';
  static const body = 'Inter';
  static const mono = 'JetBrains Mono';
}
