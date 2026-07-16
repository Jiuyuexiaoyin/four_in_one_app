import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/router/app_router.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/presentation/app_settings_scope.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/features/settings/presentation/widgets/notification_permissions_section.dart';
import 'package:four_in_one_app/shared/widgets/product/my_settings_section.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({this.showScaffold = true, super.key});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final settingsStore = AppSettingsScope.of(context);
    final content = _SettingsContent(settingsStore: settingsStore);

    if (!showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: content,
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageTop,
        AppThemeTokens.pagePadding,
        StitchExactPremiumSpacing.pageBottomSecondary,
      ),
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: StitchExactColors.onSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                '我',
                style: TextStyle(
                  color: StitchExactColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '我的',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StitchExactColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 32),
        _SettingsStudioHero(settingsStore: settingsStore),
        const SizedBox(height: 32),
        _AppearanceSection(settingsStore: settingsStore),
        const SizedBox(height: StitchExactPremiumSpacing.section),
        _SettingsControlConsole(settingsStore: settingsStore),
        const SizedBox(height: StitchExactPremiumSpacing.section),
        _ReviewAccessConsole(
          onOpenReview: () => Navigator.of(context).pushNamed(AppRoute.review),
        ),
        const SizedBox(height: StitchExactPremiumSpacing.section),
        const _DataSummarySection(),
        const SizedBox(height: StitchExactPremiumSpacing.section),
        const NotificationPermissionsSection(),
        const SizedBox(height: StitchExactPremiumSpacing.section),
        const _GetreadyAboutSection(),
      ],
    );
  }
}

