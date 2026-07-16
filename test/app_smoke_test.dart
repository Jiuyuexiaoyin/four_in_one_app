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

    expect(find.text('今天'), findsWidgets);
    expect(find.text('习惯'), findsWidgets);
    expect(find.text('计划'), findsWidgets);
    expect(find.text('专注'), findsWidgets);
    expect(find.text('My'), findsNothing);
    expect(find.text('复盘'), findsNothing);
    expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsWidgets);
    expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
    expect(find.text('推进指标'), findsOneWidget);
    expect(find.text('优先行动'), findsOneWidget);
    expect(find.text('节奏趋势'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('行动计划'), 300);
    await tester.pumpAndSettle();

    expect(find.text('行动计划'), findsOneWidget);
    expect(find.text('💧 Drink water'), findsWidgets);
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
    expect(find.text('习惯'), findsWidgets);
    navigator.pop();
    await tester.pumpAndSettle();

    navigator.pushNamed(AppRoute.goals);
    await tester.pumpAndSettle();
    expect(find.text('计划'), findsWidgets);
    expect(find.text('一个计划，一个下一步。'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    navigator.pushNamed(AppRoute.settings);
    await tester.pumpAndSettle();
    expect(find.text('我的'), findsWidgets);
    expect(find.text('主题工作室'), findsWidgets);
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
