import 'package:flutter/material.dart';

import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';
import 'package:four_in_one_app/core/permissions/notification_permission_prompt.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/shared/theme/app_text_styles.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/main_page_header.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final focusStore = FocusStoreScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final targets = _buildSelectableTargets(goalsStore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        focusStore.reconcileSelectedTarget(targets);
      }
    });

    return SingleChildScrollView(
      key: const ValueKey('focus-page-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageTop,
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StitchExactMainPageHeader(
            title: '专注',
            leadingIcon: Icons.timer_outlined,
            actions: [
              StitchExactMainHeaderAction(
                key: const ValueKey('focus-header-target'),
                icon: Icons.adjust_rounded,
                tooltip: '选择专注对象',
                disabledTooltip: '本轮进行中，结束或重置后可选择专注对象',
                onPressed: focusStore.isIdle
                    ? () => _FocusTargetSection.showTargetPicker(
                        context,
                        focusStore,
                        targets,
                      )
                    : null,
                primary: true,
              ),
              StitchExactMainHeaderAction(
                key: const ValueKey('focus-header-settings'),
                icon: Icons.person_outline_rounded,
                tooltip: '我的/设置',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoute.settings),
              ),
            ],
          ),
          _FocusStitchExactDashboard(focusStore: focusStore),
          const SizedBox(height: StitchExactPremiumSpacing.section),
          _FocusTargetSection(focusStore: focusStore, targets: targets),
          const SizedBox(height: StitchExactPremiumSpacing.section),
          _FocusDurationSelector(focusStore: focusStore),
          const SizedBox(height: 12),
          _FocusActionRow(focusStore: focusStore),
          const SizedBox(height: StitchExactPremiumSpacing.section),
          _FocusWeeklyOverview(focusStore: focusStore),
        ],
      ),
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

class _FocusStitchExactDashboard extends StatelessWidget {
  const _FocusStitchExactDashboard({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = focusStore.activeDurationSeconds;
    final elapsedProgress = duration == 0
        ? 0.0
        : ((duration - focusStore.remainingSeconds) / duration).clamp(0.0, 1.0);
    final weekMinutes = focusStore.weeklyFocusMinutes(focusStore.now);
    final weekSessions = focusStore.weeklySessionCount(focusStore.now);
    final todaySessions = focusStore.recentDayCounts(focusStore.now).first;
    final targetTitle = focusStore.currentTarget?.title ?? '深度工作';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StitchExactPanel(
          glow: focusStore.isRunning,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StitchExactCapsLabel(
                      text: '专注状态',
                      accent: colorScheme.primary,
                    ),
                  ),
                  StitchExactStatusPill(
                    label: _focusStatusLabel(focusStore.status),
                    selected: focusStore.isRunning,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  focusStore.formattedRemaining,
                  key: const ValueKey('focus-remaining-time'),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 68,
                    fontWeight: FontWeight.w900,
                    height: 0.88,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _focusStatusDescription(focusStore),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  height: 1.34,
                ),
              ),
              const SizedBox(height: 24),
              StitchExactProgressRail(
                label: '本轮进度',
                value: elapsedProgress,
                detail: targetTitle,
                valueKey: 'focus-session-progress',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        StitchExactMetricGrid(
          minHeight: 74,
          metrics: [
            StitchExactMetric(
              label: '今日',
              value: '$todaySessions',
              detail: '今日轮次',
            ),
            StitchExactMetric(
              label: '分钟',
              value: '$weekMinutes',
              detail: '本周分钟',
              accent: colorScheme.secondary,
            ),
            StitchExactMetric(
              label: '轮次',
              value: '$weekSessions',
              detail: '本周轮次',
              accent: colorScheme.tertiary,
            ),
            StitchExactMetric(
              label: '历史',
              value: '${focusStore.completedSessionCount}',
              detail: '完成专注',
            ),
          ],
        ),
      ],
    );
  }
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

