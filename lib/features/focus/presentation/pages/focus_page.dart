import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final focusStore = FocusStoreScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final targets = _buildSelectableTargets(goalsStore);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentWidth = constraints.maxWidth > 620
            ? 560.0
            : constraints.maxWidth;

        return SingleChildScrollView(
          key: const ValueKey('focus-page-scroll'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _OptimizeHeader(),
                  const SizedBox(height: 14),
                  _FlowStatusPanel(focusStore: focusStore),
                  const SizedBox(height: 14),
                  _FocusScorePanel(focusStore: focusStore),
                  const SizedBox(height: 14),
                  _WeeklyDistributionPanel(focusStore: focusStore),
                  const SizedBox(height: 14),
                  _FocusHeatmapPanel(focusStore: focusStore),
                  const SizedBox(height: 64),
                  _FocusTargetSection(
                    focusStore: focusStore,
                    targets: targets,
                  ),
                  const SizedBox(height: 14),
                  _FocusDurationSelector(focusStore: focusStore),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

List<FocusTargetSnapshot> _buildSelectableTargets(GoalsStore goalsStore) {
  return goalsStore.tasks
      .where((task) => !task.isCompleted)
      .map((task) => _targetSnapshotForTask(goalsStore, task))
      .toList(growable: false);
}

FocusTargetSnapshot _targetSnapshotForTask(
  GoalsStore goalsStore,
  GoalTaskItem task,
) {
  final project = _findProject(goalsStore, task.projectId);
  final goal = project == null ? null : _findGoal(goalsStore, project.goalId);
  final subproject = task.subprojectId == null
      ? null
      : _findSubproject(goalsStore, task.subprojectId!);
  final contextParts = <String>[
    if (goal != null) goal.title,
    if (project != null) project.title,
    if (subproject != null) subproject.title,
  ];

  return FocusTargetSnapshot(
    taskId: task.id,
    title: task.title,
    context: contextParts.isEmpty ? '计划行动' : contextParts.join(' / '),
  );
}

GoalItem? _findGoal(GoalsStore goalsStore, String goalId) {
  for (final goal in goalsStore.goals) {
    if (goal.id == goalId) {
      return goal;
    }
  }

  return null;
}

ProjectItem? _findProject(GoalsStore goalsStore, String projectId) {
  for (final project in goalsStore.projects) {
    if (project.id == projectId) {
      return project;
    }
  }

  return null;
}

SubprojectItem? _findSubproject(GoalsStore goalsStore, String subprojectId) {
  for (final subproject in goalsStore.subprojects) {
    if (subproject.id == subprojectId) {
      return subproject;
    }
  }

  return null;
}

class _OptimizeHeader extends StatelessWidget {
  const _OptimizeHeader();

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasShellBackButton = Navigator.of(context).canPop();

    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: hasShellBackButton ? 35 : 0),
              child: Opacity(
                opacity: hasShellBackButton ? 0.58 : 1,
                child: Container(
                  width: hasShellBackButton ? 18 : 24,
                  height: hasShellBackButton ? 18 : 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101414).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: cyan.withValues(alpha: 0.28)),
                  ),
                  child: Icon(
                    Icons.terminal_rounded,
                    size: hasShellBackButton ? 10 : 13,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'OPTIMIZE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStatusPanel extends StatelessWidget {
  const _FlowStatusPanel({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final total = focusStore.activeDurationSeconds;
    final remaining = focusStore.remainingSeconds;
    final elapsed = total - remaining;
    final progress = total <= 0 ? 0.0 : _unit(elapsed / total);
    final progressPercent = (progress * 100).round();
    final elapsedMinutes = elapsed <= 0 ? 0 : (elapsed / 60).ceil();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _FocusTechSurface(
      minHeight: 232,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      gradientColors: [
        colorScheme.primary.withValues(alpha: 0.09),
        colorScheme.surface.withValues(alpha: 0.68),
        colorScheme.primaryContainer.withValues(alpha: 0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _KickerLabel(
                  primary: '实时心流状态',
                  secondary: 'FLOW STATUS',
                ),
              ),
              Icon(
                Icons.hub_outlined,
                size: 17,
                color: colorScheme.primary.withValues(alpha: 0.86),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FlowMicroGrid(active: !focusStore.isIdle, value: progress),
          const SizedBox(height: 12),
          Center(
            child: Text(
              focusStore.formattedRemaining,
              key: const ValueKey('focus-remaining-time'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                height: 0.90,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _statusLabel(focusStore.status),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _FocusProgressLine(value: progress)),
              const SizedBox(width: 12),
              Text(
                '$progressPercent%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _FocusSegmentScale(
            value: progress,
            color: const Color(0xFF00E5FF),
            leftLabel: 'IDLE',
            rightLabel: 'FLOW',
          ),
          const SizedBox(height: 14),
          Text(
            _statusDescription(focusStore),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT RUN',
                      style: _monoLabel(context).copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$elapsedMinutes'),
                          TextSpan(
                            text: ' MIN',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.74,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '本轮时长 ${focusStore.activeDurationSeconds ~/ 60} 分钟',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _FocusControls(focusStore: focusStore),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final mainLabel = focusStore.isRunning
        ? '暂停'
        : focusStore.isPaused
        ? '继续'
        : '开始';
    final mainAction = focusStore.isRunning ? focusStore.pause : focusStore.start;
    final mainEnabled = focusStore.isRunning ? focusStore.canPause : focusStore.canStart;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          height: 42,
          child: FilledButton(
            onPressed: mainEnabled ? mainAction : null,
            style: FilledButton.styleFrom(
              backgroundColor: focusStore.isIdle
                  ? cyan.withValues(alpha: 0.86)
                  : cyan,
              foregroundColor: Colors.black,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            child: Text(mainLabel),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          height: 42,
          child: OutlinedButton(
            onPressed: focusStore.canReset ? focusStore.reset : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: cyan.withValues(alpha: 0.62),
              side: BorderSide(color: cyan.withValues(alpha: 0.16)),
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            child: const Text('重置'),
          ),
        ),
      ],
    );
  }
}

class _FlowMicroGrid extends StatelessWidget {
  const _FlowMicroGrid({required this.active, required this.value});

  final bool active;
  final double value;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final activeCells = (value.clamp(0.0, 1.0) * 30).round();

    return SizedBox(
      height: 22,
      child: Column(
        children: [
          for (var row = 0; row < 3; row += 1) ...[
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < 10; column += 1) ...[
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: active && row * 10 + column < activeCells
                              ? cyan.withValues(alpha: 0.36)
                              : Colors.white.withValues(alpha: 0.045),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    if (column != 9) const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
            if (row != 2) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _FocusSegmentScale extends StatelessWidget {
  const _FocusSegmentScale({
    required this.value,
    required this.color,
    required this.leftLabel,
    required this.rightLabel,
    this.segments = 16,
  });

  final double value;
  final Color color;
  final String leftLabel;
  final String rightLabel;
  final int segments;

  @override
  Widget build(BuildContext context) {
    final activeSegments = (value.clamp(0.0, 1.0) * segments).round();

    return Column(
      children: [
        Row(
          children: [
            Text(
              leftLabel,
              style: _monoLabel(
                context,
              ).copyWith(color: Colors.white.withValues(alpha: 0.30)),
            ),
            const Spacer(),
            Text(
              rightLabel,
              style: _monoLabel(
                context,
              ).copyWith(color: color.withValues(alpha: 0.58)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (var i = 0; i < segments; i += 1) ...[
              Expanded(
                child: Container(
                  height: i % 4 == 0 ? 5 : 3,
                  decoration: BoxDecoration(
                    color: i < activeSegments
                        ? color.withValues(alpha: 0.72)
                        : Colors.white.withValues(alpha: 0.095),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              if (i != segments - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ],
    );
  }
}

class _WeeklyAxisGrid extends StatelessWidget {
  const _WeeklyAxisGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i += 1) ...[
          Row(
            children: [
              Container(
                width: i == 0 ? 18 : 10,
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.035),
                ),
              ),
            ],
          ),
          if (i != 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FocusScorePanel extends StatelessWidget {
  const _FocusScorePanel({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final now = focusStore.now;
    final weekCount = focusStore.weeklySessionCount(now);
    final weekMinutes = focusStore.weeklyFocusMinutes(now);
    final score = _focusScore(focusStore, weekCount, weekMinutes);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const green = Color(0xFF5CFF18);

    return _FocusTechSurface(
      minHeight: 124,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      gradientColors: [
        green.withValues(alpha: 0.08),
        colorScheme.surface.withValues(alpha: 0.70),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('FOCUS SCORE', style: _monoLabel(context)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: green,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 0.92,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/ 100',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FocusProgressLine(value: score / 100, color: green),
          const SizedBox(height: 6),
          _FocusSegmentScale(
            value: score / 100,
            color: green,
            leftLabel: 'BASE',
            rightLabel: 'PEAK',
            segments: 14,
          ),
          const SizedBox(height: 12),
          Text(
            weekCount == 0
                ? 'Waiting for completed rounds.'
                : '$weekCount rounds, $weekMinutes focused minutes this week.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.86),
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyDistributionPanel extends StatelessWidget {
  const _WeeklyDistributionPanel({required this.focusStore});

  final FocusStore focusStore;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayNames = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final now = focusStore.now;
    final weekCount = focusStore.weeklySessionCount(now);
    final weekMinutes = focusStore.weeklyFocusMinutes(now);
    final dayCounts = focusStore.weeklyDayCounts(now);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _FocusTechSurface(
      key: const ValueKey('focus-weekly-section'),
      minHeight: 148,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('本周专注', style: _monoLabel(context)),
              Text(
                ' / WEEKLY DIST',
                style: _monoLabel(context).copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.78),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$weekCount 次',
                    key: const ValueKey('focus-weekly-sessions'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    '$weekMinutes 分钟',
                    key: const ValueKey('focus-weekly-minutes'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 10),
          _WeeklyAxisGrid(),
          const SizedBox(height: 8),
          SizedBox(
            key: const ValueKey('focus-weekly-strip'),
            height: 58,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < dayCounts.length; i++) ...[
                  Expanded(
                    child: _WeeklyBar(
                      count: dayCounts[i],
                      maxCount: _maxCount(dayCounts),
                      label: _dayLabels[i],
                      semanticLabel: '周${_dayNames[i]} ${dayCounts[i]} 次',
                      active: dayCounts[i] > 0,
                    ),
                  ),
                  if (i != dayCounts.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({
    required this.count,
    required this.maxCount,
    required this.label,
    required this.semanticLabel,
    required this.active,
  });

  final int count;
  final int maxCount;
  final String label;
  final String semanticLabel;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = 7 + normalized * 28;
    final color = active
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.13);

    return Semantics(
      label: semanticLabel,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.22),
                        blurRadius: 12,
                        spreadRadius: -4,
                      ),
                    ]
                  : const [],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: active
                  ? colorScheme.primary
                  : AppThemeTokens.secondaryTextTone(
                      colorScheme,
                    ).withValues(alpha: 0.72),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusHeatmapPanel extends StatelessWidget {
  const _FocusHeatmapPanel({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final matrix = _weeklyHeatmap(focusStore);
    final colorScheme = Theme.of(context).colorScheme;

    return _FocusTechSurface(
      minHeight: 108,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('专注热力图', style: _monoLabel(context)),
              Text(
                ' / HEATMAP',
                style: _monoLabel(context).copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.78),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.64),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (var row = 0; row < matrix.length; row++) ...[
                Row(
                  children: [
                    for (var column = 0; column < matrix[row].length; column++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: column == matrix[row].length - 1 ? 0 : 5,
                          ),
                          child: _HeatCell(count: matrix[row][column]),
                        ),
                      ),
                  ],
                ),
                if (row != matrix.length - 1) const SizedBox(height: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alpha = switch (count) {
      0 => 0.11,
      1 => 0.46,
      2 => 0.68,
      _ => 0.92,
    };

    return AspectRatio(
      aspectRatio: 2.05,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: count == 0
              ? colorScheme.onSurface.withValues(alpha: alpha)
              : colorScheme.primary.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _FocusTargetSection extends StatelessWidget {
  const _FocusTargetSection({required this.focusStore, required this.targets});

  final FocusStore focusStore;
  final List<FocusTargetSnapshot> targets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final target = focusStore.currentTarget;
    final isLocked = !focusStore.isIdle;

    return _FocusTechSurface(
      key: const ValueKey('focus-target-section'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '本轮专注对象',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                isLocked ? '对象已锁定' : '可选',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (target == null)
            _EmptyFocusTarget(
              isLocked: isLocked,
              onSelect: focusStore.isIdle
                  ? () => _showTargetPicker(context, focusStore, targets)
                  : null,
            )
          else
            _SelectedFocusTarget(
              target: target,
              isLocked: isLocked,
              onSelect: focusStore.isIdle
                  ? () => _showTargetPicker(context, focusStore, targets)
                  : null,
              onClear: focusStore.isIdle
                  ? focusStore.clearSelectedTarget
                  : null,
            ),
        ],
      ),
    );
  }

  Future<void> _showTargetPicker(
    BuildContext context,
    FocusStore focusStore,
    List<FocusTargetSnapshot> targets,
  ) async {
    final selectedTarget = await showModalBottomSheet<FocusTargetSnapshot>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppThemeTokens.pagePadding,
              0,
              AppThemeTokens.pagePadding,
              AppThemeTokens.pagePadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('选择行动', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '从计划里的未完成行动中选择',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
                const SizedBox(height: 16),
                if (targets.isEmpty)
                  _FocusTechSurface(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      '暂无可选择行动',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: targets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (itemContext, index) {
                        final target = targets[index];
                        final isSelected =
                            focusStore.selectedTarget?.taskId == target.taskId;

                        return ListTile(
                          key: ValueKey<String>(
                            'focus-target-option-${target.taskId}',
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.30)
                                  : AppThemeTokens.borderTone(colorScheme),
                            ),
                          ),
                          tileColor: isSelected
                              ? AppThemeTokens.selectedStateTone(colorScheme)
                              : AppThemeTokens.softSurfaceTone(colorScheme),
                          title: Text(target.title),
                          subtitle: Text(target.context),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetContext).pop(target),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedTarget != null) {
      focusStore.selectTarget(selectedTarget);
    }
  }
}

class _EmptyFocusTarget extends StatelessWidget {
  const _EmptyFocusTarget({required this.isLocked, required this.onSelect});

  final bool isLocked;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            isLocked ? '本轮未绑定行动' : '从计划里的未完成行动中选择',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          key: const ValueKey('focus-target-select'),
          onPressed: onSelect,
          child: const Text('选择行动'),
        ),
      ],
    );
  }
}

class _SelectedFocusTarget extends StatelessWidget {
  const _SelectedFocusTarget({
    required this.target,
    required this.isLocked,
    required this.onSelect,
    required this.onClear,
  });

  final FocusTargetSnapshot target;
  final bool isLocked;
  final VoidCallback? onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLocked ? '正在推进' : '已选择行动',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            target.title,
            key: const ValueKey('focus-target-title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            target.context,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              height: 1.22,
            ),
          ),
          if (!isLocked) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  key: const ValueKey('focus-target-select'),
                  onPressed: onSelect,
                  child: const Text('选择行动'),
                ),
                TextButton(
                  key: const ValueKey('focus-target-clear'),
                  onPressed: onClear,
                  child: const Text('清除'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FocusDurationSelector extends StatelessWidget {
  const _FocusDurationSelector({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _FocusTechSurface(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '专注时长',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                focusStore.isIdle ? '下一轮' : '本轮已锁定',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final seconds in FocusStore.durationChoicesSeconds)
                ChoiceChip(
                  key: ValueKey<String>('focus-duration-choice-$seconds'),
                  label: Text('${seconds ~/ 60} 分钟'),
                  selected: focusStore.selectedDurationSeconds == seconds,
                  onSelected: focusStore.isIdle
                      ? (_) => focusStore.selectDuration(seconds)
                      : null,
                ),
              ChoiceChip(
                key: const ValueKey('focus-duration-custom'),
                label: const Text('自定义'),
                selected: focusStore.hasCustomSelectedDuration,
                onSelected: focusStore.isIdle
                    ? (_) => _showCustomDurationDialog(context, focusStore)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDurationDialog(
    BuildContext context,
    FocusStore focusStore,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _CustomDurationDialog(
        initialMinutes: focusStore.selectedDurationSeconds ~/ 60,
      ),
    );

    if (result != null) {
      focusStore.selectDuration(result * 60);
    }
  }
}

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialMinutes}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('自定义时长'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '输入专注时长',
          suffixText: '分钟',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('确定')),
      ],
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    final minutes = int.tryParse(text);
    final isWholeMinutes = RegExp(r'^\d+$').hasMatch(text);

    if (!isWholeMinutes ||
        minutes == null ||
        !FocusStore.isValidDurationMinutes(minutes)) {
      setState(() {
        _errorText = '请输入 1 到 180 分钟';
      });
      return;
    }

    Navigator.of(context).pop(minutes);
  }
}

class _FocusTechSurface extends StatelessWidget {
  const _FocusTechSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.minHeight,
    this.gradientColors,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? minHeight;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors =
        gradientColors ??
        [
          colorScheme.surface.withValues(alpha: 0.76),
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.10),
        ];

    return Container(
      constraints: minHeight == null
          ? const BoxConstraints()
          : BoxConstraints(minHeight: minHeight!),
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

class _FocusProgressLine extends StatelessWidget {
  const _FocusProgressLine({
    required this.value,
    this.color = const Color(0xFF00E5FF),
  });

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        minHeight: 3,
        value: _unit(value),
        color: color,
        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    );
  }
}

class _KickerLabel extends StatelessWidget {
  const _KickerLabel({required this.primary, required this.secondary});

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(primary, style: _monoLabel(context)),
        Text(
          '/ $secondary',
          style: _monoLabel(
            context,
          ).copyWith(color: colorScheme.primary.withValues(alpha: 0.82)),
        ),
      ],
    );
  }
}

TextStyle _monoLabel(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  return Theme.of(context).textTheme.labelSmall!.copyWith(
    color: colorScheme.onSurface.withValues(alpha: 0.88),
    fontSize: 9,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.35,
    height: 1,
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

String _statusDescription(FocusStore focusStore) {
  if (focusStore.isRunning) {
    return '计时进行中，系统会在完成时提醒你。';
  }

  if (focusStore.isPaused) {
    return '这一轮已暂停，可继续，也可重置。';
  }

  if (focusStore.remainingSeconds == 0) {
    return '这一轮已完成，开始即可进入下一轮。';
  }

  return '准备好后，开始一段安静推进。';
}

int _focusScore(FocusStore store, int weekCount, int weekMinutes) {
  if (weekCount == 0 || weekMinutes == 0) {
    return 0;
  }

  final selectedMinutes = store.selectedDurationSeconds ~/ 60;
  final baseline = selectedMinutes <= 0 ? 25 : selectedMinutes;
  final minutesScore = ((weekMinutes / (baseline * 3)) * 70).round();
  final roundsScore = weekCount * 8;
  final score = minutesScore + roundsScore;

  if (score < 1) {
    return 1;
  }

  if (score > 100) {
    return 100;
  }

  return score;
}

List<List<int>> _weeklyHeatmap(FocusStore focusStore) {
  final now = focusStore.now;
  final today = DateTime(now.year, now.month, now.day);
  final matrix = List.generate(4, (_) => List<int>.filled(14, 0));

  for (final session in focusStore.sessions) {
    final local = session.completedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo < 0 || daysAgo >= 14) {
      continue;
    }

    final column = 13 - daysAgo;
    final bucket = (local.hour ~/ 6).clamp(0, 3);
    matrix[bucket][column] += 1;
  }

  return matrix;
}

int _maxCount(List<int> counts) {
  var max = 0;
  for (final count in counts) {
    if (count > max) {
      max = count;
    }
  }

  return max;
}

double _unit(num value) {
  if (value < 0) {
    return 0;
  }

  if (value > 1) {
    return 1;
  }

  return value.toDouble();
}
