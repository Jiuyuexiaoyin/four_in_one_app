import 'package:flutter/widgets.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/data/app_settings_local_storage.dart';
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

  final appSettingsStore = await AppSettingsStore.load(
    AppSettingsLocalStorage(),
  );
  final habitReminderNotificationService =
      HabitReminderLocalNotificationService();
  await habitReminderNotificationService.initialize();
  final goalsStore = await GoalsStore.load(GoalsLocalStorage());
  final habitsStore = await HabitsStore.load(
    HabitsLocalStorage(),
    reminderNotificationService: habitReminderNotificationService,
    planRecordWriter: GoalsHabitPlanRecordWriter(goalsStore),
  );
  final focusNotificationService = FocusLocalNotificationService();
  await focusNotificationService.initialize();
  final focusStore = await FocusStore.load(
    FocusLocalStorage(),
    notificationService: focusNotificationService,
  );

  runApp(
    FourInOneApp(
      appSettingsStore: appSettingsStore,
      habitsStore: habitsStore,
      goalsStore: goalsStore,
      focusStore: focusStore,
    ),
  );
}
