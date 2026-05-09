import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habit_record_attachment_storage.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/features/habits/presentation/pages/habits_page.dart';
import 'package:four_in_one_app/shared/widgets/product/habit_identity_card.dart';

void main() {
  testWidgets('shares record-based habits state between Habits and Today', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    expect(_findKeyedText('today-habits-completed', '0'), findsOneWidget);
    expect(_findKeyedText('today-habits-total', '/ 3'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('today-habits-check-ins-total')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    expect(find.text('Habits'), findsOneWidget);

    await tester.tap(find.text('添加习惯').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('habit-name-field')),
      'Meditate 10 min',
    );
    await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Meditate 10 min'), findsOneWidget);
    expect(find.text('未设置提醒'), findsWidgets);
    expect(find.text('今日 0 / 1'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(_findKeyedText('today-habits-completed', '0'), findsOneWidget);
    expect(_findKeyedText('today-habits-total', '/ 4'), findsOneWidget);
    expect(find.text('🌱 Meditate 10 min'), findsOneWidget);
    expect(find.text('今日 0 / 1'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('habit-check-in-habit-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-check-in-habit-4')));
    await tester.pumpAndSettle();

    expect(find.text('今日 2 / 1'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(_findKeyedText('today-habits-completed', '1'), findsOneWidget);
    expect(_findKeyedText('today-habits-total', '/ 4'), findsOneWidget);
    expect(find.text('今日打卡 2 次'), findsOneWidget);
    expect(find.text('还可继续'), findsOneWidget);
    expect(find.text('🌱 Meditate 10 min'), findsNothing);
    expect(find.text('今日 2 / 1'), findsNothing);
  });

  testWidgets('create habit flow stores optional identity fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加习惯').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('habit-name-field')),
      'Journal',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-emoji-field')),
      '✍️',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-description-field')),
      'Write one clear thought.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-target-field')),
      '3',
    );
    await _chooseReminderPreset(tester, '08:30');
    await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
    await tester.pumpAndSettle();

    expect(find.text('✍️'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Write one clear thought.'), findsOneWidget);
    expect(find.text('今日 0 / 3'), findsOneWidget);
    expect(find.textContaining('08:30'), findsOneWidget);
  });

  testWidgets('edit habit flow updates fields and preserves check-ins', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('habit-check-in-habit-1')));
    await tester.pumpAndSettle();
    expect(find.text('今日 1 / 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('habit-edit-habit-1')));
    await tester.pumpAndSettle();

    expect(find.text('编辑习惯'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('habit-name-field')),
      'Evening journal',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-emoji-field')),
      '🌙',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-description-field')),
      'Close the day gently.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('habit-target-field')),
      '2',
    );
    await _chooseReminderPreset(tester, '21:30');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('🌙'), findsOneWidget);
    expect(find.text('Evening journal'), findsOneWidget);
    expect(find.text('Close the day gently.'), findsOneWidget);
    expect(find.textContaining('21:30'), findsOneWidget);
    expect(find.text('今日 1 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('habit-check-in-habit-1')));
    await tester.pumpAndSettle();

    expect(find.text('今日 2 / 2'), findsOneWidget);
  });

  testWidgets('recent activity strip shows count-aware intensity levels', (
    tester,
  ) async {
    final habit = _testHabit(id: 'habit-activity');
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 23, 9),
          initialHabits: [habit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-1',
              habitId: habit.id,
              localDate: '2026-04-18',
            ),
            _testRecord(
              id: 'habit-record-2',
              habitId: habit.id,
              localDate: '2026-04-19',
            ),
            _testRecord(
              id: 'habit-record-3',
              habitId: habit.id,
              localDate: '2026-04-19',
            ),
            _testRecord(
              id: 'habit-record-4',
              habitId: habit.id,
              localDate: '2026-04-20',
            ),
            _testRecord(
              id: 'habit-record-5',
              habitId: habit.id,
              localDate: '2026-04-20',
            ),
            _testRecord(
              id: 'habit-record-6',
              habitId: habit.id,
              localDate: '2026-04-20',
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('habit-activity-habit-activity-0-level-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-activity-habit-activity-1-level-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-activity-habit-activity-2-level-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-activity-habit-activity-3-level-3')),
      findsOneWidget,
    );
  });

  testWidgets('monthly heatmap opens and shows current-month counts', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(360, 640);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final habit = _testHabit(id: 'habit-month', name: 'Journal');
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 23, 9),
          initialHabits: [habit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-1',
              habitId: habit.id,
              localDate: '2026-03-31',
            ),
            _testRecord(
              id: 'habit-record-2',
              habitId: habit.id,
              localDate: '2026-04-02',
            ),
            _testRecord(
              id: 'habit-record-3',
              habitId: habit.id,
              localDate: '2026-04-02',
            ),
            _testRecord(
              id: 'habit-record-4',
              habitId: habit.id,
              localDate: '2026-04-03',
            ),
            _testRecord(
              id: 'habit-record-5',
              habitId: habit.id,
              localDate: '2026-04-03',
            ),
            _testRecord(
              id: 'habit-record-6',
              habitId: habit.id,
              localDate: '2026-04-03',
            ),
            _testRecord(
              id: 'habit-record-7',
              habitId: habit.id,
              localDate: '2026-05-01',
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('habit-activity-month-habit-month')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('habit-activity-month-habit-month')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('habit-month-heatmap-dialog-habit-month')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-month-close-habit-month')),
      findsOneWidget,
    );
    for (final level in [0, 1, 2, 3]) {
      expect(
        find.byKey(ValueKey<String>('habit-month-legend-level-$level')),
        findsOneWidget,
      );
    }
    expect(find.text('🌱 Journal'), findsOneWidget);
    expect(find.text('2026年4月活动'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-month-2026-04-01-level-0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-month-2026-04-02-level-2'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-month-2026-04-03-level-3'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-month-2026-03-31-level-1'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-month-2026-05-01-level-1'),
      ),
      findsNothing,
    );
  });

  testWidgets('habit card reminder picker sets and clears reminder', (
    tester,
  ) async {
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          initialHabits: [_testHabit(id: 'habit-reminder')],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('habit-reminder-habit-reminder')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('habit-reminder-add-rule')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('habit-reminder-add-rule')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-rule-time-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-preset-08:30')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-rules-save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('08:30'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('habit-reminder-habit-reminder')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('habit-reminder-rule-remove-0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-rules-save')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('habit-reminder-habit-reminder')),
      findsOneWidget,
    );
  });

  testWidgets('habit lifecycle sections and action sheet update visibility', (
    tester,
  ) async {
    final activeHabit = _testHabit(id: 'habit-active', name: 'Active');
    final pausedHabit = _testHabit(
      id: 'habit-paused',
      name: 'Paused',
      status: HabitLifecycleStatus.paused,
    );
    final archivedHabit = _testHabit(
      id: 'habit-archived',
      name: 'Archived',
      status: HabitLifecycleStatus.archived,
    );
    final deletedHabit = _testHabit(
      id: 'habit-deleted',
      name: 'Deleted',
      status: HabitLifecycleStatus.deleted,
    );
    final store = HabitsStore.seededInMemory(
      initialHabits: [activeHabit, pausedHabit, archivedHabit, deletedHabit],
      initialRecords: [
        _testRecord(
          id: 'habit-record-paused',
          habitId: pausedHabit.id,
          localDate: '2026-04-23',
        ),
        _testRecord(
          id: 'habit-record-archived',
          habitId: archivedHabit.id,
          localDate: '2026-04-23',
        ),
      ],
    );
    addTearDown(store.dispose);

    await _pumpHabitsPage(tester, store, _FakeHabitAttachmentStorage());

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('已暂停'), findsWidgets);
    expect(find.text('已归档习惯'), findsOneWidget);
    expect(find.text('Archived'), findsNothing);
    expect(find.text('Deleted'), findsNothing);

    final pausedButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('habit-check-in-habit-paused')),
    );
    expect(pausedButton.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('habits-archived-section')));
    await _pumpStableFrame(tester);

    expect(find.text('Archived'), findsOneWidget);
    final archivedButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('habit-check-in-habit-archived')),
    );
    expect(archivedButton.onPressed, isNull);

    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-habit-active')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-pause-habit-active')),
    );
    await _pumpStableFrame(tester);

    expect(
      store.pausedHabits.map((habit) => habit.id),
      contains('habit-active'),
    );
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('已暂停'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-habit-active')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-restore-habit-active')),
    );
    await _pumpStableFrame(tester);

    expect(store.habits.map((habit) => habit.id), contains('habit-active'));

    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-habit-active')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(
      find.byKey(const ValueKey('habit-lifecycle-delete-habit-active')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(
      find.byKey(const ValueKey('habit-soft-delete-confirm-habit-active')),
    );
    await _pumpStableFrame(tester);

    expect(
      store.deletedHabits.map((habit) => habit.id),
      contains('habit-active'),
    );
    expect(find.text('Active'), findsNothing);
    expect(store.records.map((record) => record.id), [
      'habit-record-paused',
      'habit-record-archived',
    ]);
  });

  testWidgets('habit record sheet saves only after explicit confirmation', (
    tester,
  ) async {
    final habit = _testHabit(id: 'habit-records', name: 'Journal');
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: const [],
    );
    addTearDown(store.dispose);

    await _pumpHabitsPage(tester, store, _FakeHabitAttachmentStorage());

    await tester.tap(find.byKey(const ValueKey('habit-records-habit-records')));
    await _pumpStableFrame(tester);

    expect(
      find.byKey(const ValueKey('habit-record-sheet-habit-records')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-date-records-empty-habit-records')),
      findsOneWidget,
    );
    expect(store.records, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('habit-record-note-field-habit-records')),
      'Draft only.',
    );
    await tester.tap(
      find.byKey(const ValueKey('habit-detailed-check-in-habit-records')),
    );
    await _pumpStableFrame(tester);

    expect(store.records, isEmpty);

    await tester.tap(find.byKey(const ValueKey('habit-makeup-habit-records')));
    await _pumpStableFrame(tester);

    expect(find.text('选中日期 2026-04-22'), findsOneWidget);
    expect(store.records, isEmpty);

    await tester.tap(
      find.byKey(const ValueKey('habit-record-cancel-habit-records')),
    );
    await _pumpStableFrame(tester);

    expect(store.records, isEmpty);

    await tester.tap(find.byKey(const ValueKey('habit-records-habit-records')));
    await _pumpStableFrame(tester);
    await tester.enterText(
      find.byKey(const ValueKey('habit-record-note-field-habit-records')),
      'Felt focused.',
    );
    await tester.tap(
      find.byKey(const ValueKey('habit-record-save-habit-records')),
    );
    await _pumpStableFrame(tester);

    expect(store.records, hasLength(1));
    expect(store.records.single.type, HabitRecordType.checkIn);
    expect(store.records.single.localDate, '2026-04-23');
    expect(store.records.single.note, 'Felt focused.');
    expect(store.todayCheckInCount(habit), 1);
    expect(find.textContaining('Felt focused.'), findsWidgets);
    expect(find.textContaining('打卡'), findsWidgets);
    expect(find.textContaining('不能标记跳过'), findsOneWidget);
  });

  testWidgets(
    'month view opens date-specific sheet for makeup and future guard',
    (tester) async {
      final habit = _testHabit(id: 'habit-records', name: 'Journal');
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 23, 9),
        initialHabits: [habit],
        initialRecords: const [],
      );
      addTearDown(store.dispose);

      await _pumpHabitsPage(tester, store, _FakeHabitAttachmentStorage());

      await tester.tap(
        find.byKey(const ValueKey('habit-activity-month-habit-records')),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('habit-month-cell-habit-records-2026-04-22-level-0'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(
        find.byKey(const ValueKey('habit-record-sheet-habit-records')),
        findsOneWidget,
      );
      expect(find.text('选中日期 2026-04-22'), findsOneWidget);
      expect(store.records, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('habit-record-note-field-habit-records')),
        'Made up yesterday.',
      );
      await tester.tap(
        find.byKey(const ValueKey('habit-record-save-habit-records')),
      );
      await _pumpStableFrame(tester);

      expect(store.records, hasLength(1));
      expect(store.records.single.type, HabitRecordType.makeup);
      expect(store.records.single.localDate, '2026-04-22');
      expect(store.activityCountOn(habit, '2026-04-22'), 1);
      expect(store.todayCheckInCount(habit), 0);

      await tester.tap(
        find.byKey(const ValueKey('habit-record-cancel-habit-records')),
      );
      await _pumpStableFrame(tester);

      await tester.tap(
        find.byKey(const ValueKey('habit-activity-month-habit-records')),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('habit-month-cell-habit-records-2026-04-24-level-0'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(find.text('选中日期 2026-04-24'), findsOneWidget);
      expect(find.text('未来日期暂不能记录。'), findsWidgets);
      await tester.tap(
        find.byKey(const ValueKey('habit-record-save-habit-records')),
      );
      await _pumpStableFrame(tester);

      expect(store.records, hasLength(1));
    },
  );

  testWidgets('skip from date-specific sheet stays non-completion', (
    tester,
  ) async {
    final habit = _testHabit(id: 'habit-skip-date', name: 'Rest');
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: const [],
    );
    addTearDown(store.dispose);

    await _pumpHabitsPage(tester, store, _FakeHabitAttachmentStorage());
    await tester.tap(
      find.byKey(const ValueKey('habit-activity-month-habit-skip-date')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(
      find.byKey(
        const ValueKey('habit-month-cell-habit-skip-date-2026-04-21-level-0'),
      ),
    );
    await _pumpStableFrame(tester);
    expect(
      find.byKey(const ValueKey('habit-record-sheet-habit-skip-date')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('habit-skip-habit-skip-date')));
    await _pumpStableFrame(tester);
    await tester.enterText(
      find.byKey(const ValueKey('habit-record-note-field-habit-skip-date')),
      'Intentional rest.',
    );
    await tester.tap(
      find.byKey(const ValueKey('habit-record-save-habit-skip-date')),
    );
    await _pumpStableFrame(tester);

    expect(store.records, hasLength(1));
    expect(store.records.single.type, HabitRecordType.skip);
    expect(store.records.single.localDate, '2026-04-21');
    expect(store.records.single.note, 'Intentional rest.');
    expect(store.activityCountOn(habit, '2026-04-21'), 0);
    expect(store.currentMonthActivity(habit).days[20].count, 0);
  });

  testWidgets('habit statistics sheet renders real per-habit metrics', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(360, 760);
    view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    final habit = _testHabit(
      id: 'habit-stat',
      name: 'Journal',
      targetCountPerDay: 2,
      createdAt: DateTime(2026, 4, 1, 8),
    );
    final store = HabitsStore.seededInMemory(
      nowProvider: () => DateTime(2026, 4, 23, 9),
      initialHabits: [habit],
      initialRecords: [
        _testRecord(
          id: 'habit-record-1',
          habitId: habit.id,
          localDate: '2026-04-01',
          note: 'First check-in.',
        ),
        _testRecord(
          id: 'habit-record-2',
          habitId: habit.id,
          localDate: '2026-04-01',
          type: HabitRecordType.makeup,
        ),
        _testRecord(
          id: 'habit-record-3',
          habitId: habit.id,
          localDate: '2026-04-02',
          type: HabitRecordType.skip,
        ),
      ],
      initialAttachments: [
        HabitRecordAttachment(
          id: 'habit-attachment-1',
          recordId: 'habit-record-1',
          habitId: habit.id,
          relativePath: 'habit_record_images/proof.png',
          fileName: 'proof.png',
          mimeType: 'image/png',
          createdAt: DateTime.utc(2026, 4, 1, 8),
        ),
      ],
    );
    addTearDown(store.dispose);

    await _pumpHabitsPage(tester, store, _FakeHabitAttachmentStorage());

    await tester.tap(find.byKey(const ValueKey('habit-stats-habit-stat')));
    await _pumpStableFrame(tester);

    expect(
      find.byKey(const ValueKey('habit-statistics-sheet-habit-stat')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-completed-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-effective-check-ins-habit-stat', '2'),
      findsOneWidget,
    );
    expect(_findKeyedText('habit-stats-skips-habit-stat', '1'), findsOneWidget);
    expect(
      _findKeyedText('habit-stats-makeups-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-proofs-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-completion-rate-habit-stat', '50%'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-current-streak-habit-stat', '0'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-stats-longest-streak-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-streak-protection-note-habit-stat')),
      findsOneWidget,
    );
    expect(find.text('连续天数按达标日期计算'), findsOneWidget);
    expect(find.text('暂停期间不计入连续天数'), findsOneWidget);
    expect(find.text('跳过不会算作达标'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('habit-completion-distribution-habit-stat')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-active-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-tracked-days-habit-stat', '2'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-skip-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-proof-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-distribution-bars-habit-stat')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-bar-completed-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-bar-skip-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('habit-distribution-bar-proof-days-habit-stat', '1'),
      findsOneWidget,
    );
    expect(find.text('近 3 个月活动'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('habit-annual-activity-habit-stat')),
      findsOneWidget,
    );
    expect(find.text('月份以 1-12 标记；横向滑动查看全年节奏。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('habit-annual-scroll-habit-stat')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-annual-cell-habit-stat-2026-04-01-level-2'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-annual-cell-habit-stat-2026-04-02-level-0'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-analytics-recent-months-habit-stat')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-analytics-month-habit-stat-2026-02')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-analytics-month-habit-stat-2026-03')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-analytics-month-habit-stat-2026-04')),
      findsOneWidget,
    );
    expect(find.text('记录明细'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('habit-record-date-group-habit-stat-2026-04-01'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-record-date-group-habit-stat-2026-04-02'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-stat-record-row-habit-record-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-stat-record-type-habit-record-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-stat-record-note-habit-record-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-stat-record-proof-count-habit-record-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('habit-stat-proof-missing-habit-record-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-stat-2026-04-01-level-2'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('habit-month-cell-habit-stat-2026-04-02-level-0'),
      ),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'Habit analytics overflow at 360dp and 1.15 text scale',
    );
  });

  testWidgets(
    'habit record attachment sheet adds image metadata with fake storage',
    (tester) async {
      final habit = _testHabit(id: 'habit-proof', name: 'Journal');
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 23, 9),
        initialHabits: [habit],
        initialRecords: [
          _testRecord(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-04-23',
            note: 'Proof note',
          ),
        ],
      );
      addTearDown(store.dispose);
      final attachmentStorage = _FakeHabitAttachmentStorage(
        galleryPicks: const [
          [
            StoredHabitRecordImage(
              relativePath: 'habit_record_images/proof-a.png',
              fileName: 'proof-a.png',
              mimeType: 'image/png',
            ),
            StoredHabitRecordImage(
              relativePath: 'habit_record_images/proof-b.jpg',
              fileName: 'proof-b.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
        ],
        cameraCaptures: const [
          StoredHabitRecordImage(
            relativePath: 'habit_record_images/proof-c.jpg',
            fileName: 'proof-c.jpg',
            mimeType: 'image/jpeg',
          ),
        ],
      );

      await _pumpHabitsPage(tester, store, attachmentStorage);

      await tester.tap(find.byKey(const ValueKey('habit-records-habit-proof')));
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(const ValueKey('habit-record-attach-habit-record-1')),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(const ValueKey('habit-record-image-add-habit-record-1')),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('habit-record-image-source-gallery-habit-record-1'),
        ),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(const ValueKey('habit-record-image-add-habit-record-1')),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('habit-record-image-source-camera-habit-record-1'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(attachmentStorage.galleryRecordIds, ['habit-record-1']);
      expect(attachmentStorage.cameraRecordIds, ['habit-record-1']);
      expect(attachmentStorage.galleryLimits, [3]);
      expect(store.attachmentsForRecord('habit-record-1'), hasLength(3));
      expect(
        store.attachments.map((attachment) => attachment.recordId).toSet(),
        {'habit-record-1'},
      );
      expect(
        store.attachments.map((attachment) => attachment.habitId).toSet(),
        {habit.id},
      );
      expect(
        store.attachments.map((attachment) => attachment.relativePath).toSet(),
        {
          'habit_record_images/proof-a.png',
          'habit_record_images/proof-b.jpg',
          'habit_record_images/proof-c.jpg',
        },
      );
      expect(
        find.byKey(const ValueKey('habit-record-image-max-habit-record-1')),
        findsOneWidget,
      );
      expect(store.records.single.note, 'Proof note');
      expect(store.todayCheckInCount(habit), 1);
    },
  );

  testWidgets(
    'habit record missing image state is safe and replace/remove delete old files',
    (tester) async {
      final habit = _testHabit(id: 'habit-proof', name: 'Journal');
      final store = HabitsStore.seededInMemory(
        nowProvider: () => DateTime(2026, 4, 23, 9),
        initialHabits: [habit],
        initialRecords: [
          _testRecord(
            id: 'habit-record-1',
            habitId: habit.id,
            localDate: '2026-04-23',
          ),
        ],
        initialAttachments: [
          HabitRecordAttachment(
            id: 'habit-attachment-1',
            recordId: 'habit-record-1',
            habitId: habit.id,
            relativePath: 'habit_record_images/proof-a.png',
            fileName: 'proof-a.png',
            mimeType: 'image/png',
            createdAt: DateTime.utc(2026, 4, 23, 8, 30),
          ),
        ],
      );
      addTearDown(store.dispose);
      final attachmentStorage = _FakeHabitAttachmentStorage(
        galleryPicks: const [
          [
            StoredHabitRecordImage(
              relativePath: 'habit_record_images/proof-b.jpg',
              fileName: 'proof-b.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
        ],
      );

      await _pumpHabitsPage(tester, store, attachmentStorage);

      await _pumpStableFrame(tester);
      await tester.tap(find.byKey(const ValueKey('habit-records-habit-proof')));
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(const ValueKey('habit-record-missing-image-habit-record-1')),
      );
      await _pumpStableFrame(tester);

      expect(
        find.byKey(const ValueKey('habit-record-image-missing-habit-record-1')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey('habit-record-image-missing-thumb-habit-attachment-1'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('habit-record-image-missing-thumb-habit-attachment-1'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(
        find.byKey(const ValueKey('habit-record-image-missing-habit-record-1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('habit-record-image-replace-habit-attachment-1'),
        ),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('habit-record-image-source-gallery-habit-record-1'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(
        store.attachments.single.relativePath,
        'habit_record_images/proof-b.jpg',
      );
      expect(attachmentStorage.removedPaths, [
        'habit_record_images/proof-a.png',
      ]);

      final replacementId = store.attachments.single.id;
      await tester.tap(
        find.byKey(
          ValueKey<String>('habit-record-image-missing-thumb-$replacementId'),
        ),
      );
      await _pumpStableFrame(tester);
      await tester.tap(
        find.byKey(
          ValueKey<String>('habit-record-image-remove-$replacementId'),
        ),
      );
      await _pumpStableFrame(tester);

      expect(store.attachments, isEmpty);
      expect(store.records.single.id, 'habit-record-1');
      expect(attachmentStorage.removedPaths, [
        'habit_record_images/proof-a.png',
        'habit_record_images/proof-b.jpg',
      ]);
    },
  );

  testWidgets('skip-only habit shows skipped state without completion', (
    tester,
  ) async {
    final habit = _testHabit(id: 'habit-skipped', name: 'Rest');
    await tester.pumpWidget(
      FourInOneApp(
        habitsStore: HabitsStore.seededInMemory(
          nowProvider: () => DateTime(2026, 4, 23, 9),
          initialHabits: [habit],
          initialRecords: [
            _testRecord(
              id: 'habit-record-skip',
              habitId: habit.id,
              localDate: '2026-04-23',
              type: HabitRecordType.skip,
            ),
          ],
        ),
        goalsStore: GoalsStore.inMemory(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('habit-today-count-0-1')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('habit-skip-state-habit-skipped')),
      findsOneWidget,
    );
  });

  testWidgets(
    'preset emoji selection fills habit emoji while custom input remains available',
    (tester) async {
      await tester.pumpWidget(
        FourInOneApp(
          habitsStore: HabitsStore.seededInMemory(initialHabits: const []),
          goalsStore: GoalsStore.inMemory(),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '添加习惯'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('habit-name-field')),
        'Read',
      );
      await tester.tap(find.byKey(const ValueKey('habit-emoji-preset-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Read'), findsOneWidget);
      expect(find.text('📖'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, '添加习惯'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('habit-name-field')),
        'Custom icon',
      );
      await tester.enterText(
        find.byKey(const ValueKey('habit-emoji-field')),
        '⭐',
      );
      await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Custom icon'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
    },
  );

  testWidgets('habit color picker creates edits and clears habit color', (
    tester,
  ) async {
    final store = HabitsStore.seededInMemory(initialHabits: const []);

    await tester.pumpWidget(
      FourInOneApp(habitsStore: store, goalsStore: GoalsStore.inMemory()),
    );
    await tester.tap(find.byKey(const ValueKey('today-habits-view-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('habit-name-field')),
      'Color habit',
    );
    await tester.tap(find.byKey(const ValueKey('habit-color-preset-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
    await tester.pumpAndSettle();

    expect(store.habits.single.habitColorValue, 0xFF6F95AF);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HabitIdentityCard &&
            widget.habitId == store.habits.single.id &&
            widget.accentColor == const Color(0xFF6F95AF),
      ),
      findsOneWidget,
    );

    await store.checkIn(store.habits.single.id);
    expect(store.todayCheckInCount(store.habits.single), 1);

    await tester.tap(
      find.byKey(ValueKey<String>('habit-edit-${store.habits.single.id}')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('habit-color-preset-7')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-color-preset-7')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
    await tester.pumpAndSettle();

    expect(store.habits.single.habitColorValue, 0xFF4F8D8B);
    expect(store.todayCheckInCount(store.habits.single), 1);

    await tester.tap(
      find.byKey(ValueKey<String>('habit-edit-${store.habits.single.id}')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('habit-color-follow-accent')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-color-follow-accent')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-form-submit')));
    await tester.pumpAndSettle();

    expect(store.habits.single.habitColorValue, isNull);
    expect(store.todayCheckInCount(store.habits.single), 1);
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

Future<void> _chooseReminderPreset(WidgetTester tester, String value) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  final field = find.byKey(const ValueKey('habit-reminder-field'));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-add-rule')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-rule-time-0')));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey<String>('habit-reminder-preset-$value')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-save')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-rules-save')));
  await tester.pumpAndSettle();
}

Future<void> _pumpHabitsPage(
  WidgetTester tester,
  HabitsStore store,
  HabitRecordAttachmentStorage attachmentStorage,
) {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: HabitsScope(
        notifier: store,
        child: Scaffold(body: HabitsPage(attachmentStorage: attachmentStorage)),
      ),
    ),
  );
}

Future<void> _pumpStableFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

HabitItem _testHabit({
  required String id,
  String name = 'Saved habit',
  int targetCountPerDay = 1,
  HabitLifecycleStatus status = HabitLifecycleStatus.active,
  DateTime? createdAt,
}) {
  return HabitItem(
    id: id,
    name: name,
    emoji: HabitItem.defaultEmoji,
    description: '',
    targetCountPerDay: targetCountPerDay,
    reminderTime: null,
    status: status,
    createdAt: createdAt ?? DateTime.parse('2026-04-23T08:00:00.000'),
  );
}

HabitRecord _testRecord({
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

class _FakeHabitAttachmentStorage implements HabitRecordAttachmentStorage {
  _FakeHabitAttachmentStorage({
    List<List<StoredHabitRecordImage>> galleryPicks =
        const <List<StoredHabitRecordImage>>[],
    List<StoredHabitRecordImage?> cameraCaptures =
        const <StoredHabitRecordImage?>[],
    List<List<StoredHabitRecordImage>> lostRecoveries =
        const <List<StoredHabitRecordImage>>[],
    Map<String, File> resolvedImages = const <String, File>{},
  }) : _galleryPicks = List<List<StoredHabitRecordImage>>.of(galleryPicks),
       _cameraCaptures = List<StoredHabitRecordImage?>.of(cameraCaptures),
       _lostRecoveries = List<List<StoredHabitRecordImage>>.of(lostRecoveries),
       _resolvedImages = resolvedImages;

  final List<List<StoredHabitRecordImage>> _galleryPicks;
  final List<StoredHabitRecordImage?> _cameraCaptures;
  final List<List<StoredHabitRecordImage>> _lostRecoveries;
  final Map<String, File> _resolvedImages;
  final List<String> galleryRecordIds = <String>[];
  final List<int> galleryLimits = <int>[];
  final List<String> cameraRecordIds = <String>[];
  final List<String> lostRecordIds = <String>[];
  final List<String> removedPaths = <String>[];

  @override
  Future<List<StoredHabitRecordImage>> pickAndStoreImages(
    String recordId, {
    required int limit,
  }) async {
    galleryRecordIds.add(recordId);
    galleryLimits.add(limit);
    if (_galleryPicks.isEmpty || limit <= 0) {
      return const <StoredHabitRecordImage>[];
    }

    return _galleryPicks.removeAt(0).take(limit).toList(growable: false);
  }

  @override
  Future<StoredHabitRecordImage?> captureAndStoreImage(String recordId) async {
    cameraRecordIds.add(recordId);
    if (_cameraCaptures.isEmpty) {
      return null;
    }

    return _cameraCaptures.removeAt(0);
  }

  @override
  Future<List<StoredHabitRecordImage>> retrieveLostImages(
    String recordId, {
    required int limit,
  }) async {
    lostRecordIds.add(recordId);
    if (_lostRecoveries.isEmpty || limit <= 0) {
      return const <StoredHabitRecordImage>[];
    }

    return _lostRecoveries.removeAt(0).take(limit).toList(growable: false);
  }

  @override
  Future<void> removeImage(String relativePath) async {
    removedPaths.add(relativePath);
  }

  @override
  Future<File?> resolveImage(String relativePath) async {
    return _resolvedImages[relativePath];
  }
}
