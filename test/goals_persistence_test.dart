import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/data/goals_local_storage.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';

void main() {
  test('first load stays empty when no saved goals exist', () async {
    final keyValueStore = _FakeGoalsKeyValueStore();
    final storage = GoalsLocalStorage(store: keyValueStore);

    final store = await GoalsStore.load(
      storage,
      nowProvider: () => DateTime.utc(2026, 4, 25, 8),
    );

    expect(store.totalCount, 0);
    expect(store.projects, isEmpty);
    expect(store.subprojects, isEmpty);
    expect(store.tasks, isEmpty);
    expect(store.records, isEmpty);
    expect(keyValueStore.setCalls, 0);
  });

  test(
    'old flat goals migrate without losing titles or creating fake tasks',
    () async {
      final keyValueStore = _FakeGoalsKeyValueStore(
        values: {
          GoalsLocalStorage.storageKey: jsonEncode([
            {'id': 'goal-7', 'title': '完成骨架', 'isCompleted': true},
            {'id': 'goal-8', 'title': '整理计划', 'isCompleted': false},
          ]),
        },
      );
      final storage = GoalsLocalStorage(store: keyValueStore);

      final store = await GoalsStore.load(
        storage,
        nowProvider: () => DateTime.utc(2026, 4, 25, 8),
      );

      expect(store.goals.map((goal) => goal.title), ['完成骨架', '整理计划']);
      expect(store.projects, isEmpty);
      expect(store.subprojects, isEmpty);
      expect(store.tasks, isEmpty);
      expect(store.records, isEmpty);
      expect(store.attachments, isEmpty);
      expect(store.legacyGoalStates.single.goalId, 'goal-7');
      expect(store.legacyGoalStates.single.wasCompleted, isTrue);
      expect(store.completedCount, 0);
      expect(keyValueStore.setCalls, 1);

      final saved = jsonDecode(
        keyValueStore.values[GoalsLocalStorage.storageKey]!,
      );
      expect(saved['schemaVersion'], 6);
      expect(saved['subprojects'], isEmpty);
      expect(saved['tasks'], isEmpty);
      expect(saved['records'], isEmpty);
      expect(saved['attachments'], isEmpty);
      expect(saved['goals'].first['icon'], GoalItem.defaultIcon);
      expect(saved['goals'].first['description'], '');
      expect(saved['goals'].first['colorValue'], GoalItem.defaultColorValue);
    },
  );

  test('malformed json falls back safely to an empty hierarchy', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {GoalsLocalStorage.storageKey: '{not valid json'},
    );
    final storage = GoalsLocalStorage(store: keyValueStore);

    final store = await GoalsStore.load(storage);

    expect(store.totalCount, 0);
    expect(store.projects, isEmpty);
    expect(store.subprojects, isEmpty);
    expect(store.tasks, isEmpty);
    expect(store.records, isEmpty);
  });

  test('invalid goal items fall back safely to an empty hierarchy', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode([
          {'id': 'goal-1', 'title': 42, 'isCompleted': false},
        ]),
      },
    );
    final storage = GoalsLocalStorage(store: keyValueStore);

    final store = await GoalsStore.load(storage);

    expect(store.totalCount, 0);
    expect(store.projects, isEmpty);
    expect(store.subprojects, isEmpty);
    expect(store.tasks, isEmpty);
    expect(store.records, isEmpty);
  });

  test(
    'new snapshot saves with schemaVersion 6 and default identity',
    () async {
      final keyValueStore = _FakeGoalsKeyValueStore();
      final storage = GoalsLocalStorage(store: keyValueStore);
      final store = await GoalsStore.load(
        storage,
        nowProvider: () => DateTime.utc(2026, 4, 25, 8),
      );

      await store.createGoal('完成最小 MVP');

      final saved = jsonDecode(
        keyValueStore.values[GoalsLocalStorage.storageKey]!,
      );
      expect(saved['schemaVersion'], 6);
      expect(saved['goals'].single['id'], 'goal-1');
      expect(saved['goals'].single['title'], '完成最小 MVP');
      expect(saved['goals'].single['icon'], GoalItem.defaultIcon);
      expect(saved['goals'].single['description'], '');
      expect(saved['goals'].single['colorValue'], GoalItem.defaultColorValue);
      expect(saved['projects'], isEmpty);
      expect(saved['subprojects'], isEmpty);
      expect(saved['tasks'], isEmpty);
      expect(saved['records'], isEmpty);
      expect(saved['attachments'], isEmpty);
    },
  );

  test('loads existing schema 1 hierarchy without subprojects', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 1,
          'goals': [
            {
              'id': 'goal-1',
              'title': '长期目标',
              'createdAt': '2026-04-25T08:00:00.000Z',
            },
          ],
          'projects': [
            {
              'id': 'project-1',
              'goalId': 'goal-1',
              'title': '产品打磨',
              'createdAt': '2026-04-25T08:10:00.000Z',
            },
          ],
          'tasks': [
            {
              'id': 'task-1',
              'projectId': 'project-1',
              'title': '整理信息架构',
              'isCompleted': false,
              'createdAt': '2026-04-25T08:20:00.000Z',
            },
          ],
          'legacyGoalStates': [],
        }),
      },
    );
    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.goals.single.title, '长期目标');
    expect(store.goals.single.icon, GoalItem.defaultIcon);
    expect(store.goals.single.description, '');
    expect(store.goals.single.colorValue, GoalItem.defaultColorValue);
    expect(store.projects.single.title, '产品打磨');
    expect(store.projects.single.icon, ProjectItem.defaultIcon);
    expect(store.projects.single.description, '');
    expect(store.projects.single.colorValue, ProjectItem.defaultColorValue);
    expect(store.projects.single.dueDate, isNull);
    expect(store.projects.single.priority, isNull);
    expect(store.projects.single.tags, isEmpty);
    expect(store.subprojects, isEmpty);
    expect(store.tasks.single.title, '整理信息架构');
    expect(store.tasks.single.subprojectId, isNull);
    expect(store.tasks.single.dueDate, isNull);
    expect(store.tasks.single.priority, isNull);
    expect(store.tasks.single.tags, isEmpty);
    expect(store.records, isEmpty);
  });

  test('malformed planning metadata is sanitized safely', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 6,
          'goals': [
            {
              'id': 'goal-1',
              'title': 'Goal',
              'createdAt': '2026-04-25T08:00:00.000Z',
            },
          ],
          'projects': [
            {
              'id': 'project-1',
              'goalId': 'goal-1',
              'title': 'Project',
              'dueDate': '2026-13-40',
              'priority': 'loud',
              'tags': [' work ', '', 42, 'work', 'very-long-tag-name-value'],
              'createdAt': '2026-04-25T08:10:00.000Z',
            },
          ],
          'subprojects': [],
          'tasks': [
            {
              'id': 'task-1',
              'projectId': 'project-1',
              'title': 'Action',
              'isCompleted': false,
              'dueDate': '2026-02-30',
              'priority': 'urgent',
              'tags': [' next ', 'next', null, 'today'],
              'createdAt': '2026-04-25T08:20:00.000Z',
            },
          ],
          'records': [],
          'attachments': [],
          'legacyGoalStates': [],
        }),
      },
    );

    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.projects.single.dueDate, isNull);
    expect(store.projects.single.priority, isNull);
    expect(store.projects.single.tags, ['work', 'very-long-tag-na']);
    expect(store.tasks.single.dueDate, isNull);
    expect(store.tasks.single.priority, PlanPriority.urgent);
    expect(store.tasks.single.tags, ['next', 'today']);
  });

  test('malformed records are skipped while valid hierarchy loads', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 3,
          'goals': [
            {
              'id': 'goal-1',
              'title': 'Goal',
              'createdAt': '2026-04-25T08:00:00.000Z',
            },
          ],
          'projects': [
            {
              'id': 'project-1',
              'goalId': 'goal-1',
              'title': 'Project',
              'createdAt': '2026-04-25T08:10:00.000Z',
            },
          ],
          'subprojects': [],
          'tasks': [],
          'records': [
            {
              'id': 'record-1',
              'projectId': 'project-1',
              'type': 'note',
              'localDate': '2026-04-25',
              'note': 'Valid note',
              'createdAt': '2026-04-25T08:20:00.000Z',
            },
            {
              'id': 'record-bad',
              'projectId': 'project-1',
              'type': 'numeric',
              'localDate': 'bad-date',
              'numericValue': '30',
              'createdAt': '2026-04-25T08:20:00.000Z',
            },
          ],
          'legacyGoalStates': [],
        }),
      },
    );

    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.goals.single.title, 'Goal');
    expect(store.projects.single.title, 'Project');
    expect(store.records.length, 1);
    expect(store.records.single.id, 'record-1');
  });

  test('loads schema 4 without attachments as empty attachments', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 4,
          'goals': [
            {
              'id': 'goal-1',
              'title': 'Goal',
              'createdAt': '2026-04-25T08:00:00.000Z',
            },
          ],
          'projects': [
            {
              'id': 'project-1',
              'goalId': 'goal-1',
              'title': 'Project',
              'createdAt': '2026-04-25T08:10:00.000Z',
            },
          ],
          'subprojects': [],
          'tasks': [],
          'records': [],
          'legacyGoalStates': [],
        }),
      },
    );

    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.goals.single.id, 'goal-1');
    expect(store.projects.single.id, 'project-1');
    expect(store.records, isEmpty);
    expect(store.attachments, isEmpty);
  });

  test('malformed attachment entries are skipped safely', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 5,
          'goals': [
            {
              'id': 'goal-1',
              'title': 'Goal',
              'createdAt': '2026-04-25T08:00:00.000Z',
            },
          ],
          'projects': [
            {
              'id': 'project-1',
              'goalId': 'goal-1',
              'title': 'Project',
              'createdAt': '2026-04-25T08:10:00.000Z',
            },
          ],
          'subprojects': [],
          'tasks': [],
          'records': [
            {
              'id': 'record-1',
              'projectId': 'project-1',
              'type': 'note',
              'localDate': '2026-04-25',
              'note': 'Valid note',
              'createdAt': '2026-04-25T08:20:00.000Z',
            },
          ],
          'attachments': [
            {
              'id': 'attachment-1',
              'recordId': 'record-1',
              'relativePath': 'plan_record_images/proof.png',
              'fileName': 'proof.png',
              'mimeType': 'image/png',
              'createdAt': '2026-04-25T08:30:00.000Z',
            },
            {
              'id': 'attachment-bad',
              'recordId': 'record-1',
              'relativePath': 'plan_record_images/bad.png',
              'createdAt': '2026-04-25T08:30:00.000Z',
            },
            'not an attachment',
          ],
          'legacyGoalStates': [],
        }),
      },
    );

    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.attachments.length, 1);
    expect(store.attachments.single.id, 'attachment-1');
    expect(store.attachmentForRecord('record-1')?.fileName, 'proof.png');
  });

  test('attachment pointing to missing record is ignored by lookup', () async {
    final keyValueStore = _FakeGoalsKeyValueStore(
      values: {
        GoalsLocalStorage.storageKey: jsonEncode({
          'schemaVersion': 5,
          'goals': [],
          'projects': [],
          'subprojects': [],
          'tasks': [],
          'records': [],
          'attachments': [
            {
              'id': 'attachment-1',
              'recordId': 'record-missing',
              'relativePath': 'plan_record_images/orphan.png',
              'fileName': 'orphan.png',
              'createdAt': '2026-04-25T08:30:00.000Z',
            },
          ],
          'legacyGoalStates': [],
        }),
      },
    );

    final store = await GoalsStore.load(
      GoalsLocalStorage(store: keyValueStore),
    );

    expect(store.attachments.length, 1);
    expect(store.attachmentForRecord('record-missing'), isNull);
  });

  test(
    'adds replaces and removes attachment metadata without storing bytes',
    () async {
      final keyValueStore = _FakeGoalsKeyValueStore();
      final store = await GoalsStore.load(
        GoalsLocalStorage(store: keyValueStore),
        nowProvider: () => DateTime.utc(2026, 4, 25, 8),
      );

      await store.createGoal('Goal');
      await store.createProject('goal-1', 'Project');
      await store.createProjectNoteRecord('project-1', 'Progress note');

      final firstReplaced = await store.replaceRecordAttachment(
        recordId: 'record-1',
        relativePath: 'plan_record_images/proof-a.png',
        fileName: 'proof-a.png',
        mimeType: 'image/png',
      );

      expect(firstReplaced, isNull);
      expect(store.attachments.length, 1);
      expect(store.attachments.single.recordId, 'record-1');
      expect(
        store.attachments.single.relativePath,
        'plan_record_images/proof-a.png',
      );
      expect(store.attachments.single.fileName, 'proof-a.png');
      expect(store.attachments.single.mimeType, 'image/png');
      expect(store.attachments.single.createdAt, DateTime.utc(2026, 4, 25, 8));

      var saved =
          jsonDecode(keyValueStore.values[GoalsLocalStorage.storageKey]!)
              as Map<String, dynamic>;
      expect(saved['attachments'], hasLength(1));
      expect(jsonEncode(saved), isNot(contains('data:image')));
      expect(jsonEncode(saved), isNot(contains('base64')));

      final secondReplaced = await store.replaceRecordAttachment(
        recordId: 'record-1',
        relativePath: 'plan_record_images/proof-b.jpg',
        fileName: 'proof-b.jpg',
        mimeType: 'image/jpeg',
      );

      expect(secondReplaced?.relativePath, 'plan_record_images/proof-a.png');
      expect(store.attachments.length, 1);
      expect(
        store.attachments.single.relativePath,
        'plan_record_images/proof-b.jpg',
      );

      saved =
          jsonDecode(keyValueStore.values[GoalsLocalStorage.storageKey]!)
              as Map<String, dynamic>;
      expect(saved['attachments'], hasLength(1));
      expect(saved['attachments'].single['fileName'], 'proof-b.jpg');

      final removed = await store.removeRecordAttachment('record-1');

      expect(removed?.relativePath, 'plan_record_images/proof-b.jpg');
      expect(store.attachments, isEmpty);
      expect(store.records.single.note, 'Progress note');

      saved =
          jsonDecode(keyValueStore.values[GoalsLocalStorage.storageKey]!)
              as Map<String, dynamic>;
      expect(saved['attachments'], isEmpty);
      expect(saved['records'], hasLength(1));
    },
  );

  test('record stats and task progress ignore image attachments', () async {
    final store = GoalsStore.inMemory(
      nowProvider: () => DateTime(2026, 4, 25, 8),
    );

    await store.createGoal('Goal');
    await store.createProject('goal-1', 'Project');
    await store.createTask('project-1', 'Action');
    await store.createProjectNoteRecord('project-1', 'Progress note');
    await store.createProjectNumericRecord('project-1', 12, 'pages');
    await store.replaceRecordAttachment(
      recordId: 'record-1',
      relativePath: 'plan_record_images/proof.png',
      fileName: 'proof.png',
      mimeType: 'image/png',
    );

    final stats = store.computeProjectRecordStats('project-1');

    expect(stats.recordCount, 2);
    expect(stats.noteRecordCount, 1);
    expect(stats.activeDaysCount, 1);
    expect(stats.currentMonthRecordCount, 2);
    expect(stats.photoAttachmentCount, 1);
    expect(stats.numericTotalsByUnit, {'pages': 12});
    expect(stats.currentMonthCountsByLocalDate, {'2026-04-25': 2});
    expect(stats.currentYearRecordCount, 2);
    expect(stats.currentYearCountsByLocalDate, {'2026-04-25': 2});
    expect(stats.currentYearCountsByMonth, {4: 2});
    expect(store.computeProjectProgress('project-1').completedTasks, 0);
    expect(store.computeProjectProgress('project-1').totalTasks, 1);

    await store.toggleTask('task-1');

    expect(store.computeProjectProgress('project-1').completedTasks, 1);
    expect(store.recordsForProject('project-1'), hasLength(2));
    expect(store.attachments, hasLength(1));
  });

  test(
    'project stats include child records photos and ignore orphan attachments',
    () {
      final store = GoalsStore.inMemory(
        initialGoals: [
          GoalItem(
            id: 'goal-1',
            title: 'Goal',
            createdAt: DateTime.utc(2026, 4, 25, 8),
          ),
          GoalItem(
            id: 'goal-2',
            title: 'Other goal',
            createdAt: DateTime.utc(2026, 4, 25, 8),
          ),
        ],
        initialProjects: [
          ProjectItem(
            id: 'project-1',
            goalId: 'goal-1',
            title: 'Project',
            createdAt: DateTime.utc(2026, 4, 25, 8, 10),
          ),
          ProjectItem(
            id: 'project-2',
            goalId: 'goal-2',
            title: 'Other project',
            createdAt: DateTime.utc(2026, 4, 25, 8, 10),
          ),
        ],
        initialSubprojects: [
          SubprojectItem(
            id: 'subproject-1',
            projectId: 'project-1',
            title: 'Strength',
            createdAt: DateTime.utc(2026, 4, 25, 8, 15),
          ),
        ],
        initialTasks: [
          GoalTaskItem(
            id: 'task-1',
            projectId: 'project-1',
            subprojectId: 'subproject-1',
            title: 'Squats',
            isCompleted: false,
            createdAt: DateTime.utc(2026, 4, 25, 8, 20),
          ),
        ],
        initialRecords: [
          PlanRecord(
            id: 'record-1',
            projectId: 'project-1',
            type: PlanRecordType.note,
            localDate: '2026-04-25',
            note: 'Project note',
            createdAt: DateTime.utc(2026, 4, 25, 9),
          ),
          PlanRecord(
            id: 'record-2',
            projectId: 'project-1',
            subprojectId: 'subproject-1',
            type: PlanRecordType.note,
            localDate: '2026-04-26',
            note: 'Subproject note',
            createdAt: DateTime.utc(2026, 4, 26, 9),
          ),
          PlanRecord(
            id: 'record-3',
            projectId: 'project-1',
            subprojectId: 'subproject-1',
            taskId: 'task-1',
            type: PlanRecordType.numeric,
            localDate: '2026-04-26',
            numericValue: 30,
            unit: '个',
            createdAt: DateTime.utc(2026, 4, 26, 10),
          ),
          PlanRecord(
            id: 'record-4',
            projectId: 'project-1',
            type: PlanRecordType.numeric,
            localDate: '2026-03-25',
            numericValue: 45,
            unit: '分钟',
            createdAt: DateTime.utc(2026, 3, 25, 9),
          ),
          PlanRecord(
            id: 'record-other',
            projectId: 'project-2',
            type: PlanRecordType.numeric,
            localDate: '2026-04-25',
            numericValue: 999,
            unit: '个',
            createdAt: DateTime.utc(2026, 4, 25, 9),
          ),
        ],
        initialAttachments: [
          PlanRecordAttachment(
            id: 'attachment-1',
            recordId: 'record-1',
            relativePath: 'plan_record_images/project.png',
            fileName: 'project.png',
            createdAt: DateTime.utc(2026, 4, 25, 10),
          ),
          PlanRecordAttachment(
            id: 'attachment-2',
            recordId: 'record-3',
            relativePath: 'plan_record_images/task.png',
            fileName: 'task.png',
            createdAt: DateTime.utc(2026, 4, 26, 10),
          ),
          PlanRecordAttachment(
            id: 'attachment-other',
            recordId: 'record-other',
            relativePath: 'plan_record_images/other.png',
            fileName: 'other.png',
            createdAt: DateTime.utc(2026, 4, 25, 10),
          ),
          PlanRecordAttachment(
            id: 'attachment-orphan',
            recordId: 'record-missing',
            relativePath: 'plan_record_images/orphan.png',
            fileName: 'orphan.png',
            createdAt: DateTime.utc(2026, 4, 25, 10),
          ),
        ],
        nowProvider: () => DateTime(2026, 4, 26, 8),
      );

      final stats = store.computeProjectRecordStats('project-1');

      expect(stats.recordCount, 4);
      expect(stats.noteRecordCount, 2);
      expect(stats.activeDaysCount, 3);
      expect(stats.currentMonthRecordCount, 3);
      expect(stats.photoAttachmentCount, 2);
      expect(stats.numericTotalsByUnit, {'个': 30, '分钟': 45});
      expect(stats.currentMonthCountsByLocalDate, {
        '2026-04-25': 1,
        '2026-04-26': 2,
      });
      expect(stats.currentYearRecordCount, 4);
      expect(stats.currentYearCountsByLocalDate, {
        '2026-04-25': 1,
        '2026-04-26': 2,
        '2026-03-25': 1,
      });
      expect(stats.currentYearCountsByMonth, {4: 3, 3: 1});
    },
  );

  test('invalid local dates do not crash derived project stats', () {
    final store = GoalsStore.inMemory(
      initialProjects: [
        ProjectItem(
          id: 'project-1',
          goalId: 'goal-1',
          title: 'Project',
          createdAt: DateTime.utc(2026, 4, 25, 8),
        ),
      ],
      initialRecords: [
        PlanRecord(
          id: 'record-1',
          projectId: 'project-1',
          type: PlanRecordType.note,
          localDate: 'bad-date',
          note: 'Imported malformed date',
          createdAt: DateTime.utc(2026, 4, 25, 9),
        ),
      ],
      nowProvider: () => DateTime(2026, 4, 25, 8),
    );

    final stats = store.computeProjectRecordStats('project-1');

    expect(stats.recordCount, 1);
    expect(stats.activeDaysCount, 0);
    expect(stats.currentMonthRecordCount, 0);
    expect(stats.currentMonthCountsByLocalDate, isEmpty);
    expect(stats.currentYearRecordCount, 0);
    expect(stats.currentYearCountsByLocalDate, isEmpty);
    expect(stats.currentYearCountsByMonth, isEmpty);
  });

  test('creates goals, projects, subprojects, and tasks', () async {
    final store = GoalsStore.inMemory(
      nowProvider: () => DateTime.utc(2026, 4, 25, 8),
    );

    await store.createGoal('长期目标');
    await store.createProject('goal-1', '产品打磨');
    await store.createSubproject('project-1', '设计分组');
    await store.createTask('project-1', '整理信息架构');
    await store.createTask('project-1', '完成视觉草稿', subprojectId: 'subproject-1');

    expect(store.goals.single.title, '长期目标');
    expect(store.getProjectsForGoal('goal-1').single.title, '产品打磨');
    expect(store.getSubprojectsForProject('project-1').single.title, '设计分组');
    expect(store.getDirectTasksForProject('project-1').single.title, '整理信息架构');
    expect(store.getTasksForSubproject('subproject-1').single.title, '完成视觉草稿');
    expect(store.getTasksForProject('project-1').length, 2);
  });

  test('creates project and task records with grouped numeric stats', () async {
    final store = GoalsStore.inMemory(
      nowProvider: () => DateTime(2026, 4, 25, 8),
    );

    await store.createGoal('Goal');
    await store.createProject('goal-1', 'Fitness project');
    await store.createSubproject('project-1', 'Strength');
    await store.createTask('project-1', 'Squats', subprojectId: 'subproject-1');

    expect(
      await store.createProjectNoteRecord('project-1', 'Good rhythm'),
      isTrue,
    );
    expect(
      await store.createProjectNumericRecord(
        'project-1',
        30,
        '个',
        localDate: '2026-04-25',
      ),
      isTrue,
    );
    expect(
      await store.createTaskNoteRecord(
        'task-1',
        'First set done',
        localDate: '2026-04-24',
      ),
      isTrue,
    );
    expect(
      await store.createTaskNumericRecord(
        'task-1',
        20,
        '分钟',
        localDate: '2026-03-25',
      ),
      isTrue,
    );

    expect(store.recordsForProject('project-1').length, 4);
    expect(store.recordsForTask('task-1').length, 2);
    expect(store.recordsForMonth('project-1', 2026, 4).length, 3);

    final stats = store.computeProjectRecordStats('project-1');
    expect(stats.recordCount, 4);
    expect(stats.noteRecordCount, 2);
    expect(stats.activeDaysCount, 3);
    expect(stats.currentMonthRecordCount, 3);
    expect(stats.photoAttachmentCount, 0);
    expect(stats.currentMonthCountsByLocalDate, {
      '2026-04-25': 2,
      '2026-04-24': 1,
    });
    expect(stats.currentYearRecordCount, 4);
    expect(stats.currentYearCountsByLocalDate, {
      '2026-04-25': 2,
      '2026-04-24': 1,
      '2026-03-25': 1,
    });
    expect(stats.currentYearCountsByMonth, {4: 3, 3: 1});
    expect(stats.numericTotalsByUnit['个'], 30);
    expect(stats.numericTotalsByUnit['分钟'], 20);

    expect(store.computeProjectProgress('project-1').completedTasks, 0);
    expect(store.computeProjectProgress('project-1').totalTasks, 1);
    await store.toggleTask('task-1');
    expect(store.computeProjectProgress('project-1').completedTasks, 1);
  });

  test(
    'edits goal and project identity without resetting records or progress',
    () async {
      final store = GoalsStore.inMemory(
        nowProvider: () => DateTime(2026, 4, 25, 8),
      );

      await store.createGoal('Original goal');
      await store.createProject('goal-1', 'Original project');
      await store.createTask('project-1', 'Action');
      await store.createProjectNoteRecord('project-1', 'Record note');
      await store.toggleTask('task-1');

      final goalUpdated = await store.updateGoalIdentity(
        'goal-1',
        title: 'Updated goal',
        icon: '🚀',
        description: 'Long-term direction',
        colorValue: 0xFF6B8A86,
      );
      final projectUpdated = await store.updateProjectIdentity(
        'project-1',
        title: 'Updated project',
        icon: '📚',
        description: 'Project direction',
        colorValue: 0xFF8A7465,
      );

      expect(goalUpdated, isTrue);
      expect(projectUpdated, isTrue);
      expect(store.goals.single.id, 'goal-1');
      expect(store.goals.single.title, 'Updated goal');
      expect(store.goals.single.icon, '🚀');
      expect(store.goals.single.description, 'Long-term direction');
      expect(store.goals.single.colorValue, 0xFF6B8A86);
      expect(store.projects.single.id, 'project-1');
      expect(store.projects.single.goalId, 'goal-1');
      expect(store.projects.single.title, 'Updated project');
      expect(store.projects.single.icon, '📚');
      expect(store.projects.single.description, 'Project direction');
      expect(store.projects.single.colorValue, 0xFF8A7465);
      expect(store.records.single.note, 'Record note');
      expect(store.computeProjectProgress('project-1').completedTasks, 1);
      expect(store.computeGoalProgress('goal-1').completedTasks, 1);
    },
  );

  test(
    'edits project and task planning metadata without changing progress',
    () async {
      final keyValueStore = _FakeGoalsKeyValueStore();
      final store = await GoalsStore.load(
        GoalsLocalStorage(store: keyValueStore),
        nowProvider: () => DateTime(2026, 4, 25, 8),
      );

      await store.createGoal('Goal');
      await store.createProject('goal-1', 'Project');
      await store.createTask('project-1', 'Action');
      await store.toggleTask('task-1');

      expect(
        await store.updateProjectPlanningMeta(
          'project-1',
          dueDate: '2026-04-30',
          priority: PlanPriority.high,
          tags: [' work ', 'launch', 'work'],
        ),
        isTrue,
      );
      expect(
        await store.updateTaskPlanningMeta(
          'task-1',
          dueDate: '2026-04-26',
          priority: PlanPriority.urgent,
          tags: ['today', ' focus '],
        ),
        isTrue,
      );

      expect(store.projects.single.dueDate, '2026-04-30');
      expect(store.projects.single.priority, PlanPriority.high);
      expect(store.projects.single.tags, ['work', 'launch']);
      expect(store.tasks.single.dueDate, '2026-04-26');
      expect(store.tasks.single.priority, PlanPriority.urgent);
      expect(store.tasks.single.tags, ['today', 'focus']);
      expect(store.tasks.single.isCompleted, isTrue);
      expect(store.computeProjectProgress('project-1').completedTasks, 1);

      final saved =
          jsonDecode(keyValueStore.values[GoalsLocalStorage.storageKey]!)
              as Map<String, dynamic>;
      expect(saved['projects'].single['dueDate'], '2026-04-30');
      expect(saved['projects'].single['priority'], 'high');
      expect(saved['projects'].single['tags'], ['work', 'launch']);
      expect(saved['tasks'].single['dueDate'], '2026-04-26');
      expect(saved['tasks'].single['priority'], 'urgent');
      expect(saved['tasks'].single['tags'], ['today', 'focus']);
      expect(saved['tasks'].single['isCompleted'], isTrue);

      expect(
        await store.updateProjectPlanningMeta(
          'project-1',
          dueDate: '2026-11-31',
          priority: PlanPriority.low,
          tags: ['later'],
        ),
        isTrue,
      );
      expect(
        await store.updateTaskPlanningMeta(
          'task-1',
          dueDate: '2026-02-30',
          priority: PlanPriority.medium,
          tags: ['retry'],
        ),
        isTrue,
      );

      expect(store.projects.single.dueDate, isNull);
      expect(store.projects.single.priority, PlanPriority.low);
      expect(store.projects.single.tags, ['later']);
      expect(store.tasks.single.dueDate, isNull);
      expect(store.tasks.single.priority, PlanPriority.medium);
      expect(store.tasks.single.tags, ['retry']);
      expect(store.tasks.single.isCompleted, isTrue);

      expect(
        await store.updateProjectPlanningMeta(
          'project-1',
          dueDate: null,
          priority: null,
          tags: const <String>[],
        ),
        isTrue,
      );
      expect(
        await store.updateTaskPlanningMeta(
          'task-1',
          dueDate: null,
          priority: null,
          tags: const <String>[],
        ),
        isTrue,
      );

      expect(store.projects.single.dueDate, isNull);
      expect(store.projects.single.priority, isNull);
      expect(store.projects.single.tags, isEmpty);
      expect(store.tasks.single.dueDate, isNull);
      expect(store.tasks.single.priority, isNull);
      expect(store.tasks.single.tags, isEmpty);
      expect(store.tasks.single.isCompleted, isTrue);

      final cleared =
          jsonDecode(keyValueStore.values[GoalsLocalStorage.storageKey]!)
              as Map<String, dynamic>;
      expect(cleared['projects'].single['dueDate'], isNull);
      expect(cleared['projects'].single['priority'], isNull);
      expect(cleared['projects'].single['tags'], isEmpty);
      expect(cleared['tasks'].single['dueDate'], isNull);
      expect(cleared['tasks'].single['priority'], isNull);
      expect(cleared['tasks'].single['tags'], isEmpty);
      expect(cleared['tasks'].single['isCompleted'], isTrue);
    },
  );

  test(
    'due date helpers keep completed overdue work out of active overdue',
    () {
      final store = GoalsStore.inMemory(
        initialGoals: [
          GoalItem(
            id: 'goal-1',
            title: 'Goal',
            createdAt: DateTime.utc(2026, 4, 20),
          ),
        ],
        initialProjects: [
          ProjectItem(
            id: 'project-open',
            goalId: 'goal-1',
            title: 'Open project',
            dueDate: '2026-04-24',
            createdAt: DateTime.utc(2026, 4, 20),
          ),
          ProjectItem(
            id: 'project-complete',
            goalId: 'goal-1',
            title: 'Complete project',
            dueDate: '2026-04-24',
            createdAt: DateTime.utc(2026, 4, 20),
          ),
        ],
        initialTasks: [
          GoalTaskItem(
            id: 'task-open',
            projectId: 'project-open',
            title: 'Open action',
            isCompleted: false,
            dueDate: '2026-04-24',
            createdAt: DateTime.utc(2026, 4, 20),
          ),
          GoalTaskItem(
            id: 'task-complete',
            projectId: 'project-complete',
            title: 'Complete action',
            isCompleted: true,
            dueDate: '2026-04-24',
            createdAt: DateTime.utc(2026, 4, 20),
          ),
        ],
        nowProvider: () => DateTime(2026, 4, 25, 8),
      );

      expect(store.isProjectOverdue(store.projects.first), isTrue);
      expect(store.isTaskOverdue(store.tasks.first), isTrue);
      expect(store.isProjectOverdue(store.projects.last), isFalse);
      expect(store.isTaskOverdue(store.tasks.last), isFalse);
    },
  );

  test(
    'toggles task completion and rolls project progress up from direct tasks',
    () async {
      final store = GoalsStore.inMemory(
        nowProvider: () => DateTime.utc(2026, 4, 25, 8),
      );

      await store.createGoal('长期目标');
      await store.createProject('goal-1', '产品打磨');
      await store.createTask('project-1', '整理信息架构');
      await store.createTask('project-1', '完成低保真');

      expect(store.computeProjectProgress('project-1').completedTasks, 0);
      expect(store.computeProjectProgress('project-1').totalTasks, 2);
      expect(store.computeProjectProgress('project-1').label, '进度 0%');

      await store.toggleTask('task-1');

      final progress = store.computeProjectProgress('project-1');
      expect(progress.completedTasks, 1);
      expect(progress.totalTasks, 2);
      expect(progress.percentage, 50);
      expect(store.getTasksForProject('project-1').last.isCompleted, isTrue);
    },
  );

  test('rolls subproject progress up from child tasks', () async {
    final store = GoalsStore.inMemory(
      nowProvider: () => DateTime.utc(2026, 4, 25, 8),
    );

    await store.createGoal('长期目标');
    await store.createProject('goal-1', '产品打磨');
    await store.createSubproject('project-1', '设计分组');
    await store.createTask('project-1', '视觉草稿', subprojectId: 'subproject-1');
    await store.createTask('project-1', '交互草稿', subprojectId: 'subproject-1');

    expect(store.computeSubprojectProgress('subproject-1').label, '进度 0%');

    await store.toggleTask('task-1');

    final progress = store.computeSubprojectProgress('subproject-1');
    expect(progress.completedTasks, 1);
    expect(progress.totalTasks, 2);
    expect(progress.percentage, 50);
  });

  test('rolls goal progress up from direct and subproject tasks', () async {
    final store = GoalsStore.inMemory(
      nowProvider: () => DateTime.utc(2026, 4, 25, 8),
    );

    await store.createGoal('长期目标');
    await store.createProject('goal-1', '项目 A');
    await store.createProject('goal-1', '项目 B');
    await store.createSubproject('project-1', '分组 A');
    await store.createTask('project-1', '行动 A');
    await store.createTask('project-1', '分组行动', subprojectId: 'subproject-1');
    await store.createTask('project-2', '行动 B');
    await store.toggleTask('task-1');
    await store.toggleTask('task-2');
    await store.toggleTask('task-3');

    final projectProgress = store.computeProjectProgress('project-1');
    expect(projectProgress.completedTasks, 2);
    expect(projectProgress.totalTasks, 2);

    final goalProgress = store.computeGoalProgress('goal-1');
    expect(goalProgress.completedTasks, 3);
    expect(goalProgress.totalTasks, 3);
    expect(goalProgress.isComplete, isTrue);
    expect(store.completedCount, 1);
  });

  test('zero-task goal has a neutral progress state', () async {
    final store = GoalsStore.inMemory();

    await store.createGoal('还没拆解的长期目标');

    final progress = store.computeGoalProgress('goal-1');
    expect(progress.hasTasks, isFalse);
    expect(progress.isComplete, isFalse);
    expect(progress.label, '尚未添加行动');
    expect(store.completedCount, 0);
  });
}

class _FakeGoalsKeyValueStore implements GoalsKeyValueStore {
  _FakeGoalsKeyValueStore({Map<String, String>? values})
    : values = values ?? <String, String>{};

  final Map<String, String> values;
  int setCalls = 0;

  @override
  Future<String?> getString(String key) async {
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    setCalls += 1;
    values[key] = value;
  }
}
