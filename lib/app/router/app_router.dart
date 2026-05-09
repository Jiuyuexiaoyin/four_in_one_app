import 'package:flutter/material.dart';
import 'package:four_in_one_app/features/focus/presentation/pages/focus_page.dart';
import 'package:four_in_one_app/features/goals/presentation/pages/goals_page.dart';
import 'package:four_in_one_app/features/habits/presentation/pages/habits_page.dart';
import 'package:four_in_one_app/features/review/presentation/pages/review_page.dart';
import 'package:four_in_one_app/features/settings/presentation/pages/settings_page.dart';
import 'package:four_in_one_app/features/today/presentation/pages/today_page.dart';
import 'package:four_in_one_app/shared/widgets/app_shell.dart';

abstract final class AppRoute {
  static const root = '/';
  static const today = '/today';
  static const habits = '/habits';
  static const goals = '/goals';
  static const focus = '/focus';
  static const review = '/review';
  static const settings = '/settings';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name ?? AppRoute.root) {
      case AppRoute.root:
      case AppRoute.today:
        return _buildRoute(
          settings,
          const AppShell(title: '今日', currentIndex: 0, child: TodayPage()),
        );
      case AppRoute.habits:
        return _buildRoute(settings, const HabitsPage());
      case AppRoute.goals:
        return _buildRoute(
          settings,
          const AppShell(title: '计划', currentIndex: 1, child: GoalsPage()),
        );
      case AppRoute.focus:
        return _buildRoute(
          settings,
          const AppShell(title: '专注', currentIndex: 2, child: FocusPage()),
        );
      case AppRoute.review:
        return _buildRoute(
          settings,
          const AppShell(title: '复盘', currentIndex: 3, child: ReviewPage()),
        );
      case AppRoute.settings:
        return _buildRoute(
          settings,
          const AppShell(
            title: '我的',
            currentIndex: 4,
            child: SettingsPage(showScaffold: false),
          ),
        );
      default:
        return _buildRoute(
          const RouteSettings(name: AppRoute.today),
          const AppShell(title: '今日', currentIndex: 0, child: TodayPage()),
        );
    }
  }

  static MaterialPageRoute<void> _buildRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}
