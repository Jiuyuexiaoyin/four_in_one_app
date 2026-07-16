import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';

class NotificationRuntimeScope
    extends InheritedNotifier<NotificationRuntimeController> {
  const NotificationRuntimeScope({
    required NotificationRuntimeController notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static NotificationRuntimeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<NotificationRuntimeScope>();
    assert(scope != null, 'NotificationRuntimeScope is missing.');
    return scope!.notifier!;
  }

  static NotificationRuntimeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NotificationRuntimeScope>()
        ?.notifier;
  }
}
