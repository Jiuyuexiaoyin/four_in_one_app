import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/goals/data/plan_record_attachment_storage.dart';

void main() {
  test('fake picker stores image under plan_record_images', () async {
    final fileSystem = _FakeAttachmentFileSystem();
    final storage = LocalPlanRecordAttachmentStorage(
      picker: _FakeImagePicker(
        const PlanPickedImage(
          path: r'D:\picker-temp\selected-proof.png',
          fileName: 'proof.png',
          mimeType: 'image/png',
        ),
      ),
      directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
      fileSystem: fileSystem,
    );

    final stored = await storage.pickAndStoreImage('record-1');

    expect(stored, isNotNull);
    expect(stored!.relativePath, startsWith('plan_record_images/record-1_'));
    expect(stored.relativePath, endsWith('.png'));
    expect(stored.fileName, startsWith('record-1_'));
    expect(stored.fileName, endsWith('.png'));
    expect(stored.mimeType, 'image/png');
    expect(
      fileSystem.ensuredDirectories.single.path,
      contains('plan_record_images'),
    );
    expect(
      fileSystem.copiedSources.single,
      r'D:\picker-temp\selected-proof.png',
    );
    expect(fileSystem.copiedTargets.single, contains('plan_record_images'));
  });

  test(
    'missing local image resolves to null without platform channels',
    () async {
      final storage = LocalPlanRecordAttachmentStorage(
        picker: _FakeImagePicker(null),
        directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
        fileSystem: _FakeAttachmentFileSystem(),
      );

      expect(
        await storage.resolveImage('plan_record_images/missing.png'),
        isNull,
      );
      expect(await storage.resolveImage('../escape.png'), isNull);
      expect(await storage.resolveImage(r'C:\escape.png'), isNull);
    },
  );

  test(
    'remove image attempts best effort delete through fake file system',
    () async {
      final fileSystem = _FakeAttachmentFileSystem(
        existingFiles: {r'D:\app-documents\plan_record_images\old-proof.png'},
      );
      final storage = LocalPlanRecordAttachmentStorage(
        picker: _FakeImagePicker(null),
        directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
        fileSystem: fileSystem,
      );

      await storage.removeImage('plan_record_images/old-proof.png');
      await storage.removeImage('../unsafe.png');

      expect(fileSystem.deletedPaths, hasLength(1));
      expect(
        fileSystem.deletedPaths.single.replaceAll('\\', '/'),
        'D:/app-documents/plan_record_images/old-proof.png',
      );
    },
  );
}

class _FakeImagePicker implements PlanRecordImagePicker {
  const _FakeImagePicker(this.image);

  final PlanPickedImage? image;

  @override
  Future<PlanPickedImage?> pickImage() async => image;
}

class _FakeDirectoryProvider implements PlanRecordAttachmentDirectoryProvider {
  const _FakeDirectoryProvider(this.documentsPath);

  final String documentsPath;

  @override
  Future<Directory> attachmentDirectory() async {
    return Directory(
      '$documentsPath${Platform.pathSeparator}'
      '${LocalPlanRecordAttachmentStorage.attachmentDirectoryName}',
    );
  }

  @override
  Future<Directory> documentsDirectory() async => Directory(documentsPath);
}

class _FakeAttachmentFileSystem implements PlanRecordAttachmentFileSystem {
  _FakeAttachmentFileSystem({Set<String>? existingFiles})
    : existingFiles = existingFiles ?? <String>{};

  final Set<String> existingFiles;
  final List<Directory> ensuredDirectories = <Directory>[];
  final List<String> copiedSources = <String>[];
  final List<String> copiedTargets = <String>[];
  final List<String> deletedPaths = <String>[];

  @override
  Future<File> copyFile(String sourcePath, String targetPath) async {
    copiedSources.add(sourcePath);
    copiedTargets.add(targetPath);
    existingFiles.add(targetPath);
    return File(targetPath);
  }

  @override
  Future<void> deleteFileIfExists(String path) async {
    existingFiles.remove(path);
    deletedPaths.add(path);
  }

  @override
  Future<void> ensureDirectory(Directory directory) async {
    ensuredDirectories.add(directory);
  }

  @override
  Future<bool> fileExists(String path) async => existingFiles.contains(path);
}
