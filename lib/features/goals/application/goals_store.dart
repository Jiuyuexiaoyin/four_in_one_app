import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:four_in_one_app/features/goals/data/goals_local_storage.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';

typedef GoalNowProvider = DateTime Function();

class GoalsStore extends ChangeNotifier {
  static const habitPlanRecordSourceType = 'habit';

  static String habitDailyCompletionSourceKey({
    required String habitId,
    required String localDate,
  }) {
    return 'habit:$habitId:$localDate:dailyCompletion';
  }

  GoalsStore._({
    required GoalsStorage storage,
    required List<GoalItem> initialGoals,
    required List<ProjectItem> initialProjects,
    required List<SubprojectItem> initialSubprojects,
    required List<GoalTaskItem> initialTasks,
    required List<PlanRecord> initialRecords,
    required List<PlanRecordAttachment> initialAttachments,
    required List<LegacyGoalState> initialLegacyGoalStates,
    required int nextGoalId,
    required int nextProjectId,
    required int nextSubprojectId,
    required int nextTaskId,
    required int nextRecordId,
    required int nextAttachmentId,
    required GoalNowProvider nowProvider,
  }) : _storage = storage,
       _goals = List<GoalItem>.of(initialGoals),
       _projects = List<ProjectItem>.of(initialProjects),
       _subprojects = List<SubprojectItem>.of(initialSubprojects),
       _tasks = List<GoalTaskItem>.of(initialTasks),
       _records = List<PlanRecord>.of(initialRecords),
       _attachments = List<PlanRecordAttachment>.of(initialAttachments),
       _legacyGoalStates = List<LegacyGoalState>.of(initialLegacyGoalStates),
       _nextGoalId = nextGoalId,
       _nextProjectId = nextProjectId,
       _nextSubprojectId = nextSubprojectId,
       _nextTaskId = nextTaskId,
       _nextRecordId = nextRecordId,
       _nextAttachmentId = nextAttachmentId,
       _nowProvider = nowProvider;

  static Future<GoalsStore> load(
    GoalsStorage storage, {
    GoalNowProvider? nowProvider,
  }) async {
    final effectiveNowProvider = nowProvider ?? DateTime.now;

    try {
      final snapshot = await storage.loadSnapshot(
        migrationCreatedAt: effectiveNowProvider(),
      );
      final store = GoalsStore._(
        storage: storage,
        initialGoals: snapshot.goals,
        initialProjects: snapshot.projects,
        initialSubprojects: snapshot.subprojects,
        initialTasks: snapshot.tasks,
        initialRecords: snapshot.records,
        initialAttachments: snapshot.attachments,
        initialLegacyGoalStates: snapshot.legacyGoalStates,
        nextGoalId: _deriveNextId(snapshot.goals, 'goal'),
        nextProjectId: _deriveNextId(snapshot.projects, 'project'),
        nextSubprojectId: _deriveNextId(snapshot.subprojects, 'subproject'),
        nextTaskId: _deriveNextId(snapshot.tasks, 'task'),
        nextRecordId: _deriveNextId(snapshot.records, 'record'),
        nextAttachmentId: _deriveNextId(snapshot.attachments, 'attachment'),
        nowProvider: effectiveNowProvider,
      );

      if (snapshot.shouldPersistAfterLoad) {
        await store._persistSnapshot();
      }

      return store;
    } catch (_) {
      return GoalsStore._(
        storage: storage,
        initialGoals: const <GoalItem>[],
        initialProjects: const <ProjectItem>[],
        initialSubprojects: const <SubprojectItem>[],
        initialTasks: const <GoalTaskItem>[],
        initialRecords: const <PlanRecord>[],
        initialAttachments: const <PlanRecordAttachment>[],
        initialLegacyGoalStates: const <LegacyGoalState>[],
        nextGoalId: 1,
        nextProjectId: 1,
        nextSubprojectId: 1,
        nextTaskId: 1,
        nextRecordId: 1,
        nextAttachmentId: 1,
        nowProvider: effectiveNowProvider,
      );
    }
  }

