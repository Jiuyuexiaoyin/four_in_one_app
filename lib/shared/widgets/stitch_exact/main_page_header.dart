import 'package:flutter/material.dart';
import 'package:four_in_one_app/shared/widgets/stitch_exact/stitch_exact.dart';

class StitchExactMainHeaderAction {
  const StitchExactMainHeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.key,
    this.disabledTooltip,
    this.primary = false,
  }) : assert(tooltip != '');

  final Key? key;
  final IconData icon;
  final String tooltip;
  final String? disabledTooltip;
  final VoidCallback? onPressed;
  final bool primary;

  String get effectiveTooltip =>
      onPressed == null ? disabledTooltip ?? tooltip : tooltip;
}

class StitchExactMainPageHeader extends StatelessWidget {
  const StitchExactMainPageHeader({
    required this.title,
    required this.leadingIcon,
    required this.actions,
    super.key,
  }) : assert(actions.length <= 2);

  final String title;
  final IconData leadingIcon;
  final List<StitchExactMainHeaderAction> actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.72),
                ),
              ),
              child: SizedBox.square(
                dimension: 48,
                child: Icon(leadingIcon, color: colorScheme.primary, size: 21),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
            if (actions.isNotEmpty) const SizedBox(width: 10),
            for (var index = 0; index < actions.length; index += 1) ...[
              if (index > 0) const SizedBox(width: 8),
              _MainHeaderActionButton(action: actions[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MainHeaderActionButton extends StatefulWidget {
  const _MainHeaderActionButton({required this.action});

  final StitchExactMainHeaderAction action;

  @override
  State<_MainHeaderActionButton> createState() =>
      _MainHeaderActionButtonState();
}

class _MainHeaderActionButtonState extends State<_MainHeaderActionButton> {
  bool _pressed = false;

  StitchExactMainHeaderAction get action => widget.action;

  void _setPressed(bool value) {
    if (action.onPressed == null || _pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = action.primary
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final background = action.primary
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: StitchExactMotion.fast,
        curve: StitchExactMotion.fastCurve,
        child: IconButton(
          key: action.key,
          tooltip: action.effectiveTooltip,
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 20),
          style:
              IconButton.styleFrom(
                fixedSize: const Size.square(48),
                padding: EdgeInsets.zero,
                foregroundColor: foreground,
                backgroundColor: background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.72),
                  ),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return action.primary
                        ? colorScheme.onPrimary.withValues(alpha: 0.16)
                        : colorScheme.primary.withValues(alpha: 0.14);
                  }
                  return null;
                }),
              ),
        ),
      ),
    );
  }
}
