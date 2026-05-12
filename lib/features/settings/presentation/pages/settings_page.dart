import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/settings/application/app_settings_store.dart';
import 'package:four_in_one_app/app/settings/presentation/app_settings_scope.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/features/focus/presentation/focus_scope.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/habits/presentation/habits_scope.dart';
import 'package:four_in_one_app/shared/widgets/product/my_settings_section.dart';
import 'package:four_in_one_app/shared/widgets/product/product_page_header.dart';

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
        AppThemeTokens.spaceXl,
        AppThemeTokens.pagePadding,
        AppThemeTokens.pagePadding,
      ),
      children: [
        const ProductPageHeader(
          eyebrow: '个人中心',
          title: '我的',
          subtitle: '外观、提醒与本地数据，慢慢集中到这里。',
        ),
        const SizedBox(height: AppThemeTokens.spaceXl),
        _AppearanceSection(settingsStore: settingsStore),
        const SizedBox(height: AppThemeTokens.spaceLg),
        const _FutureSection(
          title: '提醒',
          rowTitle: '提醒设置',
          helper: '后续集中管理提醒设置',
          icon: Icons.notifications_none_rounded,
        ),
        const SizedBox(height: AppThemeTokens.spaceLg),
        const _FutureSection(
          title: '隐私与权限',
          rowTitle: '权限说明',
          helper: '后续整理权限与隐私说明',
          icon: Icons.privacy_tip_outlined,
        ),
        const SizedBox(height: AppThemeTokens.spaceLg),
        const _DataSummarySection(),
        const SizedBox(height: AppThemeTokens.spaceLg),
        const _FutureSection(
          title: '关于',
          rowTitle: '版本信息',
          helper: '当前测试版本信息',
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
    return MySettingsSection(
      title: '外观',
      subtitle: '让界面跟随你的使用环境。',
      leadingIcon: Icons.palette_outlined,
      rows: [
        MySettingsRow(
          title: '主题模式',
          subtitle: '跟随系统、浅色或深色',
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
                title: '浅色',
                value: AppThemeMode.light,
                groupValue: settingsStore.themeMode,
                onChanged: settingsStore.setThemeMode,
              ),
              _ThemeModeTile(
                key: const ValueKey('settings-theme-mode-dark'),
                title: '深色',
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
        const SizedBox(height: AppThemeTokens.spaceMd),
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
        const SizedBox(height: AppThemeTokens.spaceMd),
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
        const SizedBox(height: AppThemeTokens.spaceMd),
        _VisualColorPickerPanel(
          key: const ValueKey('theme-studio-visual-picker'),
          color: _currentTargetColor(store),
          targetLabel: _target.label,
          onColorChanged: _applyVisualColor,
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        Text(
          '不会选色可以直接拖动色盘或点选色卡。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceLg),
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
    final previewBackground = Color.lerp(background, Colors.white, 0.82)!;
    final previewSurface = Color.lerp(surface, Colors.white, 0.7)!;

    return Container(
      key: const ValueKey('theme-studio-preview'),
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: previewBackground,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
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
                    color: Colors.black.withValues(alpha: 0.82),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.62),
              ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '色卡灵感',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        for (final board in _themePaletteBoards) ...[
          _PaletteBoard(
            board: board,
            currentColor: currentColor,
            target: target,
            onColorSelected: onColorSelected,
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
        ],
      ],
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
      padding: const EdgeInsets.all(AppThemeTokens.spaceSm),
      decoration: BoxDecoration(
        color: AppThemeTokens.softSurfaceTone(
          colorScheme,
        ).withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.64),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            board.title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          Wrap(
            spacing: AppThemeTokens.spaceSm,
            runSpacing: AppThemeTokens.spaceSm,
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
    return ExpansionTile(
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
        ? colorScheme.primary.withValues(alpha: 0.70)
        : AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.72);

    return InkWell(
      key: ValueKey<String>('${target.optionKeyPrefix}-$swatchKey'),
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusXl),
                border: Border.all(color: ringColor, width: selected ? 1.5 : 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        key: ValueKey<String>(
                          '${target.selectedKeyPrefix}-$swatchKey',
                        ),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceXs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? colorScheme.primary
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
          enabled: false,
        ),
        MySettingsRow(
          title: '目标与行动',
          subtitle: '$taskCount 条行动',
          leadingIcon: Icons.account_tree_rounded,
          enabled: false,
        ),
        MySettingsRow(
          title: '专注记录',
          subtitle: '$focusCount 次专注',
          leadingIcon: Icons.timer_rounded,
          enabled: false,
        ),
      ],
    );
  }
}

class _FutureSection extends StatelessWidget {
  const _FutureSection({
    required this.title,
    required this.rowTitle,
    required this.helper,
    required this.icon,
    this.badgeLabel = '后续',
  });

  final String title;
  final String rowTitle;
  final String helper;
  final IconData icon;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return MySettingsSection(
      title: title,
      rows: [
        MySettingsRow(
          title: rowTitle,
          subtitle: helper,
          leadingIcon: icon,
          enabled: false,
          trailing: _QuietBadge(label: badgeLabel),
        ),
      ],
    );
  }
}

class _QuietBadge extends StatelessWidget {
  const _QuietBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
        border: Border.all(color: AppThemeTokens.borderTone(colorScheme)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeTokens.spaceSm,
          vertical: AppThemeTokens.spaceXs,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppThemeTokens.secondaryTextTone(colorScheme),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
