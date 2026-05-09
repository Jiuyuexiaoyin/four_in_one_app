import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:four_in_one_app/features/habits/data/habit_record_attachment_storage.dart';

void main() {
  test('fake picker stores gallery images under habit_record_images', () async {
    final fileSystem = _FakeAttachmentFileSystem();
    final storage = LocalHabitRecordAttachmentStorage(
      picker: _FakeImagePicker(
        galleryImages: const [
          HabitPickedImage(
            path: r'D:\picker-temp\habit-proof-a.png',
            fileName: 'habit-proof-a.png',
            mimeType: 'image/png',
          ),
          HabitPickedImage(
            path: r'D:\picker-temp\habit-proof-b.jpg',
            fileName: 'habit-proof-b.jpg',
            mimeType: 'image/jpeg',
          ),
          HabitPickedImage(
            path: r'D:\picker-temp\habit-proof-extra.webp',
            fileName: 'habit-proof-extra.webp',
            mimeType: 'image/webp',
          ),
        ],
      ),
      directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
      fileSystem: fileSystem,
    );

    final stored = await storage.pickAndStoreImages('habit-record-1', limit: 2);

    expect(stored, hasLength(2));
    expect(stored.first.relativePath, startsWith('habit_record_images/'));
    expect(stored.first.relativePath, endsWith('.png'));
    expect(stored.first.fileName, startsWith('habit-record-1_'));
    expect(stored.first.mimeType, 'image/png');
    expect(stored.last.relativePath, endsWith('.jpg'));
    expect(stored.last.mimeType, 'image/jpeg');
    expect(
      fileSystem.ensuredDirectories.single.path,
      contains('habit_record_images'),
    );
    expect(fileSystem.copiedSources, [
      r'D:\picker-temp\habit-proof-a.png',
      r'D:\picker-temp\habit-proof-b.jpg',
    ]);
    expect(
      fileSystem.copiedTargets,
      everyElement(contains('habit_record_images')),
    );
  });

  test('camera image stores through the same app-managed directory', () async {
    final fileSystem = _FakeAttachmentFileSystem();
    final storage = LocalHabitRecordAttachmentStorage(
      picker: _FakeImagePicker(
        cameraImage: const HabitPickedImage(
          path: r'D:\camera-temp\habit-camera-proof.jpg',
          fileName: 'habit-camera-proof.jpg',
          mimeType: 'image/jpeg',
        ),
      ),
      directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
      fileSystem: fileSystem,
    );

    final stored = await storage.captureAndStoreImage('habit-record-1');

    expect(stored, isNotNull);
    expect(stored!.relativePath, startsWith('habit_record_images/'));
    expect(stored.relativePath, endsWith('.jpg'));
    expect(stored.mimeType, 'image/jpeg');
    expect(
      fileSystem.copiedSources.single,
      r'D:\camera-temp\habit-camera-proof.jpg',
    );
    expect(fileSystem.copiedTargets.single, contains('habit_record_images'));
  });

  test('lost picker data can be recovered without platform channels', () async {
    final fileSystem = _FakeAttachmentFileSystem();
    final storage = LocalHabitRecordAttachmentStorage(
      picker: _FakeImagePicker(
        lostImages: const [
          HabitPickedImage(
            path: r'D:\lost-temp\habit-lost-proof.png',
            fileName: 'habit-lost-proof.png',
            mimeType: 'image/png',
          ),
        ],
      ),
      directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
      fileSystem: fileSystem,
    );

    final stored = await storage.retrieveLostImages('habit-record-1', limit: 3);

    expect(stored, hasLength(1));
    expect(stored.single.relativePath, startsWith('habit_record_images/'));
    expect(stored.single.fileName, endsWith('.png'));
    expect(
      fileSystem.copiedSources.single,
      r'D:\lost-temp\habit-lost-proof.png',
    );
  });

  test(
    'missing local image resolves to null without platform channels',
    () async {
      final storage = LocalHabitRecordAttachmentStorage(
        picker: const _FakeImagePicker(),
        directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
        fileSystem: _FakeAttachmentFileSystem(),
      );

      expect(
        await storage.resolveImage('habit_record_images/missing.png'),
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
        existingFiles: {r'D:\app-documents\habit_record_images\old-proof.png'},
      );
      final storage = LocalHabitRecordAttachmentStorage(
        picker: const _FakeImagePicker(),
        directoryProvider: _FakeDirectoryProvider(r'D:\app-documents'),
        fileSystem: fileSystem,
      );

      await storage.removeImage('habit_record_images/old-proof.png');
      await storage.removeImage('../unsafe.png');

      expect(fileSystem.deletedPaths, hasLength(1));
      expect(
        fileSystem.deletedPaths.single.replaceAll('\\', '/'),
        'D:/app-documents/habit_record_images/old-proof.png',
      );
    },
  );
}

class _FakeImagePicker implements HabitRecordImagePicker {
  const _FakeImagePicker({
    this.galleryImages = const <HabitPickedImage>[],
    this.cameraImage,
    this.lostImages = const <HabitPickedImage>[],
  });

  final List<HabitPickedImage> galleryImages;
  final HabitPickedImage? cameraImage;
  final List<HabitPickedImage> lostImages;

  @override
  Future<List<HabitPickedImage>> pickImages({required int limit}) async =>
      galleryImages;

  @override
  Future<HabitPickedImage?> captureImage() async => cameraImage;

  @override
  Future<List<HabitPickedImage>> retrieveLostImages() async => lostImages;
}

class _FakeDirectoryProvider implements HabitRecordAttachmentDirectoryProvider {
  const _FakeDirectoryProvider(this.documentsPath);

  final String documentsPath;

  @override
  Future<Directory> attachmentDirectory() async {
    return Directory(
      '$documentsPath${Platform.pathSeparator}'
      '${LocalHabitRecordAttachmentStorage.attachmentDirectoryName}',
    );
  }

  @override
  Future<Directory> documentsDirectory() async => Directory(documentsPath);
}

class _FakeAttachmentFileSystem implements HabitRecordAttachmentFileSystem {
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
