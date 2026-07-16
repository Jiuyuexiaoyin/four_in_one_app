import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:four_in_one_app/features/habits/data/habit_reminder_notification_service.dart';
import 'package:four_in_one_app/features/habits/data/habits_local_storage.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_check_in_template.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_metric.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_statistics_summary.dart';

typedef HabitNowProvider = DateTime Function();

abstract interface class HabitPlanRecordWriter {
  Future<void> recordDailyCompletion({
    required HabitItem habit,
    required String localDate,
    required int effectiveCount,
  });
}

class NoopHabitPlanRecordWriter implements HabitPlanRecordWriter {
  const NoopHabitPlanRecordWriter();

  @override
  Future<void> recordDailyCompletion({
    required HabitItem habit,
    required String localDate,
    required int effectiveCount,
  }) async {}
}

class HabitActivityDay {
  const HabitActivityDay({required this.localDate, required this.count});

  final String localDate;
  final int count;
}

class HabitActivityMonth {
  const HabitActivityMonth({
    required this.year,
    required this.month,
    required this.days,
  });

  final int year;
  final int month;
  final List<HabitActivityDay> days;
}

class HabitAnnualActivity {
  const HabitAnnualActivity({required this.year, required this.days});

  final int year;
  final List<HabitActivityDay> days;
}

class HabitRecordDateGroup {
  const HabitRecordDateGroup({required this.localDate, required this.records});

  final String localDate;
  final List<HabitRecord> records;
}

class HabitCheckInTemplateDraft {
  const HabitCheckInTemplateDraft({
    required this.title,
    required this.unit,
    this.defaultValue,
  });

  final String title;
  final String unit;
  final double? defaultValue;
}

class HabitRecordMetricInput {
  const HabitRecordMetricInput({
    required this.templateId,
    required this.numericValue,
  });

  final String templateId;
  final double numericValue;
}

class HabitMetricTotal {
  const HabitMetricTotal({
    required this.title,
    required this.unit,
    required this.total,
    required this.entryCount,
  });

  final String title;
  final String unit;
  final double total;
  final int entryCount;
}

class HabitMetricRecordEntry {
  const HabitMetricRecordEntry({required this.record, required this.metric});

  final HabitRecord record;
  final HabitRecordMetric metric;
}

class HabitMetricSummary {
  const HabitMetricSummary({required this.totals, required this.recentEntries});

  final List<HabitMetricTotal> totals;
  final List<HabitMetricRecordEntry> recentEntries;

  bool get hasMetrics => totals.isNotEmpty || recentEntries.isNotEmpty;
}

class HabitsStore extends ChangeNotifier {
  static const maxAttachmentsPerRecord = 3;
  static const maxCheckInTemplatesPerHabit = 6;

  HabitsStore._({
    required HabitsStorage storage,
    required List<HabitItem> initialHabits,
    required List<HabitRecord> initialRecords,
    required List<HabitRecordAttachment> initialAttachments,
    required List<HabitCheckInTemplate> initialCheckInTemplates,
    required List<HabitRecordMetric> initialRecordMetrics,
    required int nextHabitId,
    required int nextRecordId,
    required int nextAttachmentId,
    required int nextTemplateId,
    required int nextMetricId,
    required HabitNowProvider nowProvider,
    required HabitReminderNotificationService reminderNotificationService,
    required HabitPlanRecordWriter planRecordWriter,
  }) : _storage = storage,
       _habits = List<HabitItem>.of(initialHabits),
       _records = List<HabitRecord>.of(initialRecords),
       _attachments = List<HabitRecordAttachment>.of(initialAttachments),
       _checkInTemplates = List<HabitCheckInTemplate>.of(
         initialCheckInTemplates,
       ),
       _recordMetrics = List<HabitRecordMetric>.of(initialRecordMetrics),
       _nextHabitId = nextHabitId,
       _nextRecordId = nextRecordId,
       _nextAttachmentId = nextAttachmentId,
       _nextTemplateId = nextTemplateId,
       _nextMetricId = nextMetricId,
       _nowProvider = nowProvider,
       _reminderNotificationService = reminderNotificationService,
       _planRecordWriter = planRecordWriter;

  static Future<HabitsStore> load(
    HabitsStorage storage, {
    HabitNowProvider? nowProvider,
    HabitReminderNotificationService? reminderNotificationService,
    HabitPlanRecordWriter? planRecordWriter,
  }) async {
    final effectiveNowProvider = nowProvider ?? DateTime.now;
    final effectiveReminderNotificationService =
        reminderNotificationService ?? NoopHabitReminderNotificationService();
    final effectivePlanRecordWriter =
        planRecordWriter ?? const NoopHabitPlanRecordWriter();
    final currentDayKey = _localDayKey(effectiveNowProvider());
    final savedSnapshot = await storage.loadSnapshot(
      migrationDateKey: currentDayKey,
    );

    if (savedSnapshot != null) {
      final store = HabitsStore._(
        storage: storage,
        initialHabits: savedSnapshot.habits,
        initialRecords: savedSnapshot.records,
        initialAttachments: savedSnapshot.attachments,
        initialCheckInTemplates: savedSnapshot.checkInTemplates,
        initialRecordMetrics: savedSnapshot.recordMetrics,
        nextHabitId: _deriveNextId(savedSnapshot.habits),
        nextRecordId: _deriveNextRecordId(savedSnapshot.records),
        nextAttachmentId: _deriveNextAttachmentId(savedSnapshot.attachments),
        nextTemplateId: _deriveNextTemplateId(savedSnapshot.checkInTemplates),
        nextMetricId: _deriveNextMetricId(savedSnapshot.recordMetrics),
        nowProvider: effectiveNowProvider,
        reminderNotificationService: effectiveReminderNotificationService,
        planRecordWriter: effectivePlanRecordWriter,
      );

      if (savedSnapshot.shouldPersistAfterLoad) {
        await store._persistSnapshot();
      }

      await store._resyncRemindersOnStartup();

      return store;
    }

    final seededHabits = _buildSeedHabits(effectiveNowProvider);
    await storage.saveSnapshot(
      HabitsSnapshot(
        habits: seededHabits,
        records: const <HabitRecord>[],
        attachments: const <HabitRecordAttachment>[],
        checkInTemplates: const <HabitCheckInTemplate>[],
        recordMetrics: const <HabitRecordMetric>[],
      ),
    );

    final store = HabitsStore._(
      storage: storage,
      initialHabits: seededHabits,
      initialRecords: const <HabitRecord>[],
      initialAttachments: const <HabitRecordAttachment>[],
      initialCheckInTemplates: const <HabitCheckInTemplate>[],
      initialRecordMetrics: const <HabitRecordMetric>[],
      nextHabitId: _deriveNextId(seededHabits),
      nextRecordId: 1,
      nextAttachmentId: 1,
      nextTemplateId: 1,
      nextMetricId: 1,
      nowProvider: effectiveNowProvider,
      reminderNotificationService: effectiveReminderNotificationService,
      planRecordWriter: effectivePlanRecordWriter,
    );

    await store._resyncRemindersOnStartup();

    return store;
  }