  factory GoalsStore.inMemory({
    List<GoalItem>? initialGoals,
    List<ProjectItem>? initialProjects,
    List<SubprojectItem>? initialSubprojects,
    List<GoalTaskItem>? initialTasks,
    List<PlanRecord>? initialRecords,
    List<PlanRecordAttachment>? initialAttachments,
    List<LegacyGoalState>? initialLegacyGoalStates,
    GoalNowProvider? nowProvider,
  }) {
    final goals = List<GoalItem>.of(initialGoals ?? const <GoalItem>[]);
    final projects = List<ProjectItem>.of(
      initialProjects ?? const <ProjectItem>[],
    );
    final subprojects = List<SubprojectItem>.of(
      initialSubprojects ?? const <SubprojectItem>[],
    );
    final tasks = List<GoalTaskItem>.of(initialTasks ?? const <GoalTaskItem>[]);
    final records = List<PlanRecord>.of(initialRecords ?? const <PlanRecord>[]);
    final attachments = List<PlanRecordAttachment>.of(
      initialAttachments ?? const <PlanRecordAttachment>[],
    );

    return GoalsStore._(
      storage: _InMemoryGoalsStorage(),
      initialGoals: goals,
      initialProjects: projects,
      initialSubprojects: subprojects,
      initialTasks: tasks,
      initialRecords: records,
      initialAttachments: attachments,
      initialLegacyGoalStates: List<LegacyGoalState>.of(
        initialLegacyGoalStates ?? const <LegacyGoalState>[],
      ),
      nextGoalId: _deriveNextId(goals, 'goal'),
      nextProjectId: _deriveNextId(projects, 'project'),
      nextSubprojectId: _deriveNextId(subprojects, 'subproject'),
      nextTaskId: _deriveNextId(tasks, 'task'),
      nextRecordId: _deriveNextId(records, 'record'),
      nextAttachmentId: _deriveNextId(attachments, 'attachment'),
      nowProvider: nowProvider ?? DateTime.now,
    );
  }

  final GoalsStorage _storage;
  final List<GoalItem> _goals;
  final List<ProjectItem> _projects;
  final List<SubprojectItem> _subprojects;
  final List<GoalTaskItem> _tasks;
  final List<PlanRecord> _records;
  final List<PlanRecordAttachment> _attachments;
  final List<LegacyGoalState> _legacyGoalStates;
  final GoalNowProvider _nowProvider;
  int _nextGoalId;
  int _nextProjectId;
  int _nextSubprojectId;
  int _nextTaskId;
  int _nextRecordId;
  int _nextAttachmentId;

  UnmodifiableListView<GoalItem> get goals => UnmodifiableListView(_goals);

  UnmodifiableListView<ProjectItem> get projects =>
      UnmodifiableListView(_projects);

  UnmodifiableListView<SubprojectItem> get subprojects =>
      UnmodifiableListView(_subprojects);

  UnmodifiableListView<GoalTaskItem> get tasks => UnmodifiableListView(_tasks);

  UnmodifiableListView<PlanRecord> get records =>
      UnmodifiableListView(_records);

  UnmodifiableListView<PlanRecordAttachment> get attachments =>
      UnmodifiableListView(_attachments);

  UnmodifiableListView<LegacyGoalState> get legacyGoalStates =>
      UnmodifiableListView(_legacyGoalStates);

