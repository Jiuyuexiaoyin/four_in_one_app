import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';

class HabitsScope extends InheritedNotifier<HabitsStore> {
  const HabitsScope({
    required HabitsStore notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static HabitsStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HabitsScope>();
    assert(scope != null, 'HabitsScope is not available in this context.');
    return scope!.notifier!;
  }
}
