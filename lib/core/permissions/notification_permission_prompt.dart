import 'package:flutter/material.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';
import 'package:four_in_one_app/core/permissions/permission_explanation.dart';

enum NotificationPermissionContext {
  habitReminder,
  focusCompletion,
  testNotification,
  settings,
}

Future<AppPermissionResult> requestNotificationPermissionInContext(
  BuildContext context, {
  required NotificationPermissionContext requestContext,
  NotificationRuntimeController? controller,
}) async {
  final runtime = controller ?? NotificationRuntimeScope.of(context);
  final current = await runtime.checkNotificationPermission();
  if (!context.mounted ||
      current.status == AppPermissionStatus.granted ||
      current.status == AppPermissionStatus.notApplicable ||
      current.status == AppPermissionStatus.unavailable) {
    return current;
  }

  if (current.status == AppPermissionStatus.settingsRequired ||
      current.status == AppPermissionStatus.restricted) {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('前往系统设置'),
        content: Text(
          current.status == AppPermissionStatus.restricted
              ? '通知受系统或设备策略限制，请在允许时前往系统设置查看。'
              : PermissionExplanations.notifications.settingsRequiredMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('暂不开启'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
    if (openSettings == true) {
      await runtime.openNotificationSettings();
    }
    return current;
  }

  final continueRequest = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(PermissionExplanations.notifications.title),
      content: Text(
        '${_contextualReason(requestContext)}\n\n'
        '${PermissionExplanations.notifications.rationale}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('暂不开启'),
        ),
        FilledButton(
          key: const ValueKey('notification-permission-continue'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('继续'),
        ),
      ],
    ),
  );

  if (continueRequest != true) {
    return current;
  }
  return runtime.requestNotificationPermission();
}

String _contextualReason(NotificationPermissionContext requestContext) {
  return switch (requestContext) {
    NotificationPermissionContext.habitReminder =>
      '你刚刚设置了习惯提醒。允许通知后，Android 才能在提醒时间显示它。',
    NotificationPermissionContext.focusCompletion =>
      '允许通知后，即使你暂时离开应用，也能收到本轮专注完成提醒。',
    NotificationPermissionContext.testNotification =>
      '发送测试通知前，需要先允许 Android 显示本应用的通知。',
    NotificationPermissionContext.settings => '允许通知后，已保存的习惯提醒和专注完成提醒才能显示。',
  };
}
