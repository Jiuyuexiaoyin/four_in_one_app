enum HabitLifecycleStatus {
  active,
  paused,
  archived,
  deleted;

  String get storageValue {
    return switch (this) {
      HabitLifecycleStatus.active => 'active',
      HabitLifecycleStatus.paused => 'paused',
      HabitLifecycleStatus.archived => 'archived',
      HabitLifecycleStatus.deleted => 'deleted',
    };
  }

  static HabitLifecycleStatus fromStorageValue(Object? value) {
    return tryFromStorageValue(value) ?? HabitLifecycleStatus.active;
  }

  static HabitLifecycleStatus? tryFromStorageValue(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return switch (text) {
      'active' => HabitLifecycleStatus.active,
      'paused' => HabitLifecycleStatus.paused,
      'archived' => HabitLifecycleStatus.archived,
      'deleted' => HabitLifecycleStatus.deleted,
      _ => null,
    };
  }
}

class HabitReminderRule {
  const HabitReminderRule({
    required this.id,
    required this.time,
    required this.weekdays,
    required this.isEnabled,
    required this.createdAt,
  });

  factory HabitReminderRule.fromJson(Map<String, dynamic> json) {
    final id = _readNonEmptyString(json['id']);
    final time = _readReminderTime(json['time']);
    final weekdays = _readWeekdays(json['weekdays']);
    final isEnabled = json['isEnabled'];
    final createdAt = _readOptionalDateTime(json['createdAt']);

    if (id == null ||
        time == null ||
        weekdays.isEmpty ||
        isEnabled is! bool ||
        createdAt == null) {
      throw const FormatException('Invalid habit reminder rule');
    }

    return HabitReminderRule(
      id: id,
      time: time,
      weekdays: weekdays,
      isEnabled: isEnabled,
      createdAt: createdAt,
    );
  }

  factory HabitReminderRule.fromLegacyReminderTime({
    required String habitId,
    required String time,
    required DateTime createdAt,
  }) {
    return HabitReminderRule(
      id: 'habit-reminder-$habitId-legacy',
      time: time,
      weekdays: allWeekdays,
      isEnabled: true,
      createdAt: createdAt.toUtc(),
    );
  }

  static const maxRulesPerHabit = 3;
  static const allWeekdays = <int>[1, 2, 3, 4, 5, 6, 7];

  final String id;
  final String time;
  final List<int> weekdays;
  final bool isEnabled;
  final DateTime createdAt;

  bool get isEveryDay => weekdays.length == 7;

  bool get isWorkdays =>
      weekdays.length == 5 &&
      weekdays[0] == 1 &&
      weekdays[1] == 2 &&
      weekdays[2] == 3 &&
      weekdays[3] == 4 &&
      weekdays[4] == 5;

