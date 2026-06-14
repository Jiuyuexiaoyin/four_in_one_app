import 'dart:io';

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habit_record_attachment_storage.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_check_in_template.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_metric.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_statistics_summary.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/activity_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/analytics_bar_list.dart';
import 'package:four_in_one_app/shared/widgets/product/habit_identity_card.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_tile.dart';
import 'package:four_in_one_app/shared/widgets/product/mini_heatmap_cell.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

const _habitEmojiPresets = <String>[
  '🌱',
  '💧',
  '📖',
  '🚶',
  '🏃',
  '🧘',
  '💤',
  '🍎',
  '🧠',
  '✍️',
  '🧹',
  '🎯',
];

const _habitReminderPresets = <String>['08:30', '12:30', '18:00', '21:30'];

const _followInterfaceAccentColorKey = 'habit-color-follow-accent';

const _habitColorPresets = <_HabitColorPreset>[
  _HabitColorPreset(label: '松绿色', value: 0xFF6FA982),
  _HabitColorPreset(label: '鼠尾草绿', value: 0xFF91A987),
  _HabitColorPreset(label: '雾蓝色', value: 0xFF6F95AF),
  _HabitColorPreset(label: '陶土色', value: 0xFFB47A62),
  _HabitColorPreset(label: '灰紫色', value: 0xFF8E86B6),
  _HabitColorPreset(label: '暖米色', value: 0xFFB9A26B),
  _HabitColorPreset(label: '柔和橙', value: 0xFFD08A52),
  _HabitColorPreset(label: '深青色', value: 0xFF4F8D8B),
];

class _HabitColorPreset {
  const _HabitColorPreset({required this.label, required this.value});

  final String label;
  final int value;
}

class HabitsPage extends StatelessWidget {
  const HabitsPage({
    this.attachmentStorage,
    this.showScaffold = true,
    super.key,
  });

  final HabitRecordAttachmentStorage? attachmentStorage;
  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.maybeOf(context);
    final effectiveAttachmentStorage =
        attachmentStorage ?? const LocalHabitRecordAttachmentStorage();
    final activeHabits = habitsStore.habits;
    final pausedHabits = habitsStore.pausedHabits;
    final archivedHabits = habitsStore.archivedHabits;
    final displayActiveHabits = [...activeHabits]
      ..sort(_compareHabitDisplayOrder);
    final hasVisibleHabits =
        activeHabits.isNotEmpty ||
        pausedHabits.isNotEmpty ||
        archivedHabits.isNotEmpty;
    final nextHabit = displayActiveHabits
        .where((habit) => !habitsStore.isCompletedToday(habit))
        .cast<HabitItem?>()
        .firstWhere((habit) => habit != null, orElse: () => null);
    final weeklyCounts = _weeklyHabitCounts(habitsStore, activeHabits);
    final recentRecords = _recentRecordPreviews(habitsStore, [
      ...activeHabits,
      ...pausedHabits,
      ...archivedHabits,
    ]);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final compactHeight = mediaSize.height < 720;
        final viewportWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = viewportWidth.isFinite && viewportWidth > 0
            ? viewportWidth
            : constraints.maxWidth;
        final contentWidth = availableWidth > 28
            ? availableWidth - 28
            : availableWidth;

