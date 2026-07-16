import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habit_reminder_notification_service.dart';
import 'package:four_in_one_app/features/habits/data/habits_local_storage.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';

void main() {
  test('scheduling a reminder calls service with correct habit data', () async {
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: const [],
      reminderNotificationService: reminders,
    );

    await store.createHabit('Journal', emoji: '鉁嶏笍', reminderTime: '08:30');

    expect(reminders.scheduled, hasLength(1));
    expect(reminders.scheduled.single.habit.name, 'Journal');
    expect(reminders.scheduled.single.habit.emoji, '鉁嶏笍');
    expect(reminders.scheduled.single.habit.reminderTime, '08:30');
    expect(reminders.scheduled.single.habit.reminderRules, hasLength(1));
    expect(reminders.scheduled.single.habit.reminderRules.single.weekdays, [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ]);
    expect(reminders.scheduled.single.requestPermission, isTrue);
    expect(
      HabitReminderLocalNotificationService.reminderBodyForHabit(
        reminders.scheduled.single.habit,
      ),
      '今天的「Journal」还未完成',
    );
  });

  test('editing reminderTime updates the scheduled reminder', () async {
    final habit = _habit(reminderTime: '08:30');
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [habit],
      reminderNotificationService: reminders,
    );

    await store.updateHabit(
      habit.id,
      name: habit.name,
      emoji: habit.emoji,
      description: habit.description,
      targetCountPerDay: habit.targetCountPerDay,
      reminderTime: '21:15',
    );

    expect(reminders.scheduled, hasLength(1));
    expect(reminders.scheduled.single.habit.reminderTime, '21:15');
    expect(reminders.scheduled.single.habit.reminderRules.single.time, '21:15');
    expect(reminders.scheduled.single.requestPermission, isTrue);
  });

  test('removing reminderTime cancels the scheduled reminder', () async {
    final habit = _habit(reminderTime: '08:30');
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [habit],
      reminderNotificationService: reminders,
    );

    await store.updateHabit(
      habit.id,
      name: habit.name,
      emoji: habit.emoji,
      description: habit.description,
      targetCountPerDay: habit.targetCountPerDay,
      reminderTime: null,
    );

    expect(reminders.cancelledHabitIds, [habit.id]);
    expect(reminders.scheduled, isEmpty);
  });

  test('editing name and emoji updates future reminder copy', () async {
    final habit = _habit(reminderTime: '08:30');
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [habit],
      reminderNotificationService: reminders,
    );

    await store.updateHabit(
      habit.id,
      name: 'Evening journal',
      emoji: '馃寵',
      description: habit.description,
      targetCountPerDay: habit.targetCountPerDay,
      reminderRules: habit.reminderRules,
    );

    expect(reminders.scheduled.single.habit.name, 'Evening journal');
    expect(reminders.scheduled.single.habit.emoji, '馃寵');
    expect(
      HabitReminderLocalNotificationService.reminderBodyForHabit(
        reminders.scheduled.single.habit,
      ),
      '今天的「Evening journal」还未完成',
    );
  });

  test('multiple reminder rules schedule and persist enabled rules', () async {
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [_habit()],
      reminderNotificationService: reminders,
    );
    final rules = [
      _rule(id: 'rule-morning', time: '08:00'),
      _rule(id: 'rule-evening', time: '21:00', weekdays: const [1, 3, 5]),
      _rule(id: 'rule-disabled', time: '22:00', isEnabled: false),
      _rule(id: 'rule-over-limit', time: '23:00'),
    ];

    final updated = await store.updateHabitReminderRules('habit-1', rules);

    expect(updated, isTrue);
    expect(store.habits.single.reminderRules, hasLength(3));
    expect(store.habits.single.enabledReminderRules, hasLength(2));
    expect(store.habits.single.reminderTime, '08:00');
    expect(reminders.scheduled.single.habit.enabledReminderRules, hasLength(2));
    expect(reminders.scheduled.single.requestPermission, isTrue);
  });

  test('disabled and removed reminder rules do not schedule', () async {
    final habit = _habit(
      reminderRules: [
        _rule(id: 'rule-disabled', time: '08:30', isEnabled: false),
      ],
    );
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [habit],
      reminderNotificationService: reminders,
    );

    final disabledUpdated = await store.updateHabitReminderRules(
      habit.id,
      habit.reminderRules,
    );

    expect(disabledUpdated, isTrue);
    expect(store.habits.single.reminderRules.single.isEnabled, isFalse);
    expect(store.habits.single.reminderTime, isNull);
    expect(reminders.scheduled, isEmpty);
    expect(reminders.cancelledHabitIds, [habit.id]);

    final removed = await store.updateHabitReminderRules(habit.id, const []);

    expect(removed, isTrue);
    expect(store.habits.single.reminderRules, isEmpty);
    expect(store.habits.single.reminderTime, isNull);
    expect(reminders.cancelledHabitIds, [habit.id, habit.id]);
  });

  test('startup resync schedules all valid reminders without prompt', () async {
    final reminders = _FakeHabitReminderNotificationService();
    await HabitsStore.load(
      _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(
          habits: [
            _habit(id: 'habit-1', name: 'Water', reminderTime: '08:30'),
            _habit(id: 'habit-2', name: 'Read', reminderTime: '21:00'),
            _habit(id: 'habit-3', name: 'No reminder'),
            _habit(id: 'habit-custom', name: 'Bad', reminderTime: '25:00'),
          ],
          records: const [],
        ),
      ),
      reminderNotificationService: reminders,
    );

    expect(reminders.startupResyncs, 1);
    expect(reminders.scheduled.map((request) => request.habit.id), [
      'habit-1',
      'habit-2',
    ]);
    expect(
      reminders.scheduled.every((request) => !request.requestPermission),
      isTrue,
    );
    expect(reminders.permissionPromptRequests, 0);
  });

  test('startup resync skips paused archived and deleted reminders', () async {
    final reminders = _FakeHabitReminderNotificationService();
    await HabitsStore.load(
      _FakeHabitsStorage(
        storedSnapshot: HabitsSnapshot(
          habits: [
            _habit(id: 'habit-active', name: 'Active', reminderTime: '08:30'),
            _habit(
              id: 'habit-paused',
              name: 'Paused',
              reminderTime: '09:00',
              status: HabitLifecycleStatus.paused,
            ),
            _habit(
              id: 'habit-archived',
              name: 'Archived',
              reminderTime: '10:00',
              status: HabitLifecycleStatus.archived,
            ),
            _habit(
              id: 'habit-deleted',
              name: 'Deleted',
              reminderTime: '11:00',
              status: HabitLifecycleStatus.deleted,
            ),
          ],
          records: const [],
        ),
      ),
      reminderNotificationService: reminders,
    );

    expect(reminders.startupResyncs, 1);
    expect(reminders.scheduled.map((request) => request.habit.id), [
      'habit-active',
    ]);
    expect(reminders.cancelledHabitIds, [
      'habit-active',
      'habit-paused',
      'habit-archived',
      'habit-deleted',
    ]);
  });

  test('pause archive and soft delete cancel deterministic reminder', () async {
    final habit = _habit(reminderTime: '08:30');
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [habit],
      reminderNotificationService: reminders,
    );

    await store.pauseHabit(habit.id);

    expect(store.pausedHabits.single.id, habit.id);
    expect(reminders.cancelledHabitIds, [habit.id]);

    await store.restoreHabit(habit.id);

    expect(store.habits.single.id, habit.id);
    expect(reminders.scheduled.single.habit.id, habit.id);
    expect(reminders.scheduled.single.requestPermission, isTrue);

    await store.archiveHabit(habit.id);

    expect(store.archivedHabits.single.id, habit.id);
    expect(reminders.cancelledHabitIds, [habit.id, habit.id]);

    await store.softDeleteHabit(habit.id, confirmed: true);

    expect(store.deletedHabits.single.id, habit.id);
    expect(reminders.cancelledHabitIds, [habit.id, habit.id, habit.id]);
  });

  test('reminder IDs stay deterministic and away from Focus IDs', () {
    final firstId = HabitReminderLocalNotificationService.reminderIdForHabitId(
      'habit-1',
    );
    final secondId = HabitReminderLocalNotificationService.reminderIdForHabitId(
      'habit-2',
    );
    final customId = HabitReminderLocalNotificationService.reminderIdForHabitId(
      'custom-habit-id',
    );
    final dailyRuleId =
        HabitReminderLocalNotificationService.reminderRuleIdForHabitSlot(
          habitId: 'habit-1',
          ruleIndex: 0,
          weekday: 0,
        );
    final weeklyRuleId =
        HabitReminderLocalNotificationService.reminderRuleIdForHabitSlot(
          habitId: 'habit-1',
          ruleIndex: 0,
          weekday: 1,
        );

    expect(firstId, isNot(secondId));
    expect(firstId, isNot(customId));
    expect(secondId, isNot(customId));
    expect(dailyRuleId, isNot(weeklyRuleId));
    for (final id in [firstId, secondId, customId, dailyRuleId, weeklyRuleId]) {
      expect(id, greaterThan(4102));
      expect(id, isNot(4101));
      expect(id, isNot(4102));
    }
    expect(
      HabitReminderLocalNotificationService.reminderIdForHabitId(
        'custom-habit-id',
      ),
      customId,
    );
  });

  test('malformed reminderTime fails safe and does not schedule', () async {
    final reminders = _FakeHabitReminderNotificationService();
    final store = HabitsStore.seededInMemory(
      initialHabits: [_habit()],
      reminderNotificationService: reminders,
    );

    await store.updateHabit(
      'habit-1',
      name: 'Saved habit',
      emoji: HabitItem.defaultEmoji,
      description: '',
      targetCountPerDay: 1,
      reminderTime: 'bad-time',
    );

    expect(store.habits.single.reminderTime, isNull);
    expect(store.habits.single.reminderRules, isEmpty);
    expect(reminders.scheduled, isEmpty);
    expect(reminders.cancelledHabitIds, ['habit-1']);
    expect(
      HabitReminderLocalNotificationService.parseReminderTime('bad-time'),
      isNull,
    );
  });

  test('permission denied does not break habit behavior', () async {
    final reminders = _FakeHabitReminderNotificationService(
      permissionGranted: false,
    );
    final store = HabitsStore.seededInMemory(
      initialHabits: const [],
      reminderNotificationService: reminders,
    );

    await store.createHabit('Meditate', emoji: '馃', reminderTime: '07:00');

    expect(store.habits.single.name, 'Meditate');
    expect(store.habits.single.reminderTime, '07:00');
    expect(store.habits.single.reminderRules, hasLength(1));
    expect(reminders.scheduled, isEmpty);
    expect(reminders.permissionPromptRequests, 1);
  });
}

