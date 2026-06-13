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
    final stageHeight = math.min(420.0, math.max(340.0, screenHeight * 0.38));

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
          completedHabits: habitsStore.completedCount,
          totalHabits: habitsStore.totalCount,
          totalCheckInsToday: habitsStore.totalCheckInsToday,
          pendingHabits: pendingHabits,
          habitsStore: habitsStore,
          onHabitsAction: () {
            Navigator.of(context).pushNamed(AppRoute.habits);
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
            4,
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
              const SizedBox(height: 14),
              _ActionPlanTimeline(
                progress: stageProgress,
                previewActions: previewActions,
                pendingHabits: pendingHabits,
                todayFocusMinutes: todayFocusMinutes,
                focusStore: focusStore,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            22,
            AppThemeTokens.pagePadding,
            110,
          ),
          child: _TodayRhythmCanvas(
            nodes: <_TodayRhythmNodeData>[
              _TodayRhythmNodeData(
                marker: 'H',
                alignment: _NodeAlign.left,
                title: '习惯节奏',
                subtitle: habitsStore.totalCount == 0
                    ? '先建立一个可重复动作'
                    : '轻轻推进日常动作',
                action: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.habits),
                  child: const Text('进入习惯'),
                ),
                content: _todayHabitsContent(
                  context: context,
                  completedHabits: habitsStore.completedCount,
                  totalHabits: habitsStore.totalCount,
                  totalCheckInsToday: habitsStore.totalCheckInsToday,
                  pendingHabits: pendingHabits,
                  habitsStore: habitsStore,
                ),
              ),
              _TodayRhythmNodeData(
                marker: 'P',
                alignment: _NodeAlign.right,
                title: '目标规划',
                subtitle: '把目标拆成今天能走的一步。',
                action: TextButton.icon(
                  key: const ValueKey('today-goals-view-all'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.goals),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('查看全部'),
                ),
                content: _todayPlanContent(
                  context: context,
                  goalsStore: goalsStore,
                  previewGoals: previewGoals,
                  previewActions: previewActions,
                  todayPlanRecordCount: todayPlanRecords.length,
                  habitLinkedPlanRecordCount: habitLinkedPlanRecordCount,
                  completedActionCount: completedActionCount,
                  totalActionCount: totalActionCount,
                ),
              ),
              _TodayRhythmNodeData(
                marker: 'F',
                alignment: _NodeAlign.left,
                title: '专注概览',
                subtitle: focusStore.currentTarget == null
                    ? '选一轮时间，让注意力回到现场。'
                    : _focusTargetLabel(focusStore.currentTarget!),
                action: TextButton.icon(
                  key: const ValueKey('today-focus-view-all'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.focus),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('进入专注'),
                ),
                content: _todayFocusContent(
                  context: context,
                  focusStore: focusStore,
                  todaySessionCount: todayFocusSessions.length,
                  todayFocusMinutes: todayFocusMinutes,
                ),
              ),
              _TodayRhythmNodeData(
                marker: 'R',
                alignment: _NodeAlign.right,
                title: '今日复盘',
                subtitle: 'End of Day · 当前累积的真实记录。',
                action: TextButton.icon(
                  key: const ValueKey('today-review-entry'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.review),
                  icon: const Icon(Icons.insights_outlined, size: 18),
                  label: const Text('End of Day'),
                ),
                content: _todayReviewContent(
                  context: context,
                  totalCheckInsToday: habitsStore.totalCheckInsToday,
                  completedActions: completedActionCount,
                  todayPlanRecordCount: todayPlanRecords.length,
                  todayFocusSessionCount: todayFocusSessions.length,
                ),
              ),
            ],
          ),
        ),
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
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.pendingHabits,
    required this.habitsStore,
    required this.onHabitsAction,
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
  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final List<HabitItem> pendingHabits;
  final HabitsStore habitsStore;
  final VoidCallback onHabitsAction;
  final VoidCallback onReviewAction;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final readiness = (progress.clamp(0, 1) * 100).round();

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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final compact = constraints.maxWidth < 380 || textScale > 1.0;
                final scoreSize = compact ? 54.0 : 64.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 54),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF00E5FF),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '今日',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'STRIVE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'TODAY / COMMAND',
                                  maxLines: 1,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF00E5FF),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _StageLabel(
                                        text: 'FOCUS SCORE',
                                        compact: compact,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '今日中心',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: const Color(
                                                0xFF00E5FF,
                                              ).withValues(alpha: 0.72),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        '今天的节奏',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.88),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                              height: 1,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Peak Rhythm · $todayDateLabel',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  AppThemeTokens
                                                      .secondaryTextTone(
                                                        colorScheme,
                                                      ),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.9,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: '$readiness'),
                                      TextSpan(
                                        text: '%',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: const Color(0xFF00E5FF),
                                              fontWeight: FontWeight.w900,
                                              height: 1,
                                            ),
                                      ),
                                    ],
                                  ),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: const Color(0xFF00E5FF),
                                    fontSize: scoreSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                    height: 0.95,
                                    shadows: [
                                      Shadow(
                                        color: const Color(
                                          0xFF00E5FF,
                                        ).withValues(alpha: 0.40),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            _CognitiveLoadBar(progress: progress),
                            const SizedBox(height: 14),
                            _StageSignalRow(
                              habitSignal: habitSignal,
                              planSignal: planSignal,
                              focusSignal: focusSignal,
                              compact: compact,
                            ),
                            const SizedBox(height: 12),
                            _TodayHabitQuickEntry(
                              completedHabits: completedHabits,
                              totalHabits: totalHabits,
                              totalCheckInsToday: totalCheckInsToday,
                              pendingHabits: pendingHabits,
                              habitsStore: habitsStore,
                              onPressed: onHabitsAction,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 13 : 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00E5FF,
                                        ).withValues(alpha: 0.60),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    'PRIORITY EXECUTE / 当前优先',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF00E5FF),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.ads_click_rounded,
                                  color: const Color(0xFF00E5FF).withValues(
                                    alpha: 0.90,
                                  ),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 11),
                            Text(
                              '今天，先推进一件事',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1.03,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '先看最重要的事',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppThemeTokens.secondaryTextTone(
                                  colorScheme,
                                ),
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: const [
                                _MicroChip(
                                  label: '120m',
                                  color: Color(0xFF00E5FF),
                                ),
                                _MicroChip(
                                  label: 'Initiate',
                                  color: Color(0xFF80FF2C),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _PrimaryActionPill(
                                    label: primaryLabel,
                                    compact: compact,
                                    onPressed: onPrimaryAction,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _ReviewEntryButton(
                                  compact: compact,
                                  onPressed: onReviewAction,
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
        ],
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
                'OPTIMAL RANGE',
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
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
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
      ..color = Colors.white.withValues(alpha: 0.045);
    final labelPaint = TextPainter(textDirection: TextDirection.ltr);
    final chartRect = Rect.fromLTWH(0, 4, size.width, size.height - 22);

    for (var index = 0; index < 4; index += 1) {
      final y = chartRect.top + chartRect.height * index / 3;
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

    final normalized = progress.clamp(0.08, 0.96).toDouble();
    final points = <double>[
      (0.18 + normalized * 0.18).clamp(0.0, 1.0),
      (0.30 + sessionCount * 0.06).clamp(0.0, 0.86),
      (0.24 + normalized * 0.28).clamp(0.0, 1.0),
      (0.58 + normalized * 0.18).clamp(0.0, 1.0),
      (0.40 + focusMinutes / 180).clamp(0.0, 0.92),
      (0.78 + normalized * 0.15).clamp(0.0, 1.0),
      (0.50 + sessionCount * 0.04).clamp(0.0, 0.82),
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
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF00E5FF),
    );

    final marker = pointFor(5, points[5]);
    canvas.drawCircle(
      marker,
      4.2,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF00E5FF),
    );
    canvas.drawCircle(
      marker,
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.22),
    );

    final labels = ['06:00', '12:00', '18:00', '22:00'];
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
        Offset(x.clamp(0.0, size.width - labelPaint.width), size.height - 13),
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
  });

  final double progress;
  final List<GoalTaskItem> previewActions;
  final List<HabitItem> pendingHabits;
  final int todayFocusMinutes;
  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rows = _rows();

    return _TechnicalPanel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ACTION PLAN',
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
                '${(progress.clamp(0, 1) * 100).round()}% READY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF80FF2C),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < rows.length; index += 1)
            _ActionPlanRow(
              data: rows[index],
              isLast: index == rows.length - 1,
            ),
        ],
      ),
    );
  }

  List<_ActionPlanRowData> _rows() {
    final rows = <_ActionPlanRowData>[];
    const times = ['09:00', '11:30'];
    for (var index = 0; index < previewActions.length && index < 2; index += 1) {
      rows.add(
        _ActionPlanRowData(
          time: times[index],
          title: previewActions[index].title,
          description: 'High leverage task. Keep the next action visible.',
          tags: const ['Deep Work', 'Plan'],
          accent: const Color(0xFF00E5FF),
        ),
      );
    }

    if (pendingHabits.isNotEmpty) {
      final habit = pendingHabits.first;
      rows.add(
        _ActionPlanRowData(
          time: rows.isEmpty ? '09:00' : '14:00',
          title: '${habit.emoji} ${habit.name}',
          description: 'Daily protocol still open. Complete the next check-in.',
          tags: const ['Habit', 'Signal'],
          accent: const Color(0xFF80FF2C),
        ),
      );
    }

    rows.add(
      _ActionPlanRowData(
        time: rows.isEmpty ? '09:00' : '16:30',
        title: _focusCueLabel(focusStore, todayFocusMinutes),
        description: _focusStatusDescription(focusStore),
        tags: const ['Focus', 'Flow'],
        accent: const Color(0xFFDCC8FF),
      ),
    );

    return rows.take(3).toList(growable: false);
  }
}

