import 'dart:convert';

import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_check_in_template.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_metric.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitsSnapshot {
  const HabitsSnapshot({
    required this.habits,
    required this.records,
    this.attachments = const <HabitRecordAttachment>[],
    this.checkInTemplates = const <HabitCheckInTemplate>[],
    this.recordMetrics = const <HabitRecordMetric>[],
    this.shouldPersistAfterLoad = false,
  });

  const HabitsSnapshot.empty()
    : habits = const <HabitItem>[],
      records = const <HabitRecord>[],
      attachments = const <HabitRecordAttachment>[],
      checkInTemplates = const <HabitCheckInTemplate>[],
      recordMetrics = const <HabitRecordMetric>[],
      shouldPersistAfterLoad = false;

  final List<HabitItem> habits;
  final List<HabitRecord> records;
  final List<HabitRecordAttachment> attachments;
  final List<HabitCheckInTemplate> checkInTemplates;
  final List<HabitRecordMetric> recordMetrics;
  final bool shouldPersistAfterLoad;

  HabitsSnapshot copyWith({
    List<HabitItem>? habits,
    List<HabitRecord>? records,
    List<HabitRecordAttachment>? attachments,
    List<HabitCheckInTemplate>? checkInTemplates,
    List<HabitRecordMetric>? recordMetrics,
    bool? shouldPersistAfterLoad,
  }) {
    return HabitsSnapshot(
      habits: habits ?? this.habits,
      records: records ?? this.records,
      attachments: attachments ?? this.attachments,
      checkInTemplates: checkInTemplates ?? this.checkInTemplates,
      recordMetrics: recordMetrics ?? this.recordMetrics,
      shouldPersistAfterLoad:
          shouldPersistAfterLoad ?? this.shouldPersistAfterLoad,
    );
  }
}

abstract class HabitsStorage {
  Future<HabitsSnapshot?> loadSnapshot({required String migrationDateKey});

  Future<void> saveSnapshot(HabitsSnapshot snapshot);
}

abstract interface class HabitsKeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

class HabitsLocalStorage implements HabitsStorage {
  HabitsLocalStorage({HabitsKeyValueStore? store})
    : _store = store ?? _SharedPreferencesAsyncStore();

  static const storageKey = 'habits.local.json';
  static const recordsStorageKey = 'habits.records.local.json';
  static const attachmentsStorageKey = 'habits.record.attachments.local.json';
  static const templatesStorageKey = 'habits.checkin.templates.local.json';
  static const metricsStorageKey = 'habits.record.metrics.local.json';

  final HabitsKeyValueStore _store;

  @override
  Future<HabitsSnapshot?> loadSnapshot({
    required String migrationDateKey,
  }) async {
    final habitsPayload = await _store.getString(storageKey);
    if (habitsPayload == null || habitsPayload.isEmpty) {
      return null;
    }

    var shouldPersistAfterLoad = false;
    final habits = <HabitItem>[];
    final migratedRecords = <HabitRecord>[];

    try {
      final decodedHabits = jsonDecode(habitsPayload);
      if (decodedHabits is! List<dynamic>) {
        return const HabitsSnapshot.empty();
      }

      for (final item in decodedHabits) {
        if (item is! Map) {
          shouldPersistAfterLoad = true;
          continue;
        }

        final json = Map<String, dynamic>.from(item);
        try {
          final habit = HabitItem.fromJson(json);
          habits.add(habit);

          if (HabitItem.needsMigration(json)) {
            shouldPersistAfterLoad = true;
          }

          final legacyDate = HabitItem.legacyCompletedDateKey(
            json,
            migrationDateKey: migrationDateKey,
          );
          if (legacyDate != null) {
            migratedRecords.add(
              _buildMigratedCheckInRecord(habit: habit, localDate: legacyDate),
            );
          }
        } catch (_) {
          shouldPersistAfterLoad = true;
        }
      }
    } catch (_) {
      return const HabitsSnapshot.empty();
    }

    final recordsLoadResult = await _loadRecords();
    shouldPersistAfterLoad =
        shouldPersistAfterLoad || recordsLoadResult.shouldPersistAfterLoad;

    final attachmentsLoadResult = await _loadAttachments();
    shouldPersistAfterLoad =
        shouldPersistAfterLoad || attachmentsLoadResult.shouldPersistAfterLoad;

    final records = _mergeRecords(recordsLoadResult.records, migratedRecords);
    final recordIds = records.map((record) => record.id).toSet();
    final habitIds = habits.map((habit) => habit.id).toSet();

    final templatesLoadResult = await _loadTemplates();
    shouldPersistAfterLoad =
        shouldPersistAfterLoad || templatesLoadResult.shouldPersistAfterLoad;

    final metricsLoadResult = await _loadMetrics();
    shouldPersistAfterLoad =
        shouldPersistAfterLoad || metricsLoadResult.shouldPersistAfterLoad;

    final templates = templatesLoadResult.templates
        .where((template) => habitIds.contains(template.habitId))
        .toList(growable: false);
    if (templates.length != templatesLoadResult.templates.length) {
      shouldPersistAfterLoad = true;
    }

    final metrics = metricsLoadResult.metrics
        .where(
          (metric) =>
              habitIds.contains(metric.habitId) &&
              recordIds.contains(metric.recordId),
        )
        .toList(growable: false);
    if (metrics.length != metricsLoadResult.metrics.length) {
      shouldPersistAfterLoad = true;
    }

    if (migratedRecords.isNotEmpty) {
      shouldPersistAfterLoad = true;
    }

    return HabitsSnapshot(
      habits: habits,
      records: records,
      attachments: attachmentsLoadResult.attachments,
      checkInTemplates: templates,
      recordMetrics: metrics,
      shouldPersistAfterLoad: shouldPersistAfterLoad,
    );
  }

