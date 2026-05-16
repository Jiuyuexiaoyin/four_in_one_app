import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';

void main() {
  testWidgets('renders the shell with the cross-feature Today overview', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    expect(find.text('今日'), findsWidgets);
    expect(find.text('习惯'), findsOneWidget);
    expect(find.text('计划'), findsOneWidget);
    expect(find.text('专注'), findsWidgets);
    expect(find.text('复盘'), findsOneWidget);
    expect(find.text('我的'), findsNothing);
    expect(find.byIcon(Icons.track_changes_outlined), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('today-habits-view-all')), findsOneWidget);
    expect(find.text('今日习惯'), findsOneWidget);
    expect(_findKeyedText('today-habits-completed', '0'), findsOneWidget);
    expect(_findKeyedText('today-habits-total', '/ 3'), findsOneWidget);
    expect(find.text('今日打卡 0 次'), findsOneWidget);
    expect(find.text('💧 Drink water'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('today-goals-view-all')),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('today-goals-view-all')), findsOneWidget);
    expect(find.text('目标规划'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('today-focus-view-all')),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('today-focus-view-all')), findsOneWidget);
    expect(find.text('专注概览'), findsOneWidget);
  });

  testWidgets('keeps existing feature routes compatible', (tester) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.pushNamed(AppRoute.habits);
    await tester.pumpAndSettle();
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('轻量记录每天的重复行为。'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    navigator.pushNamed(AppRoute.goals);
    await tester.pumpAndSettle();
    expect(find.text('计划'), findsWidgets);
    expect(find.text('计划你的长期推进。'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    navigator.pushNamed(AppRoute.settings);
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsWidgets);
    expect(find.text('界面强调色'), findsOneWidget);
  });

  testWidgets('main pages render at 360dp with larger Chinese text', (
    tester,
  ) async {
    final view = tester.view;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    view.devicePixelRatio = 1;
    view.physicalSize = const Size(360, 860);

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'Today should render on 360dp with text scale 1.15',
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    const routes = <String>[
      AppRoute.habits,
      AppRoute.goals,
      AppRoute.focus,
      AppRoute.review,
      AppRoute.settings,
    ];

    for (final route in routes) {
      navigator.pushNamed(route);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$route should render on 360dp with text scale 1.15',
      );
      navigator.pop();
      await tester.pumpAndSettle();
    }
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
