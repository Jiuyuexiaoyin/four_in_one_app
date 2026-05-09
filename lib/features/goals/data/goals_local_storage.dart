import 'dart:convert';

import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GoalsStorage {
  Future<GoalsSnapshot> loadSnapshot({required DateTime migrationCreatedAt});

  Future<void> saveSnapshot(GoalsSnapshot snapshot);
}

abstract interface class GoalsKeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

class GoalsSnapshot {
  const GoalsSnapshot({
    required this.goals,
    required this.projects,
    required this.subprojects,
    required this.tasks,
    required this.records,
    required this.attachments,
    required this.legacyGoalStates,
    this.shouldPersistAfterLoad = false,
  });

  static const schemaVersion = 6;

  final List<GoalItem> goals;
  final List<ProjectItem> projects;
  final List<SubprojectItem> subprojects;
  final List<GoalTaskItem> tasks;
  final List<PlanRecord> records;
  final List<PlanRecordAttachment> attachments;
  final List<LegacyGoalState> legacyGoalStates;
  final bool shouldPersistAfterLoad;

  factory GoalsSnapshot.empty() {
    return const GoalsSnapshot(
      goals: <GoalItem>[],
      projects: <ProjectItem>[],
      subprojects: <SubprojectItem>[],
      tasks: <GoalTaskItem>[],
      records: <PlanRecord>[],
      attachments: <PlanRecordAttachment>[],
      legacyGoalStates: <LegacyGoalState>[],
    );
  }

  factory GoalsSnapshot.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1 &&
        schemaVersion != 2 &&
        schemaVersion != 3 &&
        schemaVersion != 4 &&
        schemaVersion != 5 &&
        schemaVersion != GoalsSnapshot.schemaVersion) {
      throw const FormatException('Unsupported goals snapshot schema.');
    }

    return GoalsSnapshot(
      goals: _decodeList(json['goals'], GoalItem.fromJson),
      projects: _decodeList(json['projects'], ProjectItem.fromJson),
      subprojects: _decodeOptionalList(
        json['subprojects'],
        SubprojectItem.fromJson,
      ),
      tasks: _decodeList(json['tasks'], GoalTaskItem.fromJson),
      records: _decodeOptionalValidList(json['records'], PlanRecord.fromJson),
      attachments: _decodeOptionalValidList(
        json['attachments'],
        PlanRecordAttachment.fromJson,
      ),
      legacyGoalStates: _decodeList(
        json['legacyGoalStates'],
        LegacyGoalState.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'goals': goals.map((goal) => goal.toJson()).toList(growable: false),
      'projects': projects
          .map((project) => project.toJson())
          .toList(growable: false),
      'subprojects': subprojects
          .map((subproject) => subproject.toJson())
          .toList(growable: false),
      'tasks': tasks.map((task) => task.toJson()).toList(growable: false),
      'records': records
          .map((record) => record.toJson())
          .toList(growable: false),
      'attachments': attachments
          .map((attachment) => attachment.toJson())
          .toList(growable: false),
      'legacyGoalStates': legacyGoalStates
          .map((state) => state.toJson())
          .toList(growable: false),
    };
  }

  GoalsSnapshot copyWith({
    List<GoalItem>? goals,
    List<ProjectItem>? projects,
    List<SubprojectItem>? subprojects,
    List<GoalTaskItem>? tasks,
    List<PlanRecord>? records,
    List<PlanRecordAttachment>? attachments,
    List<LegacyGoalState>? legacyGoalStates,
    bool? shouldPersistAfterLoad,
  }) {
    return GoalsSnapshot(
      goals: goals ?? this.goals,
      projects: projects ?? this.projects,
      subprojects: subprojects ?? this.subprojects,
      tasks: tasks ?? this.tasks,
      records: records ?? this.records,
      attachments: attachments ?? this.attachments,
      legacyGoalStates: legacyGoalStates ?? this.legacyGoalStates,
      shouldPersistAfterLoad:
          shouldPersistAfterLoad ?? this.shouldPersistAfterLoad,
    );
  }

  static List<T> _decodeList<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List<dynamic>) {
      throw const FormatException('Goals snapshot list is invalid.');
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Goals snapshot item is invalid.');
          }

          return fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  static List<T> _decodeOptionalList<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) {
      return <T>[];
    }

    return _decodeList(value, fromJson);
  }

  static List<T> _decodeOptionalValidList<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List<dynamic>) {
      return <T>[];
    }

    final decoded = <T>[];
    for (final item in value) {
      if (item is! Map) {
        continue;
      }

      try {
        decoded.add(fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }

    return decoded;
  }
}

class GoalsLocalStorage implements GoalsStorage {
  GoalsLocalStorage({GoalsKeyValueStore? store})
    : _store = store ?? _SharedPreferencesAsyncStore();

  static const storageKey = 'goals.local.json';

  final GoalsKeyValueStore _store;

  @override
  Future<GoalsSnapshot> loadSnapshot({
    required DateTime migrationCreatedAt,
  }) async {
    try {
      final payload = await _store.getString(storageKey);
      if (payload == null || payload.isEmpty) {
        return GoalsSnapshot.empty();
      }

      final decoded = jsonDecode(payload);
      if (decoded is List<dynamic>) {
        return _migrateLegacyFlatGoals(decoded, migrationCreatedAt);
      }

      if (decoded is Map) {
        return GoalsSnapshot.fromJson(Map<String, dynamic>.from(decoded));
      }

      return GoalsSnapshot.empty();
    } catch (_) {
      return GoalsSnapshot.empty();
    }
  }

  @override
  Future<void> saveSnapshot(GoalsSnapshot snapshot) async {
    await _store.setString(storageKey, jsonEncode(snapshot.toJson()));
  }

  GoalsSnapshot _migrateLegacyFlatGoals(
    List<dynamic> decoded,
    DateTime migrationCreatedAt,
  ) {
    try {
      final goals = <GoalItem>[];
      final legacyStates = <LegacyGoalState>[];

      for (final item in decoded) {
        if (item is! Map) {
          throw const FormatException('Legacy goal item is invalid.');
        }

        final json = Map<String, dynamic>.from(item);
        final id = json['id'];
        final title = json['title'];
        final isCompleted = json['isCompleted'];

        if (id is! String ||
            id.isEmpty ||
            title is! String ||
            title.isEmpty ||
            isCompleted is! bool) {
          throw const FormatException('Legacy goal item is malformed.');
        }

        goals.add(
          GoalItem(id: id, title: title, createdAt: migrationCreatedAt.toUtc()),
        );

        if (isCompleted) {
          legacyStates.add(
            LegacyGoalState(goalId: id, wasCompleted: isCompleted),
          );
        }
      }

      return GoalsSnapshot(
        goals: goals,
        projects: const <ProjectItem>[],
        subprojects: const <SubprojectItem>[],
        tasks: const <GoalTaskItem>[],
        records: const <PlanRecord>[],
        attachments: const <PlanRecordAttachment>[],
        legacyGoalStates: legacyStates,
        shouldPersistAfterLoad: true,
      );
    } catch (_) {
      return GoalsSnapshot.empty();
    }
  }
}

class _SharedPreferencesAsyncStore implements GoalsKeyValueStore {
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