  @override
  Future<void> saveSnapshot(HabitsSnapshot snapshot) async {
    final habitsPayload = jsonEncode(
      snapshot.habits.map((habit) => habit.toJson()).toList(growable: false),
    );
    final recordsPayload = jsonEncode(
      snapshot.records.map((record) => record.toJson()).toList(growable: false),
    );
    final attachmentsPayload = jsonEncode(
      snapshot.attachments
          .map((attachment) => attachment.toJson())
          .toList(growable: false),
    );
    final templatesPayload = jsonEncode(
      snapshot.checkInTemplates
          .map((template) => template.toJson())
          .toList(growable: false),
    );
    final metricsPayload = jsonEncode(
      snapshot.recordMetrics
          .map((metric) => metric.toJson())
          .toList(growable: false),
    );

    await _store.setString(storageKey, habitsPayload);
    await _store.setString(recordsStorageKey, recordsPayload);
    await _store.setString(attachmentsStorageKey, attachmentsPayload);
    await _store.setString(templatesStorageKey, templatesPayload);
    await _store.setString(metricsStorageKey, metricsPayload);
  }

  Future<_RecordsLoadResult> _loadRecords() async {
    final recordsPayload = await _store.getString(recordsStorageKey);
    if (recordsPayload == null || recordsPayload.isEmpty) {
      return const _RecordsLoadResult(records: <HabitRecord>[]);
    }

    var shouldPersistAfterLoad = false;
    final records = <HabitRecord>[];

    try {
      final decodedRecords = jsonDecode(recordsPayload);
      if (decodedRecords is! List<dynamic>) {
        return const _RecordsLoadResult(
          records: <HabitRecord>[],
          shouldPersistAfterLoad: true,
        );
      }

      for (final item in decodedRecords) {
        if (item is! Map) {
          shouldPersistAfterLoad = true;
          continue;
        }

        try {
          final json = Map<String, dynamic>.from(item);
          if (!json.containsKey('type')) {
            shouldPersistAfterLoad = true;
          }

          records.add(HabitRecord.fromJson(json));
        } catch (_) {
          shouldPersistAfterLoad = true;
        }
      }
    } catch (_) {
      return const _RecordsLoadResult(
        records: <HabitRecord>[],
        shouldPersistAfterLoad: true,
      );
    }

    return _RecordsLoadResult(
      records: records,
      shouldPersistAfterLoad: shouldPersistAfterLoad,
    );
  }

  Future<_AttachmentsLoadResult> _loadAttachments() async {
    final attachmentsPayload = await _store.getString(attachmentsStorageKey);
    if (attachmentsPayload == null || attachmentsPayload.isEmpty) {
      return const _AttachmentsLoadResult(
        attachments: <HabitRecordAttachment>[],
      );
    }

    var shouldPersistAfterLoad = false;
    final attachments = <HabitRecordAttachment>[];

    try {
      final decodedAttachments = jsonDecode(attachmentsPayload);
      if (decodedAttachments is! List<dynamic>) {
        return const _AttachmentsLoadResult(
          attachments: <HabitRecordAttachment>[],
          shouldPersistAfterLoad: true,
        );
      }

      for (final item in decodedAttachments) {
        if (item is! Map) {
          shouldPersistAfterLoad = true;
          continue;
        }

        try {
          final json = Map<String, dynamic>.from(item);
          attachments.add(HabitRecordAttachment.fromJson(json));
        } catch (_) {
          shouldPersistAfterLoad = true;
        }
      }
    } catch (_) {
      return const _AttachmentsLoadResult(
        attachments: <HabitRecordAttachment>[],
        shouldPersistAfterLoad: true,
      );
    }

    return _AttachmentsLoadResult(
      attachments: attachments,
      shouldPersistAfterLoad: shouldPersistAfterLoad,
    );
  }

