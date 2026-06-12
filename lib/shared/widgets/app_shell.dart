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
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canvasColor = theme.scaffoldBackgroundColor;
    final shellSurface =
        Color.lerp(colorScheme.surface, canvasColor, 0.26) ??
        colorScheme.surface;
    final selectedIndex = currentIndex.clamp(0, _routes.length - 1).toInt();
    final isTodayTab = showBottomNavigation && selectedIndex == 0;
    final showPageAppBar = !isTodayTab;

    return Scaffold(
      extendBody: true,
      backgroundColor: canvasColor,
      appBar: showPageAppBar
          ? AppBar(
              title: Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              flexibleSpace: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      canvasColor.withValues(alpha: 0.96),
                      Color.lerp(canvasColor, colorScheme.primary, 0.04) ??
                          canvasColor,
                      shellSurface.withValues(alpha: 0.86),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: _ShellUtilityButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoute.settings),
                  ),
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
                padding: EdgeInsets.only(bottom: showBottomNavigation ? 82 : 0),
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
                child: _ShellUtilityButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoute.settings),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: showBottomNavigation
          ? SafeArea(
              top: false,
              child: _PerformanceBottomNavigation(
                selectedIndex: selectedIndex,
                onSelected: (index) {
                  if (index == selectedIndex) {
                    return;
                  }
                  Navigator.of(context).pushReplacementNamed(_routes[index]);
                },
              ),
            )
          : null,
    );
  }
}

class _ShellUtilityButton extends StatelessWidget {
  const _ShellUtilityButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: '我的 / Theme Studio',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('shell-settings-entry'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1B1B).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(cyan, colorScheme.onSurface, 0.70)!
                    .withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: cyan.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cyan,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withValues(alpha: 0.55),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceBottomNavigation extends StatelessWidget {
  const _PerformanceBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_PerformanceNavItem>[
    _PerformanceNavItem(
      label: '今天',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
    ),
    _PerformanceNavItem(
      label: '习惯',
      icon: Icons.check_circle_outline_rounded,
      selectedIcon: Icons.check_circle_rounded,
    ),
    _PerformanceNavItem(
      label: '计划',
      icon: Icons.track_changes_outlined,
      selectedIcon: Icons.track_changes,
    ),
    _PerformanceNavItem(
      label: '专注',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E0E).withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
            bottom: Radius.circular(24),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: -12,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBarTheme(
            data: theme.navigationBarTheme.copyWith(
              height: 68,
              backgroundColor: Colors.transparent,
              indicatorColor: cyan.withValues(alpha: 0.13),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 20,
                  color: selected
                      ? cyan
                      : AppThemeTokens.secondaryTextTone(
                          colorScheme,
                        ).withValues(alpha: 0.68),
                  shadows: selected
                      ? [
                          Shadow(
                            color: cyan.withValues(alpha: 0.58),
                            blurRadius: 8,
                          ),
                        ]
                      : const [],
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? cyan
                      : AppThemeTokens.secondaryTextTone(
                          colorScheme,
                        ).withValues(alpha: 0.70),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  height: 1,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceNavItem {
  const _PerformanceNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
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
