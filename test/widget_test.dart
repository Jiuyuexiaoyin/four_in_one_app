import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';

void main() {
  testWidgets('loads the app shell on Today', (tester) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    expect(find.text('今日'), findsWidgets);
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('习惯'), findsOneWidget);
    expect(find.text('计划'), findsOneWidget);
    expect(find.text('专注'), findsWidgets);
    expect(find.byKey(const ValueKey('today-habits-view-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('shell-settings-entry')), findsOneWidget);
  });
}
