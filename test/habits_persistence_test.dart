import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habits_local_storage.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';

void main() {
  test('creating a habit with only name uses defaults', () async {
    final storage = _FakeHabitsStorage(
      storedSnapshot: const HabitsSnapshot.empty(),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    await store.createHabit('Meditate');

    final habit = store.habits.first;
    expect(habit.name, 'Meditate');
    expect(habit.emoji, HabitItem.defaultEmoji);
    expect(habit.description, '');
    expect(habit.targetCountPerDay, 1);
    expect(habit.reminderTime, isNull);
    expect(habit.habitColorValue, isNull);
  });

  test('creating a habit stores optional identity fields', () async {
    final storage = _FakeHabitsStorage(
      storedSnapshot: const HabitsSnapshot.empty(),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    await store.createHabit(
      'Journal',
      emoji: '✍️',
      description: 'Write one clear thought.',
      targetCountPerDay: 3,
      reminderTime: '08:30',
      habitColorValue: 0xFF6FA982,
    );

    final habit = storage.lastSavedSnapshot!.habits.first;
    expect(habit.name, 'Journal');
    expect(habit.emoji, '✍️');
    expect(habit.description, 'Write one clear thought.');
    expect(habit.targetCountPerDay, 3);
    expect(habit.reminderTime, '08:30');
    expect(habit.habitColorValue, 0xFF6FA982);
  });

  test('old reminderTime migrates to one enabled all-week rule', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-1',
            'name': 'Saved habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': '08:30',
            'habitColorValue': null,
            'status': 'active',
            'pausedAt': null,
            'archivedAt': null,
            'deletedAt': null,
            'pauseIntervals': [],
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits.single.reminderRules, hasLength(1));
    expect(snapshot.habits.single.reminderRules.single.time, '08:30');
    expect(snapshot.habits.single.reminderRules.single.weekdays, [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ]);
    expect(snapshot.habits.single.reminderRules.single.isEnabled, isTrue);
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test('null reminderTime migrates to empty reminder rules', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-1',
            'name': 'Saved habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': null,
            'status': 'active',
            'pausedAt': null,
            'archivedAt': null,
            'deletedAt': null,
            'pauseIntervals': [],
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits.single.reminderRules, isEmpty);
    expect(snapshot.habits.single.reminderTime, isNull);
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test('malformed reminder rules are skipped safely', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-1',
            'name': 'Saved habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': null,
            'status': 'active',
            'pausedAt': null,
            'archivedAt': null,
            'deletedAt': null,
            'pauseIntervals': [],
            'reminderRules': [
              {
                'id': 'rule-valid',
                'time': '08:30',
                'weekdays': [1, 3, 5],
                'isEnabled': true,
                'createdAt': '2026-04-23T08:00:00.000Z',
              },
              {
                'id': 'rule-bad-time',
                'time': '25:00',
                'weekdays': [1, 2, 3],
                'isEnabled': true,
                'createdAt': '2026-04-23T08:00:00.000Z',
              },
              {
                'id': 'rule-empty-weekdays',
                'time': '09:00',
                'weekdays': [],
                'isEnabled': true,
                'createdAt': '2026-04-23T08:00:00.000Z',
              },
              'not a rule',
            ],
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits.single.reminderRules, hasLength(1));
    expect(snapshot.habits.single.reminderRules.single.id, 'rule-valid');
    expect(snapshot.habits.single.reminderTime, '08:30');
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test(
    'editing a habit updates identity fields and preserves records',
    () async {
      final habit = _habit();
      final records = [
        _record(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-23',
        ),
        _record(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-22',
        ),
      ];
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(habits: [habit], records: records),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime(2026, 4, 23, 9),
      );

      final updated = await store.updateHabit(
        habit.id,
        name: 'Evening journal',
        emoji: '✍️',
        description: 'Close the day gently.',
        targetCountPerDay: 2,
        reminderTime: '21:30',
        habitColorValue: 0xFF8E86B6,
      );

      final editedHabit = store.habits.single;
      expect(updated, isTrue);
      expect(editedHabit.name, 'Evening journal');
      expect(editedHabit.emoji, '✍️');
      expect(editedHabit.description, 'Close the day gently.');
      expect(editedHabit.targetCountPerDay, 2);
      expect(editedHabit.reminderTime, '21:30');
      expect(editedHabit.habitColorValue, 0xFF8E86B6);
      expect(store.records.map((record) => record.id), [
        'habit-record-1',
        'habit-record-2',
      ]);
      expect(storage.lastSavedSnapshot!.records.length, 2);
    },
  );

  test('editing target count recalculates today completion', () async {
    final habit = _habit(targetCountPerDay: 2);
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(
        habits: [habit],
        records: [
          _record(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
        ],
      ),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    expect(store.isCompletedToday(store.habits.single), isFalse);

    final updated = await store.updateHabit(
      habit.id,
      name: habit.name,
      emoji: habit.emoji,
      description: habit.description,
      targetCountPerDay: 1,
      reminderTime: habit.reminderTime,
    );

    expect(updated, isTrue);
    expect(store.isCompletedToday(store.habits.single), isTrue);
    expect(store.completedCount, 1);
  });

  test(
    'editing habit color preserves records attachments reminders and counts',
    () async {
      final habit = _habit(targetCountPerDay: 2, habitColorValue: 0xFF6FA982);
      final records = [
        _record(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-23',
        ),
        _record(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-23',
        ),
      ];
      final attachment = HabitRecordAttachment(
        id: 'habit-attachment-1',
        recordId: 'habit-record-1',
        habitId: habit.id,
        relativePath: 'habit_record_images/proof.png',
        fileName: 'proof.png',
        mimeType: 'image/png',
        createdAt: DateTime.utc(2026, 4, 23, 9),
      );
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(
          habits: [habit],
          records: records,
          attachments: [attachment],
        ),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime(2026, 4, 23, 9),
      );

      final updated = await store.updateHabit(
        habit.id,
        name: habit.name,
        emoji: habit.emoji,
        description: habit.description,
        targetCountPerDay: habit.targetCountPerDay,
        reminderTime: habit.reminderTime,
        habitColorValue: 0xFF4F8D8B,
      );

      expect(updated, isTrue);
      expect(store.habits.single.habitColorValue, 0xFF4F8D8B);
      expect(store.todayCheckInCount(store.habits.single), 2);
      expect(store.isCompletedToday(store.habits.single), isTrue);
      expect(store.records.map((record) => record.id), [
        'habit-record-1',
        'habit-record-2',
      ]);
      expect(store.attachments.single.id, 'habit-attachment-1');
    },
  );

  test('clearing habit color returns to global accent fallback', () async {
    final habit = _habit(habitColorValue: 0xFF6FA982);
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final updated = await store.updateHabit(
      habit.id,
      name: habit.name,
      emoji: habit.emoji,
      description: habit.description,
      targetCountPerDay: habit.targetCountPerDay,
      reminderTime: habit.reminderTime,
      clearHabitColorValue: true,
    );

    expect(updated, isTrue);
    expect(store.habits.single.habitColorValue, isNull);
    expect(storage.lastSavedSnapshot!.habits.single.habitColorValue, isNull);
  });

  test('editing rejects empty name and invalid target count', () async {
    final habit = _habit(targetCountPerDay: 2);
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final emptyNameUpdated = await store.updateHabit(
      habit.id,
      name: '   ',
      emoji: '🌙',
      description: 'Should not apply.',
      targetCountPerDay: 1,
      reminderTime: '07:00',
    );
    final invalidTargetUpdated = await store.updateHabit(
      habit.id,
      name: 'Still saved habit',
      emoji: '🌙',
      description: 'Should not apply.',
      targetCountPerDay: 0,
      reminderTime: '07:00',
    );

    expect(emptyNameUpdated, isFalse);
    expect(invalidTargetUpdated, isFalse);
    expect(store.habits.single.name, habit.name);
    expect(store.habits.single.targetCountPerDay, 2);
    expect(storage.saveCalls, 0);
  });

  test('multiple check-ins on the same local day can exceed target', () async {
    final habit = _habit(targetCountPerDay: 3);
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    await store.checkIn(habit.id);
    await store.checkIn(habit.id);
    await store.checkIn(habit.id);
    await store.checkIn(habit.id);

    expect(store.todayCheckInCount(habit), 4);
    expect(store.totalCheckInsToday, 4);
    expect(store.isCompletedToday(habit), isTrue);
    expect(store.completedCount, 1);
    expect(storage.lastSavedSnapshot!.records.length, 4);
  });

  test(
    'check-in notes persist while one-tap check-in stays optional',
    () async {
      final habit = _habit(targetCountPerDay: 2);
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime(2026, 4, 23, 9),
      );

      await store.checkIn(habit.id, note: '  Felt calm after reading.  ');
      await store.checkIn(habit.id);

      expect(store.todayCheckInCount(habit), 2);
      expect(store.isCompletedToday(habit), isTrue);
      expect(storage.lastSavedSnapshot!.records.length, 2);
      expect(storage.lastSavedSnapshot!.records.first.note, isNull);
      expect(
        storage.lastSavedSnapshot!.records.last.note,
        'Felt calm after reading.',
      );
    },
  );

  test('skip record persists and does not count as completion', () async {
    final habit = _habit();
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final skipped = await store.skipHabit(habit.id, note: 'Rest day.');

    expect(skipped, isTrue);
    expect(store.todayCheckInCount(habit), 0);
    expect(store.totalCheckInsToday, 0);
    expect(store.isCompletedToday(habit), isFalse);
    expect(store.isSkippedToday(habit), isTrue);
    expect(
      storage.lastSavedSnapshot!.records.single.type,
      HabitRecordType.skip,
    );
    expect(storage.lastSavedSnapshot!.records.single.note, 'Rest day.');

    await store.checkIn(habit.id);

    expect(store.todayCheckInCount(habit), 1);
    expect(store.totalCheckInsToday, 1);
    expect(store.isCompletedToday(habit), isTrue);
    expect(store.isSkippedToday(habit), isFalse);

    final skippedAfterCheckIn = await store.skipHabit(
      habit.id,
      note: 'Should not apply.',
    );

    expect(skippedAfterCheckIn, isFalse);
    expect(
      store.records.where((record) => record.type == HabitRecordType.skip),
      hasLength(1),
    );
  });

  test(
    'duplicate skip on the same local date replaces skip metadata',
    () async {
      final habit = _habit();
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime(2026, 4, 23, 9),
      );

      await store.skipHabit(habit.id, note: 'First reason.');
      await store.skipHabit(habit.id, note: 'Updated reason.');

      final skipRecords = store.records
          .where((record) => record.type == HabitRecordType.skip)
          .toList(growable: false);
      expect(skipRecords.length, 1);
      expect(skipRecords.single.note, 'Updated reason.');
    },
  );

  test('makeup check-in counts on selected local date only', () async {
    final habit = _habit();
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(habits: [habit], records: const []),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final yesterdayMakeup = await store.makeupCheckIn(
      habit.id,
      localDate: '2026-04-22',
      note: 'Made it up.',
    );

    expect(yesterdayMakeup, isTrue);
    expect(store.activityCountOn(habit, '2026-04-22'), 1);
    expect(store.todayCheckInCount(habit), 0);
    expect(store.totalCheckInsToday, 0);

    final todayMakeup = await store.makeupCheckIn(
      habit.id,
      localDate: '2026-04-23',
    );
    final futureMakeup = await store.makeupCheckIn(
      habit.id,
      localDate: '2026-04-24',
    );

    expect(todayMakeup, isFalse);
    expect(futureMakeup, isFalse);
    expect(store.todayCheckInCount(habit), 0);
    expect(store.totalCheckInsToday, 0);
    expect(store.currentMonthActivity(habit).days[21].count, 1);
    expect(store.currentMonthActivity(habit).days[22].count, 0);
  });

  test(
    'skip is blocked for future dates and dates with effective check-ins',
    () async {
      final habit = _habit();
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(
          habits: [habit],
          records: [
            _record(
              id: 'habit-record-1',
              habitId: habit.id,
              localDate: '2026-04-22',
              type: HabitRecordType.makeup,
            ),
          ],
        ),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime(2026, 4, 23, 9),
      );

      final skippedPastCompleted = await store.skipHabit(
        habit.id,
        localDate: '2026-04-22',
      );
      final skippedFuture = await store.skipHabit(
        habit.id,
        localDate: '2026-04-24',
      );
      final skippedPastOpen = await store.skipHabit(
        habit.id,
        localDate: '2026-04-21',
        note: 'Intentional rest.',
      );

      expect(skippedPastCompleted, isFalse);
      expect(skippedFuture, isFalse);
      expect(skippedPastOpen, isTrue);
      expect(store.activityCountOn(habit, '2026-04-21'), 0);
      expect(
        store.records
            .where(
              (record) =>
                  record.localDate == '2026-04-21' &&
                  record.type == HabitRecordType.skip,
            )
            .single
            .note,
        'Intentional rest.',
      );
    },
  );

  test('today completion is computed from today records only', () async {
    final habit = _habit(targetCountPerDay: 1);
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(
        habits: [habit],
        records: [
          _record(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-04-22',
          ),
        ],
      ),
    );

    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    expect(store.todayCheckInCount(habit), 0);
    expect(store.isCompletedToday(habit), isFalse);

    await store.checkIn(habit.id);

    expect(store.todayCheckInCount(habit), 1);
    expect(store.isCompletedToday(habit), isTrue);
  });

  test('recent 7-day activity reflects stored records', () async {
    final habit = _habit();
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(
        habits: [habit],
        records: [
          _record(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-04-17',
          ),
          _record(
            id: 'habit-record-2',
            habitId: habit.id,
            localDate: '2026-04-21',
          ),
          _record(
            id: 'habit-record-3',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
          _record(
            id: 'habit-record-4',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
        ],
      ),
    );

    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final activity = store.recentActivityDays(habit);

    expect(activity.map((day) => day.localDate), [
      '2026-04-17',
      '2026-04-18',
      '2026-04-19',
      '2026-04-20',
      '2026-04-21',
      '2026-04-22',
      '2026-04-23',
    ]);
    expect(activity.map((day) => day.count), [1, 0, 0, 0, 1, 0, 2]);
  });

  test('current month activity reflects current-month records only', () async {
    final habit = _habit();
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(
        habits: [habit],
        records: [
          _record(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-03-31',
          ),
          _record(
            id: 'habit-record-2',
            habitId: habit.id,
            localDate: '2026-04-01',
          ),
          _record(
            id: 'habit-record-3',
            habitId: habit.id,
            localDate: '2026-04-02',
          ),
          _record(
            id: 'habit-record-4',
            habitId: habit.id,
            localDate: '2026-04-02',
          ),
          _record(
            id: 'habit-record-5',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
          _record(
            id: 'habit-record-6',
            habitId: habit.id,
            localDate: '2026-05-01',
          ),
        ],
      ),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    final monthActivity = store.currentMonthActivity(habit);

    expect(monthActivity.year, 2026);
    expect(monthActivity.month, 4);
    expect(monthActivity.days.length, 30);
    expect(monthActivity.days[0].count, 1);
    expect(monthActivity.days[1].count, 2);
    expect(monthActivity.days[22].count, 1);
    expect(
      monthActivity.days
          .where((day) => day.count > 0)
          .map((day) => day.localDate),
      ['2026-04-01', '2026-04-02', '2026-04-23'],
    );
  });

  test(
    'records without type load as check-in and malformed types are skipped',
    () async {
      final habitJson = _habit().toJson();
      final keyValueStore = _FakeKeyValueStore(
        values: {
          HabitsLocalStorage.storageKey: jsonEncode([habitJson]),
          HabitsLocalStorage.recordsStorageKey: jsonEncode([
            {
              'id': 'habit-record-1',
              'habitId': 'habit-1',
              'localDate': '2026-04-23',
              'note': '  old note  ',
              'createdAt': '2026-04-23T08:00:00Z',
            },
            {
              'id': 'habit-record-2',
              'habitId': 'habit-1',
              'localDate': '2026-04-23',
              'type': 'unsupported',
              'createdAt': '2026-04-23T09:00:00Z',
            },
          ]),
        },
      );
      final storage = HabitsLocalStorage(store: keyValueStore);

      final snapshot = await storage.loadSnapshot(
        migrationDateKey: '2026-04-23',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.records.length, 1);
      expect(snapshot.records.single.type, HabitRecordType.checkIn);
      expect(snapshot.records.single.note, 'old note');
      expect(snapshot.shouldPersistAfterLoad, isTrue);
    },
  );

  test('old and malformed habit color data load safely', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-old',
            'name': 'Old habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'createdAt': '2026-04-23T08:00:00.000',
          },
          {
            'id': 'habit-bad',
            'name': 'Bad color',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': 'not-a-color',
            'createdAt': '2026-04-23T08:00:00.000',
          },
          {
            'id': 'habit-color',
            'name': 'Saved color',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': 4285503874,
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits[0].habitColorValue, isNull);
    expect(snapshot.habits[1].habitColorValue, isNull);
    expect(snapshot.habits[2].habitColorValue, 4285503874);
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test('old and malformed lifecycle data load safely as active', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-old',
            'name': 'Old habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': null,
            'createdAt': '2026-04-23T08:00:00.000',
          },
          {
            'id': 'habit-bad',
            'name': 'Bad lifecycle',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': null,
            'status': 'sleeping',
            'pausedAt': 'not-a-date',
            'archivedAt': null,
            'deletedAt': null,
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits.map((habit) => habit.status), [
      HabitLifecycleStatus.active,
      HabitLifecycleStatus.active,
    ]);
    expect(snapshot.habits[1].pausedAt, isNull);
    expect(snapshot.habits[0].pauseIntervals, isEmpty);
    expect(snapshot.habits[1].pauseIntervals, isEmpty);
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test(
    'currently paused old habits synthesize an open pause interval',
    () async {
      final keyValueStore = _FakeKeyValueStore(
        values: {
          HabitsLocalStorage.storageKey: jsonEncode([
            {
              'id': 'habit-paused',
              'name': 'Paused habit',
              'emoji': HabitItem.defaultEmoji,
              'description': '',
              'targetCountPerDay': 1,
              'reminderTime': null,
              'habitColorValue': null,
              'status': 'paused',
              'pausedAt': '2026-04-22T08:00:00.000',
              'archivedAt': null,
              'deletedAt': null,
              'createdAt': '2026-04-20T08:00:00.000',
            },
          ]),
        },
      );
      final storage = HabitsLocalStorage(store: keyValueStore);

      final snapshot = await storage.loadSnapshot(
        migrationDateKey: '2026-04-23',
      );

      expect(snapshot, isNotNull);
      final habit = snapshot!.habits.single;
      expect(habit.status, HabitLifecycleStatus.paused);
      expect(habit.pauseIntervals, hasLength(1));
      expect(habit.pauseIntervals.single.isOpen, isTrue);
      expect(habit.pauseIntervals.single.startLocalDate, '2026-04-22');
      expect(habit.pauseIntervals.single.endLocalDate, isNull);
      expect(snapshot.shouldPersistAfterLoad, isTrue);
    },
  );

  test('malformed pause interval entries are skipped safely', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-1',
            'name': 'Saved habit',
            'emoji': HabitItem.defaultEmoji,
            'description': '',
            'targetCountPerDay': 1,
            'reminderTime': null,
            'habitColorValue': null,
            'status': 'active',
            'pausedAt': null,
            'archivedAt': null,
            'deletedAt': null,
            'pauseIntervals': [
              {
                'id': 'pause-valid',
                'startedAt': '2026-04-20T08:00:00.000Z',
                'startLocalDate': '2026-04-20',
                'endedAt': '2026-04-21T08:00:00.000Z',
                'endLocalDate': '2026-04-21',
              },
              {
                'id': 'pause-bad-date',
                'startedAt': '2026-04-20T08:00:00.000Z',
                'startLocalDate': 'not-a-date',
              },
              'not an interval',
            ],
            'createdAt': '2026-04-20T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits.single.pauseIntervals, hasLength(1));
    expect(snapshot.habits.single.pauseIntervals.single.id, 'pause-valid');
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test(
    'pause archive restore and soft delete preserve records and attachments',
    () async {
      final habit = _habit(reminderTime: '08:30');
      final record = _record(
        id: 'habit-record-1',
        habitId: habit.id,
        localDate: '2026-04-23',
      );
      final attachment = HabitRecordAttachment(
        id: 'habit-attachment-1',
        recordId: record.id,
        habitId: habit.id,
        relativePath: 'habit_record_images/proof.png',
        fileName: 'proof.png',
        createdAt: DateTime.utc(2026, 4, 23, 9),
      );
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(
          habits: [habit],
          records: [record],
          attachments: [attachment],
        ),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime.utc(2026, 4, 23, 10),
      );

      final paused = await store.pauseHabit(habit.id);

      expect(paused, isTrue);
      expect(store.habits, isEmpty);
      expect(store.pausedHabits.single.status, HabitLifecycleStatus.paused);
      expect(store.pausedHabits.single.pausedAt, isNotNull);
      expect(store.pausedHabits.single.pauseIntervals, hasLength(1));
      expect(store.pausedHabits.single.pauseIntervals.single.isOpen, isTrue);
      expect(
        store.pausedHabits.single.pauseIntervals.single.startLocalDate,
        '2026-04-23',
      );
      expect(store.records.single.id, record.id);
      expect(store.attachments.single.id, attachment.id);
      await store.checkIn(habit.id);
      expect(store.records, hasLength(1));

      final restored = await store.restoreHabit(habit.id);

      expect(restored, isTrue);
      expect(store.habits.single.status, HabitLifecycleStatus.active);
      expect(store.habits.single.pausedAt, isNull);
      expect(store.habits.single.pauseIntervals.single.isOpen, isFalse);
      expect(
        store.habits.single.pauseIntervals.single.endLocalDate,
        '2026-04-23',
      );

      final archived = await store.archiveHabit(habit.id);

      expect(archived, isTrue);
      expect(store.habits, isEmpty);
      expect(store.archivedHabits.single.status, HabitLifecycleStatus.archived);
      expect(store.archivedHabits.single.archivedAt, isNotNull);
      expect(store.records.single.id, record.id);
      expect(store.attachments.single.id, attachment.id);

      final rejectedDelete = await store.softDeleteHabit(
        habit.id,
        confirmed: false,
      );
      expect(rejectedDelete, isFalse);
      expect(store.archivedHabits, hasLength(1));

      final deleted = await store.softDeleteHabit(habit.id, confirmed: true);

      expect(deleted, isTrue);
      expect(store.habits, isEmpty);
      expect(store.pausedHabits, isEmpty);
      expect(store.archivedHabits, isEmpty);
      expect(store.deletedHabits.single.status, HabitLifecycleStatus.deleted);
      expect(store.deletedHabits.single.deletedAt, isNotNull);
      expect(store.records.single.id, record.id);
      expect(store.attachments.single.id, attachment.id);
      expect(
        store
            .statisticsForHabit(store.deletedHabits.single)
            .effectiveCheckInCount,
        1,
      );
      expect(
        storage.lastSavedSnapshot!.habits.single.status.storageValue,
        'deleted',
      );
    },
  );

  test('archive and soft delete close open pause intervals', () async {
    final archiveHabit = _habit(id: 'habit-archive');
    final deleteHabit = _habit(id: 'habit-delete');
    final storage = _FakeHabitsStorage(
      storedSnapshot: HabitsSnapshot(
        habits: [archiveHabit, deleteHabit],
        records: const [],
      ),
    );
    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime.utc(2026, 4, 23, 10),
    );

    await store.pauseHabit(archiveHabit.id);
    await store.pauseHabit(deleteHabit.id);

    expect(
      store.pausedHabits.every((habit) => habit.pauseIntervals.single.isOpen),
      isTrue,
    );

    final archived = await store.archiveHabit(archiveHabit.id);
    final deleted = await store.softDeleteHabit(
      deleteHabit.id,
      confirmed: true,
    );

    expect(archived, isTrue);
    expect(deleted, isTrue);
    expect(store.archivedHabits.single.pauseIntervals.single.isOpen, isFalse);
    expect(store.deletedHabits.single.pauseIntervals.single.isOpen, isFalse);
    expect(
      store.archivedHabits.single.pauseIntervals.single.endLocalDate,
      '2026-04-23',
    );
    expect(
      store.deletedHabits.single.pauseIntervals.single.endLocalDate,
      '2026-04-23',
    );
  });

  test(
    'old habit records without attachments load with empty attachments',
    () async {
      final habitJson = _habit().toJson();
      final keyValueStore = _FakeKeyValueStore(
        values: {
          HabitsLocalStorage.storageKey: jsonEncode([habitJson]),
          HabitsLocalStorage.recordsStorageKey: jsonEncode([
            _record(
              id: 'habit-record-1',
              habitId: 'habit-1',
              localDate: '2026-04-23',
            ).toJson(),
          ]),
        },
      );
      final storage = HabitsLocalStorage(store: keyValueStore);

      final snapshot = await storage.loadSnapshot(
        migrationDateKey: '2026-04-23',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.records, hasLength(1));
      expect(snapshot.attachments, isEmpty);
    },
  );

  test('malformed attachment entries are skipped safely', () async {
    final habitJson = _habit().toJson();
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([habitJson]),
        HabitsLocalStorage.recordsStorageKey: jsonEncode([
          _record(
            id: 'habit-record-1',
            habitId: 'habit-1',
            localDate: '2026-04-23',
          ).toJson(),
        ]),
        HabitsLocalStorage.attachmentsStorageKey: jsonEncode([
          {
            'id': 'habit-attachment-1',
            'recordId': 'habit-record-1',
            'habitId': 'habit-1',
            'relativePath': 'habit_record_images/proof.png',
            'fileName': 'proof.png',
            'mimeType': 'image/png',
            'createdAt': '2026-04-23T08:30:00.000Z',
          },
          {
            'id': 'habit-attachment-bad',
            'recordId': 'habit-record-1',
            'habitId': 'habit-1',
            'relativePath': 'habit_record_images/bad.png',
            'createdAt': '2026-04-23T08:30:00.000Z',
          },
          'not an attachment',
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.attachments.length, 1);
    expect(snapshot.attachments.single.id, 'habit-attachment-1');
    expect(snapshot.shouldPersistAfterLoad, isTrue);
  });

  test(
    'multi-image attachment metadata add replace and remove preserves records',
    () async {
      final habit = _habit();
      final record = _record(
        id: 'habit-record-1',
        habitId: habit.id,
        localDate: '2026-04-23',
        note: 'Proof note',
      );
      final storage = _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(habits: [habit], records: [record]),
      );
      final store = await HabitsStore.load(
        storage,
        nowProvider: () => DateTime.utc(2026, 4, 23, 9),
      );

      final first = await store.addRecordAttachment(
        recordId: 'habit-record-1',
        relativePath: 'habit_record_images/proof-a.png',
        fileName: 'proof-a.png',
        mimeType: 'image/png',
      );
      final second = await store.addRecordAttachment(
        recordId: 'habit-record-1',
        relativePath: 'habit_record_images/proof-b.jpg',
        fileName: 'proof-b.jpg',
        mimeType: 'image/jpeg',
      );
      final third = await store.addRecordAttachment(
        recordId: 'habit-record-1',
        relativePath: 'habit_record_images/proof-c.webp',
        fileName: 'proof-c.webp',
        mimeType: 'image/webp',
      );
      final fourth = await store.addRecordAttachment(
        recordId: 'habit-record-1',
        relativePath: 'habit_record_images/proof-d.png',
        fileName: 'proof-d.png',
        mimeType: 'image/png',
      );

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(third, isNotNull);
      expect(fourth, isNull);
      expect(store.attachmentsForRecord('habit-record-1'), hasLength(3));
      expect(
        store.attachments.map((attachment) => attachment.recordId).toSet(),
        {'habit-record-1'},
      );
      expect(
        store.attachments.map((attachment) => attachment.habitId).toSet(),
        {habit.id},
      );

      var savedJson = jsonEncode(
        storage.lastSavedSnapshot!.attachments
            .map((attachment) => attachment.toJson())
            .toList(growable: false),
      );
      expect(savedJson, isNot(contains('data:image')));
      expect(savedJson, isNot(contains('base64')));

      final replaced = await store.replaceRecordAttachmentById(
        attachmentId: second!.id,
        relativePath: 'habit_record_images/proof-b-2.jpg',
        fileName: 'proof-b-2.jpg',
        mimeType: 'image/jpeg',
      );

      expect(replaced?.relativePath, 'habit_record_images/proof-b.jpg');
      expect(store.attachmentsForRecord('habit-record-1'), hasLength(3));
      expect(
        store.attachments.map((attachment) => attachment.relativePath),
        containsAll([
          'habit_record_images/proof-a.png',
          'habit_record_images/proof-b-2.jpg',
          'habit_record_images/proof-c.webp',
        ]),
      );

      final removed = await store.removeRecordAttachmentById(first!.id);

      expect(removed?.relativePath, 'habit_record_images/proof-a.png');
      expect(store.attachmentsForRecord('habit-record-1'), hasLength(2));
      expect(
        store.attachments.map((attachment) => attachment.relativePath).toSet(),
        {
          'habit_record_images/proof-b-2.jpg',
          'habit_record_images/proof-c.webp',
        },
      );
      expect(store.records.single.note, 'Proof note');
      expect(store.todayCheckInCount(habit), 1);

      savedJson = jsonEncode(
        storage.lastSavedSnapshot!.attachments
            .map((attachment) => attachment.toJson())
            .toList(growable: false),
      );
      expect(savedJson, contains('proof-b-2.jpg'));
      expect(savedJson, contains('proof-c.webp'));
      expect(savedJson, isNot(contains('proof-a.png')));
      expect(storage.lastSavedSnapshot!.records.single.note, 'Proof note');
    },
  );

  test(
    'orphan attachments are ignored and proof does not affect counts',
    () async {
      final habit = _habit(targetCountPerDay: 2);
      final records = [
        _record(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-23',
        ),
        _record(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-23',
          type: HabitRecordType.skip,
        ),
        _record(
          id: 'habit-record-3',
          habitId: habit.id,
          localDate: '2026-04-22',
          type: HabitRecordType.makeup,
        ),
      ];
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 23, 9),
        initialHabits: [habit],
        initialRecords: records,
        initialAttachments: [
          HabitRecordAttachment(
            id: 'habit-attachment-1',
            recordId: 'habit-record-1',
            habitId: habit.id,
            relativePath: 'habit_record_images/proof.png',
            fileName: 'proof.png',
            createdAt: DateTime.utc(2026, 4, 23, 9),
          ),
          HabitRecordAttachment(
            id: 'habit-attachment-orphan',
            recordId: 'habit-record-missing',
            habitId: habit.id,
            relativePath: 'habit_record_images/orphan.png',
            fileName: 'orphan.png',
            createdAt: DateTime.utc(2026, 4, 23, 9),
          ),
        ],
      );

      expect(store.attachmentForRecord('habit-record-1'), isNotNull);
      expect(store.attachmentForRecord('habit-record-missing'), isNull);
      expect(store.todayCheckInCount(habit), 1);
      expect(store.totalCheckInsToday, 1);
      expect(store.activityCountOn(habit, '2026-04-22'), 1);
      expect(store.currentMonthActivity(habit).days[21].count, 1);
      expect(store.currentMonthActivity(habit).days[22].count, 1);
    },
  );

  test('legacy completed date migrates into one check-in record', () async {
    final keyValueStore = _FakeKeyValueStore(
      values: {
        HabitsLocalStorage.storageKey: jsonEncode([
          {
            'id': 'habit-8',
            'name': 'Saved habit',
            'completedOnDate': '2026-04-23',
            'createdAt': '2026-04-23T08:00:00.000',
          },
        ]),
      },
    );
    final storage = HabitsLocalStorage(store: keyValueStore);

    final loadedSnapshot = await storage.loadSnapshot(
      migrationDateKey: '2026-04-24',
    );

    expect(loadedSnapshot, isNotNull);
    expect(loadedSnapshot!.habits.single.name, 'Saved habit');
    expect(loadedSnapshot.habits.single.emoji, HabitItem.defaultEmoji);
    expect(loadedSnapshot.habits.single.targetCountPerDay, 1);
    expect(loadedSnapshot.records.single.localDate, '2026-04-23');
    expect(loadedSnapshot.records.single.type, HabitRecordType.checkIn);
    expect(loadedSnapshot.shouldPersistAfterLoad, isTrue);

    await storage.saveSnapshot(loadedSnapshot);

    final rewrittenHabits =
        keyValueStore.values[HabitsLocalStorage.storageKey]!;
    final rewrittenRecords =
        keyValueStore.values[HabitsLocalStorage.recordsStorageKey]!;
    expect(rewrittenHabits, isNot(contains('completedOnDate')));
    expect(rewrittenHabits, isNot(contains('completedToday')));
    expect(rewrittenRecords, contains('"type":"checkIn"'));
  });

  test('malformed local data fails safe to empty snapshot', () async {
    final storage = HabitsLocalStorage(
      store: _FakeKeyValueStore(
        values: {HabitsLocalStorage.storageKey: '{not-json'},
      ),
    );

    final snapshot = await storage.loadSnapshot(migrationDateKey: '2026-04-23');

    expect(snapshot, isNotNull);
    expect(snapshot!.habits, isEmpty);
    expect(snapshot.records, isEmpty);
  });

  test('seeds once and saves once when no saved data exists', () async {
    final storage = _FakeHabitsStorage();

    final store = await HabitsStore.load(
      storage,
      nowProvider: () => DateTime(2026, 4, 23, 9),
    );

    expect(store.totalCount, 3);
    expect(storage.saveCalls, 1);
    expect(storage.lastSavedSnapshot, isNotNull);
    expect(storage.lastSavedSnapshot!.habits.length, 3);
    expect(storage.lastSavedSnapshot!.records, isEmpty);
  });
}

