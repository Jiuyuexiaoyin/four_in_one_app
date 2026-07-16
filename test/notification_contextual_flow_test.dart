import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/core/permissions/android_permission_coordinator.dart';
import 'package:four_in_one_app/core/permissions/app_permission.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/focus/presentation/pages/focus_page.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/features/habits/presentation/pages/habits_page.dart';

void main() {
  testWidgets('enabling a Habit reminder requests notification in context', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final permissions = _PermissionCoordinator();
    final runtime = NotificationRuntimeController(
      permissionCoordinator: permissions,
      notificationService: AppLocalNotificationService(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
    );
    addTearDown(runtime.dispose);
    final store = HabitsStore.seededInMemory(
      initialHabits: [
        HabitItem(
          id: 'habit-1',
          name: '喝水',
          emoji: '💧',
          description: '',
          targetCountPerDay: 1,
          reminderTime: null,
          createdAt: DateTime.utc(2026, 7, 13, 8),
        ),
      ],
    );
    addTearDown(store.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationRuntimeScope(
          notifier: runtime,
          child: HabitsScope(
            notifier: store,
            child: const Scaffold(body: HabitsPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('habit-reminder-habit-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-add-rule')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-rule-time-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-preset-08:30')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('habit-reminder-rules-save')));
    await tester.pumpAndSettle();

    expect(find.text('开启通知'), findsOneWidget);
    expect(store.habits.single.reminderRules, isEmpty);

    await tester.tap(
      find.byKey(const ValueKey('notification-permission-continue')),
    );
    await tester.pumpAndSettle();

    expect(permissions.requestCalls, 1);
    expect(store.habits.single.enabledReminderRules, hasLength(1));
    expect(store.habits.single.reminderTime, '08:30');
  });

  testWidgets('Habit denial preserves reminder and exposes Settings fallback', (
    tester,
  ) async {
    _configureLargeTestView(tester);

    final permissions = _PermissionCoordinator(
      requestStatus: AppPermissionStatus.denied,
    );
    final runtime = _runtimeFor(permissions);
    addTearDown(runtime.dispose);
    final store = _habitStoreWithoutReminder();
    addTearDown(store.dispose);

    await _pumpHabitPage(tester, runtime: runtime, store: store);
    await _openAndSaveFirstHabitReminder(tester);

    expect(find.text('开启通知'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('notification-permission-continue')),
    );
    await tester.pumpAndSettle();

    expect(permissions.requestCalls, 1);
    expect(store.habits.single.enabledReminderRules, hasLength(1));
    expect(store.habits.single.reminderTime, '08:30');

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('提醒已保存，但 Android 尚未允许显示通知。'), findsOneWidget);
    expect(find.text('系统设置'), findsOneWidget);

    await tester.tap(find.text('系统设置'));
    await tester.pump();
    expect(permissions.openSettingsCalls, 1);
  });

  testWidgets(
    'Focus denial still starts timer and explains notification state',
    (tester) async {
      _configureLargeTestView(tester);

      final permissions = _PermissionCoordinator(
        requestStatus: AppPermissionStatus.denied,
      );
      final runtime = _runtimeFor(permissions);
      addTearDown(runtime.dispose);
      final focusStore = FocusStore.inMemory();
      final goalsStore = GoalsStore.inMemory();
      addTearDown(focusStore.dispose);
      addTearDown(goalsStore.dispose);

      await _pumpFocusPage(
        tester,
        runtime: runtime,
        focusStore: focusStore,
        goalsStore: goalsStore,
      );
      await _tapFocusStart(tester);

      expect(find.text('开启通知'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('notification-permission-continue')),
      );
      await tester.pumpAndSettle();

      expect(permissions.requestCalls, 1);
      expect(focusStore.isRunning, isTrue);
      expect(find.text('专注已开始，但 Android 尚未允许完成通知。'), findsOneWidget);

      await tester.tap(find.text('系统设置'));
      await tester.pump();
      expect(permissions.openSettingsCalls, 1);
      focusStore.reset();
      await tester.pump();
    },
  );

  testWidgets(
    'Focus settings-required state starts timer without re-request loop',
    (tester) async {
      _configureLargeTestView(tester);

      final permissions = _PermissionCoordinator(
        status: AppPermissionStatus.settingsRequired,
      );
      final runtime = _runtimeFor(permissions);
      addTearDown(runtime.dispose);
      final focusStore = FocusStore.inMemory();
      final goalsStore = GoalsStore.inMemory();
      addTearDown(focusStore.dispose);
      addTearDown(goalsStore.dispose);

      await _pumpFocusPage(
        tester,
        runtime: runtime,
        focusStore: focusStore,
        goalsStore: goalsStore,
      );
      await _tapFocusStart(tester);

      expect(find.text('前往系统设置'), findsOneWidget);
      await tester.tap(find.text('暂不开启'));
      await tester.pumpAndSettle();

      expect(permissions.requestCalls, 0);
      expect(focusStore.isRunning, isTrue);
      expect(find.text('专注已开始，请在系统设置中开启完成通知。'), findsOneWidget);

      await tester.tap(find.text('系统设置'));
      await tester.pump();
      expect(permissions.openSettingsCalls, 1);
      focusStore.reset();
      await tester.pump();
    },
  );
}

void _configureLargeTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

NotificationRuntimeController _runtimeFor(
  AppPermissionCoordinator permissions,
) {
  return NotificationRuntimeController(
    permissionCoordinator: permissions,
    notificationService: AppLocalNotificationService(
      isWeb: true,
      platform: TargetPlatform.android,
    ),
  );
}

HabitsStore _habitStoreWithoutReminder() {
  return HabitsStore.seededInMemory(
    initialHabits: [
      HabitItem(
        id: 'habit-1',
        name: '喝水',
        emoji: '💧',
        description: '',
        targetCountPerDay: 1,
        reminderTime: null,
        createdAt: DateTime.utc(2026, 7, 13, 8),
      ),
    ],
  );
}

Future<void> _pumpHabitPage(
  WidgetTester tester, {
  required NotificationRuntimeController runtime,
  required HabitsStore store,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationRuntimeScope(
        notifier: runtime,
        child: HabitsScope(
          notifier: store,
          child: const Scaffold(body: HabitsPage()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openAndSaveFirstHabitReminder(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('habit-reminder-habit-1')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-add-rule')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-rule-time-0')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-preset-08:30')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-save')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('habit-reminder-rules-save')));
  await tester.pumpAndSettle();
}

Future<void> _pumpFocusPage(
  WidgetTester tester, {
  required NotificationRuntimeController runtime,
  required FocusStore focusStore,
  required GoalsStore goalsStore,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationRuntimeScope(
        notifier: runtime,
        child: GoalsScope(
          notifier: goalsStore,
          child: FocusStoreScope(
            notifier: focusStore,
            child: const Scaffold(body: FocusPage()),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapFocusStart(WidgetTester tester) async {
  final startButton = find.widgetWithText(FilledButton, '开始');
  await tester.ensureVisible(startButton);
  await tester.pumpAndSettle();
  await tester.tap(startButton);
  await tester.pumpAndSettle();
}

class _PermissionCoordinator implements AppPermissionCoordinator {
  _PermissionCoordinator({
    this.status = AppPermissionStatus.denied,
    this.requestStatus = AppPermissionStatus.granted,
  });

  AppPermissionStatus status;
  final AppPermissionStatus requestStatus;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<AppPermissionResult> check(AppPermission permission) async {
    return AppPermissionResult(
      permission: permission,
      status: status,
      apiLevel: 35,
    );
  }

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    requestCalls += 1;
    status = requestStatus;
    return AppPermissionResult(
      permission: permission,
      status: status,
      didRequest: true,
      apiLevel: 35,
    );
  }

  @override
  Future<bool> openSettings(AppPermission permission) async {
    openSettingsCalls += 1;
    return true;
  }

  @override
  Future<bool> openNotificationChannelSettings(String channelId) async => true;
}
