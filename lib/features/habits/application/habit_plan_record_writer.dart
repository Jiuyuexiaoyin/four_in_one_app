import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';

class GoalsHabitPlanRecordWriter implements HabitPlanRecordWriter {
  const GoalsHabitPlanRecordWriter(this._goalsStore);

  final GoalsStore _goalsStore;

  @override
  Future<void> recordDailyCompletion({
    required HabitItem habit,
    required String localDate,
    required int effectiveCount,
  }) async {
    final link = habit.planLink;
    if (link == null) {
      return;
    }

    final taskId = link.targetType == HabitPlanLinkTargetType.task
        ? link.taskId
        : null;
    if (link.targetType == HabitPlanLinkTargetType.project &&
        _goalsStore.projectById(link.projectId) == null) {
      return;
    }
    if (link.targetType == HabitPlanLinkTargetType.task) {
      final task = taskId == null ? null : _goalsStore.taskById(taskId);
      if (task == null || task.projectId != link.projectId) {
        return;
      }
    }

    await _goalsStore.createHabitLinkedCompletionRecord(
      habitId: habit.id,
      habitName: habit.name,
      projectId: link.projectId,
      taskId: taskId,
      localDate: localDate,
      effectiveCount: effectiveCount,
      targetCount: habit.targetCountPerDay,
    );
  }
}
