import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/shared/widgets/app_shell.dart';

void main() {
  testWidgets('habit check-in synchronizes Habits, Today, and Review', (
    tester,
  ) async {
    final habit = _habit(id: 'habit-sync', name: '同步习惯');
    final habitsStore = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 7, 12, 9),
      initialHabits: [habit],
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: habitsStore,
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(),
      ),
    );

    await _bringIntoView(
      tester,
      find.byKey(const ValueKey('today-priority-action')),
      const ValueKey('today-page-scroll'),
    );
    await tester.tap(find.byKey(const ValueKey('today-priority-action')));
    await tester.pumpAndSettle();

    expect(find.text('1/1 · 1 次'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/habits')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('habit-today-count-1-1')), findsOneWidget);

    await _pushRoute(tester, AppRoute.review);
    expect(_keyedText('review-hero-habit-checkins', '1'), findsOneWidget);
    expect(_keyedText('review-habits-completed', '1'), findsOneWidget);
  });

  testWidgets('Plan completion synchronizes Today, Review, and Focus targets', (
    tester,
  ) async {
    final createdAt = DateTime.utc(2026, 7, 12, 8);
    final goalsStore = GoalsStore.inMemory(
      initialGoals: [
        GoalItem(id: 'goal-sync', title: '同步计划', createdAt: createdAt),
      ],
      initialProjects: [
        ProjectItem(
          id: 'project-sync',
          goalId: 'goal-sync',
          title: '同步项目',
          createdAt: createdAt,
        ),
      ],
      initialTasks: [
        GoalTaskItem(
          id: 'task-sync',
          projectId: 'project-sync',
          title: '同步行动',
          isCompleted: false,
          createdAt: createdAt,
        ),
      ],
    );
    final focusStore = FocusStore.inMemory();
    focusStore.selectTarget(
      const FocusTargetSnapshot(
        taskId: 'task-sync',
        title: '同步行动',
        context: '同步计划 / 同步项目',
      ),
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
        ),
        goalsStore: goalsStore,
        focusStore: focusStore,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/goals')));
    await tester.pumpAndSettle();
    await _bringIntoView(
      tester,
      find.byKey(const ValueKey('plan-next-action-toggle-task-sync')),
      const ValueKey('goals-page-scroll'),
    );
    await tester.tap(
      find.byKey(const ValueKey('plan-next-action-toggle-task-sync')),
    );
    await tester.pumpAndSettle();
    _jumpScrollToStart(tester, const ValueKey('goals-page-scroll'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('plan-overview-progress')),
      findsOneWidget,
    );
    expect(find.text('已完成 1 / 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/today')));
    await tester.pumpAndSettle();
    expect(find.text('1/1'), findsOneWidget);

    await _pushRoute(tester, AppRoute.review);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-goals-section')),
      300,
    );
    await tester.pumpAndSettle();
    expect(_keyedText('review-goals-completed-tasks', '1'), findsOneWidget);
    expect(
      _keyedTextContaining('review-goals-action-rate', '100%'),
      findsOneWidget,
    );

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stitch-nav-/focus')));
    await tester.pumpAndSettle();

    expect(focusStore.selectedTarget, isNull);
    await tester.tap(find.byKey(const ValueKey('focus-header-target')));
    await tester.pumpAndSettle();
    expect(find.text('暂无可选择行动'), findsOneWidget);
    expect(find.text('同步行动'), findsNothing);
  });

  testWidgets('completed Focus round synchronizes Focus, Today, and Review', (
    tester,
  ) async {
    var fakeNow = DateTime(2026, 7, 12, 9);
    final timerFactory = _FakeTimerFactory();
    final focusStore = FocusStore.inMemory(
      defaultDurationSeconds: 60,
      nowProvider: () => fakeNow,
      timerFactory: timerFactory.call,
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => fakeNow,
          initialHabits: const <HabitItem>[],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: focusStore,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/focus')));
    await tester.pumpAndSettle();
    await _bringIntoView(
      tester,
      find.byKey(const ValueKey('focus-start')),
      const ValueKey('focus-page-scroll'),
    );
    await tester.tap(find.byKey(const ValueKey('focus-start')));
    await tester.pump();
    fakeNow = fakeNow.add(const Duration(seconds: 61));
    timerFactory.records.single.tick();
    await tester.pumpAndSettle();

    expect(focusStore.completedSessionCount, 1);
    await _bringIntoView(
      tester,
      find.byKey(const ValueKey('focus-weekly-section')),
      const ValueKey('focus-page-scroll'),
    );
    await tester.pumpAndSettle();
    expect(
      _keyedTextStartingWith('focus-weekly-sessions', '1'),
      findsOneWidget,
    );
    expect(_keyedTextStartingWith('focus-weekly-minutes', '1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/today')));
    await tester.pumpAndSettle();
    expect(find.text('0% · 1m'), findsOneWidget);

    await _pushRoute(tester, AppRoute.review);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-focus-section')),
      300,
    );
    await tester.pumpAndSettle();
    expect(
      _keyedTextStartingWith('review-focus-completed-sessions', '1'),
      findsOneWidget,
    );
    expect(
      _keyedTextStartingWith('review-focus-total-minutes', '1'),
      findsOneWidget,
    );
  });

  testWidgets('shared main headers open every required action', (tester) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    AppShell currentShell() => tester.widget<AppShell>(find.byType(AppShell));

    expect(find.byTooltip('复盘'), findsOneWidget);
    expect(find.byTooltip('我的/设置'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('today-header-review')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '复盘');
    expect(currentShell().showBottomNavigation, isFalse);
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('today-header-settings')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '我的');
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/habits')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '习惯');
    expect(find.byTooltip('新建习惯'), findsOneWidget);
    expect(find.byTooltip('我的/设置'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('habits-header-create')));
    await tester.pumpAndSettle();
    expect(find.text('新建习惯'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('habit-form-cancel')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habits-header-settings')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '我的');
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/goals')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '计划');
    expect(find.byTooltip('新建计划'), findsOneWidget);
    expect(find.byTooltip('我的/设置'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-goal-button')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('新建计划'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('goals-header-settings')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '我的');
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/focus')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '专注');
    expect(find.byTooltip('选择专注对象'), findsOneWidget);
    expect(find.byTooltip('我的/设置'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('focus-header-target')));
    await tester.pumpAndSettle();
    expect(find.text('暂无可选择行动'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('focus-header-settings')));
    await tester.pumpAndSettle();
    expect(currentShell().title, '我的');
  });

  testWidgets('theme mode updates the visible page without restart', (
    tester,
  ) async {
    final settingsStore = AppSettingsStore.inMemory(
      themeMode: AppThemeMode.dark,
    );
    await tester.pumpWidget(
      FourInOneApp(
        appSettingsStore: settingsStore,
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    final initialScaffold = tester.widget<Scaffold>(
      find.byKey(const ValueKey('app-shell-scaffold')),
    );
    final initialBackground = initialScaffold.backgroundColor;

    await settingsStore.setThemeMode(AppThemeMode.light);
    await tester.pumpAndSettle();

    final updatedScaffold = tester.widget<Scaffold>(
      find.byKey(const ValueKey('app-shell-scaffold')),
    );
    final updatedBody = tester.widget<Material>(
      find.byKey(const ValueKey('app-shell-body-surface')),
    );
    expect(settingsStore.themeMode, AppThemeMode.light);
    expect(updatedScaffold.backgroundColor, isNot(initialBackground));
    expect(updatedBody.color, updatedScaffold.backgroundColor);
    expect(find.byKey(const ValueKey('today-header-review')), findsOneWidget);
  });

  testWidgets('Plan empty-project action is explicit and opens creation', (
    tester,
  ) async {
    final goalsStore = GoalsStore.inMemory(
      initialGoals: [
        GoalItem(
          id: 'goal-empty-project',
          title: '待拆解计划',
          createdAt: DateTime.utc(2026, 7, 12, 8),
        ),
      ],
    );
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
        ),
        goalsStore: goalsStore,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('stitch-nav-/goals')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '先建项目'), findsOneWidget);

    await _bringIntoView(
      tester,
      find.byKey(const ValueKey('goal-open-focus-goal-empty-project')),
      const ValueKey('goals-page-scroll'),
    );
    await tester.tap(
      find.byKey(const ValueKey('goal-open-focus-goal-empty-project')),
    );
    await tester.pumpAndSettle();
    expect(find.text('新建项目'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(goalsStore.projects, isEmpty);
  });

  testWidgets('main tabs have no back button and secondary routes return', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    for (final route in <String>[
      AppRoute.today,
      AppRoute.habits,
      AppRoute.goals,
      AppRoute.focus,
    ]) {
      if (route != AppRoute.today) {
        await tester.tap(find.byKey(ValueKey('stitch-nav-$route')));
        await tester.pumpAndSettle();
      }
      expect(find.byType(BackButton), findsNothing);
      expect(find.byKey(const ValueKey('secondary-back-button')), findsNothing);
    }

    await _pushRoute(tester, AppRoute.settings);
    expect(find.byKey(const ValueKey('secondary-back-button')), findsOneWidget);
    expect(find.byTooltip('返回'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('专注'), findsWidgets);

    await _pushRoute(tester, AppRoute.review);
    expect(find.byKey(const ValueKey('secondary-back-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('secondary-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('专注'), findsWidgets);
  });
}

Future<void> _pushRoute(WidgetTester tester, String route) async {
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

Future<void> _bringIntoView(
  WidgetTester tester,
  Finder target,
  ValueKey<String> scrollViewKey,
) async {
  await tester.dragUntilVisible(
    target,
    find.byKey(scrollViewKey),
    const Offset(0, -300),
  );
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
}

void _jumpScrollToStart(WidgetTester tester, ValueKey<String> scrollViewKey) {
  final scrollable = find.descendant(
    of: find.byKey(scrollViewKey),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    ),
  );
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
}

Finder _keyedText(String key, String value) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        widget.data == value,
  );
}

Finder _keyedTextContaining(String key, String value) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        (widget.data?.contains(value) ?? false),
  );
}

Finder _keyedTextStartingWith(String key, String value) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        (widget.data?.startsWith(value) ?? false),
  );
}

HabitItem _habit({required String id, required String name}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: '✓',
    description: '',
    targetCountPerDay: 1,
    reminderTime: null,
    createdAt: DateTime.utc(2026, 7, 12, 8),
  );
}

class _FakeTimerFactory {
  final records = <_FakeTimer>[];

  FocusTimerHandle call(Duration interval, VoidCallback onTick) {
    final timer = _FakeTimer(onTick);
    records.add(timer);
    return timer;
  }
}

class _FakeTimer implements FocusTimerHandle {
  _FakeTimer(this.onTick);

  final VoidCallback onTick;

  @override
  void cancel() {}

  void tick() => onTick();
}
