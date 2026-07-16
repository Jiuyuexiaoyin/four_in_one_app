import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';

enum CompactPlanFilterKind {
  today('今天'),
  overdue('逾期'),
  highPriority('高优先级'),
  incomplete('未完成'),
  completed('已完成');

  const CompactPlanFilterKind(this.label);

  final String label;
}

enum CompactPlanSortMode {
  hierarchy('默认层级'),
  dueDate('截止日期'),
  priority('优先级');

  const CompactPlanSortMode(this.label);

  final String label;
}

@immutable
class CompactPlanFilterState {
  const CompactPlanFilterState({
    this.filters = const <CompactPlanFilterKind>{},
    this.tag,
    this.sortMode = CompactPlanSortMode.hierarchy,
  });

  static const _unchangedTag = Object();

  final Set<CompactPlanFilterKind> filters;
  final String? tag;
  final CompactPlanSortMode sortMode;

  int get activeFilterCount => filters.length + (tag == null ? 0 : 1);

  bool get hasActiveFilters => activeFilterCount > 0;

  bool get isDefault =>
      !hasActiveFilters && sortMode == CompactPlanSortMode.hierarchy;

  CompactPlanFilterState copyWith({
    Set<CompactPlanFilterKind>? filters,
    Object? tag = _unchangedTag,
    CompactPlanSortMode? sortMode,
  }) {
    return CompactPlanFilterState(
      filters: filters ?? this.filters,
      tag: identical(tag, _unchangedTag) ? this.tag : tag as String?,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

class CompactPlanFilterBar extends StatelessWidget {
  const CompactPlanFilterBar({
    required this.searchController,
    required this.availableTags,
    required this.filterState,
    required this.onSearchChanged,
    required this.onFilterStateChanged,
    required this.onClearAll,
    this.results,
    super.key,
  });

  final TextEditingController searchController;
  final List<String> availableTags;
  final CompactPlanFilterState filterState;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CompactPlanFilterState> onFilterStateChanged;
  final VoidCallback onClearAll;
  final Widget? results;

  bool get _isActive =>
      searchController.text.trim().isNotEmpty || !filterState.isDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: AppThemeTokens.borderTone(colorScheme).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '查找与筛选',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_isActive)
                TextButton(
                  key: const ValueKey('plan-search-clear'),
                  onPressed: onClearAll,
                  child: const Text('清除'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('plan-search-field'),
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索项目、行动或标签',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            key: const ValueKey('plan-search-clear-query'),
                            tooltip: '清除搜索',
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest.withValues(
                      alpha: 0.74,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMd,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMd,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _FilterButton(
                count: filterState.activeFilterCount,
                onPressed: () => _openFilterSheet(context),
              ),
              PopupMenuButton<CompactPlanSortMode>(
                key: const ValueKey('plan-sort-button'),
                tooltip: '排序：${filterState.sortMode.label}',
                icon: Icon(
                  Icons.swap_vert_rounded,
                  color: filterState.sortMode == CompactPlanSortMode.hierarchy
                      ? AppThemeTokens.secondaryTextTone(colorScheme)
                      : colorScheme.primary,
                ),
                onSelected: (mode) {
                  onFilterStateChanged(filterState.copyWith(sortMode: mode));
                },
                itemBuilder: (context) => [
                  for (final mode in CompactPlanSortMode.values)
                    PopupMenuItem<CompactPlanSortMode>(
                      key: ValueKey<String>('plan-sort-menu-${mode.name}'),
                      value: mode,
                      child: Row(
                        children: [
                          Expanded(child: Text(mode.label)),
                          if (filterState.sortMode == mode)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: filterState.hasActiveFilters
                ? Padding(
                    key: ValueKey<String>(
                      'plan-active-filters-${filterState.activeFilterCount}',
                    ),
                    padding: const EdgeInsets.only(top: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final filter in filterState.filters) ...[
                            InputChip(
                              key: ValueKey<String>(
                                'plan-active-filter-${filter.name}',
                              ),
                              label: Text(filter.label),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () => _removeFilter(filter),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (filterState.tag != null)
                            InputChip(
                              key: const ValueKey('plan-active-filter-tag'),
                              label: Text('#${filterState.tag}'),
                              visualDensity: VisualDensity.compact,
                              onDeleted: () {
                                onFilterStateChanged(
                                  filterState.copyWith(tag: null),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey('plan-active-filters-empty'),
                  ),
          ),
          if (results != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            results!,
          ],
        ],
      ),
    );
  }

  void _removeFilter(CompactPlanFilterKind filter) {
    final updated = Set<CompactPlanFilterKind>.of(filterState.filters)
      ..remove(filter);
    onFilterStateChanged(filterState.copyWith(filters: updated));
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet<CompactPlanFilterState>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _CompactPlanFilterSheet(
        initialState: filterState,
        availableTags: availableTags,
      ),
    );

    if (result != null) {
      onFilterStateChanged(result);
    }
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          key: const ValueKey('plan-filter-button'),
          tooltip: count == 0 ? '筛选' : '筛选，已启用 $count 项',
          onPressed: onPressed,
          icon: Icon(
            Icons.tune_rounded,
            color: count == 0
                ? AppThemeTokens.secondaryTextTone(colorScheme)
                : colorScheme.primary,
          ),
        ),
        if (count > 0)
          Positioned(
            key: const ValueKey('plan-filter-count-badge'),
            right: 3,
            top: 3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: colorScheme.surface),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactPlanFilterSheet extends StatefulWidget {
  const _CompactPlanFilterSheet({
    required this.initialState,
    required this.availableTags,
  });

  final CompactPlanFilterState initialState;
  final List<String> availableTags;

  @override
  State<_CompactPlanFilterSheet> createState() =>
      _CompactPlanFilterSheetState();
}

class _CompactPlanFilterSheetState extends State<_CompactPlanFilterSheet> {
  late CompactPlanFilterState _draft;

  @override
  void initState() {
    super.initState();
    _draft = CompactPlanFilterState(
      filters: Set<CompactPlanFilterKind>.of(widget.initialState.filters),
      tag: widget.initialState.tag,
      sortMode: widget.initialState.sortMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FractionallySizedBox(
      heightFactor: 0.84,
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
                        '筛选计划',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '关闭不会改变已应用的筛选',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.secondaryTextTone(colorScheme),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('plan-filter-sheet-close'),
                  tooltip: '关闭',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                _FilterSection(
                  title: '日期 / 状态',
                  children: [
                    _filterChip(CompactPlanFilterKind.today),
                    _filterChip(CompactPlanFilterKind.overdue),
                  ],
                ),
                _FilterSection(
                  title: '优先级',
                  children: [_filterChip(CompactPlanFilterKind.highPriority)],
                ),
                _FilterSection(
                  title: '完成情况',
                  children: [
                    _filterChip(CompactPlanFilterKind.incomplete),
                    _filterChip(CompactPlanFilterKind.completed),
                  ],
                ),
                _FilterSection(
                  title: '标签',
                  children: widget.availableTags.isEmpty
                      ? [
                          Text(
                            '还没有标签',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppThemeTokens.secondaryTextTone(
                                colorScheme,
                              ),
                            ),
                          ),
                        ]
                      : [
                          for (final tag in widget.availableTags)
                            ChoiceChip(
                              key: ValueKey<String>('plan-tag-$tag'),
                              label: Text('#$tag'),
                              selected: _draft.tag == tag,
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) {
                                setState(() {
                                  _draft = _draft.copyWith(
                                    tag: _draft.tag == tag ? null : tag,
                                  );
                                });
                              },
                            ),
                        ],
                ),
                _FilterSection(
                  title: '排序',
                  children: [
                    for (final mode in CompactPlanSortMode.values)
                      ChoiceChip(
                        key: ValueKey<String>('plan-sort-${mode.name}'),
                        label: Text(mode.label),
                        selected: _draft.sortMode == mode,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          setState(() {
                            _draft = _draft.copyWith(sortMode: mode);
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppThemeTokens.borderTone(
                    colorScheme,
                  ).withValues(alpha: 0.24),
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  key: const ValueKey('plan-filter-reset'),
                  onPressed: () {
                    setState(() {
                      _draft = const CompactPlanFilterState();
                    });
                  },
                  child: const Text('重置'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('plan-filter-apply'),
                    onPressed: () => Navigator.of(context).pop(_draft),
                    child: const Text('应用筛选'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(CompactPlanFilterKind filter) {
    return FilterChip(
      key: ValueKey<String>('plan-filter-${filter.name}'),
      label: Text(filter.label),
      selected: _draft.filters.contains(filter),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => _toggleFilter(filter),
    );
  }

  void _toggleFilter(CompactPlanFilterKind filter) {
    final filters = Set<CompactPlanFilterKind>.of(_draft.filters);
    final selected = filters.contains(filter);

    switch (filter) {
      case CompactPlanFilterKind.today:
      case CompactPlanFilterKind.overdue:
        filters.remove(CompactPlanFilterKind.today);
        filters.remove(CompactPlanFilterKind.overdue);
        break;
      case CompactPlanFilterKind.incomplete:
      case CompactPlanFilterKind.completed:
        filters.remove(CompactPlanFilterKind.incomplete);
        filters.remove(CompactPlanFilterKind.completed);
        break;
      case CompactPlanFilterKind.highPriority:
        filters.remove(CompactPlanFilterKind.highPriority);
        break;
    }

    if (!selected) {
      filters.add(filter);
    }

    setState(() {
      _draft = _draft.copyWith(filters: filters);
    });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppThemeTokens.secondaryTextTone(colorScheme),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
