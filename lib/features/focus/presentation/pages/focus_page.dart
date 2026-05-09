import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/focus_timer_hero.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final focusStore = FocusStoreScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final theme = Theme.of(context);
    final targets = _buildSelectableTargets(goalsStore);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        AppThemeTokens.spaceXl,
        AppThemeTokens.pagePadding,
        AppThemeTokens.pagePadding,
      ),
      children: [
        Text('把注意力交给此刻。', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '选择一段时间，开始、暂停或重置这一轮专注。',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppThemeTokens.secondaryTextTone(theme.colorScheme),
          ),
        ),
        const SizedBox(height: AppThemeTokens.pagePadding),
        _FocusTargetSection(focusStore: focusStore, targets: targets),
        const SizedBox(height: 18),
        _FocusTimerPanel(focusStore: focusStore),
        const SizedBox(height: 18),
        _FocusDurationSelector(focusStore: focusStore),
        const SizedBox(height: 18),
        _FocusActionRow(focusStore: focusStore),
      ],
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

class _FocusTimerPanel extends StatelessWidget {
  const _FocusTimerPanel({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    final duration = focusStore.activeDurationSeconds;
    final progress = duration == 0
        ? 0.0
        : focusStore.remainingSeconds / duration;
    final target = focusStore.currentTarget;

    return FocusTimerHero(
      remainingTime: focusStore.formattedRemaining,
      remainingTimeKey: const ValueKey('focus-remaining-time'),
      statusLabel: _statusLabel(focusStore.status),
      statusDescription: _statusDescription(focusStore),
      durationLabel: '本轮时长 ${focusStore.activeDurationSeconds ~/ 60} 分钟',
      visualState: _visualState(focusStore.status),
      progressValue: progress,
      target: target == null
          ? null
          : FocusTimerHeroTarget(title: target.title, context: target.context),
    );
  }

  FocusTimerHeroState _visualState(FocusStatus status) {
    switch (status) {
      case FocusStatus.running:
        return FocusTimerHeroState.running;
      case FocusStatus.paused:
        return FocusTimerHeroState.paused;
      case FocusStatus.idle:
        return FocusTimerHeroState.idle;
    }
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

    return Container(
      key: const ValueKey('focus-target-section'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('本轮专注对象', style: theme.textTheme.titleMedium),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.softSurfaceTone(colorScheme),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusLg,
                      ),
                      border: Border.all(
                        color: AppThemeTokens.borderTone(colorScheme),
                      ),
                    ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('选择时长', style: theme.textTheme.titleMedium)),
              Text(
                focusStore.isIdle ? '下一轮' : '本轮已锁定',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
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

class _FocusActionRow extends StatelessWidget {
  const _FocusActionRow({required this.focusStore});

  final FocusStore focusStore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: focusStore.canStart ? focusStore.start : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(focusStore.isPaused ? '继续' : '开始'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonal(
            onPressed: focusStore.canPause ? focusStore.pause : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('暂停'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: focusStore.canReset ? focusStore.reset : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('重置'),
          ),
        ),
      ],
    );
  }
}
