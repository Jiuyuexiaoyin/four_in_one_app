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
    final usesInlineChrome =
        showBottomNavigation &&
        (selectedIndex == 0 ||
            selectedIndex == 1 ||
            selectedIndex == 2 ||
            selectedIndex == 3);
    final showPageAppBar = !usesInlineChrome;
    final usesSettingsCommandChrome = showPageAppBar &&
        !showBottomNavigation &&
        title == '我的';

    return Scaffold(
      extendBody: true,
      backgroundColor: canvasColor,
      appBar: showPageAppBar
          ? usesSettingsCommandChrome
                ? const _SettingsCommandAppBar()
                : AppBar(
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
                padding: EdgeInsets.only(bottom: showBottomNavigation ? 66 : 0),
                child: child,
              ),
            ),
          ),
          if (usesInlineChrome)
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
          if (usesInlineChrome && Navigator.of(context).canPop())
            PositionedDirectional(
              top: 12,
              start: 18,
              child: SafeArea(
                bottom: false,
                child: _ShellBackButton(onPressed: Navigator.of(context).pop),
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

class _SettingsCommandAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _SettingsCommandAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      backgroundColor: const Color(0xFF0B0D0D).withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 78,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 20),
          child: Tooltip(
            message: canPop ? '返回' : 'Theme Studio',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canPop ? Navigator.of(context).pop : null,
                borderRadius: BorderRadius.circular(11),
                child: Ink(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'img',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF0A0C0C),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'STRATEGIC COMMAND',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          Opacity(
            opacity: 0,
            child: Text(
              '我的',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 20),
          child: Tooltip(
            message: 'Theme Studio',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('shell-settings-entry'),
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Ink(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 22,
                    color: colorScheme.onSurface.withValues(alpha: 0.86),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0D0D).withValues(alpha: 0.94),
          border: Border(
            bottom: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.09),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellBackButton extends StatelessWidget {
  const _ShellBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00E5FF);
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF15191A).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Color.lerp(cyan, colorScheme.onSurface, 0.70)!
                    .withValues(alpha: 0.24),
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.86),
            ),
          ),
        ),
      ),
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
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF15191A).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(15),
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
                  Icons.person_outline_rounded,
                  size: 15,
                  color: colorScheme.onSurface.withValues(alpha: 0.86),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 4,
                    height: 4,
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
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E0E).withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(14),
            bottom: Radius.circular(14),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              blurRadius: 18,
              spreadRadius: -12,
              offset: const Offset(0, -3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: NavigationBarTheme(
            data: theme.navigationBarTheme.copyWith(
              height: 54,
              backgroundColor: Colors.transparent,
              indicatorColor: cyan.withValues(alpha: 0.10),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 18,
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
                  fontSize: 8.5,
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