HabitItem _habit({
  String id = 'habit-1',
  String name = 'Saved habit',
  String? reminderTime,
  List<HabitReminderRule>? reminderRules,
  HabitLifecycleStatus status = HabitLifecycleStatus.active,
}) {
  final rules =
      reminderRules ??
      (reminderTime == null
          ? const <HabitReminderRule>[]
          : [_rule(id: 'habit-reminder-$id-legacy', time: reminderTime)]);

  return HabitItem(
    id: id,
    name: name,
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: 1,
    reminderTime: _legacyReminderTimeForRules(rules),
    reminderRules: rules,
    status: status,
    createdAt: DateTime.parse('2026-04-23T08:00:00.000'),
  );
}

HabitReminderRule _rule({
  String id = 'rule-1',
  String time = '08:30',
  List<int> weekdays = HabitReminderRule.allWeekdays,
  bool isEnabled = true,
}) {
  return HabitReminderRule(
    id: id,
    time: time,
    weekdays: weekdays,
    isEnabled: isEnabled,
    createdAt: DateTime.parse('2026-04-23T08:00:00.000Z'),
  );
}

String? _legacyReminderTimeForRules(List<HabitReminderRule> rules) {
  for (final rule in rules) {
    if (rule.isEnabled &&
        HabitReminderLocalNotificationService.parseReminderTime(rule.time) !=
            null) {
      return rule.time;
    }
  }

  return null;
}

