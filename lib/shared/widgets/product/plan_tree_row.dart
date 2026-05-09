import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/shared/widgets/product/progress_rail.dart';

enum PlanTreeRowType { project, subproject, task }

class PlanTreeRow extends StatelessWidget {
  const PlanTreeRow({
    required this.type,
    required this.title,
    this.identitySeed,
    this.icon,
    this.description = '',
    this.colorValue,
    this.level = 0,
    this.metadataText,
    this.progressText,
    this.progressValue,
    this.hasProgress = false,
    this.completed = false,
    this.showConnector = false,
    this.showProgressDots = false,
    this.children = const <Widget>[],
    this.progressTextKey,
    this.toggleKey,
    this.editKey,
    this.detailKey,
    this.addRecordKey,
    this.addSubprojectKey,
    this.addTaskKey,
    this.emptyAffordanceKey,
    this.emptyAffordanceText,
    this.onToggleTask,
    this.onEdit,
    this.onOpenDetail,
    this.onAddRecord,
    this.onAddSubproject,
    this.onAddTask,
    this.onEmptyAffordanceTap,
    super.key,
  });

  final PlanTreeRowType type;
  final String title;
  final String? identitySeed;
  final String? icon;
  final String description;
  final int? colorValue;
  final int level;
  final String? metadataText;
  final String? progressText;
  final double? progressValue;
  final bool hasProgress;
  final bool completed;
  final bool showConnector;
  final bool showProgressDots;
  final List<Widget> children;
  final Key? progressTextKey;
  final Key? toggleKey;
  final Key? editKey;
  final Key? detailKey;
  final Key? addRecordKey;
  final Key? addSubprojectKey;
  final Key? addTaskKey;
  final Key? emptyAffordanceKey;
  final String? emptyAffordanceText;
  final VoidCallback? onToggleTask;
  final VoidCallback? onEdit;
  final VoidCallback? onOpenDetail;
  final VoidCallback? onAddRecord;
  final VoidCallback? onAddSubproject;
  final VoidCallback? onAddTask;
  final VoidCallback? onEmptyAffordanceTap;

  @override
  Widget build(BuildContext context) {
    if (type == PlanTreeRowType.task) {
      return _TaskPlanTreeRow(
        title: title,
        completed: completed,
        metadataText: metadataText,
        toggleKey: toggleKey,
        editKey: editKey,
        addRecordKey: addRecordKey,
        onToggleTask: onToggleTask,
        onEdit: onEdit,
        onAddRecord: onAddRecord,
      );
    }

    final content = Padding(
      padding: EdgeInsets.only(
        top: level > 0 ? AppThemeTokens.spaceSm : 0,
        left: showConnector ? 0 : level * 18,
      ),
      child: _BranchPlanTreeRow(
        type: type,
        title: title,
        identitySeed: identitySeed ?? title,
        icon: icon,
        description: description,
        colorValue: colorValue,
        metadataText: metadataText,
        progressText: progressText,
        progressValue: progressValue,
        hasProgress: hasProgress,
        showProgressDots: showProgressDots,
        progressTextKey: progressTextKey,
        editKey: editKey,
        detailKey: detailKey,
        addRecordKey: addRecordKey,
        addSubprojectKey: addSubprojectKey,
        addTaskKey: addTaskKey,
        emptyAffordanceKey: emptyAffordanceKey,
        emptyAffordanceText: emptyAffordanceText,
        onEdit: onEdit,
        onOpenDetail: onOpenDetail,
        onAddRecord: onAddRecord,
        onAddSubproject: onAddSubproject,
        onAddTask: onAddTask,
        onEmptyAffordanceTap: onEmptyAffordanceTap,
        children: children,
      ),
    );

    if (!showConnector) {
      return content;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlanConnector(hasProgress: hasProgress, colorValue: colorValue),
        Expanded(child: content),
      ],
    );
  }
}

class _BranchPlanTreeRow extends StatelessWidget {
  const _BranchPlanTreeRow({
    required this.type,
    required this.title,
    required this.identitySeed,
    required this.hasProgress,
    required this.showProgressDots,
    required this.children,
    this.icon,
    this.description = '',
    this.colorValue,
    this.metadataText,
    this.progressText,
    this.progressValue,
    this.progressTextKey,
    this.editKey,
    this.detailKey,
    this.addRecordKey,
    this.addSubprojectKey,
    this.addTaskKey,
    this.emptyAffordanceKey,
    this.emptyAffordanceText,
    this.onEdit,
    this.onOpenDetail,
    this.onAddRecord,
    this.onAddSubproject,
    this.onAddTask,
    this.onEmptyAffordanceTap,
  });