  factory HabitsStore.seededInMemory({
    HabitNowProvider? nowProvider,
    List<HabitItem>? initialHabits,
    List<HabitRecord>? initialRecords,
    List<HabitRecordAttachment>? initialAttachments,
    List<HabitCheckInTemplate>? initialCheckInTemplates,
    List<HabitRecordMetric>? initialRecordMetrics,
    HabitReminderNotificationService? reminderNotificationService,
    HabitPlanRecordWriter? planRecordWriter,
  }) {
    final effectiveNowProvider = nowProvider ?? DateTime.now;
    final seededHabits =
        initialHabits ?? _buildSeedHabits(effectiveNowProvider);
    final records = initialRecords ?? const <HabitRecord>[];
    final attachments = initialAttachments ?? const <HabitRecordAttachment>[];
    final checkInTemplates =
        initialCheckInTemplates ?? const <HabitCheckInTemplate>[];
    final recordMetrics = initialRecordMetrics ?? const <HabitRecordMetric>[];

    return HabitsStore._(
      storage: _InMemoryHabitsStorage(),
      initialHabits: seededHabits,
      initialRecords: records,
      initialAttachments: attachments,
      initialCheckInTemplates: checkInTemplates,
      initialRecordMetrics: recordMetrics,
      nextHabitId: _deriveNextId(seededHabits),
      nextRecordId: _deriveNextRecordId(records),
      nextAttachmentId: _deriveNextAttachmentId(attachments),
      nextTemplateId: _deriveNextTemplateId(checkInTemplates),
      nextMetricId: _deriveNextMetricId(recordMetrics),
      nowProvider: effectiveNowProvider,
      reminderNotificationService:
          reminderNotificationService ?? NoopHabitReminderNotificationService(),
      planRecordWriter: planRecordWriter ?? const NoopHabitPlanRecordWriter(),
    );
  }

  final HabitsStorage _storage;
  final List<HabitItem> _habits;
  final List<HabitRecord> _records;
  final List<HabitRecordAttachment> _attachments;
  final List<HabitCheckInTemplate> _checkInTemplates;
  final List<HabitRecordMetric> _recordMetrics;
  final HabitNowProvider _nowProvider;
  final HabitReminderNotificationService _reminderNotificationService;
  final HabitPlanRecordWriter _planRecordWriter;
  int _nextHabitId;
  int _nextRecordId;
  int _nextAttachmentId;
  int _nextTemplateId;
  int _nextMetricId;

  List<HabitItem> get _activeHabits => _habits
      .where((habit) => habit.status == HabitLifecycleStatus.active)
      .toList(growable: false);

  List<HabitItem> get _pausedHabits => _habits
      .where((habit) => habit.status == HabitLifecycleStatus.paused)
      .toList(growable: false);

  List<HabitItem> get _archivedHabits => _habits
      .where((habit) => habit.status == HabitLifecycleStatus.archived)
      .toList(growable: false);

  List<HabitItem> get _deletedHabits => _habits
      .where((habit) => habit.status == HabitLifecycleStatus.deleted)
      .toList(growable: false);

  Set<String> get _activeHabitIds =>
      _activeHabits.map((habit) => habit.id).toSet();

  UnmodifiableListView<HabitItem> get habits =>
      UnmodifiableListView(_activeHabits);

  UnmodifiableListView<HabitItem> get storedHabits =>
      UnmodifiableListView(_habits);

  UnmodifiableListView<HabitItem> get pausedHabits =>
      UnmodifiableListView(_pausedHabits);

  UnmodifiableListView<HabitItem> get archivedHabits =>
      UnmodifiableListView(_archivedHabits);

  UnmodifiableListView<HabitItem> get deletedHabits =>
      UnmodifiableListView(_deletedHabits);

  UnmodifiableListView<HabitRecord> get records =>
      UnmodifiableListView(_records);

  UnmodifiableListView<HabitRecordAttachment> get attachments =>
      UnmodifiableListView(_attachments);

  UnmodifiableListView<HabitCheckInTemplate> get checkInTemplates =>
      UnmodifiableListView(_checkInTemplates);

  UnmodifiableListView<HabitRecordMetric> get recordMetrics =>
      UnmodifiableListView(_recordMetrics);

  List<HabitItem> get previewHabits =>
      _activeHabits.take(3).toList(growable: false);

  int get totalCount => _activeHabits.length;

  String get currentDayKey => _currentDayKey;

  int get completedCount => _activeHabits.where(isCompletedToday).length;

  int get remainingCount => totalCount - completedCount;

  int get totalCheckInsToday {
    final activeHabitIds = _activeHabitIds;
    return _records
        .where(
          (record) =>
              activeHabitIds.contains(record.habitId) &&
              _countsTowardCompletion(record) &&
              record.localDate == _currentDayKey,
        )
        .length;
  }

  bool isCompletedToday(HabitItem habit) {
    if (!habit.isActive) {
      return false;
    }

    return todayCheckInCount(habit) >= habit.targetCountPerDay;
  }

  int todayCheckInCount(HabitItem habit) {
    if (!habit.isActive) {
      return 0;
    }

    return activityCountOn(habit, _currentDayKey);
  }

  int activityCountOn(HabitItem habit, String localDate) {
    return _records
        .where(
          (record) =>
              record.habitId == habit.id &&
              record.localDate == localDate &&
              _countsTowardCompletion(record),
        )
        .length;
  }

  bool hasSkipOn(HabitItem habit, String localDate) {
    return _records.any(
      (record) =>
          record.habitId == habit.id &&
          record.localDate == localDate &&
          record.type == HabitRecordType.skip,
    );
  }

  bool isSkippedToday(HabitItem habit) {
    return hasSkipOn(habit, _currentDayKey) &&
        activityCountOn(habit, _currentDayKey) == 0;
  }

  List<HabitRecord> recordsForHabit(HabitItem habit, {int? limit}) {
    final records = _records
        .where((record) => record.habitId == habit.id)
        .toList(growable: false);

    if (limit == null || records.length <= limit) {
      return records;
    }

    return records.take(limit).toList(growable: false);
  }

  List<HabitRecord> recordsForHabitDate(HabitItem habit, String localDate) {
    return _records
        .where(
          (record) =>
              record.habitId == habit.id && record.localDate == localDate,
        )
        .toList(growable: false);
  }

