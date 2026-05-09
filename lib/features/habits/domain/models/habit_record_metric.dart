class HabitRecordMetric {
  const HabitRecordMetric({
    required this.id,
    required this.recordId,
    required this.habitId,
    required this.titleSnapshot,
    required this.unitSnapshot,
    required this.numericValue,
    required this.createdAt,
    this.templateId,
  });

  final String id;
  final String recordId;
  final String habitId;
  final String? templateId;
  final String titleSnapshot;
  final String unitSnapshot;
  final double numericValue;
  final DateTime createdAt;

  HabitRecordMetric copyWith({
    String? id,
    String? recordId,
    String? habitId,
    String? templateId,
    bool clearTemplateId = false,
    String? titleSnapshot,
    String? unitSnapshot,
    double? numericValue,
    DateTime? createdAt,
  }) {
    return HabitRecordMetric(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      habitId: habitId ?? this.habitId,
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      unitSnapshot: unitSnapshot ?? this.unitSnapshot,
      numericValue: numericValue ?? this.numericValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recordId': recordId,
      'habitId': habitId,
      'templateId': templateId,
      'titleSnapshot': titleSnapshot,
      'unitSnapshot': unitSnapshot,
      'numericValue': numericValue,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory HabitRecordMetric.fromJson(Map<String, dynamic> json) {
    final id = _readNonEmptyString(json['id']);
    final recordId = _readNonEmptyString(json['recordId']);
    final habitId = _readNonEmptyString(json['habitId']);
    final templateId = _readOptionalString(json['templateId']);
    final titleSnapshot = _readNonEmptyString(json['titleSnapshot']);
    final unitSnapshot = _readNonEmptyString(json['unitSnapshot']);
    final numericValue = _readPositiveFiniteDouble(json['numericValue']);
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (id == null ||
        recordId == null ||
        habitId == null ||
        titleSnapshot == null ||
        unitSnapshot == null ||
        numericValue == null ||
        createdAt == null) {
      throw const FormatException('Invalid habit record metric');
    }
    return HabitRecordMetric(
      id: id,
      recordId: recordId,
      habitId: habitId,
      templateId: templateId,
      titleSnapshot: titleSnapshot,
      unitSnapshot: unitSnapshot,
      numericValue: numericValue,
      createdAt: createdAt,
    );
  }

  static String? _readNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _readOptionalString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _readPositiveFiniteDouble(Object? value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null || !number.isFinite || number <= 0) {
      return null;
    }
    return number;
  }
}
