import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/presentation/app_settings_scope.dart';
import 'package:four_in_one_app/app/theme/app_theme.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';

class FourInOneApp extends StatefulWidget {
  const FourInOneApp({
    required this.habitsStore,
    required this.goalsStore,
    this.appSettingsStore,
    this.focusStore,
    super.key,
  });

  final HabitsStore habitsStore;
  final GoalsStore goalsStore;
  final AppSettingsStore? appSettingsStore;
  final FocusStore? focusStore;

  @override
  State<FourInOneApp> createState() => _FourInOneAppState();
}

class _FourInOneAppState extends State<FourInOneApp> {
  late final AppSettingsStore _appSettingsStore;
  late final FocusStore _focusStore;

  @override
  void initState() {
    super.initState();
    _appSettingsStore = widget.appSettingsStore ?? AppSettingsStore.inMemory();
    _focusStore = widget.focusStore ?? FocusStore.inMemory();
  }

  @override
  void dispose() {
    _focusStore.dispose();
    _appSettingsStore.dispose();
    widget.goalsStore.dispose();
    widget.habitsStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoalsScope(
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
                final backgroundColor = _appSettingsStore.customBackgroundColor;
                final surfaceColor = _appSettingsStore.customSurfaceColor;

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Four In One',
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
    );
  }
}
