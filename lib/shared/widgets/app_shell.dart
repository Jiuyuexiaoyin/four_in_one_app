import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.currentIndex,
    required this.child,
    this.showBottomNavigation = true,
    super.key,
  });

  final String title;
  final int currentIndex;
  final Widget child;
  final bool showBottomNavigation;

  static const _routes = <String>[
    AppRoute.today,
    AppRoute.habits,
    AppRoute.goals,
    AppRoute.focus,
  ];

  static const _items = <StitchExactBottomNavItem>[
    StitchExactBottomNavItem(
      label: '今天',
      icon: Icons.calendar_today_outlined,
      route: AppRoute.today,
    ),
    StitchExactBottomNavItem(
      label: '习惯',
      icon: Icons.account_tree_outlined,
      route: AppRoute.habits,
    ),
    StitchExactBottomNavItem(
      label: '计划',
      icon: Icons.event_note_outlined,
      route: AppRoute.goals,
    ),
    StitchExactBottomNavItem(
      label: '专注',
      icon: Icons.timer_outlined,
      route: AppRoute.focus,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clampedIndex = currentIndex.clamp(0, _routes.length - 1);
    final routeName = ModalRoute.of(context)?.settings.name;
    final showSettingsAction =
        !showBottomNavigation && routeName != AppRoute.settings;
    return Scaffold(
      key: const ValueKey('app-shell-scaffold'),
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: showBottomNavigation
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: colorScheme.surfaceContainerLowest,
              foregroundColor: colorScheme.onSurface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                key: const ValueKey('secondary-back-button'),
                tooltip: '返回',
                onPressed: () {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                    return;
                  }
                  navigator.pushReplacementNamed(AppRoute.today);
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
              actions: showSettingsAction
                  ? [
                      IconButton(
                        tooltip: '我的/设置',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoute.settings),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ]
                  : null,
            ),
      body: Material(
        key: const ValueKey('app-shell-body-surface'),
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(top: showBottomNavigation, bottom: false, child: child),
      ),
      bottomNavigationBar: showBottomNavigation
          ? StitchExactBottomNav(
              items: _items,
              currentIndex: clampedIndex,
              onSelected: (index) {
                if (index == clampedIndex) return;
                Navigator.of(context).pushReplacementNamed(_routes[index]);
              },
            )
          : null,
    );
  }
}