  final PlanTreeRowType type;
  final String title;
  final String identitySeed;
  final String? icon;
  final String description;
  final int? colorValue;
  final String? metadataText;
  final String? progressText;
  final double? progressValue;
  final bool hasProgress;
  final bool showProgressDots;
  final List<Widget> children;
  final Key? progressTextKey;
  final Key? editKey;
  final Key? detailKey;
  final Key? addRecordKey;
  final Key? addSubprojectKey;
  final Key? addTaskKey;
  final Key? emptyAffordanceKey;
  final String? emptyAffordanceText;
  final VoidCallback? onEdit;
  final VoidCallback? onOpenDetail;
  final VoidCallback? onAddRecord;
  final VoidCallback? onAddSubproject;
  final VoidCallback? onAddTask;
  final VoidCallback? onEmptyAffordanceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isProject = type == PlanTreeRowType.project;
    final identityColor = colorValue == null
        ? colorScheme.primary
        : Color(colorValue!);

    return Container(
      padding: EdgeInsets.all(isProject ? 14 : 12),
      decoration: BoxDecoration(
        color: isProject
            ? Theme.of(context).scaffoldBackgroundColor.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.18 : 0.48,
              )
            : AppThemeTokens.softSurfaceTone(colorScheme),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: hasProgress
              ? identityColor.withValues(alpha: isProject ? 0.12 : 0.10)
              : AppThemeTokens.borderTone(colorScheme),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isProject ? 36 : 26,
            height: isProject ? 4 : 3,
            decoration: BoxDecoration(
              color: identityColor.withValues(
                alpha: hasProgress ? (isProject ? 0.34 : 0.30) : 0.12,
              ),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlanVisualMarker(
                markerKey: isProject
                    ? ValueKey('project-identity-icon-$identitySeed')
                    : null,
                iconLabel: icon ?? (isProject ? '📁' : '🧩'),
                colorValue: identityColor.toARGB32(),
                size: isProject ? 34 : 32,
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description.trim(),
                        key: isProject
                            ? ValueKey('project-description-$identitySeed')
                            : null,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (metadataText != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        metadataText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              _PlanIdentityPill(label: isProject ? '项目' : '子项目'),
            ],
          ),
          if (_hasActions) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      key: editKey,
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(isProject ? '编辑项目' : '编辑分组'),
                    ),
                  if (isProject && onOpenDetail != null)
                    TextButton.icon(
                      key: detailKey,
                      onPressed: onOpenDetail,
                      icon: const Icon(
                        Icons.dashboard_customize_rounded,
                        size: 16,
                      ),
                      label: const Text('项目详情'),
                    ),
                  if (onAddRecord != null)
                    TextButton(
                      key: addRecordKey,
                      onPressed: onAddRecord,
                      child: const Text('添加记录'),
                    ),
                  if (isProject && onAddSubproject != null)
                    TextButton(
                      key: addSubprojectKey,
                      onPressed: onAddSubproject,
                      child: const Text('添加子项目'),
                    ),
                  if (onAddTask != null)
                    TextButton(
                      key: addTaskKey,
                      onPressed: onAddTask,
                      child: const Text('添加行动'),
                    ),
                ],
              ),
            ),
          ],
          if (progressText != null) ...[
            const SizedBox(height: 2),
            Text(
              progressText!,
              key: progressTextKey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasProgress
                    ? identityColor
                    : AppThemeTokens.secondaryTextTone(colorScheme),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ProgressRail(
              value: hasProgress ? progressValue : null,
              height: 6,
              fillColor: identityColor.withValues(alpha: 0.72),
              backgroundColor: AppThemeTokens.borderTone(
                colorScheme,
              ).withValues(alpha: 0.42),
            ),
            if (showProgressDots) ...[
              const SizedBox(height: 7),
              _PlanProgressDots(
                activeCount: hasProgress
                    ? ((progressValue ?? 0) * 5).ceil().clamp(1, 5)
                    : 0,
                color: identityColor,
              ),
            ],
          ],
          if (emptyAffordanceText != null) ...[
            const SizedBox(height: 8),
            _PlanInlineCue(
              cueKey: emptyAffordanceKey,
              text: emptyAffordanceText!,
              onTap: onEmptyAffordanceTap,
            ),
          ],
          if (children.isNotEmpty) ...[const SizedBox(height: 8), ...children],
        ],
      ),
    );
  }

  bool get _hasActions =>
      onEdit != null ||
      onOpenDetail != null ||
      onAddRecord != null ||
      onAddSubproject != null ||
      onAddTask != null;
}

