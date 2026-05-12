class GoalItem {
  const GoalItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.icon = defaultIcon,
    this.description = '',
    this.colorValue = defaultColorValue,
  });

  static const defaultIcon = '🎯';
  static const defaultColorValue = 0xFF7A8A6A;

  final String id;
  final String title;
  final DateTime createdAt;
  final String icon;
  final String description;
  final int colorValue;

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Goal is missing a valid id.');
    }

    if (title is! String || title.isEmpty) {
      throw const FormatException('Goal is missing a valid title.');
    }

    return GoalItem(
      id: id,
      title: title,
      createdAt: createdAt,
      icon: _parseOptionalText(json['icon'], defaultIcon),
      description: _parseOptionalText(json['description'], ''),
      colorValue: _parseOptionalColorValue(
        json['colorValue'],
        defaultColorValue,
      ),
    );
  }

  GoalItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? icon,
    String? description,
    int? colorValue,
  }) {
    return GoalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'icon': icon,
      'description': description,
      'colorValue': colorValue,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

enum PlanPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const PlanPriority(this.value);

  final String value;

  static PlanPriority? parse(Object? value) {
    return switch (value) {
      'low' => PlanPriority.low,
      'medium' => PlanPriority.medium,
      'high' => PlanPriority.high,
      'urgent' => PlanPriority.urgent,
      _ => null,
    };
  }
}

