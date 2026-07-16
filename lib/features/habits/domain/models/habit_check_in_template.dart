class HabitCheckInTemplate {
  const HabitCheckInTemplate({
    required this.id,
    required this.habitId,
    required this.title,
    required this.unit,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    this.defaultValue,
    this.updatedAt,
  });

  final String id;
  final String habitId;
  final String title;
  final String unit;
  final double? defaultValue;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HabitCheckInTemplate copyWith({
    String? id,
    String? habitId,
    String? title,
    String? unit,
    double? defaultValue,
    bool clearDefaultValue = false,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return HabitCheckInTemplate(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      defaultValue: clearDefaultValue
          ? null
          : (defaultValue ?? this.defaultValue),
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'habitId': habitId,
      'title': title,
      'unit': unit,
      'defaultValue': defaultValue,
      'sortOrder': sortOrder,
      'isArchived': isArchived,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  factory HabitCheckInTemplate.fromJson(Map<String, dynamic> json) {
    final id = _readNonEmptyString(json['id']);
    final habitId = _readNonEmptyString(json['habitId']);
    final title = _readNonEmptyString(json['title']);
    final unit = _readNonEmptyString(json['unit']);
    final sortOrder = _readInt(json['sortOrder']);
    final isArchived = json['isArchived'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (id == null ||
        habitId == null ||
        title == null ||
        unit == null ||
        sortOrder == null ||
        isArchived is! bool ||
        createdAt == null) {
      throw const FormatException('Invalid habit check-in template');
    }

    final defaultValue = _readOptionalFiniteDouble(json['defaultValue']);
    final updatedAtText = json['updatedAt']?.toString();
    final updatedAt = updatedAtText == null || updatedAtText.isEmpty
        ? null
        : DateTime.tryParse(updatedAtText);
    if (json['defaultValue'] != null && defaultValue == null) {
      throw const FormatException('Invalid template default value');
    }
    if (updatedAtText != null &&
        updatedAtText.isNotEmpty &&
        updatedAt == null) {
      throw const FormatException('Invalid template updatedAt');
    }

    return HabitCheckInTemplate(
      id: id,
      habitId: habitId,
      title: title,
      unit: unit,
      defaultValue: defaultValue,
      sortOrder: sortOrder,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _readNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _readOptionalFiniteDouble(Object? value) {
    if (value == null) {
      return null;
    }
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null || !number.isFinite || number < 0) {
      return null;
    }
    return number;
  }
}
