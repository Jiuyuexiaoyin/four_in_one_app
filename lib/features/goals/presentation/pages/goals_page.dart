import 'dart:io';

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/data/plan_record_attachment_storage.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/analytics_bar_list.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_strip.dart';
import 'package:four_in_one_app/shared/widgets/product/metric_tile.dart';
import 'package:four_in_one_app/shared/widgets/product/mini_heatmap_cell.dart';
import 'package:four_in_one_app/shared/widgets/product/plan_goal_card.dart';
import 'package:four_in_one_app/shared/widgets/product/plan_tree_row.dart';
import 'package:four_in_one_app/shared/widgets/product/product_page_header.dart';
import 'package:four_in_one_app/shared/widgets/product/progress_rail.dart';
import 'package:four_in_one_app/shared/widgets/product/soft_surface.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({this.attachmentStorage, super.key});

  final PlanRecordAttachmentStorage? attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final goalsStore = GoalsScope.of(context);
    final effectiveAttachmentStorage =
        attachmentStorage ?? const LocalPlanRecordAttachmentStorage();

    return ListView(
      key: const ValueKey('goals-page-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        AppThemeTokens.spaceXl,
        AppThemeTokens.pagePadding,
        AppThemeTokens.pagePadding,
      ),
      children: [
        const ProductPageHeader(
          title: '计划你的长期推进。',
          subtitle: '目标是方向，项目是路径，行动才是下一步。',
        ),
        const SizedBox(height: AppThemeTokens.spaceXl),
        _PlanOverviewSurface(goalsStore: goalsStore),
        const SizedBox(height: 14),
        _PlanSearchSurface(
          goalsStore: goalsStore,
          onEditProject: (project) =>
              _showEditProjectDialog(context, goalsStore, project),
          onEditTask: (task) => _showEditTaskDialog(context, goalsStore, task),
          onOpenProjectDetail: (project) => _showProjectDetailSheet(
            context,
            project: project,
            goalsStore: goalsStore,
            attachmentStorage: effectiveAttachmentStorage,
          ),
        ),
        const SizedBox(height: AppThemeTokens.pagePadding),
        _AddGoalSection(
          onPressed: () => _showCreateGoalDialog(context, goalsStore),
        ),
        const SizedBox(height: 28),
        _GoalsListHeader(
          totalCount: goalsStore.totalCount,
          completedCount: goalsStore.completedCount,
        ),
        const SizedBox(height: 14),
        if (goalsStore.goals.isEmpty)
          const _GoalsEmptyState()
        else
          Column(
            children: goalsStore.goals
                .map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GoalHierarchyCard(
                      goal: goal,
                      goalsStore: goalsStore,
                      onOpenFocus: () =>
                          _showGoalStructureSheet(context, goalsStore, goal),
                      onEditGoal: () =>
                          _showEditGoalDialog(context, goalsStore, goal),
                      onCreateProject: () =>
                          _showCreateProjectDialog(context, goalsStore, goal),
                      onEditProject: (project) =>
                          _showEditProjectDialog(context, goalsStore, project),
                      onCreateSubproject: (project) =>
                          _showCreateSubprojectDialog(
                            context,
                            goalsStore,
                            project,
                          ),
                      onEditSubproject: (subproject) =>
                          _showEditSubprojectDialog(
                            context,
                            goalsStore,
                            subproject,
                          ),
                      onCreateProjectTask: (project) =>
                          _showCreateTaskDialog(context, goalsStore, project),
                      onCreateSubprojectTask: (subproject) =>
                          _showCreateSubprojectTaskDialog(
                            context,
                            goalsStore,
                            subproject,
                          ),
                      onEditTask: (task) =>
                          _showEditTaskDialog(context, goalsStore, task),
                      onCreateProjectRecord: (project) =>
                          _showCreateProjectRecordDialog(
                            context,
                            goalsStore,
                            project,
                          ),
                      onCreateTaskRecord: (task) => _showCreateTaskRecordDialog(
                        context,
                        goalsStore,
                        task,
                      ),
                      attachmentStorage: effectiveAttachmentStorage,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }

  Future<void> _showCreateGoalDialog(
    BuildContext context,
    GoalsStore goalsStore,
  ) async {
    final goalTitle = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(title: '新建目标', hintText: '输入目标名称'),
    );

    if (goalTitle == null) {
      return;
    }

    goalsStore.createGoal(goalTitle);
  }

  Future<void> _showCreateProjectDialog(
    BuildContext context,
    GoalsStore goalsStore,
    GoalItem goal,
  ) async {
    final projectTitle = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(title: '新建项目', hintText: '输入项目名称'),
    );

    if (projectTitle == null) {
      return;
    }

    goalsStore.createProject(goal.id, projectTitle);
  }

  Future<void> _showEditGoalDialog(
    BuildContext context,
    GoalsStore goalsStore,
    GoalItem goal,
  ) async {
    final draft = await showDialog<_PlanIdentityDraft>(
      context: context,
      builder: (_) => _PlanIdentityDialog(
        title: '编辑目标',
        titleLabel: '目标名称',
        initialTitle: goal.title,
        initialIcon: goal.icon,
        initialDescription: goal.description,
        initialColorValue: goal.colorValue,
        defaultIcon: GoalItem.defaultIcon,
      ),
    );

    if (draft == null) {
      return;
    }

    goalsStore.updateGoalIdentity(
      goal.id,
      title: draft.title,
      icon: draft.icon,
      description: draft.description,
      colorValue: draft.colorValue,
    );
  }

  Future<void> _showEditProjectDialog(
    BuildContext context,
    GoalsStore goalsStore,
    ProjectItem project,
  ) async {
    final draft = await showDialog<_PlanIdentityDraft>(
      context: context,
      builder: (_) => _PlanIdentityDialog(
        title: '编辑项目',
        titleLabel: '项目名称',
        initialTitle: project.title,
        initialIcon: project.icon,
        initialDescription: project.description,
        initialColorValue: project.colorValue,
        defaultIcon: ProjectItem.defaultIcon,
        includePlanningMeta: true,
        initialDueDate: project.dueDate,
        initialPriority: project.priority,
        initialTags: project.tags,
        planningKeyPrefix: 'plan-project',
      ),
    );

    if (draft == null) {
      return;
    }

    await goalsStore.updateProjectIdentity(
      project.id,
      title: draft.title,
      icon: draft.icon,
      description: draft.description,
      colorValue: draft.colorValue,
    );
    await goalsStore.updateProjectPlanningMeta(
      project.id,
      dueDate: draft.dueDate,
      priority: draft.priority,
      tags: draft.tags,
    );
  }

  Future<void> _showCreateSubprojectDialog(
    BuildContext context,
    GoalsStore goalsStore,
    ProjectItem project,
  ) async {
    final subprojectTitle = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(title: '新建子项目', hintText: '输入子项目名称'),
    );

    if (subprojectTitle == null) {
      return;
    }

    goalsStore.createSubproject(project.id, subprojectTitle);
  }

  Future<void> _showEditSubprojectDialog(
    BuildContext context,
    GoalsStore goalsStore,
    SubprojectItem subproject,
  ) async {
    final subprojectTitle = await showDialog<String>(
      context: context,
      builder: (_) => _TitleDialog(
        title: '编辑分组',
        hintText: '输入分组名称',
        initialText: subproject.title,
        submitLabel: '保存',
      ),
    );

    if (subprojectTitle == null) {
      return;
    }

    goalsStore.updateSubprojectTitle(subproject.id, subprojectTitle);
  }

  Future<void> _showCreateTaskDialog(
    BuildContext context,
    GoalsStore goalsStore,
    ProjectItem project,
  ) async {
    final taskTitle = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(title: '新建行动', hintText: '输入行动名称'),
    );

    if (taskTitle == null) {
      return;
    }

    goalsStore.createTask(project.id, taskTitle);
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    GoalsStore goalsStore,
    GoalTaskItem task,
  ) async {
    final draft = await showDialog<_TaskEditDraft>(
      context: context,
      builder: (_) => _TaskEditDialog(task: task),
    );

    if (draft == null) {
      return;
    }

    await goalsStore.updateTaskTitle(task.id, draft.title);
    await goalsStore.updateTaskPlanningMeta(
      task.id,
      dueDate: draft.dueDate,
      priority: draft.priority,
      tags: draft.tags,
    );
  }

  Future<void> _showCreateSubprojectTaskDialog(
    BuildContext context,
    GoalsStore goalsStore,
    SubprojectItem subproject,
  ) async {
    final taskTitle = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(title: '新建行动', hintText: '输入行动名称'),
    );

    if (taskTitle == null) {
      return;
    }

    goalsStore.createTask(
      subproject.projectId,
      taskTitle,
      subprojectId: subproject.id,
    );
  }

  Future<void> _showGoalStructureSheet(
    BuildContext context,
    GoalsStore goalsStore,
    GoalItem goal,
  ) {
    final effectiveAttachmentStorage =
        attachmentStorage ?? const LocalPlanRecordAttachmentStorage();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AnimatedBuilder(
        animation: goalsStore,
        builder: (sheetContext, _) {
          return _GoalStructureSheet(
            goal: goal,
            goalsStore: goalsStore,
            attachmentStorage: effectiveAttachmentStorage,
            onEditGoal: () =>
                _showEditGoalDialog(sheetContext, goalsStore, goal),
            onCreateProject: () =>
                _showCreateProjectDialog(sheetContext, goalsStore, goal),
            onEditProject: (project) =>
                _showEditProjectDialog(sheetContext, goalsStore, project),
            onCreateSubproject: (project) =>
                _showCreateSubprojectDialog(sheetContext, goalsStore, project),
            onEditSubproject: (subproject) =>
                _showEditSubprojectDialog(sheetContext, goalsStore, subproject),
            onCreateProjectTask: (project) =>
                _showCreateTaskDialog(sheetContext, goalsStore, project),
            onCreateSubprojectTask: (subproject) =>
                _showCreateSubprojectTaskDialog(
                  sheetContext,
                  goalsStore,
                  subproject,
                ),
            onEditTask: (task) =>
                _showEditTaskDialog(sheetContext, goalsStore, task),
            onCreateProjectRecord: (project) => _showCreateProjectRecordDialog(
              sheetContext,
              goalsStore,
              project,
            ),
            onCreateTaskRecord: (task) =>
                _showCreateTaskRecordDialog(sheetContext, goalsStore, task),
          );
        },
      ),
    );
  }

  Future<void> _showCreateProjectRecordDialog(
    BuildContext context,
    GoalsStore goalsStore,
    ProjectItem project,
  ) async {
    final draft = await showDialog<_PlanRecordDraft>(
      context: context,
      builder: (_) =>
          _RecordDialog(title: '添加项目记录', contextLabel: project.title),
    );

    if (draft == null) {
      return;
    }

    if (draft.type == PlanRecordType.note) {
      await goalsStore.createProjectNoteRecord(
        project.id,
        draft.note ?? '',
        localDate: draft.localDate,
      );
      return;
    }

    await goalsStore.createProjectNumericRecord(
      project.id,
      draft.numericValue ?? 0,
      draft.unit ?? '',
      note: draft.note,
      localDate: draft.localDate,
    );
  }

  Future<void> _showCreateTaskRecordDialog(
    BuildContext context,
    GoalsStore goalsStore,
    GoalTaskItem task,
  ) async {
    final draft = await showDialog<_PlanRecordDraft>(
      context: context,
      builder: (_) => _RecordDialog(title: '添加行动记录', contextLabel: task.title),
    );

    if (draft == null) {
      return;
    }

    if (draft.type == PlanRecordType.note) {
      await goalsStore.createTaskNoteRecord(
        task.id,
        draft.note ?? '',
        localDate: draft.localDate,
      );
      return;
    }

    await goalsStore.createTaskNumericRecord(
      task.id,
      draft.numericValue ?? 0,
      draft.unit ?? '',
      note: draft.note,
      localDate: draft.localDate,
    );
  }
}