class _ActionPlanRowData {
  const _ActionPlanRowData({
    required this.time,
    required this.title,
    required this.description,
    required this.tags,
    required this.accent,
  });

  final String time;
  final String title;
  final String description;
  final List<String> tags;
  final Color accent;
}

class _ActionPlanRow extends StatelessWidget {
  const _ActionPlanRow({
    required this.data,
    required this.isLast,
  });

  final _ActionPlanRowData data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(
              data.time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: data.accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: data.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.accent.withValues(alpha: 0.45),
                      blurRadius: 9,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 64,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  color: Colors.white.withValues(alpha: 0.10),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
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
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: data.accent.withValues(alpha: 0.88),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      for (final tag in data.tags)
                        _MicroChip(label: tag, color: data.accent),
                    ],
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
        color: const Color(0xFF111111).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          height: 1,
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PEAK RHYTHM',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF80FF2C),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Text(
              clampedProgress >= 0.72
                  ? '最佳'
                  : clampedProgress >= 0.36
                  ? '稳定'
                  : '预热',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Container(
                height: 3,
                color: colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              FractionallySizedBox(
                widthFactor: clampedProgress,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFFDCC8FF)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayHabitQuickEntry extends StatelessWidget {
  const _TodayHabitQuickEntry({
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.pendingHabits,
    required this.habitsStore,
    required this.onPressed,
  });

  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final List<HabitItem> pendingHabits;
  final HabitsStore habitsStore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('today-habits-view-all'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF101010).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '今日习惯',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '今日打卡 $totalCheckInsToday 次',
                          key: const ValueKey('today-habits-check-ins-total'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppThemeTokens.secondaryTextTone(
                              colorScheme,
                            ),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completedHabits',
                    key: const ValueKey('today-habits-completed'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ $totalHabits',
                    key: const ValueKey('today-habits-total'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.88),
                    size: 18,
                  ),
                ],
              ),
              if (pendingHabits.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '还可继续',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                for (final habit in pendingHabits)
                  _TodayHabitQuickLine(
                    habit: habit,
                    habitsStore: habitsStore,
                  ),
              ] else ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    totalHabits == 0 ? '还没有习惯' : '今天都已达标',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayHabitQuickLine extends StatelessWidget {
  const _TodayHabitQuickLine({
    required this.habit,
    required this.habitsStore,
  });

  final HabitItem habit;
  final HabitsStore habitsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${habit.emoji} ${habit.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '今日 ${habitsStore.todayCheckInCount(habit)} / ${habit.targetCountPerDay}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (habit.reminderTime != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '提醒 ${habit.reminderTime}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewEntryButton extends StatelessWidget {
  const _ReviewEntryButton({
    required this.compact,
    required this.onPressed,
  });

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('today-end-of-day-entry'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insights_outlined,
                color: Color(0xFF00E5FF),
                size: 18,
              ),
              const SizedBox(width: 7),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '复盘',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'End of Day',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      height: 1,
                    ),
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
        color: const Color(0xFF00E5FF),
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
            horizontal: compact ? 14 : 16,
            vertical: compact ? 9 : 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF001F24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF001F24),
                size: compact ? 17 : 18,
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
    required this.habitSignal,
    required this.planSignal,
    required this.focusSignal,
    required this.compact,
  });

  final String habitSignal;
  final String planSignal;
  final String focusSignal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StageSignal(
            label: '恢复',
            value: habitSignal,
            icon: Icons.directions_run_rounded,
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: _StageSignal(
            label: '压力',
            value: planSignal,
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: _StageSignal(
            label: 'FOCUS',
            value: focusSignal,
            icon: Icons.graphic_eq_rounded,
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
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = label == '恢复'
        ? const Color(0xFF00E5FF)
        : label == '压力'
        ? const Color(0xFF80FF2C)
        : const Color(0xFFDCC8FF);
    final indicatorValue = label == '恢复'
        ? 0.72
        : label == '压力'
        ? 0.58
        : 0.46;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: indicatorValue,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                Icon(
                  icon,
                  size: 13,
                  color: accent.withValues(alpha: 0.78),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: SizedBox(
                    width: 43,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              height: 1,
            ),
          ),
        ],
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
    return '${value.substring(5, 7)}.${value.substring(8, 10)}';
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
