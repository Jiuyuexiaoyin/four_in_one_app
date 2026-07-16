import 'dart:async';

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/presentation/app_settings_scope.dart';
import 'package:four_in_one_app/app/theme/app_theme.dart';
import 'package:four_in_one_app/core/notifications/app_notification_routing.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/data/habit_reminder_notification_service.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';

class FourInOneApp extends StatefulWidget {
  const FourInOneApp({
    required this.habitsStore,
    required this.goalsStore,
    this.appSettingsStore,
    this.focusStore,
    this.notificationRuntimeController,
    this.habitReminderNotificationService,
    super.key,
  });

  final HabitsStore habitsStore;
  final GoalsStore goalsStore;
  final AppSettingsStore? appSettingsStore;
  final FocusStore? focusStore;
  final NotificationRuntimeController? notificationRuntimeController;
  final HabitReminderNotificationService? habitReminderNotificationService;

  @override
  State<FourInOneApp> createState() => _FourInOneAppState();
}

class _FourInOneAppState extends State<FourInOneApp>
    with WidgetsBindingObserver {
  late final AppSettingsStore _appSettingsStore;
  late final FocusStore _focusStore;
  late final NotificationRuntimeController _notificationRuntimeController;
  late final StreamSubscription<AppNotificationDestination>
  _notificationDestinationSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<AppNotificationDestination> _pendingDestinations =
      <AppNotificationDestination>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appSettingsStore = widget.appSettingsStore ?? AppSettingsStore.inMemory();
    _focusStore = widget.focusStore ?? FocusStore.inMemory();
    _notificationRuntimeController =
        widget.notificationRuntimeController ??
        NotificationRuntimeController.noop();
    _notificationDestinationSubscription = _notificationRuntimeController
        .destinations
        .listen(_queueNotificationDestination);
    unawaited(_initializeNotificationRouting());
  }

  Future<void> _initializeNotificationRouting() async {
    await _notificationRuntimeController.initialize();
    while (mounted) {
      final initialDestination = _notificationRuntimeController
          .takeInitialDestination();
      if (initialDestination == null) {
        break;
      }
      _queueNotificationDestination(initialDestination);
    }
  }

  void _queueNotificationDestination(AppNotificationDestination destination) {
    _pendingDestinations.add(destination);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drainNotificationDestinations();
    });
  }

  void _drainNotificationDestinations() {
    if (!mounted || _pendingDestinations.isEmpty) {
      return;
    }
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drainNotificationDestinations();
      });
      return;
    }

    final destination = _pendingDestinations.removeAt(0);
    unawaited(
      navigator.pushNamed<void>(
        destination.route,
        arguments: destination.entityId,
      ),
    );
    if (_pendingDestinations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drainNotificationDestinations();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    unawaited(_refreshNotificationRuntimeAfterResume());
  }

  Future<void> _refreshNotificationRuntimeAfterResume() async {
    await _notificationRuntimeController.refresh();
    final timeZoneChanged = await _notificationRuntimeController
        .refreshTimeZone();
    final reminderService = widget.habitReminderNotificationService;
    if (timeZoneChanged && reminderService != null) {
      await reminderService.resyncReminders(widget.habitsStore.habits);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_notificationDestinationSubscription.cancel());
    _notificationRuntimeController.dispose();
    _focusStore.dispose();
    _appSettingsStore.dispose();
    widget.goalsStore.dispose();
    widget.habitsStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationRuntimeScope(
      notifier: _notificationRuntimeController,
      child: GoalsScope(
        notifier: widget.goalsStore,
        child: FocusStoreScope(
          notifier: _focusStore,
          child: HabitsScope(
            notifier: widget.habitsStore,
            child: AppSettingsScope(
              notifier: _appSettingsStore,
              child: AnimatedBuilder(
                animation: _appSettingsStore,
                builder: (context, _) {
                  final accentColor = _appSettingsStore.accentColor;
                  final backgroundColor =
                      _appSettingsStore.customBackgroundColor;
                  final surfaceColor = _appSettingsStore.customSurfaceColor;

                  return MaterialApp(
                    navigatorKey: _navigatorKey,
                    debugShowCheckedModeBanner: false,
                    title: 'Get Ready',
                    theme: AppTheme.light(
                      accentColor: accentColor,
                      backgroundColor: backgroundColor,
                      surfaceColor: surfaceColor,
                    ),
                    darkTheme: AppTheme.dark(
                      accentColor: accentColor,
                      backgroundColor: backgroundColor,
                      surfaceColor: surfaceColor,
                    ),
                    themeMode: _appSettingsStore.materialThemeMode,
                    initialRoute: AppRoute.root,
                    onGenerateRoute: AppRouter.onGenerateRoute,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
