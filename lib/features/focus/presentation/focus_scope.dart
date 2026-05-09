import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';

class FocusStoreScope extends InheritedNotifier<FocusStore> {
  const FocusStoreScope({
    required FocusStore notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static FocusStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FocusStoreScope>();
    assert(scope != null, 'FocusStoreScope is not available in this context.');
    return scope!.notifier!;
  }
}
