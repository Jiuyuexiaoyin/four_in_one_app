import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';

void main() {
  testWidgets('shows a read-only review overview with current data', (
    tester,
  ) async {
    final completedHabit = _testHabit(
      id: 'habit-complete',
      name: 'Hydrate',
      targetCountPerDay: 2,
    );
    final pendingHabit = _testHabit(
      id: 'habit-pending',
      name: 'Read',
      targetCountPerDay: 2,
    );
    final untouchedHabit = _testHabit(id: 'habit-untouched', name: 'Walk');

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 25, 9),
          initialHabits: [completedHabit, pendingHabit, untouchedHabit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-1',
              habitId: completedHabit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-2',
              habitId: completedHabit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-3',
              habitId: pendingHabit.id,
              localDate: '2026-04-25',
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(
          initialGoals: [
            _testGoal(id: 'goal-1', title: 'Build today'),
            _testGoal(id: 'goal-2', title: 'Plan review'),
          ],
          initialProjects: [
            _testProject(id: 'project-1', goalId: 'goal-1', title: 'Shell'),
            _testProject(id: 'project-2', goalId: 'goal-2', title: 'Docs'),
          ],
          initialSubprojects: [
            _testSubproject(
              id: 'subproject-1',
              projectId: 'project-2',
              title: 'Structure',
            ),
          ],
          initialTasks: [
            _testTask(
              id: 'task-1',
              projectId: 'project-1',
              title: 'Build shell',
              isCompleted: true,
            ),
            _testTask(
              id: 'task-2',
              projectId: 'project-2',
              subprojectId: 'subproject-1',
              title: 'Organize docs',
            ),
          ],
        ),
        focusStore: FocusStore.inMemory(
          defaultDurationSeconds: 25 * 60,
          initialSessions: [
            FocusSessionItem(
              id: 'focus-session-1',
              completedAt: DateTime.utc(2026, 4, 24, 8),
              durationSeconds: 1500,
              target: const FocusTargetSnapshot(
                taskId: 'task-1',
                title: 'Build shell',
                context: 'Build today / Shell',
              ),
            ),
          ],
        ),
      ),
    );

    await _openReview(tester);

    expect(find.byKey(const ValueKey('review-overview-hero')), findsOneWidget);
    expect(_findKeyedText('review-hero-habit-checkins', '3'), findsOneWidget);
    expect(
      _findKeyedText('review-hero-completed-actions', '1'),
      findsOneWidget,
    );
    expect(_findKeyedText('review-hero-focus-sessions', '1'), findsOneWidget);
    expect(_findKeyedText('review-hero-plan-progress', '50%'), findsOneWidget);

    expect(find.byKey(const ValueKey('review-habits-section')), findsOneWidget);
    expect(_findKeyedText('review-habits-completed', '1'), findsOneWidget);
    expect(_findKeyedText('review-habits-total', '3'), findsOneWidget);
    expect(
      _findKeyedTextStartingWith('review-habits-check-ins-today', '3'),
      findsOneWidget,
    );
    expect(
      _findKeyedTextStartingWith('review-habits-active-days', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedTextContaining('review-habits-rate', '33%'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('review-habits-recent-strip')),
      findsOneWidget,
    );
    expect(
      _findKeyedTextContaining('review-habits-recent-activity', '3'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-goals-section')),
      300,
    );
    await tester.pumpAndSettle();

    expect(_findKeyedText('review-goals-count', '2'), findsOneWidget);
    expect(_findKeyedText('review-goals-projects', '2'), findsOneWidget);
    expect(_findKeyedText('review-goals-subprojects', '1'), findsOneWidget);
    expect(_findKeyedText('review-goals-tasks', '2'), findsOneWidget);
    expect(_findKeyedText('review-goals-completed-tasks', '1'), findsOneWidget);
    expect(
      _findKeyedTextContaining('review-goals-action-rate', '50%'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-focus-section')),
      300,
    );
    await tester.pumpAndSettle();

    expect(_findKeyedText('review-focus-remaining', '25:00'), findsOneWidget);
    expect(
      _findKeyedTextStartingWith('review-focus-completed-sessions', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedTextStartingWith('review-focus-total-minutes', '25'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('review-focus-latest-target', 'Build shell'),
      findsOneWidget,
    );
  });

  testWidgets('Review habit metrics count makeup but ignore skip records', (
    tester,
  ) async {
    final habit = _testHabit(id: 'habit-1', name: 'Read', targetCountPerDay: 2);
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 25, 9),
          initialHabits: [habit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-check-in',
              habitId: habit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-makeup',
              habitId: habit.id,
              localDate: '2026-04-25',
              type: HabitRecordType.makeup,
            ),
            _testRecord(
              id: 'habit-record-skip',
              habitId: habit.id,
              localDate: '2026-04-25',
              type: HabitRecordType.skip,
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    await _openReview(tester);

    expect(_findKeyedText('review-hero-habit-checkins', '2'), findsOneWidget);
    expect(
      _findKeyedTextStartingWith('review-habits-check-ins-today', '2'),
      findsOneWidget,
    );
    expect(_findKeyedText('review-habits-completed', '1'), findsOneWidget);
    expect(
      _findKeyedTextStartingWith('review-habits-active-days', '1'),
      findsOneWidget,
    );
  });

  testWidgets('focus recent strip appears when sessions exist in past 7 days', (
    tester,
  ) async {
    final fakeNow = DateTime(2026, 4, 25, 10);
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
          initialRecords: const <HabitRecord>[],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(
          defaultDurationSeconds: 25 * 60,
          nowProvider: () => fakeNow,
          initialSessions: [
            FocusSessionItem(
              id: 'focus-recent-1',
              completedAt: DateTime.utc(2026, 4, 25, 8),
              durationSeconds: 1500,
            ),
            FocusSessionItem(
              id: 'focus-recent-2',
              completedAt: DateTime.utc(2026, 4, 23, 9),
              durationSeconds: 1500,
            ),
          ],
        ),
      ),
    );

    await _openReview(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-focus-section')),
      300,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('review-focus-recent-strip')),
      findsOneWidget,
    );
  });

  testWidgets('does not show empty habit or plan progress rates', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: const <HabitItem>[],
          initialRecords: const <HabitRecord>[],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    await _openReview(tester);

    expect(
      find.byKey(const ValueKey('review-hero-plan-progress')),
      findsOneWidget,
    );
    expect(_findKeyedText('review-habits-completed', '0'), findsOneWidget);
    expect(_findKeyedText('review-habits-total', '0'), findsOneWidget);
    expect(find.byKey(const ValueKey('review-habits-rate')), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('review-goals-section')),
      300,
    );
    await tester.pumpAndSettle();

    expect(_findKeyedText('review-goals-count', '0'), findsOneWidget);
    expect(_findKeyedText('review-goals-projects', '0'), findsOneWidget);
    expect(_findKeyedText('review-goals-subprojects', '0'), findsOneWidget);
    expect(_findKeyedText('review-goals-tasks', '0'), findsOneWidget);
    expect(_findKeyedText('review-goals-completed-tasks', '0'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('review-goals-action-rate')),
      findsNothing,
    );
  });
}

