import 'app_permission.dart';

class PermissionExplanation {
  const PermissionExplanation({
    required this.title,
    required this.rationale,
    required this.deniedMessage,
    required this.settingsRequiredMessage,
  });

  final String title;
  final String rationale;
  final String deniedMessage;
  final String settingsRequiredMessage;
}

abstract final class PermissionExplanations {
  static const notifications = PermissionExplanation(
    title: '开启通知',
    rationale: '开启通知后，习惯提醒和专注完成提醒才能在系统中显示。你可以稍后在系统设置中更改。',
    deniedMessage: '提醒设置已保存，但 Android 当前不会显示通知。',
    settingsRequiredMessage: '通知权限已关闭，请前往系统设置开启。',
  );

  static PermissionExplanation forPermission(AppPermission permission) {
    return switch (permission) {
      AppPermission.notifications => notifications,
    };
  }
}
