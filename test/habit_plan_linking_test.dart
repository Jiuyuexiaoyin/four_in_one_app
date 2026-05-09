import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habit_plan_record_writer.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';

void main() {
  final now = DateTime(2026, 4, 30, 9);

  HabitItem habit({
    String id = 'habit-1',
    String name = 'Read',
    int targetCountPerDay = 1,
    HabitPlanLink? planLink,
  }) {
    return HabitItem(
      id: id,
      name: name,
      emoji: 'R',
      description: '',
      targetCountPerDay: targetCountPerDay,
      reminderTime: null,
      planLink: planLink,
      createdAt: now,
    );
  }

  HabitPlanLink projectLink({
    String projectId = 'project-1',
    String title = 'Reading project',
  }) {
    return HabitPlanLink(
      targetType: HabitPlanLinkTargetType.project,
      projectId: projectId,
      titleSnapshot: title,
      contextSnapshot: 'Goal / Project',
      createdAt: now,
    );
  }

  HabitPlanLink taskLink() {
    return HabitPlanLink(
      targetType: HabitPlanLinkTargetType.task,
      projectId: 'project-1',
      taskId: 'task-1',
      titleSnapshot: 'Read chapter',
      contextSnapshot: 'Reading project / Sprint / Action',
      createdAt: now,
    );
  }

  GoalsStore goalsStore({
    List<ProjectItem>? projects,
    List<SubprojectItem>? subprojects,
    List<GoalTaskItem>? tasks,
  }) {
    return GoalsStore.inMemory(
      nowProvider: () => now,
      initialGoals: [GoalItem(id: 'goal-1', title: 'Learn', createdAt: now)],
      initialProjects:
          projects ??
          [
            ProjectItem(
              id: 'project-1',
              goalId: 'goal-1',
              title: 'Reading project',
              createdAt: now,
            ),
          ],
      initialSubprojects: subprojects,
      initialTasks: tasks,
    );
  }

  HabitsStore linkedHabitsStore({
    required GoalsStore goalsStore,
    required HabitItem habit,
  }) {
    return HabitsStore.seededInMemory(
      nowProvider: () => now,
      initialHabits: [habit],
      initialRecords: const [],
      initialAttachments: const [],
      planRecordWriter: GoalsHabitPlanRecordWriter(goalsStore),
    );
  }

  test('old and malformed habit plan links load safely', () {
    final baseJson = <String, dynamic>{
      'id': 'habit-1',
      'name': 'Read',
      'emoji': 'R',
      'description': '',
      'targetCountPerDay': 1,
      'reminderTime': null,
      'habitColorValue': null,
      'status': 'active',
      'pausedAt': null,
      'archivedAt': null,
      'deletedAt': null,
      'pauseIntervals': <dynamic>[],
      'reminderRules': <dynamic>[],
      'createdAt': now.toIso8601String(),
    };

    final oldHabit = HabitItem.fromJson(baseJson);
    expect(oldHabit.planLink, isNull);
    expect(HabitItem.needsMigration(baseJson), isTrue);

    final malformedJson = {
      ...baseJson,
      'planLink': {
        'targetType': 'unknown',
        'projectId': 'project-1',
        'titleSnapshot': 'Reading project',
        'createdAt': now.toIso8601String(),
      },
    };
    final malformedHabit = HabitItem.fromJson(malformedJson);
    expect(malformedHabit.planLink, isNull);
    expect(HabitItem.needsMigration(malformedJson), isTrue);
  });

  test('old PlanRecord JSON loads with empty source metadata', () {
    final record = PlanRecord.fromJson({
      'id': 'record-1',
      'projectId': 'project-1',
      'subprojectId': null,
      'taskId': null,
      'type': 'note',
      'localDate': '2026-04-30',
      'note': 'Manual note',
      'numericValue': null,
      'unit': null,
      'createdAt': now.toIso8601String(),
    });

    expect(record.sourceType, isNull);
    expect(record.sourceId, isNull);
    expect(record.sourceLocalDate, isNull);
    expect(record.sourceKey, isNull);
  });

  test('create, edit, and clear habit plan link data', () async {
    final store = HabitsStore.seededInMemory(
      nowProvider: () => now,
      initialHabits: const [],
      initialRecords: const [],
      initialAttachments: const [],
    );

    await store.createHabit('Read', planLink: projectLink());
    expect(store.storedHabits.single.planLink?.projectId, 'project-1');

    await store.updateHabit(
      store.storedHabits.single.id,
      name: 'Read',
      emoji: 'R',
      description: '',
      targetCountPerDay: 1,
      planLink: projectLink(projectId: 'project-2', title: 'Second project'),
    );
    expect(store.storedHabits.single.planLink?.projectId, 'project-2');

    await store.updateHabitPlanLink(store.storedHabits.single.id, null);
    expect(store.storedHabits.single.planLink, isNull);
  });

  test(
    'target-reaching check-in creates one sourced project PlanRecord',
    () async {
      final goals = goalsStore();
      final habits = linkedHabitsStore(
        goalsStore: goals,
        habit: habit(targetCountPerDay: 2, planLink: projectLink()),
      );

      await habits.checkIn('habit-1');
      expect(goals.records, isEmpty);

      await habits.checkIn('habit-1');
      expect(goals.records, hasLength(1));
      final record = goals.records.single;
      expect(record.projectId, 'project-1');
      expect(record.taskId, isNull);
      expect(record.type, PlanRecordType.note);
      expect(record.localDate, '2026-04-30');
      expect(record.note, contains('来自习惯：Read'));
      expect(record.sourceType, GoalsStore.habitPlanRecordSourceType);
      expect(record.sourceId, 'habit-1');
      expect(record.sourceLocalDate, '2026-04-30');
      expect(
        record.sourceKey,
        GoalsStore.habitDailyCompletionSourceKey(
          habitId: 'habit-1',
          localDate: '2026-04-30',
        ),
      );

      await habits.checkIn('habit-1');
      expect(goals.records, hasLength(1));
    },
  );

  test(
    'makeup completion creates sourced task record without completing task',
    () async {
      final goals = goalsStore(
        subprojects: [
          SubprojectItem(
            id: 'subproject-1',
            projectId: 'project-1',
            title: 'Sprint',
            createdAt: now,
          ),
        ],
        tasks: [
          GoalTaskItem(
            id: 'task-1',
            projectId: 'project-1',
            subprojectId: 'subproject-1',
            title: 'Read chapter',
            isCompleted: false,
            createdAt: now,
          ),
        ],
      );
      final habits = linkedHabitsStore(
        goalsStore: goals,
        habit: habit(planLink: taskLink()),
      );

      final created = await habits.makeupCheckIn(
        'habit-1',
        localDate: '2026-04-29',
      );

      expect(created, isTrue);
      expect(goals.records, hasLength(1));
      final record = goals.records.single;
      expect(record.projectId, 'project-1');
      expect(record.subprojectId, 'subproject-1');
      expect(record.taskId, 'task-1');
      expect(record.localDate, '2026-04-29');
      expect(record.sourceLocalDate, '2026-04-29');
      expect(goals.taskById('task-1')?.isCompleted, isFalse);
      expect(goals.computeProjectProgress('project-1').completedTasks, 0);
    },
  );

  test(
    'skip, proof-only, and missing linked targets do not create records',
    () async {
      final goals = goalsStore();
      final habits = linkedHabitsStore(
        goalsStore: goals,
        habit: habit(targetCountPerDay: 2, planLink: projectLink()),
      );

      final skipped = await habits.skipHabit('habit-1');
      expect(skipped, isTrue);
      expect(goals.records, isEmpty);

      await habits.checkIn('habit-1');
      expect(goals.records, isEmpty);
      final checkInRecord = habits.records.firstWhere(
        (record) => record.localDate == '2026-04-30',
      );
      await habits.addRecordAttachment(
        recordId: checkInRecord.id,
        relativePath: 'habit_record_images/proof.jpg',
        fileName: 'proof.jpg',
      );
      expect(goals.records, isEmpty);

      final missingTargetGoals = goalsStore(projects: const []);
      final missingTargetHabits = linkedHabitsStore(
        goalsStore: missingTargetGoals,
        habit: habit(planLink: projectLink(projectId: 'missing-project')),
      );
      await missingTargetHabits.checkIn('habit-1');
      expect(missingTargetGoals.records, isEmpty);
    },
  );

  test(
    'clearing or changing link preserves historical generated records',
    () async {
      final goals = goalsStore(
        projects: [
          ProjectItem(
            id: 'project-1',
            goalId: 'goal-1',
            title: 'Reading project',
            createdAt: now,
          ),
          ProjectItem(
            id: 'project-2',
            goalId: 'goal-1',
            title: 'Second project',
            createdAt: now,
          ),
        ],
      );
      final habits = linkedHabitsStore(
        goalsStore: goals,
        habit: habit(planLink: projectLink()),
      );

      await habits.checkIn('habit-1');
      expect(goals.records.single.projectId, 'project-1');

      await habits.updateHabitPlanLink(
        'habit-1',
        projectLink(projectId: 'project-2', title: 'Second project'),
      );
      expect(goals.records.single.projectId, 'project-1');

      await habits.updateHabitPlanLink('habit-1', null);
      expect(habits.storedHabits.single.planLink, isNull);
      expect(goals.records, hasLength(1));
      expect(goals.records.single.projectId, 'project-1');
    },
  );
}