  GoalItem? goalById(String goalId) {
    for (final goal in _goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }

  ProjectItem? projectById(String projectId) => _projectById(projectId);

  SubprojectItem? subprojectById(String subprojectId) {
    for (final subproject in _subprojects) {
      if (subproject.id == subprojectId) {
        return subproject;
      }
    }

    return null;
  }

  GoalTaskItem? taskById(String taskId) => _taskById(taskId);

  int get totalCount => _goals.length;

  int get completedCount =>
      _goals.where((goal) => computeGoalProgress(goal.id).isComplete).length;

  int get remainingCount => totalCount - completedCount;

  Future<void> createGoal(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    _goals.insert(
      0,
      GoalItem(
        id: 'goal-${_nextGoalId++}',
        title: trimmedTitle,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
  }

  Future<void> createProject(String goalId, String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || !_goals.any((goal) => goal.id == goalId)) {
      return;
    }

    _projects.insert(
      0,
      ProjectItem(
        id: 'project-${_nextProjectId++}',
        goalId: goalId,
        title: trimmedTitle,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
  }

  Future<void> createSubproject(String projectId, String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty ||
        !_projects.any((project) => project.id == projectId)) {
      return;
    }

    _subprojects.insert(
      0,
      SubprojectItem(
        id: 'subproject-${_nextSubprojectId++}',
        projectId: projectId,
        title: trimmedTitle,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
  }

  Future<void> createTask(
    String projectId,
    String title, {
    String? subprojectId,
  }) async {
    final trimmedTitle = title.trim();
    final projectExists = _projects.any((project) => project.id == projectId);
    final subprojectMatches =
        subprojectId == null ||
        _subprojects.any(
          (subproject) =>
              subproject.id == subprojectId &&
              subproject.projectId == projectId,
        );
    if (trimmedTitle.isEmpty || !projectExists || !subprojectMatches) {
      return;
    }

    _tasks.insert(
      0,
      GoalTaskItem(
        id: 'task-${_nextTaskId++}',
        projectId: projectId,
        subprojectId: subprojectId,
        title: trimmedTitle,
        isCompleted: false,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
  }

  Future<bool> updateProjectTitle(String projectId, String title) async {
    final project = _projectById(projectId);
    if (project == null) {
      return false;
    }

    return updateProjectIdentity(
      projectId,
      title: title,
      icon: project.icon,
      description: project.description,
      colorValue: project.colorValue,
    );
  }

  Future<bool> updateGoalIdentity(
    String goalId, {
    required String title,
    String? icon,
    String? description,
    int? colorValue,
  }) async {
    final index = _goals.indexWhere((goal) => goal.id == goalId);
    final trimmedTitle = title.trim();
    if (index == -1 || trimmedTitle.isEmpty) {
      return false;
    }

    _goals[index] = _goals[index].copyWith(
      title: trimmedTitle,
      icon: _normalizeIdentityText(icon, GoalItem.defaultIcon),
      description: description?.trim() ?? '',
      colorValue: _normalizeColorValue(colorValue, GoalItem.defaultColorValue),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateProjectIdentity(
    String projectId, {
    required String title,
    String? icon,
    String? description,
    int? colorValue,
  }) async {
    final index = _projects.indexWhere((project) => project.id == projectId);
    final trimmedTitle = title.trim();
    if (index == -1 || trimmedTitle.isEmpty) {
      return false;
    }

    _projects[index] = _projects[index].copyWith(
      title: trimmedTitle,
      icon: _normalizeIdentityText(icon, ProjectItem.defaultIcon),
      description: description?.trim() ?? '',
      colorValue: _normalizeColorValue(
        colorValue,
        ProjectItem.defaultColorValue,
      ),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateProjectPlanningMeta(
    String projectId, {
    String? dueDate,
    PlanPriority? priority,
    List<String>? tags,
  }) async {
    final index = _projects.indexWhere((project) => project.id == projectId);
    if (index == -1) {
      return false;
    }

    final normalizedDueDate = _normalizeLocalDate(dueDate);
    final current = _projects[index];
    _projects[index] = current.copyWith(
      dueDate: normalizedDueDate,
      clearDueDate: normalizedDueDate == null,
      priority: priority,
      clearPriority: priority == null,
      tags: tags == null ? current.tags : _normalizeTags(tags),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateSubprojectTitle(String subprojectId, String title) async {
    final index = _subprojects.indexWhere(
      (subproject) => subproject.id == subprojectId,
    );
    final trimmedTitle = title.trim();
    if (index == -1 || trimmedTitle.isEmpty) {
      return false;
    }

    _subprojects[index] = _subprojects[index].copyWith(title: trimmedTitle);
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateTaskTitle(String taskId, String title) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    final trimmedTitle = title.trim();
    if (index == -1 || trimmedTitle.isEmpty) {
      return false;
    }

    _tasks[index] = _tasks[index].copyWith(title: trimmedTitle);
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<bool> updateTaskPlanningMeta(
    String taskId, {
    String? dueDate,
    PlanPriority? priority,
    List<String>? tags,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return false;
    }

    final normalizedDueDate = _normalizeLocalDate(dueDate);
    final current = _tasks[index];
    _tasks[index] = current.copyWith(
      dueDate: normalizedDueDate,
      clearDueDate: normalizedDueDate == null,
      priority: priority,
      clearPriority: priority == null,
      tags: tags == null ? current.tags : _normalizeTags(tags),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    final currentTask = _tasks[index];
    _tasks[index] = currentTask.copyWith(isCompleted: !currentTask.isCompleted);
    notifyListeners();

    await _persistSnapshot();
  }

  Future<bool> createProjectNoteRecord(
    String projectId,
    String note, {
    String? localDate,
  }) {
    return _createRecord(
      projectId: projectId,
      type: PlanRecordType.note,
      note: note,
      localDate: localDate,
    );
  }

  Future<bool> createProjectNumericRecord(
    String projectId,
    double value,
    String unit, {
    String? note,
    String? localDate,
  }) {
    return _createRecord(
      projectId: projectId,
      type: PlanRecordType.numeric,
      numericValue: value,
      unit: unit,
      note: note,
      localDate: localDate,
    );
  }

  Future<bool> createTaskNoteRecord(
    String taskId,
    String note, {
    String? localDate,
  }) {
    final task = _taskById(taskId);
    if (task == null) {
      return Future<bool>.value(false);
    }

    return _createRecord(
      projectId: task.projectId,
      subprojectId: task.subprojectId,
      taskId: task.id,
      type: PlanRecordType.note,
      note: note,
      localDate: localDate,
    );
  }

  Future<bool> createTaskNumericRecord(
    String taskId,
    double value,
    String unit, {
    String? note,
    String? localDate,
  }) {
    final task = _taskById(taskId);
    if (task == null) {
      return Future<bool>.value(false);
    }

    return _createRecord(
      projectId: task.projectId,
      subprojectId: task.subprojectId,
      taskId: task.id,
      type: PlanRecordType.numeric,
      numericValue: value,
      unit: unit,
      note: note,
      localDate: localDate,
    );
  }

  Future<bool> createHabitLinkedCompletionRecord({
    required String habitId,
    required String habitName,
    required String projectId,
    String? taskId,
    required String localDate,
    required int effectiveCount,
    required int targetCount,
  }) {
    if (!_isValidLocalDate(localDate)) {
      return Future<bool>.value(false);
    }

    final sourceKey = habitDailyCompletionSourceKey(
      habitId: habitId,
      localDate: localDate,
    );
    if (_records.any((record) => record.sourceKey == sourceKey)) {
      return Future<bool>.value(false);
    }

    final trimmedHabitName = habitName.trim();
    final safeHabitName = trimmedHabitName.isEmpty ? '习惯' : trimmedHabitName;
    final note =
        '来自习惯：$safeHabitName · $localDate 已达标（$effectiveCount/$targetCount）';

    if (taskId != null) {
      final task = _taskById(taskId);
      if (task == null || task.projectId != projectId) {
        return Future<bool>.value(false);
      }

      return _createRecord(
        projectId: task.projectId,
        subprojectId: task.subprojectId,
        taskId: task.id,
        type: PlanRecordType.note,
        note: note,
        localDate: localDate,
        sourceType: habitPlanRecordSourceType,
        sourceId: habitId,
        sourceLocalDate: localDate,
        sourceKey: sourceKey,
      );
    }

    if (_projectById(projectId) == null) {
      return Future<bool>.value(false);
    }

    return _createRecord(
      projectId: projectId,
      type: PlanRecordType.note,
      note: note,
      localDate: localDate,
      sourceType: habitPlanRecordSourceType,
      sourceId: habitId,
      sourceLocalDate: localDate,
      sourceKey: sourceKey,
    );
  }

  List<ProjectItem> getProjectsForGoal(String goalId) {
    return _projects
        .where((project) => project.goalId == goalId)
        .toList(growable: false);
  }

  List<SubprojectItem> getSubprojectsForProject(String projectId) {
    return _subprojects
        .where((subproject) => subproject.projectId == projectId)
        .toList(growable: false);
  }

  List<GoalTaskItem> getTasksForProject(String projectId) {
    return _tasks
        .where((task) => task.projectId == projectId)
        .toList(growable: false);
  }

  List<GoalTaskItem> getDirectTasksForProject(String projectId) {
    return _tasks
        .where(
          (task) => task.projectId == projectId && task.subprojectId == null,
        )
        .toList(growable: false);
  }

  List<GoalTaskItem> getTasksForSubproject(String subprojectId) {
    return _tasks
        .where((task) => task.subprojectId == subprojectId)
        .toList(growable: false);
  }

  List<PlanRecord> recordsForProject(String projectId) {
    return _sortedRecords(
      _records.where((record) => record.projectId == projectId),
    );
  }

  List<PlanRecord> recordsForTask(String taskId) {
    return _sortedRecords(_records.where((record) => record.taskId == taskId));
  }

  PlanRecordAttachment? attachmentForRecord(String recordId) {
    if (!_records.any((record) => record.id == recordId)) {
      return null;
    }

    for (final attachment in _attachments) {
      if (attachment.recordId == recordId) {
        return attachment;
      }
    }

    return null;
  }

  Future<PlanRecordAttachment?> replaceRecordAttachment({
    required String recordId,
    required String relativePath,
    required String fileName,
    String? mimeType,
  }) async {
    final trimmedRelativePath = relativePath.trim();
    final trimmedFileName = fileName.trim();
    final trimmedMimeType = mimeType?.trim();
    if (!_records.any((record) => record.id == recordId) ||
        trimmedRelativePath.isEmpty ||
        trimmedFileName.isEmpty) {
      return null;
    }

    PlanRecordAttachment? replacedAttachment;
    _attachments.removeWhere((attachment) {
      final matches = attachment.recordId == recordId;
      if (matches && replacedAttachment == null) {
        replacedAttachment = attachment;
      }
      return matches;
    });

    _attachments.insert(
      0,
      PlanRecordAttachment(
        id: 'attachment-${_nextAttachmentId++}',
        recordId: recordId,
        relativePath: trimmedRelativePath,
        fileName: trimmedFileName,
        mimeType: trimmedMimeType == null || trimmedMimeType.isEmpty
            ? null
            : trimmedMimeType,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
    return replacedAttachment;
  }

  Future<PlanRecordAttachment?> removeRecordAttachment(String recordId) async {
    PlanRecordAttachment? removedAttachment;
    _attachments.removeWhere((attachment) {
      final matches = attachment.recordId == recordId;
      if (matches && removedAttachment == null) {
        removedAttachment = attachment;
      }
      return matches;
    });

    if (removedAttachment == null) {
      return null;
    }

    notifyListeners();

    await _persistSnapshot();
    return removedAttachment;
  }

  List<PlanRecord> recordsForMonth(String projectId, int year, int month) {
    final monthPrefix =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';

    return _sortedRecords(
      _records.where(
        (record) =>
            record.projectId == projectId &&
            _isValidLocalDate(record.localDate) &&
            record.localDate.startsWith(monthPrefix),
      ),
    );
  }

  ProjectRecordStats computeProjectRecordStats(String projectId) {
    final projectRecords = recordsForProject(projectId);
    final now = _nowProvider().toLocal();
    final currentMonthRecords = recordsForMonth(projectId, now.year, now.month);
    final activeDays = projectRecords
        .where((record) => _isValidLocalDate(record.localDate))
        .map((record) => record.localDate)
        .toSet();
    final projectRecordIds = projectRecords.map((record) => record.id).toSet();
    final attachmentRecordIds = _attachments
        .where((attachment) => projectRecordIds.contains(attachment.recordId))
        .map((attachment) => attachment.recordId)
        .toSet();
    final currentMonthCountsByLocalDate = <String, int>{};
    final totals = <String, double>{};
    var noteRecordCount = 0;

    for (final record in currentMonthRecords) {
      currentMonthCountsByLocalDate[record.localDate] =
          (currentMonthCountsByLocalDate[record.localDate] ?? 0) + 1;
    }

    for (final record in projectRecords) {
      if (record.type == PlanRecordType.note) {
        noteRecordCount += 1;
      }

      final value = record.numericValue;
      if (record.type != PlanRecordType.numeric || value == null) {
        continue;
      }

      final unit = (record.unit ?? '').trim();
      totals[unit] = (totals[unit] ?? 0) + value;
    }

    return ProjectRecordStats(
      recordCount: projectRecords.length,
      noteRecordCount: noteRecordCount,
      activeDaysCount: activeDays.length,
      currentMonthRecordCount: currentMonthRecords.length,
      photoAttachmentCount: attachmentRecordIds.length,
      numericTotalsByUnit: Map<String, double>.unmodifiable(totals),
      currentMonthCountsByLocalDate: Map<String, int>.unmodifiable(
        currentMonthCountsByLocalDate,
      ),
      currentYear: now.year,
      currentMonth: now.month,
      currentLocalDate: _localDateKey(now),
    );
  }

  GoalProgress computeProjectProgress(String projectId) {
    final projectTasks = getTasksForProject(projectId);

    return GoalProgress(
      completedTasks: projectTasks.where((task) => task.isCompleted).length,
      totalTasks: projectTasks.length,
    );
  }

  GoalProgress computeSubprojectProgress(String subprojectId) {
    final subprojectTasks = getTasksForSubproject(subprojectId);

    return GoalProgress(
      completedTasks: subprojectTasks.where((task) => task.isCompleted).length,
      totalTasks: subprojectTasks.length,
    );
  }

  GoalProgress computeGoalProgress(String goalId) {
    final projectIds = getProjectsForGoal(
      goalId,
    ).map((project) => project.id).toSet();
    final goalTasks = _tasks
        .where((task) => projectIds.contains(task.projectId))
        .toList(growable: false);

    return GoalProgress(
      completedTasks: goalTasks.where((task) => task.isCompleted).length,
      totalTasks: goalTasks.length,
    );
  }

  int projectCountForGoal(String goalId) => getProjectsForGoal(goalId).length;

  int taskCountForGoal(String goalId) => getProjectsForGoal(goalId).fold<int>(
    0,
    (count, project) => count + getTasksForProject(project.id).length,
  );

  bool isProjectDueToday(ProjectItem project, {String? todayKey}) {
    final dueDate = project.dueDate;
    if (dueDate == null) {
      return false;
    }

    return dueDate == (todayKey ?? _localDateKey(_nowProvider())) &&
        !computeProjectProgress(project.id).isComplete;
  }

  bool isTaskDueToday(GoalTaskItem task, {String? todayKey}) {
    final dueDate = task.dueDate;
    if (dueDate == null) {
      return false;
    }

    return dueDate == (todayKey ?? _localDateKey(_nowProvider())) &&
        !task.isCompleted;
  }

  bool isProjectOverdue(ProjectItem project, {String? todayKey}) {
    final dueDate = project.dueDate;
    if (dueDate == null) {
      return false;
    }

    return dueDate.compareTo(todayKey ?? _localDateKey(_nowProvider())) < 0 &&
        !computeProjectProgress(project.id).isComplete;
  }

  bool isTaskOverdue(GoalTaskItem task, {String? todayKey}) {
    final dueDate = task.dueDate;
    if (dueDate == null) {
      return false;
    }

    return dueDate.compareTo(todayKey ?? _localDateKey(_nowProvider())) < 0 &&
        !task.isCompleted;
  }

  LegacyGoalState? legacyStateForGoal(String goalId) {
    for (final state in _legacyGoalStates) {
      if (state.goalId == goalId) {
        return state;
      }
    }

    return null;
  }

  Future<void> _persistSnapshot() async {
    final snapshot = GoalsSnapshot(
      goals: List<GoalItem>.of(_goals),
      projects: List<ProjectItem>.of(_projects),
      subprojects: List<SubprojectItem>.of(_subprojects),
      tasks: List<GoalTaskItem>.of(_tasks),
      records: List<PlanRecord>.of(_records),
      attachments: List<PlanRecordAttachment>.of(_attachments),
      legacyGoalStates: List<LegacyGoalState>.of(_legacyGoalStates),
    );

    try {
      await _storage.saveSnapshot(snapshot);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'goals_store',
          context: ErrorDescription('while persisting goals locally'),
        ),
      );
    }
  }

  static int _deriveNextId<T>(List<T> items, String prefix) {
    final matcher = RegExp('^$prefix-(\\d+)\$');

    final maxId = items.fold<int>(0, (currentMax, item) {
      final id = switch (item) {
        GoalItem() => item.id,
        ProjectItem() => item.id,
        SubprojectItem() => item.id,
        GoalTaskItem() => item.id,
        PlanRecord() => item.id,
        PlanRecordAttachment() => item.id,
        _ => '',
      };
      final match = matcher.firstMatch(id);
      final parsedId = int.tryParse(match?.group(1) ?? '');

      if (parsedId == null || parsedId <= currentMax) {
        return currentMax;
      }

      return parsedId;
    });

    return maxId + 1;
  }

  Future<bool> _createRecord({
    required String projectId,
    String? subprojectId,
    String? taskId,
    required PlanRecordType type,
    String? note,
    double? numericValue,
    String? unit,
    String? localDate,
    String? sourceType,
    String? sourceId,
    String? sourceLocalDate,
    String? sourceKey,
  }) async {
    if (!_projects.any((project) => project.id == projectId)) {
      return false;
    }
    if (subprojectId != null &&
        !_subprojects.any(
          (subproject) =>
              subproject.id == subprojectId &&
              subproject.projectId == projectId,
        )) {
      return false;
    }
    if (taskId != null &&
        !_tasks.any(
          (task) =>
              task.id == taskId &&
              task.projectId == projectId &&
              task.subprojectId == subprojectId,
        )) {
      return false;
    }

    final trimmedNote = note?.trim();
    final trimmedUnit = unit?.trim();
    final resolvedLocalDate = localDate ?? _localDateKey(_nowProvider());
    if (!_isValidLocalDate(resolvedLocalDate)) {
      return false;
    }

    if (type == PlanRecordType.note &&
        (trimmedNote == null || trimmedNote.isEmpty)) {
      return false;
    }
    if (type == PlanRecordType.numeric &&
        (numericValue == null || !numericValue.isFinite)) {
      return false;
    }

    _records.insert(
      0,
      PlanRecord(
        id: 'record-${_nextRecordId++}',
        projectId: projectId,
        subprojectId: subprojectId,
        taskId: taskId,
        type: type,
        localDate: resolvedLocalDate,
        note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
        numericValue: type == PlanRecordType.numeric ? numericValue : null,
        unit: trimmedUnit == null || trimmedUnit.isEmpty ? null : trimmedUnit,
        sourceType: sourceType,
        sourceId: sourceId,
        sourceLocalDate: sourceLocalDate,
        sourceKey: sourceKey,
        createdAt: _nowProvider().toUtc(),
      ),
    );
    notifyListeners();

    await _persistSnapshot();
    return true;
  }

  GoalTaskItem? _taskById(String taskId) {
    for (final task in _tasks) {
      if (task.id == taskId) {
        return task;
      }
    }

    return null;
  }

  ProjectItem? _projectById(String projectId) {
    for (final project in _projects) {
      if (project.id == projectId) {
        return project;
      }
    }

    return null;
  }

  String _normalizeIdentityText(String? value, String fallback) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? fallback : trimmed;
  }

  int _normalizeColorValue(int? value, int fallback) {
    if (value == null || value < 0 || value > 0xFFFFFFFF) {
      return fallback;
    }

    return value;
  }

  String? _normalizeLocalDate(String? value) {
    final trimmed = value?.trim() ?? '';
    return _isValidLocalDate(trimmed) ? trimmed : null;
  }

  List<String> _normalizeTags(List<String> tags) {
    final normalized = <String>[];
    for (final tag in tags) {
      final trimmed = tag.trim();
      if (trimmed.isEmpty || normalized.contains(trimmed)) {
        continue;
      }

      normalized.add(trimmed.length > 16 ? trimmed.substring(0, 16) : trimmed);
      if (normalized.length >= 8) {
        break;
      }
    }

    return List<String>.unmodifiable(normalized);
  }

  List<PlanRecord> _sortedRecords(Iterable<PlanRecord> records) {
    final sorted = records.toList(growable: false);
    sorted.sort((a, b) {
      final localDateCompare = b.localDate.compareTo(a.localDate);
      if (localDateCompare != 0) {
        return localDateCompare;
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    return sorted;
  }

  String _localDateKey(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  bool _isValidLocalDate(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
  }
}

class _InMemoryGoalsStorage implements GoalsStorage {
  @override
  Future<GoalsSnapshot> loadSnapshot({
    required DateTime migrationCreatedAt,
  }) async {
    return GoalsSnapshot.empty();
  }

  @override
  Future<void> saveSnapshot(GoalsSnapshot snapshot) async {}
}