List<int> _focusRecentHeatmapValues(
  FocusStore focusStore, {
  required int days,
}) {
  final today = DateTime(
    focusStore.now.year,
    focusStore.now.month,
    focusStore.now.day,
  );
  final values = List<int>.filled(days, 0);
  for (final session in focusStore.sessions) {
    final local = session.completedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo >= 0 && daysAgo < days) {
      values[days - 1 - daysAgo] += 1;
    }
  }
  return values;
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

    return StitchExactPanel(
      key: const ValueKey('focus-target-section'),
      glow: target != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '本轮专注对象',
                  style: AppTextStyles.sectionTitle(context),
                ),
              ),
              Text(
                isLocked ? '对象已锁定' : '可选',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (target == null)
            _EmptyFocusTarget(
              isLocked: isLocked,
              onSelect: focusStore.isIdle
                  ? () => showTargetPicker(context, focusStore, targets)
                  : null,
            )
          else
            _SelectedFocusTarget(
              target: target,
              isLocked: isLocked,
              onSelect: focusStore.isIdle
                  ? () => showTargetPicker(context, focusStore, targets)
                  : null,
              onClear: focusStore.isIdle
                  ? focusStore.clearSelectedTarget
                  : null,
            ),
        ],
      ),
    );
  }

  static Future<void> showTargetPicker(
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
                  SoftSurface(
                    width: double.infinity,
                    tone: SoftSurfaceTone.flat,
                    borderRadius: AppThemeTokens.radiusLg,
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
                            borderRadius: BorderRadius.circular(
                              AppThemeTokens.radiusLg,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.28)
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.selectedStateTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLocked ? '正在推进' : '已选择行动',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            target.title,
            key: const ValueKey('focus-target-title'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            target.context,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('选择时长', style: AppTextStyles.sectionTitle(context)),
              ),
              if (!focusStore.isIdle) ...[
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                _durationLabel(focusStore.selectedDurationSeconds),
                key: const ValueKey('focus-selected-duration-label'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (
                var index = 0;
                index < FocusStore.durationChoicesSeconds.length;
                index += 1
              ) ...[
                Expanded(
                  child: _FocusDurationOption(
                    key: ValueKey<String>(
                      'focus-duration-choice-${FocusStore.durationChoicesSeconds[index]}',
                    ),
                    label:
                        '${FocusStore.durationChoicesSeconds[index] ~/ 60} 分钟',
                    selected:
                        focusStore.selectedDurationSeconds ==
                        FocusStore.durationChoicesSeconds[index],
                    onTap: focusStore.isIdle
                        ? () => focusStore.selectDuration(
                            FocusStore.durationChoicesSeconds[index],
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: _FocusDurationOption(
                  key: const ValueKey('focus-duration-custom'),
                  label: '自定义',
                  selected: focusStore.hasCustomSelectedDuration,
                  onTap: focusStore.isIdle
                      ? () => _showCustomDurationDialog(context, focusStore)
                      : null,
                ),
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

  String _durationLabel(int seconds) {
    if (seconds % 60 == 0) {
      return '${seconds ~/ 60} 分钟';
    }
    if (seconds < 60) {
      return '$seconds 秒';
    }

    return '${seconds ~/ 60} 分 ${seconds % 60} 秒';
  }
}

class _FocusDurationOption extends StatelessWidget {
  const _FocusDurationOption({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerLowest.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.52)
                : AppThemeTokens.borderTone(
                    colorScheme,
                  ).withValues(alpha: 0.13),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? colorScheme.primary
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        key: const ValueKey('focus-custom-duration-input'),
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
          key: const ValueKey('focus-custom-duration-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('focus-custom-duration-confirm'),
          onPressed: _submit,
          child: const Text('确认'),
        ),
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

class _FocusActionRow extends StatelessWidget {
  const _FocusActionRow({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startLabel = focusStore.isPaused ? '继续' : '开始';

    return StitchExactPanel(
      padding: const EdgeInsets.all(12),
      glow: focusStore.canStart || focusStore.canPause,
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: focusStore.canStart ? '开始或继续专注' : '专注进行中，无需再次开始',
              child: FilledButton(
                key: const ValueKey('focus-start'),
                onPressed: focusStore.canStart ? () => _start(context) : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: AnimatedSwitcher(
                  duration: StitchExactMotion.fast,
                  child: Text(startLabel, key: ValueKey(startLabel)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Tooltip(
              message: focusStore.canPause ? '暂停本轮专注' : '开始专注后可暂停',
              child: FilledButton.tonal(
                key: const ValueKey('focus-pause'),
                onPressed: focusStore.canPause ? focusStore.pause : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: colorScheme.secondary.withValues(
                    alpha: 0.16,
                  ),
                  foregroundColor: colorScheme.secondary,
                ),
                child: const Text('暂停'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Tooltip(
              message: focusStore.canReset ? '重置本轮专注' : '当前已是初始状态',
              child: OutlinedButton(
                key: const ValueKey('focus-reset'),
                onPressed: focusStore.canReset ? focusStore.reset : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('重置'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    AppPermissionResult? permissionResult;
    final runtime = NotificationRuntimeScope.maybeOf(context);
    if (focusStore.isIdle && runtime != null) {
      permissionResult = await requestNotificationPermissionInContext(
        context,
        requestContext: NotificationPermissionContext.focusCompletion,
        controller: runtime,
      );
    }

    focusStore.start();
    if (!context.mounted ||
        permissionResult == null ||
        permissionResult.status == AppPermissionStatus.granted ||
        permissionResult.status == AppPermissionStatus.notApplicable) {
      return;
    }

    final message = switch (permissionResult.status) {
      AppPermissionStatus.denied => '专注已开始，但 Android 尚未允许完成通知。',
      AppPermissionStatus.settingsRequired => '专注已开始，请在系统设置中开启完成通知。',
      AppPermissionStatus.restricted => '专注已开始，但通知受到系统或设备策略限制。',
      AppPermissionStatus.unavailable => '专注已开始，但当前无法读取 Android 通知状态。',
      AppPermissionStatus.granted || AppPermissionStatus.notApplicable => '',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: runtime == null
            ? null
            : SnackBarAction(
                label: '系统设置',
                onPressed: () async {
                  await runtime.openNotificationSettings();
                },
              ),
      ),
    );
  }
}

class _FocusWeeklyOverview extends StatelessWidget {
  const _FocusWeeklyOverview({required this.focusStore});

  final FocusStore focusStore;

  static const _dayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    final now = focusStore.now;
    final weekCount = focusStore.weeklySessionCount(now);
    final weekMinutes = focusStore.weeklyFocusMinutes(now);
    final dayCounts = focusStore.weeklyDayCounts(now);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StitchExactPanel(
      key: const ValueKey('focus-weekly-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchExactCommandHeader(
            eyebrow: '本周回看',
            title: '本周专注',
            subtitle: weekCount == 0 ? '本周还没有完成的专注记录。' : '完成专注后的真实统计。',
            leadingIcon: Icons.calendar_view_week_rounded,
            compact: true,
          ),
          const SizedBox(height: 14),
          StitchExactMetricGrid(
            metrics: [
              StitchExactMetric(
                valueKey: 'focus-weekly-sessions',
                value: '$weekCount 次',
                label: '本周次数',
              ),
              StitchExactMetric(
                valueKey: 'focus-weekly-minutes',
                value: '$weekMinutes 分钟',
                label: '本周时长',
                accent: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          StitchExactCapsLabel(
            text: '周一至周日',
            accent: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
          const SizedBox(height: 10),
          StitchExactMiniBars(
            valueKey: 'focus-weekly-strip',
            values: dayCounts,
            labels: _dayLabels,
          ),
          const SizedBox(height: 20),
          const StitchExactCapsLabel(text: '最近 28 天'),
          const SizedBox(height: 10),
          StitchExactHeatmap(
            values: _focusRecentHeatmapValues(focusStore, days: 28),
            columns: 14,
            valueKey: 'focus-heatmap-grid',
          ),
          if (weekCount == 0) ...[
            const SizedBox(height: 10),
            Text(
              '本周还没有完成的专注记录。',
              key: const ValueKey('focus-weekly-empty'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
