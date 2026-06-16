import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/presentation/app_settings_scope.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';

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
        20,
        14,
        20,
        96,
      ),
      children: [
        _ThemeStudio(settingsStore: settingsStore),
        const SizedBox(height: 22),
        const _FutureSection(
          rowTitle: '提醒设置',
          helper: 'REMINDERS CONFIG',
          icon: Icons.notifications_none_rounded,
        ),
        const SizedBox(height: 6),
        const _FutureSection(
          rowTitle: '隐私与安全',
          helper: 'PRIVACY & SECURITY',
          icon: Icons.privacy_tip_outlined,
        ),
        const SizedBox(height: 6),
        const _DataSummarySection(),
        const SizedBox(height: 6),
        const _FutureSection(
          rowTitle: '版本信息',
          helper: 'CURRENT BUILD',
          icon: Icons.info_outline_rounded,
          badgeLabel: '测试中',
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
    return Row(
      children: [
        Expanded(
          child: _ThemeModeTile(
            key: const ValueKey('settings-theme-mode-system'),
            title: '跟随系统',
            value: AppThemeMode.system,
            groupValue: settingsStore.themeMode,
            onChanged: settingsStore.setThemeMode,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ThemeModeTile(
            key: const ValueKey('settings-theme-mode-light'),
            title: '浅色',
            value: AppThemeMode.light,
            groupValue: settingsStore.themeMode,
            onChanged: settingsStore.setThemeMode,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ThemeModeTile(
            key: const ValueKey('settings-theme-mode-dark'),
            title: '深色',
            value: AppThemeMode.dark,
            groupValue: settingsStore.themeMode,
            onChanged: settingsStore.setThemeMode,
          ),
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
        const SizedBox(height: 28),
        const _ColorLabHeader(),
        const SizedBox(height: 14),
        Text(
          '颜色工作室',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '界面强调色',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '影响按钮、选中态和强调元素',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            height: 1.12,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 9),
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
        const SizedBox(height: 10),
        _VisualColorPickerPanel(
          key: const ValueKey('theme-studio-visual-picker'),
          color: _currentTargetColor(store),
          targetLabel: _target.label,
          onColorChanged: _applyVisualColor,
        ),
        const SizedBox(height: 10),
        Text(
          '拖动矩阵或色相轨道会实时更新当前目标色。',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: AppThemeTokens.spaceMd),
        Wrap(
          spacing: AppThemeTokens.spaceSm,
          runSpacing: AppThemeTokens.spaceSm,
          children: [
            OutlinedButton(
              key: ValueKey<String>('theme-studio-reset-${_target.key}'),
              onPressed: _resetCurrentTarget,
              child: Text(_target.resetLabel),
            ),
            OutlinedButton(
              key: const ValueKey('theme-studio-reset-all'),
              onPressed: () {
                widget.settingsStore.resetAllColors();
                _showMessage('已恢复默认颜色。');
              },
              child: const Text('恢复默认颜色'),
            ),
          ],
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
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
    final colorScheme = theme.colorScheme;
    final accent = settingsStore.accentColor;
    final background =
        settingsStore.customBackgroundColor ??
        AppSettingsStore.defaultLightBackgroundColor;
    final surface =
        settingsStore.customSurfaceColor ??
        AppSettingsStore.defaultLightSurfaceColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = constraints.maxWidth > 520
            ? 300.0
            : (constraints.maxWidth * 0.96).clamp(350.0, 386.0);
        final heroSurface = Color.lerp(
          const Color(0xFF0B0D0D),
          surface,
          0.08,
        )!;
        final heroBackground = Color.lerp(
          const Color(0xFF0B0D0D),
          background,
          0.06,
        )!;

        return Container(
          key: const ValueKey('theme-studio-preview'),
          height: heroHeight,
          decoration: BoxDecoration(
            color: heroBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(accent, colorScheme.onSurface, 0.76)!
                  .withValues(alpha: 0.36),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 34,
                spreadRadius: -24,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(heroSurface, accent, 0.05)!,
                        heroSurface.withValues(alpha: 0.92),
                        const Color(0xFF070808),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _MineWavePainter(
                    accent: accent,
                    lineColor: colorScheme.onSurface,
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 22,
                right: 22,
                child: _HeroThemeModeDock(settingsStore: settingsStore),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                                color: accent.withValues(alpha: 0.55),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EDITION 01',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'EDITION 01',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.18),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '主题工作室',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 0.94,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.72),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Theme Studio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Curated visual environments for peak cognitive focus.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.82),
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroThemeModeDock extends StatelessWidget {
  const _HeroThemeModeDock({required this.settingsStore});

  final AppSettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: 0.58,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '外观',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '主题模式',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _AppearanceSection(settingsStore: settingsStore),
        ],
      ),
    );
  }
}

class _ColorLabHeader extends StatelessWidget {
  const _ColorLabHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR LAB',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            'ACTIVE PALETTE CONFIGURATION',
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.86),
              fontWeight: FontWeight.w900,
              letterSpacing: 2.6,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _MineWavePainter extends CustomPainter {
  const _MineWavePainter({required this.accent, required this.lineColor});

  final Color accent;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.72, 0.42),
        radius: 0.88,
        colors: [
          accent.withValues(alpha: 0.20),
          accent.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glowPaint);

    final baseY = size.height * 0.48;
    for (var index = 0; index < 13; index += 1) {
      final progress = index / 12;
      final path = Path()..moveTo(-18, baseY + index * 9);
      path.cubicTo(
        size.width * 0.16,
        baseY - 74 + index * 5,
        size.width * 0.36,
        baseY + 44 + index * 2,
        size.width * 0.52,
        baseY + 22 + index * 8,
      );
      path.cubicTo(
        size.width * 0.68,
        baseY + 2 + index * 10,
        size.width * 0.78,
        baseY - 82 + index * 7,
        size.width + 28,
        baseY - 30 + index * 4,
      );

      final paint = Paint()
        ..color = Color.lerp(lineColor, accent, 0.18)!
            .withValues(alpha: 0.11 - progress * 0.035)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, paint);
    }

    final shadePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Color(0xAA050606),
          Color(0xEE050606),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, shadePaint);
  }

  @override
  bool shouldRepaint(covariant _MineWavePainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.lineColor != lineColor;
  }
}

class _MineTechPanel extends StatelessWidget {
  const _MineTechPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF181A1A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Color.lerp(colorScheme.primary, colorScheme.onSurface, 0.72)!
              .withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );
  }
}

class _MinePanelLabel extends StatelessWidget {
  const _MinePanelLabel({required this.primary, required this.secondary});

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FittedBox(
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            primary,
            maxLines: 1,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '/ $secondary',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.62),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final target in _ThemeColorTarget.values)
          ChoiceChip(
            key: ValueKey<String>('theme-studio-target-${target.key}'),
            label: Text(target.label),
            selected: selectedTarget == target,
            labelStyle: TextStyle(
              color: selectedTarget == target
                  ? const Color(0xFF061214)
                  : colorScheme.onSurface.withValues(alpha: 0.72),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            selectedColor: colorScheme.primary,
            backgroundColor: const Color(0xFF121515).withValues(alpha: 0.82),
            side: BorderSide(
              color: selectedTarget == target
                  ? colorScheme.primary.withValues(alpha: 0.85)
                  : colorScheme.onSurface.withValues(alpha: 0.14),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
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
    final rgbText =
        '${(color.r * 255).round()}, ${(color.g * 255).round()}, ${(color.b * 255).round()}';

    return _MineTechPanel(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _MinePanelLabel(
                  primary: 'SAT / BRI MATRIX',
                  secondary: 'VISUAL PICKER',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'H: ${hsv.hue.round()}°',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _SaturationBrightnessPicker(
            hsv: hsv,
            onChanged: (nextHsv) {
              onColorChanged(nextHsv.toColor());
            },
          ),
          const SizedBox(height: 16),
          Text(
            'GLOBAL CONTROLS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.82),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _ControlReadoutRow(label: 'HUE', value: '${hsv.hue.round()}°'),
          const SizedBox(height: 8),
          _HueSlider(
            hue: hsv.hue,
            onChanged: (hue) {
              onColorChanged(hsv.withHue(hue).toColor());
            },
          ),
          const SizedBox(height: 12),
          _ControlReadoutRow(
            label: 'LUMINANCE',
            value: '${(hsv.value * 100).round()}%',
          ),
          const SizedBox(height: 8),
          _LuminanceMeter(value: hsv.value, color: color),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ColorValueTile(
                  label: 'HEX',
                  value: _colorToHex(color),
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ColorValueTile(
                  label: 'RGB',
                  value: rgbText,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                key: const ValueKey('theme-studio-current-color'),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.22),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  targetLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlReadoutRow extends StatelessWidget {
  const _ControlReadoutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _ColorValueTile extends StatelessWidget {
  const _ColorValueTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1010).withValues(alpha: 0.92),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.70),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                color: label == 'HEX' ? color : colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuminanceMeter extends StatelessWidget {
  const _LuminanceMeter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Container(
                width: constraints.maxWidth * clamped,
                height: 4,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    colorScheme.onSurface.withValues(alpha: 0.34),
                    color,
                    0.62,
                  )!,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Positioned(
                left: (constraints.maxWidth * clamped - 8).clamp(
                  0.0,
                  constraints.maxWidth - 16,
                ),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.32),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
        final width = constraints.maxWidth;
        final height = (width * 0.50).clamp(150.0, 178.0);

        void updateFromPosition(Offset localPosition) {
          final saturation = (localPosition.dx / width).clamp(0.0, 1.0);
          final value = (1 - localPosition.dy / height).clamp(0.0, 1.0);
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
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(width, height),
                    painter: _SaturationBrightnessPainter(hue: hsv.hue),
                  ),
                  Positioned(
                    left: hsv.saturation * width - 9,
                    top: (1 - hsv.value) * height - 9,
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
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      saturationPaint,
    );

    final valuePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
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
        const height = 10.0;
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
            height: 28,
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
                    height: 26,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(
          colorScheme,
        ).withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '色卡灵感',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                target.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppThemeTokens.secondaryTextTone(colorScheme),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          for (var index = 0; index < _themePaletteBoards.length; index += 1)
            ...[
              if (index > 0) const SizedBox(height: 10),
              _PaletteBoard(
                board: _themePaletteBoards[index],
                currentColor: currentColor,
                target: target,
                onColorSelected: onColorSelected,
              ),
            ],
        ],
      ),
    );
  }
}

class _PaletteBoard extends StatelessWidget {
  const _PaletteBoard({
    required this.board,
    required this.currentColor,
    required this.target,
    required this.onColorSelected,
  });

  final _ColorPaletteBoard board;
  final Color currentColor;
  final _ThemeColorTarget target;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.032),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            board.title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: [
              for (final preset in board.colors)
                _PresetColorOption(
                  color: preset.color,
                  label: preset.label,
                  target: target,
                  selected: currentColor.toARGB32() == preset.color.toARGB32(),
                  onTap: () => onColorSelected(preset.color),
                ),
            ],
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        key: const ValueKey('theme-studio-advanced-input'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('高级输入'),
      subtitle: const Text('色号输入适合高级自定义。'),
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
      ),
    );
  }
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

class _PresetColorOption extends StatelessWidget {
  const _PresetColorOption({
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
    final colorScheme = Theme.of(context).colorScheme;
    final swatchKey = color.toARGB32().toRadixString(16);
    final ringColor = selected
        ? colorScheme.primary.withValues(alpha: 0.54)
        : AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.28);

    return InkWell(
      key: ValueKey<String>('${target.optionKeyPrefix}-$swatchKey'),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: 94,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.onSurface.withValues(alpha: 0.028),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ringColor, width: selected ? 1.2 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      key: ValueKey<String>(
                        '${target.selectedKeyPrefix}-$swatchKey',
                      ),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: colorScheme.onPrimary,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.primary
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                height: 1.1,
              ),
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

    return _MineTechPanel(
      key: const ValueKey('settings-data-summary'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MineCommandRowHeader(
            icon: Icons.storage_rounded,
            title: '本地数据',
            subtitle: 'LOCAL STORAGE',
            badge: '1.2',
          ),
          const SizedBox(height: 10),
          _DataMetricLine(label: '习惯与打卡', value: '$habitCount 个习惯'),
          const SizedBox(height: 6),
          _DataMetricLine(label: '目标与行动', value: '$taskCount 条行动'),
          const SizedBox(height: 6),
          _DataMetricLine(label: '专注记录', value: '$focusCount 次专注'),
        ],
      ),
    );
  }
}

class _FutureSection extends StatelessWidget {
  const _FutureSection({
    required this.rowTitle,
    required this.helper,
    required this.icon,
    this.badgeLabel = '后续',
  });

  final String rowTitle;
  final String helper;
  final IconData icon;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return _MineTechPanel(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: _MineCommandRowHeader(
        icon: icon,
        title: rowTitle,
        subtitle: helper,
        badge: badgeLabel == '后续' ? null : badgeLabel,
        showChevron: true,
      ),
    );
  }
}

class _MineCommandRowHeader extends StatelessWidget {
  const _MineCommandRowHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.showChevron = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            icon,
            color: colorScheme.onSurface.withValues(alpha: 0.86),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.35,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1111).withValues(alpha: 0.90),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              badge!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                height: 1.0,
              ),
            ),
          ),
        if (showChevron) ...[
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
            size: 20,
          ),
        ],
      ],
    );
  }
}

class _DataMetricLine extends StatelessWidget {
  const _DataMetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChanged(value);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.38),
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected
                        ? colorScheme.onSurface
                        : AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: 0.1,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
