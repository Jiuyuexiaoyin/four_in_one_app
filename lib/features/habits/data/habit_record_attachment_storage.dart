import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class HabitRecordAttachmentStorage {
  Future<List<StoredHabitRecordImage>> pickAndStoreImages(
    String recordId, {
    required int limit,
  });

  Future<StoredHabitRecordImage?> captureAndStoreImage(String recordId);

  Future<List<StoredHabitRecordImage>> retrieveLostImages(
    String recordId, {
    required int limit,
  });

  Future<File?> resolveImage(String relativePath);

  Future<void> removeImage(String relativePath);
}

class StoredHabitRecordImage {
  const StoredHabitRecordImage({
    required this.relativePath,
    required this.fileName,
    this.mimeType,
  });

  final String relativePath;
  final String fileName;
  final String? mimeType;
}

class LocalHabitRecordAttachmentStorage
    implements HabitRecordAttachmentStorage {
  const LocalHabitRecordAttachmentStorage({
    HabitRecordImagePicker? picker,
    HabitRecordAttachmentDirectoryProvider? directoryProvider,
    HabitRecordAttachmentFileSystem? fileSystem,
  }) : _picker = picker,
       _directoryProvider = directoryProvider,
       _fileSystem = fileSystem;

  static const attachmentDirectoryName = 'habit_record_images';

  final HabitRecordImagePicker? _picker;
  final HabitRecordAttachmentDirectoryProvider? _directoryProvider;
  final HabitRecordAttachmentFileSystem? _fileSystem;

  @override
  Future<List<StoredHabitRecordImage>> pickAndStoreImages(
    String recordId, {
    required int limit,
  }) async {
    final trimmedRecordId = recordId.trim();
    if (trimmedRecordId.isEmpty || limit <= 0) {
      return const <StoredHabitRecordImage>[];
    }

    try {
      final picker = _picker ?? const ImagePickerHabitRecordImagePicker();
      final pickedImages = await picker.pickImages(limit: limit);
      return _storePickedImages(
        recordId: trimmedRecordId,
        images: pickedImages,
        limit: limit,
        errorContext: 'while storing selected habit record images',
      );
    } catch (error, stackTrace) {
      _reportStorageError(
        error,
        stackTrace,
        'while storing selected habit record images',
      );
      return const <StoredHabitRecordImage>[];
    }
  }

  @override
  Future<StoredHabitRecordImage?> captureAndStoreImage(String recordId) async {
    final trimmedRecordId = recordId.trim();
    if (trimmedRecordId.isEmpty) {
      return null;
    }

    try {
      final picker = _picker ?? const ImagePickerHabitRecordImagePicker();
      final picked = await picker.captureImage();
      if (picked == null) {
        return null;
      }

      final storedImages = await _storePickedImages(
        recordId: trimmedRecordId,
        images: [picked],
        limit: 1,
        errorContext: 'while storing captured habit record image',
      );
      return storedImages.isEmpty ? null : storedImages.first;
    } catch (error, stackTrace) {
      _reportStorageError(
        error,
        stackTrace,
        'while storing captured habit record image',
      );
      return null;
    }
  }

  @override
  Future<List<StoredHabitRecordImage>> retrieveLostImages(
    String recordId, {
    required int limit,
  }) async {
    final trimmedRecordId = recordId.trim();
    if (trimmedRecordId.isEmpty || limit <= 0) {
      return const <StoredHabitRecordImage>[];
    }

    try {
      final picker = _picker ?? const ImagePickerHabitRecordImagePicker();
      final pickedImages = await picker.retrieveLostImages();
      return _storePickedImages(
        recordId: trimmedRecordId,
        images: pickedImages,
        limit: limit,
        errorContext: 'while recovering lost habit record images',
      );
    } catch (error, stackTrace) {
      _reportStorageError(
        error,
        stackTrace,
        'while recovering lost habit record images',
      );
      return const <StoredHabitRecordImage>[];
    }
  }

  @override
  Future<File?> resolveImage(String relativePath) async {
    final safeRelativePath = _safeRelativePath(relativePath);
    if (safeRelativePath == null) {
      return null;
    }

    try {
      final fileSystem =
          _fileSystem ?? const DartHabitRecordAttachmentFileSystem();
      final directoryProvider =
          _directoryProvider ??
          const AppDocumentsHabitRecordAttachmentDirectoryProvider();
      final documentsDirectory = await directoryProvider.documentsDirectory();
      final file = File(_joinPath(documentsDirectory.path, safeRelativePath));

      if (!await fileSystem.fileExists(file.path)) {
        return null;
      }

      return file;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> removeImage(String relativePath) async {
    final safeRelativePath = _safeRelativePath(relativePath);
    if (safeRelativePath == null) {
      return;
    }

    try {
      final fileSystem =
          _fileSystem ?? const DartHabitRecordAttachmentFileSystem();
      final directoryProvider =
          _directoryProvider ??
          const AppDocumentsHabitRecordAttachmentDirectoryProvider();
      final documentsDirectory = await directoryProvider.documentsDirectory();
      await fileSystem.deleteFileIfExists(
        _joinPath(documentsDirectory.path, safeRelativePath),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habit_record_attachment_storage',
          context: ErrorDescription('while removing a habit record image'),
        ),
      );
    }
  }

  Future<List<StoredHabitRecordImage>> _storePickedImages({
    required String recordId,
    required Iterable<HabitPickedImage> images,
    required int limit,
    required String errorContext,
  }) async {
    if (limit <= 0) {
      return const <StoredHabitRecordImage>[];
    }

    final pickedImages = images.take(limit).toList(growable: false);
    if (pickedImages.isEmpty) {
      return const <StoredHabitRecordImage>[];
    }

    final fileSystem =
        _fileSystem ?? const DartHabitRecordAttachmentFileSystem();
    final directoryProvider =
        _directoryProvider ??
        const AppDocumentsHabitRecordAttachmentDirectoryProvider();
    final directory = await directoryProvider.attachmentDirectory();
    await fileSystem.ensureDirectory(directory);

    final storedImages = <StoredHabitRecordImage>[];
    for (var index = 0; index < pickedImages.length; index += 1) {
      final picked = pickedImages[index];
      try {
        final fileName = _buildFileName(recordId, picked, index);
        final copiedFile = await fileSystem.copyFile(
          picked.path,
          _joinPath(directory.path, fileName),
        );

        storedImages.add(
          StoredHabitRecordImage(
            relativePath: '$attachmentDirectoryName/$fileName',
            fileName: fileName,
            mimeType: picked.mimeType ?? _mimeTypeFromFileName(copiedFile.path),
          ),
        );
      } catch (error, stackTrace) {
        _reportStorageError(error, stackTrace, errorContext);
      }
    }

    return storedImages;
  }

  String _buildFileName(
    String recordId,
    HabitPickedImage picked,
    int sequence,
  ) {
    final safeRecordId = recordId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final extension =
        _safeExtension(picked.fileName) ??
        _safeExtension(picked.path) ??
        '.jpg';

    return '${safeRecordId}_${timestamp}_$sequence$extension';
  }

  String? _safeExtension(String value) {
    final dotIndex = value.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == value.length - 1) {
      return null;
    }

    final extension = value.substring(dotIndex).toLowerCase();
    if (!RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)) {
      return null;
    }

    return extension;
  }

  String? _safeRelativePath(String value) {
    final normalized = value.trim().replaceAll('\\', '/');
    if (normalized.isEmpty ||
        normalized.startsWith('/') ||
        normalized.contains('..') ||
        RegExp(r'^[A-Za-z]:').hasMatch(normalized)) {
      return null;
    }

    return normalized;
  }

  String? _mimeTypeFromFileName(String fileName) {
    final extension = _safeExtension(fileName);
    return switch (extension) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      _ => null,
    };
  }

  String _joinPath(String first, String second) {
    final separator = Platform.pathSeparator;
    return first.endsWith(separator)
        ? '$first$second'
        : '$first$separator$second';
  }

  void _reportStorageError(
    Object error,
    StackTrace stackTrace,
    String context,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'habit_record_attachment_storage',
        context: ErrorDescription(context),
      ),
    );
  }
}

