import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';

void main() {
  testWidgets('shows a short cross-feature overview on Today', (tester) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(
          initialGoals: [
            _testGoal(id: 'goal-1', title: '完成首页骨架'),
            _testGoal(id: 'goal-2', title: '整理目标页文案'),
            _testGoal(id: 'goal-3', title: '补充复盘页'),
          ],
          initialProjects: [
            _testProject(id: 'project-1', goalId: 'goal-1', title: '首页项目'),
            _testProject(id: 'project-2', goalId: 'goal-2', title: '文案项目'),
          ],
          initialSubprojects: [
            _testSubproject(
              id: 'subproject-1',
              projectId: 'project-2',
              title: '文案结构',
            ),
          ],
          initialTasks: [
            _testTask(id: 'task-1', projectId: 'project-1', title: '完成骨架'),
            _testTask(
              id: 'task-2',
              projectId: 'project-2',
              title: '整理文案',
              subprojectId: 'subproject-1',
              isCompleted: true,
            ),
          ],
        ),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    expect(find.text('今天'), findsWidgets);
    expect(find.text('高效节奏'), findsOneWidget);
    expect(find.text('推进指标'), findsOneWidget);
    expect(find.text('优先行动'), findsOneWidget);
    expect(find.text('节奏趋势'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('完成骨架'), findsWidgets);

    await _scrollToActionPlan(tester);

    expect(find.text('行动计划'), findsOneWidget);
    expect(find.text('完成骨架'), findsWidgets);
    expect(find.text('整理文案'), findsNothing);
    expect(find.text('补充复盘页'), findsNothing);
  });

  testWidgets('expresses habits as read-only daily tracking on Today', (
    tester,
  ) async {
    final completedHabit = _testHabit(
      id: 'habit-complete',
      name: '晨间饮水',
      emoji: '💧',
      targetCountPerDay: 2,
    );
    final pendingHabit = _testHabit(
      id: 'habit-pending',
      name: '阅读',
      emoji: '📖',
      targetCountPerDay: 3,
      reminderTime: '08:30',
    );
    final untouchedHabit = _testHabit(
      id: 'habit-untouched',
      name: '散步',
      emoji: '🚶',
    );

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
            _testRecord(
              id: 'habit-record-4',
              habitId: untouchedHabit.id,
              localDate: '2026-04-24',
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    expect(find.textContaining('3 次打卡'), findsOneWidget);
    await _scrollToActionPlan(tester);

    expect(find.text('💧 晨间饮水'), findsNothing);
    expect(find.text('📖 阅读'), findsWidgets);
    expect(find.text('今日 1 / 3'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('🚶 散步'), findsOneWidget);
    expect(find.text('今日 0 / 1'), findsOneWidget);
  });

  testWidgets('Today counts makeup for today and ignores skip records', (
    tester,
  ) async {
    /*
    final todayMakeupHabit = _testHabit(
      id: 'habit-makeup-today',
      name: '琛ュ崱浠婂ぉ',
      emoji: '鉁嶏笍',
    );
    final skippedHabit = _testHabit(
      id: 'habit-skipped',
      name: '浼戞伅',
      emoji: '馃挙',
    );
    final pastMakeupHabit = _testHabit(
      id: 'habit-makeup-past',
      name: '鏄ㄥぉ琛ュ崱',
      emoji: '馃尡',
    );

    */
    final todayMakeupHabit = _testHabit(
      id: 'habit-makeup-today',
      name: 'Makeup today',
      emoji: '*',
    );
    final skippedHabit = _testHabit(
      id: 'habit-skipped',
      name: 'Rest',
      emoji: '-',
    );
    final pastMakeupHabit = _testHabit(
      id: 'habit-makeup-past',
      name: 'Makeup yesterday',
      emoji: '+',
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 25, 9),
          initialHabits: [todayMakeupHabit, skippedHabit, pastMakeupHabit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-makeup-today',
              habitId: todayMakeupHabit.id,
              localDate: '2026-04-25',
              type: HabitRecordType.makeup,
            ),
            _testRecord(
              id: 'habit-record-skip-today',
              habitId: skippedHabit.id,
              localDate: '2026-04-25',
              type: HabitRecordType.skip,
            ),
            _testRecord(
              id: 'habit-record-makeup-yesterday',
              habitId: pastMakeupHabit.id,
              localDate: '2026-04-24',
              type: HabitRecordType.makeup,
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    expect(find.textContaining('1 次打卡'), findsOneWidget);
    await _scrollToActionPlan(tester);

    /*
    expect(find.text('浠婃棩鎵撳崱 1 娆?), findsOneWidget);
    expect(find.text('鉁嶏笍 琛ュ崱浠婂ぉ'), findsNothing);
    expect(find.text('馃挙 浼戞伅'), findsOneWidget);
    expect(find.text('馃尡 鏄ㄥぉ琛ュ崱'), findsOneWidget);
    */
    expect(find.text('* Makeup today'), findsNothing);
    expect(find.text('- Rest'), findsWidgets);
    expect(find.text('+ Makeup yesterday'), findsOneWidget);
  });

  testWidgets('Today excludes paused archived and deleted habits', (
    tester,
  ) async {
    final activeHabit = _testHabit(
      id: 'habit-active',
      name: 'Active',
      emoji: 'A',
    );
    final pausedHabit = _testHabit(
      id: 'habit-paused',
      name: 'Paused',
      emoji: 'P',
      status: HabitLifecycleStatus.paused,
    );
    final archivedHabit = _testHabit(
      id: 'habit-archived',
      name: 'Archived',
      emoji: 'R',
      status: HabitLifecycleStatus.archived,
    );
    final deletedHabit = _testHabit(
      id: 'habit-deleted',
      name: 'Deleted',
      emoji: 'D',
      status: HabitLifecycleStatus.deleted,
    );

    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 25, 9),
          initialHabits: [
            activeHabit,
            pausedHabit,
            archivedHabit,
            deletedHabit,
          ],
          initialRecords: [
            _testRecord(
              id: 'habit-record-active',
              habitId: activeHabit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-paused',
              habitId: pausedHabit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-archived',
              habitId: archivedHabit.id,
              localDate: '2026-04-25',
            ),
            _testRecord(
              id: 'habit-record-deleted',
              habitId: deletedHabit.id,
              localDate: '2026-04-25',
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
        focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
      ),
    );

    expect(find.textContaining('1 次打卡'), findsOneWidget);
    await _scrollToActionPlan(tester);

    expect(find.text('A Active'), findsNothing);
    expect(find.text('P Paused'), findsNothing);
    expect(find.text('R Archived'), findsNothing);
    expect(find.text('D Deleted'), findsNothing);
  });

  testWidgets('Today renders safely on common phone widths', (tester) async {
    final view = tester.view;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final width in <double>[360, 393, 412]) {
      view.devicePixelRatio = 1;
      view.physicalSize = Size(width, 860);

      final habit = _testHabit(
        id: 'habit-responsive-$width',
        name: '小屏幕也清楚的阅读习惯',
        emoji: '📖',
        targetCountPerDay: 2,
        reminderTime: '08:30',
      );

      await tester.pumpWidget(
        FourInOneApp(
          habitsStore: HabitsStore.seededInMemory(
            nowProvider: () => DateTime(2026, 4, 25, 9),
            initialHabits: [habit],
            initialRecords: [
              _testRecord(
                id: 'habit-record-responsive-$width',
                habitId: habit.id,
                localDate: '2026-04-25',
              ),
            ],
          ),
          goalsStore: GoalsStore.inMemory(
            initialGoals: [_testGoal(id: 'goal-responsive', title: '长期目标小屏摘要')],
            initialProjects: [
              _testProject(
                id: 'project-responsive',
                goalId: 'goal-responsive',
                title: '项目小屏摘要',
              ),
            ],
            initialTasks: [
              _testTask(
                id: 'task-responsive',
                projectId: 'project-responsive',
                title: '推进一个明确行动',
              ),
            ],
            initialRecords: [
              PlanRecord(
                id: 'record-responsive',
                projectId: 'project-responsive',
                type: PlanRecordType.note,
                localDate: '2026-04-25',
                note: '来自习惯的今日记录',
                sourceType: GoalsStore.habitPlanRecordSourceType,
                sourceId: habit.id,
                sourceLocalDate: '2026-04-25',
                sourceKey: 'habit:${habit.id}:2026-04-25:dailyCompletion',
                createdAt: DateTime.parse('2026-04-25T09:00:00Z'),
              ),
            ],
          ),
          focusStore: FocusStore.inMemory(defaultDurationSeconds: 25 * 60),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('今天'), findsWidgets);
      expect(find.text('推进一个明确行动'), findsWidgets);
      expect(find.text('0/1'), findsOneWidget);
      await _scrollToActionPlan(tester);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Today overflow at ${width}dp',
      );

      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Today scroll overflow at ${width}dp',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

Future<void> _scrollToActionPlan(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('行动计划'), 300);
  await tester.pumpAndSettle();
}

HabitItem _testHabit({
  required String id,
  required String name,
  required String emoji,
  int targetCountPerDay = 1,
  String? reminderTime,
  HabitLifecycleStatus status = HabitLifecycleStatus.active,
}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: emoji,
    description: '',
    targetCountPerDay: targetCountPerDay,
    reminderTime: reminderTime,
    status: status,
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
  required String title,
  String? subprojectId,
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
