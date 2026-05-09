class HabitRecordAttachment {
  const HabitRecordAttachment({
    required this.id,
    required this.recordId,
    required this.habitId,
    required this.relativePath,
    required this.fileName,
    this.mimeType,
    required this.createdAt,
  });

  final String id;
  final String recordId;
  final String habitId;
  final String relativePath;
  final String fileName;
  final String? mimeType;
  final DateTime createdAt;

  factory HabitRecordAttachment.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final recordId = json['recordId'];
    final habitId = json['habitId'];
    final relativePath = json['relativePath'];
    final fileName = json['fileName'];
    final rawMimeType = json['mimeType'];

    if (id is! String || id.isEmpty) {
      throw const FormatException('Habit record attachment is missing an id.');
    }

    if (recordId is! String || recordId.isEmpty) {
      throw const FormatException(
        'Habit record attachment is missing a record id.',
      );
    }

    if (habitId is! String || habitId.isEmpty) {
      throw const FormatException(
        'Habit record attachment is missing a habit id.',
      );
    }

    if (relativePath is! String || relativePath.isEmpty) {
      throw const FormatException(
        'Habit record attachment is missing a relative path.',
      );
    }

    if (fileName is! String || fileName.isEmpty) {
      throw const FormatException(
        'Habit record attachment is missing a file name.',
      );
    }

    if (rawMimeType != null && rawMimeType is! String) {
      throw const FormatException(
        'Habit record attachment mime type is invalid.',
      );
    }

    final createdAt = DateTime.parse(json['createdAt'] as String).toUtc();
    final mimeType = rawMimeType?.trim();

    return HabitRecordAttachment(
      id: id,
      recordId: recordId,
      habitId: habitId,
      relativePath: relativePath,
      fileName: fileName,
      mimeType: mimeType == null || mimeType.isEmpty ? null : mimeType,
      createdAt: createdAt,
    );
  }

  HabitRecordAttachment copyWith({
    String? id,
    String? recordId,
    String? habitId,
    String? relativePath,
    String? fileName,
    String? mimeType,
    DateTime? createdAt,
    bool clearMimeType = false,
  }) {
    return HabitRecordAttachment(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      habitId: habitId ?? this.habitId,
      relativePath: relativePath ?? this.relativePath,
      fileName: fileName ?? this.fileName,
      mimeType: clearMimeType ? null : mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recordId': recordId,
      'habitId': habitId,
      'relativePath': relativePath,
      'fileName': fileName,
      'mimeType': mimeType,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
