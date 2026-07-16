import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/data/goals_local_storage.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';

Finder _goalsPageScrollView() =>
    find.byKey(const ValueKey('goals-page-scroll'));

Future<void> _tapPlanTab(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('stitch-nav-/goals')));
  await tester.pumpAndSettle();
  expect(_goalsPageScrollView(), findsOneWidget);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  final target = finder.first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollPlanUntilVisible(
  WidgetTester tester,
  Finder finder, [
  double delta = 300,
]) async {
  bool finderPresent() {
    try {
      return finder.evaluate().isNotEmpty;
    } on StateError {
      return false;
    }
  }

  final scrollView = _goalsPageScrollView();
  for (
    var attempt = 0;
    attempt < 20 && !finderPresent() && scrollView.evaluate().isNotEmpty;
    attempt++
  ) {
    await tester.drag(scrollView, Offset(0, -delta));
    await tester.pumpAndSettle();
  }
  if (finderPresent()) {
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
  }
}

Finder _activeDialogTextField() => find
    .descendant(
      of: find.byType(AlertDialog).last,
      matching: find.byType(TextField),
    )
    .first;

Finder _activeDialogSubmitButton() => find
    .descendant(
      of: find.byType(AlertDialog).last,
      matching: find.byType(FilledButton),
    )
    .last;

Future<void> _openPlanDetail(WidgetTester tester, String goalId) async {
  final card = find.byKey(ValueKey('goal-row-$goalId'));
  await _scrollPlanUntilVisible(tester, card, 300);
  await tester.tap(card.first);
  await tester.pumpAndSettle();
  expect(find.byKey(ValueKey('goal-focus-sheet-$goalId')), findsOneWidget);
}

Future<void> _expandAdvanced(WidgetTester tester, String goalId) async {
  await _tapVisible(
    tester,
    find.byKey(ValueKey('plan-advanced-breakdown-$goalId')),
  );
}

Future<void> _openSearch(WidgetTester tester) async {
  await _scrollPlanUntilVisible(
    tester,
    find.byKey(const ValueKey('plan-search-disclosure')),
    300,
  );
}

