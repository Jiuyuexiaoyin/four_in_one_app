import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class PlanRecordAttachmentStorage {
  Future<StoredPlanRecordImage?> pickAndStoreImage(String recordId);

  Future<File?> resolveImage(String relativePath);

  Future<void> removeImage(String relativePath);
}

class StoredPlanRecordImage {
  const StoredPlanRecordImage({
    required this.relativePath,
    required this.fileName,
    this.mimeType,
  });

  final String relativePath;
  final String fileName;
  final String? mimeType;
}

class LocalPlanRecordAttachmentStorage implements PlanRecordAttachmentStorage {
  const LocalPlanRecordAttachmentStorage({
    PlanRecordImagePicker? picker,
    PlanRecordAttachmentDirectoryProvider? directoryProvider,
    PlanRecordAttachmentFileSystem? fileSystem,
  }) : _picker = picker,
       _directoryProvider = directoryProvider,
       _fileSystem = fileSystem;

  static const attachmentDirectoryName = 'plan_record_images';

  final PlanRecordImagePicker? _picker;
  final PlanRecordAttachmentDirectoryProvider? _directoryProvider;
  final PlanRecordAttachmentFileSystem? _fileSystem;

  @override
  Future<StoredPlanRecordImage?> pickAndStoreImage(String recordId) async {
    final trimmedRecordId = recordId.trim();
    if (trimmedRecordId.isEmpty) {
      return null;
    }

    try {
      final picker = _picker ?? const ImagePickerPlanRecordImagePicker();
      final picked = await picker.pickImage();
      if (picked == null) {
        return null;
      }

      final fileSystem = _fileSystem ?? const DartPlanRecordAttachmentFileSystem();
      final directoryProvider =
          _directoryProvider ??
          const AppDocumentsPlanRecordAttachmentDirectoryProvider();
      final directory = await directoryProvider.attachmentDirectory();
      await fileSystem.ensureDirectory(directory);

      final fileName = _buildFileName(trimmedRecordId, picked);
      final copiedFile = await fileSystem.copyFile(
        picked.path,
        _joinPath(directory.path, fileName),
      );

      return StoredPlanRecordImage(
        relativePath: '$attachmentDirectoryName/$fileName',
        fileName: fileName,
        mimeType: picked.mimeType ?? _mimeTypeFromFileName(copiedFile.path),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'plan_record_attachment_storage',
          context: ErrorDescription('while storing a plan record image'),
        ),
      );
      return null;
    }
  }

  @override
  Future<File?> resolveImage(String relativePath) async {
    final safeRelativePath = _safeRelativePath(relativePath);
    if (safeRelativePath == null) {
      return null;
    }

    try {
      final fileSystem = _fileSystem ?? const DartPlanRecordAttachmentFileSystem();
      final directoryProvider =
          _directoryProvider ??
          const AppDocumentsPlanRecordAttachmentDirectoryProvider();
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
      final fileSystem = _fileSystem ?? const DartPlanRecordAttachmentFileSystem();
      final directoryProvider =
          _directoryProvider ??
          const AppDocumentsPlanRecordAttachmentDirectoryProvider();
      final documentsDirectory = await directoryProvider.documentsDirectory();
      await fileSystem.deleteFileIfExists(
        _joinPath(documentsDirectory.path, safeRelativePath),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'plan_record_attachment_storage',
          context: ErrorDescription('while removing a plan record image'),
        ),
      );
    }
  }

  String _buildFileName(String recordId, PlanPickedImage picked) {
    final safeRecordId = recordId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final extension = _safeExtension(picked.fileName) ?? _safeExtension(picked.path) ?? '.jpg';

    return '${safeRecordId}_$timestamp$extension';
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
    return first.endsWith(separator) ? '$first$second' : '$first$separator$second';
  }
}

abstract interface class PlanRecordImagePicker {
  Future<PlanPickedImage?> pickImage();
}

class PlanPickedImage {
  const PlanPickedImage({
    required this.path,
    required this.fileName,
    this.mimeType,
  });

  final String path;
  final String fileName;
  final String? mimeType;
}

class ImagePickerPlanRecordImagePicker implements PlanRecordImagePicker {
  const ImagePickerPlanRecordImagePicker();

  @override
  Future<PlanPickedImage?> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    return PlanPickedImage(
      path: image.path,
      fileName: image.name,
      mimeType: image.mimeType,
    );
  }
}

abstract interface class PlanRecordAttachmentDirectoryProvider {
  Future<Directory> documentsDirectory();

  Future<Directory> attachmentDirectory();
}

class AppDocumentsPlanRecordAttachmentDirectoryProvider
    implements PlanRecordAttachmentDirectoryProvider {
  const AppDocumentsPlanRecordAttachmentDirectoryProvider();

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
        LocalPlanRecordAttachmentStorage.attachmentDirectoryName,
      ),
    );
  }

  String _joinPath(String first, String second) {
    final separator = Platform.pathSeparator;
    return first.endsWith(separator) ? '$first$second' : '$first$separator$second';
  }
}

abstract interface class PlanRecordAttachmentFileSystem {
  Future<void> ensureDirectory(Directory directory);

  Future<File> copyFile(String sourcePath, String targetPath);

  Future<bool> fileExists(String path);

  Future<void> deleteFileIfExists(String path);
}

class DartPlanRecordAttachmentFileSystem
    implements PlanRecordAttachmentFileSystem {
  const DartPlanRecordAttachmentFileSystem();

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
