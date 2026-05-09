import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/goals/application/goals_store.dart';
import 'package:four_in_one_app/features/goals/data/plan_record_attachment_storage.dart';
import 'package:four_in_one_app/features/goals/domain/models/goal_item.dart';
import 'package:four_in_one_app/features/goals/presentation/goals_scope.dart';
import 'package:four_in_one_app/features/goals/presentation/pages/goals_page.dart';

void main() {
  testWidgets('record attachment sheet adds image metadata with fake storage', (
    tester,
  ) async {
    final store = _storeWithRecord();
    addTearDown(store.dispose);
    final attachmentStorage = _FakeAttachmentStorage(
      picks: [
        const StoredPlanRecordImage(
          relativePath: 'plan_record_images/proof-a.png',
          fileName: 'proof-a.png',
          mimeType: 'image/png',
        ),
      ],
    );

    await _pumpGoalsPage(tester, store, attachmentStorage);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('project-record-attach-record-1')),
      300,
    );
    await tester.tap(
      find.byKey(const ValueKey('project-record-attach-record-1')),
    );
    await _pumpStableFrame(tester);
    await tester.tap(find.byKey(const ValueKey('record-image-pick-record-1')));
    await _pumpStableFrame(tester);

    expect(attachmentStorage.pickedRecordIds, ['record-1']);
    expect(store.attachments.length, 1);
    expect(store.attachments.single.recordId, 'record-1');
    expect(
      store.attachments.single.relativePath,
      'plan_record_images/proof-a.png',
    );
    expect(store.attachments.single.fileName, 'proof-a.png');
    expect(store.attachments.single.mimeType, 'image/png');
    expect(store.records.single.note, 'Progress note');
  });

  testWidgets(
    'missing image state is safe and replace/remove delete old files',
    (tester) async {
      final store = _storeWithRecord(
        attachments: [
          PlanRecordAttachment(
            id: 'attachment-1',
            recordId: 'record-1',
            relativePath: 'plan_record_images/proof-a.png',
            fileName: 'proof-a.png',
            mimeType: 'image/png',
            createdAt: DateTime.utc(2026, 4, 25, 8, 30),
          ),
        ],
      );
      addTearDown(store.dispose);
      final attachmentStorage = _FakeAttachmentStorage(
        picks: [
          const StoredPlanRecordImage(
            relativePath: 'plan_record_images/proof-b.jpg',
            fileName: 'proof-b.jpg',
            mimeType: 'image/jpeg',
          ),
        ],
      );

      await _pumpGoalsPage(tester, store, attachmentStorage);

      await _pumpStableFrame(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('project-record-missing-image-record-1')),
        300,
      );
      await tester.tap(
        find.byKey(const ValueKey('project-record-missing-image-record-1')),
      );
      await _pumpStableFrame(tester);

      expect(find.text('图片文件已不在本地，记录仍然保留。'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('record-image-pick-record-1')),
      );
      await _pumpStableFrame(tester);

      expect(
        store.attachments.single.relativePath,
        'plan_record_images/proof-b.jpg',
      );
      expect(attachmentStorage.removedPaths, [
        'plan_record_images/proof-a.png',
      ]);

      await tester.tap(
        find.byKey(const ValueKey('record-image-remove-record-1')),
      );
      await _pumpStableFrame(tester);

      expect(store.attachments, isEmpty);
      expect(store.records.single.id, 'record-1');
      expect(attachmentStorage.removedPaths, [
        'plan_record_images/proof-a.png',
        'plan_record_images/proof-b.jpg',
      ]);
    },
  );

  testWidgets('project statistics sheet shows photo count and missing image', (
    tester,
  ) async {
    final store = _storeWithRecord(
      attachments: [
        PlanRecordAttachment(
          id: 'attachment-1',
          recordId: 'record-1',
          relativePath: 'plan_record_images/proof-a.png',
          fileName: 'proof-a.png',
          mimeType: 'image/png',
          createdAt: DateTime.utc(2026, 4, 25, 8, 30),
        ),
      ],
    );
    addTearDown(store.dispose);
    final attachmentStorage = _FakeAttachmentStorage();

    await _pumpGoalsPage(tester, store, attachmentStorage);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('project-record-open-stats-project-1')),
      300,
    );
    await tester.tap(
      find.byKey(const ValueKey('project-record-open-stats-project-1')),
    );
    await _pumpStableFrame(tester);

    expect(
      find.byKey(const ValueKey('project-stats-sheet-project-1')),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-stats-record-count-project-1', '1'),
      findsOneWidget,
    );
    expect(
      _findKeyedText('project-stats-photo-count-project-1', '1'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-stats-heatmap-project-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-stats-record-missing-image-record-1')),
      findsOneWidget,
    );

    final imageFilter = find.byKey(
      const ValueKey('project-stats-filter-image-project-1'),
    );
    await tester.ensureVisible(imageFilter);
    await _pumpStableFrame(tester);
    await tester.tap(imageFilter);
    await _pumpStableFrame(tester);

    expect(
      find.byKey(const ValueKey('project-stats-record-missing-image-record-1')),
      findsOneWidget,
    );
  });
}

Future<void> _pumpGoalsPage(
  WidgetTester tester,
  GoalsStore store,
  PlanRecordAttachmentStorage attachmentStorage,
) {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: GoalsScope(
        notifier: store,
        child: Scaffold(body: GoalsPage(attachmentStorage: attachmentStorage)),
      ),
    ),
  );
}

Future<void> _pumpStableFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

GoalsStore _storeWithRecord({
  List<PlanRecordAttachment> attachments = const <PlanRecordAttachment>[],
}) {
  return GoalsStore.inMemory(
    initialGoals: [
      GoalItem(
        id: 'goal-1',
        title: 'Goal',
        createdAt: DateTime.utc(2026, 4, 25, 8),
      ),
    ],
    initialProjects: [
      ProjectItem(
        id: 'project-1',
        goalId: 'goal-1',
        title: 'Project',
        createdAt: DateTime.utc(2026, 4, 25, 8, 10),
      ),
    ],
    initialRecords: [
      PlanRecord(
        id: 'record-1',
        projectId: 'project-1',
        type: PlanRecordType.note,
        localDate: '2026-04-25',
        note: 'Progress note',
        createdAt: DateTime.utc(2026, 4, 25, 8, 20),
      ),
    ],
    initialAttachments: attachments,
    nowProvider: () => DateTime.utc(2026, 4, 25, 9),
  );
}

class _FakeAttachmentStorage implements PlanRecordAttachmentStorage {
  _FakeAttachmentStorage({
    List<StoredPlanRecordImage?> picks = const <StoredPlanRecordImage?>[],
    Map<String, File> resolvedImages = const <String, File>{},
  }) : _picks = List<StoredPlanRecordImage?>.of(picks),
       _resolvedImages = resolvedImages;

  final List<StoredPlanRecordImage?> _picks;
  final Map<String, File> _resolvedImages;
  final List<String> pickedRecordIds = <String>[];
  final List<String> removedPaths = <String>[];

  @override
  Future<StoredPlanRecordImage?> pickAndStoreImage(String recordId) async {
    pickedRecordIds.add(recordId);
    if (_picks.isEmpty) {
      return null;
    }

    return _picks.removeAt(0);
  }

  @override
  Future<void> removeImage(String relativePath) async {
    removedPaths.add(relativePath);
  }

  @override
  Future<File?> resolveImage(String relativePath) async {
    return _resolvedImages[relativePath];
  }
}

Finder _findKeyedText(String key, String text) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.key == ValueKey<String>(key) &&
        widget.data == text,
  );
}
