import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';

const _unsetTarget = Object();

class FocusSessionItem {
  const FocusSessionItem({
    required this.id,
    required this.completedAt,
    required this.durationSeconds,
    this.target,
  });

  final String id;
  final DateTime completedAt;
  final int durationSeconds;
  final FocusTargetSnapshot? target;

  factory FocusSessionItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final completedAt = json['completedAt'];
    final durationSeconds = json['durationSeconds'];

    if (id is! String || id.isEmpty) {
      throw const FormatException('Focus session is missing a valid id.');
    }

    if (completedAt is! String || completedAt.isEmpty) {
      throw const FormatException(
        'Focus session is missing a valid completion time.',
      );
    }

    if (durationSeconds is! int || durationSeconds <= 0) {
      throw const FormatException('Focus session is missing a valid duration.');
    }

    return FocusSessionItem(
      id: id,
      completedAt: DateTime.parse(completedAt).toUtc(),
      durationSeconds: durationSeconds,
      target: FocusTargetSnapshot.tryFromJson(json['target']),
    );
  }

  FocusSessionItem copyWith({
    String? id,
    DateTime? completedAt,
    int? durationSeconds,
    Object? target = _unsetTarget,
  }) {
    return FocusSessionItem(
      id: id ?? this.id,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      target: identical(target, _unsetTarget)
          ? this.target
          : target as FocusTargetSnapshot?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'completedAt': completedAt.toUtc().toIso8601String(),
      'durationSeconds': durationSeconds,
      'target': target?.toJson(),
    };
  }
}
