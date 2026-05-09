enum HabitRecordType {
  checkIn,
  skip,
  makeup;

  String get storageValue {
    switch (this) {
      case HabitRecordType.checkIn:
        return 'checkIn';
      case HabitRecordType.skip:
        return 'skip';
      case HabitRecordType.makeup:
        return 'makeup';
    }
  }

  static HabitRecordType fromStorageValue(String value) {
    switch (value) {
      case 'checkIn':
        return HabitRecordType.checkIn;
      case 'skip':
        return HabitRecordType.skip;
      case 'makeup':
        return HabitRecordType.makeup;
      default:
        throw FormatException('Unsupported habit record type: $value');
    }
  }
}

class HabitRecord {
  const HabitRecord({
    required this.id,
    required this.habitId,
    required this.localDate,
    required this.type,
    required this.createdAt,
    this.note,
  });

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    final localDate = json['localDate'] as String;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(localDate)) {
      throw FormatException('Invalid habit record local date: $localDate');
    }
    final typeValue = json['type'];
    final noteValue = json['note'];

    return HabitRecord(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      localDate: localDate,
      type: typeValue == null
          ? HabitRecordType.checkIn
          : HabitRecordType.fromStorageValue(typeValue as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: noteValue == null ? null : _normalizeNote(noteValue as String),
    );
  }

  final String id;
  final String habitId;
  final String localDate;
  final HabitRecordType type;
  final DateTime createdAt;
  final String? note;

  HabitRecord copyWith({
    String? id,
    String? habitId,
    String? localDate,
    HabitRecordType? type,
    DateTime? createdAt,
    String? note,
    bool clearNote = false,
  }) {
    return HabitRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      localDate: localDate ?? this.localDate,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'habitId': habitId,
      'localDate': localDate,
      'type': type.storageValue,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };

    final note = this.note;
    if (note != null && note.isNotEmpty) {
      json['note'] = note;
    }

    return json;
  }

  static String? _normalizeNote(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