  Future<_TemplatesLoadResult> _loadTemplates() async {
    final templatesPayload = await _store.getString(templatesStorageKey);
    if (templatesPayload == null || templatesPayload.isEmpty) {
      return const _TemplatesLoadResult(templates: <HabitCheckInTemplate>[]);
    }

    var shouldPersistAfterLoad = false;
    final templates = <HabitCheckInTemplate>[];

    try {
      final decodedTemplates = jsonDecode(templatesPayload);
      if (decodedTemplates is! List<dynamic>) {
        return const _TemplatesLoadResult(
          templates: <HabitCheckInTemplate>[],
          shouldPersistAfterLoad: true,
        );
      }

      for (final item in decodedTemplates) {
        if (item is! Map) {
          shouldPersistAfterLoad = true;
          continue;
        }

        try {
          final json = Map<String, dynamic>.from(item);
          templates.add(HabitCheckInTemplate.fromJson(json));
        } catch (_) {
          shouldPersistAfterLoad = true;
        }
      }
    } catch (_) {
      return const _TemplatesLoadResult(
        templates: <HabitCheckInTemplate>[],
        shouldPersistAfterLoad: true,
      );
    }

    return _TemplatesLoadResult(
      templates: templates,
      shouldPersistAfterLoad: shouldPersistAfterLoad,
    );
  }

  Future<_MetricsLoadResult> _loadMetrics() async {
    final metricsPayload = await _store.getString(metricsStorageKey);
    if (metricsPayload == null || metricsPayload.isEmpty) {
      return const _MetricsLoadResult(metrics: <HabitRecordMetric>[]);
    }

    var shouldPersistAfterLoad = false;
    final metrics = <HabitRecordMetric>[];

    try {
      final decodedMetrics = jsonDecode(metricsPayload);
      if (decodedMetrics is! List<dynamic>) {
        return const _MetricsLoadResult(
          metrics: <HabitRecordMetric>[],
          shouldPersistAfterLoad: true,
        );
      }

      for (final item in decodedMetrics) {
        if (item is! Map) {
          shouldPersistAfterLoad = true;
          continue;
        }

        try {
          final json = Map<String, dynamic>.from(item);
          metrics.add(HabitRecordMetric.fromJson(json));
        } catch (_) {
          shouldPersistAfterLoad = true;
        }
      }
    } catch (_) {
      return const _MetricsLoadResult(
        metrics: <HabitRecordMetric>[],
        shouldPersistAfterLoad: true,
      );
    }

    return _MetricsLoadResult(
      metrics: metrics,
      shouldPersistAfterLoad: shouldPersistAfterLoad,
    );
  }

  HabitRecord _buildMigratedCheckInRecord({
    required HabitItem habit,
    required String localDate,
  }) {
    return HabitRecord(
      id: 'habit-record-${habit.id}-$localDate',
      habitId: habit.id,
      localDate: localDate,
      type: HabitRecordType.checkIn,
      createdAt: DateTime.parse('${localDate}T00:00:00Z'),
    );
  }

  List<HabitRecord> _mergeRecords(
    List<HabitRecord> records,
    List<HabitRecord> migratedRecords,
  ) {
    final byId = <String, HabitRecord>{};
    for (final record in [...records, ...migratedRecords]) {
      byId[record.id] = record;
    }

    final merged = byId.values.toList(growable: false)
      ..sort((a, b) {
        final dateComparison = b.localDate.compareTo(a.localDate);
        if (dateComparison != 0) {
          return dateComparison;
        }

        return b.createdAt.compareTo(a.createdAt);
      });

    return merged;
  }
}

class _RecordsLoadResult {
  const _RecordsLoadResult({
    required this.records,
    this.shouldPersistAfterLoad = false,
  });

  final List<HabitRecord> records;
  final bool shouldPersistAfterLoad;
}

class _AttachmentsLoadResult {
  const _AttachmentsLoadResult({
    required this.attachments,
    this.shouldPersistAfterLoad = false,
  });

  final List<HabitRecordAttachment> attachments;
  final bool shouldPersistAfterLoad;
}

class _TemplatesLoadResult {
  const _TemplatesLoadResult({
    required this.templates,
    this.shouldPersistAfterLoad = false,
  });

  final List<HabitCheckInTemplate> templates;
  final bool shouldPersistAfterLoad;
}

class _MetricsLoadResult {
  const _MetricsLoadResult({
    required this.metrics,
    this.shouldPersistAfterLoad = false,
  });

  final List<HabitRecordMetric> metrics;
  final bool shouldPersistAfterLoad;
}

class _SharedPreferencesAsyncStore implements HabitsKeyValueStore {
  _SharedPreferencesAsyncStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) {
    return _preferences.setString(key, value);
  }
}