  List<HabitRecordDateGroup> recordDateGroupsForHabit(
    HabitItem habit, {
    int dateLimit = 8,
  }) {
    if (dateLimit <= 0) {
      return const <HabitRecordDateGroup>[];
    }

    final recordsByDate = <String, List<HabitRecord>>{};
    for (final record in _records) {
      if (record.habitId != habit.id ||
          _normalizeLocalDate(record.localDate) == null) {
        continue;
      }

      recordsByDate.putIfAbsent(record.localDate, () => []).add(record);
    }

    final sortedDates = recordsByDate.keys.toList(growable: false)
      ..sort((a, b) => b.compareTo(a));

    return sortedDates
        .take(dateLimit)
        .map((localDate) {
          final records = List<HabitRecord>.of(recordsByDate[localDate]!);
          records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return HabitRecordDateGroup(localDate: localDate, records: records);
        })
        .toList(growable: false);
  }

  HabitStatisticsSummary statisticsForHabit(HabitItem habit) {
    return HabitStatisticsSummary.fromRecords(
      habit: habit,
      records: _records,
      attachments: _attachments,
      now: _nowProvider(),
    );
  }

  List<HabitCheckInTemplate> templatesForHabit(
    HabitItem habit, {
    bool includeArchived = false,
  }) {
    final templates = _checkInTemplates
        .where(
          (template) =>
              template.habitId == habit.id &&
              (includeArchived || !template.isArchived),
        )
        .toList(growable: false);
    templates.sort(_compareTemplates);
    return templates;
  }

  List<HabitRecordMetric> metricsForRecord(String recordId) {
    final record = _recordById(recordId);
    if (record == null) {
      return const <HabitRecordMetric>[];
    }

    final metrics = _recordMetrics
        .where(
          (metric) =>
              metric.recordId == record.id && metric.habitId == record.habitId,
        )
        .toList(growable: false);
    metrics.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return metrics;
  }

  List<HabitRecordMetric> metricsForHabit(HabitItem habit) {
    final recordIds = _records
        .where((record) => record.habitId == habit.id)
        .map((record) => record.id)
        .toSet();
    final metrics = _recordMetrics
        .where(
          (metric) =>
              metric.habitId == habit.id && recordIds.contains(metric.recordId),
        )
        .toList(growable: false);
    metrics.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return metrics;
  }

  int metricEntryCountOn(HabitItem habit, String localDate) {
    final recordIds = recordsForHabitDate(
      habit,
      localDate,
    ).where(_countsTowardCompletion).map((record) => record.id).toSet();
    return _recordMetrics
        .where(
          (metric) =>
              metric.habitId == habit.id && recordIds.contains(metric.recordId),
        )
        .length;
  }

  HabitMetricSummary metricSummaryForHabit(
    HabitItem habit, {
    int recentLimit = 8,
  }) {
    final recordById = <String, HabitRecord>{
      for (final record in _records)
        if (record.habitId == habit.id) record.id: record,
    };
    final metrics = _recordMetrics
        .where(
          (metric) =>
              metric.habitId == habit.id &&
              recordById.containsKey(metric.recordId),
        )
        .toList(growable: false);

    final totalsByKey = <String, _MetricAccumulator>{};
    for (final metric in metrics) {
      final key = '${metric.titleSnapshot}\u0000${metric.unitSnapshot}';
      final accumulator = totalsByKey.putIfAbsent(
        key,
        () => _MetricAccumulator(
          title: metric.titleSnapshot,
          unit: metric.unitSnapshot,
        ),
      );
      accumulator.add(metric.numericValue);
    }

    final totals =
        totalsByKey.values
            .map(
              (accumulator) => HabitMetricTotal(
                title: accumulator.title,
                unit: accumulator.unit,
                total: accumulator.total,
                entryCount: accumulator.entryCount,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) {
            final titleComparison = a.title.compareTo(b.title);
            if (titleComparison != 0) {
              return titleComparison;
            }
            return a.unit.compareTo(b.unit);
          });

    final recentEntries =
        metrics
            .map(
              (metric) => HabitMetricRecordEntry(
                record: recordById[metric.recordId]!,
                metric: metric,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) {
            final dateComparison = b.record.localDate.compareTo(
              a.record.localDate,
            );
            if (dateComparison != 0) {
              return dateComparison;
            }
            final recordComparison = b.record.createdAt.compareTo(
              a.record.createdAt,
            );
            if (recordComparison != 0) {
              return recordComparison;
            }
            return b.metric.createdAt.compareTo(a.metric.createdAt);
          });

    return HabitMetricSummary(
      totals: totals,
      recentEntries: recentEntries.take(recentLimit).toList(growable: false),
    );
  }

  HabitRecordAttachment? attachmentForRecord(String recordId) {
    final attachments = attachmentsForRecord(recordId);
    return attachments.isEmpty ? null : attachments.first;
  }

  List<HabitRecordAttachment> attachmentsForRecord(String recordId) {
    final record = _recordById(recordId);
    if (record == null) {
      return const <HabitRecordAttachment>[];
    }

    final attachments = _attachments
        .where(
          (attachment) =>
              attachment.recordId == recordId &&
              attachment.habitId == record.habitId,
        )
        .toList(growable: false);
    attachments.sort((a, b) {
      final createdComparison = a.createdAt.compareTo(b.createdAt);
      if (createdComparison != 0) {
        return createdComparison;
      }
      return a.id.compareTo(b.id);
    });
    return attachments;
  }

  List<HabitActivityDay> recentActivityDays(HabitItem habit, {int days = 7}) {
    final today = _dateOnly(_nowProvider().toLocal());

    return List<HabitActivityDay>.generate(days, (index) {
      final date = today.subtract(Duration(days: days - index - 1));
      final localDate = _localDayKey(date);

      return HabitActivityDay(
        localDate: localDate,
        count: activityCountOn(habit, localDate),
      );
    }, growable: false);
  }

  List<HabitActivityMonth> recentActivityMonths(
    HabitItem habit, {
    int months = 3,
  }) {
    if (months <= 0) {
      return const <HabitActivityMonth>[];
    }

    final currentLocalDate = _nowProvider().toLocal();
    final firstMonth = DateTime(
      currentLocalDate.year,
      currentLocalDate.month - months + 1,
    );

    return List<HabitActivityMonth>.generate(months, (index) {
      final monthDate = DateTime(firstMonth.year, firstMonth.month + index);
      return _activityMonthFor(
        habit,
        year: monthDate.year,
        month: monthDate.month,
      );
    }, growable: false);
  }

  HabitActivityMonth currentMonthActivity(HabitItem habit) {
    final currentLocalDate = _nowProvider().toLocal();
    return _activityMonthFor(
      habit,
      year: currentLocalDate.year,
      month: currentLocalDate.month,
    );
  }

