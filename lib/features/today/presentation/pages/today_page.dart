import 'dart:math' as math;

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
    final stageHeight = math.min(460.0, math.max(350.0, screenHeight * 0.44));

    return ListView(
      padding: EdgeInsets.zero,
      cacheExtent: 1600,
      children: [
        _TodayStage(
          height: stageHeight,
          progress: stageProgress,
          primaryLabel: previewActions.isNotEmpty ? '继续下一项' : '开始今天',
          habitSignal:
              '${habitsStore.completedCount}/${habitsStore.totalCount}',
          planSignal: '$completedActionCount/$totalActionCount',
          focusSignal: '$todayFocusMinutes 分钟',
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
            18,
            AppThemeTokens.pagePadding,
            0,
          ),
          child: _TodayActionRail(
            completedHabits: habitsStore.completedCount,
            totalHabits: habitsStore.totalCount,
            totalCheckInsToday: habitsStore.totalCheckInsToday,
            pendingHabits: pendingHabits,
            habitsStore: habitsStore,
            planCueLabel: _planCueLabel(goalsStore, previewActions),
            focusCueLabel: _focusCueLabel(focusStore, todayFocusMinutes),
            todayFocusMinutes: todayFocusMinutes,
            onViewHabits: () {
              Navigator.of(context).pushNamed(AppRoute.habits);
            },
            onViewPlan: () {
              Navigator.of(context).pushNamed(AppRoute.goals);
            },
            onViewFocus: () {
              Navigator.of(context).pushNamed(AppRoute.focus);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            22,
            AppThemeTokens.pagePadding,
            0,
          ),
          child: _TodayPlanSection(
            goalsStore: goalsStore,
            previewGoals: goalsStore.goals.take(2).toList(growable: false),
            previewActions: previewActions,
            todayPlanRecordCount: todayPlanRecords.length,
            habitLinkedPlanRecordCount: habitLinkedPlanRecordCount,
            completedActionCount: completedActionCount,
            totalActionCount: totalActionCount,
            onViewAll: () {
              Navigator.of(context).pushNamed(AppRoute.goals);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            18,
            AppThemeTokens.pagePadding,
            0,
          ),
          child: _TodayFocusSection(
            focusStore: focusStore,
            todaySessionCount: todayFocusSessions.length,
            todayFocusMinutes: todayFocusMinutes,
            onViewAll: () {
              Navigator.of(context).pushNamed(AppRoute.focus);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            18,
            AppThemeTokens.pagePadding,
            110,
          ),
          child: _TodayReviewStrip(
            totalCheckInsToday: habitsStore.totalCheckInsToday,
            completedActions: completedActionCount,
            todayPlanRecordCount: todayPlanRecords.length,
            todayFocusSessionCount: todayFocusSessions.length,
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
    required this.primaryLabel,
    required this.habitSignal,
    required this.planSignal,
    required this.focusSignal,
    required this.onPrimaryAction,
  });

  final double height;
  final double progress;
  final String primaryLabel;
  final String habitSignal;
  final String planSignal;
  final String focusSignal;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _TodayBackdropPainter(
                colorScheme: colorScheme,
                progress: progress,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.10),
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.78),
                    colorScheme.surfaceContainerLowest,
                  ],
                  stops: const [0.0, 0.70, 1.0],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final compact = constraints.maxHeight < 420 || textScale > 1.0;
              final horizontalPadding = compact ? 22.0 : 26.0;
              final topPadding = compact ? 22.0 : 34.0;
              final bottomPadding = compact ? 20.0 : 30.0;
              final titleSize = compact ? 30.0 : 36.0;
              final sectionGap = compact ? 10.0 : 18.0;
              final actionGap = compact ? 16.0 : 24.0;
              final signalGap = compact ? 16.0 : 24.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 52),
                      child: Row(
                        children: [
                          _StageLabel(text: '今日', compact: compact),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '今日中心',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.82,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '今天的节奏',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppThemeTokens.secondaryTextTone(
                                      colorScheme,
                                    ).withValues(alpha: 0.74),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (compact)
                      SizedBox(height: sectionGap)
                    else
                      const Spacer(),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Text(
                        '今天，先推进一件事',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: titleSize,
                          height: compact ? 1.05 : 1.08,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    Text(
                      '先看最重要的事',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(
                          colorScheme,
                        ).withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                        height: 1.36,
                      ),
                    ),
                    SizedBox(height: actionGap),
                    _PrimaryActionPill(
                      label: primaryLabel,
                      compact: compact,
                      onPressed: onPrimaryAction,
                    ),
                    SizedBox(height: signalGap),
                    _StageSignalRow(
                      habitSignal: habitSignal,
                      planSignal: planSignal,
                      focusSignal: focusSignal,
                      compact: compact,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
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
    final colorScheme = theme.colorScheme;

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
            color: colorScheme.primary.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: colorScheme.onPrimary,
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
    return Wrap(
      spacing: compact ? 16 : 22,
      runSpacing: compact ? 6 : 8,
      children: [
        _StageSignal(label: '习惯完成', value: habitSignal),
        _StageSignal(label: '计划行动', value: planSignal),
        _StageSignal(label: '专注分钟', value: focusSignal),
      ],
    );
  }
}

class _StageSignal extends StatelessWidget {
  const _StageSignal({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '  $label',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TodayActionRail extends StatelessWidget {
  const _TodayActionRail({
    required this.completedHabits,
    required this.totalHabits,
    required this.totalCheckInsToday,
    required this.pendingHabits,
    required this.habitsStore,
    required this.planCueLabel,
    required this.focusCueLabel,
    required this.todayFocusMinutes,
    required this.onViewHabits,
    required this.onViewPlan,
    required this.onViewFocus,
  });

  final int completedHabits;
  final int totalHabits;
  final int totalCheckInsToday;
  final List<HabitItem> pendingHabits;
  final HabitsStore habitsStore;
  final String planCueLabel;
  final String focusCueLabel;
  final int todayFocusMinutes;
  final VoidCallback onViewHabits;
  final VoidCallback onViewPlan;
  final VoidCallback onViewFocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RailHeader(title: '今日行动', subtitle: '三条线，轻轻推进。'),
        const SizedBox(height: 12),
        _TodayActionTile(
          title: '今日习惯',
          subtitle: totalHabits == 0 ? '先建立一个可重复动作' : '轻轻推进日常动作',
          marker: 'H',
          onTap: onViewHabits,
          trailing: TextButton(
            key: const ValueKey('today-habits-view-all'),
            onPressed: onViewHabits,
            child: const Text('进入习惯'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$completedHabits',
                    key: const ValueKey('today-habits-completed'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '/ $totalHabits',
                    key: const ValueKey('today-habits-total'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '今日打卡 $totalCheckInsToday 次',
                    key: const ValueKey('today-habits-check-ins-total'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (pendingHabits.isEmpty)
                Text(
                  totalHabits == 0 ? '还没有习惯' : '今天都已达标',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                )
              else ...[
                Text(
                  '还可继续',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                for (final habit in pendingHabits)
                  _HabitMiniRow(habit: habit, habitsStore: habitsStore),
              ],
            ],
          ),
        ),
        _TodayActionTile(
          title: '计划推进',
          subtitle: planCueLabel,
          marker: 'P',
          onTap: onViewPlan,
          trailing: IconButton(
            onPressed: onViewPlan,
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: '进入计划',
          ),
          child: Text(
            '下一步行动已在下方整理。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _TodayActionTile(
          title: '专注准备',
          subtitle: focusCueLabel,
          marker: 'F',
          onTap: onViewFocus,
          trailing: IconButton(
            onPressed: onViewFocus,
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: '开始专注',
          ),
          child: Text(
            todayFocusMinutes == 0
                ? '今天还没有完成专注，准备一轮安静推进。'
                : '今日已专注 $todayFocusMinutes 分钟。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _RailHeader extends StatelessWidget {
  const _RailHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayActionTile extends StatelessWidget {
  const _TodayActionTile({
    required this.title,
    required this.subtitle,
    required this.marker,
    required this.onTap,
    required this.trailing,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String marker;
  final VoidCallback onTap;
  final Widget trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: Color.lerp(
                colorScheme.surface,
                colorScheme.surfaceContainerLowest,
                0.20,
              )!.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          marker,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppThemeTokens.secondaryTextTone(
                                colorScheme,
                              ),
                              fontWeight: FontWeight.w500,
                              height: 1.32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        ),
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

class _TodayPlanSection extends StatelessWidget {
  const _TodayPlanSection({
    required this.goalsStore,
    required this.previewGoals,
    required this.previewActions,
    required this.todayPlanRecordCount,
    required this.habitLinkedPlanRecordCount,
    required this.completedActionCount,
    required this.totalActionCount,
    required this.onViewAll,
  });

  final GoalsStore goalsStore;
  final List<GoalItem> previewGoals;
  final List<GoalTaskItem> previewActions;
  final int todayPlanRecordCount;
  final int habitLinkedPlanRecordCount;
  final int completedActionCount;
  final int totalActionCount;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      title: '目标规划',
      subtitle: '把目标拆成今天能走的一步。',
      action: TextButton.icon(
        key: const ValueKey('today-goals-view-all'),
        onPressed: onViewAll,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('查看全部'),
      ),
      child: Column(
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
            const _EmptyLine(
              title: '还没有计划',
              description: '去计划页创建长期目标后，这里会显示规划摘要。',
            )
          else
            for (final goal in previewGoals)
              _GoalPreviewRow(goal: goal, goalsStore: goalsStore),
          if (previewActions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '今日可推进',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (final action in previewActions)
              _AgendaRow(title: action.title, meta: '未完成行动'),
          ],
        ],
      ),
    );
  }
}

class _TodayFocusSection extends StatelessWidget {
  const _TodayFocusSection({
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
    final target = focusStore.currentTarget;

    return _SectionFrame(
      title: '专注概览',
      subtitle: target == null ? '选一轮时间，让注意力回到现场。' : _focusTargetLabel(target),
      action: TextButton.icon(
        key: const ValueKey('today-focus-view-all'),
        onPressed: onViewAll,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('进入专注'),
      ),
      child: Column(
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
      ),
    );
  }
}

class _TodayReviewStrip extends StatelessWidget {
  const _TodayReviewStrip({
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.10)),
        ),
      ),
      child: _SoftMetaLine(
        labels: [
          '打卡 $totalCheckInsToday 次',
          '计划记录 $todayPlanRecordCount 条',
          '完成行动 $completedActions 个',
          '专注 $todayFocusSessionCount 轮',
        ],
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
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
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              action,
            ],
          ),
          const SizedBox(height: 14),
          child,
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
