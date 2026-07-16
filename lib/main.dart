import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/data/app_settings_local_storage.dart';
import 'package:four_in_one_app/core/media/android_photo_picker.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/data/focus_local_storage.dart';
import 'package:four_in_one_app/features/focus/data/focus_notification_service.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/data/goals_local_storage.dart';
import 'package:four_in_one_app/features/habits/application/habit_plan_record_writer.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habit_reminder_notification_service.dart';
import 'package:four_in_one_app/features/habits/data/habits_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAndroidPhotoPicker();

  final appSettingsStore = await AppSettingsStore.load(
    AppSettingsLocalStorage(),
  );
  final appNotificationService = AppLocalNotificationService(
    accentColorValue: appSettingsStore.accentColor.toARGB32(),
  );
  final notificationRuntimeController = NotificationRuntimeController(
    permissionCoordinator: AndroidPermissionCoordinator(),
    notificationService: appNotificationService,
  );
  await notificationRuntimeController.initialize();
  final habitReminderNotificationService =
      HabitReminderLocalNotificationService(
        appNotificationService: appNotificationService,
      );
  final goalsStore = await GoalsStore.load(GoalsLocalStorage());
  final habitsStore = await HabitsStore.load(
    HabitsLocalStorage(),
    reminderNotificationService: habitReminderNotificationService,
    planRecordWriter: GoalsHabitPlanRecordWriter(goalsStore),
  );
  final focusNotificationService = FocusLocalNotificationService(
    appNotificationService: appNotificationService,
  );
  final focusStore = await FocusStore.load(
    FocusLocalStorage(),
    notificationService: focusNotificationService,
  );
  if (focusStore.isIdle) {
    // Repair a stale completion left by an interrupted reset/old app version.
    // A restored running round has already reconciled its own target above.
    try {
      await focusNotificationService.clearFocusNotifications();
    } catch (_) {
      // Notification repair must never prevent the application from opening.
    }
  }

  runApp(
    FourInOneApp(
      appSettingsStore: appSettingsStore,
      habitsStore: habitsStore,
      goalsStore: goalsStore,
      focusStore: focusStore,
      notificationRuntimeController: notificationRuntimeController,
      habitReminderNotificationService: habitReminderNotificationService,
    ),
  );
}
