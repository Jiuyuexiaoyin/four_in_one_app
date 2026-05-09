import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';

void main() {
  test('per-habit statistics derive from real records only', () {
    final habit = _habit(targetCountPerDay: 2);
    final otherHabit = _habit(id: 'habit-other');
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit, otherHabit],
      initialRecords: [
        _record(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-01',
        ),
        _record(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-01',
          type: HabitRecordType.makeup,
        ),
        _record(
          id: 'habit-record-3',
          habitId: habit.id,
          localDate: '2026-04-02',
          type: HabitRecordType.skip,
        ),
        _record(
          id: 'habit-record-4',
          habitId: habit.id,
          localDate: '2026-03-31',
        ),
        _record(
          id: 'habit-record-invalid-date',
          habitId: habit.id,
          localDate: 'not-a-date',
        ),
        _record(
          id: 'habit-record-other',
          habitId: otherHabit.id,
          localDate: '2026-04-01',
        ),
      ],
      initialAttachments: [
        _attachment(
          id: 'habit-attachment-1',
          recordId: 'habit-record-1',
          habitId: habit.id,
        ),
        _attachment(
          id: 'habit-attachment-duplicate',
          recordId: 'habit-record-1',
          habitId: habit.id,
        ),
        _attachment(
          id: 'habit-attachment-orphan',
          recordId: 'habit-record-missing',
          habitId: habit.id,
        ),
        _attachment(
          id: 'habit-attachment-other',
          recordId: 'habit-record-other',
          habitId: otherHabit.id,
        ),
      ],
    );
    addTearDown(store.dispose);

    final summary = store.statisticsForHabit(habit);

    expect(summary.checkInCount, 2);
    expect(summary.makeupCount, 1);
    expect(summary.skipCount, 1);
    expect(summary.effectiveCheckInCount, 3);
    expect(summary.proofCount, 2);
    expect(summary.proofRecordCount, 1);
    expect(summary.activeDays, 2);
    expect(summary.completedDays, 1);
    expect(summary.currentStreakDays, 0);
    expect(summary.longestStreakDays, 1);
    expect(summary.trackedDays, 3);
    expect(summary.skipDays, 1);
    expect(summary.proofDays, 1);
    expect(summary.completionRate, closeTo(1 / 3, 0.0001));
    expect(summary.currentMonthEffectiveCheckInCount, 2);
    expect(summary.currentMonthActiveDays, 1);
  });

  test('completion rate is neutral when there are no tracked days', () {
    final habit = _habit();
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: const [],
    );
    addTearDown(store.dispose);

    final summary = store.statisticsForHabit(habit);

    expect(summary.trackedDays, 0);
    expect(summary.completedDays, 0);
    expect(summary.currentStreakDays, 0);
    expect(summary.longestStreakDays, 0);
    expect(summary.completionRate, isNull);
  });

  test('proof, note, and skip do not affect habit completion counts', () {
    final habit = _habit(targetCountPerDay: 2);
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: [
        _record(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-23',
          note: 'Proof note.',
        ),
        _record(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-23',
          type: HabitRecordType.skip,
          note: 'Rest day.',
        ),
      ],
      initialAttachments: [
        _attachment(
          id: 'habit-attachment-1',
          recordId: 'habit-record-1',
          habitId: habit.id,
        ),
      ],
    );
    addTearDown(store.dispose);

    final summary = store.statisticsForHabit(habit);

    expect(store.todayCheckInCount(habit), 1);
    expect(store.isCompletedToday(habit), isFalse);
    expect(summary.effectiveCheckInCount, 1);
    expect(summary.skipCount, 1);
    expect(summary.proofCount, 1);
    expect(summary.proofRecordCount, 1);
    expect(summary.completedDays, 0);
    expect(summary.currentStreakDays, 0);
    expect(summary.longestStreakDays, 0);
  });

  test(
    'annual activity and streak metrics use effective localDate records',
    () {
      final habit = _habit(targetCountPerDay: 2);
      final otherHabit = _habit(id: 'habit-other');
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 30, 9),
        initialHabits: [habit, otherHabit],
        initialRecords: [
          ..._completedDayRecordPair(habit.id, '2026-01-10', 'jan-10'),
          ..._completedDayRecordPair(habit.id, '2026-01-11', 'jan-11'),
          ..._completedDayRecordPair(habit.id, '2026-01-12', 'jan-12'),
          ..._completedDayRecordPair(habit.id, '2026-01-13', 'jan-13'),
          ..._completedDayRecordPair(habit.id, '2026-01-15', 'jan-15'),
          _record(
            id: 'habit-record-skip',
            habitId: habit.id,
            localDate: '2026-04-02',
            type: HabitRecordType.skip,
          ),
          _record(
            id: 'habit-record-note',
            habitId: habit.id,
            localDate: '2026-04-03',
            note: 'Proof note.',
          ),
          ..._completedDayRecordPair(habit.id, '2026-04-27', 'apr-27'),
          ..._completedDayRecordPair(habit.id, '2026-04-28', 'apr-28'),
          ..._completedDayRecordPair(habit.id, '2026-04-29', 'apr-29'),
          _record(
            id: 'habit-record-today-incomplete',
            habitId: habit.id,
            localDate: '2026-04-30',
          ),
          ..._completedDayRecordPair(habit.id, '2025-12-31', 'previous-year'),
          _record(
            id: 'habit-record-other',
            habitId: otherHabit.id,
            localDate: '2026-04-29',
          ),
        ],
        initialAttachments: [
          _attachment(
            id: 'habit-attachment-proof',
            recordId: 'habit-record-note',
            habitId: habit.id,
          ),
        ],
      );
      addTearDown(store.dispose);

      final summary = store.statisticsForHabit(habit);

      expect(summary.currentStreakDays, 3);
      expect(summary.longestStreakDays, 4);

      final annualActivity = store.currentYearActivity(habit);

      expect(annualActivity.year, 2026);
      expect(annualActivity.days, hasLength(365));
      expect(annualActivity.days.first.localDate, '2026-01-01');
      expect(annualActivity.days.last.localDate, '2026-12-31');
      expect(_annualCountOn(annualActivity, '2026-01-10'), 2);
      expect(_annualCountOn(annualActivity, '2026-01-14'), 0);
      expect(_annualCountOn(annualActivity, '2026-04-02'), 0);
      expect(_annualCountOn(annualActivity, '2026-04-03'), 1);
      expect(_annualCountOn(annualActivity, '2026-04-29'), 2);
      expect(_annualCountOn(annualActivity, '2026-04-30'), 1);
    },
  );

  test('pause intervals bridge streak gaps without adding completed days', () {
    final habit = _habit(
      createdAt: DateTime(2026, 4, 20, 8),
      pauseIntervals: [
        _pauseInterval(
          id: 'pause-1',
          startLocalDate: '2026-04-22',
          endLocalDate: '2026-04-24',
        ),
        _pauseInterval(
          id: 'pause-2',
          startLocalDate: '2026-04-26',
          endLocalDate: '2026-04-26',
        ),
      ],
    );
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 27, 9),
      initialHabits: [habit],
      initialRecords: [
        _record(
          id: 'habit-record-20',
          habitId: habit.id,
          localDate: '2026-04-20',
        ),
        _record(
          id: 'habit-record-21',
          habitId: habit.id,
          localDate: '2026-04-21',
        ),
        _record(
          id: 'habit-record-25',
          habitId: habit.id,
          localDate: '2026-04-25',
        ),
        _record(
          id: 'habit-record-27',
          habitId: habit.id,
          localDate: '2026-04-27',
        ),
      ],
    );
    addTearDown(store.dispose);

    final summary = store.statisticsForHabit(habit);

    expect(summary.completedDays, 4);
    expect(summary.pauseProtectedDays, 4);
    expect(summary.currentStreakDays, 4);
    expect(summary.longestStreakDays, 4);
    expect(store.currentMonthActivity(habit).days[21].count, 0);
    expect(store.currentMonthActivity(habit).days[25].count, 0);
  });

  test('open current pause protects through today', () {
    final habit = _habit(
      createdAt: DateTime(2026, 4, 20, 8),
      status: HabitLifecycleStatus.paused,
      pauseIntervals: [
        _pauseInterval(id: 'pause-open', startLocalDate: '2026-04-22'),
      ],
    );
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: [
        _record(
          id: 'habit-record-20',
          habitId: habit.id,
          localDate: '2026-04-20',
        ),
        _record(
          id: 'habit-record-21',
          habitId: habit.id,
          localDate: '2026-04-21',
        ),
      ],
    );
    addTearDown(store.dispose);

    final summary = store.statisticsForHabit(habit);

    expect(summary.pauseProtectedDays, 2);
    expect(summary.currentStreakDays, 2);
    expect(summary.longestStreakDays, 2);
  });

  test('skip breaks streak outside pause but is neutral inside pause', () {
    final baseHabit = _habit(createdAt: DateTime(2026, 4, 20, 8));
    final protectedHabit = _habit(
      id: 'habit-protected',
      createdAt: DateTime(2026, 4, 20, 8),
      pauseIntervals: [
        _pauseInterval(
          id: 'pause-skip',
          startLocalDate: '2026-04-22',
          endLocalDate: '2026-04-22',
        ),
      ],
    );
    final records = [
      _record(
        id: 'habit-record-20',
        habitId: baseHabit.id,
        localDate: '2026-04-20',
      ),
      _record(
        id: 'habit-record-21',
        habitId: baseHabit.id,
        localDate: '2026-04-21',
      ),
      _record(
        id: 'habit-record-skip',
        habitId: baseHabit.id,
        localDate: '2026-04-22',
        type: HabitRecordType.skip,
      ),
      _record(
        id: 'habit-record-23',
        habitId: baseHabit.id,
        localDate: '2026-04-23',
      ),
      _record(
        id: 'habit-record-protected-20',
        habitId: protectedHabit.id,
        localDate: '2026-04-20',
      ),
      _record(
        id: 'habit-record-protected-21',
        habitId: protectedHabit.id,
        localDate: '2026-04-21',
      ),
      _record(
        id: 'habit-record-protected-skip',
        habitId: protectedHabit.id,
        localDate: '2026-04-22',
        type: HabitRecordType.skip,
      ),
      _record(
        id: 'habit-record-protected-23',
        habitId: protectedHabit.id,
        localDate: '2026-04-23',
      ),
    ];
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [baseHabit, protectedHabit],
      initialRecords: records,
    );
    addTearDown(store.dispose);

    final baseSummary = store.statisticsForHabit(baseHabit);
    final protectedSummary = store.statisticsForHabit(protectedHabit);

    expect(baseSummary.currentStreakDays, 1);
    expect(baseSummary.longestStreakDays, 2);
    expect(protectedSummary.currentStreakDays, 3);
    expect(protectedSummary.longestStreakDays, 3);
    expect(protectedSummary.skipCount, 1);
  });

  test(
    'target count and makeup still control pause-aware streak completion',
    () {
      final habit = _habit(
        targetCountPerDay: 2,
        createdAt: DateTime(2026, 4, 20, 8),
        pauseIntervals: [
          _pauseInterval(
            id: 'pause-1',
            startLocalDate: '2026-04-22',
            endLocalDate: '2026-04-22',
          ),
        ],
      );
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 24, 9),
        initialHabits: [habit],
        initialRecords: [
          ..._completedDayRecordPair(habit.id, '2026-04-20', 'apr-20'),
          _record(
            id: 'habit-record-21-incomplete',
            habitId: habit.id,
            localDate: '2026-04-21',
          ),
          _record(
            id: 'habit-record-23-check',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
          _record(
            id: 'habit-record-23-makeup',
            habitId: habit.id,
            localDate: '2026-04-23',
            type: HabitRecordType.makeup,
          ),
          ..._completedDayRecordPair(habit.id, '2026-04-24', 'apr-24'),
        ],
      );
      addTearDown(store.dispose);

      final summary = store.statisticsForHabit(habit);

      expect(summary.completedDays, 3);
      expect(summary.currentStreakDays, 2);
      expect(summary.longestStreakDays, 2);
    },
  );

  test(
    'recent activity months bucket effective records by selected localDate',
    () {
      final habit = _habit(targetCountPerDay: 2);
      final otherHabit = _habit(id: 'habit-other');
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 23, 9),
        initialHabits: [habit, otherHabit],
        initialRecords: [
          _record(
            id: 'habit-record-feb',
            habitId: habit.id,
            localDate: '2026-02-28',
          ),
          _record(
            id: 'habit-record-mar',
            habitId: habit.id,
            localDate: '2026-03-31',
            type: HabitRecordType.makeup,
            note: 'Made up for March.',
          ),
          _record(
            id: 'habit-record-apr-check',
            habitId: habit.id,
            localDate: '2026-04-01',
            note: 'Proof note.',
          ),
          _record(
            id: 'habit-record-apr-makeup',
            habitId: habit.id,
            localDate: '2026-04-01',
            type: HabitRecordType.makeup,
          ),
          _record(
            id: 'habit-record-apr-skip',
            habitId: habit.id,
            localDate: '2026-04-02',
            type: HabitRecordType.skip,
          ),
          _record(
            id: 'habit-record-jan',
            habitId: habit.id,
            localDate: '2026-01-15',
          ),
          _record(
            id: 'habit-record-other',
            habitId: otherHabit.id,
            localDate: '2026-04-01',
          ),
        ],
        initialAttachments: [
          _attachment(
            id: 'habit-attachment-proof',
            recordId: 'habit-record-apr-check',
            habitId: habit.id,
          ),
        ],
      );
      addTearDown(store.dispose);

      final months = store.recentActivityMonths(habit);

      expect(months.map((month) => '${month.year}-${month.month}'), [
        '2026-2',
        '2026-3',
        '2026-4',
      ]);
      expect(months[0].days[27].count, 1);
      expect(months[1].days[30].count, 1);
      expect(months[2].days[0].count, 2);
      expect(months[2].days[1].count, 0);

      final summary = store.statisticsForHabit(habit);

      expect(summary.effectiveCheckInCount, 5);
      expect(summary.skipCount, 1);
      expect(summary.proofCount, 1);
      expect(summary.proofRecordCount, 1);
      expect(summary.activeDays, 4);
      expect(summary.completedDays, 1);
      expect(summary.currentStreakDays, 0);
      expect(summary.longestStreakDays, 1);
      expect(summary.trackedDays, 5);
      expect(summary.skipDays, 1);
      expect(summary.proofDays, 1);
      expect(summary.currentMonthEffectiveCheckInCount, 2);
      expect(summary.currentMonthActiveDays, 1);

      final groups = store.recordDateGroupsForHabit(habit);

      expect(groups.map((group) => group.localDate), [
        '2026-04-02',
        '2026-04-01',
        '2026-03-31',
        '2026-02-28',
        '2026-01-15',
      ]);
      expect(groups[1].records.map((record) => record.id).toSet(), {
        'habit-record-apr-check',
        'habit-record-apr-makeup',
      });
    },
  );
}

