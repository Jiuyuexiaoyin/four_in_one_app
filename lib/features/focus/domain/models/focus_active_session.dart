import 'package:four_in_one_app/features/focus/domain/models/focus_target_snapshot.dart';

enum FocusActiveSessionStatus { running, paused }

class FocusActiveSession {
  const FocusActiveSession({
    required this.status,
    required this.startedAt,
    required this.targetEndAt,
    required this.remainingSeconds,
    required this.durationSeconds,
    this.target,
  });

  final FocusActiveSessionStatus status;
  final DateTime startedAt;
  final DateTime? targetEndAt;
  final int remainingSeconds;
  final int durationSeconds;
  final FocusTargetSnapshot? target;

  factory FocusActiveSession.fromJson(Map<String, dynamic> json) {
    final status = _parseStatus(json['status']);
    final startedAt = json['startedAt'];
    final targetEndAt = json['targetEndAt'];
    final remainingSeconds = json['remainingSeconds'];
    final durationSeconds = json['durationSeconds'];

    if (startedAt is! String || startedAt.isEmpty) {
      throw const FormatException(
        'Active focus session is missing a valid start time.',
      );
    }

    if (remainingSeconds is! int || remainingSeconds < 0) {
      throw const FormatException(
        'Active focus session is missing a valid remaining duration.',
      );
    }

    if (durationSeconds is! int || durationSeconds <= 0) {
      throw const FormatException(
        'Active focus session is missing a valid total duration.',
      );
    }

    final parsedTargetEndAt = targetEndAt == null
        ? null
        : targetEndAt is String && targetEndAt.isNotEmpty
        ? DateTime.parse(targetEndAt).toUtc()
        : throw const FormatException(
            'Active focus session has an invalid target end time.',
          );

    if (status == FocusActiveSessionStatus.running &&
        parsedTargetEndAt == null) {
      throw const FormatException(
        'Running focus session requires a target end time.',
      );
    }

    return FocusActiveSession(
      status: status,
      startedAt: DateTime.parse(startedAt).toUtc(),
      targetEndAt: parsedTargetEndAt,
      remainingSeconds: remainingSeconds,
      durationSeconds: durationSeconds,
      target: FocusTargetSnapshot.tryFromJson(json['target']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': switch (status) {
        FocusActiveSessionStatus.running => 'running',
        FocusActiveSessionStatus.paused => 'paused',
      },
      'startedAt': startedAt.toUtc().toIso8601String(),
      'targetEndAt': targetEndAt?.toUtc().toIso8601String(),
      'remainingSeconds': remainingSeconds,
      'durationSeconds': durationSeconds,
      'target': target?.toJson(),
    };
  }

  static FocusActiveSessionStatus _parseStatus(Object? value) {
    return switch (value) {
      'running' => FocusActiveSessionStatus.running,
      'paused' => FocusActiveSessionStatus.paused,
      _ => throw const FormatException(
        'Active focus session is missing a valid status.',
      ),
    };
  }
}