  HabitAnnualActivity currentYearActivity(HabitItem habit) {
    final year = _nowProvider().toLocal().year;
    final start = DateTime(year);
    final dayCount = DateTime(year + 1).difference(start).inDays;

    return HabitAnnualActivity(
      year: year,
      days: List<HabitActivityDay>.generate(dayCount, (index) {
        final date = start.add(Duration(days: index));
        final localDate = _localDayKey(date);

        return HabitActivityDay(
          localDate: localDate,
          count: activityCountOn(habit, localDate),
        );
      }, growable: false),
    );
  }

  HabitActivityMonth _activityMonthFor(
    HabitItem habit, {
    required int year,
    required int month,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return HabitActivityMonth(
      year: year,
      month: month,
      days: List<HabitActivityDay>.generate(daysInMonth, (index) {
        final date = DateTime(year, month, index + 1);
        final localDate = _localDayKey(date);

        return HabitActivityDay(
          localDate: localDate,
          count: activityCountOn(habit, localDate),
        );
      }, growable: false),
    );
  }

  Future<HabitItem?> createHabit(
    String name, {
    String emoji = HabitItem.defaultEmoji,
    String description = '',
    int targetCountPerDay = HabitItem.defaultTargetCountPerDay,
    String? reminderTime,
    List<HabitReminderRule>? reminderRules,
    int? habitColorValue,
    HabitPlanLink? planLink,
    List<HabitCheckInTemplateDraft> checkInTemplates = const [],
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return null;
    }

    final normalizedEmoji = emoji.trim().isEmpty
        ? HabitItem.defaultEmoji
        : emoji.trim();
    final normalizedHabitColorValue = _normalizeHabitColorValue(
      habitColorValue,
    );
    final habitId = 'habit-${_nextHabitId++}';
    final now = _nowProvider();
    final normalizedReminderRules = _normalizeReminderRules(
      habitId: habitId,
      createdAt: now,
      reminderTime: reminderTime,
      reminderRules: reminderRules,
    );

    final habit = HabitItem(
      id: habitId,
      name: trimmedName,
      emoji: normalizedEmoji,
      description: description.trim(),
      targetCountPerDay: targetCountPerDay < 1
          ? HabitItem.defaultTargetCountPerDay
          : targetCountPerDay,
      reminderTime: _legacyReminderTimeForRules(normalizedReminderRules),
      reminderRules: normalizedReminderRules,
      habitColorValue: normalizedHabitColorValue,
      planLink: _normalizePlanLink(planLink, now),
      createdAt: now,
    );

    _habits.insert(0, habit);
    _checkInTemplates.addAll(
      _buildTemplatesForHabit(
        habitId: habit.id,
        drafts: checkInTemplates,
        createdAt: now,
      ),
    );
    notifyListeners();

    await _persistSnapshot();
    await _syncReminderForHabit(habit, requestPermission: true);
    return habit;
  }

  Future<bool> updateHabit(
    String id, {
    required String name,
    String emoji = HabitItem.defaultEmoji,
    String description = '',
    required int targetCountPerDay,
    String? reminderTime,
    List<HabitReminderRule>? reminderRules,
    int? habitColorValue,
    bool clearHabitColorValue = false,
    HabitPlanLink? planLink,
    bool clearPlanLink = false,
  }) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == id);
    final trimmedName = name.trim();
    if (habitIndex == -1 || trimmedName.isEmpty || targetCountPerDay < 1) {
      return false;
    }

    final normalizedEmoji = emoji.trim().isEmpty
        ? HabitItem.defaultEmoji
        : emoji.trim();
    final normalizedHabitColorValue = _normalizeHabitColorValue(
      habitColorValue,
    );
    final currentHabit = _habits[habitIndex];
    if (currentHabit.isDeleted) {
      return false;
    }
    final normalizedReminderRules = _normalizeReminderRules(
      habitId: currentHabit.id,
      createdAt: _nowProvider(),
      reminderTime: reminderTime,
      reminderRules: reminderRules,
    );

    final updatedHabit = currentHabit.copyWith(
      name: trimmedName,
      emoji: normalizedEmoji,
      description: description.trim(),
      targetCountPerDay: targetCountPerDay,
      reminderTime: _legacyReminderTimeForRules(normalizedReminderRules),
      clearReminderTime: normalizedReminderRules.isEmpty,
      reminderRules: normalizedReminderRules,
      habitColorValue: normalizedHabitColorValue,
      clearHabitColorValue: clearHabitColorValue,
      planLink: _normalizePlanLink(planLink, _nowProvider()),
      clearPlanLink: clearPlanLink,
    );
    _habits[habitIndex] = updatedHabit;
    notifyListeners();