HabitItem _habit({
  String id = 'habit-1',
  String name = 'Saved habit',
  int targetCountPerDay = 1,
  int? habitColorValue,
  String? reminderTime,
  HabitLifecycleStatus status = HabitLifecycleStatus.active,
  DateTime? pausedAt,
  List<HabitPauseInterval> pauseIntervals = const <HabitPauseInterval>[],
}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: targetCountPerDay,
    reminderTime: reminderTime,
    habitColorValue: habitColorValue,
    status: status,
    pausedAt: pausedAt,
    pauseIntervals: pauseIntervals,
    createdAt: DateTime.parse('2026-04-23T08:00:00.000'),
  );
}

HabitRecord _record({
  required String id,
  required String habitId,
  required String localDate,
  HabitRecordType type = HabitRecordType.checkIn,
  String? note,
}) {
  return HabitRecord(
    id: id,
    habitId: habitId,
    localDate: localDate,
    type: type,
    note: note,
    createdAt: DateTime.parse('${localDate}T08:00:00Z'),
  );
}

class _FakeHabitsStorage implements HabitsStorage {
  _FakeHabitsStorage({HabitsSnapshot? storedSnapshot})
    : _storedSnapshot = storedSnapshot;

  HabitsSnapshot? _storedSnapshot;
  int saveCalls = 0;

  HabitsSnapshot? get lastSavedSnapshot => _storedSnapshot == null
      ? null
      : HabitsSnapshot(
          habits: _storedSnapshot!.habits
              .map((habit) => habit.copyWith())
              .toList(growable: false),
          records: _storedSnapshot!.records
              .map((record) => record.copyWith())
              .toList(growable: false),
          attachments: _storedSnapshot!.attachments
              .map((attachment) => attachment.copyWith())
              .toList(growable: false),
        );

  @override
  Future<HabitsSnapshot?> loadSnapshot({
    required String migrationDateKey,
  }) async {
    return lastSavedSnapshot;
  }

  @override
  Future<void> saveSnapshot(HabitsSnapshot snapshot) async {
    saveCalls += 1;
    _storedSnapshot = HabitsSnapshot(
      habits: snapshot.habits
          .map((habit) => habit.copyWith())
          .toList(growable: false),
      records: snapshot.records
          .map((record) => record.copyWith())
          .toList(growable: false),
      attachments: snapshot.attachments
          .map((attachment) => attachment.copyWith())
          .toList(growable: false),
    );
  }
}

class _FakeKeyValueStore implements HabitsKeyValueStore {
  _FakeKeyValueStore({Map<String, String>? values})
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