class _PlanOverviewSurface extends StatelessWidget {
  const _PlanOverviewSurface({required this.goalsStore});

  final GoalsStore goalsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalActions = goalsStore.tasks.length;
    final completedActions = goalsStore.tasks
        .where((task) => task.isCompleted)
        .length;
    final totalSubprojects = goalsStore.subprojects.length;
    final overviewProgress = totalActions == 0
        ? 0.0
        : completedActions / totalActions;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceXl),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '目标树概览',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '把长期结果拆成项目、子项目和行动。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              ),
              const SizedBox(width: AppThemeTokens.spaceMd),
              Text(
                '推进 ${goalsStore.completedCount} / ${goalsStore.totalCount}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PlanOverviewProgressLine(value: overviewProgress),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _PlanOverviewMetric(
                label: '目标',
                value: '${goalsStore.goals.length}',
              ),
              _PlanOverviewMetric(
                label: '项目',
                value: '${goalsStore.projects.length}',
              ),
              _PlanOverviewMetric(label: '子项目', value: '$totalSubprojects'),
              _PlanOverviewMetric(
                label: '已完成行动',
                value: '$completedActions / $totalActions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanOverviewMetric extends StatelessWidget {
  const _PlanOverviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.18 : 0.48,
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOverviewProgressLine extends StatelessWidget {
  const _PlanOverviewProgressLine({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final boundedValue = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: boundedValue,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.16 : 0.46,
        ),
        valueColor: AlwaysStoppedAnimation<Color>(
          colorScheme.primary.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}

enum _PlanSearchFilter {
  all('全部'),
  today('今天'),
  overdue('逾期'),
  highPriority('高优先级'),
  incomplete('未完成'),
  completed('已完成'),
  tag('标签');

  const _PlanSearchFilter(this.label);

  final String label;
}

enum _PlanSortMode {
  hierarchy('默认层级'),
  dueDate('截止日期'),
  priority('优先级');

  const _PlanSortMode(this.label);

  final String label;
}

enum _PlanSearchResultType { project, task }

class _PlanSearchResult {
  const _PlanSearchResult.project({
    required this.project,
    required this.context,
    required this.index,
  }) : task = null,
       type = _PlanSearchResultType.project;

  const _PlanSearchResult.task({
    required this.task,
    required this.context,
    required this.index,
  }) : project = null,
       type = _PlanSearchResultType.task;

  final _PlanSearchResultType type;
  final ProjectItem? project;
  final GoalTaskItem? task;
  final String context;
  final int index;

  String get title => project?.title ?? task?.title ?? '';

  String? get dueDate => project?.dueDate ?? task?.dueDate;

  PlanPriority? get priority => project?.priority ?? task?.priority;

  List<String> get tags => project?.tags ?? task?.tags ?? const <String>[];
}

class _PlanSearchSurface extends StatefulWidget {
  const _PlanSearchSurface({
    required this.goalsStore,
    required this.onEditProject,
    required this.onEditTask,
    required this.onOpenProjectDetail,
  });

  final GoalsStore goalsStore;
  final ValueChanged<ProjectItem> onEditProject;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<ProjectItem> onOpenProjectDetail;

  @override
  State<_PlanSearchSurface> createState() => _PlanSearchSurfaceState();
}

class _PlanSearchSurfaceState extends State<_PlanSearchSurface> {
  final TextEditingController _queryController = TextEditingController();
  _PlanSearchFilter _filter = _PlanSearchFilter.all;
  _PlanSortMode _sortMode = _PlanSortMode.hierarchy;
  String? _selectedTag;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tags = _availableTags();
    final results = _results();
    final active = _isActive;

    return SoftSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: AppThemeTokens.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '计划筛选',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (active)
                TextButton(
                  key: const ValueKey('plan-search-clear'),
                  onPressed: _clear,
                  child: const Text('清除'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '按截止日期、优先级和标签快速找到项目或行动。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('plan-search-field'),
            controller: _queryController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: '搜索项目 / 行动 / 标签',
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _PlanSearchFilter.values
                .map(
                  (filter) => FilterChip(
                    key: ValueKey('plan-filter-${filter.name}'),
                    label: Text(filter.label),
                    selected: _filter == filter,
                    onSelected: (_) {
                      setState(() {
                        _filter = filter;
                        if (filter != _PlanSearchFilter.tag) {
                          _selectedTag = null;
                        }
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(growable: false),
          ),
          if (_filter == _PlanSearchFilter.tag) ...[
            const SizedBox(height: 10),
            if (tags.isEmpty)
              Text(
                '还没有标签。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map(
                      (tag) => ChoiceChip(
                        key: ValueKey('plan-tag-$tag'),
                        label: Text('#$tag'),
                        selected: _selectedTag == tag,
                        onSelected: (_) {
                          setState(() {
                            _selectedTag = _selectedTag == tag ? null : tag;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '排序',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
              ..._PlanSortMode.values.map(
                (mode) => ChoiceChip(
                  key: ValueKey('plan-sort-${mode.name}'),
                  label: Text(mode.label),
                  selected: _sortMode == mode,
                  onSelected: (_) {
                    setState(() {
                      _sortMode = mode;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 14),
            Text(
              '筛选结果 ${results.length}',
              key: const ValueKey('plan-filtered-results'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              Text(
                '没有找到匹配的项目或行动。',
                key: const ValueKey('plan-filter-empty'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              )
            else
              Column(
                children: results
                    .map(
                      (result) => _PlanSearchResultRow(
                        result: result,
                        goalsStore: widget.goalsStore,
                        onEditProject: widget.onEditProject,
                        onEditTask: widget.onEditTask,
                        onOpenProjectDetail: widget.onOpenProjectDetail,
                      ),
                    )
                    .toList(growable: false),
              ),
          ],
        ],
      ),
    );
  }

  bool get _isActive =>
      _queryController.text.trim().isNotEmpty ||
      _filter != _PlanSearchFilter.all ||
      _sortMode != _PlanSortMode.hierarchy;

  void _clear() {
    setState(() {
      _queryController.clear();
      _filter = _PlanSearchFilter.all;
      _sortMode = _PlanSortMode.hierarchy;
      _selectedTag = null;
    });
  }

  List<String> _availableTags() {
    final tags = <String>{};
    for (final project in widget.goalsStore.projects) {
      tags.addAll(project.tags);
    }
    for (final task in widget.goalsStore.tasks) {
      tags.addAll(task.tags);
    }

    final sorted = tags.toList(growable: false)..sort();
    return sorted;
  }

  List<_PlanSearchResult> _results() {
    final results = <_PlanSearchResult>[];
    var index = 0;

    for (final project in widget.goalsStore.projects) {
      final goal = widget.goalsStore.goalById(project.goalId);
      final result = _PlanSearchResult.project(
        project: project,
        context: goal == null ? '目标不可用' : goal.title,
        index: index++,
      );
      if (_matches(result)) {
        results.add(result);
      }
    }

    for (final task in widget.goalsStore.tasks) {
      final project = widget.goalsStore.projectById(task.projectId);
      final goal = project == null
          ? null
          : widget.goalsStore.goalById(project.goalId);
      final subproject = task.subprojectId == null
          ? null
          : widget.goalsStore.subprojectById(task.subprojectId!);
      final context = _joinNonEmpty([
        goal?.title,
        project?.title,
        subproject?.title,
      ]);
      final result = _PlanSearchResult.task(
        task: task,
        context: context.isEmpty ? '计划位置不可用' : context,
        index: index++,
      );
      if (_matches(result)) {
        results.add(result);
      }
    }

    results.sort(_compareResults);
    return results;
  }

  bool _matches(_PlanSearchResult result) {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isNotEmpty && !_matchesQuery(result, query)) {
      return false;
    }

    return switch (_filter) {
      _PlanSearchFilter.all => true,
      _PlanSearchFilter.today => _isDueToday(result),
      _PlanSearchFilter.overdue => _isOverdue(result),
      _PlanSearchFilter.highPriority =>
        result.priority == PlanPriority.high ||
            result.priority == PlanPriority.urgent,
      _PlanSearchFilter.incomplete => !_isComplete(result),
      _PlanSearchFilter.completed => _isComplete(result),
      _PlanSearchFilter.tag =>
        _selectedTag != null && result.tags.contains(_selectedTag),
    };
  }

  bool _matchesQuery(_PlanSearchResult result, String query) {
    final searchable = [
      result.title,
      result.project?.description ?? '',
      result.context,
      ...result.tags,
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }

  int _compareResults(_PlanSearchResult a, _PlanSearchResult b) {
    final primary = switch (_sortMode) {
      _PlanSortMode.hierarchy => a.index.compareTo(b.index),
      _PlanSortMode.dueDate => _dueSortKey(
        a.dueDate,
      ).compareTo(_dueSortKey(b.dueDate)),
      _PlanSortMode.priority => _priorityRank(
        a.priority,
      ).compareTo(_priorityRank(b.priority)),
    };

    if (primary != 0) {
      return primary;
    }

    return a.index.compareTo(b.index);
  }

  bool _isDueToday(_PlanSearchResult result) {
    final project = result.project;
    if (project != null) {
      return widget.goalsStore.isProjectDueToday(project);
    }

    final task = result.task;
    return task != null && widget.goalsStore.isTaskDueToday(task);
  }

  bool _isOverdue(_PlanSearchResult result) {
    final project = result.project;
    if (project != null) {
      return widget.goalsStore.isProjectOverdue(project);
    }

    final task = result.task;
    return task != null && widget.goalsStore.isTaskOverdue(task);
  }

  bool _isComplete(_PlanSearchResult result) {
    final project = result.project;
    if (project != null) {
      return widget.goalsStore.computeProjectProgress(project.id).isComplete;
    }

    return result.task?.isCompleted ?? false;
  }
}

class _PlanSearchResultRow extends StatelessWidget {
  const _PlanSearchResultRow({
    required this.result,
    required this.goalsStore,
    required this.onEditProject,
    required this.onEditTask,
    required this.onOpenProjectDetail,
  });

  final _PlanSearchResult result;
  final GoalsStore goalsStore;
  final ValueChanged<ProjectItem> onEditProject;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<ProjectItem> onOpenProjectDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isProject = result.type == _PlanSearchResultType.project;
    final project = result.project;
    final task = result.task;
    final overdue = project == null
        ? (task != null && goalsStore.isTaskOverdue(task))
        : goalsStore.isProjectOverdue(project);
    final dueToday = project == null
        ? (task != null && goalsStore.isTaskDueToday(task))
        : goalsStore.isProjectDueToday(project);
    final meta = _planningMetaText(
      dueDate: result.dueDate,
      priority: result.priority,
      tags: result.tags,
      overdue: overdue,
      dueToday: dueToday,
    );

    return Container(
      key: ValueKey(
        isProject
            ? 'plan-filtered-result-project-${project!.id}'
            : 'plan-filtered-result-task-${task!.id}',
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.20 : 0.48,
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                isProject ? '项目' : '行动',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                result.context,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            result.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (meta != null) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: overdue
                    ? colorScheme.error
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (project != null)
                TextButton(
                  onPressed: () => onOpenProjectDetail(project),
                  child: const Text('项目详情'),
                ),
              TextButton(
                onPressed: () {
                  if (project != null) {
                    onEditProject(project);
                    return;
                  }
                  if (task != null) {
                    onEditTask(task);
                  }
                },
                child: Text(isProject ? '编辑项目' : '编辑行动'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _joinNonEmpty(Iterable<String?> values, {String separator = ' / '}) {
  return values
      .where((value) => value != null && value.trim().isNotEmpty)
      .map((value) => value!.trim())
      .join(separator);
}

String? _planningMetaText({
  required String? dueDate,
  required PlanPriority? priority,
  required List<String> tags,
  bool overdue = false,
  bool dueToday = false,
}) {
  final parts = <String>[];
  if (dueDate != null) {
    if (overdue) {
      parts.add('逾期 $dueDate');
    } else if (dueToday) {
      parts.add('今天截止');
    } else {
      parts.add('截止 $dueDate');
    }
  }

  final priorityText = _priorityLabel(priority);
  if (priorityText != null) {
    parts.add('优先级 $priorityText');
  }

  if (tags.isNotEmpty) {
    final visibleTags = tags.take(2).map((tag) => '#$tag').join(' ');
    final hiddenCount = tags.length - 2;
    parts.add(hiddenCount > 0 ? '$visibleTags +$hiddenCount' : visibleTags);
  }

  return parts.isEmpty ? null : parts.join(' · ');
}

String? _priorityLabel(PlanPriority? priority) {
  return switch (priority) {
    PlanPriority.low => '低',
    PlanPriority.medium => '中',
    PlanPriority.high => '高',
    PlanPriority.urgent => '紧急',
    null => null,
  };
}

String _dueSortKey(String? dueDate) => dueDate ?? '9999-99-99';

int _priorityRank(PlanPriority? priority) {
  return switch (priority) {
    PlanPriority.urgent => 0,
    PlanPriority.high => 1,
    PlanPriority.medium => 2,
    PlanPriority.low => 3,
    null => 4,
  };
}

String _formatLocalDate(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

DateTime? _parseLocalDateForPicker(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final parts = value.split('-');
  if (parts.length != 3) {
    return null;
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }

  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }

  return parsed;
}

class _AddGoalSection extends StatelessWidget {
  const _AddGoalSection({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('写下长期结果', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '先确定方向，再拆成项目、子项目和行动。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            key: const ValueKey('add-goal-button'),
            onPressed: onPressed,
            child: const Text('添加目标'),
          ),
        ],
      ),
    );
  }
}

class _GoalsListHeader extends StatelessWidget {
  const _GoalsListHeader({
    required this.totalCount,
    required this.completedCount,
  });

  final int totalCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(child: Text('目标规划', style: theme.textTheme.titleLarge)),
        Text(
          '推进 $completedCount / $totalCount',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GoalsEmptyState extends StatelessWidget {
  const _GoalsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey('goals-empty-state'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('还没有长期目标', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '先写下一个想长期推进的结果。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleDialog extends StatefulWidget {
  const _TitleDialog({
    required this.title,
    required this.hintText,
    this.initialText = '',
    this.submitLabel = '创建',
  });

  final String title;
  final String hintText;
  final String initialText;
  final String submitLabel;

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: [
        FilledButton(
          key: ValueKey<String>('title-dialog-submit-${widget.submitLabel}'),
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}

class _PlanIdentityDraft {
  const _PlanIdentityDraft({
    required this.title,
    required this.icon,
    required this.description,
    required this.colorValue,
    this.dueDate,
    this.priority,
    this.tags = const <String>[],
  });

  final String title;
  final String icon;
  final String description;
  final int colorValue;
  final String? dueDate;
  final PlanPriority? priority;
  final List<String> tags;
}

class _TaskEditDraft {
  const _TaskEditDraft({
    required this.title,
    this.dueDate,
    this.priority,
    this.tags = const <String>[],
  });

  final String title;
  final String? dueDate;
  final PlanPriority? priority;
  final List<String> tags;
}

class _PlanningMetadataController {
  _PlanningMetadataController({
    this.dueDate,
    this.priority,
    List<String> tags = const <String>[],
  }) : tags = List<String>.of(tags);

  String? dueDate;
  PlanPriority? priority;
  final List<String> tags;
  final TextEditingController tagController = TextEditingController();

  void dispose() {
    tagController.dispose();
  }
}

class _PlanningMetadataEditor extends StatefulWidget {
  const _PlanningMetadataEditor({
    required this.controller,
    required this.keyPrefix,
  });

  final _PlanningMetadataController controller;
  final String keyPrefix;

  @override
  State<_PlanningMetadataEditor> createState() =>
      _PlanningMetadataEditorState();
}

class _PlanningMetadataEditorState extends State<_PlanningMetadataEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dueDate = widget.controller.dueDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '计划属性',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InputChip(
              label: Text(dueDate == null ? '未设置截止日期' : '截止 $dueDate'),
              avatar: const Icon(Icons.event_rounded, size: 18),
              onPressed: _pickDueDate,
              visualDensity: VisualDensity.compact,
            ),
            OutlinedButton(
              key: ValueKey('${widget.keyPrefix}-due-date-picker'),
              onPressed: _pickDueDate,
              child: const Text('选择日期'),
            ),
            if (dueDate != null)
              TextButton(
                key: ValueKey('${widget.keyPrefix}-due-date-clear'),
                onPressed: () {
                  setState(() {
                    widget.controller.dueDate = null;
                  });
                },
                child: const Text('清除日期'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '优先级',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: ValueKey('${widget.keyPrefix}-priority-none'),
              label: const Text('普通'),
              selected: widget.controller.priority == null,
              onSelected: (_) {
                setState(() {
                  widget.controller.priority = null;
                });
              },
              visualDensity: VisualDensity.compact,
            ),
            ...PlanPriority.values.map(
              (priority) => ChoiceChip(
                key: ValueKey('${widget.keyPrefix}-priority-${priority.name}'),
                label: Text(_priorityLabel(priority)!),
                selected: widget.controller.priority == priority,
                onSelected: (_) {
                  setState(() {
                    widget.controller.priority = priority;
                  });
                },
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '标签',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: ValueKey('${widget.keyPrefix}-tags-field'),
                controller: widget.controller.tagController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '添加标签',
                  isDense: true,
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              key: ValueKey('${widget.keyPrefix}-tags-add'),
              onPressed: _addTag,
              child: const Text('添加'),
            ),
          ],
        ),
        if (widget.controller.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.tags
                .map(
                  (tag) => InputChip(
                    key: ValueKey('${widget.keyPrefix}-tag-$tag'),
                    label: Text('#$tag'),
                    onDeleted: () {
                      setState(() {
                        widget.controller.tags.remove(tag);
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          '用于搜索、筛选和排序，不会改变进度。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate = _parseLocalDateForPicker(widget.controller.dueDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      widget.controller.dueDate = _formatLocalDate(picked);
    });
  }

  void _addTag() {
    final raw = widget.controller.tagController.text.trim();
    if (raw.isEmpty) {
      return;
    }

    final tag = raw.length > 16 ? raw.substring(0, 16) : raw;
    setState(() {
      if (!widget.controller.tags.contains(tag) &&
          widget.controller.tags.length < 8) {
        widget.controller.tags.add(tag);
      }
      widget.controller.tagController.clear();
    });
  }
}

class _TaskEditDialog extends StatefulWidget {
  const _TaskEditDialog({required this.task});

  final GoalTaskItem task;

  @override
  State<_TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<_TaskEditDialog> {
  late final TextEditingController _titleController;
  late final _PlanningMetadataController _planningController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _planningController = _PlanningMetadataController(
      dueDate: widget.task.dueDate,
      priority: widget.task.priority,
      tags: widget.task.tags,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _planningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('编辑行动'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const ValueKey('plan-task-title-field'),
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '行动名称'),
            ),
            _PlanningMetadataEditor(
              controller: _planningController,
              keyPrefix: 'plan-task',
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('plan-task-submit'),
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorText = '请先填写行动名称';
      });
      return;
    }

    Navigator.of(context).pop(
      _TaskEditDraft(
        title: title,
        dueDate: _planningController.dueDate,
        priority: _planningController.priority,
        tags: List<String>.unmodifiable(_planningController.tags),
      ),
    );
  }
}

class _PlanIdentityDialog extends StatefulWidget {
  const _PlanIdentityDialog({
    required this.title,
    required this.titleLabel,
    required this.initialTitle,
    required this.initialIcon,
    required this.initialDescription,
    required this.initialColorValue,
    required this.defaultIcon,
    this.includePlanningMeta = false,
    this.initialDueDate,
    this.initialPriority,
    this.initialTags = const <String>[],
    this.planningKeyPrefix = 'plan-identity',
  });

  final String title;
  final String titleLabel;
  final String initialTitle;
  final String initialIcon;
  final String initialDescription;
  final int initialColorValue;
  final String defaultIcon;
  final bool includePlanningMeta;
  final String? initialDueDate;
  final PlanPriority? initialPriority;
  final List<String> initialTags;
  final String planningKeyPrefix;

  @override
  State<_PlanIdentityDialog> createState() => _PlanIdentityDialogState();
}

class _PlanIdentityDialogState extends State<_PlanIdentityDialog> {
  static const _quickIcons = <String>[
    '🎯',
    '📁',
    '📚',
    '💪',
    '🧠',
    '✍️',
    '🧩',
    '🚀',
    '🌱',
    '🧭',
  ];

  static const _palette = <int>[
    0xFF7A8A6A,
    0xFF6E7E9E,
    0xFF8A7465,
    0xFF7E748F,
    0xFF6B8A86,
    0xFF9A835F,
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _iconController;
  late final TextEditingController _descriptionController;
  late final _PlanningMetadataController _planningController;
  late int _selectedColorValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _iconController = TextEditingController(text: widget.initialIcon);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _planningController = _PlanningMetadataController(
      dueDate: widget.initialDueDate,
      priority: widget.initialPriority,
      tags: widget.initialTags,
    );
    _selectedColorValue = widget.initialColorValue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    _planningController.dispose();
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
            TextField(
              key: const ValueKey('plan-identity-title-field'),
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: widget.titleLabel),
            ),
            const SizedBox(height: 14),
            Text(
              '图标',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickIcons
                  .map(
                    (icon) => ChoiceChip(
                      key: ValueKey('plan-identity-icon-$icon'),
                      label: Text(icon),
                      selected: _iconController.text.trim() == icon,
                      onSelected: (_) {
                        setState(() {
                          _iconController.text = icon;
                        });
                      },
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('plan-identity-icon-field'),
              controller: _iconController,
              decoration: InputDecoration(
                labelText: '自定义图标',
                hintText: widget.defaultIcon,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('plan-identity-description-field'),
              controller: _descriptionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '写一句这个目标/项目的方向',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '颜色',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _palette
                  .map((value) {
                    final selected = _selectedColorValue == value;
                    final color = Color(value);

                    return InkWell(
                      key: ValueKey('plan-identity-color-$value'),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusPill,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedColorValue = value;
                        });
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? color
                                : AppThemeTokens.borderTone(colorScheme),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: selected
                            ? Icon(Icons.check_rounded, size: 17, color: color)
                            : null,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
            if (widget.includePlanningMeta)
              _PlanningMetadataEditor(
                controller: _planningController,
                keyPrefix: widget.planningKeyPrefix,
              ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('plan-identity-submit'),
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorText = '请先填写名称';
      });
      return;
    }

    final icon = _iconController.text.trim().isEmpty
        ? widget.defaultIcon
        : _iconController.text.trim();

    Navigator.of(context).pop(
      _PlanIdentityDraft(
        title: title,
        icon: icon,
        description: _descriptionController.text.trim(),
        colorValue: _selectedColorValue,
        dueDate: widget.includePlanningMeta
            ? _planningController.dueDate
            : null,
        priority: widget.includePlanningMeta
            ? _planningController.priority
            : null,
        tags: widget.includePlanningMeta
            ? List<String>.unmodifiable(_planningController.tags)
            : const <String>[],
      ),
    );
  }
}

class _GoalHierarchyCard extends StatelessWidget {
  const _GoalHierarchyCard({
    required this.goal,
    required this.goalsStore,
    required this.onOpenFocus,
    required this.onEditGoal,
    required this.onCreateProject,
    required this.onEditProject,
    required this.onCreateSubproject,
    required this.onEditSubproject,
    required this.onCreateProjectTask,
    required this.onCreateSubprojectTask,
    required this.onEditTask,
    required this.onCreateProjectRecord,
    required this.onCreateTaskRecord,
    required this.attachmentStorage,
  });

  final GoalItem goal;
  final GoalsStore goalsStore;
  final VoidCallback onOpenFocus;
  final VoidCallback onEditGoal;
  final VoidCallback onCreateProject;
  final ValueChanged<ProjectItem> onEditProject;
  final ValueChanged<ProjectItem> onCreateSubproject;
  final ValueChanged<SubprojectItem> onEditSubproject;
  final ValueChanged<ProjectItem> onCreateProjectTask;
  final ValueChanged<SubprojectItem> onCreateSubprojectTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<ProjectItem> onCreateProjectRecord;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final projects = goalsStore.getProjectsForGoal(goal.id);
    final progress = goalsStore.computeGoalProgress(goal.id);
    final projectCount = projects.length;
    final subprojectCount = projects.fold<int>(
      0,
      (count, project) =>
          count + goalsStore.getSubprojectsForProject(project.id).length,
    );
    final taskCount = goalsStore.taskCountForGoal(goal.id);

    return PlanGoalCard(
      key: ValueKey('goal-row-${goal.id}'),
      goalId: goal.id,
      title: goal.title,
      icon: goal.icon,
      description: goal.description,
      colorValue: goal.colorValue,
      projectCount: projectCount,
      subprojectCount: subprojectCount,
      actionCount: taskCount,
      completedActionCount: progress.completedTasks,
      progressLabel: progress.label,
      hasActions: progress.hasTasks,
      progressValue: progress.hasTasks ? progress.percentage / 100 : null,
      progressTextKey: ValueKey('goal-progress-${goal.id}'),
      openTreeKey: ValueKey('goal-open-focus-${goal.id}'),
      editGoalKey: ValueKey('goal-edit-${goal.id}'),
      addProjectKey: ValueKey('goal-add-project-${goal.id}'),
      onOpenTree: onOpenFocus,
      onEditGoal: onEditGoal,
      onAddProject: onCreateProject,
      child: projects.isEmpty
          ? const _InlineCue(
              cueKey: ValueKey('goal-empty-projects-cue'),
              text: '先添加项目，把目标拆成推进方向。',
            )
          : Column(
              children: projects
                  .map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProjectBranch(
                        project: project,
                        goalsStore: goalsStore,
                        onEditProject: () => onEditProject(project),
                        onCreateSubproject: () => onCreateSubproject(project),
                        onCreateProjectTask: () => onCreateProjectTask(project),
                        onEditSubproject: onEditSubproject,
                        onCreateSubprojectTask: onCreateSubprojectTask,
                        onEditTask: onEditTask,
                        onCreateProjectRecord: () =>
                            onCreateProjectRecord(project),
                        onCreateTaskRecord: onCreateTaskRecord,
                        attachmentStorage: attachmentStorage,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _ProjectBranch extends StatelessWidget {
  const _ProjectBranch({
    required this.project,
    required this.goalsStore,
    required this.onEditProject,
    required this.onCreateSubproject,
    required this.onCreateProjectTask,
    required this.onEditSubproject,
    required this.onCreateSubprojectTask,
    required this.onEditTask,
    required this.onCreateProjectRecord,
    required this.onCreateTaskRecord,
    required this.attachmentStorage,
  });

  final ProjectItem project;
  final GoalsStore goalsStore;
  final VoidCallback onEditProject;
  final VoidCallback onCreateSubproject;
  final VoidCallback onCreateProjectTask;
  final ValueChanged<SubprojectItem> onEditSubproject;
  final ValueChanged<SubprojectItem> onCreateSubprojectTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final VoidCallback onCreateProjectRecord;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final directTasks = goalsStore.getDirectTasksForProject(project.id);
    final subprojects = goalsStore.getSubprojectsForProject(project.id);
    final progress = goalsStore.computeProjectProgress(project.id);
    final totalTasks = goalsStore.getTasksForProject(project.id).length;
    final planningMeta = _planningMetaText(
      dueDate: project.dueDate,
      priority: project.priority,
      tags: project.tags,
      overdue: goalsStore.isProjectOverdue(project),
      dueToday: goalsStore.isProjectDueToday(project),
    );

    return PlanTreeRow(
      key: ValueKey('project-branch-${project.id}'),
      type: PlanTreeRowType.project,
      title: project.title,
      identitySeed: project.id,
      icon: project.icon,
      description: project.description,
      colorValue: project.colorValue,
      metadataText: _joinNonEmpty([
        '子项目 ${subprojects.length} · 行动 $totalTasks',
        planningMeta,
      ], separator: ' · '),
      progressText: '行动 $totalTasks · ${progress.label}',
      progressTextKey: ValueKey('project-progress-${project.id}'),
      progressValue: progress.hasTasks ? progress.percentage / 100 : null,
      hasProgress: progress.hasTasks,
      showConnector: true,
      showProgressDots: true,
      editKey: ValueKey('project-edit-${project.id}'),
      detailKey: ValueKey('project-open-detail-${project.id}'),
      addRecordKey: ValueKey('project-add-record-${project.id}'),
      addSubprojectKey: ValueKey('project-add-subproject-${project.id}'),
      addTaskKey: ValueKey('project-add-task-${project.id}'),
      onEdit: onEditProject,
      onOpenDetail: () => _showProjectDetailSheet(
        context,
        project: project,
        goalsStore: goalsStore,
        attachmentStorage: attachmentStorage,
      ),
      onAddRecord: onCreateProjectRecord,
      onAddSubproject: onCreateSubproject,
      onAddTask: onCreateProjectTask,
      emptyAffordanceKey: directTasks.isEmpty && subprojects.isEmpty
          ? const ValueKey('project-empty-tasks-cue')
          : null,
      emptyAffordanceText: directTasks.isEmpty && subprojects.isEmpty
          ? '还没有行动 · 添加行动'
          : null,
      onEmptyAffordanceTap: directTasks.isEmpty && subprojects.isEmpty
          ? onCreateProjectTask
          : null,
      children: [
        ...directTasks.map(
          (task) => PlanTreeRow(
            type: PlanTreeRowType.task,
            title: task.title,
            completed: task.isCompleted,
            metadataText: _planningMetaText(
              dueDate: task.dueDate,
              priority: task.priority,
              tags: task.tags,
              overdue: goalsStore.isTaskOverdue(task),
              dueToday: goalsStore.isTaskDueToday(task),
            ),
            toggleKey: ValueKey('goal-task-toggle-${task.id}'),
            editKey: ValueKey('goal-task-edit-${task.id}'),
            addRecordKey: ValueKey('goal-task-add-record-${task.id}'),
            onToggleTask: () => goalsStore.toggleTask(task.id),
            onEdit: () => onEditTask(task),
            onAddRecord: () => onCreateTaskRecord(task),
          ),
        ),
        if (directTasks.isNotEmpty && subprojects.isNotEmpty)
          const SizedBox(height: 8),
        ...subprojects.map(
          (subproject) => _SubprojectBranch(
            subproject: subproject,
            goalsStore: goalsStore,
            onEdit: () => onEditSubproject(subproject),
            onCreateTask: () => onCreateSubprojectTask(subproject),
            onEditTask: onEditTask,
            onCreateTaskRecord: onCreateTaskRecord,
          ),
        ),
        _ProjectRecordsPanel(
          project: project,
          goalsStore: goalsStore,
          attachmentStorage: attachmentStorage,
        ),
      ],
    );
  }
}

class _SubprojectBranch extends StatelessWidget {
  const _SubprojectBranch({
    required this.subproject,
    required this.goalsStore,
    required this.onEdit,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onCreateTaskRecord,
  });

  final SubprojectItem subproject;
  final GoalsStore goalsStore;
  final VoidCallback onEdit;
  final VoidCallback onCreateTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;

  @override
  Widget build(BuildContext context) {
    final tasks = goalsStore.getTasksForSubproject(subproject.id);
    final progress = goalsStore.computeSubprojectProgress(subproject.id);

    return PlanTreeRow(
      key: ValueKey('subproject-branch-${subproject.id}'),
      type: PlanTreeRowType.subproject,
      level: 1,
      title: subproject.title,
      identitySeed: subproject.id,
      progressText: '行动 ${tasks.length} · ${progress.label}',
      progressTextKey: ValueKey('subproject-progress-${subproject.id}'),
      progressValue: progress.hasTasks ? progress.percentage / 100 : null,
      hasProgress: progress.hasTasks,
      showProgressDots: true,
      editKey: ValueKey('subproject-edit-${subproject.id}'),
      addTaskKey: ValueKey('subproject-add-task-${subproject.id}'),
      onEdit: onEdit,
      onAddTask: onCreateTask,
      emptyAffordanceKey: tasks.isEmpty
          ? const ValueKey('subproject-empty-tasks-cue')
          : null,
      emptyAffordanceText: tasks.isEmpty ? '还没有行动 · 添加行动' : null,
      onEmptyAffordanceTap: tasks.isEmpty ? onCreateTask : null,
      children: tasks
          .map(
            (task) => PlanTreeRow(
              type: PlanTreeRowType.task,
              title: task.title,
              completed: task.isCompleted,
              metadataText: _planningMetaText(
                dueDate: task.dueDate,
                priority: task.priority,
                tags: task.tags,
                overdue: goalsStore.isTaskOverdue(task),
                dueToday: goalsStore.isTaskDueToday(task),
              ),
              toggleKey: ValueKey('goal-task-toggle-${task.id}'),
              editKey: ValueKey('goal-task-edit-${task.id}'),
              addRecordKey: ValueKey('goal-task-add-record-${task.id}'),
              onToggleTask: () => goalsStore.toggleTask(task.id),
              onEdit: () => onEditTask(task),
              onAddRecord: () => onCreateTaskRecord(task),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _GoalStructureSheet extends StatelessWidget {
  const _GoalStructureSheet({
    required this.goal,
    required this.goalsStore,
    required this.onEditGoal,
    required this.onCreateProject,
    required this.onEditProject,
    required this.onCreateSubproject,
    required this.onEditSubproject,
    required this.onCreateProjectTask,
    required this.onCreateSubprojectTask,
    required this.onEditTask,
    required this.onCreateProjectRecord,
    required this.onCreateTaskRecord,
    required this.attachmentStorage,
  });

  final GoalItem goal;
  final GoalsStore goalsStore;
  final VoidCallback onEditGoal;
  final VoidCallback onCreateProject;
  final ValueChanged<ProjectItem> onEditProject;
  final ValueChanged<ProjectItem> onCreateSubproject;
  final ValueChanged<SubprojectItem> onEditSubproject;
  final ValueChanged<ProjectItem> onCreateProjectTask;
  final ValueChanged<SubprojectItem> onCreateSubprojectTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<ProjectItem> onCreateProjectRecord;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final projects = goalsStore.getProjectsForGoal(goal.id);
    final progress = goalsStore.computeGoalProgress(goal.id);

    return SafeArea(
      child: Container(
        key: ValueKey('goal-focus-sheet-${goal.id}'),
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          8,
          AppThemeTokens.pagePadding,
          MediaQuery.of(context).viewInsets.bottom + AppThemeTokens.pagePadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('目标树结构', style: theme.textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(
                goal.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '项目 ${projects.length} · 行动 ${goalsStore.taskCountForGoal(goal.id)} · ${progress.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: progress.hasTasks
                      ? colorScheme.primary
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ProgressRail(
                value: progress.hasTasks ? progress.percentage / 100 : null,
                height: 6,
                fillColor: colorScheme.primary.withValues(alpha: 0.72),
                backgroundColor: AppThemeTokens.borderTone(
                  colorScheme,
                ).withValues(alpha: 0.42),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton.tonalIcon(
                    key: ValueKey('goal-focus-edit-${goal.id}'),
                    onPressed: onEditGoal,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('编辑目标'),
                  ),
                  FilledButton.tonalIcon(
                    key: ValueKey('goal-focus-add-project-${goal.id}'),
                    onPressed: onCreateProject,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('添加项目'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (projects.isEmpty)
                _InlineCue(
                  cueKey: const ValueKey('goal-focus-empty-projects-cue'),
                  onTap: onCreateProject,
                  text: '还没有项目 · 添加推进方向',
                )
              else
                Column(
                  children: projects
                      .map(
                        (project) => _FocusedProjectBlock(
                          project: project,
                          goalsStore: goalsStore,
                          onEditProject: () => onEditProject(project),
                          onCreateSubproject: () => onCreateSubproject(project),
                          onCreateProjectTask: () =>
                              onCreateProjectTask(project),
                          onEditSubproject: onEditSubproject,
                          onCreateSubprojectTask: onCreateSubprojectTask,
                          onEditTask: onEditTask,
                          onCreateProjectRecord: () =>
                              onCreateProjectRecord(project),
                          onCreateTaskRecord: onCreateTaskRecord,
                          attachmentStorage: attachmentStorage,
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusedProjectBlock extends StatelessWidget {
  const _FocusedProjectBlock({
    required this.project,
    required this.goalsStore,
    required this.onEditProject,
    required this.onCreateSubproject,
    required this.onCreateProjectTask,
    required this.onEditSubproject,
    required this.onCreateSubprojectTask,
    required this.onEditTask,
    required this.onCreateProjectRecord,
    required this.onCreateTaskRecord,
    required this.attachmentStorage,
  });

  final ProjectItem project;
  final GoalsStore goalsStore;
  final VoidCallback onEditProject;
  final VoidCallback onCreateSubproject;
  final VoidCallback onCreateProjectTask;
  final ValueChanged<SubprojectItem> onEditSubproject;
  final ValueChanged<SubprojectItem> onCreateSubprojectTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final VoidCallback onCreateProjectRecord;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final directTasks = goalsStore.getDirectTasksForProject(project.id);
    final subprojects = goalsStore.getSubprojectsForProject(project.id);
    final progress = goalsStore.computeProjectProgress(project.id);
    final totalTasks = goalsStore.getTasksForProject(project.id).length;
    final planningMeta = _planningMetaText(
      dueDate: project.dueDate,
      priority: project.priority,
      tags: project.tags,
      overdue: goalsStore.isProjectOverdue(project),
      dueToday: goalsStore.isProjectDueToday(project),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PlanTreeRow(
        type: PlanTreeRowType.project,
        title: project.title,
        identitySeed: project.id,
        icon: project.icon,
        description: project.description,
        colorValue: project.colorValue,
        metadataText: _joinNonEmpty([
          '子项目 ${subprojects.length} · 行动 $totalTasks',
          planningMeta,
        ], separator: ' · '),
        progressText: '行动 $totalTasks · ${progress.label}',
        progressValue: progress.hasTasks ? progress.percentage / 100 : null,
        hasProgress: progress.hasTasks,
        editKey: ValueKey('goal-focus-project-edit-${project.id}'),
        detailKey: ValueKey('goal-focus-project-open-detail-${project.id}'),
        addRecordKey: ValueKey('goal-focus-project-add-record-${project.id}'),
        addSubprojectKey: ValueKey(
          'goal-focus-project-add-subproject-${project.id}',
        ),
        addTaskKey: ValueKey('goal-focus-project-add-task-${project.id}'),
        onEdit: onEditProject,
        onOpenDetail: () => _showProjectDetailSheet(
          context,
          project: project,
          goalsStore: goalsStore,
          attachmentStorage: attachmentStorage,
        ),
        onAddRecord: onCreateProjectRecord,
        onAddSubproject: onCreateSubproject,
        onAddTask: onCreateProjectTask,
        emptyAffordanceKey: directTasks.isEmpty && subprojects.isEmpty
            ? const ValueKey('goal-focus-empty-tasks-cue')
            : null,
        emptyAffordanceText: directTasks.isEmpty && subprojects.isEmpty
            ? '还没有行动 · 添加行动'
            : null,
        onEmptyAffordanceTap: directTasks.isEmpty && subprojects.isEmpty
            ? onCreateProjectTask
            : null,
        children: [
          ...directTasks.map(
            (task) => PlanTreeRow(
              type: PlanTreeRowType.task,
              title: task.title,
              completed: task.isCompleted,
              metadataText: _planningMetaText(
                dueDate: task.dueDate,
                priority: task.priority,
                tags: task.tags,
                overdue: goalsStore.isTaskOverdue(task),
                dueToday: goalsStore.isTaskDueToday(task),
              ),
              editKey: ValueKey('goal-focus-task-edit-${task.id}'),
              addRecordKey: ValueKey('goal-focus-task-add-record-${task.id}'),
              onEdit: () => onEditTask(task),
              onAddRecord: () => onCreateTaskRecord(task),
            ),
          ),
          ...subprojects.map(
            (subproject) => _FocusedSubprojectBlock(
              subproject: subproject,
              goalsStore: goalsStore,
              onEdit: () => onEditSubproject(subproject),
              onCreateTask: () => onCreateSubprojectTask(subproject),
              onEditTask: onEditTask,
              onCreateTaskRecord: onCreateTaskRecord,
            ),
          ),
          _ProjectRecordsPanel(
            project: project,
            goalsStore: goalsStore,
            attachmentStorage: attachmentStorage,
          ),
        ],
      ),
    );
  }
}

class _FocusedSubprojectBlock extends StatelessWidget {
  const _FocusedSubprojectBlock({
    required this.subproject,
    required this.goalsStore,
    required this.onEdit,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onCreateTaskRecord,
  });

  final SubprojectItem subproject;
  final GoalsStore goalsStore;
  final VoidCallback onEdit;
  final VoidCallback onCreateTask;
  final ValueChanged<GoalTaskItem> onEditTask;
  final ValueChanged<GoalTaskItem> onCreateTaskRecord;

  @override
  Widget build(BuildContext context) {
    final tasks = goalsStore.getTasksForSubproject(subproject.id);
    final progress = goalsStore.computeSubprojectProgress(subproject.id);

    return PlanTreeRow(
      type: PlanTreeRowType.subproject,
      level: 1,
      title: subproject.title,
      identitySeed: subproject.id,
      progressText: '行动 ${tasks.length} · ${progress.label}',
      progressValue: progress.hasTasks ? progress.percentage / 100 : null,
      hasProgress: progress.hasTasks,
      editKey: ValueKey('goal-focus-subproject-edit-${subproject.id}'),
      addTaskKey: ValueKey('goal-focus-subproject-add-task-${subproject.id}'),
      onEdit: onEdit,
      onAddTask: onCreateTask,
      emptyAffordanceKey: tasks.isEmpty
          ? ValueKey('goal-focus-subproject-empty-${subproject.id}')
          : null,
      emptyAffordanceText: tasks.isEmpty ? '还没有行动 · 添加行动' : null,
      onEmptyAffordanceTap: tasks.isEmpty ? onCreateTask : null,
      children: tasks
          .map(
            (task) => PlanTreeRow(
              type: PlanTreeRowType.task,
              title: task.title,
              completed: task.isCompleted,
              metadataText: _planningMetaText(
                dueDate: task.dueDate,
                priority: task.priority,
                tags: task.tags,
                overdue: goalsStore.isTaskOverdue(task),
                dueToday: goalsStore.isTaskDueToday(task),
              ),
              editKey: ValueKey('goal-focus-task-edit-${task.id}'),
              addRecordKey: ValueKey('goal-focus-task-add-record-${task.id}'),
              onEdit: () => onEditTask(task),
              onAddRecord: () => onCreateTaskRecord(task),
            ),
          )
          .toList(growable: false),
    );
  }
}

Future<void> _showProjectDetailSheet(
  BuildContext context, {
  required ProjectItem project,
  required GoalsStore goalsStore,
  required PlanRecordAttachmentStorage attachmentStorage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => AnimatedBuilder(
      animation: goalsStore,
      builder: (sheetContext, _) {
        return _ProjectStatsSheet(
          project: project,
          goalsStore: goalsStore,
          attachmentStorage: attachmentStorage,
        );
      },
    ),
  );
}

class _ProjectRecordsPanel extends StatelessWidget {
  const _ProjectRecordsPanel({
    required this.project,
    required this.goalsStore,
    required this.attachmentStorage,
  });

  final ProjectItem project;
  final GoalsStore goalsStore;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stats = goalsStore.computeProjectRecordStats(project.id);
    final records = goalsStore.recordsForProject(project.id);
    final visibleRecords = records.take(4).toList(growable: false);

    return Container(
      key: ValueKey('project-records-${project.id}'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '项目记录',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${stats.currentMonthRecordCount} 本月',
                key: ValueKey('project-record-month-count-${project.id}'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                key: ValueKey('project-record-open-stats-${project.id}'),
                onPressed: () => _showProjectDetailSheet(
                  context,
                  project: project,
                  goalsStore: goalsStore,
                  attachmentStorage: attachmentStorage,
                ),
                icon: const Icon(Icons.query_stats_rounded, size: 16),
                label: const Text('详情'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            key: ValueKey('project-record-stats-${project.id}'),
            children: [
              _ProjectRecordStatChip(
                label: '记录',
                value: '${stats.recordCount}',
                valueKey: ValueKey('project-record-count-${project.id}'),
              ),
              _ProjectRecordStatChip(
                label: '活跃天',
                value: '${stats.activeDaysCount}',
                valueKey: ValueKey('project-record-active-days-${project.id}'),
              ),
              ...stats.numericTotalsByUnit.entries.map(
                (entry) => _ProjectRecordStatChip(
                  label: entry.key.isEmpty ? '数值' : entry.key,
                  value: _formatRecordNumber(entry.value),
                  valueKey: ValueKey(
                    'project-record-total-${project.id}-${entry.key}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (visibleRecords.isEmpty)
            Text(
              '还没有记录，先为项目或行动补一条进展。',
              key: ValueKey('project-record-empty-${project.id}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            )
          else
            Column(
              key: ValueKey('project-record-list-${project.id}'),
              children: visibleRecords
                  .map(
                    (record) => _ProjectRecordRow(
                      record: record,
                      attachment: goalsStore.attachmentForRecord(record.id),
                      attachmentStorage: attachmentStorage,
                      onOpenAttachment: () =>
                          _showRecordAttachmentSheet(context, record),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Future<void> _showRecordAttachmentSheet(
    BuildContext context,
    PlanRecord record,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _RecordAttachmentSheet(
        record: record,
        goalsStore: goalsStore,
        attachmentStorage: attachmentStorage,
      ),
    );
  }
}

class _ProjectRecordStatChip extends StatelessWidget {
  const _ProjectRecordStatChip({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            key: valueKey,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectStatsSheet extends StatelessWidget {
  const _ProjectStatsSheet({
    required this.project,
    required this.goalsStore,
    required this.attachmentStorage,
  });

  final ProjectItem project;
  final GoalsStore goalsStore;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stats = goalsStore.computeProjectRecordStats(project.id);
    final records = goalsStore.recordsForProject(project.id);
    final goal = goalsStore.goalById(project.goalId);
    final subprojects = goalsStore.getSubprojectsForProject(project.id);
    final tasks = goalsStore.getTasksForProject(project.id);
    final progress = goalsStore.computeProjectProgress(project.id);
    final habitLinkedRecordCount = records
        .where(
          (record) => record.sourceType == GoalsStore.habitPlanRecordSourceType,
        )
        .length;
    final projectColor = Color(project.colorValue);

    return DraggableScrollableSheet(
      key: ValueKey('project-stats-sheet-${project.id}'),
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppThemeTokens.pagePadding,
              0,
              AppThemeTokens.pagePadding,
              MediaQuery.of(context).viewInsets.bottom +
                  AppThemeTokens.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: projectColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                          AppThemeTokens.radiusLg,
                        ),
                        border: Border.all(
                          color: projectColor.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Text(
                        project.icon,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '项目详情',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            project.title,
                            key: ValueKey('project-detail-title-${project.id}'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              project.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppThemeTokens.secondaryTextTone(
                                  colorScheme,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      key: ValueKey('project-stats-close-${project.id}'),
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ProjectDetailSnapshot(
                  projectId: project.id,
                  goalTitle: goal?.title ?? '所属目标不可用',
                  dueDate: project.dueDate,
                  priority: project.priority,
                  tags: project.tags,
                  isOverdue: goalsStore.isProjectOverdue(project),
                  isDueToday: goalsStore.isProjectDueToday(project),
                  subprojectCount: subprojects.length,
                  actionCount: tasks.length,
                  completedActionCount: progress.completedTasks,
                  progress: progress,
                  habitLinkedRecordCount: habitLinkedRecordCount,
                  projectColor: projectColor,
                ),
                const SizedBox(height: 14),
                MetricStrip(
                  metrics: [
                    MetricTileData(
                      value: '${stats.recordCount}',
                      label: '记录',
                      valueKey: 'project-stats-record-count-${project.id}',
                    ),
                    MetricTileData(
                      value: '${stats.activeDaysCount}',
                      label: '活跃天',
                      valueKey: 'project-stats-active-days-${project.id}',
                    ),
                    MetricTileData(
                      value: '${stats.currentMonthRecordCount}',
                      label: '本月记录',
                      valueKey: 'project-stats-month-count-${project.id}',
                    ),
                    MetricTileData(
                      value: '${stats.photoAttachmentCount}',
                      label: '图片记录',
                      valueKey: 'project-stats-photo-count-${project.id}',
                    ),
                  ],
                  tileWidth: 124,
                  tileEmphasis: MetricTileEmphasis.hero,
                ),
                const SizedBox(height: 14),
                SoftSurface(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppThemeTokens.radiusLg,
                  child: _ProjectRecordBreakdownPanel(
                    projectId: project.id,
                    records: records,
                    photoRecordCount: stats.photoAttachmentCount,
                    habitLinkedRecordCount: habitLinkedRecordCount,
                    projectColor: projectColor,
                  ),
                ),
                const SizedBox(height: 14),
                SoftSurface(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppThemeTokens.radiusLg,
                  child: _ProjectMonthHeatmap(
                    projectId: project.id,
                    stats: stats,
                    accentColor: projectColor,
                  ),
                ),
                const SizedBox(height: 14),
                SoftSurface(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppThemeTokens.radiusLg,
                  child: _ProjectYearActivityPanel(
                    projectId: project.id,
                    stats: stats,
                    accentColor: projectColor,
                  ),
                ),
                const SizedBox(height: 14),
                SoftSurface(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppThemeTokens.radiusLg,
                  child: _ProjectNumericTotals(
                    projectId: project.id,
                    stats: stats,
                  ),
                ),
                const SizedBox(height: 14),
                SoftSurface(
                  padding: const EdgeInsets.all(14),
                  borderRadius: AppThemeTokens.radiusLg,
                  child: _ProjectStatsRecordHistory(
                    projectId: project.id,
                    records: records,
                    goalsStore: goalsStore,
                    attachmentStorage: attachmentStorage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectRecordBreakdownPanel extends StatelessWidget {
  const _ProjectRecordBreakdownPanel({
    required this.projectId,
    required this.records,
    required this.photoRecordCount,
    required this.habitLinkedRecordCount,
    required this.projectColor,
  });

  final String projectId;
  final List<PlanRecord> records;
  final int photoRecordCount;
  final int habitLinkedRecordCount;
  final Color projectColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final noteCount = records
        .where((record) => record.type == PlanRecordType.note)
        .length;
    final numericCount = records
        .where((record) => record.type == PlanRecordType.numeric)
        .length;

    return Column(
      key: ValueKey('project-record-breakdown-$projectId'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '记录构成',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '图片和来自习惯是记录标记统计，可能与备注/数值重叠。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: 12),
        AnalyticsBarList(
          accentColor: projectColor,
          maxValue: records.length,
          emptyText: '还没有项目记录。',
          items: [
            AnalyticsBarListItem(
              label: '备注',
              value: noteCount,
              valueKey: 'project-record-breakdown-note-$projectId',
            ),
            AnalyticsBarListItem(
              label: '数值',
              value: numericCount,
              color: colorScheme.secondary,
              valueKey: 'project-record-breakdown-numeric-$projectId',
            ),
            AnalyticsBarListItem(
              label: '图片',
              value: photoRecordCount,
              color: colorScheme.tertiary,
              valueKey: 'project-record-breakdown-image-$projectId',
            ),
            AnalyticsBarListItem(
              label: '来自习惯',
              value: habitLinkedRecordCount,
              color: projectColor.withValues(alpha: 0.70),
              valueKey: 'project-record-breakdown-habit-$projectId',
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectDetailSnapshot extends StatelessWidget {
  const _ProjectDetailSnapshot({
    required this.projectId,
    required this.goalTitle,
    required this.dueDate,
    required this.priority,
    required this.tags,
    required this.isOverdue,
    required this.isDueToday,
    required this.subprojectCount,
    required this.actionCount,
    required this.completedActionCount,
    required this.progress,
    required this.habitLinkedRecordCount,
    required this.projectColor,
  });

  final String projectId;
  final String goalTitle;
  final String? dueDate;
  final PlanPriority? priority;
  final List<String> tags;
  final bool isOverdue;
  final bool isDueToday;
  final int subprojectCount;
  final int actionCount;
  final int completedActionCount;
  final GoalProgress progress;
  final int habitLinkedRecordCount;
  final Color projectColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SoftSurface(
      padding: const EdgeInsets.all(14),
      borderRadius: AppThemeTokens.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProjectDetailChip(
                label: '所属目标',
                value: goalTitle,
                valueKey: ValueKey('project-detail-goal-$projectId'),
              ),
              if (dueDate != null)
                _ProjectDetailChip(
                  label: isOverdue
                      ? '逾期'
                      : isDueToday
                      ? '今天截止'
                      : '截止日期',
                  value: dueDate!,
                  valueKey: ValueKey('project-detail-due-$projectId'),
                ),
              if (priority != null)
                _ProjectDetailChip(
                  label: '优先级',
                  value: _priorityLabel(priority)!,
                  valueKey: ValueKey('project-detail-priority-$projectId'),
                ),
              if (tags.isNotEmpty)
                _ProjectDetailChip(
                  label: '标签',
                  value: tags.map((tag) => '#$tag').join(' '),
                  valueKey: ValueKey('project-detail-tags-$projectId'),
                ),
              _ProjectDetailChip(label: '分组', value: '$subprojectCount'),
              _ProjectDetailChip(label: '行动', value: '$actionCount'),
              _ProjectDetailChip(label: '已完成', value: '$completedActionCount'),
              _ProjectDetailChip(
                label: '来自习惯',
                value: '$habitLinkedRecordCount',
                valueKey: ValueKey(
                  'project-detail-habit-record-count-$projectId',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '任务派生进度',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                progress.label,
                key: ValueKey('project-detail-progress-$projectId'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: progress.hasTasks
                      ? projectColor
                      : AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressRail(
            value: progress.hasTasks ? progress.percentage / 100 : null,
            height: 7,
            fillColor: projectColor.withValues(alpha: 0.72),
            backgroundColor: AppThemeTokens.borderTone(
              colorScheme,
            ).withValues(alpha: 0.42),
          ),
          const SizedBox(height: 8),
          Text(
            '记录只作为项目历史和证据展示，不会改变行动完成状态。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDetailChip extends StatelessWidget {
  const _ProjectDetailChip({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              key: valueKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectMonthHeatmap extends StatelessWidget {
  const _ProjectMonthHeatmap({
    required this.projectId,
    required this.stats,
    required this.accentColor,
  });

  final String projectId;
  final ProjectRecordStats stats;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final daysInMonth = DateTime(
      stats.currentYear,
      stats.currentMonth + 1,
      0,
    ).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '本月活动',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${stats.currentMonthRecordCount} 条',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '按每天记录数量显示深浅。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          key: ValueKey('project-stats-heatmap-$projectId'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final day = index + 1;
            final dateKey =
                '${stats.currentYear.toString().padLeft(4, '0')}-'
                '${stats.currentMonth.toString().padLeft(2, '0')}-'
                '${day.toString().padLeft(2, '0')}';
            final count = stats.currentMonthCountsByLocalDate[dateKey] ?? 0;

            return MiniHeatmapCell(
              key: ValueKey('project-stats-heatmap-day-$projectId-$dateKey'),
              count: count,
              dateLabel: '$day',
              today: dateKey == stats.currentLocalDate,
              height: 32,
              borderRadius: 8,
              accentColor: accentColor,
              semanticLabel: '$dateKey $count 条记录',
            );
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '少',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
            for (final count in const [0, 1, 2, 3])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    child: MiniHeatmapCell(
                      count: count,
                      height: 12,
                      accentColor: accentColor,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    count >= 3 ? '3+' : '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            Text(
              '多',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectYearActivityPanel extends StatelessWidget {
  const _ProjectYearActivityPanel({
    required this.projectId,
    required this.stats,
    required this.accentColor,
  });

  final String projectId;
  final ProjectRecordStats stats;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthCounts = List<int>.generate(
      12,
      (index) => stats.currentYearCountsByMonth[index + 1] ?? 0,
    );
    final maxMonthCount = monthCounts.fold<int>(
      0,
      (current, count) => count > current ? count : current,
    );
    final recentDateEntries = stats.currentYearCountsByLocalDate.entries.toList(
      growable: false,
    )..sort((a, b) => b.key.compareTo(a.key));
    final visibleRecentEntries = recentDateEntries
        .take(5)
        .toList(growable: false);

    return Column(
      key: ValueKey('project-stats-year-activity-$projectId'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '年度活动',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${stats.currentYearRecordCount} 条',
              key: ValueKey('project-stats-year-count-$projectId'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${stats.currentYear} 年 · ${stats.currentYearCountsByLocalDate.length} 个活跃日 · 只读记录统计',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          key: ValueKey('project-stats-year-heatmap-$projectId'),
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var month = 1; month <= 12; month++)
              SizedBox(
                width: 54,
                child: MiniHeatmapCell(
                  key: ValueKey('project-stats-year-month-$projectId-$month'),
                  count: stats.currentYearCountsByMonth[month] ?? 0,
                  dateLabel: '$month月',
                  height: 28,
                  borderRadius: 8,
                  accentColor: accentColor,
                  semanticLabel:
                      '${stats.currentYear}年$month月 ${stats.currentYearCountsByMonth[month] ?? 0} 条记录',
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ProjectYearMonthChart(
          projectId: projectId,
          monthCounts: monthCounts,
          maxMonthCount: maxMonthCount,
          accentColor: accentColor,
        ),
        const SizedBox(height: 12),
        _ProjectRecentActivityTimeline(
          projectId: projectId,
          entries: visibleRecentEntries,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _ProjectYearMonthChart extends StatelessWidget {
  const _ProjectYearMonthChart({
    required this.projectId,
    required this.monthCounts,
    required this.maxMonthCount,
    required this.accentColor,
  });

  final String projectId;
  final List<int> monthCounts;
  final int maxMonthCount;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: ValueKey('project-stats-year-chart-$projectId'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '月度分布',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < monthCounts.length; index++) ...[
                Expanded(
                  child: _ProjectYearMonthBar(
                    month: index + 1,
                    count: monthCounts[index],
                    maxCount: maxMonthCount,
                    accentColor: accentColor,
                  ),
                ),
                if (index < monthCounts.length - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectYearMonthBar extends StatelessWidget {
  const _ProjectYearMonthBar({
    required this.month,
    required this.count,
    required this.maxCount,
    required this.accentColor,
  });

  final int month;
  final int count;
  final int maxCount;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = maxCount <= 0
        ? 0.0
        : (count / maxCount).clamp(0.0, 1.0).toDouble();
    final barHeight = count <= 0 ? 4.0 : 10 + 34 * ratio;

    return Semantics(
      label: '$month月 $count 条记录',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: barHeight,
            constraints: const BoxConstraints(minWidth: 8),
            decoration: BoxDecoration(
              color: count <= 0
                  ? AppThemeTokens.borderTone(
                      colorScheme,
                    ).withValues(alpha: 0.48)
                  : accentColor.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$month',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectRecentActivityTimeline extends StatelessWidget {
  const _ProjectRecentActivityTimeline({
    required this.projectId,
    required this.entries,
    required this.accentColor,
  });

  final String projectId;
  final List<MapEntry<String, int>> entries;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: ValueKey('project-stats-timeline-$projectId'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近活动',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text(
            '今年还没有项目记录。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          )
        else
          Column(
            children: [
              for (final entry in entries)
                _ProjectRecentActivityRow(
                  projectId: projectId,
                  localDate: entry.key,
                  count: entry.value,
                  accentColor: accentColor,
                ),
            ],
          ),
      ],
    );
  }
}

class _ProjectRecentActivityRow extends StatelessWidget {
  const _ProjectRecentActivityRow({
    required this.projectId,
    required this.localDate,
    required this.count,
    required this.accentColor,
  });

  final String projectId;
  final String localDate;
  final int count;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: ValueKey('project-stats-timeline-row-$projectId-$localDate'),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              localDate,
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
            '$count 条',
            key: ValueKey('project-stats-timeline-count-$projectId-$localDate'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectNumericTotals extends StatelessWidget {
  const _ProjectNumericTotals({required this.projectId, required this.stats});

  final String projectId;
  final ProjectRecordStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数值合计',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '按单位分别累计，不混合不同单位。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: 10),
        if (!stats.hasNumericTotals)
          Text(
            '还没有数值记录。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          )
        else
          Column(
            key: ValueKey('project-stats-total-list-$projectId'),
            children: stats.numericTotalsByUnit.entries
                .map(
                  (entry) => _ProjectNumericTotalRow(
                    projectId: projectId,
                    unit: entry.key,
                    total: entry.value,
                    valueKey: ValueKey(
                      'project-stats-total-$projectId-${entry.key}',
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _ProjectNumericTotalRow extends StatelessWidget {
  const _ProjectNumericTotalRow({
    required this.projectId,
    required this.unit,
    required this.total,
    required this.valueKey,
  });

  final String projectId;
  final String unit;
  final double total;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = unit.isEmpty ? '未标单位' : unit;

    return Container(
      key: ValueKey('project-stats-total-row-$projectId-$unit'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppThemeTokens.selectedStateTone(colorScheme),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '同单位累计',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatRecordNumber(total),
            key: valueKey,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProjectRecordFilter {
  all('全部'),
  note('备注'),
  numeric('数值'),
  image('图片'),
  habit('来自习惯');

  const _ProjectRecordFilter(this.label);

  final String label;
}

class _ProjectStatsRecordHistory extends StatefulWidget {
  const _ProjectStatsRecordHistory({
    required this.projectId,
    required this.records,
    required this.goalsStore,
    required this.attachmentStorage,
  });

  final String projectId;
  final List<PlanRecord> records;
  final GoalsStore goalsStore;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  State<_ProjectStatsRecordHistory> createState() =>
      _ProjectStatsRecordHistoryState();
}

class _ProjectStatsRecordHistoryState
    extends State<_ProjectStatsRecordHistory> {
  _ProjectRecordFilter _filter = _ProjectRecordFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredRecords = widget.records
        .where(_recordMatchesFilter)
        .toList(growable: false);

    return Column(
      key: ValueKey('project-stats-record-history-${widget.projectId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '记录表',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '按日期查看项目、分组、行动和习惯生成记录。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ProjectRecordFilter.values
              .map(
                (filter) => FilterChip(
                  key: ValueKey(
                    'project-stats-filter-${filter.name}-${widget.projectId}',
                  ),
                  label: Text(filter.label),
                  selected: _filter == filter,
                  onSelected: (_) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 10),
        if (widget.records.isEmpty)
          Text(
            '还没有项目记录。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          )
        else if (filteredRecords.isEmpty)
          Text(
            '这个筛选下还没有记录。',
            key: ValueKey(
              'project-stats-filter-empty-${_filter.name}-${widget.projectId}',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
            ),
          )
        else
          Column(children: _groupedRecordRows(filteredRecords)),
      ],
    );
  }

  bool _recordMatchesFilter(PlanRecord record) {
    final attachment = widget.goalsStore.attachmentForRecord(record.id);

    return switch (_filter) {
      _ProjectRecordFilter.all => true,
      _ProjectRecordFilter.note => record.type == PlanRecordType.note,
      _ProjectRecordFilter.numeric => record.type == PlanRecordType.numeric,
      _ProjectRecordFilter.image => attachment != null,
      _ProjectRecordFilter.habit =>
        record.sourceType == GoalsStore.habitPlanRecordSourceType,
    };
  }

  List<Widget> _groupedRecordRows(List<PlanRecord> records) {
    final children = <Widget>[];
    String? currentDate;

    for (final record in records) {
      if (record.localDate != currentDate) {
        currentDate = record.localDate;
        children.add(
          _ProjectRecordDateHeader(
            projectId: widget.projectId,
            localDate: currentDate,
          ),
        );
      }

      children.add(
        _ProjectStatsRecordRow(
          record: record,
          attachment: widget.goalsStore.attachmentForRecord(record.id),
          attachmentStorage: widget.attachmentStorage,
          goalsStore: widget.goalsStore,
        ),
      );
    }

    return children;
  }
}

class _ProjectRecordDateHeader extends StatelessWidget {
  const _ProjectRecordDateHeader({
    required this.projectId,
    required this.localDate,
  });

  final String projectId;
  final String localDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        key: ValueKey('project-stats-date-group-$projectId-$localDate'),
        children: [
          Expanded(
            child: Divider(color: AppThemeTokens.borderTone(colorScheme)),
          ),
          const SizedBox(width: 8),
          Text(
            localDate,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: AppThemeTokens.borderTone(colorScheme)),
          ),
        ],
      ),
    );
  }
}

class _ProjectStatsRecordRow extends StatelessWidget {
  const _ProjectStatsRecordRow({
    required this.record,
    required this.attachment,
    required this.attachmentStorage,
    required this.goalsStore,
  });

  final PlanRecord record;
  final PlanRecordAttachment? attachment;
  final PlanRecordAttachmentStorage attachmentStorage;
  final GoalsStore goalsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: ValueKey('project-stats-record-row-${record.id}'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.14 : 0.48,
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemeTokens.selectedStateTone(colorScheme),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            ),
            child: Text(
              _recordDateLabel(record.localDate),
              key: ValueKey('project-stats-record-date-${record.id}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _recordTitle(record),
                      key: ValueKey('project-stats-record-title-${record.id}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_recordSourceLabel(record) != null)
                      _RecordSourceChip(
                        label: _recordSourceLabel(record)!,
                        valueKey: ValueKey(
                          'project-stats-record-source-${record.id}',
                        ),
                      ),
                    if (_recordContextLabel(record, goalsStore) != null)
                      _RecordContextChip(
                        label: _recordContextLabel(record, goalsStore)!,
                        valueKey: ValueKey(
                          'project-stats-record-context-${record.id}',
                        ),
                      ),
                    Container(
                      key: ValueKey('project-stats-record-type-${record.id}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeTokens.selectedStateTone(colorScheme),
                        borderRadius: BorderRadius.circular(
                          AppThemeTokens.radiusPill,
                        ),
                      ),
                      child: Text(
                        record.type == PlanRecordType.numeric ? '数值' : '备注',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (record.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ProjectStatsAttachmentIndicator(
            record: record,
            attachment: attachment,
            attachmentStorage: attachmentStorage,
          ),
        ],
      ),
    );
  }
}

class _ProjectStatsAttachmentIndicator extends StatelessWidget {
  const _ProjectStatsAttachmentIndicator({
    required this.record,
    required this.attachment,
    required this.attachmentStorage,
  });

  final PlanRecord record;
  final PlanRecordAttachment? attachment;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attachment = this.attachment;

    if (attachment == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        final hasFile = file != null;

        return InkWell(
          key: ValueKey(
            hasFile
                ? 'project-stats-record-thumbnail-${record.id}'
                : 'project-stats-record-missing-image-${record.id}',
          ),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPreview(context, attachment),
          child: Container(
            width: 42,
            height: 42,
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
            child: hasFile
                ? Image.file(file, fit: BoxFit.cover)
                : Icon(
                    Icons.broken_image_outlined,
                    size: 19,
                    color: colorScheme.error,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showPreview(
    BuildContext context,
    PlanRecordAttachment attachment,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppThemeTokens.pagePadding,
            0,
            AppThemeTokens.pagePadding,
            MediaQuery.of(context).viewInsets.bottom +
                AppThemeTokens.pagePadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('图片证明', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _RecordAttachmentPreview(
                attachment: attachment,
                attachmentStorage: attachmentStorage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordSourceChip extends StatelessWidget {
  const _RecordSourceChip({required this.label, required this.valueKey});

  final String label;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: valueKey,
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.tertiary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RecordContextChip extends StatelessWidget {
  const _RecordContextChip({required this.label, required this.valueKey});

  final String label;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: valueKey,
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProjectRecordRow extends StatelessWidget {
  const _ProjectRecordRow({
    required this.record,
    required this.attachmentStorage,
    required this.onOpenAttachment,
    this.attachment,
  });

  final PlanRecord record;
  final PlanRecordAttachment? attachment;
  final PlanRecordAttachmentStorage attachmentStorage;
  final VoidCallback onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppThemeTokens.selectedStateTone(colorScheme),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
            child: Text(
              _recordDateLabel(record.localDate),
              key: ValueKey('project-record-date-${record.id}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _recordTitle(record),
                      key: ValueKey('project-record-title-${record.id}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_recordSourceLabel(record) != null)
                      _RecordSourceChip(
                        label: _recordSourceLabel(record)!,
                        valueKey: ValueKey(
                          'project-record-source-${record.id}',
                        ),
                      ),
                  ],
                ),
                if (record.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RecordAttachmentThumb(
            record: record,
            attachment: attachment,
            attachmentStorage: attachmentStorage,
            onTap: onOpenAttachment,
          ),
        ],
      ),
    );
  }
}

class _RecordAttachmentThumb extends StatelessWidget {
  const _RecordAttachmentThumb({
    required this.record,
    required this.attachment,
    required this.attachmentStorage,
    required this.onTap,
  });

  final PlanRecord record;
  final PlanRecordAttachment? attachment;
  final PlanRecordAttachmentStorage attachmentStorage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attachment = this.attachment;

    if (attachment == null) {
      return IconButton(
        key: ValueKey('project-record-attach-${record.id}'),
        tooltip: '添加图片',
        onPressed: onTap,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
        color: colorScheme.primary,
        visualDensity: VisualDensity.compact,
      );
    }

    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        final hasFile = file != null;

        return InkWell(
          key: ValueKey(
            hasFile
                ? 'project-record-thumbnail-${record.id}'
                : 'project-record-missing-image-${record.id}',
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
            child: hasFile
                ? Image.file(file, fit: BoxFit.cover)
                : Icon(
                    Icons.broken_image_outlined,
                    size: 20,
                    color: colorScheme.error,
                  ),
          ),
        );
      },
    );
  }
}

class _RecordAttachmentSheet extends StatefulWidget {
  const _RecordAttachmentSheet({
    required this.record,
    required this.goalsStore,
    required this.attachmentStorage,
  });

  final PlanRecord record;
  final GoalsStore goalsStore;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  State<_RecordAttachmentSheet> createState() => _RecordAttachmentSheetState();
}

class _RecordAttachmentSheetState extends State<_RecordAttachmentSheet> {
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attachment = widget.goalsStore.attachmentForRecord(widget.record.id);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppThemeTokens.pagePadding,
          6,
          AppThemeTokens.pagePadding,
          MediaQuery.of(context).viewInsets.bottom + AppThemeTokens.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('记录图片证明', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${widget.record.localDate} · ${_recordTitle(widget.record)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _RecordAttachmentPreview(
              attachment: attachment,
              attachmentStorage: widget.attachmentStorage,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: ValueKey('record-image-pick-${widget.record.id}'),
                  onPressed: _isWorking ? null : _pickAndStoreImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(attachment == null ? '选择图片' : '更换图片'),
                ),
                if (attachment != null)
                  TextButton.icon(
                    key: ValueKey('record-image-remove-${widget.record.id}'),
                    onPressed: _isWorking ? null : _removeImage,
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

  Future<void> _pickAndStoreImage() async {
    setState(() {
      _isWorking = true;
    });

    final stored = await widget.attachmentStorage.pickAndStoreImage(
      widget.record.id,
    );
    if (!mounted) {
      return;
    }

    if (stored != null) {
      final replaced = await widget.goalsStore.replaceRecordAttachment(
        recordId: widget.record.id,
        relativePath: stored.relativePath,
        fileName: stored.fileName,
        mimeType: stored.mimeType,
      );
      if (replaced != null) {
        await widget.attachmentStorage.removeImage(replaced.relativePath);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isWorking = false;
    });
  }

  Future<void> _removeImage() async {
    setState(() {
      _isWorking = true;
    });

    final removed = await widget.goalsStore.removeRecordAttachment(
      widget.record.id,
    );
    if (removed != null) {
      await widget.attachmentStorage.removeImage(removed.relativePath);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isWorking = false;
    });
  }
}

class _RecordAttachmentPreview extends StatelessWidget {
  const _RecordAttachmentPreview({
    required this.attachment,
    required this.attachmentStorage,
  });

  final PlanRecordAttachment? attachment;
  final PlanRecordAttachmentStorage attachmentStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attachment = this.attachment;

    if (attachment == null) {
      return _RecordAttachmentPlaceholder(
        icon: Icons.image_outlined,
        text: '还没有图片证明，可从相册选择一张。',
      );
    }

    return FutureBuilder<File?>(
      future: attachmentStorage.resolveImage(attachment.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return _RecordAttachmentPlaceholder(
            icon: Icons.broken_image_outlined,
            text: '图片文件已不在本地，记录仍然保留。',
            isError: true,
          );
        }

        return Container(
          key: const ValueKey('record-image-preview'),
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 280),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppThemeTokens.softSurfaceTone(colorScheme),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
            border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Image.file(
                  file,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  attachment.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w600,
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

class _RecordAttachmentPlaceholder extends StatelessWidget {
  const _RecordAttachmentPlaceholder({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tone = isError ? colorScheme.error : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: tone.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError
                    ? tone
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRecordDraft {
  const _PlanRecordDraft({
    required this.type,
    required this.localDate,
    this.note,
    this.numericValue,
    this.unit,
  });

  final PlanRecordType type;
  final String localDate;
  final String? note;
  final double? numericValue;
  final String? unit;
}

class _RecordDialog extends StatefulWidget {
  const _RecordDialog({required this.title, required this.contextLabel});

  final String title;
  final String contextLabel;

  @override
  State<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<_RecordDialog> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  PlanRecordType _type = PlanRecordType.note;
  DateTime _selectedDate = DateTime.now();
  String? _errorText;

  @override
  void dispose() {
    _noteController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contextLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppThemeTokens.secondaryTextTone(
                  Theme.of(context).colorScheme,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('文字记录'),
                  selected: _type == PlanRecordType.note,
                  onSelected: (_) {
                    setState(() {
                      _type = PlanRecordType.note;
                      _errorText = null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('数值记录'),
                  selected: _type == PlanRecordType.numeric,
                  onSelected: (_) {
                    setState(() {
                      _type = PlanRecordType.numeric;
                      _errorText = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_type == PlanRecordType.numeric) ...[
              TextField(
                key: const ValueKey('plan-record-value-field'),
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '数值'),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('plan-record-unit-field'),
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: '单位',
                  hintText: '个 / 分钟 / 页',
                ),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              key: const ValueKey('plan-record-note-field'),
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _type == PlanRecordType.note ? '记录内容' : '备注（可选）',
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              key: const ValueKey('plan-record-date-picker'),
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text('日期 ${_dateKey(_selectedDate)}'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('plan-record-dialog-submit'),
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  void _submit() {
    final note = _noteController.text.trim();
    final unit = _unitController.text.trim();
    final localDate = _dateKey(_selectedDate);

    if (_type == PlanRecordType.note) {
      if (note.isEmpty) {
        setState(() {
          _errorText = '请先写下记录内容';
        });
        return;
      }

      Navigator.of(
        context,
      ).pop(_PlanRecordDraft(type: _type, localDate: localDate, note: note));
      return;
    }

    final value = double.tryParse(_valueController.text.trim());
    if (value == null || !value.isFinite) {
      setState(() {
        _errorText = '请输入有效数值';
      });
      return;
    }

    Navigator.of(context).pop(
      _PlanRecordDraft(
        type: _type,
        localDate: localDate,
        note: note.isEmpty ? null : note,
        numericValue: value,
        unit: unit.isEmpty ? null : unit,
      ),
    );
  }
}

String _recordTitle(PlanRecord record) {
  if (record.type == PlanRecordType.numeric) {
    final unit = record.unit ?? '';
    final spacing = unit.isEmpty ? '' : ' ';
    return '${_formatRecordNumber(record.numericValue ?? 0)}$spacing$unit';
  }

  return '文字记录';
}

String? _recordSourceLabel(PlanRecord record) {
  if (record.sourceType != GoalsStore.habitPlanRecordSourceType) {
    return null;
  }

  final note = record.note ?? '';
  final sourcePrefix = note.split(' · ').first.trim();
  if (sourcePrefix.startsWith('来自习惯：')) {
    return sourcePrefix;
  }

  return '来自习惯';
}

String? _recordContextLabel(PlanRecord record, GoalsStore goalsStore) {
  final taskId = record.taskId;
  if (taskId != null) {
    final task = goalsStore.taskById(taskId);
    if (task != null) {
      return '行动：${task.title}';
    }
  }

  final subprojectId = record.subprojectId;
  if (subprojectId != null) {
    final subproject = goalsStore.subprojectById(subprojectId);
    if (subproject != null) {
      return '分组：${subproject.title}';
    }
  }

  return null;
}

String _recordDateLabel(String localDate) {
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(localDate)) {
    return localDate.substring(5);
  }

  return '未知';
}

String _formatRecordNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _InlineCue extends StatelessWidget {
  const _InlineCue({required this.cueKey, required this.text, this.onTap});

  final Key cueKey;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Container(
      key: cueKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onTap == null
            ? AppThemeTokens.softSurfaceTone(colorScheme)
            : AppThemeTokens.selectedStateTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: onTap == null
              ? AppThemeTokens.borderTone(colorScheme)
              : colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onTap == null
                    ? AppThemeTokens.secondaryTextTone(colorScheme)
                    : colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onTap != null)
            Icon(Icons.add_rounded, size: 16, color: colorScheme.primary),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      onTap: onTap,
      child: content,
    );
  }
}
