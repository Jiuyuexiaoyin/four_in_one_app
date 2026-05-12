import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_active_session.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';

void main() {
  testWidgets('supports a minimal focus countdown loop', (tester) async {
    var fakeNow = DateTime(2026, 4, 23, 9);

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(
          defaultDurationSeconds: 3,
          nowProvider: () => fakeNow,
        ),
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    expect(find.text('空闲中'), findsOneWidget);
    expect(find.text('准备好后，开始一段安静推进。'), findsOneWidget);
    expect(_findKeyedText('focus-remaining-time', '00:03'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '开始'));
    await tester.pump();

    expect(find.text('专注中'), findsOneWidget);
    expect(find.text('本轮已锁定'), findsOneWidget);

    fakeNow = fakeNow.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(_findKeyedText('focus-remaining-time', '00:02'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '暂停'));
    await tester.pump();

    expect(find.text('已暂停'), findsOneWidget);
    expect(find.text('这一轮已暂停，可继续，也可重置。'), findsOneWidget);

    fakeNow = fakeNow.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(_findKeyedText('focus-remaining-time', '00:02'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '继续'));
    await tester.pump();

    fakeNow = fakeNow.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(_findKeyedText('focus-remaining-time', '00:01'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(OutlinedButton, '重置'));
    await tester.pump();

    expect(find.text('空闲中'), findsOneWidget);
    expect(_findKeyedText('focus-remaining-time', '00:03'), findsOneWidget);
  });

  testWidgets('custom duration dialog validates and applies minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(),
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('focus-duration-custom')),
    );
    await tester.pumpAndSettle();

    expect(find.text('自定义时长'), findsOneWidget);
    expect(find.text('输入专注时长'), findsOneWidget);
    expect(find.text('分钟'), findsWidgets);

    await tester.enterText(find.byType(TextField), '181');
    await tester.tap(find.text('确定'));
    await tester.pump();

    expect(find.text('请输入 1 到 180 分钟'), findsOneWidget);
    expect(find.text('本轮时长 25 分钟'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '37');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('自定义时长'), findsNothing);
    expect(find.text('本轮时长 37 分钟'), findsOneWidget);
    expect(_findKeyedText('focus-remaining-time', '37:00'), findsOneWidget);
  });

  testWidgets('selects and clears an incomplete Plan action as focus target', (
    tester,
  ) async {
    final goalsStore = _goalsStoreWithPlanActions();

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
        focusStore: FocusStore.inMemory(),
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    expect(find.text('本轮专注对象'), findsOneWidget);
    expect(find.text('从计划里的未完成行动中选择'), findsOneWidget);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('focus-target-select')),
    );
    await tester.pumpAndSettle();

    expect(find.text('选择行动'), findsWidgets);
    expect(find.text('写产品说明'), findsOneWidget);
    expect(find.text('已完成行动'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('focus-target-option-task-1')));
    await tester.pumpAndSettle();

    expect(find.text('已选择行动'), findsOneWidget);
    expect(_findKeyedText('focus-target-title', '写产品说明'), findsOneWidget);
    expect(find.text('年度目标 / 产品项目 / 文档子项'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('focus-target-clear')));
    await tester.pumpAndSettle();

    expect(_findKeyedText('focus-target-title', '写产品说明'), findsNothing);
    expect(find.text('从计划里的未完成行动中选择'), findsOneWidget);
  });

  testWidgets('focus target locks during a round and does not complete task', (
    tester,
  ) async {
    var fakeNow = DateTime(2026, 4, 23, 9);
    final goalsStore = _goalsStoreWithPlanActions();
    final focusStore = FocusStore.inMemory(
      defaultDurationSeconds: 3,
      nowProvider: () => fakeNow,
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: goalsStore,
        focusStore: focusStore,
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('focus-target-select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('focus-target-option-task-1')));
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.widgetWithText(FilledButton, '开始'));
    await tester.pump();

    expect(focusStore.activeTarget?.taskId, 'task-1');
    expect(focusStore.currentTarget?.title, '写产品说明');

    fakeNow = fakeNow.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(focusStore.completedSessionCount, 1);
    expect(focusStore.sessions.single.target?.taskId, 'task-1');
    expect(focusStore.sessions.single.target?.title, '写产品说明');
    expect(
      goalsStore.tasks.firstWhere((task) => task.id == 'task-1').isCompleted,
      isFalse,
    );
  });

  testWidgets('missing live Plan task does not break restored target display', (
    tester,
  ) async {
    final fakeNow = DateTime.utc(2026, 4, 23, 9);
    final focusStore = FocusStore.inMemory(
      initialActiveSession: FocusActiveSession(
        status: FocusActiveSessionStatus.paused,
        startedAt: fakeNow.subtract(const Duration(minutes: 5)),
        targetEndAt: null,
        remainingSeconds: 600,
        durationSeconds: 1500,
        target: const FocusTargetSnapshot(
          taskId: 'task-missing',
          title: '旧行动快照',
          context: '旧目标 / 旧项目',
        ),
      ),
      nowProvider: () => fakeNow,
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
        focusStore: focusStore,
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    expect(find.text('已暂停'), findsOneWidget);
    expect(find.text('正在推进'), findsOneWidget);
    expect(_findKeyedText('focus-target-title', '旧行动快照'), findsOneWidget);
  });

  testWidgets('weekly overview shows session count and day strip', (
    tester,
  ) async {
    // Monday 2026-04-20 in local time; sessions span Mon–Fri of that week.
    final fakeNow = DateTime(2026, 4, 24, 10); // Friday
    final focusStore = FocusStore.inMemory(
      initialSessions: [
        FocusSessionItem(
          id: 'fs-1',
          completedAt: DateTime(2026, 4, 20, 9).toUtc(), // Monday
          durationSeconds: 1500,
        ),
        FocusSessionItem(
          id: 'fs-2',
          completedAt: DateTime(2026, 4, 22, 9).toUtc(), // Wednesday
          durationSeconds: 900,
        ),
        FocusSessionItem(
          id: 'fs-3',
          completedAt: DateTime(2026, 4, 24, 9).toUtc(), // Friday
          durationSeconds: 1500,
        ),
        FocusSessionItem(
          id: 'fs-old',
          completedAt: DateTime(2026, 4, 13, 9).toUtc(), // previous week
          durationSeconds: 1500,
        ),
      ],
      nowProvider: () => fakeNow,
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
        focusStore: focusStore,
      ),
    );

    await tester.tap(find.text('专注'));
    await tester.pumpAndSettle();

    final weeklySectionFinder = find.byKey(
      const ValueKey('focus-weekly-section'),
    );
    await tester.scrollUntilVisible(
      weeklySectionFinder,
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.ensureVisible(weeklySectionFinder);
    await tester.pumpAndSettle();

    expect(find.text('本周专注'), findsOneWidget);
    expect(find.byKey(const ValueKey('focus-weekly-strip')), findsOneWidget);

    // 3 sessions this week: Mon (25 min), Wed (15 min), Fri (25 min) = 65 min
    expect(
      _findKeyedTextStartingWith('focus-weekly-sessions', '3'),
      findsOneWidget,
    );
    expect(
      _findKeyedTextStartingWith('focus-weekly-minutes', '65'),
      findsOneWidget,
    );
  });
}

Finder _findKeyedText(String key, String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        widget.data == text,
  );
}

Finder _findKeyedTextStartingWith(String key, String prefix) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        (widget.data?.startsWith(prefix) ?? false),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    80,
    scrollable: find.byType(Scrollable),
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

GoalsStore _goalsStoreWithPlanActions() {
  final createdAt = DateTime.utc(2026, 4, 23, 8);

  return GoalsStore.inMemory(
    initialGoals: [GoalItem(id: 'goal-1', title: '年度目标', createdAt: createdAt)],
    initialProjects: [
      ProjectItem(
        id: 'project-1',
        goalId: 'goal-1',
        title: '产品项目',
        createdAt: createdAt,
      ),
    ],
    initialSubprojects: [
      SubprojectItem(
        id: 'subproject-1',
        projectId: 'project-1',
        title: '文档子项',
        createdAt: createdAt,
      ),
    ],
    initialTasks: [
      GoalTaskItem(
        id: 'task-1',
        projectId: 'project-1',
        subprojectId: 'subproject-1',
        title: '写产品说明',
        isCompleted: false,
        createdAt: createdAt,
      ),
      GoalTaskItem(
        id: 'task-2',
        projectId: 'project-1',
        title: '已完成行动',
        isCompleted: true,
        createdAt: createdAt,
      ),
    ],
  );
}
