import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/app/app.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/features/focus/application/focus_store.dart';
import 'package:four_in_one_app/features/focus/domain/models/focus_session_item.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/habits/application/habits_store.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';

void main() {
  testWidgets('Settings page can change theme mode', (tester) async {
    final settingsStore = AppSettingsStore.inMemory();

    await _pumpApp(tester, settingsStore);
    await _openSettings(tester);
    await _ensureVisible(tester, const ValueKey('settings-theme-mode-dark'));

    expect(find.text('外观'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings-theme-mode-dark')));
    await tester.pumpAndSettle();

    expect(settingsStore.themeMode, AppThemeMode.dark);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('Settings page can change accent color', (tester) async {
    final settingsStore = AppSettingsStore.inMemory();
    const accentOptions = <_AccentExpectation>[
      _AccentExpectation(label: '松绿色', color: Color(0xFF2E6B5A)),
      _AccentExpectation(label: '鼠尾草绿', color: Color(0xFF6F7F69)),
      _AccentExpectation(label: '雾蓝色', color: Color(0xFF6E7E9E)),
      _AccentExpectation(label: '陶土色', color: Color(0xFF8A6F6A)),
      _AccentExpectation(label: '灰紫色', color: Color(0xFF7A6F8F)),
    ];

    await _pumpApp(tester, settingsStore);
    await _openSettings(tester);
    await _ensureVisible(tester, const ValueKey('theme-studio-more-palettes'));

    expect(find.text('界面强调色'), findsOneWidget);
    expect(find.text('影响按钮、选中态和强调元素'), findsOneWidget);
    expect(find.text('主题色'), findsNothing);
    expect(
      find.byKey(const ValueKey('theme-studio-current-palette')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('theme-studio-more-palettes')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('更多色卡'),
      ),
      findsOneWidget,
    );

    for (final accentOption in accentOptions) {
      final optionFinder = find.byKey(ValueKey<String>(accentOption.optionKey));
      await tester.ensureVisible(optionFinder);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: optionFinder,
          matching: find.text(accentOption.label),
        ),
        findsOneWidget,
      );
      await tester.tap(optionFinder);
      await tester.pumpAndSettle();

      expect(
        settingsStore.accentColor.toARGB32(),
        accentOption.color.toARGB32(),
      );
      expect(
        find.byKey(ValueKey<String>(accentOption.selectedKey)),
        findsOneWidget,
      );
    }

    await tester.tap(
      find.byKey(const ValueKey('theme-studio-more-palettes-close')),
    );
    await tester.pumpAndSettle();
    await _ensureVisible(tester, const ValueKey('theme-studio-reset-accent'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-reset-accent')));
    await tester.pumpAndSettle();

    expect(
      settingsStore.accentColor.toARGB32(),
      AppSettingsStore.defaultAccentColor.toARGB32(),
    );
  });

  testWidgets('Theme Studio accepts HEX, RGB, ARGB, and reset inputs', (
    tester,
  ) async {
    final settingsStore = AppSettingsStore.inMemory();

    await _pumpApp(tester, settingsStore);
    await _openSettings(tester);
    await _ensureVisible(tester, const ValueKey('theme-studio-visual-picker'));

    expect(find.text('颜色工作室'), findsOneWidget);
    expect(find.text('背景颜色'), findsWidgets);
    expect(find.text('卡片颜色'), findsWidgets);
    expect(find.text('UI 强调色'), findsWidgets);
    expect(
      find.byKey(const ValueKey('theme-studio-visual-picker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('theme-studio-color-square')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('theme-studio-hue-slider')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('theme-studio-hex-input')), findsNothing);

    await _ensureVisible(tester, const ValueKey('theme-studio-color-square'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-color-square')));
    await tester.pumpAndSettle();
    expect(
      settingsStore.accentColor.toARGB32(),
      isNot(AppSettingsStore.defaultAccentColor.toARGB32()),
    );

    await _ensureVisible(tester, const ValueKey('theme-studio-hue-slider'));
    final hueRect = tester.getRect(
      find.byKey(const ValueKey('theme-studio-hue-slider')),
    );
    await tester.tapAt(Offset(hueRect.left + 8, hueRect.center.dy));
    await tester.pumpAndSettle();
    final colorAfterHueStart = settingsStore.accentColor.toARGB32();
    await tester.tapAt(
      Offset(hueRect.left + hueRect.width * 0.55, hueRect.center.dy),
    );
    await tester.pumpAndSettle();
    expect(settingsStore.accentColor.toARGB32(), isNot(colorAfterHueStart));

    await _ensureVisible(tester, const ValueKey('theme-studio-advanced-input'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-advanced-input')));
    await tester.pumpAndSettle();

    await _ensureVisible(tester, const ValueKey('theme-studio-hex-input'));
    final colorBeforeInvalidHex = settingsStore.accentColor.toARGB32();
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-hex-input')),
      'not-a-color',
    );
    await tester.tap(find.byKey(const ValueKey('theme-studio-apply-hex')));
    await tester.pumpAndSettle();

    expect(settingsStore.accentColor.toARGB32(), colorBeforeInvalidHex);
    expect(find.text('请输入 #RRGGBB 或 #AARRGGBB 格式的颜色。'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-hex-input')),
      '#123456',
    );
    await tester.tap(find.byKey(const ValueKey('theme-studio-apply-hex')));
    await tester.pumpAndSettle();

    expect(
      settingsStore.accentColor.toARGB32(),
      const Color(0xFF123456).toARGB32(),
    );

    await _ensureVisible(
      tester,
      const ValueKey('theme-studio-target-background'),
    );
    await tester.tap(
      find.byKey(const ValueKey('theme-studio-target-background')),
    );
    await tester.pumpAndSettle();
    await _ensureVisible(tester, const ValueKey('theme-studio-r-input'));
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-r-input')),
      '12',
    );
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-g-input')),
      '34',
    );
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-b-input')),
      '56',
    );
    await _ensureVisible(tester, const ValueKey('theme-studio-apply-rgb'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-apply-rgb')));
    await tester.pumpAndSettle();

    expect(
      settingsStore.customBackgroundColor?.toARGB32(),
      const Color(0xFF0C2238).toARGB32(),
    );

    await _ensureVisible(tester, const ValueKey('theme-studio-target-surface'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-target-surface')));
    await tester.pumpAndSettle();
    await _ensureVisible(tester, const ValueKey('theme-studio-a-input'));
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-a-input')),
      '255',
    );
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-argb-r-input')),
      '90',
    );
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-argb-g-input')),
      '100',
    );
    await tester.enterText(
      find.byKey(const ValueKey('theme-studio-argb-b-input')),
      '110',
    );
    await _ensureVisible(tester, const ValueKey('theme-studio-apply-argb'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-apply-argb')));
    await tester.pumpAndSettle();

    expect(
      settingsStore.customSurfaceColor?.toARGB32(),
      const Color(0xFF5A646E).toARGB32(),
    );

    await _ensureVisible(tester, const ValueKey('theme-studio-reset-all'));
    await tester.tap(find.byKey(const ValueKey('theme-studio-reset-all')));
    await tester.pumpAndSettle();

    expect(settingsStore.accentColorValue, isNull);
    expect(settingsStore.backgroundColorValue, isNull);
    expect(settingsStore.surfaceColorValue, isNull);
  });

  testWidgets('data summary section shows local record counts', (tester) async {
    final settingsStore = AppSettingsStore.inMemory();
    final habit = HabitItem(
      id: 'h1',
      name: 'Run',
      emoji: HabitItem.defaultEmoji,
      description: '',
      targetCountPerDay: 1,
      reminderTime: null,
      createdAt: DateTime.parse('2026-04-25T08:00:00Z'),
    );
    final goal = GoalItem(
      id: 'g1',
      title: 'Ship V6',
      createdAt: DateTime.parse('2026-04-25T08:00:00Z'),
    );

    await tester.pumpWidget(
      FourInOneApp(
        appSettingsStore: settingsStore,
        habitsStore: HabitsStore.seededInMemory(initialHabits: [habit]),
        goalsStore: GoalsStore.inMemory(initialGoals: [goal]),
        focusStore: FocusStore.inMemory(
          defaultDurationSeconds: 25 * 60,
          initialSessions: [
            FocusSessionItem(
              id: 'fs1',
              completedAt: DateTime.utc(2026, 4, 25, 8),
              durationSeconds: 1500,
            ),
          ],
        ),
      ),
    );

    await _openSettings(tester);

    await _ensureVisible(tester, const ValueKey('settings-data-summary'));

    expect(find.byKey(const ValueKey('settings-data-summary')), findsOneWidget);
    expect(find.text('1 个习惯'), findsOneWidget);
    expect(find.text('0 条行动'), findsOneWidget);
    expect(find.text('1 次专注'), findsOneWidget);
  });

  testWidgets('Theme Studio renders on common phone widths with larger text', (
    tester,
  ) async {
    final view = tester.view;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.15;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final settingsStore = AppSettingsStore.inMemory();

    for (final width in <double>[360, 393, 412]) {
      view.devicePixelRatio = 1;
      view.physicalSize = Size(width, 860);

      await _pumpApp(tester, settingsStore);
      await _openSettings(tester);

      await _ensureVisible(tester, const ValueKey('theme-studio-preview'));
      expect(find.text('颜色工作室'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('theme-studio-preview')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });
}

class _AccentExpectation {
  const _AccentExpectation({required this.label, required this.color});

  final String label;
  final Color color;

  String get optionKey =>
      'settings-accent-${color.toARGB32().toRadixString(16)}';

  String get selectedKey =>
      'settings-accent-selected-${color.toARGB32().toRadixString(16)}';
}

Future<void> _pumpApp(
  WidgetTester tester,
  AppSettingsStore settingsStore,
) async {
  await tester.pumpWidget(
    FourInOneApp(
      appSettingsStore: settingsStore,
      habitsStore: HabitsStore.seededInMemory(),
      goalsStore: GoalsStore.inMemory(),
    ),
  );
}

Future<void> _openSettings(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(AppRoute.settings);
  await tester.pumpAndSettle();
}

Future<void> _ensureVisible(WidgetTester tester, ValueKey<String> key) async {
  final finder = find.byKey(key);
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