    await _persistSnapshot();
    await _syncReminderForHabit(updatedHabit, requestPermission: true);
    return true;
  }

  Future<HabitCheckInTemplate?> addCheckInTemplate(
    String habitId, {
    required String title,
    required String unit,
    double? defaultValue,
  }) async {
    final habit = _habitById(habitId);
    final normalizedTitle = title.trim();
    final normalizedUnit = unit.trim();
    final normalizedDefaultValue = _normalizeOptionalMetricValue(defaultValue);
    if (habit == null ||
        habit.isDeleted ||
        normalizedTitle.isEmpty ||
        normalizedUnit.isEmpty ||
        activeTemplateCountForHabit(habit) >= maxCheckInTemplatesPerHabit) {
      return null;
    }

    final now = _nowProvider();
    final template = HabitCheckInTemplate(
      id: 'habit-template-${_nextTemplateId++}',
      habitId: habit.id,
      title: normalizedTitle,
      unit: normalizedUnit,
      defaultValue: normalizedDefaultValue,
      sortOrder: _nextTemplateSortOrder(habit.id),
      isArchived: false,
      createdAt: now,
    );
    _checkInTemplates.add(template);
    notifyListeners();

    await _persistSnapshot();
    return template;
  }

  Future<bool> updateCheckInTemplate(
    String templateId, {
    required String title,
    required String unit,
    double? defaultValue,
    bool clearDefaultValue = false,
  }) async {
    final templateIndex = _checkInTemplates.indexWhere(
      (template) => template.id == templateId,
    );
    final normalizedTitle = title.trim();
    final normalizedUnit = unit.trim();
    if (templateIndex == -1 ||
        normalizedTitle.isEmpty ||
        normalizedUnit.isEmpty) {
      return false;
    }

    final currentTemplate = _checkInTemplates[templateIndex];
    final habit = _habitById(currentTemplate.habitId);
    if (habit == null || habit.isDeleted) {
      return false;
    }

    _checkInTemplates[templateIndex] = currentTemplate.copyWith(
      title: normalizedTitle,
      unit: normalizedUnit,
      defaultValue: _normalizeOptionalMetricValue(defaultValue),
      clearDefaultValue: clearDefaultValue,
      updatedAt: _nowProvider(),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> archiveCheckInTemplate(String templateId) async {
    return _setCheckInTemplateArchived(templateId, isArchived: true);
  }

  Future<bool> restoreCheckInTemplate(String templateId) async {
    final template = _templateById(templateId);
    if (template == null) {
      return false;
    }
    final habit = _habitById(template.habitId);
    if (habit == null ||
        activeTemplateCountForHabit(habit) >= maxCheckInTemplatesPerHabit) {
      return false;
    }
    return _setCheckInTemplateArchived(templateId, isArchived: false);
  }

  int activeTemplateCountForHabit(HabitItem habit) {
    return _checkInTemplates
        .where(
          (template) => template.habitId == habit.id && !template.isArchived,
        )
        .length;
  }

  Future<bool> updateHabitPlanLink(String id, HabitPlanLink? planLink) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == id);
    if (habitIndex == -1) {
      return false;
    }

    final currentHabit = _habits[habitIndex];
    if (currentHabit.isDeleted) {
      return false;
    }

    _habits[habitIndex] = currentHabit.copyWith(
      planLink: _normalizePlanLink(planLink, _nowProvider()),
      clearPlanLink: planLink == null,
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateHabitReminder(String id, String? reminderTime) async {
    final habit = _habitById(id);
    if (habit == null) {
      return false;
    }

    return updateHabitReminderRules(
      id,
      _normalizeReminderRules(
        habitId: id,
        createdAt: _nowProvider(),
        reminderTime: reminderTime,
      ),
    );
  }

  Future<bool> updateHabitReminderRules(
    String id,
    List<HabitReminderRule> reminderRules,
  ) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == id);
    if (habitIndex == -1) {
      return false;
    }

    final currentHabit = _habits[habitIndex];
    if (currentHabit.isDeleted) {
      return false;
    }
    final normalizedReminderRules = _normalizeReminderRules(
      habitId: currentHabit.id,
      createdAt: _nowProvider(),
      reminderRules: reminderRules,
    );
    final updatedHabit = currentHabit.copyWith(
      reminderTime: _legacyReminderTimeForRules(normalizedReminderRules),
      clearReminderTime: normalizedReminderRules.isEmpty,
      reminderRules: normalizedReminderRules,
    );

    _habits[habitIndex] = updatedHabit;
    notifyListeners();

    await _persistSnapshot();
    await _syncReminderForHabit(updatedHabit, requestPermission: true);
    return true;
  }

  Future<bool> pauseHabit(String id) async {
    final habit = _habitById(id);
    if (habit == null || !habit.isActive) {
      return false;
    }
    final now = _nowProvider();

    return _setHabitLifecycle(
      id,
      status: HabitLifecycleStatus.paused,
      pausedAt: now.toUtc(),
      clearArchivedAt: true,
      clearDeletedAt: true,
      pauseIntervals: _pauseIntervalsWithOpenInterval(habit, now),
    );
  }

  Future<bool> restoreHabit(String id) async {
    final habit = _habitById(id);
    if (habit == null || (!habit.isPaused && !habit.isArchived)) {
      return false;
    }
    final now = _nowProvider();

    return _setHabitLifecycle(
      id,
      status: HabitLifecycleStatus.active,
      clearPausedAt: true,
      clearArchivedAt: true,
      clearDeletedAt: true,
      pauseIntervals: _pauseIntervalsWithClosedOpenIntervals(habit, now),
    );
  }

  Future<bool> archiveHabit(String id) async {
    final habit = _habitById(id);
    if (habit == null || habit.isArchived || habit.isDeleted) {
      return false;
    }
    final now = _nowProvider();

    return _setHabitLifecycle(
      id,
      status: HabitLifecycleStatus.archived,
      archivedAt: now.toUtc(),
      clearPausedAt: true,
      clearDeletedAt: true,
      pauseIntervals: _pauseIntervalsWithClosedOpenIntervals(habit, now),
    );
  }

  Future<bool> softDeleteHabit(String id, {required bool confirmed}) async {
    final habit = _habitById(id);
    if (!confirmed || habit == null || habit.isDeleted) {
      return false;
    }
    final now = _nowProvider();

    return _setHabitLifecycle(
      id,
      status: HabitLifecycleStatus.deleted,
      deletedAt: now.toUtc(),
      clearPausedAt: true,
      clearArchivedAt: true,
      pauseIntervals: _pauseIntervalsWithClosedOpenIntervals(habit, now),
    );
  }

  Future<void> checkIn(
    String id, {
    String? note,
    List<HabitRecordMetricInput> metricInputs = const [],
  }) async {
    await _createHabitRecord(
      habitId: id,
      type: HabitRecordType.checkIn,
      localDate: _currentDayKey,
      note: note,
      metricInputs: metricInputs,
    );
  }

  Future<bool> skipHabit(String id, {String? localDate, String? note}) async {
    final normalizedDate = _normalizeLocalDate(localDate ?? _currentDayKey);
    final habit = _habitById(id);
    if (normalizedDate == null || habit == null || !habit.isActive) {
      return false;
    }
    if (normalizedDate.compareTo(_currentDayKey) > 0) {
      return false;
    }
    if (_effectiveRecordCountOn(id, normalizedDate) > 0) {
      return false;
    }

    _records.removeWhere(
      (record) =>
          record.habitId == id &&
          record.localDate == normalizedDate &&
          record.type == HabitRecordType.skip,
    );

    return _createHabitRecord(
      habitId: id,
      type: HabitRecordType.skip,
      localDate: normalizedDate,
      note: note,
    );
  }

  Future<bool> makeupCheckIn(
    String id, {
    required String localDate,
    String? note,
    List<HabitRecordMetricInput> metricInputs = const [],
  }) async {
    final normalizedDate = _normalizeLocalDate(localDate);
    if (normalizedDate == null) {
      return false;
    }
    if (normalizedDate.compareTo(_currentDayKey) >= 0) {
      return false;
    }

    return _createHabitRecord(
      habitId: id,
      type: HabitRecordType.makeup,
      localDate: normalizedDate,
      note: note,
      metricInputs: metricInputs,
    );
  }

  Future<bool> _createHabitRecord({
    required String habitId,
    required HabitRecordType type,
    required String localDate,
    String? note,
    List<HabitRecordMetricInput> metricInputs = const [],
  }) async {
    final habit = _habitById(habitId);
    if (habit == null || !habit.isActive) {
      return false;
    }

    final normalizedDate = _normalizeLocalDate(localDate);
    if (normalizedDate == null) {
      return false;
    }

    final normalizedNote = _normalizeNote(note);
    final previousEffectiveCount = _countsTowardCompletionType(type)
        ? _effectiveRecordCountOn(habitId, normalizedDate)
        : 0;
    final createdAt = _nowProvider().toUtc();
    final record = HabitRecord(
      id: 'habit-record-${_nextRecordId++}',
      habitId: habitId,
      localDate: normalizedDate,
      type: type,
      note: normalizedNote,
      createdAt: createdAt,
    );
    final metrics = _countsTowardCompletionType(type)
        ? _buildMetricRecords(
            habit: habit,
            record: record,
            inputs: metricInputs,
            createdAt: createdAt,
          )
        : const <HabitRecordMetric>[];

    _records.insert(0, record);
    _recordMetrics.insertAll(0, metrics);
    notifyListeners();

    await _persistSnapshot();
    final effectiveCount = _countsTowardCompletionType(type)
        ? previousEffectiveCount + 1
        : previousEffectiveCount;
    if (_countsTowardCompletionType(type) &&
        previousEffectiveCount < habit.targetCountPerDay &&
        effectiveCount >= habit.targetCountPerDay) {
      await _syncLinkedPlanRecordAfterCompletion(
        habit: habit,
        localDate: normalizedDate,
        effectiveCount: effectiveCount,
      );
    }
    return true;
  }

  Future<void> toggleCompleted(String id) {
    return checkIn(id);
  }

  Future<HabitRecordAttachment?> replaceRecordAttachment({
    required String recordId,
    required String relativePath,
    required String fileName,
    String? mimeType,
  }) async {
    final record = _recordById(recordId);
    final trimmedRelativePath = relativePath.trim();
    final trimmedFileName = fileName.trim();
    final trimmedMimeType = mimeType?.trim();
    if (record == null ||
        trimmedRelativePath.isEmpty ||
        trimmedFileName.isEmpty) {
      return null;
    }

    HabitRecordAttachment? replacedAttachment;
    _attachments.removeWhere((attachment) {
      final matches = attachment.recordId == recordId;
      if (matches && replacedAttachment == null) {
        replacedAttachment = attachment;
      }
      return matches;
    });

    _attachments.insert(
      0,
      HabitRecordAttachment(
        id: 'habit-attachment-${_nextAttachmentId++}',
        recordId: recordId,
        habitId: record.habitId,
        relativePath: trimmedRelativePath,
        fileName: trimmedFileName,
        mimeType: trimmedMimeType == null || trimmedMimeType.isEmpty
            ? null
            : trimmedMimeType,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
    return replacedAttachment;
  }

  Future<HabitRecordAttachment?> addRecordAttachment({
    required String recordId,
    required String relativePath,
    required String fileName,
    String? mimeType,
  }) async {
    final record = _recordById(recordId);
    final trimmedRelativePath = relativePath.trim();
    final trimmedFileName = fileName.trim();
    final trimmedMimeType = mimeType?.trim();
    if (record == null ||
        trimmedRelativePath.isEmpty ||
        trimmedFileName.isEmpty ||
        attachmentsForRecord(recordId).length >= maxAttachmentsPerRecord) {
      return null;
    }

    final attachment = HabitRecordAttachment(
      id: 'habit-attachment-${_nextAttachmentId++}',
      recordId: recordId,
      habitId: record.habitId,
      relativePath: trimmedRelativePath,
      fileName: trimmedFileName,
      mimeType: trimmedMimeType == null || trimmedMimeType.isEmpty
          ? null
          : trimmedMimeType,
      createdAt: _nowProvider().toUtc(),
    );

    _attachments.insert(0, attachment);
    notifyListeners();

    await _persistSnapshot();
    return attachment;
  }

  Future<HabitRecordAttachment?> replaceRecordAttachmentById({
    required String attachmentId,
    required String relativePath,
    required String fileName,
    String? mimeType,
  }) async {
    final attachmentIndex = _attachments.indexWhere(
      (attachment) => attachment.id == attachmentId,
    );
    final trimmedRelativePath = relativePath.trim();
    final trimmedFileName = fileName.trim();
    final trimmedMimeType = mimeType?.trim();
    if (attachmentIndex == -1 ||
        trimmedRelativePath.isEmpty ||
        trimmedFileName.isEmpty) {
      return null;
    }

    final oldAttachment = _attachments[attachmentIndex];
    final record = _recordById(oldAttachment.recordId);
    if (record == null || record.habitId != oldAttachment.habitId) {
      return null;
    }

    _attachments[attachmentIndex] = HabitRecordAttachment(
      id: 'habit-attachment-${_nextAttachmentId++}',
      recordId: oldAttachment.recordId,
      habitId: oldAttachment.habitId,
      relativePath: trimmedRelativePath,
      fileName: trimmedFileName,
      mimeType: trimmedMimeType == null || trimmedMimeType.isEmpty
          ? null
          : trimmedMimeType,
      createdAt: _nowProvider().toUtc(),
    );
    notifyListeners();

    await _persistSnapshot();
    return oldAttachment;
  }

  Future<HabitRecordAttachment?> removeRecordAttachment(String recordId) async {
    HabitRecordAttachment? removedAttachment;
    _attachments.removeWhere((attachment) {
      final matches = attachment.recordId == recordId;
      if (matches && removedAttachment == null) {
        removedAttachment = attachment;
      }
      return matches;
    });

    if (removedAttachment == null) {
      return null;
    }

    notifyListeners();

    await _persistSnapshot();
    return removedAttachment;
  }

  Future<HabitRecordAttachment?> removeRecordAttachmentById(
    String attachmentId,
  ) async {
    final attachmentIndex = _attachments.indexWhere(
      (attachment) => attachment.id == attachmentId,
    );
    if (attachmentIndex == -1) {
      return null;
    }

    final removedAttachment = _attachments.removeAt(attachmentIndex);
    notifyListeners();

    await _persistSnapshot();
    return removedAttachment;
  }

  Future<bool> _setHabitLifecycle(
    String id, {
    required HabitLifecycleStatus status,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    List<HabitPauseInterval>? pauseIntervals,
  }) async {
    final habitIndex = _habits.indexWhere((habit) => habit.id == id);
    if (habitIndex == -1) {
      return false;
    }

    final updatedHabit = _habits[habitIndex].copyWith(
      status: status,
      pausedAt: pausedAt,
      clearPausedAt: clearPausedAt,
      archivedAt: archivedAt,
      clearArchivedAt: clearArchivedAt,
      deletedAt: deletedAt,
      clearDeletedAt: clearDeletedAt,
      pauseIntervals: pauseIntervals,
    );

    _habits[habitIndex] = updatedHabit;
    notifyListeners();

    await _persistSnapshot();
    await _syncReminderForHabit(updatedHabit, requestPermission: true);

    return true;
  }

  List<HabitPauseInterval> _pauseIntervalsWithOpenInterval(
    HabitItem habit,
    DateTime now,
  ) {
    if (habit.pauseIntervals.any((interval) => interval.isOpen)) {
      return habit.pauseIntervals;
    }

    return [
      ...habit.pauseIntervals,
      HabitPauseInterval(
        id: 'habit-pause-${habit.id}-${now.toUtc().millisecondsSinceEpoch}',
        startedAt: now.toUtc(),
        startLocalDate: _localDayKey(now),
      ),
    ];
  }

  List<HabitPauseInterval> _pauseIntervalsWithClosedOpenIntervals(
    HabitItem habit,
    DateTime now,
  ) {
    final endLocalDate = _localDayKey(now);

    return habit.pauseIntervals
        .map(
          (interval) => interval.isOpen
              ? interval.copyWith(
                  endedAt: now.toUtc(),
                  endLocalDate: endLocalDate,
                )
              : interval,
        )
        .toList(growable: false);
  }

  static bool _countsTowardCompletion(HabitRecord record) {
    return _countsTowardCompletionType(record.type);
  }

  static bool _countsTowardCompletionType(HabitRecordType type) {
    return type == HabitRecordType.checkIn || type == HabitRecordType.makeup;
  }

  int _effectiveRecordCountOn(String habitId, String localDate) {
    return _records
        .where(
          (record) =>
              record.habitId == habitId &&
              record.localDate == localDate &&
              _countsTowardCompletion(record),
        )
        .length;
  }

  List<HabitCheckInTemplate> _buildTemplatesForHabit({
    required String habitId,
    required List<HabitCheckInTemplateDraft> drafts,
    required DateTime createdAt,
  }) {
    final templates = <HabitCheckInTemplate>[];
    for (final draft in drafts) {
      if (templates.length >= maxCheckInTemplatesPerHabit) {
        break;
      }
      final title = draft.title.trim();
      final unit = draft.unit.trim();
      if (title.isEmpty || unit.isEmpty) {
        continue;
      }

      templates.add(
        HabitCheckInTemplate(
          id: 'habit-template-${_nextTemplateId++}',
          habitId: habitId,
          title: title,
          unit: unit,
          defaultValue: _normalizeOptionalMetricValue(draft.defaultValue),
          sortOrder: templates.length,
          isArchived: false,
          createdAt: createdAt,
        ),
      );
    }
    return templates;
  }

  List<HabitRecordMetric> _buildMetricRecords({
    required HabitItem habit,
    required HabitRecord record,
    required List<HabitRecordMetricInput> inputs,
    required DateTime createdAt,
  }) {
    if (inputs.isEmpty) {
      return const <HabitRecordMetric>[];
    }

    final templatesById = <String, HabitCheckInTemplate>{
      for (final template in _checkInTemplates)
        if (template.habitId == habit.id && !template.isArchived)
          template.id: template,
    };
    final metrics = <HabitRecordMetric>[];
    final seenTemplateIds = <String>{};

    for (final input in inputs) {
      if (!input.numericValue.isFinite || input.numericValue <= 0) {
        continue;
      }
      final template = templatesById[input.templateId];
      if (template == null || !seenTemplateIds.add(template.id)) {
        continue;
      }

      metrics.add(
        HabitRecordMetric(
          id: 'habit-metric-${_nextMetricId++}',
          recordId: record.id,
          habitId: habit.id,
          templateId: template.id,
          titleSnapshot: template.title,
          unitSnapshot: template.unit,
          numericValue: input.numericValue,
          createdAt: createdAt,
        ),
      );
    }

    return metrics;
  }

  Future<bool> _setCheckInTemplateArchived(
    String templateId, {
    required bool isArchived,
  }) async {
    final templateIndex = _checkInTemplates.indexWhere(
      (template) => template.id == templateId,
    );
    if (templateIndex == -1) {
      return false;
    }

    final template = _checkInTemplates[templateIndex];
    final habit = _habitById(template.habitId);
    if (habit == null || habit.isDeleted) {
      return false;
    }

    _checkInTemplates[templateIndex] = template.copyWith(
      isArchived: isArchived,
      updatedAt: _nowProvider(),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  int _nextTemplateSortOrder(String habitId) {
    final matchingTemplates = _checkInTemplates
        .where((template) => template.habitId == habitId)
        .toList(growable: false);
    if (matchingTemplates.isEmpty) {
      return 0;
    }
    return matchingTemplates
            .map((template) => template.sortOrder)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  HabitCheckInTemplate? _templateById(String templateId) {
    for (final template in _checkInTemplates) {
      if (template.id == templateId) {
        return template;
      }
    }

    return null;
  }

  HabitRecord? _recordById(String recordId) {
    for (final record in _records) {
      if (record.id == recordId) {
        return record;
      }
    }

    return null;
  }

  HabitItem? _habitById(String habitId) {
    for (final habit in _habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }

    return null;
  }

  static String? _normalizeLocalDate(String value) {
    final text = value.trim();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) {
      return null;
    }

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) {
      return null;
    }

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    return text;
  }

  static String? _normalizeNote(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static double? _normalizeOptionalMetricValue(double? value) {
    if (value == null || !value.isFinite || value < 0) {
      return null;
    }
    return value;
  }

  HabitPlanLink? _normalizePlanLink(HabitPlanLink? link, DateTime now) {
    if (link == null) {
      return null;
    }

    final titleSnapshot = link.titleSnapshot.trim();
    final projectId = link.projectId.trim();
    final taskId = link.taskId?.trim();
    final contextSnapshot = link.contextSnapshot?.trim();

    if (projectId.isEmpty || titleSnapshot.isEmpty) {
      return null;
    }
    if (link.targetType == HabitPlanLinkTargetType.task &&
        (taskId == null || taskId.isEmpty)) {
      return null;
    }

    return link.copyWith(
      projectId: projectId,
      taskId: link.targetType == HabitPlanLinkTargetType.task ? taskId : null,
      clearTaskId: link.targetType == HabitPlanLinkTargetType.project,
      titleSnapshot: titleSnapshot,
      contextSnapshot: contextSnapshot == null || contextSnapshot.isEmpty
          ? null
          : contextSnapshot,
      clearContextSnapshot: contextSnapshot == null || contextSnapshot.isEmpty,
      createdAt: link.createdAt.toUtc(),
      updatedAt: now.toUtc(),
    );
  }

  Future<void> _syncLinkedPlanRecordAfterCompletion({
    required HabitItem habit,
    required String localDate,
    required int effectiveCount,
  }) async {
    if (habit.planLink == null) {
      return;
    }

    try {
      await _planRecordWriter.recordDailyCompletion(
        habit: habit,
        localDate: localDate,
        effectiveCount: effectiveCount,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habits_store',
          context: ErrorDescription(
            'while creating a linked plan record for a completed habit',
          ),
        ),
      );
    }
  }

  Future<void> _persistSnapshot() async {
    final snapshot = HabitsSnapshot(
      habits: List<HabitItem>.of(_habits),
      records: List<HabitRecord>.of(_records),
      attachments: List<HabitRecordAttachment>.of(_attachments),
      checkInTemplates: List<HabitCheckInTemplate>.of(_checkInTemplates),
      recordMetrics: List<HabitRecordMetric>.of(_recordMetrics),
    );

    try {
      await _storage.saveSnapshot(snapshot);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habits_store',
          context: ErrorDescription('while persisting habits locally'),
        ),
      );
    }
  }

  Future<void> _resyncRemindersOnStartup() async {
    try {
      await _reminderNotificationService.resyncReminders(
        List<HabitItem>.of(_habits),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habits_store',
          context: ErrorDescription('while syncing habit reminders on startup'),
        ),
      );
    }
  }

  Future<void> _syncReminderForHabit(
    HabitItem habit, {
    required bool requestPermission,
  }) async {
    try {
      if (!habit.isActive || habit.enabledReminderRules.isEmpty) {
        await _reminderNotificationService.cancelReminder(habit.id);
        return;
      }

      await _reminderNotificationService.scheduleDailyReminder(
        habit,
        requestPermission: requestPermission,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habits_store',
          context: ErrorDescription('while syncing a habit reminder'),
        ),
      );
    }
  }

  String get _currentDayKey => _localDayKey(_nowProvider());

  static List<HabitItem> _buildSeedHabits(HabitNowProvider nowProvider) {
    final now = nowProvider();

    return [
      HabitItem(
        id: 'habit-1',
        name: 'Drink water',
        emoji: '💧',
        description: '',
        targetCountPerDay: 1,
        reminderTime: null,
        habitColorValue: null,
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      HabitItem(
        id: 'habit-2',
        name: 'Read 20 min',
        emoji: '📖',
        description: '',
        targetCountPerDay: 1,
        reminderTime: null,
        habitColorValue: null,
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      HabitItem(
        id: 'habit-3',
        name: 'Walk 30 min',
        emoji: '🚶',
        description: '',
        targetCountPerDay: 1,
        reminderTime: null,
        habitColorValue: null,
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  static int _deriveNextId(List<HabitItem> habits) {
    final matcher = RegExp(r'^habit-(\d+)$');

    final maxId = habits.fold<int>(0, (currentMax, habit) {
      final match = matcher.firstMatch(habit.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static int _deriveNextRecordId(List<HabitRecord> records) {
    final matcher = RegExp(r'^habit-record-(\d+)$');

    final maxId = records.fold<int>(0, (currentMax, record) {
      final match = matcher.firstMatch(record.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static int _deriveNextAttachmentId(List<HabitRecordAttachment> attachments) {
    final matcher = RegExp(r'^habit-attachment-(\d+)$');

    final maxId = attachments.fold<int>(0, (currentMax, attachment) {
      final match = matcher.firstMatch(attachment.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static int _deriveNextTemplateId(List<HabitCheckInTemplate> templates) {
    final matcher = RegExp(r'^habit-template-(\d+)$');

    final maxId = templates.fold<int>(0, (currentMax, template) {
      final match = matcher.firstMatch(template.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static int _deriveNextMetricId(List<HabitRecordMetric> metrics) {
    final matcher = RegExp(r'^habit-metric-(\d+)$');

    final maxId = metrics.fold<int>(0, (currentMax, metric) {
      final match = matcher.firstMatch(metric.id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  static int _compareTemplates(
    HabitCheckInTemplate first,
    HabitCheckInTemplate second,
  ) {
    final orderComparison = first.sortOrder.compareTo(second.sortOrder);
    if (orderComparison != 0) {
      return orderComparison;
    }
    final dateComparison = first.createdAt.compareTo(second.createdAt);
    if (dateComparison != 0) {
      return dateComparison;
    }
    return first.id.compareTo(second.id);
  }

  static String _localDayKey(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String? _normalizeReminderTime(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
    final hour = int.tryParse(match?.group(1) ?? '');
    final minute = int.tryParse(match?.group(2) ?? '');

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return text;
  }

  static List<HabitReminderRule> _normalizeReminderRules({
    required String habitId,
    required DateTime createdAt,
    String? reminderTime,
    List<HabitReminderRule>? reminderRules,
  }) {
    if (reminderRules == null) {
      final normalizedReminderTime = _normalizeReminderTime(reminderTime);
      if (normalizedReminderTime == null) {
        return const <HabitReminderRule>[];
      }

      return [
        HabitReminderRule.fromLegacyReminderTime(
          habitId: habitId,
          time: normalizedReminderTime,
          createdAt: createdAt,
        ),
      ];
    }

    final normalizedRules = <HabitReminderRule>[];
    for (final rule in reminderRules) {
      if (normalizedRules.length >= HabitReminderRule.maxRulesPerHabit) {
        break;
      }

      final normalizedTime = _normalizeReminderTime(rule.time);
      final normalizedWeekdays = _normalizeWeekdays(rule.weekdays);
      if (normalizedTime == null || normalizedWeekdays.isEmpty) {
        continue;
      }

      normalizedRules.add(
        rule.copyWith(
          id: _normalizeReminderRuleId(
            habitId: habitId,
            index: normalizedRules.length,
            rule: rule,
          ),
          time: normalizedTime,
          weekdays: normalizedWeekdays,
          createdAt: rule.createdAt.toUtc(),
        ),
      );
    }

    return normalizedRules;
  }

  static List<int> _normalizeWeekdays(List<int> weekdays) {
    final normalizedWeekdays = <int>{};
    for (final weekday in weekdays) {
      if (weekday >= 1 && weekday <= 7) {
        normalizedWeekdays.add(weekday);
      }
    }

    return normalizedWeekdays.toList(growable: false)..sort();
  }

  static String _normalizeReminderRuleId({
    required String habitId,
    required int index,
    required HabitReminderRule rule,
  }) {
    final trimmedId = rule.id.trim();
    if (trimmedId.isNotEmpty &&
        !trimmedId.startsWith('habit-reminder-draft-')) {
      return trimmedId;
    }

    return 'habit-reminder-$habitId-${index + 1}-${rule.createdAt.toUtc().millisecondsSinceEpoch}';
  }

  static String? _legacyReminderTimeForRules(List<HabitReminderRule> rules) {
    for (final rule in rules) {
      if (rule.isEnabled) {
        return rule.time;
      }
    }

    return null;
  }

  static int? _normalizeHabitColorValue(int? value) {
    if (value == null || value < 0 || value > 0xFFFFFFFF) {
      return null;
    }

    return value;
  }
}

class _MetricAccumulator {
  _MetricAccumulator({required this.title, required this.unit});

  final String title;
  final String unit;
  double total = 0;
  int entryCount = 0;

  void add(double value) {
    total += value;
    entryCount += 1;
  }
}

class _InMemoryHabitsStorage implements HabitsStorage {
  @override
  Future<HabitsSnapshot?> loadSnapshot({
    required String migrationDateKey,
  }) async {
    return null;
  }

  @override
  Future<void> saveSnapshot(HabitsSnapshot snapshot) async {}
}