class _ReminderRequest {
  const _ReminderRequest({
    required this.habit,
    required this.requestPermission,
  });

  final HabitItem habit;
  final bool requestPermission;
}

class _FakeHabitReminderNotificationService
    implements HabitReminderNotificationService {
  _FakeHabitReminderNotificationService({this.permissionGranted = true});

  final bool permissionGranted;
  final List<_ReminderRequest> scheduled = [];
  final List<String> cancelledHabitIds = [];
  int startupResyncs = 0;
  int permissionPromptRequests = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> resyncReminders(List<HabitItem> habits) async {
    startupResyncs += 1;

    for (final habit in habits) {
      cancelledHabitIds.add(habit.id);
      if (permissionGranted && habit.isActive && _hasSchedulableRule(habit)) {
        scheduled.add(_ReminderRequest(habit: habit, requestPermission: false));
      }
    }
  }

  @override
  Future<void> scheduleDailyReminder(
    HabitItem habit, {
    required bool requestPermission,
  }) async {
    if (requestPermission) {
      permissionPromptRequests += 1;
    }

    if (!permissionGranted || !habit.isActive || !_hasSchedulableRule(habit)) {
      return;
    }

    scheduled.add(
      _ReminderRequest(habit: habit, requestPermission: requestPermission),
    );
  }

  @override
  Future<void> cancelReminder(String habitId) async {
    cancelledHabitIds.add(habitId);
  }

  bool _hasSchedulableRule(HabitItem habit) {
    return habit.enabledReminderRules.any(
      (rule) =>
          HabitReminderLocalNotificationService.parseReminderTime(rule.time) !=
          null,
    );
  }
}

class _FakeHabitsStorage implements HabitsStorage {
  const _FakeHabitsStorage({required this.storedSnapshot});

  final HabitsSnapshot storedSnapshot;

  @override
  Future<HabitsSnapshot?> loadSnapshot({
    required String migrationDateKey,
  }) async {
    return storedSnapshot;
  }

  @override
  Future<void> saveSnapshot(HabitsSnapshot snapshot) async {}
}
