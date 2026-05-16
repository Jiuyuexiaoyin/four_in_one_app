import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

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
    AppRoute.review,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canvasColor = theme.scaffoldBackgroundColor;
    final shellSurface =
        Color.lerp(colorScheme.surface, canvasColor, 0.26) ??
        colorScheme.surface;
    final isTodayTab = showBottomNavigation && currentIndex == 0;
    final showPageAppBar = !isTodayTab;

    return Scaffold(
      extendBody: true,
      backgroundColor: canvasColor,
      appBar: showPageAppBar
          ? AppBar(
              title: Text(title),
              flexibleSpace: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      canvasColor.withValues(alpha: 0.98),
                      Color.lerp(canvasColor, colorScheme.primary, 0.06) ??
                          canvasColor,
                      shellSurface.withValues(alpha: 0.90),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.settings),
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: '我的',
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppThemeTokens.pageBackgroundGradient(colorScheme),
              ),
            ),
          ),
          Positioned(
            top: -118,
            left: -98,
            child: _AmbientGlow(
              size: 250,
              color: colorScheme.primary.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            top: 120,
            right: -116,
            child: _AmbientGlow(
              size: 210,
              color: colorScheme.secondary.withValues(alpha: 0.12),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              top: !showPageAppBar,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: showBottomNavigation ? 82 : 0,
                ),
                child: child,
              ),
            ),
          ),
          if (isTodayTab)
            PositionedDirectional(
              top: 12,
              end: 18,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoute.settings),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: '我的',
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: showBottomNavigation
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: shellSurface.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: NavigationBar(
                      height: 54,
                      backgroundColor: Colors.transparent,
                      indicatorColor: colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      selectedIndex: currentIndex,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (index) {
                        if (index == currentIndex) {
                          return;
                        }
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(_routes[index]);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined, size: 19),
                          selectedIcon: Icon(Icons.home, size: 19),
                          label: '今天',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 19,
                          ),
                          selectedIcon: Icon(
                            Icons.check_circle_rounded,
                            size: 19,
                          ),
                          label: '习惯',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.track_changes_outlined, size: 19),
                          selectedIcon: Icon(Icons.track_changes, size: 19),
                          label: '计划',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.timer_outlined, size: 19),
                          selectedIcon: Icon(Icons.timer, size: 19),
                          label: '专注',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.insights_outlined, size: 19),
                          selectedIcon: Icon(Icons.insights, size: 19),
                          label: '复盘',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