int _annualCountOn(HabitAnnualActivity annualActivity, String localDate) {
  return annualActivity.days
      .singleWhere((day) => day.localDate == localDate)
      .count;
}

HabitItem _habit({
  String id = 'habit-1',
  String name = 'Saved habit',
  int targetCountPerDay = 1,
  HabitLifecycleStatus status = HabitLifecycleStatus.active,
  DateTime? createdAt,
  List<HabitPauseInterval> pauseIntervals = const <HabitPauseInterval>[],
}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: targetCountPerDay,
    reminderTime: null,
    status: status,
    pauseIntervals: pauseIntervals,
    createdAt: createdAt ?? DateTime.parse('2026-01-01T08:00:00.000'),
  );
}

HabitPauseInterval _pauseInterval({
  required String id,
  required String startLocalDate,
  String? endLocalDate,
}) {
  return HabitPauseInterval(
    id: id,
    startedAt: DateTime.parse('${startLocalDate}T08:00:00Z'),
    startLocalDate: startLocalDate,
    endedAt: endLocalDate == null
        ? null
        : DateTime.parse('${endLocalDate}T18:00:00Z'),
    endLocalDate: endLocalDate,
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
    createdAt: DateTime.utc(2026, 4, 23, 8),
  );
}

List<HabitRecord> _completedDayRecordPair(
  String habitId,
  String localDate,
  String key,
) {
  return [
    _record(
      id: 'habit-record-$key-check',
      habitId: habitId,
      localDate: localDate,
    ),
    _record(
      id: 'habit-record-$key-makeup',
      habitId: habitId,
      localDate: localDate,
      type: HabitRecordType.makeup,
    ),
  ];
}

HabitRecordAttachment _attachment({
  required String id,
  required String recordId,
  required String habitId,
}) {
  return HabitRecordAttachment(
    id: id,
    recordId: recordId,
    habitId: habitId,
    relativePath: 'habit_record_images/$id.png',
    fileName: '$id.png',
    mimeType: 'image/png',
    createdAt: DateTime.utc(2026, 4, 23, 9),
  );
}