  HabitReminderRule copyWith({
    String? id,
    String? time,
    List<int>? weekdays,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return HabitReminderRule(
      id: id ?? this.id,
      time: time ?? this.time,
      weekdays: weekdays ?? this.weekdays,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'weekdays': weekdays,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  static bool isValidJson(Object? value) {
    if (value is! Map) {
      return false;
    }

    try {
      HabitReminderRule.fromJson(Map<String, dynamic>.from(value));
      return true;
    } catch (_) {
      return false;
    }
  }

  static String? _readNonEmptyString(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static String? _readReminderTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
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

  static List<int> _readWeekdays(Object? value) {
    if (value is! List) {
      return const <int>[];
    }

    final weekdays = <int>{};
    for (final item in value) {
      final weekday = switch (item) {
        int() => item,
        String() => int.tryParse(item),
        _ => null,
      };
      if (weekday != null && weekday >= 1 && weekday <= 7) {
        weekdays.add(weekday);
      }
    }

    final sortedWeekdays = weekdays.toList(growable: false)..sort();
    return sortedWeekdays;
  }

  static DateTime? _readOptionalDateTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}

class HabitPauseInterval {
  const HabitPauseInterval({
    required this.id,
    required this.startedAt,
    required this.startLocalDate,
    this.endedAt,
    this.endLocalDate,
  });

  factory HabitPauseInterval.fromJson(Map<String, dynamic> json) {
    final id = _readNonEmptyString(json['id']);
    final startedAt = _readOptionalDateTime(json['startedAt']);
    final startLocalDate = _readLocalDate(json['startLocalDate']);
    final endedAt = _readOptionalDateTime(json['endedAt']);
    final endLocalDate = _readLocalDate(json['endLocalDate']);

    if (id == null || startedAt == null || startLocalDate == null) {
      throw const FormatException('Invalid habit pause interval');
    }

    if ((json['endedAt'] != null && endedAt == null) ||
        (json['endLocalDate'] != null && endLocalDate == null) ||
        (endedAt == null) != (endLocalDate == null) ||
        (endLocalDate != null && startLocalDate.compareTo(endLocalDate) > 0)) {
      throw const FormatException('Invalid habit pause interval end');
    }

    return HabitPauseInterval(
      id: id,
      startedAt: startedAt,
      startLocalDate: startLocalDate,
      endedAt: endedAt,
      endLocalDate: endLocalDate,
    );
  }

  final String id;
  final DateTime startedAt;
  final String startLocalDate;
  final DateTime? endedAt;
  final String? endLocalDate;

  bool get isOpen => endedAt == null && endLocalDate == null;

  HabitPauseInterval copyWith({
    String? id,
    DateTime? startedAt,
    String? startLocalDate,
    DateTime? endedAt,
    bool clearEndedAt = false,
    String? endLocalDate,
    bool clearEndLocalDate = false,
  }) {
    return HabitPauseInterval(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      startLocalDate: startLocalDate ?? this.startLocalDate,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      endLocalDate: clearEndLocalDate
          ? null
          : (endLocalDate ?? this.endLocalDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'startLocalDate': startLocalDate,
      'endedAt': endedAt?.toUtc().toIso8601String(),
      'endLocalDate': endLocalDate,
    };
  }

  static bool isValidJson(Object? value) {
    if (value is! Map) {
      return false;
    }

    try {
      HabitPauseInterval.fromJson(Map<String, dynamic>.from(value));
      return true;
    } catch (_) {
      return false;
    }
  }

  static String? _readNonEmptyString(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static DateTime? _readOptionalDateTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  static String? _readLocalDate(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
      return null;
    }

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
}

enum HabitPlanLinkTargetType {
  project('project'),
  task('task');

  const HabitPlanLinkTargetType(this.storageValue);

  final String storageValue;

  static HabitPlanLinkTargetType? fromStorageValue(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return switch (text) {
      'project' => HabitPlanLinkTargetType.project,
      'task' => HabitPlanLinkTargetType.task,
      _ => null,
    };
  }
}

class HabitPlanLink {
  const HabitPlanLink({
    required this.targetType,
    required this.projectId,
    this.taskId,
    required this.titleSnapshot,
    this.contextSnapshot,
    required this.createdAt,
    this.updatedAt,
  });

  factory HabitPlanLink.fromJson(Map<String, dynamic> json) {
    final targetType = HabitPlanLinkTargetType.fromStorageValue(
      json['targetType'],
    );
    final projectId = _readNonEmptyString(json['projectId']);
    final titleSnapshot = _readNonEmptyString(json['titleSnapshot']);
    final createdAt = _readOptionalDateTime(json['createdAt']);

    if (targetType == null ||
        projectId == null ||
        titleSnapshot == null ||
        createdAt == null) {
      throw const FormatException('Invalid habit plan link');
    }

    final taskId = _readNonEmptyString(json['taskId']);
    if (targetType == HabitPlanLinkTargetType.task && taskId == null) {
      throw const FormatException('Task habit plan link requires taskId');
    }

    return HabitPlanLink(
      targetType: targetType,
      projectId: projectId,
      taskId: targetType == HabitPlanLinkTargetType.task ? taskId : null,
      titleSnapshot: titleSnapshot,
      contextSnapshot: _readNonEmptyString(json['contextSnapshot']),
      createdAt: createdAt,
      updatedAt: _readOptionalDateTime(json['updatedAt']),
    );
  }

  final HabitPlanLinkTargetType targetType;
  final String projectId;
  final String? taskId;
  final String titleSnapshot;
  final String? contextSnapshot;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HabitPlanLink copyWith({
    HabitPlanLinkTargetType? targetType,
    String? projectId,
    String? taskId,
    bool clearTaskId = false,
    String? titleSnapshot,
    String? contextSnapshot,
    bool clearContextSnapshot = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return HabitPlanLink(
      targetType: targetType ?? this.targetType,
      projectId: projectId ?? this.projectId,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      contextSnapshot: clearContextSnapshot
          ? null
          : (contextSnapshot ?? this.contextSnapshot),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType.storageValue,
      'projectId': projectId,
      'taskId': taskId,
      'titleSnapshot': titleSnapshot,
      'contextSnapshot': contextSnapshot,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  static bool isValidJson(Object? value) {
    if (value is! Map) {
      return false;
    }

    try {
      HabitPlanLink.fromJson(Map<String, dynamic>.from(value));
      return true;
    } catch (_) {
      return false;
    }
  }

  static String? _readNonEmptyString(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static DateTime? _readOptionalDateTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}

class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.targetCountPerDay,
    required this.reminderTime,
    this.habitColorValue,
    this.status = HabitLifecycleStatus.active,
    this.pausedAt,
    this.archivedAt,
    this.deletedAt,
    this.pauseIntervals = const <HabitPauseInterval>[],
    this.reminderRules = const <HabitReminderRule>[],
    this.planLink,
    required this.createdAt,
  });

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final status = HabitLifecycleStatus.fromStorageValue(json['status']);
    final pausedAt = _readOptionalDateTime(json['pausedAt']);
    final pauseIntervals = _pauseIntervalsWithSynthesizedCurrentPause(
      id: id,
      status: status,
      pausedAt: pausedAt,
      pauseIntervals: _readPauseIntervals(json['pauseIntervals']),
    );
    final reminderRules = _reminderRulesWithLegacyFallback(
      id: id,
      createdAt: createdAt,
      reminderRules: _readReminderRules(json['reminderRules']),
      reminderTime: _readReminderTime(json['reminderTime']),
    );

    return HabitItem(
      id: id,
      name: json['name'] as String,
      emoji: _readNonEmptyString(json['emoji']) ?? defaultEmoji,
      description: (json['description'] as String?)?.trim() ?? '',
      targetCountPerDay: _readTargetCount(json['targetCountPerDay']),
      reminderTime: _legacyReminderTimeForRules(reminderRules),
      habitColorValue: _readHabitColorValue(json['habitColorValue']),
      status: status,
      pausedAt: pausedAt,
      archivedAt: _readOptionalDateTime(json['archivedAt']),
      deletedAt: _readOptionalDateTime(json['deletedAt']),
      pauseIntervals: pauseIntervals,
      reminderRules: reminderRules,
      planLink: _readPlanLink(json['planLink']),
      createdAt: createdAt,
    );
  }

  static const defaultEmoji = '🌱';
  static const defaultTargetCountPerDay = 1;

  final String id;
  final String name;
  final String emoji;
  final String description;
  final int targetCountPerDay;
  final String? reminderTime;
  final int? habitColorValue;
  final HabitLifecycleStatus status;
  final DateTime? pausedAt;
  final DateTime? archivedAt;
  final DateTime? deletedAt;
  final List<HabitPauseInterval> pauseIntervals;
  final List<HabitReminderRule> reminderRules;
  final HabitPlanLink? planLink;
  final DateTime createdAt;

  bool get isActive => status == HabitLifecycleStatus.active;

  bool get isPaused => status == HabitLifecycleStatus.paused;

  bool get isArchived => status == HabitLifecycleStatus.archived;

  bool get isDeleted => status == HabitLifecycleStatus.deleted;

  List<HabitReminderRule> get enabledReminderRules =>
      reminderRules.where((rule) => rule.isEnabled).toList(growable: false);

  HabitItem copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    int? targetCountPerDay,
    String? reminderTime,
    bool clearReminderTime = false,
    int? habitColorValue,
    bool clearHabitColorValue = false,
    HabitLifecycleStatus? status,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    List<HabitPauseInterval>? pauseIntervals,
    List<HabitReminderRule>? reminderRules,
    HabitPlanLink? planLink,
    bool clearPlanLink = false,
    DateTime? createdAt,
  }) {
    final effectiveReminderRules = reminderRules ?? this.reminderRules;

    return HabitItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      targetCountPerDay: targetCountPerDay ?? this.targetCountPerDay,
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
      habitColorValue: clearHabitColorValue
          ? null
          : (habitColorValue ?? this.habitColorValue),
      status: status ?? this.status,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      pauseIntervals: pauseIntervals ?? this.pauseIntervals,
      reminderRules: effectiveReminderRules,
      planLink: clearPlanLink ? null : (planLink ?? this.planLink),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'description': description,
      'targetCountPerDay': targetCountPerDay,
      'reminderTime': _legacyReminderTimeForRules(reminderRules),
      'habitColorValue': habitColorValue,
      'status': status.storageValue,
      'pausedAt': pausedAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'pauseIntervals': pauseIntervals
          .map((interval) => interval.toJson())
          .toList(growable: false),
      'reminderRules': reminderRules
          .map((rule) => rule.toJson())
          .toList(growable: false),
      'planLink': planLink?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static bool needsMigration(Map<String, dynamic> json) {
    return !json.containsKey('emoji') ||
        !json.containsKey('description') ||
        !json.containsKey('targetCountPerDay') ||
        !json.containsKey('reminderTime') ||
        !json.containsKey('habitColorValue') ||
        !json.containsKey('status') ||
        !json.containsKey('pausedAt') ||
        !json.containsKey('archivedAt') ||
        !json.containsKey('deletedAt') ||
        !json.containsKey('pauseIntervals') ||
        !json.containsKey('reminderRules') ||
        !json.containsKey('planLink') ||
        (json['habitColorValue'] != null &&
            _readHabitColorValue(json['habitColorValue']) == null) ||
        (json['status'] != null &&
            HabitLifecycleStatus.tryFromStorageValue(json['status']) == null) ||
        (json['pausedAt'] != null &&
            _readOptionalDateTime(json['pausedAt']) == null) ||
        (json['archivedAt'] != null &&
            _readOptionalDateTime(json['archivedAt']) == null) ||
        (json['deletedAt'] != null &&
            _readOptionalDateTime(json['deletedAt']) == null) ||
        _pauseIntervalsNeedMigration(json) ||
        _reminderRulesNeedMigration(json) ||
        _planLinkNeedsMigration(json) ||
        json.containsKey('completedOnDate') ||
        json.containsKey('completedToday');
  }

  static String? legacyCompletedDateKey(
    Map<String, dynamic> json, {
    required String migrationDateKey,
  }) {
    final completedOnDate = _readNonEmptyString(json['completedOnDate']);
    if (completedOnDate != null) {
      return completedOnDate;
    }

    final completedToday = json['completedToday'] as bool?;
    if (completedToday ?? false) {
      return migrationDateKey;
    }

    return null;
  }

  static String? _readNonEmptyString(Object? value) {
    final text = (value as String?)?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static int _readTargetCount(Object? value) {
    final parsed = switch (value) {
      int() => value,
      String() => int.tryParse(value),
      _ => null,
    };

    if (parsed == null || parsed < 1) {
      return defaultTargetCountPerDay;
    }

    return parsed;
  }

  static String? _readReminderTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
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

  static int? _readHabitColorValue(Object? value) {
    final parsed = switch (value) {
      int() => value,
      String() => int.tryParse(value),
      _ => null,
    };

    if (parsed == null || parsed < 0 || parsed > 0xFFFFFFFF) {
      return null;
    }

    return parsed;
  }

  static DateTime? _readOptionalDateTime(Object? value) {
    final text = _readNonEmptyString(value);
    if (text == null) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  static List<HabitPauseInterval> _readPauseIntervals(Object? value) {
    if (value is! List) {
      return const <HabitPauseInterval>[];
    }

    final intervals = <HabitPauseInterval>[];
    for (final item in value) {
      if (item is! Map) {
        continue;
      }

      try {
        intervals.add(
          HabitPauseInterval.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        continue;
      }
    }

    return intervals;
  }

  static List<HabitReminderRule> _readReminderRules(Object? value) {
    if (value is! List) {
      return const <HabitReminderRule>[];
    }

    final rules = <HabitReminderRule>[];
    for (final item in value) {
      if (item is! Map || rules.length >= HabitReminderRule.maxRulesPerHabit) {
        continue;
      }

      try {
        rules.add(HabitReminderRule.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }

    return rules;
  }

  static HabitPlanLink? _readPlanLink(Object? value) {
    if (value == null || value is! Map) {
      return null;
    }

    try {
      return HabitPlanLink.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      return null;
    }
  }

  static bool _pauseIntervalsNeedMigration(Map<String, dynamic> json) {
    final value = json['pauseIntervals'];
    if (value is! List) {
      return true;
    }

    if (value.any((item) => !HabitPauseInterval.isValidJson(item))) {
      return true;
    }

    final status = HabitLifecycleStatus.fromStorageValue(json['status']);
    final pausedAt = _readOptionalDateTime(json['pausedAt']);
    if (status != HabitLifecycleStatus.paused || pausedAt == null) {
      return false;
    }

    return !_readPauseIntervals(value).any((interval) => interval.isOpen);
  }

  static bool _reminderRulesNeedMigration(Map<String, dynamic> json) {
    final value = json['reminderRules'];
    if (value is! List) {
      return true;
    }

    if (value.any((item) => !HabitReminderRule.isValidJson(item))) {
      return true;
    }

    final parsedRules = _readReminderRules(value);
    final reminderTime = _readReminderTime(json['reminderTime']);
    if (parsedRules.isEmpty && reminderTime != null) {
      return true;
    }

    if (parsedRules.isNotEmpty &&
        reminderTime != _legacyReminderTimeForRules(parsedRules)) {
      return true;
    }

    return false;
  }

  static bool _planLinkNeedsMigration(Map<String, dynamic> json) {
    final value = json['planLink'];
    if (value == null) {
      return false;
    }

    return !HabitPlanLink.isValidJson(value);
  }

  static List<HabitPauseInterval> _pauseIntervalsWithSynthesizedCurrentPause({
    required String id,
    required HabitLifecycleStatus status,
    required DateTime? pausedAt,
    required List<HabitPauseInterval> pauseIntervals,
  }) {
    if (status != HabitLifecycleStatus.paused ||
        pausedAt == null ||
        pauseIntervals.any((interval) => interval.isOpen)) {
      return pauseIntervals;
    }

    return [
      ...pauseIntervals,
      HabitPauseInterval(
        id: 'habit-pause-$id-${_localDateKey(pausedAt)}',
        startedAt: pausedAt.toUtc(),
        startLocalDate: _localDateKey(pausedAt),
      ),
    ];
  }

  static List<HabitReminderRule> _reminderRulesWithLegacyFallback({
    required String id,
    required DateTime createdAt,
    required List<HabitReminderRule> reminderRules,
    required String? reminderTime,
  }) {
    if (reminderRules.isNotEmpty || reminderTime == null) {
      return reminderRules;
    }

    return [
      HabitReminderRule.fromLegacyReminderTime(
        habitId: id,
        time: reminderTime,
        createdAt: createdAt,
      ),
    ];
  }

  static String? _legacyReminderTimeForRules(List<HabitReminderRule> rules) {
    for (final rule in rules) {
      if (rule.isEnabled) {
        return rule.time;
      }
    }

    return null;
  }

  static String _localDateKey(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