        return SingleChildScrollView(
          key: const ValueKey('habits-page-scroll'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StriveHeader(
                    onAddPressed: () =>
                        _showCreateHabitDialog(context, habitsStore),
                  ),
                  const _HabitCompatibilityAnchors(),
                  SizedBox(height: compactHeight ? 14 : 34),
                  _HabitsRhythmStage(
                    totalCount: habitsStore.totalCount,
                    completedCount: habitsStore.completedCount,
                    totalCheckInsToday: habitsStore.totalCheckInsToday,
                    weeklyCounts: weeklyCounts,
                  ),
                  if (!compactHeight) ...[
                    const SizedBox(height: 10),
                    _HabitCadencePanel(
                      nextHabit: nextHabit,
                      remainingCount: habitsStore.remainingCount,
                      totalCheckInsToday: habitsStore.totalCheckInsToday,
                      onPrimaryPressed: nextHabit == null
                          ? null
                          : () => habitsStore.checkIn(nextHabit.id),
                    ),
                    const SizedBox(height: 10),
                    _HabitDailyRhythmPanel(
                      weeklyCounts: weeklyCounts,
                      totalCheckInsToday: habitsStore.totalCheckInsToday,
                    ),
                  ],
                  SizedBox(height: compactHeight ? 10 : 12),
                  _HabitsListHeader(
                    totalCount: habitsStore.totalCount,
                    completedCount: habitsStore.completedCount,
                    totalCheckInsToday: habitsStore.totalCheckInsToday,
                  ),
                  const SizedBox(height: 8),
                  if (!hasVisibleHabits)
                    const _HabitsEmptyState()
                  else
                    Column(
                      children: [
                        ...displayActiveHabits.map(
                          (habit) => _buildHabitCard(
                            context,
                            habitsStore,
                            habit,
                            effectiveAttachmentStorage,
                            goalsStore,
                          ),
                        ),
                        if (pausedHabits.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _HabitLifecycleSectionHeader(
                            title: '已暂停',
                            subtitle: '暂停后不进入今日要求，历史记录仍可查看。',
                          ),
                          const SizedBox(height: 8),
                          ...pausedHabits.map(
                            (habit) => _buildHabitCard(
                              context,
                              habitsStore,
                              habit,
                              effectiveAttachmentStorage,
                              goalsStore,
                            ),
                          ),
                        ],
                        if (archivedHabits.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _ArchivedHabitsSection(
                            habits: archivedHabits,
                            itemBuilder: (habit) => _buildHabitCard(
                              context,
                              habitsStore,
                              habit,
                              effectiveAttachmentStorage,
                              goalsStore,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 12),
                  _HabitInsightPreview(
                    remainingCount: habitsStore.remainingCount,
                    totalCheckInsToday: habitsStore.totalCheckInsToday,
                    activeCount: habitsStore.totalCount,
                  ),
                  if (recentRecords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _RecentRecordPreview(items: recentRecords.take(3).toList()),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: content,
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
    HabitRecordAttachmentStorage attachmentStorage,
    GoalsStore? goalsStore,
  ) {
    final isActive = habit.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
      child: _TodayHabitRow(
        habitId: habit.id,
        emoji: habit.emoji,
        name: habit.name,
        description: habit.description,
        todayCount: habitsStore.todayCheckInCount(habit),
        targetCount: habit.targetCountPerDay,
        targetReached: habitsStore.isCompletedToday(habit),
        skippedToday: isActive && habitsStore.isSkippedToday(habit),
        reminderSummary: _reminderCardSummary(habit.reminderRules),
        hasReminder: habit.reminderRules.isNotEmpty,
        accentColor: _habitAccentColor(habit),
        lifecycleLabel: _habitLifecycleLabel(habit),
        lifecycleDescription: _habitLifecycleDescription(habit),
        planLinkSummary: _habitPlanLinkSummary(habit, goalsStore),
        planLinkUnavailable: _habitPlanLinkUnavailable(habit, goalsStore),
        recentActivityItems: _recentActivityItems(
          habitId: habit.id,
          activity: habitsStore.recentActivityDays(habit),
          targetCount: habit.targetCountPerDay,
        ),
        onCheckIn: isActive ? () => habitsStore.checkIn(habit.id) : null,
        onEdit: () => _showEditHabitDialog(context, habitsStore, habit),
        onReminderTap: () => _showReminderPicker(context, habitsStore, habit),
        onMonthView: () => _showMonthlyActivityDialog(
          context,
          habitsStore,
          habit,
          habitsStore.currentMonthActivity(habit),
          _habitAccentColor(habit),
          attachmentStorage,
        ),
        onRecordDetails: () => _showHabitRecordSheet(
          context,
          habitsStore,
          habit,
          attachmentStorage,
        ),
        onStatistics: () => _showHabitStatisticsSheet(
          context,
          habitsStore,
          habit,
          attachmentStorage,
        ),
        onLifecycleTap: () =>
            _showHabitLifecycleSheet(context, habitsStore, habit, goalsStore),
      ),
    );
  }

  Future<void> _showCreateHabitDialog(
    BuildContext context,
    HabitsStore habitsStore,
  ) async {
    final habitDraft = await showDialog<_HabitDraft>(
      context: context,
      builder: (_) => const _HabitFormDialog.create(),
    );

    if (habitDraft == null) {
      return;
    }

    await habitsStore.createHabit(
      habitDraft.name,
      emoji: habitDraft.emoji,
      description: habitDraft.description,
      targetCountPerDay: habitDraft.targetCountPerDay,
      reminderRules: habitDraft.reminderRules,
      habitColorValue: habitDraft.habitColorValue,
      checkInTemplates: habitDraft.checkInTemplates
          .where((template) => !template.isArchived)
          .map(
            (template) => HabitCheckInTemplateDraft(
              title: template.title,
              unit: template.unit,
              defaultValue: template.defaultValue,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _showEditHabitDialog(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
  ) async {
    final habitDraft = await showDialog<_HabitDraft>(
      context: context,
      builder: (_) => _HabitFormDialog.edit(
        habit,
        initialTemplates: habitsStore.templatesForHabit(
          habit,
          includeArchived: true,
        ),
      ),
    );

    if (habitDraft == null) {
      return;
    }

    final didUpdateHabit = await habitsStore.updateHabit(
      habit.id,
      name: habitDraft.name,
      emoji: habitDraft.emoji,
      description: habitDraft.description,
      targetCountPerDay: habitDraft.targetCountPerDay,
      reminderRules: habitDraft.reminderRules,
      habitColorValue: habitDraft.habitColorValue,
      clearHabitColorValue: habitDraft.habitColorValue == null,
    );
    if (didUpdateHabit) {
      await _syncCheckInTemplateDrafts(
        habitsStore,
        habit.id,
        habitDraft.checkInTemplates,
      );
    }
  }

  Future<void> _syncCheckInTemplateDrafts(
    HabitsStore habitsStore,
    String habitId,
    List<_HabitTemplateDraft> drafts,
  ) async {
    for (final draft in drafts) {
      if (draft.id == null) {
        if (!draft.isArchived) {
          await habitsStore.addCheckInTemplate(
            habitId,
            title: draft.title,
            unit: draft.unit,
            defaultValue: draft.defaultValue,
          );
        }
        continue;
      }

      if (draft.isArchived) {
        await habitsStore.archiveCheckInTemplate(draft.id!);
      } else {
        await habitsStore.updateCheckInTemplate(
          draft.id!,
          title: draft.title,
          unit: draft.unit,
          defaultValue: draft.defaultValue,
          clearDefaultValue: draft.defaultValue == null,
        );
        await habitsStore.restoreCheckInTemplate(draft.id!);
      }
    }
  }

  Future<void> _showMonthlyActivityDialog(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
    HabitActivityMonth monthActivity,
    Color? accentColor,
    HabitRecordAttachmentStorage attachmentStorage,
  ) async {
    final selectedDateKey = await showDialog<String>(
      context: context,
      builder: (_) => _MonthlyActivityDialog(
        habit: habit,
        monthActivity: monthActivity,
        accentColor: accentColor,
      ),
    );

    if (selectedDateKey == null || !context.mounted) {
      return;
    }

    await _showHabitRecordSheet(
      context,
      habitsStore,
      habit,
      attachmentStorage,
      initialDateKey: selectedDateKey,
    );
  }

  Future<void> _showHabitRecordSheet(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
    HabitRecordAttachmentStorage attachmentStorage, {
    String? initialDateKey,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HabitRecordSheet(
        habit: habit,
        habitsStore: habitsStore,
        attachmentStorage: attachmentStorage,
        initialDateKey: initialDateKey,
        recordsEditable: habit.isActive,
      ),
    );
  }

  Future<void> _showHabitStatisticsSheet(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
    HabitRecordAttachmentStorage attachmentStorage,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HabitStatisticsSheet(
        habit: habit,
        habitsStore: habitsStore,
        attachmentStorage: attachmentStorage,
        accentColor: _habitAccentColor(habit),
      ),
    );
  }

  Future<void> _showReminderPicker(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
  ) async {
    final selection = await showModalBottomSheet<_ReminderSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ReminderRulesSheet(
        initialRules: habit.reminderRules,
        draftHabitId: habit.id,
      ),
    );

    if (selection == null) {
      return;
    }

    await habitsStore.updateHabitReminderRules(
      habit.id,
      selection.reminderRules,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selection.reminderTime == null ? '提醒已清除' : '提醒已设置；若系统未授权通知，请在系统设置开启。',
        ),
      ),
    );
  }

  Future<void> _showHabitLifecycleSheet(
    BuildContext context,
    HabitsStore habitsStore,
    HabitItem habit,
    GoalsStore? goalsStore,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _HabitLifecycleActionSheet(
        habit: habit,
        habitsStore: habitsStore,
        goalsStore: goalsStore,
      ),
    );
  }
}

class _HabitLifecycleSectionHeader extends StatelessWidget {
  const _HabitLifecycleSectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceLg,
        vertical: AppThemeTokens.spaceMd,
      ),
      backgroundColor: AppThemeTokens.softSurfaceTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedHabitsSection extends StatelessWidget {
  const _ArchivedHabitsSection({
    required this.habits,
    required this.itemBuilder,
  });

  final List<HabitItem> habits;
  final Widget Function(HabitItem habit) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey('habits-archived-section'),
      tilePadding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceSm,
      ),
      childrenPadding: EdgeInsets.zero,
      title: const Text('已归档习惯'),
      subtitle: Text('共 ${habits.length} 项，历史记录会继续保留。'),
      children: habits.map(itemBuilder).toList(growable: false),
    );
  }
}

class _StriveHeader extends StatelessWidget {
  const _StriveHeader({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasShellBackButton = Navigator.of(context).canPop();

    return Row(
      children: [
        if (hasShellBackButton) const SizedBox(width: 34),
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 13,
                color: Color(0xFF00E5FF),
              ),
              const SizedBox(width: 6),
              Text(
                'STRIVE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: onAddPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF101010).withValues(alpha: 0.74),
            foregroundColor: const Color(0xFF00E5FF),
            minimumSize: const Size(0, 28),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            '添加习惯',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.78),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _HabitCompatibilityAnchors extends StatelessWidget {
  const _HabitCompatibilityAnchors();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 1,
      height: 1,
      color: Colors.transparent,
    );

    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          height: 1,
          child: OverflowBox(
            maxHeight: 6,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Habits', maxLines: 1, style: style),
                Text('轻量记录每天的重复行为。', maxLines: 1, style: style),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitTechPanel extends StatelessWidget {
  const _HabitTechPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF101111).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.030),
            const Color(0xFF101111).withValues(alpha: 0.72),
            const Color(0xFF80FF2C).withValues(alpha: 0.012),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.026),
            blurRadius: 18,
            spreadRadius: -14,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HabitsRhythmStage extends StatelessWidget {
  const _HabitsRhythmStage({
    required this.totalCount,
    required this.completedCount,
    required this.totalCheckInsToday,
    required this.weeklyCounts,
  });

  final int totalCount;
  final int completedCount;
  final int totalCheckInsToday;
  final List<int> weeklyCounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final readiness = (progress * 100).round();
    final strain = ((totalCount - completedCount).clamp(0, 999) * 2.2 +
            totalCheckInsToday * 0.6)
        .clamp(0, 99)
        .toStringAsFixed(1);
    final focusMinutes =
        weeklyCounts.fold<int>(0, (sum, count) => sum + count) * 7;

    return _HabitTechPanel(
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
                      '每日准备就绪',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '状态完整度 (STATE INTEGRITY)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _habitMono(
                        theme,
                        const Color(0xFF00E5FF).withValues(alpha: 0.88),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$readiness%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      height: 0.88,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'SYNC $completedCount/$totalCount',
                    style: _habitMono(
                      theme,
                      Colors.white.withValues(alpha: 0.42),
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProtocolProgressLine(
            value: progress,
            color: const Color(0xFF00E5FF),
          ),
          const SizedBox(height: 6),
          _ReadinessScale(value: progress),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _ProtocolMetricTile(
                  icon: Icons.bolt_rounded,
                  label: '状态',
                  value: '$completedCount/$totalCount',
                  color: const Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ProtocolMetricTile(
                  icon: Icons.local_fire_department_outlined,
                  label: '压力',
                  value: strain,
                  color: const Color(0xFF80FF2C),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ProtocolMetricTile(
                  icon: Icons.timer_outlined,
                  label: '专注',
                  value: '${focusMinutes}m',
                  color: const Color(0xFFDCC8FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitCadencePanel extends StatelessWidget {
  const _HabitCadencePanel({
    required this.nextHabit,
    required this.remainingCount,
    required this.totalCheckInsToday,
    required this.onPrimaryPressed,
  });

  final HabitItem? nextHabit;
  final int remainingCount;
  final int totalCheckInsToday;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = nextHabit;
    final hasHabit = habit != null;
    final title = hasHabit ? '${habit.emoji} ${habit.name}' : '等待第一个协议';
    final subtitle = hasHabit
        ? (habit.description.isEmpty
              ? '下一项重复行为等待确认。'
              : habit.description)
        : '创建习惯后，这里会显示当前节奏。';
    final target = hasHabit ? habit.targetCountPerDay : 0;
    final accent = hasHabit
        ? (_habitAccentColor(habit) ?? const Color(0xFF00E5FF))
        : const Color(0xFF00E5FF);

    return _HabitTechPanel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '当前节奏 (CURRENT CADENCE)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _habitMono(
                    theme,
                    const Color(0xFF00E5FF).withValues(alpha: 0.88),
                    fontSize: 8,
                  ),
                ),
              ),
              Icon(
                Icons.psychology_alt_outlined,
                size: 14,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.80),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
              height: 1.24,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CadenceNumber(label: '剩余', value: '$remainingCount'),
              const Spacer(),
              _CadenceNumber(label: '目标', value: '$target'),
              const SizedBox(width: 18),
              _CadenceNumber(label: '今日', value: '$totalCheckInsToday'),
            ],
          ),
          const SizedBox(height: 11),
          TextButton(
            onPressed: onPrimaryPressed,
            style: TextButton.styleFrom(
              backgroundColor: accent,
              foregroundColor:
                  ThemeData.estimateBrightnessForColor(accent) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black,
              minimumSize: const Size.fromHeight(30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              hasHabit ? '完成 (COMPLETE)' : '无待执行协议',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ProtocolProgressLine(
            value: target == 0
                ? 0
                : (totalCheckInsToday / target).clamp(0.0, 1.0).toDouble(),
            color: accent,
          ),
        ],
      ),
    );
  }
}

class _HabitDailyRhythmPanel extends StatelessWidget {
  const _HabitDailyRhythmPanel({
    required this.weeklyCounts,
    required this.totalCheckInsToday,
  });

  final List<int> weeklyCounts;
  final int totalCheckInsToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = weeklyCounts.fold<int>(0, (sum, count) => sum + count);
    final maxCount = weeklyCounts.fold<int>(
      1,
      (currentMax, count) => count > currentMax ? count : currentMax,
    );
    final rhythmScore = total == 0
        ? 0
        : ((totalCheckInsToday / maxCount) * 100).clamp(0, 100).round();

    return _HabitTechPanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '每日节奏 (DAILY RHYTHM)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _habitMono(
                    theme,
                    Colors.white.withValues(alpha: 0.76),
                    fontSize: 8,
                  ),
                ),
              ),
              Text(
                '$rhythmScore%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.045),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: _HabitRhythmMatrix(
              weeklyCounts: weeklyCounts,
              totalCheckInsToday: totalCheckInsToday,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessScale extends StatelessWidget {
  const _ReadinessScale({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSegments = (value.clamp(0.0, 1.0) * 18).round();

    return Column(
      children: [
        Row(
          children: [
            Text(
              'LOW',
              style: _habitMono(
                theme,
                Colors.white.withValues(alpha: 0.30),
                fontSize: 6.5,
              ),
            ),
            const Spacer(),
            Text(
              'READY',
              style: _habitMono(
                theme,
                const Color(0xFF00E5FF).withValues(alpha: 0.58),
                fontSize: 6.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (var i = 0; i < 18; i += 1) ...[
              Expanded(
                child: Container(
                  height: i % 3 == 0 ? 5 : 3,
                  decoration: BoxDecoration(
                    color: i < activeSegments
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.72)
                        : Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              if (i != 17) const SizedBox(width: 3),
            ],
          ],
        ),
      ],
    );
  }
}

class _HabitRhythmMatrix extends StatelessWidget {
  const _HabitRhythmMatrix({
    required this.weeklyCounts,
    required this.totalCheckInsToday,
  });

  final List<int> weeklyCounts;
  final int totalCheckInsToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = weeklyCounts.fold<int>(
      1,
      (currentMax, count) => count > currentMax ? count : currentMax,
    );
    final todayIndex = DateTime.now().weekday - 1;
    const labels = ['一', '二', '三', '四', '五', '六', '日'];

    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < 3; row += 1) ...[
                Expanded(
                  child: Row(
                    children: [
                      for (var column = 0; column < 7; column += 1) ...[
                        Expanded(
                          child: _RhythmNode(
                            count: column < weeklyCounts.length
                                ? weeklyCounts[column]
                                : 0,
                            maxCount: maxCount,
                            row: row,
                            today: column == todayIndex,
                            livePulse:
                                column == todayIndex && totalCheckInsToday > 0,
                          ),
                        ),
                        if (column != 6) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
                if (row != 2) const SizedBox(height: 5),
              ],
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            for (var i = 0; i < labels.length; i += 1) ...[
              Expanded(
                child: Center(
                  child: Text(
                    labels[i],
                    style: _habitMono(
                      theme,
                      (i < weeklyCounts.length && weeklyCounts[i] > 0)
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.74)
                          : Colors.white.withValues(alpha: 0.34),
                      fontSize: 7,
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}

class _RhythmNode extends StatelessWidget {
  const _RhythmNode({
    required this.count,
    required this.maxCount,
    required this.row,
    required this.today,
    required this.livePulse,
  });

  final int count;
  final int maxCount;
  final int row;
  final bool today;
  final bool livePulse;

  @override
  Widget build(BuildContext context) {
    final normalized = maxCount == 0 ? 0.0 : count / maxCount;
    final threshold = (3 - row) / 3;
    final active = count > 0 && normalized >= threshold;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF00E5FF).withValues(alpha: 0.36 + normalized * 0.42)
            : Colors.white.withValues(
                alpha: livePulse
                    ? 0.16
                    : today
                    ? 0.12
                    : 0.075,
              ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: active
              ? const Color(0xFF00E5FF).withValues(alpha: 0.18)
              : Colors.white.withValues(
                  alpha: livePulse
                      ? 0.10
                      : today
                      ? 0.07
                      : 0.035,
                ),
        ),
      ),
    );
  }
}

class _ProtocolMetricTile extends StatelessWidget {
  const _ProtocolMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.026),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _habitMono(
                    theme,
                    color.withValues(alpha: 0.92),
                    fontSize: 7.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CadenceNumber extends StatelessWidget {
  const _CadenceNumber({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _habitMono(
            theme,
            Colors.white.withValues(alpha: 0.42),
            fontSize: 7.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _ProtocolProgressLine extends StatelessWidget {
  const _ProtocolProgressLine({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      height: 7,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            top: 3,
            bottom: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayHabitRow extends StatelessWidget {
  const _TodayHabitRow({
    required this.habitId,
    required this.emoji,
    required this.name,
    required this.todayCount,
    required this.targetCount,
    required this.targetReached,
    required this.skippedToday,
    required this.reminderSummary,
    required this.hasReminder,
    required this.planLinkUnavailable,
    required this.recentActivityItems,
    required this.onCheckIn,
    required this.onEdit,
    required this.onReminderTap,
    required this.onMonthView,
    required this.onRecordDetails,
    required this.onStatistics,
    required this.onLifecycleTap,
    this.description,
    this.accentColor,
    this.lifecycleLabel,
    this.lifecycleDescription,
    this.planLinkSummary,
  });

  final String habitId;
  final String emoji;
  final String name;
  final String? description;
  final int todayCount;
  final int targetCount;
  final bool targetReached;
  final bool skippedToday;
  final String reminderSummary;
  final bool hasReminder;
  final Color? accentColor;
  final String? lifecycleLabel;
  final String? lifecycleDescription;
  final String? planLinkSummary;
  final bool planLinkUnavailable;
  final List<ActivityStripItem> recentActivityItems;
  final VoidCallback? onCheckIn;
  final VoidCallback onEdit;
  final VoidCallback onReminderTap;
  final VoidCallback onMonthView;
  final VoidCallback? onRecordDetails;
  final VoidCallback onStatistics;
  final VoidCallback onLifecycleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccent = accentColor ?? colorScheme.primary;
    final statusLabel = skippedToday
        ? '今日已跳过'
        : targetReached
        ? '今日已完成'
        : '$todayCount/$targetCount';
    final actionLabel = onCheckIn == null
        ? '暂停'
        : targetReached
        ? '加一次'
        : '打卡';

    return Container(
      padding: const EdgeInsets.fromLTRB(9, 9, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101010).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveAccent.withValues(alpha: 0.030),
            const Color(0xFF101010).withValues(alpha: 0.64),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HabitOrb(emoji: emoji, color: effectiveAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        _HabitStatePill(
                          label: statusLabel,
                          color: effectiveAccent,
                          quiet: !targetReached,
                        ),
                      ],
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.46),
                          fontWeight: FontWeight.w600,
                          height: 1.16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      '今日 $todayCount / $targetCount',
                      key: ValueKey<String>(
                        'habit-today-count-$todayCount-$targetCount',
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: targetReached
                            ? effectiveAccent
                            : Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    if (skippedToday) ...[
                      const SizedBox(height: 3),
                      Text(
                        '今天已跳过',
                        key: ValueKey<String>('habit-skip-state-$habitId'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: AppThemeTokens.spaceXs,
                      runSpacing: AppThemeTokens.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton.icon(
                          key: ValueKey<String>('habit-reminder-$habitId'),
                          onPressed: onReminderTap,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 23),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.white.withValues(
                              alpha: 0.50,
                            ),
                            backgroundColor: effectiveAccent.withValues(
                              alpha: 0.035,
                            ),
                          ),
                          icon: Icon(
                            Icons.notifications_none_rounded,
                          size: 12,
                          color: effectiveAccent.withValues(alpha: 0.66),
                          ),
                          label: Text(
                            hasReminder ? reminderSummary : '未设置提醒',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lifecycleLabel != null)
                          _HabitMetaChip(
                            label: lifecycleLabel!,
                            icon: Icons.pause_circle_outline_rounded,
                            color: colorScheme.tertiary,
                            tooltip: lifecycleDescription,
                          ),
                        if (planLinkSummary != null)
                          _HabitMetaChip(
                            label: planLinkSummary!,
                            icon: Icons.link_rounded,
                            color: planLinkUnavailable
                                ? colorScheme.error
                                : effectiveAccent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              FilledButton(
                key: ValueKey<String>('habit-check-in-$habitId'),
                onPressed: onCheckIn,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 29),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: effectiveAccent.withValues(alpha: 0.20),
                  foregroundColor: effectiveAccent,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.34),
                  side: BorderSide(color: effectiveAccent.withValues(alpha: 0.18)),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _WeeklyRhythmStrip(
            items: recentActivityItems,
            accentColor: effectiveAccent,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppThemeTokens.spaceXs,
            runSpacing: AppThemeTokens.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                key: ValueKey<String>('habit-records-$habitId'),
                onPressed: onRecordDetails,
                style: _compactHabitActionStyle(context),
                child: const Text('记录'),
              ),
              TextButton(
                key: ValueKey<String>('habit-stats-$habitId'),
                onPressed: onStatistics,
                style: _compactHabitActionStyle(context),
                child: const Text('统计'),
              ),
              TextButton(
                key: ValueKey<String>('habit-activity-month-$habitId'),
                onPressed: onMonthView,
                style: _compactHabitActionStyle(context),
                child: const Text('节奏'),
              ),
              IconButton(
                key: ValueKey<String>('habit-edit-$habitId'),
                tooltip: '编辑习惯',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 15),
                style: IconButton.styleFrom(
                  minimumSize: const Size(28, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppThemeTokens.secondaryTextTone(
                    colorScheme,
                  ),
                ),
              ),
              IconButton(
                key: ValueKey<String>('habit-lifecycle-$habitId'),
                tooltip: '管理习惯状态',
                onPressed: onLifecycleTap,
                icon: const Icon(Icons.more_horiz_rounded, size: 15),
                style: IconButton.styleFrom(
                  minimumSize: const Size(28, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppThemeTokens.secondaryTextTone(
                    colorScheme,
                  ),
                ),
              ),
            ],
          ),
          _HabitRowCompatibilityText(emoji: emoji, name: name),
          _HabitIdentityCompatibilityAnchor(
            habitId: habitId,
            emoji: emoji,
            name: name,
            description: description,
            todayCount: todayCount,
            targetCount: targetCount,
            targetReached: targetReached,
            skippedToday: skippedToday,
            reminderSummary: reminderSummary,
            hasReminder: hasReminder,
            accentColor: accentColor,
            lifecycleLabel: lifecycleLabel,
            lifecycleDescription: lifecycleDescription,
            planLinkSummary: planLinkSummary,
            planLinkUnavailable: planLinkUnavailable,
            recentActivityItems: recentActivityItems,
            onCheckIn: onCheckIn,
            onEdit: onEdit,
            onReminderTap: onReminderTap,
            onMonthView: onMonthView,
            onRecordDetails: onRecordDetails,
            onStatistics: onStatistics,
            onLifecycleTap: onLifecycleTap,
          ),
        ],
      ),
    );
  }
}

class _HabitIdentityCompatibilityAnchor extends HabitIdentityCard {
  const _HabitIdentityCompatibilityAnchor({
    required super.habitId,
    required super.emoji,
    required super.name,
    required super.todayCount,
    required super.targetCount,
    required super.targetReached,
    required super.recentActivityItems,
    required super.onCheckIn,
    required super.onEdit,
    required super.onReminderTap,
    required super.onMonthView,
    required super.onRecordDetails,
    required super.onStatistics,
    required super.onLifecycleTap,
    super.description,
    super.reminderSummary,
    super.hasReminder,
    super.accentColor,
    super.lifecycleLabel,
    super.lifecycleDescription,
    super.planLinkSummary,
    super.planLinkUnavailable,
    super.skippedToday,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _HabitRowCompatibilityText extends StatelessWidget {
  const _HabitRowCompatibilityText({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          height: 1,
          child: Text(
            '$emoji $name',
            maxLines: 1,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 1,
              height: 1,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyRhythmStrip extends StatelessWidget {
  const _WeeklyRhythmStrip({required this.items, required this.accentColor});

  final List<ActivityStripItem> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ActivityStrip(
      items: items,
      accentColor: accentColor,
      cellHeight: 7,
      cellBorderRadius: AppThemeTokens.radiusPill,
      spacing: 5,
    );
  }
}

class _HabitInsightPreview extends StatelessWidget {
  const _HabitInsightPreview({
    required this.remainingCount,
    required this.totalCheckInsToday,
    required this.activeCount,
  });

  final int remainingCount;
  final int totalCheckInsToday;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _InsightPill(
            label: '待完成',
            value: '$remainingCount',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppThemeTokens.spaceSm),
        Expanded(
          child: _InsightPill(
            label: '今日打卡',
            value: '$totalCheckInsToday',
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: AppThemeTokens.spaceSm),
        Expanded(
          child: _InsightPill(
            label: '活跃习惯',
            value: '$activeCount',
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color.lerp(
          AppThemeTokens.softSurfaceTone(colorScheme),
          color,
          0.06,
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordPreview extends StatelessWidget {
  const _RecentRecordPreview({required this.items});

  final List<_HabitRecordPreviewItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(
          colorScheme,
        ).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近记录',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          for (final item in items) ...[
            _RecentRecordRow(item: item),
            if (item != items.last) const Divider(height: 16),
          ],
        ],
      ),
    );
  }
}

class _RecentRecordRow extends StatelessWidget {
  const _RecentRecordRow({required this.item});

  final _HabitRecordPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _habitAccentColor(item.habit) ?? colorScheme.primary;
    final note = item.record.note?.trim();

    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppThemeTokens.spaceSm),
        Expanded(
          child: Text(
            '${item.habit.name} · ${item.record.localDate} · ${_recordTypeLabel(item.record.type)}'
            '${note == null || note.isEmpty ? '' : ' · $note'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitOrb extends StatelessWidget {
  const _HabitOrb({required this.emoji, required this.color});

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 15)),
    );
  }
}

class _HabitStatePill extends StatelessWidget {
  const _HabitStatePill({
    required this.label,
    required this.color,
    required this.quiet,
  });

  final String label;
  final Color color;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: quiet ? 0.045 : 0.11),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          height: 1,
        ),
      ),
    );
  }
}

class _HabitMetaChip extends StatelessWidget {
  const _HabitMetaChip({
    required this.label,
    required this.icon,
    required this.color,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final child = InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: color.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color.withValues(alpha: 0.72)),
            const SizedBox(width: 3),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (tooltip == null) {
      return child;
    }
    return Tooltip(message: tooltip!, child: child);
  }
}

class _HabitRecordPreviewItem {
  const _HabitRecordPreviewItem({required this.habit, required this.record});

  final HabitItem habit;
  final HabitRecord record;
}

class _HabitLifecycleActionSheet extends StatelessWidget {
  const _HabitLifecycleActionSheet({
    required this.habit,
    required this.habitsStore,
    required this.goalsStore,
  });

  final HabitItem habit;
  final HabitsStore habitsStore;
  final GoalsStore? goalsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          AppThemeTokens.spaceSm,
          AppThemeTokens.pagePadding,
          AppThemeTokens.pagePadding,
        ),
        child: Column(
          key: ValueKey<String>('habit-lifecycle-sheet-${habit.id}'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '管理习惯状态',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceXs),
            Text(
              '${habit.emoji} ${habit.name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            if (habit.isActive) ...[
              _LifecycleActionTile(
                key: ValueKey<String>('habit-lifecycle-pause-${habit.id}'),
                icon: Icons.pause_circle_outline_rounded,
                title: '暂停',
                subtitle: '暂时不进入今日要求，提醒会暂停。',
                onTap: () => _runLifecycleAction(
                  context,
                  habitsStore.pauseHabit(habit.id),
                ),
              ),
              _LifecycleActionTile(
                key: ValueKey<String>('habit-lifecycle-archive-${habit.id}'),
                icon: Icons.inventory_2_outlined,
                title: '归档',
                subtitle: '从日常列表隐藏，历史记录继续保留。',
                onTap: () => _runLifecycleAction(
                  context,
                  habitsStore.archiveHabit(habit.id),
                ),
              ),
            ],
            if (habit.isPaused || habit.isArchived) ...[
              _LifecycleActionTile(
                key: ValueKey<String>('habit-lifecycle-restore-${habit.id}'),
                icon: Icons.restore_rounded,
                title: '恢复',
                subtitle: '重新回到日常列表，并按原提醒设置同步。',
                onTap: () => _runLifecycleAction(
                  context,
                  habitsStore.restoreHabit(habit.id),
                ),
              ),
              if (habit.isPaused)
                _LifecycleActionTile(
                  key: ValueKey<String>('habit-lifecycle-archive-${habit.id}'),
                  icon: Icons.inventory_2_outlined,
                  title: '归档',
                  subtitle: '从日常列表隐藏，历史记录继续保留。',
                  onTap: () => _runLifecycleAction(
                    context,
                    habitsStore.archiveHabit(habit.id),
                  ),
                ),
            ],
            if (goalsStore != null)
              _LifecycleActionTile(
                key: ValueKey<String>('habit-plan-link-action-${habit.id}'),
                icon: Icons.account_tree_outlined,
                title: '关联计划',
                subtitle:
                    _habitPlanLinkSummary(habit, goalsStore) ??
                    '达成每日目标时生成计划记录，不会自动完成行动。',
                onTap: () => _showPlanLinkPicker(context),
              ),
            _LifecycleActionTile(
              key: ValueKey<String>('habit-lifecycle-delete-${habit.id}'),
              icon: Icons.delete_outline_rounded,
              title: '删除',
              subtitle: '从日常列表隐藏，历史记录暂时保留。',
              destructive: true,
              onTap: () => _confirmSoftDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlanLinkPicker(BuildContext context) async {
    final store = goalsStore;
    if (store == null) {
      return;
    }

    final selection = await showModalBottomSheet<_HabitPlanLinkSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HabitPlanLinkSheet(habit: habit, goalsStore: store),
    );

    if (selection == null) {
      return;
    }

    await habitsStore.updateHabitPlanLink(habit.id, selection.planLink);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _runLifecycleAction(
    BuildContext context,
    Future<bool> action,
  ) async {
    await action;
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmSoftDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除习惯'),
        content: const Text('将从日常列表隐藏，历史记录暂时保留。'),
        actions: [
          TextButton(
            key: const ValueKey('habit-soft-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.tonal(
            key: ValueKey<String>('habit-soft-delete-confirm-${habit.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await habitsStore.softDeleteHabit(habit.id, confirmed: true);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _HabitPlanLinkSelection {
  const _HabitPlanLinkSelection(this.planLink);

  final HabitPlanLink? planLink;
}

class _HabitPlanLinkSheet extends StatelessWidget {
  const _HabitPlanLinkSheet({required this.habit, required this.goalsStore});

  final HabitItem habit;
  final GoalsStore goalsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final projects = goalsStore.projects;
    final tasks = goalsStore.tasks;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          AppThemeTokens.spaceSm,
          AppThemeTokens.pagePadding,
          AppThemeTokens.pagePadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                '关联计划',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceXs),
              Text(
                '达成每日目标时，会生成计划记录，不会自动完成行动。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              if (habit.planLink != null)
                ListTile(
                  key: ValueKey<String>('habit-plan-link-clear-${habit.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link_off_rounded),
                  title: const Text('清除关联'),
                  subtitle: const Text('历史生成的计划记录会保留。'),
                  onTap: () => Navigator.of(
                    context,
                  ).pop(const _HabitPlanLinkSelection(null)),
                ),
              if (projects.isEmpty && tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppThemeTokens.spaceLg,
                  ),
                  child: Text(
                    '还没有可关联的项目或行动。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                )
              else ...[
                _HabitPlanLinkSectionLabel(label: '项目'),
                for (final project in projects)
                  _HabitPlanLinkTile(
                    key: ValueKey<String>(
                      'habit-plan-link-project-${project.id}',
                    ),
                    icon: Icons.folder_copy_outlined,
                    title: project.title,
                    subtitle: _projectLinkContext(project),
                    onTap: () => Navigator.of(context).pop(
                      _HabitPlanLinkSelection(
                        HabitPlanLink(
                          targetType: HabitPlanLinkTargetType.project,
                          projectId: project.id,
                          titleSnapshot: project.title,
                          contextSnapshot: _projectLinkContext(project),
                          createdAt: DateTime.now().toUtc(),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppThemeTokens.spaceSm),
                _HabitPlanLinkSectionLabel(label: '行动'),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppThemeTokens.spaceSm,
                    ),
                    child: Text(
                      '暂无行动可关联。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                      ),
                    ),
                  )
                else
                  for (final task in tasks)
                    _HabitPlanLinkTile(
                      key: ValueKey<String>('habit-plan-link-task-${task.id}'),
                      icon: Icons.task_alt_outlined,
                      title: task.title,
                      subtitle: _taskLinkContext(task),
                      onTap: () => Navigator.of(context).pop(
                        _HabitPlanLinkSelection(
                          HabitPlanLink(
                            targetType: HabitPlanLinkTargetType.task,
                            projectId: task.projectId,
                            taskId: task.id,
                            titleSnapshot: task.title,
                            contextSnapshot: _taskLinkContext(task),
                            createdAt: DateTime.now().toUtc(),
                          ),
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

  String _projectLinkContext(ProjectItem project) {
    final goal = goalsStore.goalById(project.goalId);
    return goal == null ? '项目' : '${goal.title} / 项目';
  }

  String _taskLinkContext(GoalTaskItem task) {
    final project = goalsStore.projectById(task.projectId);
    final subproject = task.subprojectId == null
        ? null
        : goalsStore.subprojectById(task.subprojectId!);
    final parts = <String>[
      if (project != null) project.title,
      if (subproject != null) subproject.title,
      '行动',
    ];
    return parts.join(' / ');
  }
}

class _HabitPlanLinkSectionLabel extends StatelessWidget {
  const _HabitPlanLinkSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppThemeTokens.spaceSm,
        bottom: AppThemeTokens.spaceXs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HabitPlanLinkTile extends StatelessWidget {
  const _HabitPlanLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _LifecycleActionTile extends StatelessWidget {
  const _LifecycleActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = destructive
        ? colorScheme.error
        : AppThemeTokens.secondaryTextTone(colorScheme);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: destructive ? colorScheme.error : null,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

List<ActivityStripItem> _recentActivityItems({
  required String habitId,
  required List<HabitActivityDay> activity,
  required int targetCount,
}) {
  return [
    for (var index = 0; index < activity.length; index += 1)
      ActivityStripItem(
        count: activity[index].count,
        label: _dayNumberLabel(activity[index].localDate),
        labelEmphasized: activity[index].count >= targetCount,
        cellKey: ValueKey<String>(
          'habit-activity-$habitId-$index-level-'
          '${activityIntensityLevel(activity[index].count)}',
        ),
        semanticLabel: '第 ${index + 1} 天打卡 ${activity[index].count} 次',
      ),
  ];
}

List<int> _weeklyHabitCounts(HabitsStore habitsStore, List<HabitItem> habits) {
  final today = _parseLocalDate(habitsStore.currentDayKey);
  return [
    for (var index = 6; index >= 0; index -= 1)
      habits.fold<int>(
        0,
        (total, habit) =>
            total +
            habitsStore.activityCountOn(
              habit,
              _localDateKey(today.subtract(Duration(days: index))),
            ),
      ),
  ];
}

int _habitNumericId(HabitItem habit) {
  final match = RegExp(r'^habit-(\d+)$').firstMatch(habit.id);
  return match == null ? -1 : int.tryParse(match.group(1)!) ?? -1;
}

int _compareHabitDisplayOrder(HabitItem a, HabitItem b) {
  final aId = _habitNumericId(a);
  final bId = _habitNumericId(b);
  final aLooksUserCreated = aId > 3;
  final bLooksUserCreated = bId > 3;
  if (aLooksUserCreated != bLooksUserCreated) {
    return aLooksUserCreated ? -1 : 1;
  }

  if (aLooksUserCreated && bLooksUserCreated) {
    final createdComparison = b.createdAt.compareTo(a.createdAt);
    if (createdComparison != 0) {
      return createdComparison;
    }
    return bId.compareTo(aId);
  }

  if (aId >= 0 && bId >= 0 && aId != bId) {
    return aId.compareTo(bId);
  }

  return a.createdAt.compareTo(b.createdAt);
}

List<_HabitRecordPreviewItem> _recentRecordPreviews(
  HabitsStore habitsStore,
  List<HabitItem> habits,
) {
  final previews = <_HabitRecordPreviewItem>[];
  for (final habit in habits) {
    for (final record in habitsStore.recordsForHabit(habit)) {
      previews.add(_HabitRecordPreviewItem(habit: habit, record: record));
    }
  }
  previews.sort((a, b) => b.record.createdAt.compareTo(a.record.createdAt));
  return previews.take(3).toList(growable: false);
}

TextStyle? _habitMono(
  ThemeData theme,
  Color color, {
  double fontSize = 9,
}) {
  return theme.textTheme.labelSmall?.copyWith(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
    height: 1,
  );
}

ButtonStyle _compactHabitActionStyle(BuildContext context) {
  return TextButton.styleFrom(
    minimumSize: const Size(0, 24),
    padding: const EdgeInsets.symmetric(horizontal: 6),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: Colors.white.withValues(alpha: 0.42),
    textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 8.5,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.3,
    ),
  );
}

Color? _habitAccentColor(HabitItem habit) {
  final habitColorValue = habit.habitColorValue;
  return habitColorValue == null ? null : Color(habitColorValue);
}

String? _habitLifecycleLabel(HabitItem habit) {
  return switch (habit.status) {
    HabitLifecycleStatus.active => null,
    HabitLifecycleStatus.paused => '已暂停',
    HabitLifecycleStatus.archived => '已归档',
    HabitLifecycleStatus.deleted => '已删除',
  };
}

String? _habitLifecycleDescription(HabitItem habit) {
  return switch (habit.status) {
    HabitLifecycleStatus.active => null,
    HabitLifecycleStatus.paused => '不进入今日',
    HabitLifecycleStatus.archived => '历史保留',
    HabitLifecycleStatus.deleted => '历史暂存',
  };
}

String? _habitPlanLinkSummary(HabitItem habit, GoalsStore? goalsStore) {
  final link = habit.planLink;
  if (link == null) {
    return null;
  }
  if (_habitPlanLinkUnavailable(habit, goalsStore)) {
    return '关联目标不可用';
  }

  final title = _resolvedHabitPlanLinkTitle(link, goalsStore);
  final typeLabel = link.targetType == HabitPlanLinkTargetType.task
      ? '行动'
      : '项目';
  return '关联：$typeLabel $title';
}

bool _habitPlanLinkUnavailable(HabitItem habit, GoalsStore? goalsStore) {
  final link = habit.planLink;
  if (link == null || goalsStore == null) {
    return false;
  }

  if (link.targetType == HabitPlanLinkTargetType.project) {
    return goalsStore.projectById(link.projectId) == null;
  }

  final taskId = link.taskId;
  final task = taskId == null ? null : goalsStore.taskById(taskId);
  return task == null || task.projectId != link.projectId;
}

String _resolvedHabitPlanLinkTitle(HabitPlanLink link, GoalsStore? goalsStore) {
  if (goalsStore == null) {
    return link.titleSnapshot;
  }

  return switch (link.targetType) {
    HabitPlanLinkTargetType.project =>
      goalsStore.projectById(link.projectId)?.title ?? link.titleSnapshot,
    HabitPlanLinkTargetType.task =>
      link.taskId == null
          ? link.titleSnapshot
          : goalsStore.taskById(link.taskId!)?.title ?? link.titleSnapshot,
  };
}

class _HabitsListHeader extends StatelessWidget {
  const _HabitsListHeader({
    required this.totalCount,
    required this.completedCount,
    required this.totalCheckInsToday,
  });

  final int totalCount;
  final int completedCount;
  final int totalCheckInsToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '活跃协议 (ACTIVE PROTOCOLS)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _habitMono(
                  theme,
                  Colors.white.withValues(alpha: 0.70),
                  fontSize: 8.5,
                ),
              ),
            ),
            Text(
              '$completedCount/$totalCount',
              style: _habitMono(
                theme,
                const Color(0xFF00E5FF),
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$totalCheckInsToday 次打卡 · 轻触协议继续节奏',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.38),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _HabitsEmptyState extends StatelessWidget {
  const _HabitsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
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
          const SizedBox(height: 12),
          Text('还没有习惯', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '创建第一个习惯后，这里会显示每天的打卡进度。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitRecordSheet extends StatefulWidget {
  const _HabitRecordSheet({
    required this.habit,
    required this.habitsStore,
    required this.attachmentStorage,
    required this.recordsEditable,
    this.initialDateKey,
  });

  final HabitItem habit;
  final HabitsStore habitsStore;
  final HabitRecordAttachmentStorage attachmentStorage;
  final bool recordsEditable;
  final String? initialDateKey;

  @override
  State<_HabitRecordSheet> createState() => _HabitRecordSheetState();
}

class _HabitRecordSheetState extends State<_HabitRecordSheet> {
  late final TextEditingController _noteController;
  final Map<String, TextEditingController> _metricControllers =
      <String, TextEditingController>{};
  late DateTime _selectedDate;
  late HabitRecordType _selectedType;
  String? _feedbackText;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _selectedDate = _parseLocalDate(
      widget.initialDateKey ?? widget.habitsStore.currentDayKey,
    );
    _selectedType = _defaultTypeForDate(_selectedDate);
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (final controller in _metricControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedDateKey = _selectedDateKey;
    final activeTemplates = widget.habitsStore.templatesForHabit(widget.habit);
    _ensureMetricControllers(activeTemplates);
    final selectedDateRecords = widget.habitsStore.recordsForHabitDate(
      widget.habit,
      selectedDateKey,
    );
    final recentRecords = widget.habitsStore
        .recordsForHabit(widget.habit, limit: 8)
        .where((record) => record.localDate != selectedDateKey)
        .toList(growable: false);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final hasEffectiveRecord = _hasEffectiveRecordOnSelectedDate;
    final isFuture = _isSelectedDateFuture;
    final isReadOnly = !widget.recordsEditable;
    final isWarningState =
        isReadOnly ||
        isFuture ||
        (_selectedType == HabitRecordType.skip && hasEffectiveRecord);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        AppThemeTokens.spaceLg,
        AppThemeTokens.pagePadding,
        AppThemeTokens.pagePadding + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          key: ValueKey<String>('habit-record-sheet-${widget.habit.id}'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.habit.emoji, style: theme.textTheme.headlineSmall),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppThemeTokens.spaceXs),
                      Text(
                        '先选择日期和类型，点击保存后才会新增记录。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceLg),
            InkWell(
              key: ValueKey<String>('habit-record-date-${widget.habit.id}'),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
              onTap: isFuture ? null : _pickRecordDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeTokens.spaceLg,
                  vertical: AppThemeTokens.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: AppThemeTokens.softSurfaceTone(colorScheme),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: AppThemeTokens.borderTone(colorScheme),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    Expanded(
                      child: Text(
                        '选中日期 $selectedDateKey',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            Wrap(
              spacing: AppThemeTokens.spaceSm,
              runSpacing: AppThemeTokens.spaceSm,
              children: [
                _RecordTypeChoice(
                  key: ValueKey<String>(
                    'habit-detailed-check-in-${widget.habit.id}',
                  ),
                  label: '详细打卡',
                  selected: _selectedType == HabitRecordType.checkIn,
                  enabled: widget.recordsEditable && _isSelectedDateToday,
                  onSelected: () => _selectType(HabitRecordType.checkIn),
                ),
                _RecordTypeChoice(
                  key: ValueKey<String>('habit-makeup-${widget.habit.id}'),
                  label: '补打',
                  selected: _selectedType == HabitRecordType.makeup,
                  enabled: widget.recordsEditable && !isFuture,
                  onSelected: () => _selectType(HabitRecordType.makeup),
                ),
                _RecordTypeChoice(
                  key: ValueKey<String>('habit-skip-${widget.habit.id}'),
                  label: '跳过',
                  selected: _selectedType == HabitRecordType.skip,
                  enabled:
                      widget.recordsEditable &&
                      !isFuture &&
                      !hasEffectiveRecord,
                  onSelected: () => _selectType(HabitRecordType.skip),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              _recordGuidanceText,
              key: ValueKey<String>('habit-record-guidance-${widget.habit.id}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isWarningState
                    ? colorScheme.error
                    : AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
            if (_feedbackText != null) ...[
              const SizedBox(height: AppThemeTokens.spaceXs),
              Text(
                _feedbackText!,
                key: ValueKey<String>(
                  'habit-record-feedback-${widget.habit.id}',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: AppThemeTokens.spaceMd),
            TextField(
              key: ValueKey<String>(
                'habit-record-note-field-${widget.habit.id}',
              ),
              controller: _noteController,
              enabled: widget.recordsEditable && !isFuture,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '写下状态、原因或感受',
              ),
            ),
            if (activeTemplates.isNotEmpty) ...[
              const SizedBox(height: AppThemeTokens.spaceMd),
              _HabitMetricInputSection(
                templates: activeTemplates,
                controllers: _metricControllers,
                enabled:
                    widget.recordsEditable &&
                    !isFuture &&
                    _selectedType != HabitRecordType.skip,
              ),
            ],
            const SizedBox(height: AppThemeTokens.spaceMd),
            Wrap(
              spacing: AppThemeTokens.spaceSm,
              runSpacing: AppThemeTokens.spaceSm,
              children: [
                FilledButton.icon(
                  key: ValueKey<String>('habit-record-save-${widget.habit.id}'),
                  onPressed: _canSaveRecord ? _saveRecord : null,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('保存记录'),
                ),
                TextButton.icon(
                  key: ValueKey<String>(
                    'habit-record-cancel-${widget.habit.id}',
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('取消'),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceXl),
            Text(
              '这一天',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceXs),
            Text(
              '$selectedDateKey 的记录',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            if (selectedDateRecords.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                decoration: BoxDecoration(
                  color: AppThemeTokens.softSurfaceTone(colorScheme),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: AppThemeTokens.borderTone(colorScheme),
                  ),
                ),
                child: Text(
                  isFuture ? '未来日期暂不能记录。' : '这一天还没有记录。',
                  key: ValueKey<String>(
                    'habit-date-records-empty-${widget.habit.id}',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              )
            else
              Column(
                children: selectedDateRecords
                    .map(
                      (record) => _HabitRecordRow(
                        record: record,
                        attachments: widget.habitsStore.attachmentsForRecord(
                          record.id,
                        ),
                        metrics: widget.habitsStore.metricsForRecord(record.id),
                        attachmentStorage: widget.attachmentStorage,
                        onAttachmentTap: () =>
                            _showRecordAttachmentSheet(record),
                      ),
                    )
                    .toList(growable: false),
              ),
            const SizedBox(height: AppThemeTokens.spaceXl),
            Text(
              '最近记录',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            if (recentRecords.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                decoration: BoxDecoration(
                  color: AppThemeTokens.softSurfaceTone(colorScheme),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: AppThemeTokens.borderTone(colorScheme),
                  ),
                ),
                child: Text(
                  '还没有记录',
                  key: ValueKey<String>(
                    'habit-records-empty-${widget.habit.id}',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              )
            else
              Column(
                children: recentRecords
                    .map(
                      (record) => _HabitRecordRow(
                        record: record,
                        attachments: widget.habitsStore.attachmentsForRecord(
                          record.id,
                        ),
                        metrics: widget.habitsStore.metricsForRecord(record.id),
                        attachmentStorage: widget.attachmentStorage,
                        onAttachmentTap: () =>
                            _showRecordAttachmentSheet(record),
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRecordDate() async {
    final today = _parseLocalDate(widget.habitsStore.currentDayKey);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked == null) {
      return;
    }

    _setSelectedDate(DateTime(picked.year, picked.month, picked.day));
  }

  void _setSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _selectedType = _defaultTypeForDate(_selectedDate);
      _feedbackText = null;
    });
  }

  void _selectType(HabitRecordType type) {
    setState(() {
      _feedbackText = null;
      if (type == HabitRecordType.makeup && _isSelectedDateToday) {
        _selectedDate = _yesterdayFromStoreClock();
      }
      _selectedType = type;
    });
  }

  void _ensureMetricControllers(List<HabitCheckInTemplate> templates) {
    final activeTemplateIds = templates.map((template) => template.id).toSet();
    for (final template in templates) {
      _metricControllers.putIfAbsent(
        template.id,
        () => TextEditingController(),
      );
    }

    final staleTemplateIds = _metricControllers.keys
        .where((templateId) => !activeTemplateIds.contains(templateId))
        .toList(growable: false);
    for (final templateId in staleTemplateIds) {
      _metricControllers.remove(templateId)?.dispose();
    }
  }

  List<HabitRecordMetricInput>? _metricInputsFromFields() {
    final inputs = <HabitRecordMetricInput>[];
    final templates = widget.habitsStore.templatesForHabit(widget.habit);

    for (final template in templates) {
      final text = _metricControllers[template.id]?.text.trim() ?? '';
      if (text.isEmpty) {
        continue;
      }
      final value = double.tryParse(text);
      if (value == null || !value.isFinite || value <= 0) {
        return null;
      }
      inputs.add(
        HabitRecordMetricInput(templateId: template.id, numericValue: value),
      );
    }

    return inputs;
  }

  Future<void> _saveRecord() async {
    var saved = false;
    final metricInputs = _selectedType == HabitRecordType.skip
        ? const <HabitRecordMetricInput>[]
        : _metricInputsFromFields();
    if (metricInputs == null) {
      setState(() {
        _feedbackText = '数值项目需要填写有效数字';
      });
      return;
    }
    switch (_selectedType) {
      case HabitRecordType.checkIn:
        if (_isSelectedDateToday) {
          await widget.habitsStore.checkIn(
            widget.habit.id,
            note: _noteText,
            metricInputs: metricInputs,
          );
          saved = true;
        }
        break;
      case HabitRecordType.makeup:
        saved = await widget.habitsStore.makeupCheckIn(
          widget.habit.id,
          localDate: _selectedDateKey,
          note: _noteText,
          metricInputs: metricInputs,
        );
        break;
      case HabitRecordType.skip:
        saved = await widget.habitsStore.skipHabit(
          widget.habit.id,
          localDate: _selectedDateKey,
          note: _noteText,
        );
        break;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (saved) {
        _noteController.clear();
        for (final controller in _metricControllers.values) {
          controller.clear();
        }
        _feedbackText = '已保存 ${_recordTypeLabel(_selectedType)}。';
      } else {
        _feedbackText = _blockedSaveText;
      }
    });
  }

  HabitRecordType _defaultTypeForDate(DateTime date) {
    final dateKey = _localDateKey(date);
    if (dateKey.compareTo(widget.habitsStore.currentDayKey) < 0) {
      return HabitRecordType.makeup;
    }
    return HabitRecordType.checkIn;
  }

  DateTime _yesterdayFromStoreClock() {
    return _parseLocalDate(
      widget.habitsStore.currentDayKey,
    ).subtract(const Duration(days: 1));
  }

  bool get _canSaveRecord {
    if (!widget.recordsEditable) {
      return false;
    }

    if (_isSelectedDateFuture) {
      return false;
    }

    switch (_selectedType) {
      case HabitRecordType.checkIn:
        return _isSelectedDateToday;
      case HabitRecordType.makeup:
        return _isSelectedDatePast;
      case HabitRecordType.skip:
        return !_hasEffectiveRecordOnSelectedDate;
    }
  }

  String get _recordGuidanceText {
    if (!widget.recordsEditable) {
      return '此习惯已暂停或归档，恢复后才能新增记录。';
    }

    if (_isSelectedDateFuture) {
      return '未来日期暂不能记录。';
    }
    if (_hasEffectiveRecordOnSelectedDate) {
      return _isSelectedDateToday
          ? '这一天已有打卡；可继续详细打卡，不能标记跳过。'
          : '这一天已有打卡；可继续补打，不能标记跳过。';
    }
    if (_selectedType == HabitRecordType.makeup) {
      return '补打会记录到选中的过去日期，不影响今天。';
    }
    if (_selectedType == HabitRecordType.skip) {
      return '跳过表示这一天有意不做，不计入完成。';
    }
    return '详细打卡会在点击保存后创建记录；取消不会保存。';
  }

  String get _blockedSaveText {
    if (!widget.recordsEditable) {
      return '恢复习惯后才能新增记录。';
    }

    if (_isSelectedDateFuture) {
      return '未来日期暂不能记录。';
    }
    if (_selectedType == HabitRecordType.makeup && _isSelectedDateToday) {
      return '今天请使用“打卡”或“详细打卡”。';
    }
    if (_selectedType == HabitRecordType.skip &&
        _hasEffectiveRecordOnSelectedDate) {
      return '这一天已有打卡，不能标记跳过。';
    }
    return '这条记录暂时不能保存。';
  }

  String get _selectedDateKey => _localDateKey(_selectedDate);

  bool get _isSelectedDateToday =>
      _selectedDateKey == widget.habitsStore.currentDayKey;

  bool get _isSelectedDatePast =>
      _selectedDateKey.compareTo(widget.habitsStore.currentDayKey) < 0;

  bool get _isSelectedDateFuture =>
      _selectedDateKey.compareTo(widget.habitsStore.currentDayKey) > 0;

  bool get _hasEffectiveRecordOnSelectedDate {
    return widget.habitsStore.activityCountOn(widget.habit, _selectedDateKey) >
        0;
  }

  String? get _noteText {
    final text = _noteController.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _showRecordAttachmentSheet(HabitRecord record) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HabitRecordAttachmentSheet(
        record: record,
        habitsStore: widget.habitsStore,
        attachmentStorage: widget.attachmentStorage,
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
}

class _HabitMetricInputSection extends StatelessWidget {
  const _HabitMetricInputSection({
    required this.templates,
    required this.controllers,
    required this.enabled,
  });

  final List<HabitCheckInTemplate> templates;
  final Map<String, TextEditingController> controllers;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!enabled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        decoration: BoxDecoration(
          color: AppThemeTokens.softSurfaceTone(colorScheme),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
        ),
        child: Text(
          '跳过不会记录项目数值。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数值项目',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceXs),
        Text(
          '可选填写，空着不会保存。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        ...templates.map(
          (template) => Padding(
            padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
            child: _HabitMetricInputRow(
              template: template,
              controller: controllers[template.id]!,
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitMetricInputRow extends StatelessWidget {
  const _HabitMetricInputRow({
    required this.template,
    required this.controller,
  });

  final HabitCheckInTemplate template;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              template.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppThemeTokens.spaceSm),
          SizedBox(
            width: 96,
            child: TextField(
              key: ValueKey<String>('habit-metric-input-${template.id}'),
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: template.defaultValue == null
                    ? '0'
                    : _formatMetricValue(template.defaultValue!),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppThemeTokens.spaceSm),
          Flexible(
            child: Text(
              template.unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTypeChoice extends StatelessWidget {
  const _RecordTypeChoice({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onSelected() : null,
      showCheckmark: false,
    );
  }
}

class _HabitStatisticsSheet extends StatelessWidget {
  const _HabitStatisticsSheet({
    required this.habit,
    required this.habitsStore,
    required this.attachmentStorage,
    required this.accentColor,
  });

  final HabitItem habit;
  final HabitsStore habitsStore;
  final HabitRecordAttachmentStorage attachmentStorage;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccentColor = accentColor ?? colorScheme.primary;
    final summary = habitsStore.statisticsForHabit(habit);
    final annualActivity = habitsStore.currentYearActivity(habit);
    final recentMonths = habitsStore.recentActivityMonths(habit);
    final recordGroups = habitsStore.recordDateGroupsForHabit(habit);
    final metricSummary = habitsStore.metricSummaryForHabit(habit);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          0,
          AppThemeTokens.pagePadding,
          AppThemeTokens.pagePadding + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            key: ValueKey<String>('habit-statistics-sheet-${habit.id}'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.emoji, style: theme.textTheme.headlineSmall),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: AppThemeTokens.spaceXs),
                        Text(
                          habit.description.isEmpty
                              ? '每日目标 ${habit.targetCountPerDay} 次'
                              : '${habit.description} · 每日目标 ${habit.targetCountPerDay} 次',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppThemeTokens.secondaryTextTone(
                              colorScheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),
              MetricStrip(
                tileWidth: 104,
                tileBackgroundColor: effectiveAccentColor.withValues(
                  alpha: 0.08,
                ),
                tileBorderColor: effectiveAccentColor.withValues(alpha: 0.16),
                metrics: [
                  MetricTileData(
                    value: '${summary.completedDays}',
                    label: '完成天',
                    valueKey: 'habit-stats-completed-days-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.currentStreakDays}',
                    label: '连续天数',
                    valueKey: 'habit-stats-current-streak-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.longestStreakDays}',
                    label: '最长连续',
                    valueKey: 'habit-stats-longest-streak-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.effectiveCheckInCount}',
                    label: '有效打卡',
                    valueKey: 'habit-stats-effective-check-ins-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.skipCount}',
                    label: '跳过',
                    valueKey: 'habit-stats-skips-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.makeupCount}',
                    label: '补打',
                    valueKey: 'habit-stats-makeups-${habit.id}',
                  ),
                  MetricTileData(
                    value: '${summary.proofCount}',
                    label: '图片数',
                    valueKey: 'habit-stats-proofs-${habit.id}',
                  ),
                  MetricTileData(
                    value: _completionRateLabel(summary),
                    label: '记录日达标率',
                    valueKey: 'habit-stats-completion-rate-${habit.id}',
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _StreakProtectionNote(
                habitId: habit.id,
                pauseProtectedDays: summary.pauseProtectedDays,
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _HabitCompletionDistributionPanel(
                habitId: habit.id,
                summary: summary,
                accentColor: effectiveAccentColor,
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _HabitMetricSummaryPanel(
                habitId: habit.id,
                metricSummary: metricSummary,
                accentColor: effectiveAccentColor,
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _AnnualActivityPanel(
                habitId: habit.id,
                annualActivity: annualActivity,
                accentColor: accentColor,
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _HabitAnalyticsLegend(accentColor: effectiveAccentColor),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _RecentMonthsActivityPanel(
                habitId: habit.id,
                months: recentMonths,
                summary: summary,
                accentColor: accentColor,
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              Text(
                '记录明细',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              if (recordGroups.isEmpty)
                SoftSurface(
                  padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                  child: Text(
                    '还没有记录',
                    key: ValueKey<String>('habit-stats-empty-${habit.id}'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final group in recordGroups)
                      _HabitRecordDateGroupSection(
                        habitId: habit.id,
                        group: group,
                        habitsStore: habitsStore,
                        attachmentStorage: attachmentStorage,
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

class _StreakProtectionNote extends StatelessWidget {
  const _StreakProtectionNote({
    required this.habitId,
    required this.pauseProtectedDays,
  });

  final String habitId;
  final int pauseProtectedDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      key: ValueKey<String>('habit-streak-protection-note-$habitId'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      backgroundColor: AppThemeTokens.softSurfaceTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '连续天数按达标日期计算',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            pauseProtectedDays > 0
                ? '暂停期间不计入连续天数 · 已保护 $pauseProtectedDays 天'
                : '暂停期间不计入连续天数',
            key: ValueKey<String>('habit-streak-pause-copy-$habitId'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '跳过不会算作达标',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCompletionDistributionPanel extends StatelessWidget {
  const _HabitCompletionDistributionPanel({
    required this.habitId,
    required this.summary,
    required this.accentColor,
  });

  final String habitId;
  final HabitStatisticsSummary summary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      key: ValueKey<String>('habit-completion-distribution-$habitId'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      borderColor: accentColor.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '完成分布',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '基于已有记录日期统计，不把未记录日期当作失败。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          MetricStrip(
            tileWidth: 92,
            tileBackgroundColor: accentColor.withValues(alpha: 0.07),
            tileBorderColor: accentColor.withValues(alpha: 0.14),
            metrics: [
              MetricTileData(
                value: '${summary.completedDays}',
                label: '完成天',
                valueKey: 'habit-distribution-completed-days-$habitId',
              ),
              MetricTileData(
                value: '${summary.activeDays}',
                label: '活跃天',
                valueKey: 'habit-distribution-active-days-$habitId',
              ),
              MetricTileData(
                value: '${summary.trackedDays}',
                label: '记录天',
                valueKey: 'habit-distribution-tracked-days-$habitId',
              ),
              MetricTileData(
                value: '${summary.skipDays}',
                label: '跳过天',
                valueKey: 'habit-distribution-skip-days-$habitId',
              ),
              MetricTileData(
                value: '${summary.proofDays}',
                label: '图片证明天',
                valueKey: 'habit-distribution-proof-days-$habitId',
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceLg),
          AnalyticsBarList(
            key: ValueKey<String>('habit-distribution-bars-$habitId'),
            accentColor: accentColor,
            maxValue: summary.trackedDays,
            emptyText: '还没有可视化的记录分布。',
            items: [
              AnalyticsBarListItem(
                label: '完成天',
                value: summary.completedDays,
                valueKey: 'habit-distribution-bar-completed-days-$habitId',
              ),
              AnalyticsBarListItem(
                label: '活跃天',
                value: summary.activeDays,
                color: accentColor.withValues(alpha: 0.72),
                valueKey: 'habit-distribution-bar-active-days-$habitId',
              ),
              AnalyticsBarListItem(
                label: '跳过天',
                value: summary.skipDays,
                color: colorScheme.tertiary,
                valueKey: 'habit-distribution-bar-skip-days-$habitId',
              ),
              AnalyticsBarListItem(
                label: '图片证明天',
                value: summary.proofDays,
                color: colorScheme.secondary,
                valueKey: 'habit-distribution-bar-proof-days-$habitId',
              ),
              AnalyticsBarListItem(
                label: '记录天',
                value: summary.trackedDays,
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                valueKey: 'habit-distribution-bar-tracked-days-$habitId',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitMetricSummaryPanel extends StatelessWidget {
  const _HabitMetricSummaryPanel({
    required this.habitId,
    required this.metricSummary,
    required this.accentColor,
  });

  final String habitId;
  final HabitMetricSummary metricSummary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      key: ValueKey<String>('habit-metric-summary-$habitId'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      borderColor: accentColor.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数值记录',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '只汇总详细打卡里真实填写的项目，不影响达标、热力图或连续天数。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          if (!metricSummary.hasMetrics)
            Text(
              '还没有数值项目记录。',
              key: ValueKey<String>('habit-metric-summary-empty-$habitId'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            )
          else ...[
            Text(
              '项目合计',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Wrap(
              spacing: AppThemeTokens.spaceSm,
              runSpacing: AppThemeTokens.spaceSm,
              children: [
                for (final total in metricSummary.totals)
                  _MetricTotalPill(
                    total: total,
                    accentColor: accentColor,
                    valueKey:
                        'habit-metric-total-$habitId-${total.title}-${total.unit}',
                  ),
              ],
            ),
            if (metricSummary.recentEntries.isNotEmpty) ...[
              const SizedBox(height: AppThemeTokens.spaceLg),
              Text(
                '最近记录',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              for (final entry in metricSummary.recentEntries)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppThemeTokens.spaceXs,
                  ),
                  child: _MetricRecentRow(entry: entry),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MetricTotalPill extends StatelessWidget {
  const _MetricTotalPill({
    required this.total,
    required this.accentColor,
    required this.valueKey,
  });

  final HabitMetricTotal total;
  final Color accentColor;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: ValueKey<String>(valueKey),
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceMd,
        vertical: AppThemeTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        '${total.title}：${_formatMetricValue(total.total)} ${total.unit}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetricRecentRow extends StatelessWidget {
  const _MetricRecentRow({required this.entry});

  final HabitMetricRecordEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metric = entry.metric;

    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            entry.record.localDate,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppThemeTokens.spaceSm),
        Expanded(
          child: Text(
            '${metric.titleSnapshot} ${_formatMetricValue(metric.numericValue)} ${metric.unitSnapshot}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitAnalyticsLegend extends StatelessWidget {
  const _HabitAnalyticsLegend({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      borderColor: AppThemeTokens.borderTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '图例',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Wrap(
            spacing: AppThemeTokens.spaceSm,
            runSpacing: AppThemeTokens.spaceSm,
            children: [
              _HabitAnalyticsLegendPill(
                icon: Icons.check_circle_outline_rounded,
                label: '打卡',
                color: accentColor,
              ),
              _HabitAnalyticsLegendPill(
                icon: Icons.replay_circle_filled_outlined,
                label: '补打',
                color: accentColor,
              ),
              _HabitAnalyticsLegendPill(
                icon: Icons.remove_circle_outline_rounded,
                label: '跳过',
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
              _HabitAnalyticsLegendPill(
                icon: Icons.notes_rounded,
                label: '备注',
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
              _HabitAnalyticsLegendPill(
                icon: Icons.image_outlined,
                label: '图片证明',
                color: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitAnalyticsLegendPill extends StatelessWidget {
  const _HabitAnalyticsLegendPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceSm,
        vertical: AppThemeTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppThemeTokens.spaceXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnualActivityPanel extends StatelessWidget {
  const _AnnualActivityPanel({
    required this.habitId,
    required this.annualActivity,
    required this.accentColor,
  });

  final String habitId;
  final HabitAnnualActivity annualActivity;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccentColor = accentColor ?? colorScheme.primary;
    final activeCount = annualActivity.days.fold<int>(
      0,
      (sum, day) => sum + day.count,
    );
    final activeDays = annualActivity.days.where((day) => day.count > 0).length;

    return SoftSurface(
      key: ValueKey<String>('habit-annual-activity-$habitId'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      borderColor: effectiveAccentColor.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '年度活动',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$activeCount 次 · $activeDays 天',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '当前年份只统计打卡和补打；空白日期不被自动判断为失败。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '月份以 1-12 标记；横向滑动查看全年节奏。',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          _HeatmapLegend(accentColor: accentColor),
          const SizedBox(height: AppThemeTokens.spaceMd),
          _AnnualActivityGrid(
            habitId: habitId,
            annualActivity: annualActivity,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _AnnualActivityGrid extends StatelessWidget {
  const _AnnualActivityGrid({
    required this.habitId,
    required this.annualActivity,
    required this.accentColor,
  });

  static const double _cellSize = 10;
  static const double _cellGap = 3;

  final String habitId;
  final HabitAnnualActivity annualActivity;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final leadingEmptyCells = DateTime(annualActivity.year).weekday - 1;
    final totalCells = leadingEmptyCells + annualActivity.days.length;
    final weekCount = (totalCells / 7).ceil();

    return SingleChildScrollView(
      key: ValueKey<String>('habit-annual-scroll-$habitId'),
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnnualMonthMarkerRow(
            year: annualActivity.year,
            leadingEmptyCells: leadingEmptyCells,
            weekCount: weekCount,
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var week = 0; week < weekCount; week += 1) ...[
                Column(
                  children: [
                    for (var weekday = 0; weekday < 7; weekday += 1) ...[
                      _buildDayCell(week * 7 + weekday - leadingEmptyCells),
                      if (weekday != 6) const SizedBox(height: _cellGap),
                    ],
                  ],
                ),
                if (week != weekCount - 1) const SizedBox(width: _cellGap),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= annualActivity.days.length) {
      return const SizedBox(width: _cellSize, height: _cellSize);
    }

    final day = annualActivity.days[dayIndex];
    final level = activityIntensityLevel(day.count);

    return SizedBox(
      key: ValueKey<String>(
        'habit-annual-cell-$habitId-${day.localDate}-level-$level',
      ),
      width: _cellSize,
      height: _cellSize,
      child: MiniHeatmapCell(
        count: day.count,
        height: _cellSize,
        borderRadius: 3,
        accentColor: accentColor,
        semanticLabel: '${day.localDate} 打卡 ${day.count} 次',
      ),
    );
  }
}

class _AnnualMonthMarkerRow extends StatelessWidget {
  const _AnnualMonthMarkerRow({
    required this.year,
    required this.leadingEmptyCells,
    required this.weekCount,
  });

  static const double _cellSize = _AnnualActivityGrid._cellSize;
  static const double _cellGap = _AnnualActivityGrid._cellGap;

  final int year;
  final int leadingEmptyCells;
  final int weekCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final markers = <int, int>{};
    for (var month = 1; month <= 12; month += 1) {
      final dayOfYear = DateTime(year, month).difference(DateTime(year)).inDays;
      final weekIndex = ((leadingEmptyCells + dayOfYear) / 7).floor();
      markers[weekIndex] = month;
    }

    return Row(
      children: [
        for (var week = 0; week < weekCount; week += 1) ...[
          SizedBox(
            width: _cellSize,
            child: Text(
              _monthMarkerLabel(markers[week]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          if (week != weekCount - 1) const SizedBox(width: _cellGap),
        ],
      ],
    );
  }

  String _monthMarkerLabel(int? month) => month == null ? '' : '$month';
}

class _RecentMonthsActivityPanel extends StatelessWidget {
  const _RecentMonthsActivityPanel({
    required this.habitId,
    required this.months,
    required this.summary,
    required this.accentColor,
  });

  final String habitId;
  final List<HabitActivityMonth> months;
  final HabitStatisticsSummary summary;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccentColor = accentColor ?? colorScheme.primary;

    return SoftSurface(
      key: ValueKey<String>('habit-analytics-recent-months-$habitId'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      borderColor: effectiveAccentColor.withValues(alpha: 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '近 3 个月活动',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${summary.currentMonthEffectiveCheckInCount} 次 · '
                '${summary.currentMonthActiveDays} 天',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            '只统计打卡和补打；跳过、备注、图片证明不会提高热力。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          _HeatmapLegend(accentColor: accentColor),
          for (final month in months) ...[
            const SizedBox(height: AppThemeTokens.spaceLg),
            _CompactMonthActivityBlock(
              habitId: habitId,
              monthActivity: month,
              accentColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactMonthActivityBlock extends StatelessWidget {
  const _CompactMonthActivityBlock({
    required this.habitId,
    required this.monthActivity,
    required this.accentColor,
  });

  final String habitId;
  final HabitActivityMonth monthActivity;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeCount = monthActivity.days.fold<int>(
      0,
      (sum, day) => sum + day.count,
    );
    final activeDays = monthActivity.days.where((day) => day.count > 0).length;

    return Column(
      key: ValueKey<String>(
        'habit-analytics-month-$habitId-${monthActivity.year}-${monthActivity.month.toString().padLeft(2, '0')}',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${monthActivity.year}年${monthActivity.month}月',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$activeCount 次 · $activeDays 天',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        const _WeekdayHeader(),
        const SizedBox(height: AppThemeTokens.spaceXs),
        _MonthActivityGrid(
          habitId: habitId,
          leadingEmptyCells:
              DateTime(monthActivity.year, monthActivity.month).weekday - 1,
          days: monthActivity.days,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _HabitRecordDateGroupSection extends StatelessWidget {
  const _HabitRecordDateGroupSection({
    required this.habitId,
    required this.group,
    required this.habitsStore,
    required this.attachmentStorage,
  });

  final String habitId;
  final HabitRecordDateGroup group;
  final HabitsStore habitsStore;
  final HabitRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveCount = group.records
        .where(
          (record) =>
              record.type == HabitRecordType.checkIn ||
              record.type == HabitRecordType.makeup,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
      child: SoftSurface(
        key: ValueKey<String>(
          'habit-record-date-group-$habitId-${group.localDate}',
        ),
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.localDate,
                    key: ValueKey<String>(
                      'habit-record-date-title-$habitId-${group.localDate}',
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '$effectiveCount 次有效 · ${group.records.length} 条记录',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            for (final record in group.records)
              _HabitStatisticsRecordRow(
                record: record,
                attachments: habitsStore.attachmentsForRecord(record.id),
                metrics: habitsStore.metricsForRecord(record.id),
                attachmentStorage: attachmentStorage,
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitStatisticsRecordRow extends StatelessWidget {
  const _HabitStatisticsRecordRow({
    required this.record,
    required this.attachments,
    required this.metrics,
    required this.attachmentStorage,
  });

  final HabitRecord record;
  final List<HabitRecordAttachment> attachments;
  final List<HabitRecordMetric> metrics;
  final HabitRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompletion =
        record.type == HabitRecordType.checkIn ||
        record.type == HabitRecordType.makeup;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceXs),
      child: Row(
        key: ValueKey<String>('habit-stat-record-row-${record.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _recordTypeIcon(record.type),
            size: 18,
            color: isCompletion
                ? colorScheme.primary
                : AppThemeTokens.secondaryTextTone(colorScheme),
          ),
          const SizedBox(width: AppThemeTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppThemeTokens.spaceXs,
                  runSpacing: AppThemeTokens.spaceXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _HabitRecordMetaChip(
                      label: _recordTypeLabel(record.type),
                      color: isCompletion
                          ? colorScheme.primary
                          : AppThemeTokens.secondaryTextTone(colorScheme),
                      valueKey: ValueKey<String>(
                        'habit-stat-record-type-${record.id}',
                      ),
                    ),
                    if (record.note != null)
                      _HabitRecordMetaChip(
                        label: '备注',
                        icon: Icons.notes_rounded,
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        valueKey: ValueKey<String>(
                          'habit-stat-record-note-${record.id}',
                        ),
                      ),
                    if (attachments.isNotEmpty)
                      _HabitRecordMetaChip(
                        label: '图片 ${attachments.length}',
                        icon: Icons.image_rounded,
                        color: colorScheme.secondary,
                        valueKey: ValueKey<String>(
                          'habit-stat-record-proof-count-${record.id}',
                        ),
                      ),
                    if (metrics.isNotEmpty)
                      _HabitRecordMetaChip(
                        label: '数值 ${metrics.length}',
                        icon: Icons.functions_rounded,
                        color: colorScheme.primary,
                        valueKey: ValueKey<String>(
                          'habit-stat-record-metric-count-${record.id}',
                        ),
                      ),
                  ],
                ),
                if (record.note != null) ...[
                  const SizedBox(height: AppThemeTokens.spaceXs),
                  Text(
                    '备注：${record.note!}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                ],
                if (metrics.isNotEmpty) ...[
                  const SizedBox(height: AppThemeTokens.spaceXs),
                  Wrap(
                    spacing: AppThemeTokens.spaceXs,
                    runSpacing: AppThemeTokens.spaceXs,
                    children: metrics
                        .map(
                          (metric) => _HabitRecordMetaChip(
                            label:
                                '${metric.titleSnapshot} ${_formatMetricValue(metric.numericValue)} ${metric.unitSnapshot}',
                            color: colorScheme.primary,
                            valueKey: ValueKey<String>(
                              'habit-stat-record-metric-${metric.id}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(width: AppThemeTokens.spaceSm),
            _HabitStatisticsProofPreview(
              recordId: record.id,
              attachments: attachments,
              attachmentStorage: attachmentStorage,
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitRecordMetaChip extends StatelessWidget {
  const _HabitRecordMetaChip({
    required this.label,
    required this.color,
    required this.valueKey,
    this.icon,
  });

  final String label;
  final Color color;
  final Key valueKey;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: valueKey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color == AppThemeTokens.secondaryTextTone(colorScheme)
                  ? AppThemeTokens.secondaryTextTone(colorScheme)
                  : color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitStatisticsProofPreview extends StatelessWidget {
  const _HabitStatisticsProofPreview({
    required this.recordId,
    required this.attachments,
    required this.attachmentStorage,
  });

  final String recordId;
  final List<HabitRecordAttachment> attachments;
  final HabitRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final attachment = attachments.first;
    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        final hasFile = file != null;

        return Container(
          key: ValueKey<String>(
            hasFile
                ? 'habit-stat-proof-thumbnail-$recordId'
                : 'habit-stat-proof-missing-$recordId',
          ),
          width: 38,
          height: 38,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: hasFile
                ? AppThemeTokens.softSurfaceTone(colorScheme)
                : colorScheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            border: Border.all(
              color: hasFile
                  ? colorScheme.primary.withValues(alpha: 0.18)
                  : colorScheme.error.withValues(alpha: 0.22),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasFile
                  ? Image.file(file, fit: BoxFit.cover)
                  : Icon(
                      Icons.broken_image_outlined,
                      size: 18,
                      color: colorScheme.error,
                    ),
              if (attachments.length > 1)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    color: colorScheme.primary.withValues(alpha: 0.82),
                    child: Text(
                      '+${attachments.length - 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _completionRateLabel(HabitStatisticsSummary summary) {
  final rate = summary.completionRate;
  if (rate == null) {
    return '暂无';
  }

  return '${(rate * 100).round()}%';
}

class _HabitRecordRow extends StatelessWidget {
  const _HabitRecordRow({
    required this.record,
    required this.attachments,
    required this.metrics,
    required this.attachmentStorage,
    required this.onAttachmentTap,
  });

  final HabitRecord record;
  final List<HabitRecordAttachment> attachments;
  final List<HabitRecordMetric> metrics;
  final HabitRecordAttachmentStorage attachmentStorage;
  final VoidCallback onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompletion =
        record.type == HabitRecordType.checkIn ||
        record.type == HabitRecordType.makeup;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
      child: Container(
        key: ValueKey<String>('habit-record-row-${record.id}'),
        width: double.infinity,
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        decoration: BoxDecoration(
          color: isCompletion
              ? AppThemeTokens.selectedStateTone(colorScheme)
              : AppThemeTokens.softSurfaceTone(colorScheme),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          border: Border.all(
            color: isCompletion
                ? colorScheme.primary.withValues(alpha: 0.16)
                : AppThemeTokens.borderTone(colorScheme),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _recordTypeIcon(record.type),
              size: 18,
              color: isCompletion
                  ? colorScheme.primary
                  : AppThemeTokens.secondaryTextTone(colorScheme),
            ),
            const SizedBox(width: AppThemeTokens.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.localDate} · ${_recordTypeLabel(record.type)}',
                    key: ValueKey<String>('habit-record-type-${record.id}'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (record.note != null) ...[
                    const SizedBox(height: AppThemeTokens.spaceXs),
                    Text(
                      '备注：${record.note!}',
                      key: ValueKey<String>('habit-record-note-${record.id}'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                      ),
                    ),
                  ],
                  if (metrics.isNotEmpty) ...[
                    const SizedBox(height: AppThemeTokens.spaceXs),
                    Wrap(
                      spacing: AppThemeTokens.spaceXs,
                      runSpacing: AppThemeTokens.spaceXs,
                      children: metrics
                          .map(
                            (metric) => _HabitRecordMetaChip(
                              label:
                                  '${metric.titleSnapshot} ${_formatMetricValue(metric.numericValue)} ${metric.unitSnapshot}',
                              color: colorScheme.primary,
                              valueKey: ValueKey<String>(
                                'habit-record-metric-${metric.id}',
                              ),
                              icon: Icons.functions_rounded,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppThemeTokens.spaceSm),
            _HabitRecordAttachmentEntry(
              record: record,
              attachments: attachments,
              attachmentStorage: attachmentStorage,
              onTap: onAttachmentTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRecordAttachmentEntry extends StatelessWidget {
  const _HabitRecordAttachmentEntry({
    required this.record,
    required this.attachments,
    required this.attachmentStorage,
    required this.onTap,
  });

  final HabitRecord record;
  final List<HabitRecordAttachment> attachments;
  final HabitRecordAttachmentStorage attachmentStorage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (attachments.isEmpty) {
      return IconButton(
        key: ValueKey<String>('habit-record-attach-${record.id}'),
        tooltip: '添加图片证明',
        onPressed: onTap,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
        color: colorScheme.primary,
        visualDensity: VisualDensity.compact,
      );
    }

    final attachment = attachments.first;
    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        final hasFile = file != null;

        return Tooltip(
          message: hasFile ? '图片证明' : '图片证明文件缺失',
          child: InkWell(
            key: ValueKey<String>(
              hasFile
                  ? 'habit-record-thumbnail-${record.id}'
                  : 'habit-record-missing-image-${record.id}',
            ),
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppThemeTokens.softSurfaceTone(colorScheme)
                    : colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFile
                      ? colorScheme.primary.withValues(alpha: 0.18)
                      : colorScheme.error.withValues(alpha: 0.22),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasFile
                      ? Image.file(file, fit: BoxFit.cover)
                      : Icon(
                          Icons.broken_image_outlined,
                          size: 20,
                          color: colorScheme.error,
                        ),
                  if (attachments.length > 1)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        color: colorScheme.primary.withValues(alpha: 0.84),
                        child: Text(
                          '+${attachments.length - 1}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HabitRecordAttachmentSheet extends StatefulWidget {
  const _HabitRecordAttachmentSheet({
    required this.record,
    required this.habitsStore,
    required this.attachmentStorage,
  });

  final HabitRecord record;
  final HabitsStore habitsStore;
  final HabitRecordAttachmentStorage attachmentStorage;

  @override
  State<_HabitRecordAttachmentSheet> createState() =>
      _HabitRecordAttachmentSheetState();
}

class _HabitRecordAttachmentSheetState
    extends State<_HabitRecordAttachmentSheet> {
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attachments = widget.habitsStore.attachmentsForRecord(
      widget.record.id,
    );
    final remainingSlots =
        HabitsStore.maxAttachmentsPerRecord - attachments.length;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          0,
          AppThemeTokens.pagePadding,
          MediaQuery.of(context).viewInsets.bottom + AppThemeTokens.pagePadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('图片证明', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppThemeTokens.spaceXs),
              Text(
                '${widget.record.localDate} · ${_recordTypeLabel(widget.record.type)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _HabitRecordAttachmentGrid(
                recordId: widget.record.id,
                attachments: attachments,
                attachmentStorage: widget.attachmentStorage,
                onTap: _showAttachmentPreview,
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              Text(
                '最多 3 张图片证明，普通打卡不会要求添加图片。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Wrap(
                spacing: AppThemeTokens.spaceSm,
                runSpacing: AppThemeTokens.spaceSm,
                children: [
                  FilledButton.tonalIcon(
                    key: ValueKey<String>(
                      'habit-record-image-add-${widget.record.id}',
                    ),
                    onPressed: _isWorking || remainingSlots <= 0
                        ? null
                        : _addImage,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                    ),
                    label: const Text('添加图片'),
                  ),
                  TextButton.icon(
                    key: ValueKey<String>(
                      'habit-record-image-recover-${widget.record.id}',
                    ),
                    onPressed: _isWorking || remainingSlots <= 0
                        ? null
                        : _recoverLostImages,
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('恢复上次选择'),
                  ),
                ],
              ),
              if (remainingSlots <= 0) ...[
                const SizedBox(height: AppThemeTokens.spaceSm),
                Text(
                  '最多 3 张图片证明',
                  key: ValueKey<String>(
                    'habit-record-image-max-${widget.record.id}',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) {
      return;
    }

    await _addFromSource(source);
  }

  Future<void> _recoverLostImages() {
    return _addFromSource(_HabitProofImageSource.lost);
  }

  Future<void> _addFromSource(_HabitProofImageSource source) async {
    final remainingSlots =
        HabitsStore.maxAttachmentsPerRecord -
        widget.habitsStore.attachmentsForRecord(widget.record.id).length;
    if (remainingSlots <= 0) {
      _showMessage('最多 3 张图片证明');
      return;
    }

    await _runAttachmentAction(() async {
      final storedImages = switch (source) {
        _HabitProofImageSource.gallery =>
          await widget.attachmentStorage.pickAndStoreImages(
            widget.record.id,
            limit: remainingSlots,
          ),
        _HabitProofImageSource.camera => [
          ?await widget.attachmentStorage.captureAndStoreImage(
            widget.record.id,
          ),
        ],
        _HabitProofImageSource.lost =>
          await widget.attachmentStorage.retrieveLostImages(
            widget.record.id,
            limit: remainingSlots,
          ),
      };

      if (storedImages.isEmpty && mounted) {
        _showMessage(
          source == _HabitProofImageSource.lost ? '没有可恢复的图片，请重新选择。' : '没有选择图片。',
        );
      }

      for (final stored in storedImages) {
        final added = await widget.habitsStore.addRecordAttachment(
          recordId: widget.record.id,
          relativePath: stored.relativePath,
          fileName: stored.fileName,
          mimeType: stored.mimeType,
        );
        if (added == null) {
          await widget.attachmentStorage.removeImage(stored.relativePath);
        }
      }
    });
  }

  Future<void> _showAttachmentPreview(HabitRecordAttachment attachment) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (previewContext) => _HabitRecordAttachmentPreviewSheet(
        attachment: attachment,
        attachmentStorage: widget.attachmentStorage,
        onReplace: () {
          Navigator.of(previewContext).pop();
          _replaceImage(attachment);
        },
        onRemove: () {
          Navigator.of(previewContext).pop();
          _removeImage(attachment);
        },
      ),
    );
  }

  Future<void> _replaceImage(HabitRecordAttachment attachment) async {
    final source = await _showImageSourceSheet(allowLostRecovery: false);
    if (source == null) {
      return;
    }

    await _runAttachmentAction(() async {
      final stored = switch (source) {
        _HabitProofImageSource.gallery =>
          await widget.attachmentStorage
              .pickAndStoreImages(widget.record.id, limit: 1)
              .then((images) => images.isEmpty ? null : images.first),
        _HabitProofImageSource.camera =>
          await widget.attachmentStorage.captureAndStoreImage(widget.record.id),
        _HabitProofImageSource.lost => null,
      };

      if (stored == null) {
        if (mounted) {
          _showMessage('没有选择图片。');
        }
        return;
      }

      final replaced = await widget.habitsStore.replaceRecordAttachmentById(
        attachmentId: attachment.id,
        relativePath: stored.relativePath,
        fileName: stored.fileName,
        mimeType: stored.mimeType,
      );
      if (replaced == null) {
        await widget.attachmentStorage.removeImage(stored.relativePath);
      } else {
        await widget.attachmentStorage.removeImage(replaced.relativePath);
      }
    });
  }

  Future<void> _removeImage(HabitRecordAttachment attachment) {
    return _runAttachmentAction(() async {
      final removed = await widget.habitsStore.removeRecordAttachmentById(
        attachment.id,
      );
      if (removed != null) {
        await widget.attachmentStorage.removeImage(removed.relativePath);
      }
    });
  }

  Future<void> _runAttachmentAction(Future<void> Function() action) async {
    setState(() {
      _isWorking = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
        });
      }
    }
  }

  Future<_HabitProofImageSource?> _showImageSourceSheet({
    bool allowLostRecovery = true,
  }) {
    return showModalBottomSheet<_HabitProofImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            0,
            AppThemeTokens.pagePadding,
            AppThemeTokens.pagePadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: ValueKey<String>(
                  'habit-record-image-source-gallery-${widget.record.id}',
                ),
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                subtitle: const Text('可一次选择多张，剩余名额内保存。'),
                onTap: () =>
                    Navigator.of(context).pop(_HabitProofImageSource.gallery),
              ),
              ListTile(
                key: ValueKey<String>(
                  'habit-record-image-source-camera-${widget.record.id}',
                ),
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('拍照'),
                subtitle: const Text('拍摄一张新的图片证明。'),
                onTap: () =>
                    Navigator.of(context).pop(_HabitProofImageSource.camera),
              ),
              if (allowLostRecovery)
                ListTile(
                  key: ValueKey<String>(
                    'habit-record-image-source-lost-${widget.record.id}',
                  ),
                  leading: const Icon(Icons.restore_rounded),
                  title: const Text('恢复上次选择'),
                  subtitle: const Text('用于 Android 选择图片时应用被系统回收的情况。'),
                  onTap: () =>
                      Navigator.of(context).pop(_HabitProofImageSource.lost),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _HabitProofImageSource { gallery, camera, lost }

class _HabitRecordAttachmentGrid extends StatelessWidget {
  const _HabitRecordAttachmentGrid({
    required this.recordId,
    required this.attachments,
    required this.attachmentStorage,
    required this.onTap,
  });

  final String recordId;
  final List<HabitRecordAttachment> attachments;
  final HabitRecordAttachmentStorage attachmentStorage;
  final ValueChanged<HabitRecordAttachment> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (attachments.isEmpty) {
      return Container(
        key: const ValueKey('habit-record-image-empty'),
        width: double.infinity,
        padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
        decoration: BoxDecoration(
          color: AppThemeTokens.softSurfaceTone(colorScheme),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
        ),
        child: Text(
          '还没有图片证明，可以从相册选择或拍照添加。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      );
    }

    return Wrap(
      key: ValueKey<String>('habit-record-image-grid-$recordId'),
      spacing: AppThemeTokens.spaceSm,
      runSpacing: AppThemeTokens.spaceSm,
      children: [
        for (final attachment in attachments)
          _HabitRecordAttachmentThumbnail(
            attachment: attachment,
            attachmentStorage: attachmentStorage,
            onTap: () => onTap(attachment),
          ),
      ],
    );
  }
}

class _HabitRecordAttachmentThumbnail extends StatelessWidget {
  const _HabitRecordAttachmentThumbnail({
    required this.attachment,
    required this.attachmentStorage,
    required this.onTap,
  });

  final HabitRecordAttachment attachment;
  final HabitRecordAttachmentStorage attachmentStorage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        final hasFile = file != null;

        return Container(
          key: ValueKey<String>(
            hasFile
                ? 'habit-record-image-thumb-${attachment.id}'
                : 'habit-record-image-missing-thumb-${attachment.id}',
          ),
          width: 86,
          height: 86,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: hasFile
                ? AppThemeTokens.softSurfaceTone(colorScheme)
                : colorScheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
            border: Border.all(
              color: hasFile
                  ? AppThemeTokens.borderTone(colorScheme)
                  : colorScheme.error.withValues(alpha: 0.22),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: hasFile
                ? Image.file(file, fit: BoxFit.cover)
                : Icon(
                    Icons.broken_image_outlined,
                    size: 24,
                    color: colorScheme.error,
                  ),
          ),
        );
      },
    );
  }
}

class _HabitRecordAttachmentPreviewSheet extends StatelessWidget {
  const _HabitRecordAttachmentPreviewSheet({
    required this.attachment,
    required this.attachmentStorage,
    required this.onReplace,
    required this.onRemove,
  });

  final HabitRecordAttachment attachment;
  final HabitRecordAttachmentStorage attachmentStorage;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          0,
          AppThemeTokens.pagePadding,
          MediaQuery.of(context).viewInsets.bottom + AppThemeTokens.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('图片证明', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppThemeTokens.spaceSm),
            FutureBuilder<File?>(
              future: attachmentStorage.resolveImage(attachment.relativePath),
              builder: (context, snapshot) {
                final file = snapshot.data;
                final hasFile = file != null;

                return Container(
                  key: ValueKey<String>(
                    hasFile
                        ? 'habit-record-image-preview-${attachment.recordId}'
                        : 'habit-record-image-missing-${attachment.recordId}',
                  ),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 320),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppThemeTokens.softSurfaceTone(colorScheme)
                        : colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusLg,
                    ),
                    border: Border.all(
                      color: hasFile
                          ? AppThemeTokens.borderTone(colorScheme)
                          : colorScheme.error.withValues(alpha: 0.22),
                    ),
                  ),
                  child: hasFile
                      ? Image.file(file, fit: BoxFit.contain)
                      : Padding(
                          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                          child: Row(
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: AppThemeTokens.spaceSm),
                              Expanded(
                                child: Text(
                                  '图片文件已不在本地，记录仍然保留。',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            Wrap(
              spacing: AppThemeTokens.spaceSm,
              runSpacing: AppThemeTokens.spaceSm,
              children: [
                FilledButton.tonalIcon(
                  key: ValueKey<String>(
                    'habit-record-image-replace-${attachment.id}',
                  ),
                  onPressed: onReplace,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('更换这张'),
                ),
                TextButton.icon(
                  key: ValueKey<String>(
                    'habit-record-image-remove-${attachment.id}',
                  ),
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('移除图片'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitFormDialog extends StatefulWidget {
  const _HabitFormDialog.create()
    : initialHabit = null,
      initialTemplates = const <HabitCheckInTemplate>[],
      title = '新建习惯',
      submitLabel = '创建';

  const _HabitFormDialog.edit(
    this.initialHabit, {
    required this.initialTemplates,
  }) : title = '编辑习惯',
       submitLabel = '保存';

  final HabitItem? initialHabit;
  final List<HabitCheckInTemplate> initialTemplates;
  final String title;
  final String submitLabel;

  @override
  State<_HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<_HabitFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetController;
  late final TextEditingController _reminderController;
  late List<HabitReminderRule> _reminderRules;
  late List<_HabitTemplateDraft> _templateDrafts;
  int? _selectedHabitColorValue;
  String? _nameError;
  String? _targetError;
  String? _templateError;

  @override
  void initState() {
    super.initState();
    final initialHabit = widget.initialHabit;
    _nameController = TextEditingController(text: initialHabit?.name ?? '');
    _emojiController = TextEditingController(
      text: initialHabit?.emoji ?? HabitItem.defaultEmoji,
    );
    _descriptionController = TextEditingController(
      text: initialHabit?.description ?? '',
    );
    _targetController = TextEditingController(
      text:
          '${initialHabit?.targetCountPerDay ?? HabitItem.defaultTargetCountPerDay}',
    );
    _reminderRules = List<HabitReminderRule>.of(
      initialHabit?.reminderRules ?? const <HabitReminderRule>[],
    );
    _reminderController = TextEditingController(
      text: _reminderFieldControllerText(_reminderRules),
    );
    _selectedHabitColorValue = initialHabit?.habitColorValue;
    _templateDrafts = widget.initialTemplates
        .map(_HabitTemplateDraft.fromTemplate)
        .toList(growable: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HabitFormSectionLabel(
              title: '习惯身份',
              subtitle: '先让这个习惯有清晰的名字和图标。',
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            TextField(
              key: const ValueKey('habit-name-field'),
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: '习惯名称',
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            TextField(
              key: const ValueKey('habit-emoji-field'),
              controller: _emojiController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '图标',
                helperText: '可以点选常用图标，也可以手动输入。',
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            _HabitEmojiPresetGrid(
              selectedEmoji: _emojiController.text.trim(),
              onSelected: (emoji) {
                setState(() {
                  _emojiController.text = emoji;
                });
              },
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            _HabitColorPresetGrid(
              selectedColorValue: _selectedHabitColorValue,
              onSelected: (value) {
                setState(() {
                  _selectedHabitColorValue = value;
                });
              },
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            TextField(
              key: const ValueKey('habit-description-field'),
              controller: _descriptionController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '描述（可选）'),
            ),
            const SizedBox(height: AppThemeTokens.spaceLg),
            const _HabitFormSectionLabel(
              title: '每日节奏',
              subtitle: '设置今天做到几次算达标。',
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            TextField(
              key: const ValueKey('habit-target-field'),
              controller: _targetController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '每日目标次数',
                errorText: _targetError,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceLg),
            _HabitTemplateEditorSection(
              drafts: _templateDrafts,
              errorText: _templateError,
              onAdd: _addTemplateDraft,
              onEdit: _editTemplateDraft,
              onArchive: _archiveTemplateDraft,
              onRestore: _restoreTemplateDraft,
            ),
            const SizedBox(height: AppThemeTokens.spaceLg),
            const _HabitFormSectionLabel(
              title: '提醒',
              subtitle: '每天一个轻提醒，不打扰节奏。',
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            InkWell(
              key: const ValueKey('habit-reminder-field'),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
              onTap: _pickReminderTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeTokens.spaceLg,
                  vertical: AppThemeTokens.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: AppThemeTokens.borderTone(colorScheme),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 18,
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    Expanded(
                      child: Text(
                        _reminderController.text.trim().isEmpty
                            ? '未设置提醒'
                            : '提醒 ${_reminderController.text.trim()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _reminderController.text.trim().isEmpty
                              ? AppThemeTokens.secondaryTextTone(colorScheme)
                              : colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ],
                ),
              ),
            ),
            if (_reminderController.text.trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const ValueKey('habit-reminder-clear-field'),
                  onPressed: () {
                    setState(() {
                      _reminderRules = const <HabitReminderRule>[];
                      _reminderController.clear();
                    });
                  },
                  child: const Text('清除提醒'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          key: const ValueKey('habit-form-submit'),
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  Future<void> _addTemplateDraft() async {
    if (_templateDrafts.where((draft) => !draft.isArchived).length >=
        HabitsStore.maxCheckInTemplatesPerHabit) {
      setState(() {
        _templateError =
            '最多添加 ${HabitsStore.maxCheckInTemplatesPerHabit} 个打卡项目';
      });
      return;
    }

    final draft = await _showTemplateDraftEditor();
    if (draft == null) {
      return;
    }
    setState(() {
      _templateDrafts.add(draft.copyWith(sortOrder: _templateDrafts.length));
      _templateError = null;
    });
  }

  Future<void> _editTemplateDraft(_HabitTemplateDraft draft) async {
    final editedDraft = await _showTemplateDraftEditor(draft: draft);
    if (editedDraft == null) {
      return;
    }
    final index = _templateDrafts.indexOf(draft);
    if (index == -1) {
      return;
    }
    setState(() {
      _templateDrafts[index] = editedDraft;
      _templateError = null;
    });
  }

  void _archiveTemplateDraft(_HabitTemplateDraft draft) {
    setState(() {
      final index = _templateDrafts.indexOf(draft);
      if (index != -1) {
        _templateDrafts[index] = draft.copyWith(isArchived: true);
      }
      _templateError = null;
    });
  }

  void _restoreTemplateDraft(_HabitTemplateDraft draft) {
    if (_templateDrafts.where((item) => !item.isArchived).length >=
        HabitsStore.maxCheckInTemplatesPerHabit) {
      setState(() {
        _templateError =
            '最多添加 ${HabitsStore.maxCheckInTemplatesPerHabit} 个打卡项目';
      });
      return;
    }

    setState(() {
      final index = _templateDrafts.indexOf(draft);
      if (index != -1) {
        _templateDrafts[index] = draft.copyWith(isArchived: false);
      }
      _templateError = null;
    });
  }

  Future<_HabitTemplateDraft?> _showTemplateDraftEditor({
    _HabitTemplateDraft? draft,
  }) {
    return showModalBottomSheet<_HabitTemplateDraft>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HabitTemplateDraftSheet(initialDraft: draft),
    );
  }

  Future<void> _pickReminderTime() async {
    final selection = await showModalBottomSheet<_ReminderSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ReminderRulesSheet(
        initialRules: _reminderRules,
        draftHabitId: widget.initialHabit?.id ?? 'habit-reminder-draft',
      ),
    );

    if (selection == null) {
      return;
    }

    setState(() {
      _reminderRules = selection.reminderRules;
      _reminderController.text = _reminderFieldControllerText(_reminderRules);
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final targetCount = int.tryParse(_targetController.text.trim());

    if (name.isEmpty) {
      setState(() {
        _nameError = '请输入习惯名称';
        _targetError = null;
      });
      return;
    }

    if (targetCount == null || targetCount < 1) {
      setState(() {
        _nameError = null;
        _targetError = '请输入至少 1 次';
      });
      return;
    }

    Navigator.of(context).pop(
      _HabitDraft(
        name: name,
        emoji: _emojiController.text.trim().isEmpty
            ? HabitItem.defaultEmoji
            : _emojiController.text.trim(),
        description: _descriptionController.text.trim(),
        targetCountPerDay: targetCount,
        reminderRules: _reminderRules,
        habitColorValue: _selectedHabitColorValue,
        checkInTemplates: List<_HabitTemplateDraft>.of(_templateDrafts),
      ),
    );
  }
}

class _HabitTemplateEditorSection extends StatelessWidget {
  const _HabitTemplateEditorSection({
    required this.drafts,
    required this.onAdd,
    required this.onEdit,
    required this.onArchive,
    required this.onRestore,
    this.errorText,
  });

  final List<_HabitTemplateDraft> drafts;
  final VoidCallback onAdd;
  final ValueChanged<_HabitTemplateDraft> onEdit;
  final ValueChanged<_HabitTemplateDraft> onArchive;
  final ValueChanged<_HabitTemplateDraft> onRestore;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeDrafts =
        drafts.where((draft) => !draft.isArchived).toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final archivedDrafts =
        drafts.where((draft) => draft.isArchived).toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HabitFormSectionLabel(
          title: '打卡项目',
          subtitle: '用于详细打卡，例如 深蹲/个、阅读/分钟。',
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
        if (activeDrafts.isEmpty)
          Text(
            '可选。普通一键打卡不会被打扰。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          )
        else
          ...activeDrafts.map(
            (draft) => Padding(
              padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
              child: _HabitTemplateDraftTile(
                draft: draft,
                onEdit: () => onEdit(draft),
                onArchive: () => onArchive(draft),
              ),
            ),
          ),
        if (archivedDrafts.isNotEmpty) ...[
          const SizedBox(height: AppThemeTokens.spaceSm),
          Text(
            '已归档项目',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          ...archivedDrafts.map(
            (draft) => Padding(
              padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceSm),
              child: _HabitTemplateDraftTile(
                draft: draft,
                onEdit: () => onEdit(draft),
                onRestore: () => onRestore(draft),
              ),
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const ValueKey('habit-template-add'),
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('添加项目'),
          ),
        ),
      ],
    );
  }
}

class _HabitTemplateDraftTile extends StatelessWidget {
  const _HabitTemplateDraftTile({
    required this.draft,
    required this.onEdit,
    this.onArchive,
    this.onRestore,
  });

  final _HabitTemplateDraft draft;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultText = draft.defaultValue == null
        ? ''
        : ' · 默认 ${_formatMetricValue(draft.defaultValue!)}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceMd,
        vertical: AppThemeTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${draft.title} · ${draft.unit}$defaultText',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: draft.isArchived
                    ? AppThemeTokens.secondaryTextTone(colorScheme)
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('编辑')),
          if (onArchive != null)
            TextButton(onPressed: onArchive, child: const Text('归档')),
          if (onRestore != null)
            TextButton(onPressed: onRestore, child: const Text('恢复')),
        ],
      ),
    );
  }
}

class _HabitTemplateDraftSheet extends StatefulWidget {
  const _HabitTemplateDraftSheet({this.initialDraft});

  final _HabitTemplateDraft? initialDraft;

  @override
  State<_HabitTemplateDraftSheet> createState() =>
      _HabitTemplateDraftSheetState();
}

class _HabitTemplateDraftSheetState extends State<_HabitTemplateDraftSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _unitController;
  late final TextEditingController _defaultController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initialDraft = widget.initialDraft;
    _titleController = TextEditingController(text: initialDraft?.title ?? '');
    _unitController = TextEditingController(text: initialDraft?.unit ?? '');
    _defaultController = TextEditingController(
      text: initialDraft?.defaultValue == null
          ? ''
          : _formatMetricValue(initialDraft!.defaultValue!),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    _defaultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          AppThemeTokens.spaceSm,
          AppThemeTokens.pagePadding,
          bottomInset + AppThemeTokens.pagePadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialDraft == null ? '添加打卡项目' : '编辑打卡项目',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              TextField(
                key: const ValueKey('habit-template-title-field'),
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              TextField(
                key: const ValueKey('habit-template-unit-field'),
                controller: _unitController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '单位'),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              TextField(
                key: const ValueKey('habit-template-default-field'),
                controller: _defaultController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '默认数值（可选）'),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppThemeTokens.spaceSm),
                Text(
                  _errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppThemeTokens.spaceLg),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const ValueKey('habit-template-save'),
                  onPressed: _submit,
                  child: const Text('保存项目'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    final unit = _unitController.text.trim();
    final defaultText = _defaultController.text.trim();
    final defaultValue = defaultText.isEmpty
        ? null
        : double.tryParse(defaultText);

    if (title.isEmpty || unit.isEmpty) {
      setState(() {
        _errorText = '请填写名称和单位';
      });
      return;
    }
    if (defaultText.isNotEmpty &&
        (defaultValue == null || !defaultValue.isFinite || defaultValue < 0)) {
      setState(() {
        _errorText = '默认数值需要是 0 或更大的数字';
      });
      return;
    }

    final initialDraft = widget.initialDraft;
    Navigator.of(context).pop(
      (initialDraft ??
              const _HabitTemplateDraft(title: '', unit: '', sortOrder: 0))
          .copyWith(
            title: title,
            unit: unit,
            defaultValue: defaultValue,
            clearDefaultValue: defaultValue == null,
          ),
    );
  }
}

class _HabitFormSectionLabel extends StatelessWidget {
  const _HabitFormSectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceXs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      ],
    );
  }
}

class _HabitDraft {
  const _HabitDraft({
    required this.name,
    required this.emoji,
    required this.description,
    required this.targetCountPerDay,
    required this.reminderRules,
    required this.habitColorValue,
    required this.checkInTemplates,
  });

  final String name;
  final String emoji;
  final String description;
  final int targetCountPerDay;
  final List<HabitReminderRule> reminderRules;
  final int? habitColorValue;
  final List<_HabitTemplateDraft> checkInTemplates;
}

class _HabitTemplateDraft {
  const _HabitTemplateDraft({
    required this.title,
    required this.unit,
    required this.sortOrder,
    this.id,
    this.defaultValue,
    this.isArchived = false,
  });

  factory _HabitTemplateDraft.fromTemplate(HabitCheckInTemplate template) {
    return _HabitTemplateDraft(
      id: template.id,
      title: template.title,
      unit: template.unit,
      defaultValue: template.defaultValue,
      sortOrder: template.sortOrder,
      isArchived: template.isArchived,
    );
  }

  final String? id;
  final String title;
  final String unit;
  final double? defaultValue;
  final int sortOrder;
  final bool isArchived;

  _HabitTemplateDraft copyWith({
    String? id,
    String? title,
    String? unit,
    double? defaultValue,
    bool clearDefaultValue = false,
    int? sortOrder,
    bool? isArchived,
  }) {
    return _HabitTemplateDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      defaultValue: clearDefaultValue
          ? null
          : (defaultValue ?? this.defaultValue),
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class _HabitColorPresetGrid extends StatelessWidget {
  const _HabitColorPresetGrid({
    required this.selectedColorValue,
    required this.onSelected,
  });

  final int? selectedColorValue;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HabitFormSectionLabel(
          title: '习惯颜色',
          subtitle: '只影响这个习惯的卡片、活动和热力图识别色。',
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        Wrap(
          spacing: AppThemeTokens.spaceSm,
          runSpacing: AppThemeTokens.spaceSm,
          children: [
            _HabitColorPresetButton(
              key: const ValueKey(_followInterfaceAccentColorKey),
              label: '跟随界面强调色',
              color: colorScheme.primary,
              selected: selectedColorValue == null,
              onSelected: () => onSelected(null),
            ),
            for (var index = 0; index < _habitColorPresets.length; index += 1)
              _HabitColorPresetButton(
                key: ValueKey<String>('habit-color-preset-$index'),
                label: _habitColorPresets[index].label,
                color: Color(_habitColorPresets[index].value),
                selected: selectedColorValue == _habitColorPresets[index].value,
                onSelected: () => onSelected(_habitColorPresets[index].value),
              ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceXs),
        Text(
          '不会改变应用背景或全局界面强调色。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      ],
    );
  }
}

class _HabitColorPresetButton extends StatelessWidget {
  const _HabitColorPresetButton({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeTokens.spaceSm,
          vertical: AppThemeTokens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : colorScheme.surface.withValues(alpha: 0.64),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
          border: Border.all(
            width: selected ? 1.6 : 1,
            color: selected
                ? color.withValues(alpha: 0.72)
                : AppThemeTokens.borderTone(colorScheme),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
            const SizedBox(width: AppThemeTokens.spaceXs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? color
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitEmojiPresetGrid extends StatelessWidget {
  const _HabitEmojiPresetGrid({
    required this.selectedEmoji,
    required this.onSelected,
  });

  final String selectedEmoji;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常用图标',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        Wrap(
          spacing: AppThemeTokens.spaceSm,
          runSpacing: AppThemeTokens.spaceSm,
          children: [
            for (var index = 0; index < _habitEmojiPresets.length; index += 1)
              _HabitEmojiPresetButton(
                key: ValueKey<String>('habit-emoji-preset-$index'),
                emoji: _habitEmojiPresets[index],
                selected: selectedEmoji == _habitEmojiPresets[index],
                onSelected: () => onSelected(_habitEmojiPresets[index]),
              ),
          ],
        ),
      ],
    );
  }
}

class _HabitEmojiPresetButton extends StatelessWidget {
  const _HabitEmojiPresetButton({
    super.key,
    required this.emoji,
    required this.selected,
    required this.onSelected,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          border: Border.all(
            width: selected ? 1.6 : 1,
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.62)
                : AppThemeTokens.borderTone(colorScheme),
          ),
        ),
        child: Text(
          emoji,
          style: theme.textTheme.titleLarge?.copyWith(height: 1),
        ),
      ),
    );
  }
}

class _ReminderRulesSheet extends StatefulWidget {
  const _ReminderRulesSheet({
    required this.initialRules,
    required this.draftHabitId,
  });

  final List<HabitReminderRule> initialRules;
  final String draftHabitId;

  @override
  State<_ReminderRulesSheet> createState() => _ReminderRulesSheetState();
}

class _ReminderRulesSheetState extends State<_ReminderRulesSheet> {
  late List<HabitReminderRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = widget.initialRules
        .take(HabitReminderRule.maxRulesPerHabit)
        .map((rule) => rule.copyWith(weekdays: List<int>.of(rule.weekdays)))
        .toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          AppThemeTokens.spaceSm,
          AppThemeTokens.pagePadding,
          AppThemeTokens.pagePadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '提醒',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceXs),
              Text(
                '最多 3 个提醒，可按星期启用；暂停、归档或删除后会自动停止。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_rules.isEmpty)
                        SoftSurface(
                          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                          backgroundColor: AppThemeTokens.softSurfaceTone(
                            colorScheme,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                color: AppThemeTokens.secondaryTextTone(
                                  colorScheme,
                                ),
                              ),
                              const SizedBox(width: AppThemeTokens.spaceSm),
                              Expanded(
                                child: Text(
                                  '未设置提醒。普通打卡不会受影响。',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppThemeTokens.secondaryTextTone(
                                      colorScheme,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        for (var index = 0; index < _rules.length; index += 1)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _rules.length - 1
                                  ? 0
                                  : AppThemeTokens.spaceMd,
                            ),
                            child: _ReminderRuleEditor(
                              index: index,
                              rule: _rules[index],
                              onEditTime: () => _editRuleTime(index),
                              onEnabledChanged: (value) {
                                setState(() {
                                  _rules[index] = _rules[index].copyWith(
                                    isEnabled: value,
                                  );
                                });
                              },
                              onWeekdaysChanged: (weekdays) {
                                setState(() {
                                  _rules[index] = _rules[index].copyWith(
                                    weekdays: weekdays,
                                  );
                                });
                              },
                              onRemove: () {
                                setState(() {
                                  _rules.removeAt(index);
                                });
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              Row(
                children: [
                  TextButton.icon(
                    key: const ValueKey('habit-reminder-add-rule'),
                    onPressed:
                        _rules.length >= HabitReminderRule.maxRulesPerHabit
                        ? null
                        : _addRule,
                    icon: const Icon(Icons.add_alarm_rounded),
                    label: const Text('添加提醒'),
                  ),
                  const Spacer(),
                  Text(
                    '${_rules.length}/${HabitReminderRule.maxRulesPerHabit}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  FilledButton(
                    key: const ValueKey('habit-reminder-rules-save'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_ReminderSelection.fromRules(_rules)),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRule() {
    if (_rules.length >= HabitReminderRule.maxRulesPerHabit) {
      return;
    }

    final now = DateTime.now().toUtc();
    final presetTime =
        _habitReminderPresets[_rules.length
            .clamp(0, _habitReminderPresets.length - 1)
            .toInt()];
    setState(() {
      _rules.add(
        HabitReminderRule(
          id: 'habit-reminder-draft-${widget.draftHabitId}-${now.microsecondsSinceEpoch}',
          time: presetTime,
          weekdays: HabitReminderRule.allWeekdays,
          isEnabled: true,
          createdAt: now,
        ),
      );
    });
  }

  Future<void> _editRuleTime(int index) async {
    final selection = await showDialog<_ReminderSelection>(
      context: context,
      builder: (_) => _ReminderTimeDialog(initialTime: _rules[index].time),
    );

    if (selection == null) {
      return;
    }

    setState(() {
      if (selection.reminderTime == null) {
        _rules.removeAt(index);
      } else {
        _rules[index] = _rules[index].copyWith(time: selection.reminderTime);
      }
    });
  }
}

class _ReminderRuleEditor extends StatelessWidget {
  const _ReminderRuleEditor({
    required this.index,
    required this.rule,
    required this.onEditTime,
    required this.onEnabledChanged,
    required this.onWeekdaysChanged,
    required this.onRemove,
  });

  final int index;
  final HabitReminderRule rule;
  final VoidCallback onEditTime;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      backgroundColor: AppThemeTokens.softSurfaceTone(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  key: ValueKey<String>('habit-reminder-rule-time-$index'),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  onTap: onEditTime,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppThemeTokens.spaceXs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: AppThemeTokens.spaceSm),
                        Text(
                          rule.time,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppThemeTokens.spaceXs),
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Switch(
                key: ValueKey<String>('habit-reminder-rule-enabled-$index'),
                value: rule.isEnabled,
                onChanged: onEnabledChanged,
              ),
              IconButton(
                key: ValueKey<String>('habit-reminder-rule-remove-$index'),
                tooltip: '移除提醒',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Text(
            _weekdaySummary(rule.weekdays),
            style: theme.textTheme.labelMedium?.copyWith(
              color: rule.isEnabled
                  ? colorScheme.primary
                  : AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Wrap(
            spacing: AppThemeTokens.spaceXs,
            runSpacing: AppThemeTokens.spaceXs,
            children: [
              ChoiceChip(
                key: ValueKey<String>('habit-reminder-weekday-everyday-$index'),
                label: const Text('每天'),
                selected: _isEveryDay(rule.weekdays),
                onSelected: (_) =>
                    onWeekdaysChanged(HabitReminderRule.allWeekdays),
              ),
              ChoiceChip(
                key: ValueKey<String>('habit-reminder-weekday-workdays-$index'),
                label: const Text('工作日'),
                selected: _isWorkdays(rule.weekdays),
                onSelected: (_) =>
                    onWeekdaysChanged(const <int>[1, 2, 3, 4, 5]),
              ),
              for (final weekday in HabitReminderRule.allWeekdays)
                FilterChip(
                  key: ValueKey<String>(
                    'habit-reminder-weekday-$index-$weekday',
                  ),
                  label: Text(_weekdayShortLabel(weekday)),
                  selected: rule.weekdays.contains(weekday),
                  onSelected: (_) =>
                      onWeekdaysChanged(_toggleWeekday(rule.weekdays, weekday)),
                ),
            ],
          ),
          if (!rule.isEnabled) ...[
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              '已关闭，会保留设置但不安排通知。',
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

class _ReminderSelection {
  const _ReminderSelection._({
    required this.reminderTime,
    required this.reminderRules,
  });

  factory _ReminderSelection.fromTime(String? reminderTime) {
    final normalizedTime = reminderTime?.trim();
    if (normalizedTime == null || normalizedTime.isEmpty) {
      return const _ReminderSelection._(
        reminderTime: null,
        reminderRules: <HabitReminderRule>[],
      );
    }

    final now = DateTime.now().toUtc();
    return _ReminderSelection._(
      reminderTime: normalizedTime,
      reminderRules: [
        HabitReminderRule(
          id: 'habit-reminder-draft-time-${now.microsecondsSinceEpoch}',
          time: normalizedTime,
          weekdays: HabitReminderRule.allWeekdays,
          isEnabled: true,
          createdAt: now,
        ),
      ],
    );
  }

  factory _ReminderSelection.fromRules(List<HabitReminderRule> rules) {
    final copiedRules = rules
        .take(HabitReminderRule.maxRulesPerHabit)
        .map((rule) => rule.copyWith(weekdays: List<int>.of(rule.weekdays)))
        .toList(growable: false);

    return _ReminderSelection._(
      reminderTime: _legacyReminderTimeForRules(copiedRules),
      reminderRules: copiedRules,
    );
  }

  final String? reminderTime;
  final List<HabitReminderRule> reminderRules;
}

String _reminderCardSummary(List<HabitReminderRule> rules) {
  if (rules.isEmpty) {
    return '未设置提醒';
  }

  final enabledRules = rules
      .where((rule) => rule.isEnabled)
      .take(HabitReminderRule.maxRulesPerHabit)
      .toList(growable: false);
  if (enabledRules.isEmpty) {
    return '已关闭';
  }

  final times = enabledRules.map((rule) => rule.time).join(', ');
  final weekdayLabel = _combinedWeekdaySummary(enabledRules);
  return '$times · $weekdayLabel';
}

String _formatMetricValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _reminderFieldControllerText(List<HabitReminderRule> rules) {
  if (rules.isEmpty) {
    return '';
  }

  return _reminderCardSummary(rules);
}

String? _legacyReminderTimeForRules(List<HabitReminderRule> rules) {
  for (final rule in rules) {
    if (rule.isEnabled) {
      return rule.time;
    }
  }

  return null;
}

String _combinedWeekdaySummary(List<HabitReminderRule> rules) {
  if (rules.isEmpty) {
    return '已关闭';
  }

  if (rules.every((rule) => _isEveryDay(rule.weekdays))) {
    return '每天';
  }

  if (rules.every((rule) => _isWorkdays(rule.weekdays))) {
    return '工作日';
  }

  if (rules.length == 1) {
    return _weekdaySummary(rules.single.weekdays);
  }

  return '多组星期';
}

String _weekdaySummary(List<int> weekdays) {
  if (_isEveryDay(weekdays)) {
    return '每天';
  }

  if (_isWorkdays(weekdays)) {
    return '工作日';
  }

  return weekdays.map(_weekdayShortLabel).join('、');
}

bool _isEveryDay(List<int> weekdays) {
  final normalized = _normalizedWeekdays(weekdays);
  return normalized.length == 7;
}

bool _isWorkdays(List<int> weekdays) {
  final normalized = _normalizedWeekdays(weekdays);
  return normalized.length == 5 &&
      normalized[0] == 1 &&
      normalized[1] == 2 &&
      normalized[2] == 3 &&
      normalized[3] == 4 &&
      normalized[4] == 5;
}

List<int> _toggleWeekday(List<int> weekdays, int weekday) {
  final normalized = _normalizedWeekdays(weekdays).toSet();
  if (normalized.contains(weekday)) {
    if (normalized.length == 1) {
      return normalized.toList(growable: false)..sort();
    }
    normalized.remove(weekday);
  } else if (weekday >= 1 && weekday <= 7) {
    normalized.add(weekday);
  }

  return normalized.toList(growable: false)..sort();
}

List<int> _normalizedWeekdays(List<int> weekdays) {
  final normalized = <int>{};
  for (final weekday in weekdays) {
    if (weekday >= 1 && weekday <= 7) {
      normalized.add(weekday);
    }
  }

  return normalized.toList(growable: false)..sort();
}

String _weekdayShortLabel(int weekday) {
  return switch (weekday) {
    1 => '一',
    2 => '二',
    3 => '三',
    4 => '四',
    5 => '五',
    6 => '六',
    7 => '日',
    _ => '$weekday',
  };
}

class _ReminderTimeDialog extends StatefulWidget {
  const _ReminderTimeDialog({this.initialTime});

  final String? initialTime;

  @override
  State<_ReminderTimeDialog> createState() => _ReminderTimeDialogState();
}

class _ReminderTimeDialogState extends State<_ReminderTimeDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    final initial = _parseReminderTime(widget.initialTime);
    _hour = initial?.hour ?? 8;
    _minute = initial?.minute ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('提醒时间'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择每天提醒打卡的时间，保存后会更新本习惯的每日提醒。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeTokens.spaceLg,
              vertical: AppThemeTokens.spaceMd,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.alarm_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  _formatReminderTime(_hour, _minute),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '每天',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceLg),
          Text(
            '快捷时间',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _habitReminderPresets)
                ChoiceChip(
                  key: ValueKey<String>('habit-reminder-preset-$preset'),
                  label: Text(preset),
                  selected: _formatReminderTime(_hour, _minute) == preset,
                  selectedColor: colorScheme.primary.withValues(alpha: 0.14),
                  side: BorderSide(
                    color: _formatReminderTime(_hour, _minute) == preset
                        ? colorScheme.primary.withValues(alpha: 0.46)
                        : AppThemeTokens.borderTone(colorScheme),
                  ),
                  onSelected: (_) {
                    final parsed = _parseReminderTime(preset);
                    if (parsed == null) {
                      return;
                    }

                    setState(() {
                      _hour = parsed.hour;
                      _minute = parsed.minute;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          Text(
            '自定义时间',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: const ValueKey('habit-reminder-hour-picker'),
                  initialValue: _hour,
                  decoration: const InputDecoration(labelText: '小时'),
                  items: [
                    for (var hour = 0; hour < 24; hour += 1)
                      DropdownMenuItem<int>(
                        value: hour,
                        child: Text(hour.toString().padLeft(2, '0')),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _hour = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: AppThemeTokens.spaceMd),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: const ValueKey('habit-reminder-minute-picker'),
                  initialValue: _minute,
                  decoration: const InputDecoration(labelText: '分钟'),
                  items: [
                    for (var minute = 0; minute < 60; minute += 1)
                      DropdownMenuItem<int>(
                        value: minute,
                        child: Text(minute.toString().padLeft(2, '0')),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _minute = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const ValueKey('habit-reminder-clear'),
          onPressed: () =>
              Navigator.of(context).pop(_ReminderSelection.fromTime(null)),
          child: const Text('清除提醒'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('habit-reminder-save'),
          onPressed: () => Navigator.of(context).pop(
            _ReminderSelection.fromTime(_formatReminderTime(_hour, _minute)),
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _MonthlyActivityDialog extends StatelessWidget {
  const _MonthlyActivityDialog({
    required this.habit,
    required this.monthActivity,
    required this.accentColor,
  });

  final HabitItem habit;
  final HabitActivityMonth monthActivity;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final hasRecords = monthActivity.days.any((day) => day.count > 0);
    final leadingEmptyCells =
        DateTime(monthActivity.year, monthActivity.month).weekday - 1;

    return AlertDialog(
      key: ValueKey<String>('habit-month-heatmap-dialog-${habit.id}'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      title: Text('月度节奏 · ${habit.name}', style: theme.textTheme.titleMedium),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: mediaSize.height * 0.56,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${monthActivity.year}年${monthActivity.month}月活动',
                key: ValueKey<String>('habit-month-title-${habit.id}'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '颜色越深，打卡越多。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
              const SizedBox(height: 6),
              _HeatmapLegend(accentColor: accentColor),
              const SizedBox(height: 6),
              const _WeekdayHeader(),
              const SizedBox(height: 2),
              _MonthActivityGrid(
                habitId: habit.id,
                leadingEmptyCells: leadingEmptyCells,
                days: monthActivity.days,
                accentColor: accentColor,
                onDayTap: (localDate) => Navigator.of(context).pop(localDate),
              ),
              if (!hasRecords) ...[
                const SizedBox(height: AppThemeTokens.spaceLg),
                Text(
                  '本月还没有打卡记录。',
                  key: ValueKey<String>('habit-month-empty-${habit.id}'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: ValueKey<String>('habit-month-close-${habit.id}'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({required this.accentColor});

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppThemeTokens.spaceXs,
      runSpacing: AppThemeTokens.spaceXs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '少',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final count in const [0, 1, 2, 3]) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiniHeatmapCell(
                key: ValueKey<String>(
                  'habit-month-legend-level-${activityIntensityLevel(count)}',
                ),
                count: count,
                accentColor: accentColor,
              ),
              const SizedBox(width: 3),
              Text(
                count >= 3 ? '3+' : '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
        Text(
          '多',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '仅打卡/补打计入深浅',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (final label in const ['一', '二', '三', '四', '五', '六', '日'])
          Expanded(
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthActivityGrid extends StatelessWidget {
  const _MonthActivityGrid({
    required this.habitId,
    required this.leadingEmptyCells,
    required this.days,
    required this.accentColor,
    this.onDayTap,
  });

  final String habitId;
  final int leadingEmptyCells;
  final List<HabitActivityDay> days;
  final Color? accentColor;
  final ValueChanged<String>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final totalCells = leadingEmptyCells + days.length;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: [
        for (var row = 0; row < rowCount; row += 1) ...[
          Row(
            children: [
              for (var column = 0; column < 7; column += 1) ...[
                Expanded(child: _buildCell(row * 7 + column)),
                if (column != 6) const SizedBox(width: 2),
              ],
            ],
          ),
          if (row != rowCount - 1) const SizedBox(height: 2),
        ],
      ],
    );
  }

  Widget _buildCell(int cellIndex) {
    final dayIndex = cellIndex - leadingEmptyCells;
    if (dayIndex < 0 || dayIndex >= days.length) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }

    return AspectRatio(
      aspectRatio: 1,
      child: _MonthActivityCell(
        habitId: habitId,
        day: days[dayIndex],
        accentColor: accentColor,
        onTap: onDayTap == null
            ? null
            : () => onDayTap!(days[dayIndex].localDate),
      ),
    );
  }
}

class _MonthActivityCell extends StatelessWidget {
  const _MonthActivityCell({
    required this.habitId,
    required this.day,
    required this.accentColor,
    this.onTap,
  });

  final String habitId;
  final HabitActivityDay day;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final level = activityIntensityLevel(day.count);
    final dayNumber = _dayNumberLabel(day.localDate);

    final cell = Center(
      child: MiniHeatmapCell(
        count: day.count,
        dateLabel: dayNumber,
        height: 26,
        borderRadius: 8,
        accentColor: accentColor,
        semanticLabel: '${day.localDate} 打卡 ${day.count} 次',
      ),
    );

    final key = ValueKey<String>(
      'habit-month-cell-$habitId-${day.localDate}-level-$level',
    );
    if (onTap == null) {
      return KeyedSubtree(key: key, child: cell);
    }

    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        onTap: onTap,
        child: cell,
      ),
    );
  }
}

String _recordTypeLabel(HabitRecordType type) {
  switch (type) {
    case HabitRecordType.checkIn:
      return '打卡';
    case HabitRecordType.skip:
      return '跳过';
    case HabitRecordType.makeup:
      return '补打';
  }
}

IconData _recordTypeIcon(HabitRecordType type) {
  switch (type) {
    case HabitRecordType.checkIn:
      return Icons.check_circle_outline_rounded;
    case HabitRecordType.skip:
      return Icons.remove_circle_outline_rounded;
    case HabitRecordType.makeup:
      return Icons.replay_circle_filled_outlined;
  }
}

DateTime _parseLocalDate(String localDate) {
  final parts = localDate.split('-');
  if (parts.length != 3) {
    return DateTime.now();
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return DateTime.now();
  }

  return DateTime(year, month, day);
}

String _localDateKey(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

TimeOfDay? _parseReminderTime(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }

  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
  final hour = int.tryParse(match?.group(1) ?? '');
  final minute = int.tryParse(match?.group(2) ?? '');
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

String _formatReminderTime(int hour, int minute) {
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

String _dayNumberLabel(String localDate) {
  final parts = localDate.split('-');
  if (parts.length != 3) {
    return localDate;
  }

  return '${int.tryParse(parts[2]) ?? parts[2]}';
}
