import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';

class GoalsScope extends InheritedNotifier<GoalsStore> {
  const GoalsScope({
    required GoalsStore notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static GoalsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GoalsScope>();
    assert(scope != null, 'GoalsScope is not available in this context.');
    return scope!.notifier!;
  }

  static GoalsStore? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GoalsScope>()?.notifier;
  }
}