class _SettingsControlConsole extends StatelessWidget {
  const _SettingsControlConsole({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final accent = settingsStore.accentColor;
    final localRecords =
        habitsStore.habits.length +
        goalsStore.tasks.length +
        focusStore.completedSessionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StitchExactCommandHeader(
          eyebrow: '系统设置',
          title: '系统设置',
          subtitle: '本地数据、主题状态和工具入口。',
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StitchExactStatusPill(
              label: '模式',
              value: _themeModeDisplayLabel(settingsStore.themeMode),
              selected: true,
            ),
            StitchExactStatusPill(
              label: '色值',
              value: _colorToHex(accent),
              selected: true,
              accent: accent,
            ),
            StitchExactStatusPill(
              label: '本地',
              value: '$localRecords',
              selected: true,
              accent: colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 28),
        StitchExactPanel(
          glow: true,
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StitchExactCommandHeader(
                eyebrow: '主题工作室',
                title: '外观设置',
                subtitle: '深色模式、主色和颜色实验。',
                leadingIcon: Icons.palette_outlined,
                compact: true,
                trailing: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: 0.36)),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: accent,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StitchExactProgressRail(
                label: '深色模式',
                value: settingsStore.themeMode == AppThemeMode.dark ? 1.0 : 0.0,
                detail:
                    '当前模式：${_themeModeDisplayLabel(settingsStore.themeMode)}',
                accent: accent,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: StitchExactCapsLabel(text: '主色')),
                  Text(
                    'HEX ${_colorToHex(accent)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsAccentStrip(
                colors: AppSettingsStore.calmColorPresets,
                selectedColor: accent,
                onSelected: settingsStore.setAccentColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: StitchExactPremiumSpacing.sectionTight),
        StitchExactPanel(
          child: StitchExactMetricGrid(
            metrics: [
              StitchExactMetric(
                label: '习惯',
                value: '${habitsStore.habits.length}',
                detail: '本机习惯',
              ),
              StitchExactMetric(
                label: '行动',
                value: '${goalsStore.tasks.length}',
                detail: '本机行动',
                accent: colorScheme.secondary,
              ),
              StitchExactMetric(
                label: '专注',
                value: '${focusStore.completedSessionCount}',
                detail: '专注记录',
                accent: colorScheme.tertiary,
              ),
              StitchExactMetric(label: '存储', value: '本地', detail: '无云同步'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewAccessConsole extends StatelessWidget {
  const _ReviewAccessConsole({required this.onOpenReview});

  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    return StitchExactPanel(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StitchExactCommandHeader(
            eyebrow: '复盘入口',
            title: '今日回看',
            subtitle: '复盘保留为独立页面，不占用底部主导航。',
            leadingIcon: Icons.history_rounded,
            compact: true,
          ),
          const SizedBox(height: 14),
          StitchExactUtilityRow(
            title: '打开回看',
            subtitle: '复盘入口',
            icon: Icons.insights_rounded,
            value: '打开',
            onTap: onOpenReview,
          ),
        ],
      ),
    );
  }
}

class _SettingsStudioHero extends StatelessWidget {
  const _SettingsStudioHero({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    final accent = settingsStore.accentColor;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: StitchExactPanel(
            glow: true,
            accent: accent,
            padding: EdgeInsets.zero,
            borderRadius: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _ThemeStudioWavePainter(accent: accent)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          StitchExactColors.background.withValues(alpha: 0.56),
                          StitchExactColors.black.withValues(alpha: 0.92),
                        ],
                        stops: const [0.25, 0.62, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.75),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StitchExactCapsLabel(text: '本地主题', accent: accent),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '主题工作室',
                          style: TextStyle(
                            color: StitchExactColors.onSurface,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 0.98,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '用颜色和主题保持清晰、稳定的使用环境。',
                          style: TextStyle(
                            color: StitchExactColors.onSurfaceVariant,
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeStudioWavePainter extends CustomPainter {
  const _ThemeStudioWavePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = StitchExactColors.surfaceHigh;
    canvas.drawRect(Offset.zero & size, bg);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 0; i < 12; i += 1) {
      final path = Path();
      final yBase = size.height * (0.38 + i * 0.026);
      path.moveTo(0, yBase);
      for (var x = 0.0; x <= size.width; x += 12) {
        final y =
            yBase +
            math.sin((x / size.width * math.pi * 2.2) + i * 0.28) * 28 +
            math.sin((x / size.width * math.pi * 4.0) + i * 0.18) * 10;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, linePaint);
    }
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [accent.withValues(alpha: 0.16), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.62),
              radius: size.width * 0.46,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant _ThemeStudioWavePainter oldDelegate) {
    return accent != oldDelegate.accent;
  }
}

class _SettingsAccentStrip extends StatelessWidget {
  const _SettingsAccentStrip({
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final color in colors)
          GestureDetector(
            onTap: () => onSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: color.toARGB32() == selectedColor.toARGB32()
                      ? colorScheme.onSurface
                      : Colors.white.withValues(alpha: 0.10),
                  width: color.toARGB32() == selectedColor.toARGB32() ? 2 : 1,
                ),
                boxShadow: [
                  if (color.toARGB32() == selectedColor.toARGB32())
                    BoxShadow(
                      color: color.withValues(alpha: 0.34),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    return MySettingsSection(
      title: '外观',
      subtitle: '让界面跟随你的使用环境，同时保留当前深色高级方向。',
      leadingIcon: Icons.palette_outlined,
      rows: [
        MySettingsRow(
          title: '主题模式',
          subtitle: '跟随系统，或选择柔和与深邃两档深色氛围',
          content: Column(
            children: [
              _ThemeModeTile(
                key: const ValueKey('settings-theme-mode-system'),
                title: '跟随系统',
                value: AppThemeMode.system,
                groupValue: settingsStore.themeMode,
                onChanged: settingsStore.setThemeMode,
              ),
              _ThemeModeTile(
                key: const ValueKey('settings-theme-mode-light'),
                title: '柔和深色',
                value: AppThemeMode.light,
                groupValue: settingsStore.themeMode,
                onChanged: settingsStore.setThemeMode,
              ),
              _ThemeModeTile(
                key: const ValueKey('settings-theme-mode-dark'),
                title: '深邃深色',
                value: AppThemeMode.dark,
                groupValue: settingsStore.themeMode,
                onChanged: settingsStore.setThemeMode,
              ),
            ],
          ),
        ),
        MySettingsRow(
          title: '颜色工作室',
          subtitle: '影响按钮、选中态和强调元素',
          content: _ThemeStudio(settingsStore: settingsStore),
        ),
      ],
    );
  }
}

class _ThemeStudio extends StatefulWidget {
  const _ThemeStudio({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  State<_ThemeStudio> createState() => _ThemeStudioState();
}

class _ThemeStudioState extends State<_ThemeStudio> {
  final _hexController = TextEditingController();
  final _redController = TextEditingController();
  final _greenController = TextEditingController();
  final _blueController = TextEditingController();
  final _alphaController = TextEditingController(text: '255');
  final _argbRedController = TextEditingController();
  final _argbGreenController = TextEditingController();
  final _argbBlueController = TextEditingController();

  _ThemeColorTarget _target = _ThemeColorTarget.accent;
  String? _inputMessage;
  bool _inputHasError = false;

  @override
  void dispose() {
    _hexController.dispose();
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    _alphaController.dispose();
    _argbRedController.dispose();
    _argbGreenController.dispose();
    _argbBlueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.settingsStore;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ThemePreview(settingsStore: store),
        const SizedBox(height: 20),
        Text(
          '界面强调色',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceXs),
        Text(
          '界面强调色影响按钮、选中态、芯片和强调元素。背景颜色影响页面底色，卡片颜色影响面板和底表。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        _ThemeTargetSelector(
          selectedTarget: _target,
          onSelected: (target) {
            setState(() {
              _target = target;
              _inputMessage = null;
              _inputHasError = false;
            });
          },
        ),
        const SizedBox(height: 18),
        _VisualColorPickerPanel(
          key: const ValueKey('theme-studio-visual-picker'),
          color: _currentTargetColor(store),
          targetLabel: _target.label,
          onColorChanged: _applyVisualColor,
        ),
        const SizedBox(height: 12),
        Text(
          '不会选色可以直接拖动色盘或点选色卡。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: StitchExactPremiumSpacing.sectionTight),
        _PaletteBoards(
          currentColor: _currentTargetColor(store),
          target: _target,
          onColorSelected: (color) {
            _applyColor(color);
          },
        ),
        if (_inputMessage != null) ...[
          const SizedBox(height: AppThemeTokens.spaceSm),
          Text(
            _inputMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _inputHasError ? colorScheme.error : colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: AppThemeTokens.spaceXs,
          runSpacing: AppThemeTokens.spaceXs,
          children: [
            TextButton.icon(
              key: ValueKey<String>('theme-studio-reset-${_target.key}'),
              onPressed: _resetCurrentTarget,
              icon: const Icon(Icons.undo_rounded, size: 17),
              label: Text(_target.resetLabel),
            ),
            TextButton(
              key: const ValueKey('theme-studio-reset-all'),
              onPressed: () {
                widget.settingsStore.resetAllColors();
                _showMessage('已恢复默认颜色。');
              },
              child: const Text('全部恢复默认'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AdvancedColorInputs(
          hexController: _hexController,
          redController: _redController,
          greenController: _greenController,
          blueController: _blueController,
          alphaController: _alphaController,
          argbRedController: _argbRedController,
          argbGreenController: _argbGreenController,
          argbBlueController: _argbBlueController,
          onApplyHex: _applyHexInput,
          onApplyRgb: _applyRgbInput,
          onApplyArgb: _applyArgbInput,
        ),
      ],
    );
  }

  void _applyHexInput() {
    final parsedColor = _parseHexColor(_hexController.text);
    if (parsedColor == null) {
      _showMessage('请输入 #RRGGBB 或 #AARRGGBB 格式的颜色。', isError: true);
      return;
    }

    _applyColor(parsedColor);
  }

  void _applyRgbInput() {
    final red = _parseColorComponent(_redController.text);
    final green = _parseColorComponent(_greenController.text);
    final blue = _parseColorComponent(_blueController.text);
    if (red == null || green == null || blue == null) {
      _showMessage('RGB 需要填写 0-255 的数字。', isError: true);
      return;
    }

    _applyColor(Color.fromARGB(255, red, green, blue));
  }

  void _applyArgbInput() {
    final alpha = _parseColorComponent(_alphaController.text);
    final red = _parseColorComponent(_argbRedController.text);
    final green = _parseColorComponent(_argbGreenController.text);
    final blue = _parseColorComponent(_argbBlueController.text);
    if (alpha == null || red == null || green == null || blue == null) {
      _showMessage('ARGB 需要填写 0-255 的数字。', isError: true);
      return;
    }

    final safeAlpha = alpha < 0xCC ? 0xFF : alpha;
    _applyColor(
      Color.fromARGB(safeAlpha, red, green, blue),
      message: alpha < 0xCC ? '透明度过低，已使用不透明颜色保护可读性。' : null,
    );
  }

  void _applyVisualColor(Color color) {
    _applyColor(color, showMessage: false);
  }

  Future<void> _applyColor(
    Color color, {
    String? message,
    bool showMessage = true,
  }) async {
    switch (_target) {
      case _ThemeColorTarget.accent:
        await widget.settingsStore.setAccentColor(color);
        break;
      case _ThemeColorTarget.background:
        await widget.settingsStore.setBackgroundColor(color);
        break;
      case _ThemeColorTarget.surface:
        await widget.settingsStore.setSurfaceColor(color);
        break;
    }

    if (!mounted) {
      return;
    }

    if (!showMessage) {
      setState(() {
        _inputMessage = null;
        _inputHasError = false;
      });
      return;
    }

    _showMessage(message ?? _readabilityMessage(color) ?? '颜色已应用。');
  }

  void _resetCurrentTarget() {
    switch (_target) {
      case _ThemeColorTarget.accent:
        widget.settingsStore.resetAccentColor();
        break;
      case _ThemeColorTarget.background:
        widget.settingsStore.resetBackgroundColor();
        break;
      case _ThemeColorTarget.surface:
        widget.settingsStore.resetSurfaceColor();
        break;
    }
    _showMessage('${_target.label}已恢复默认。');
  }

  Color _currentTargetColor(AppSettingsStore store) {
    switch (_target) {
      case _ThemeColorTarget.accent:
        return store.accentColor;
      case _ThemeColorTarget.background:
        return store.customBackgroundColor ??
            AppSettingsStore.defaultLightBackgroundColor;
      case _ThemeColorTarget.surface:
        return store.customSurfaceColor ??
            AppSettingsStore.defaultLightSurfaceColor;
    }
  }

  Color? _parseHexColor(String input) {
    var normalized = input.trim();
    if (normalized.startsWith('#')) {
      normalized = normalized.substring(1);
    }
    if (normalized.toLowerCase().startsWith('0x')) {
      normalized = normalized.substring(2);
    }
    if (normalized.length == 6) {
      normalized = 'FF$normalized';
    }
    if (normalized.length != 8 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized)) {
      return null;
    }

    final value = int.tryParse(normalized, radix: 16);
    return AppSettingsStore.colorFromValue(value);
  }

  int? _parseColorComponent(String input) {
    final value = int.tryParse(input.trim());
    return value?.clamp(0, 255).toInt();
  }

  String? _readabilityMessage(Color color) {
    final luminance = color.computeLuminance();
    if (luminance < 0.08 || luminance > 0.92) {
      return '当前颜色可能影响文字可读性，界面会自动柔化处理。';
    }
    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    setState(() {
      _inputMessage = message;
      _inputHasError = isError;
    });
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = settingsStore.accentColor;
    final background =
        settingsStore.customBackgroundColor ??
        AppSettingsStore.defaultDarkBackgroundColor;
    final surface =
        settingsStore.customSurfaceColor ??
        AppSettingsStore.defaultDarkSurfaceColor;
    final previewBackground = Color.lerp(
      AppThemeTokens.premiumCanvas,
      background,
      0.78,
    )!;
    final previewSurface = Color.lerp(
      AppThemeTokens.premiumSurface,
      surface,
      0.78,
    )!;
    final labelColor = previewSurface.computeLuminance() > 0.5
        ? Colors.black.withValues(alpha: 0.82)
        : Colors.white.withValues(alpha: 0.88);
    final helperColor = previewSurface.computeLuminance() > 0.5
        ? Colors.black.withValues(alpha: 0.58)
        : Colors.white.withValues(alpha: 0.56);

    return Container(
      key: const ValueKey('theme-studio-preview'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            previewBackground,
            Color.lerp(previewBackground, accent, 0.08)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        decoration: BoxDecoration(
          color: previewSurface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppThemeTokens.spaceSm,
              runSpacing: AppThemeTokens.spaceXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusMd,
                    ),
                  ),
                ),
                Text(
                  '主题预览',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeTokens.spaceSm,
                    vertical: AppThemeTokens.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusPill,
                    ),
                  ),
                  child: Text(
                    '强调元素',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              '背景、卡片和按钮会保持克制的统一感。',
              style: theme.textTheme.bodySmall?.copyWith(color: helperColor),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: previewBackground,
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusPill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceXs),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: previewSurface,
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusPill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceXs),
                Container(
                  width: 44,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusPill,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTargetSelector extends StatelessWidget {
  const _ThemeTargetSelector({
    required this.selectedTarget,
    required this.onSelected,
  });

  final _ThemeColorTarget selectedTarget;
  final ValueChanged<_ThemeColorTarget> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppThemeTokens.spaceSm,
      runSpacing: AppThemeTokens.spaceSm,
      children: [
        for (final target in _ThemeColorTarget.values)
          FilterChip(
            key: ValueKey<String>('theme-studio-target-${target.key}'),
            label: Text(target.label),
            selected: selectedTarget == target,
            onSelected: (_) => onSelected(target),
          ),
      ],
    );
  }
}

class _VisualColorPickerPanel extends StatelessWidget {
  const _VisualColorPickerPanel({
    required this.color,
    required this.targetLabel,
    required this.onColorChanged,
    super.key,
  });

  final Color color;
  final String targetLabel;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hsv = HSVColor.fromColor(color.withValues(alpha: 1));

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                key: const ValueKey('theme-studio-current-color'),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.16),
                  ),
                ),
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _colorToHex(color),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          _SaturationBrightnessPicker(
            hsv: hsv,
            onChanged: (nextHsv) {
              onColorChanged(nextHsv.toColor());
            },
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          _HueSlider(
            hue: hsv.hue,
            onChanged: (hue) {
              onColorChanged(hsv.withHue(hue).toColor());
            },
          ),
        ],
      ),
    );
  }
}

class _SaturationBrightnessPicker extends StatelessWidget {
  const _SaturationBrightnessPicker({
    required this.hsv,
    required this.onChanged,
  });

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 224.0);

        void updateFromPosition(Offset localPosition) {
          final saturation = (localPosition.dx / size).clamp(0.0, 1.0);
          final value = (1 - localPosition.dy / size).clamp(0.0, 1.0);
          onChanged(
            hsv
                .withSaturation(saturation.toDouble())
                .withValue(value.toDouble())
                .withAlpha(1),
          );
        }

        return Center(
          child: GestureDetector(
            key: const ValueKey('theme-studio-color-square'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => updateFromPosition(details.localPosition),
            onPanUpdate: (details) => updateFromPosition(details.localPosition),
            child: SizedBox.square(
              dimension: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _SaturationBrightnessPainter(hue: hsv.hue),
                  ),
                  Positioned(
                    left: hsv.saturation * size - 9,
                    top: (1 - hsv.value) * size - 9,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SaturationBrightnessPainter extends CustomPainter {
  const _SaturationBrightnessPainter({required this.hue});

  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();

    final saturationPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, hueColor],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      saturationPaint,
    );

    final valuePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationBrightnessPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const height = 28.0;
        final width = constraints.maxWidth;

        void updateFromPosition(Offset localPosition) {
          final normalized = (localPosition.dx / width).clamp(0.0, 1.0);
          onChanged(normalized.toDouble() * 360);
        }

        return GestureDetector(
          key: const ValueKey('theme-studio-hue-slider'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => updateFromPosition(details.localPosition),
          onPanUpdate: (details) => updateFromPosition(details.localPosition),
          child: SizedBox(
            height: 42,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(width, height),
                  painter: const _HueSliderPainter(),
                ),
                Positioned(
                  left: (hue / 360 * width).clamp(0.0, width) - 6,
                  child: Container(
                    width: 12,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusPill,
                      ),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.26),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HueSliderPainter extends CustomPainter {
  const _HueSliderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = List<Color>.generate(
      7,
      (index) => HSVColor.fromAHSV(1, index * 60, 1, 1).toColor(),
    );
    final paint = Paint()
      ..shader = LinearGradient(colors: colors).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HueSliderPainter oldDelegate) => false;
}

class _PaletteBoards extends StatelessWidget {
  const _PaletteBoards({
    required this.currentColor,
    required this.target,
    required this.onColorSelected,
  });

  final Color currentColor;
  final _ThemeColorTarget target;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selection = _findPaletteSelection(currentColor);
    final previewColors =
        selection.board?.colors
            .map((preset) => preset.color)
            .toList(growable: false) ??
        _derivedPreviewColors(currentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '色卡灵感',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              target.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppThemeTokens.secondaryTextTone(colorScheme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey<int>(currentColor.toARGB32()),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppThemeTokens.softSurfaceTone(
                colorScheme,
              ).withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
              border: Border.all(
                color: AppThemeTokens.borderTone(
                  colorScheme,
                ).withValues(alpha: 0.26),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection.preset?.label ?? '自定义色',
                        key: const ValueKey('theme-studio-current-palette'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selection.board?.title ?? '当前颜色组合',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final color in previewColors)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          width: 27,
                          height: 27,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.10,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: colorScheme.primary.withValues(alpha: 0.78),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '常用色卡',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _commonThemePresets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final preset = _commonThemePresets[index];
              return _CommonPaletteCard(
                color: preset.color,
                label: preset.label,
                target: target,
                selected: currentColor.toARGB32() == preset.color.toARGB32(),
                onTap: () => onColorSelected(preset.color),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          key: const ValueKey('theme-studio-more-palettes'),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          onTap: () => _showAllPalettes(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('更多色卡')),
                Text(
                  '全部 15 种',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAllPalettes(BuildContext context) async {
    var sheetColor = currentColor;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => FractionallySizedBox(
          heightFactor: 0.80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '更多色卡',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text('选择后立即应用到${target.label}'),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('theme-studio-more-palettes-close'),
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    for (final board in _themePaletteBoards) ...[
                      Text(
                        board.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(
                            Theme.of(context).colorScheme,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preset in board.colors)
                            _SheetPaletteOption(
                              color: preset.color,
                              label: preset.label,
                              target: target,
                              selected:
                                  sheetColor.toARGB32() ==
                                  preset.color.toARGB32(),
                              onTap: () {
                                setSheetState(() {
                                  sheetColor = preset.color;
                                });
                                onColorSelected(preset.color);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedColorInputs extends StatelessWidget {
  const _AdvancedColorInputs({
    required this.hexController,
    required this.redController,
    required this.greenController,
    required this.blueController,
    required this.alphaController,
    required this.argbRedController,
    required this.argbGreenController,
    required this.argbBlueController,
    required this.onApplyHex,
    required this.onApplyRgb,
    required this.onApplyArgb,
  });

  final TextEditingController hexController;
  final TextEditingController redController;
  final TextEditingController greenController;
  final TextEditingController blueController;
  final TextEditingController alphaController;
  final TextEditingController argbRedController;
  final TextEditingController argbGreenController;
  final TextEditingController argbBlueController;
  final VoidCallback onApplyHex;
  final VoidCallback onApplyRgb;
  final VoidCallback onApplyArgb;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const ValueKey('theme-studio-advanced-input'),
      maintainState: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      leading: const Icon(Icons.tune_rounded, size: 20),
      title: const Text('高级颜色输入'),
      subtitle: const Text('HEX、RGB 与 ARGB'),
      children: [
        _ColorInputPanel(
          title: 'HEX 输入',
          helper: '#RRGGBB 或 #AARRGGBB',
          children: [
            TextField(
              key: const ValueKey('theme-studio-hex-input'),
              controller: hexController,
              decoration: const InputDecoration(hintText: '#2E6B5A'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onApplyHex(),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                key: const ValueKey('theme-studio-apply-hex'),
                onPressed: onApplyHex,
                child: const Text('应用 HEX'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
        _ColorInputPanel(
          title: 'RGB 输入',
          helper: '数值范围 0-255，超出会自动夹取到安全范围。',
          children: [
            Row(
              children: [
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-r-input'),
                    controller: redController,
                    label: 'R',
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-g-input'),
                    controller: greenController,
                    label: 'G',
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-b-input'),
                    controller: blueController,
                    label: 'B',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                key: const ValueKey('theme-studio-apply-rgb'),
                onPressed: onApplyRgb,
                child: const Text('应用 RGB'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
        _ColorInputPanel(
          title: 'ARGB 输入',
          helper: 'A 低于安全透明度时会转为不透明，避免文字不可读。',
          children: [
            Row(
              children: [
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-a-input'),
                    controller: alphaController,
                    label: 'A',
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceXs),
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-argb-r-input'),
                    controller: argbRedController,
                    label: 'R',
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceXs),
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-argb-g-input'),
                    controller: argbGreenController,
                    label: 'G',
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceXs),
                Expanded(
                  child: _NumberColorField(
                    key: const ValueKey('theme-studio-argb-b-input'),
                    controller: argbBlueController,
                    label: 'B',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                key: const ValueKey('theme-studio-apply-argb'),
                onPressed: onApplyArgb,
                child: const Text('应用 ARGB'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _themeModeDisplayLabel(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => '跟随系统',
    AppThemeMode.light => '柔和深色',
    AppThemeMode.dark => '深邃深色',
  };
}

String _colorToHex(Color color) {
  final rgbValue = color.toARGB32() & 0xFFFFFF;
  return '#${rgbValue.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class _ColorInputPanel extends StatelessWidget {
  const _ColorInputPanel({
    required this.title,
    required this.helper,
    required this.children,
  });

  final String title;
  final String helper;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(
          colorScheme,
        ).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceXs),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          ...children,
        ],
      ),
    );
  }
}

class _NumberColorField extends StatelessWidget {
  const _NumberColorField({
    required this.controller,
    required this.label,
    super.key,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, hintText: '0'),
    );
  }
}

class _CommonPaletteCard extends StatelessWidget {
  const _CommonPaletteCard({
    required this.color,
    required this.label,
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final _ThemeColorTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final swatchKey = color.toARGB32().toRadixString(16);

    return InkWell(
      key: ValueKey<String>('settings-common-${target.key}-$swatchKey'),
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 94,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.13)
              : AppThemeTokens.softSurfaceTone(
                  colorScheme,
                ).withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.48)
                : AppThemeTokens.borderTone(
                    colorScheme,
                  ).withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                if (selected)
                  Icon(
                    key: ValueKey<String>(
                      'settings-common-selected-${target.key}-$swatchKey',
                    ),
                    Icons.check_rounded,
                    size: 17,
                    color: colorScheme.primary,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.primary
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetPaletteOption extends StatelessWidget {
  const _SheetPaletteOption({
    required this.color,
    required this.label,
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final _ThemeColorTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final swatchKey = color.toARGB32().toRadixString(16);

    return InkWell(
      key: ValueKey<String>('${target.optionKeyPrefix}-$swatchKey'),
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.13)
              : AppThemeTokens.softSurfaceTone(
                  colorScheme,
                ).withValues(alpha: 0.46),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.50)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.10),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colorScheme.primary : null,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              Icon(
                key: ValueKey<String>('${target.selectedKeyPrefix}-$swatchKey'),
                Icons.check_rounded,
                size: 15,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _DataSummarySection extends StatelessWidget {
  const _DataSummarySection();

  @override
  Widget build(BuildContext context) {
    final habitsStore = HabitsScope.of(context);
    final goalsStore = GoalsScope.of(context);
    final focusStore = FocusStoreScope.of(context);
    final habitCount = habitsStore.habits.length;
    final taskCount = goalsStore.tasks.length;
    final focusCount = focusStore.completedSessionCount;

    return MySettingsSection(
      key: const ValueKey('settings-data-summary'),
      title: '本地数据',
      subtitle: '当前设备存储的数据记录，数据只保留在本机。',
      leadingIcon: Icons.storage_rounded,
      rows: [
        MySettingsRow(
          title: '习惯与打卡',
          subtitle: '$habitCount 个习惯',
          leadingIcon: Icons.spa_rounded,
        ),
        MySettingsRow(
          title: '目标与行动',
          subtitle: '$taskCount 条行动',
          leadingIcon: Icons.account_tree_rounded,
        ),
        MySettingsRow(
          title: '专注记录',
          subtitle: '$focusCount 次专注',
          leadingIcon: Icons.timer_rounded,
        ),
      ],
    );
  }
}

class _GetreadyAboutSection extends StatelessWidget {
  const _GetreadyAboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MySettingsSection(
      key: const ValueKey('getready-about-section'),
      title: '关于',
      subtitle: '应用与品牌信息',
      leadingIcon: Icons.info_outline_rounded,
      rows: [
        Padding(
          key: const ValueKey('getready-about-row'),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/branding/generated/get_ready_mark_64.png',
                width: 56,
                height: 56,
                filterQuality: FilterQuality.high,
                semanticLabel: 'Get Ready 标志',
              ),
              const SizedBox(width: AppThemeTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Get ',
                        children: const [
                          TextSpan(
                            text: 'Ready',
                            style: TextStyle(color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                      semanticsLabel: 'Get Ready',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppThemeTokens.spaceXs),
                    Text(
                      '随时准备，迎接每一次机会。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppThemeTokens.secondaryTextTone(colorScheme),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppThemeTokens.spaceXs),
                    Text(
                      '版本 2.6.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final String title;
  final AppThemeMode value;
  final AppThemeMode groupValue;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = value == groupValue;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? colorScheme.primary : colorScheme.outline,
      ),
      onTap: () {
        onChanged(value);
      },
    );
  }
}

enum _ThemeColorTarget {
  accent,
  background,
  surface;

  String get key {
    switch (this) {
      case _ThemeColorTarget.accent:
        return 'accent';
      case _ThemeColorTarget.background:
        return 'background';
      case _ThemeColorTarget.surface:
        return 'surface';
    }
  }

  String get label {
    switch (this) {
      case _ThemeColorTarget.accent:
        return 'UI 强调色';
      case _ThemeColorTarget.background:
        return '背景颜色';
      case _ThemeColorTarget.surface:
        return '卡片颜色';
    }
  }

  String get resetLabel {
    switch (this) {
      case _ThemeColorTarget.accent:
        return '恢复默认强调色';
      case _ThemeColorTarget.background:
        return '恢复默认背景';
      case _ThemeColorTarget.surface:
        return '恢复默认卡片';
    }
  }

  String get optionKeyPrefix {
    switch (this) {
      case _ThemeColorTarget.accent:
        return 'settings-accent';
      case _ThemeColorTarget.background:
        return 'settings-background';
      case _ThemeColorTarget.surface:
        return 'settings-surface';
    }
  }

  String get selectedKeyPrefix {
    switch (this) {
      case _ThemeColorTarget.accent:
        return 'settings-accent-selected';
      case _ThemeColorTarget.background:
        return 'settings-background-selected';
      case _ThemeColorTarget.surface:
        return 'settings-surface-selected';
    }
  }
}

class _ColorPreset {
  const _ColorPreset({required this.label, required this.color});

  final String label;
  final Color color;
}

class _ColorPaletteBoard {
  const _ColorPaletteBoard({required this.title, required this.colors});

  final String title;
  final List<_ColorPreset> colors;
}

class _PaletteSelection {
  const _PaletteSelection({this.board, this.preset});

  final _ColorPaletteBoard? board;
  final _ColorPreset? preset;
}

_PaletteSelection _findPaletteSelection(Color color) {
  for (final board in _themePaletteBoards) {
    for (final preset in board.colors) {
      if (preset.color.toARGB32() == color.toARGB32()) {
        return _PaletteSelection(board: board, preset: preset);
      }
    }
  }

  return const _PaletteSelection();
}

List<Color> _derivedPreviewColors(Color color) {
  final hsl = HSLColor.fromColor(color);
  Color shifted(double delta) => hsl
      .withLightness((hsl.lightness + delta).clamp(0.08, 0.92).toDouble())
      .toColor();

  return <Color>[shifted(-0.14), color, shifted(0.16)];
}

const _commonThemePresets = <_ColorPreset>[
  _ColorPreset(label: '松绿色', color: Color(0xFF2E6B5A)),
  _ColorPreset(label: '鼠尾草绿', color: Color(0xFF6F7F69)),
  _ColorPreset(label: '暖米色', color: Color(0xFFB9A26B)),
  _ColorPreset(label: '雾蓝色', color: Color(0xFF6E7E9E)),
  _ColorPreset(label: '深青色', color: Color(0xFF4F8D8B)),
];

const _themePaletteBoards = <_ColorPaletteBoard>[
  _ColorPaletteBoard(
    title: '自然',
    colors: [
      _ColorPreset(label: '松绿色', color: Color(0xFF2E6B5A)),
      _ColorPreset(label: '鼠尾草绿', color: Color(0xFF6F7F69)),
      _ColorPreset(label: '暖米色', color: Color(0xFFB9A26B)),
    ],
  ),
  _ColorPaletteBoard(
    title: '高级灰',
    colors: [
      _ColorPreset(label: '石墨灰', color: Color(0xFF3F4643)),
      _ColorPreset(label: '雾灰色', color: Color(0xFF777C77)),
      _ColorPreset(label: '砂岩灰', color: Color(0xFFA9A49A)),
    ],
  ),
  _ColorPaletteBoard(
    title: '柔和暖色',
    colors: [
      _ColorPreset(label: '陶土色', color: Color(0xFF8A6F6A)),
      _ColorPreset(label: '柔和橙', color: Color(0xFFD08A52)),
      _ColorPreset(label: '落日杏', color: Color(0xFFC79B73)),
    ],
  ),
  _ColorPaletteBoard(
    title: '冷静蓝绿',
    colors: [
      _ColorPreset(label: '雾蓝色', color: Color(0xFF6E7E9E)),
      _ColorPreset(label: '深青色', color: Color(0xFF4F8D8B)),
      _ColorPreset(label: '湖蓝灰', color: Color(0xFF668F99)),
    ],
  ),
  _ColorPaletteBoard(
    title: '深色高级',
    colors: [
      _ColorPreset(label: '灰紫色', color: Color(0xFF7A6F8F)),
      _ColorPreset(label: '夜青色', color: Color(0xFF263532)),
      _ColorPreset(label: '墨蓝色', color: Color(0xFF2D3440)),
    ],
  ),
];