Future<void> _openReview(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.insights_outlined));
  await tester.pumpAndSettle();
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

Finder _findKeyedTextContaining(String key, String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        (widget.data?.contains(text) ?? false),
  );
}

HabitItem _testHabit({
  required String id,
  required String name,
  int targetCountPerDay = 1,
}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: targetCountPerDay,
    reminderTime: null,
    createdAt: DateTime.parse('2026-04-25T08:00:00.000'),
  );
}

GoalItem _testGoal({required String id, required String title}) {
  return GoalItem(
    id: id,
    title: title,
    createdAt: DateTime.parse('2026-04-25T08:00:00Z'),
  );
}

ProjectItem _testProject({
  required String id,
  required String goalId,
  required String title,
}) {
  return ProjectItem(
    id: id,
    goalId: goalId,
    title: title,
    createdAt: DateTime.parse('2026-04-25T08:10:00Z'),
  );
}

SubprojectItem _testSubproject({
  required String id,
  required String projectId,
  required String title,
}) {
  return SubprojectItem(
    id: id,
    projectId: projectId,
    title: title,
    createdAt: DateTime.parse('2026-04-25T08:15:00Z'),
  );
}

GoalTaskItem _testTask({
  required String id,
  required String projectId,
  String? subprojectId,
  required String title,
  bool isCompleted = false,
}) {
  return GoalTaskItem(
    id: id,
    projectId: projectId,
    subprojectId: subprojectId,
    title: title,
    isCompleted: isCompleted,
    createdAt: DateTime.parse('2026-04-25T08:20:00Z'),
  );
}

HabitRecord _testRecord({
  required String id,
  required String habitId,
  required String localDate,
  HabitRecordType type = HabitRecordType.checkIn,
}) {
  return HabitRecord(
    id: id,
    habitId: habitId,
    localDate: localDate,
    type: type,
    createdAt: DateTime.parse('${localDate}T08:00:00Z'),
  );
}