void main() {
  testWidgets('simplified Plan creates, edits, advances, and records work', (
    tester,
  ) async {
    final goalsStore = GoalsStore.inMemory();

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
      ),
    );

    await _tapPlanTab(tester);

    expect(find.text('一个计划，一个下一步。'), findsOneWidget);
    expect(find.text('还没有计划，先建立一个目标。'), findsOneWidget);
    expect(find.byKey(const ValueKey('goals-empty-state')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-goal-button')));
    await tester.pumpAndSettle();
    expect(find.text('新建计划'), findsWidgets);
    await tester.enterText(_activeDialogTextField(), 'Ship MVP shell');
    await tester.tap(find.byKey(const ValueKey('plan-identity-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.goals.single.title, 'Ship MVP shell');
    expect(find.text('Ship MVP shell'), findsWidgets);
    expect(find.textContaining('尚未添加行动'), findsWidgets);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-current-edit-goal-1')),
    );
    expect(find.text('编辑计划'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('plan-identity-title-field')),
      'Ship benchmark plan',
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-identity-icon-field')),
      '🚀',
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-identity-description-field')),
      'Long-term planning identity',
    );
    await tester.tap(find.byKey(const ValueKey('plan-identity-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.goals.single.title, 'Ship benchmark plan');
    expect(goalsStore.goals.single.icon, '🚀');
    expect(goalsStore.goals.single.description, 'Long-term planning identity');

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-open-focus-goal-1')),
    );
    expect(find.text('新建项目'), findsOneWidget);
    await tester.enterText(_activeDialogTextField(), 'Alpha planning');
    await tester.tap(_activeDialogSubmitButton());
    await tester.pumpAndSettle();

    expect(goalsStore.projects.single.title, 'Alpha planning');

    await _openPlanDetail(tester, 'goal-1');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-add-project-goal-1')),
    );
    expect(find.text('新建行动'), findsOneWidget);
    await tester.enterText(_activeDialogTextField(), 'Write launch checklist');
    await tester.tap(_activeDialogSubmitButton());
    await tester.pumpAndSettle();

    expect(goalsStore.tasks.single.title, 'Write launch checklist');
    expect(
      _findKeyedText('project-progress-project-1', '行动 1 · 进度 0%'),
      findsNothing,
    );

    await _expandAdvanced(tester, 'goal-1');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-add-subproject-project-1')),
    );
    expect(find.text('新建子项目'), findsOneWidget);
    await tester.enterText(_activeDialogTextField(), 'Launch content');
    await tester.tap(_activeDialogSubmitButton());
    await tester.pumpAndSettle();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('subproject-empty-tasks-cue')),
    );
    expect(find.text('新建行动'), findsOneWidget);
    await tester.enterText(_activeDialogTextField(), 'Draft release note');
    await tester.tap(_activeDialogSubmitButton());
    await tester.pumpAndSettle();

    expect(goalsStore.tasks.length, 2);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-task-toggle-task-2')),
    );
    expect(
      goalsStore.tasks.firstWhere((task) => task.id == 'task-2').isCompleted,
      isTrue,
    );
    expect(goalsStore.computeProjectProgress('project-1').percentage, 50);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-edit-project-1')),
    );
    expect(find.text('编辑项目'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('plan-identity-title-field')),
      'Beta planning',
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-identity-icon-field')),
      '📚',
    );
    await tester.tap(find.byKey(const ValueKey('plan-identity-submit')));
    await tester.pumpAndSettle();
    expect(goalsStore.projects.single.title, 'Beta planning');

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-task-edit-task-2')),
    );
    expect(find.text('编辑行动'), findsWidgets);
    await tester.enterText(_activeDialogTextField(), 'Draft launch note');
    await tester.tap(find.byKey(const ValueKey('plan-task-submit')));
    await tester.pumpAndSettle();
    expect(
      goalsStore.tasks.firstWhere((task) => task.id == 'task-2').title,
      'Draft launch note',
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-add-record-project-1')),
    );
    expect(find.text('添加项目记录'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('plan-record-note-field')),
      '记录一次项目推进',
    );
    await tester.tap(find.byKey(const ValueKey('plan-record-dialog-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.records.length, 1);
    expect(goalsStore.records.single.note, '记录一次项目推进');

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-task-add-record-task-2')),
    );
    expect(find.text('添加行动记录'), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog).last,
            matching: find.text('数值记录'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('plan-record-value-field')),
      '30',
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-record-unit-field')),
      '个',
    );
    await tester.tap(find.byKey(const ValueKey('plan-record-dialog-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.records.length, 2);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-record-open-stats-project-1')).first,
    );
    expect(
      find.byKey(const ValueKey('project-stats-sheet-project-1')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-stats-record-count-project-1', '2'),
      findsOneWidget,
    );
  });

  testWidgets('project detail sheet shows records table and source filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: _storeWithProjectDetailData(),
      ),
    );

    await _tapPlanTab(tester);
    await _openPlanDetail(tester, 'goal-detail');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-record-open-stats-project-detail')),
    );

    expect(
      find.byKey(const ValueKey('project-stats-sheet-project-detail')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-detail-title-project-detail', '阅读项目'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-detail-goal-project-detail', '长期目标'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-detail-progress-project-detail', '进度 50%'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-detail-habit-record-count-project-detail', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-stats-total-project-detail-分钟', '45'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-record-breakdown-project-detail')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-row-record-note')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-row-record-numeric')),
      findsOneWidget,
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-stats-filter-numeric-project-detail')),
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-row-record-numeric')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-row-record-note')),
      findsNothing,
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-stats-filter-habit-project-detail')),
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-source-record-habit')),
      findsOneWidget,
    );
  });

  testWidgets('project and task planning metadata can be edited from detail', (
    tester,
  ) async {
    final goalsStore = GoalsStore.inMemory(
      initialGoals: [
        GoalItem(
          id: 'goal-meta',
          title: 'Meta goal',
          createdAt: DateTime.utc(2026, 4, 25, 8),
        ),
      ],
      initialProjects: [
        ProjectItem(
          id: 'project-meta',
          goalId: 'goal-meta',
          title: 'Meta project',
          dueDate: '2026-04-30',
          createdAt: DateTime.utc(2026, 4, 25, 8, 10),
        ),
      ],
      initialTasks: [
        GoalTaskItem(
          id: 'task-meta',
          projectId: 'project-meta',
          title: 'Meta action',
          isCompleted: false,
          dueDate: '2026-04-26',
          createdAt: DateTime.utc(2026, 4, 25, 8, 20),
        ),
      ],
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
      ),
    );

    await _tapPlanTab(tester);
    await _openPlanDetail(tester, 'goal-meta');
    await _expandAdvanced(tester, 'goal-meta');
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('project-edit-project-meta')),
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-project-priority-high')),
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-project-due-date-clear')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-project-tags-field')),
      'launch',
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-project-tags-add')),
    );
    await tester.tap(find.byKey(const ValueKey('plan-identity-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.projects.single.dueDate, isNull);
    expect(goalsStore.projects.single.priority, PlanPriority.high);
    expect(goalsStore.projects.single.tags, ['launch']);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('goal-task-edit-task-meta')),
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-task-priority-urgent')),
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-task-due-date-clear')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('plan-task-tags-field')),
      'focus',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('plan-task-tags-add')));
    await tester.tap(find.byKey(const ValueKey('plan-task-submit')));
    await tester.pumpAndSettle();

    expect(goalsStore.tasks.single.dueDate, isNull);
    expect(goalsStore.tasks.single.priority, PlanPriority.urgent);
    expect(goalsStore.tasks.single.tags, ['focus']);
    expect(goalsStore.tasks.single.isCompleted, isFalse);
  });

  testWidgets('Plan search filters and sorting show flat contextual results', (
    tester,
  ) async {
    final goalsStore = _storeWithSearchData();

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
      ),
    );

    await _tapPlanTab(tester);
    await _openSearch(tester);

    final searchField = find.byKey(const ValueKey('plan-search-field'));
    expect(searchField, findsOneWidget);
    expect(find.byKey(const ValueKey('plan-filter-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-filter-overdue')), findsNothing);

    await tester.enterText(searchField, 'Launch');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('plan-filtered-result-project-project-today')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('plan-filtered-result-project-project-later')),
      findsNothing,
    );

    await _tapVisible(tester, find.byKey(const ValueKey('plan-search-clear')));
    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-button')));
    expect(find.text('筛选计划'), findsOneWidget);
    await _tapVisible(tester, find.byKey(const ValueKey('plan-tag-launch')));
    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-apply')));
    expect(
      find.byKey(const ValueKey('plan-filtered-result-task-task-overdue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('plan-active-filter-tag')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('plan-filter-count-badge')),
      findsOneWidget,
    );

    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-button')));
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-filter-overdue')),
    );
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-filter-sheet-close')),
    );
    expect(
      find.byKey(const ValueKey('plan-active-filter-overdue')),
      findsNothing,
    );

    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-button')));
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-filter-overdue')),
    );
    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-apply')));
    expect(
      find.byKey(const ValueKey('plan-filtered-result-task-task-overdue')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('plan-filtered-result-task-task-complete-overdue'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('plan-active-filter-overdue')),
      findsOneWidget,
    );

    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-button')));
    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-reset')));
    await _tapVisible(tester, find.byKey(const ValueKey('plan-filter-apply')));
    expect(
      find.byKey(const ValueKey('plan-active-filter-overdue')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('plan-active-filter-tag')), findsNothing);
    expect(find.byKey(const ValueKey('plan-filter-count-badge')), findsNothing);

    await _tapVisible(tester, find.byKey(const ValueKey('plan-sort-button')));
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('plan-sort-menu-priority')),
    );
    final urgentTop = tester.getTopLeft(
      find.byKey(const ValueKey('plan-filtered-result-task-task-overdue')),
    );
    final lowTop = tester.getTopLeft(
      find.byKey(const ValueKey('plan-filtered-result-project-project-later')),
    );
    expect(urgentTop.dy, lessThan(lowTop.dy));
  });

  testWidgets('migrated old goals render as compact top-level plans', (
    tester,
  ) async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode([
          {'id': 'goal-7', 'title': '旧目标 A', 'isCompleted': true},
          {'id': 'goal-8', 'title': '旧目标 B', 'isCompleted': false},
        ]),
      },
    );
    final goalsStore = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
      nowProvider: () => DateTime.utc(2026, 4, 25, 8),
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
      ),
    );

    await _tapPlanTab(tester);

    expect(find.text('一个计划，一个下一步。'), findsOneWidget);
    await _scrollPlanUntilVisible(
      tester,
      find.byKey(const ValueKey('goal-row-goal-7')),
      200,
    );

    expect(find.text('旧目标 A'), findsOneWidget);
    expect(find.text('旧目标 B'), findsWidgets);
    expect(find.byKey(const ValueKey('goal-row-goal-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('goal-row-goal-8')), findsOneWidget);
  });

  testWidgets('Plan simplified surfaces and detail fit common phone widths', (
    tester,
  ) async {
    final view = tester.view;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final width in <double>[360, 393, 412]) {
      view.devicePixelRatio = 1;
      view.physicalSize = Size(width, 860);

      await tester.pumpWidget(
        FourInOneApp(
          habitsStore: HabitsStore.seededInMemory(),
          goalsStore: _storeWithResponsiveData(),
        ),
      );

      await _tapPlanTab(tester);
      await _scrollPlanUntilVisible(
        tester,
        find.byKey(const ValueKey('goal-row-goal-responsive')),
        300,
      );

      expect(
        find.byKey(const ValueKey('goal-edit-goal-responsive')),
        findsOneWidget,
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'Plan simplified page overflow at ${width}dp',
      );

      if (width == 360) {
        await _openPlanDetail(tester, 'goal-responsive');
        await _expandAdvanced(tester, 'goal-responsive');
        expect(
          find.byKey(const ValueKey('project-edit-project-responsive')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('goal-task-edit-task-responsive')),
          findsWidgets,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'Plan detail overflow at 360dp',
        );
        await tester.tapAt(const Offset(12, 12));
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

GoalsStore _storeWithProjectDetailData() {
  return GoalsStore.inMemory(
    initialGoals: [
      GoalItem(
        id: 'goal-detail',
        title: '长期目标',
        icon: '🎯',
        colorValue: 0xFF4F8F7A,
        createdAt: DateTime.utc(2026, 4, 25, 8),
      ),
    ],
    initialProjects: [
      ProjectItem(
        id: 'project-detail',
        goalId: 'goal-detail',
        title: '阅读项目',
        description: '用真实记录推进长期阅读。',
        icon: '📚',
        colorValue: 0xFF4F8F7A,
        createdAt: DateTime.utc(2026, 4, 25, 8, 10),
      ),
    ],
    initialSubprojects: [
      SubprojectItem(
        id: 'subproject-detail',
        projectId: 'project-detail',
        title: '读书分组',
        createdAt: DateTime.utc(2026, 4, 25, 8, 20),
      ),
    ],
    initialTasks: [
      GoalTaskItem(
        id: 'task-done',
        projectId: 'project-detail',
        subprojectId: 'subproject-detail',
        title: '完成第一章',
        isCompleted: true,
        createdAt: DateTime.utc(2026, 4, 25, 8, 30),
      ),
      GoalTaskItem(
        id: 'task-open',
        projectId: 'project-detail',
        title: '整理笔记',
        isCompleted: false,
        createdAt: DateTime.utc(2026, 4, 25, 8, 35),
      ),
    ],
    initialRecords: [
      PlanRecord(
        id: 'record-note',
        projectId: 'project-detail',
        type: PlanRecordType.note,
        localDate: '2026-04-25',
        note: '今天整理了阅读计划',
        createdAt: DateTime.utc(2026, 4, 25, 9),
      ),
      PlanRecord(
        id: 'record-numeric',
        projectId: 'project-detail',
        taskId: 'task-open',
        type: PlanRecordType.numeric,
        localDate: '2026-04-25',
        numericValue: 45,
        unit: '分钟',
        createdAt: DateTime.utc(2026, 4, 25, 9, 20),
      ),
      PlanRecord(
        id: 'record-habit',
        projectId: 'project-detail',
        type: PlanRecordType.note,
        localDate: '2026-04-24',
        note: '来自习惯：阅读 · 2026-04-24 已达标（1/1）',
        sourceType: GoalsStore.habitPlanRecordSourceType,
        sourceId: 'habit-reading',
        sourceLocalDate: '2026-04-24',
        sourceKey: GoalsStore.habitDailyCompletionSourceKey(
          habitId: 'habit-reading',
          localDate: '2026-04-24',
        ),
        createdAt: DateTime.utc(2026, 4, 24, 9, 20),
      ),
    ],
    initialAttachments: [
      PlanRecordAttachment(
        id: 'attachment-note',
        recordId: 'record-note',
        relativePath: 'missing/path.png',
        fileName: 'path.png',
        mimeType: 'image/png',
        createdAt: DateTime.utc(2026, 4, 25, 9, 30),
      ),
    ],
    nowProvider: () => DateTime.utc(2026, 4, 25, 10),
  );
}

GoalsStore _storeWithSearchData() {
  return GoalsStore.inMemory(
    initialGoals: [
      GoalItem(
        id: 'goal-search',
        title: 'Search goal',
        createdAt: DateTime.utc(2026, 4, 20),
      ),
    ],
    initialProjects: [
      ProjectItem(
        id: 'project-today',
        goalId: 'goal-search',
        title: 'Launch project',
        description: 'Release planning',
        dueDate: '2026-04-25',
        priority: PlanPriority.high,
        tags: const ['launch'],
        createdAt: DateTime.utc(2026, 4, 20),
      ),
      ProjectItem(
        id: 'project-later',
        goalId: 'goal-search',
        title: 'Archive project',
        dueDate: '2026-04-30',
        priority: PlanPriority.low,
        tags: const ['ops'],
        createdAt: DateTime.utc(2026, 4, 21),
      ),
    ],
    initialTasks: [
      GoalTaskItem(
        id: 'task-overdue',
        projectId: 'project-today',
        title: 'Fix overdue action',
        isCompleted: false,
        dueDate: '2026-04-24',
        priority: PlanPriority.urgent,
        tags: const ['launch', 'fix'],
        createdAt: DateTime.utc(2026, 4, 21),
      ),
      GoalTaskItem(
        id: 'task-complete-overdue',
        projectId: 'project-today',
        title: 'Done old action',
        isCompleted: true,
        dueDate: '2026-04-24',
        priority: PlanPriority.high,
        tags: const ['done'],
        createdAt: DateTime.utc(2026, 4, 22),
      ),
    ],
    nowProvider: () => DateTime(2026, 4, 25, 8),
  );
}

GoalsStore _storeWithResponsiveData() {
  return GoalsStore.inMemory(
    initialGoals: [
      GoalItem(
        id: 'goal-responsive',
        title: '一个很长但仍然可以编辑的目标名称',
        description: '长描述用于验证小屏幕下不会飘字或溢出。',
        icon: '🎯',
        colorValue: 0xFF4F8F7A,
        createdAt: DateTime.parse('2026-04-25T08:00:00Z'),
      ),
    ],
    initialProjects: [
      ProjectItem(
        id: 'project-responsive',
        goalId: 'goal-responsive',
        title: '可编辑的长期项目名称',
        description: '项目描述同样需要在小屏幕自然收起。',
        icon: '📁',
        colorValue: 0xFF4F8F7A,
        createdAt: DateTime.parse('2026-04-25T08:10:00Z'),
      ),
    ],
    initialSubprojects: [
      SubprojectItem(
        id: 'subproject-responsive',
        projectId: 'project-responsive',
        title: '可编辑分组',
        createdAt: DateTime.parse('2026-04-25T08:15:00Z'),
      ),
    ],
    initialTasks: [
      GoalTaskItem(
        id: 'task-responsive',
        projectId: 'project-responsive',
        subprojectId: 'subproject-responsive',
        title: '可以清楚编辑的行动标题',
        isCompleted: false,
        createdAt: DateTime.parse('2026-04-25T08:20:00Z'),
      ),
    ],
    initialRecords: [
      PlanRecord(
        id: 'record-responsive',
        projectId: 'project-responsive',
        type: PlanRecordType.note,
        localDate: '2026-04-25',
        note: '小屏项目统计记录',
        createdAt: DateTime.parse('2026-04-25T09:00:00Z'),
      ),
    ],
  );
}

Finder _findKeyedText(String key, String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        widget.data == text,
  );
}

class _FakeGoalsKeyValueStore implements GoalsKeyValueStore {
  _FakeGoalsKeyValueStore({Map<String, String>? values})
    : values = values ?? <String, String>{};

  final Map<String, String> values;

  @override
  Future<String?> getString(String key) async {
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}
