import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';

class AppSettingsScope extends InheritedNotifier<AppSettingsStore> {
  const AppSettingsScope({
    required AppSettingsStore notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static AppSettingsStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();

    assert(scope != null, 'AppSettingsScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