class _TaskPlanTreeRow extends StatelessWidget {
  const _TaskPlanTreeRow({
    required this.title,
    required this.completed,
    this.metadataText,
    this.toggleKey,
    this.editKey,
    this.addRecordKey,
    this.onToggleTask,
    this.onEdit,
    this.onAddRecord,
  });

  final String title;
  final bool completed;
  final String? metadataText;
  final Key? toggleKey;
  final Key? editKey;
  final Key? addRecordKey;
  final VoidCallback? onToggleTask;
  final VoidCallback? onEdit;
  final VoidCallback? onAddRecord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: completed
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(
            color: completed
                ? colorScheme.primary.withValues(alpha: 0.18)
                : AppThemeTokens.borderTone(colorScheme),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onToggleTask != null)
                  Checkbox(
                    key: toggleKey,
                    value: completed,
                    onChanged: (_) => onToggleTask?.call(),
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: completed
                          ? colorScheme.primary
                          : AppThemeTokens.secondaryTextTone(colorScheme),
                    ),
                  ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: completed
                              ? AppThemeTokens.secondaryTextTone(colorScheme)
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (metadataText != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          metadataText!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppThemeTokens.secondaryTextTone(
                              colorScheme,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  completed ? '已完成' : '行动',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: completed
                        ? colorScheme.primary
                        : AppThemeTokens.secondaryTextTone(colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (onEdit != null || onAddRecord != null) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      key: editKey,
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('编辑行动'),
                    ),
                  if (onAddRecord != null)
                    TextButton.icon(
                      key: addRecordKey,
                      onPressed: onAddRecord,
                      icon: const Icon(Icons.note_add_outlined, size: 16),
                      label: const Text('添加记录'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanConnector extends StatelessWidget {
  const _PlanConnector({required this.hasProgress, this.colorValue});

  final bool hasProgress;
  final int? colorValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final identityColor = colorValue == null
        ? colorScheme.primary
        : Color(colorValue!);

    return Container(
      width: 2,
      height: 72,
      margin: const EdgeInsets.only(left: 16, right: 14, top: 4),
      color: hasProgress
          ? identityColor.withValues(alpha: 0.18)
          : AppThemeTokens.borderTone(colorScheme),
    );
  }
}

class _PlanInlineCue extends StatelessWidget {
  const _PlanInlineCue({required this.text, this.cueKey, this.onTap});

  final Key? cueKey;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onTap == null
            ? AppThemeTokens.softSurfaceTone(colorScheme)
            : colorScheme.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: onTap == null
              ? AppThemeTokens.borderTone(colorScheme)
              : colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onTap == null
                    ? AppThemeTokens.secondaryTextTone(colorScheme)
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onTap != null)
            Icon(Icons.add_rounded, size: 16, color: colorScheme.primary),
        ],
      ),
    );

    if (onTap == null) {
      return Container(key: cueKey, child: content);
    }

    return InkWell(
      key: cueKey,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      onTap: onTap,
      child: content,
    );
  }
}

class _PlanIdentityPill extends StatelessWidget {
  const _PlanIdentityPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppThemeTokens.secondaryTextTone(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlanProgressDots extends StatelessWidget {
  const _PlanProgressDots({required this.activeCount, required this.color});

  final int activeCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(5, (index) {
        final active = index < activeCount;

        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: active ? 18 : 8,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.48)
                  : AppThemeTokens.borderTone(
                      colorScheme,
                    ).withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusPill),
            ),
          ),
        );
      }),
    );
  }
}

class _PlanVisualMarker extends StatelessWidget {
  const _PlanVisualMarker({
    required this.iconLabel,
    required this.colorValue,
    required this.size,
    this.markerKey,
  });

  final String iconLabel;
  final int colorValue;
  final double size;
  final Key? markerKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final identityColor = Color(colorValue);
    final markerText = iconLabel.trim().isEmpty ? '📁' : iconLabel.trim();

    return Container(
      key: markerKey,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: identityColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: identityColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        String.fromCharCodes(markerText.runes.take(2)),
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.brightness == Brightness.dark
              ? identityColor.withValues(alpha: 0.92)
              : identityColor,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
