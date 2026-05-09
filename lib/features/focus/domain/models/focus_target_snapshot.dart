class FocusTargetSnapshot {
  const FocusTargetSnapshot({
    required this.taskId,
    required this.title,
    required this.context,
  });

  final String taskId;
  final String title;
  final String context;

  factory FocusTargetSnapshot.fromJson(Map<String, dynamic> json) {
    final taskId = json['taskId'];
    final title = json['title'];
    final context = json['context'];

    if (taskId is! String || taskId.isEmpty) {
      throw const FormatException('Focus target is missing a valid task id.');
    }

    if (title is! String || title.isEmpty) {
      throw const FormatException('Focus target is missing a valid title.');
    }

    if (context is! String || context.isEmpty) {
      throw const FormatException('Focus target is missing a valid context.');
    }

    return FocusTargetSnapshot(taskId: taskId, title: title, context: context);
  }

  static FocusTargetSnapshot? tryFromJson(Object? value) {
    try {
      if (value is! Map) {
        return null;
      }

      return FocusTargetSnapshot.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'taskId': taskId,
      'title': title,
      'context': context,
    };
  }
}
