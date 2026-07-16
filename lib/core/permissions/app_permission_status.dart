import 'app_permission.dart';

enum AppPermissionStatus {
  granted,
  denied,
  settingsRequired,
  restricted,
  unavailable,
  notApplicable,
}

class AppPermissionResult {
  const AppPermissionResult({
    required this.permission,
    required this.status,
    this.didRequest = false,
    this.apiLevel,
  });

  final AppPermission permission;
  final AppPermissionStatus status;
  final bool didRequest;
  final int? apiLevel;

  bool get isGranted => status == AppPermissionStatus.granted;

  bool get requiresSettings => status == AppPermissionStatus.settingsRequired;

  bool get isApplicable => status != AppPermissionStatus.notApplicable;
}