abstract interface class HabitRecordImagePicker {
  Future<List<HabitPickedImage>> pickImages({required int limit});

  Future<HabitPickedImage?> captureImage();

  Future<List<HabitPickedImage>> retrieveLostImages();
}

class HabitPickedImage {
  const HabitPickedImage({
    required this.path,
    required this.fileName,
    this.mimeType,
  });

  final String path;
  final String fileName;
  final String? mimeType;
}

class ImagePickerHabitRecordImagePicker implements HabitRecordImagePicker {
  const ImagePickerHabitRecordImagePicker();

  @override
  Future<List<HabitPickedImage>> pickImages({required int limit}) async {
    if (limit <= 0) {
      return const <HabitPickedImage>[];
    }

    final images = await ImagePicker().pickMultiImage(limit: limit);
    return images.map(_fromXFile).toList(growable: false);
  }

  @override
  Future<HabitPickedImage?> captureImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }

    return _fromXFile(image);
  }

  @override
  Future<List<HabitPickedImage>> retrieveLostImages() async {
    final response = await ImagePicker().retrieveLostData();
    if (response.isEmpty) {
      return const <HabitPickedImage>[];
    }

    if (response.exception != null) {
      throw response.exception!;
    }

    final images =
        response.files ?? [if (response.file != null) response.file!];
    return images.map(_fromXFile).toList(growable: false);
  }

  HabitPickedImage _fromXFile(XFile image) {
    return HabitPickedImage(
      path: image.path,
      fileName: image.name,
      mimeType: image.mimeType,
    );
  }
}

abstract interface class HabitRecordAttachmentDirectoryProvider {
  Future<Directory> documentsDirectory();

  Future<Directory> attachmentDirectory();
}

class AppDocumentsHabitRecordAttachmentDirectoryProvider
    implements HabitRecordAttachmentDirectoryProvider {
  const AppDocumentsHabitRecordAttachmentDirectoryProvider();

  @override
  Future<Directory> documentsDirectory() {
    return getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> attachmentDirectory() async {
    final documents = await documentsDirectory();
    return Directory(
      _joinPath(
        documents.path,
        LocalHabitRecordAttachmentStorage.attachmentDirectoryName,
      ),
    );
  }

  String _joinPath(String first, String second) {
    final separator = Platform.pathSeparator;
    return first.endsWith(separator)
        ? '$first$second'
        : '$first$separator$second';
  }
}

abstract interface class HabitRecordAttachmentFileSystem {
  Future<void> ensureDirectory(Directory directory);

  Future<File> copyFile(String sourcePath, String targetPath);

  Future<bool> fileExists(String path);

  Future<void> deleteFileIfExists(String path);
}

class DartHabitRecordAttachmentFileSystem
    implements HabitRecordAttachmentFileSystem {
  const DartHabitRecordAttachmentFileSystem();

  @override
  Future<void> ensureDirectory(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<File> copyFile(String sourcePath, String targetPath) {
    return File(sourcePath).copy(targetPath);
  }

  @override
  Future<bool> fileExists(String path) {
    return File(path).exists();
  }

  @override
  Future<void> deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