class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.goalId,
    required this.title,
    required this.createdAt,
    this.icon = defaultIcon,
    this.description = '',
    this.colorValue = defaultColorValue,
    this.dueDate,
    this.priority,
    this.tags = const <String>[],
  });

  static const defaultIcon = '📁';
  static const defaultColorValue = 0xFF6E7E9E;

  final String id;
  final String goalId;
  final String title;
  final DateTime createdAt;
  final String icon;
  final String description;
  final int colorValue;
  final String? dueDate;
  final PlanPriority? priority;
  final List<String> tags;

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final goalId = json['goalId'];
    final title = json['title'];
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Project is missing a valid id.');
    }

    if (goalId is! String || goalId.isEmpty) {
      throw const FormatException('Project is missing a valid goal id.');
    }

    if (title is! String || title.isEmpty) {
      throw const FormatException('Project is missing a valid title.');
    }

    return ProjectItem(
      id: id,
      goalId: goalId,
      title: title,
      createdAt: createdAt,
      icon: _parseOptionalText(json['icon'], defaultIcon),
      description: _parseOptionalText(json['description'], ''),
      colorValue: _parseOptionalColorValue(
        json['colorValue'],
        defaultColorValue,
      ),
      dueDate: _parseOptionalLocalDate(json['dueDate']),
      priority: PlanPriority.parse(json['priority']),
      tags: _parseTags(json['tags']),
    );
  }

  ProjectItem copyWith({
    String? id,
    String? goalId,
    String? title,
    DateTime? createdAt,
    String? icon,
    String? description,
    int? colorValue,
    String? dueDate,
    bool clearDueDate = false,
    PlanPriority? priority,
    bool clearPriority = false,
    List<String>? tags,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: clearPriority ? null : (priority ?? this.priority),
      tags: tags == null ? this.tags : List<String>.unmodifiable(tags),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'goalId': goalId,
      'title': title,
      'icon': icon,
      'description': description,
      'colorValue': colorValue,
      'dueDate': dueDate,
      'priority': priority?.value,
      'tags': tags,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class SubprojectItem {
  const SubprojectItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String title;
  final DateTime createdAt;

  factory SubprojectItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final projectId = json['projectId'];
    final title = json['title'];
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Subproject is missing a valid id.');
    }

    if (projectId is! String || projectId.isEmpty) {
      throw const FormatException('Subproject is missing a valid project id.');
    }

    if (title is! String || title.isEmpty) {
      throw const FormatException('Subproject is missing a valid title.');
    }

    return SubprojectItem(
      id: id,
      projectId: projectId,
      title: title,
      createdAt: createdAt,
    );
  }

  SubprojectItem copyWith({
    String? id,
    String? projectId,
    String? title,
    DateTime? createdAt,
  }) {
    return SubprojectItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'projectId': projectId,
      'title': title,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class GoalTaskItem {
  const GoalTaskItem({
    required this.id,
    required this.projectId,
    this.subprojectId,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
    this.priority,
    this.tags = const <String>[],
  });

  final String id;
  final String projectId;
  final String? subprojectId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String? dueDate;
  final PlanPriority? priority;
  final List<String> tags;

  factory GoalTaskItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final projectId = json['projectId'];
    final rawSubprojectId = json['subprojectId'];
    final title = json['title'];
    final isCompleted = json['isCompleted'];
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Task is missing a valid id.');
    }

    if (projectId is! String || projectId.isEmpty) {
      throw const FormatException('Task is missing a valid project id.');
    }

    if (title is! String || title.isEmpty) {
      throw const FormatException('Task is missing a valid title.');
    }

    if (rawSubprojectId != null &&
        (rawSubprojectId is! String || rawSubprojectId.isEmpty)) {
      throw const FormatException('Task has an invalid subproject id.');
    }

    if (isCompleted is! bool) {
      throw const FormatException('Task is missing a valid completion flag.');
    }

    return GoalTaskItem(
      id: id,
      projectId: projectId,
      subprojectId: rawSubprojectId as String?,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
      dueDate: _parseOptionalLocalDate(json['dueDate']),
      priority: PlanPriority.parse(json['priority']),
      tags: _parseTags(json['tags']),
    );
  }

  GoalTaskItem copyWith({
    String? id,
    String? projectId,
    String? subprojectId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? dueDate,
    bool clearDueDate = false,
    PlanPriority? priority,
    bool clearPriority = false,
    List<String>? tags,
  }) {
    return GoalTaskItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      subprojectId: subprojectId ?? this.subprojectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: clearPriority ? null : (priority ?? this.priority),
      tags: tags == null ? this.tags : List<String>.unmodifiable(tags),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'projectId': projectId,
      'subprojectId': subprojectId,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate,
      'priority': priority?.value,
      'tags': tags,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class LegacyGoalState {
  const LegacyGoalState({required this.goalId, required this.wasCompleted});

  final String goalId;
  final bool wasCompleted;

  factory LegacyGoalState.fromJson(Map<String, dynamic> json) {
    final goalId = json['goalId'];
    final wasCompleted = json['wasCompleted'];

    if (goalId is! String || goalId.isEmpty) {
      throw const FormatException('Legacy goal state is missing a goal id.');
    }

    if (wasCompleted is! bool) {
      throw const FormatException(
        'Legacy goal state is missing a completion flag.',
      );
    }

    return LegacyGoalState(goalId: goalId, wasCompleted: wasCompleted);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'goalId': goalId, 'wasCompleted': wasCompleted};
  }
}

enum PlanRecordType {
  note('note'),
  numeric('numeric');

  const PlanRecordType(this.value);

  final String value;

  static PlanRecordType parse(Object? value) {
    return switch (value) {
      'note' => PlanRecordType.note,
      'numeric' => PlanRecordType.numeric,
      _ => throw const FormatException('Plan record type is invalid.'),
    };
  }
}

class PlanRecord {
  const PlanRecord({
    required this.id,
    required this.projectId,
    this.subprojectId,
    this.taskId,
    required this.type,
    required this.localDate,
    this.note,
    this.numericValue,
    this.unit,
    this.sourceType,
    this.sourceId,
    this.sourceLocalDate,
    this.sourceKey,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String? subprojectId;
  final String? taskId;
  final PlanRecordType type;
  final String localDate;
  final String? note;
  final double? numericValue;
  final String? unit;
  final String? sourceType;
  final String? sourceId;
  final String? sourceLocalDate;
  final String? sourceKey;
  final DateTime createdAt;

  factory PlanRecord.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final projectId = json['projectId'];
    final rawSubprojectId = json['subprojectId'];
    final rawTaskId = json['taskId'];
    final type = PlanRecordType.parse(json['type']);
    final localDate = json['localDate'];
    final rawNote = json['note'];
    final rawNumericValue = json['numericValue'];
    final rawUnit = json['unit'];
    final sourceType = _parseOptionalSourceText(json['sourceType']);
    final sourceId = _parseOptionalSourceText(json['sourceId']);
    final rawSourceLocalDate = _parseOptionalSourceText(
      json['sourceLocalDate'],
    );
    final sourceKey = _parseOptionalSourceText(json['sourceKey']);
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Plan record is missing a valid id.');
    }

    if (projectId is! String || projectId.isEmpty) {
      throw const FormatException('Plan record is missing a valid project id.');
    }

    if (rawSubprojectId != null &&
        (rawSubprojectId is! String || rawSubprojectId.isEmpty)) {
      throw const FormatException('Plan record has an invalid subproject id.');
    }

    if (rawTaskId != null && (rawTaskId is! String || rawTaskId.isEmpty)) {
      throw const FormatException('Plan record has an invalid task id.');
    }

    if (localDate is! String || !_isValidLocalDate(localDate)) {
      throw const FormatException('Plan record is missing a valid local date.');
    }

    if (rawNote != null && rawNote is! String) {
      throw const FormatException('Plan record note is invalid.');
    }

    double? numericValue;
    if (rawNumericValue != null) {
      if (rawNumericValue is! num) {
        throw const FormatException('Plan record numeric value is invalid.');
      }
      numericValue = rawNumericValue.toDouble();
      if (!numericValue.isFinite) {
        throw const FormatException('Plan record numeric value is not finite.');
      }
    }

    if (rawUnit != null && rawUnit is! String) {
      throw const FormatException('Plan record unit is invalid.');
    }

    final note = rawNote?.trim();
    final unit = rawUnit?.trim();
    if (type == PlanRecordType.note && (note == null || note.isEmpty)) {
      throw const FormatException('Plan note record requires note text.');
    }
    if (type == PlanRecordType.numeric && numericValue == null) {
      throw const FormatException('Plan numeric record requires a value.');
    }

    return PlanRecord(
      id: id,
      projectId: projectId,
      subprojectId: rawSubprojectId as String?,
      taskId: rawTaskId as String?,
      type: type,
      localDate: localDate,
      note: note == null || note.isEmpty ? null : note,
      numericValue: numericValue,
      unit: unit == null || unit.isEmpty ? null : unit,
      sourceType: sourceType,
      sourceId: sourceId,
      sourceLocalDate:
          rawSourceLocalDate != null && _isValidLocalDate(rawSourceLocalDate)
          ? rawSourceLocalDate
          : null,
      sourceKey: sourceKey,
      createdAt: createdAt,
    );
  }

  PlanRecord copyWith({
    String? id,
    String? projectId,
    String? subprojectId,
    bool clearSubprojectId = false,
    String? taskId,
    bool clearTaskId = false,
    PlanRecordType? type,
    String? localDate,
    String? note,
    bool clearNote = false,
    double? numericValue,
    bool clearNumericValue = false,
    String? unit,
    bool clearUnit = false,
    String? sourceType,
    bool clearSourceType = false,
    String? sourceId,
    bool clearSourceId = false,
    String? sourceLocalDate,
    bool clearSourceLocalDate = false,
    String? sourceKey,
    bool clearSourceKey = false,
    DateTime? createdAt,
  }) {
    return PlanRecord(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      subprojectId: clearSubprojectId
          ? null
          : (subprojectId ?? this.subprojectId),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      type: type ?? this.type,
      localDate: localDate ?? this.localDate,
      note: clearNote ? null : (note ?? this.note),
      numericValue: clearNumericValue
          ? null
          : (numericValue ?? this.numericValue),
      unit: clearUnit ? null : (unit ?? this.unit),
      sourceType: clearSourceType ? null : (sourceType ?? this.sourceType),
      sourceId: clearSourceId ? null : (sourceId ?? this.sourceId),
      sourceLocalDate: clearSourceLocalDate
          ? null
          : (sourceLocalDate ?? this.sourceLocalDate),
      sourceKey: clearSourceKey ? null : (sourceKey ?? this.sourceKey),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'projectId': projectId,
      'subprojectId': subprojectId,
      'taskId': taskId,
      'type': type.value,
      'localDate': localDate,
      'note': note,
      'numericValue': numericValue,
      'unit': unit,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'sourceLocalDate': sourceLocalDate,
      'sourceKey': sourceKey,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class PlanRecordAttachment {
  const PlanRecordAttachment({
    required this.id,
    required this.recordId,
    required this.relativePath,
    required this.fileName,
    this.mimeType,
    required this.createdAt,
  });

  final String id;
  final String recordId;
  final String relativePath;
  final String fileName;
  final String? mimeType;
  final DateTime createdAt;

  factory PlanRecordAttachment.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final recordId = json['recordId'];
    final relativePath = json['relativePath'];
    final fileName = json['fileName'];
    final rawMimeType = json['mimeType'];
    final createdAt = _parseDateTime(json['createdAt']);

    if (id is! String || id.isEmpty) {
      throw const FormatException('Plan record attachment is missing an id.');
    }

    if (recordId is! String || recordId.isEmpty) {
      throw const FormatException(
        'Plan record attachment is missing a record id.',
      );
    }

    if (relativePath is! String || relativePath.isEmpty) {
      throw const FormatException(
        'Plan record attachment is missing a relative path.',
      );
    }

    if (fileName is! String || fileName.isEmpty) {
      throw const FormatException(
        'Plan record attachment is missing a file name.',
      );
    }

    if (rawMimeType != null && rawMimeType is! String) {
      throw const FormatException('Plan record attachment mime type invalid.');
    }

    final mimeType = rawMimeType?.trim();

    return PlanRecordAttachment(
      id: id,
      recordId: recordId,
      relativePath: relativePath,
      fileName: fileName,
      mimeType: mimeType == null || mimeType.isEmpty ? null : mimeType,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recordId': recordId,
      'relativePath': relativePath,
      'fileName': fileName,
      'mimeType': mimeType,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class GoalProgress {
  const GoalProgress({required this.completedTasks, required this.totalTasks});

  final int completedTasks;
  final int totalTasks;

  bool get hasTasks => totalTasks > 0;

  bool get isComplete => hasTasks && completedTasks >= totalTasks;

  int get percentage {
    if (!hasTasks) {
      return 0;
    }

    return ((completedTasks / totalTasks) * 100).round();
  }

  String get label => hasTasks ? '进度 $percentage%' : '尚未添加行动';
}

class ProjectRecordStats {
  const ProjectRecordStats({
    required this.recordCount,
    required this.noteRecordCount,
    required this.activeDaysCount,
    required this.currentMonthRecordCount,
    required this.photoAttachmentCount,
    required this.numericTotalsByUnit,
    required this.currentMonthCountsByLocalDate,
    required this.currentYearRecordCount,
    required this.currentYearCountsByLocalDate,
    required this.currentYearCountsByMonth,
    required this.currentYear,
    required this.currentMonth,
    required this.currentLocalDate,
  });

  final int recordCount;
  final int noteRecordCount;
  final int activeDaysCount;
  final int currentMonthRecordCount;
  final int photoAttachmentCount;
  final Map<String, double> numericTotalsByUnit;
  final Map<String, int> currentMonthCountsByLocalDate;
  final int currentYearRecordCount;
  final Map<String, int> currentYearCountsByLocalDate;
  final Map<int, int> currentYearCountsByMonth;
  final int currentYear;
  final int currentMonth;
  final String currentLocalDate;

  bool get hasRecords => recordCount > 0;

  bool get hasNumericTotals => numericTotalsByUnit.isNotEmpty;

  bool get hasCurrentMonthActivity =>
      currentMonthCountsByLocalDate.values.any((count) => count > 0);

  bool get hasCurrentYearActivity =>
      currentYearCountsByLocalDate.values.any((count) => count > 0);
}

DateTime _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Missing date time value.');
  }

  return DateTime.parse(value).toUtc();
}

bool _isValidLocalDate(String value) {
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
}

String? _parseOptionalLocalDate(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return _isValidPlanningLocalDate(trimmed) ? trimmed : null;
}

String _parseOptionalText(Object? value, String fallback) {
  if (value is! String) {
    return fallback;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String? _parseOptionalSourceText(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _parseTags(Object? value) {
  if (value is! List<dynamic>) {
    return const <String>[];
  }

  final tags = <String>[];
  for (final item in value) {
    if (item is! String) {
      continue;
    }

    final trimmed = item.trim();
    if (trimmed.isEmpty || tags.contains(trimmed)) {
      continue;
    }

    tags.add(trimmed.length > 16 ? trimmed.substring(0, 16) : trimmed);
    if (tags.length >= 8) {
      break;
    }
  }

  return List<String>.unmodifiable(tags);
}

int _parseOptionalColorValue(Object? value, int fallback) {
  if (value is int && _isValidColorValue(value)) {
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null && _isValidColorValue(parsed)) {
      return parsed;
    }
  }

  return fallback;
}

bool _isValidColorValue(int value) {
  return value >= 0 && value <= 0xFFFFFFFF;
}

bool _isValidPlanningLocalDate(String value) {
  if (!_isValidLocalDate(value)) {
    return false;
  }

  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(5, 7));
  final day = int.parse(value.substring(8, 10));
  final parsed = DateTime.utc(year, month, day);

  return parsed.year == year && parsed.month == month && parsed.day == day;
}
