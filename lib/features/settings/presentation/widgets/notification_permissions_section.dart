import 'dart:async';

import 'package:flutter/material.dart';
import 'package:four_in_one_app/app/theme/app_theme_tokens.dart';
import 'package:four_in_one_app/core/notifications/app_local_notification_service.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_controller.dart';
import 'package:four_in_one_app/core/notifications/notification_runtime_scope.dart';
import 'package:four_in_one_app/core/permissions/app_permission_status.dart';
import 'package:four_in_one_app/core/permissions/notification_permission_prompt.dart';
import 'package:four_in_one_app/shared/widgets/product/app_quiet_badge.dart';
import 'package:four_in_one_app/shared/widgets/product/my_settings_section.dart';

class NotificationPermissionsSection extends StatefulWidget {
  const NotificationPermissionsSection({super.key});

  @override
  State<NotificationPermissionsSection> createState() =>
      _NotificationPermissionsSectionState();
}

class _NotificationPermissionsSectionState
    extends State<NotificationPermissionsSection> {
  bool _healthExpanded = false;
  bool _didRequestInitialRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestInitialRefresh) {
      return;
    }
    _didRequestInitialRefresh = true;
    final runtime = NotificationRuntimeScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(runtime.refresh());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final runtime = NotificationRuntimeScope.of(context);
    return AnimatedBuilder(
      animation: runtime,
      builder: (context, _) {
        final state = runtime.state;
        final permission = state.permission;
        final apiLevel = permission?.apiLevel;
        final androidSettingsApplicable =
            permission != null &&
            permission.status != AppPermissionStatus.notApplicable;
        final channelSettingsApplicable =
            androidSettingsApplicable && apiLevel != null && apiLevel >= 26;
        final notificationTestApplicable =
            permission != null &&
            permission.status != AppPermissionStatus.notApplicable;

        return MySettingsSection(
          key: const ValueKey('settings-notifications-permissions'),
          title: '通知与权限',
          subtitle: '只在你启用提醒时申请通知权限，图片和相机保持最小访问。',
          leadingIcon: Icons.notifications_active_outlined,
          rows: [
            MySettingsRow(
              key: const ValueKey('settings-notification-permission'),
              title: '通知权限',
              subtitle: _permissionSubtitle(permission?.status),
              leadingIcon: Icons.notifications_none_rounded,
              trailing: AppQuietBadge(
                label: _permissionBadge(permission?.status),
              ),
              enabled: androidSettingsApplicable,
              onTap: androidSettingsApplicable
                  ? () => _handlePermission(runtime)
                  : null,
            ),
            const MySettingsRow(
              key: ValueKey('settings-reminder-precision'),
              title: '提醒精度',
              subtitle: '使用普通提醒；Android 可能为节省电量做小幅调整。',
              leadingIcon: Icons.schedule_rounded,
              trailing: AppQuietBadge(label: '普通提醒'),
            ),
            const MySettingsRow(
              key: ValueKey('settings-image-access'),
              title: '图片访问',
              subtitle: '使用系统照片选择器，只访问你选择的图片，无需访问全部相册。',
              leadingIcon: Icons.photo_library_outlined,
              trailing: AppQuietBadge(label: '按需选择'),
            ),
            const MySettingsRow(
              key: ValueKey('settings-camera-access'),
              title: '相机',
              subtitle: '拍照时使用系统相机，本应用不直接访问相机预览。',
              leadingIcon: Icons.photo_camera_outlined,
              trailing: AppQuietBadge(label: '系统相机'),
            ),
            MySettingsRow(
              key: const ValueKey('settings-test-notification'),
              title: '通知测试',
              subtitle: permission == null
                  ? '正在确认当前平台是否支持本地通知测试。'
                  : notificationTestApplicable
                  ? '发送一条明确标记、不会重复的测试通知。'
                  : '当前平台不支持 Android 本地通知测试。',
              leadingIcon: Icons.notification_add_outlined,
              trailing: state.isRefreshing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              enabled: notificationTestApplicable,
              onTap: state.isRefreshing || !notificationTestApplicable
                  ? null
                  : () => _sendTestNotification(runtime),
            ),
            MySettingsRow(
              key: const ValueKey('settings-notification-settings'),
              title: '系统设置',
              subtitle: androidSettingsApplicable
                  ? '打开 Android 应用通知设置。'
                  : permission == null
                  ? '正在确认当前平台是否适用。'
                  : '当前平台不提供 Android 应用通知设置。',
              leadingIcon: Icons.settings_outlined,
              trailing: androidSettingsApplicable
                  ? const Icon(Icons.open_in_new_rounded, size: 18)
                  : AppQuietBadge(label: permission == null ? '检查中' : '不适用'),
              enabled: androidSettingsApplicable,
              onTap: androidSettingsApplicable
                  ? () => runtime.openNotificationSettings()
                  : null,
            ),
            MySettingsRow(
              key: const ValueKey('settings-channel-settings'),
              title: '习惯提醒渠道',
              subtitle: _channelSettingsSubtitle(
                permissionStatus: permission?.status,
                apiLevel: apiLevel,
                channelName: AppLocalNotificationService.habitChannelName,
              ),
              leadingIcon: Icons.tune_rounded,
              trailing: channelSettingsApplicable
                  ? const Icon(Icons.open_in_new_rounded, size: 18)
                  : AppQuietBadge(
                      label: _channelSettingsBadge(
                        permissionStatus: permission?.status,
                        apiLevel: apiLevel,
                      ),
                    ),
              enabled: channelSettingsApplicable,
              onTap: channelSettingsApplicable
                  ? () => runtime.openHabitChannelSettings()
                  : null,
            ),
            MySettingsRow(
              key: const ValueKey('settings-focus-channel-settings'),
              title: '专注完成渠道',
              subtitle: _channelSettingsSubtitle(
                permissionStatus: permission?.status,
                apiLevel: apiLevel,
                channelName: AppLocalNotificationService.focusChannelName,
              ),
              leadingIcon: Icons.timer_outlined,
              trailing: channelSettingsApplicable
                  ? const Icon(Icons.open_in_new_rounded, size: 18)
                  : AppQuietBadge(
                      label: _channelSettingsBadge(
                        permissionStatus: permission?.status,
                        apiLevel: apiLevel,
                      ),
                    ),
              enabled: channelSettingsApplicable,
              onTap: channelSettingsApplicable
                  ? () => runtime.openFocusChannelSettings()
                  : null,
            ),
            MySettingsRow(
              key: const ValueKey('settings-notification-health'),
              title: '提醒健康状态',
              subtitle: _healthSummary(state),
              leadingIcon: Icons.health_and_safety_outlined,
              trailing: Icon(
                _healthExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                key: const ValueKey('settings-notification-health-expand'),
              ),
              onTap: () {
                setState(() {
                  _healthExpanded = !_healthExpanded;
                });
                if (_healthExpanded) {
                  unawaited(runtime.refresh());
                }
              },
              content: _healthExpanded ? _HealthDetails(state: state) : null,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePermission(NotificationRuntimeController runtime) async {
    final status = await runtime.checkNotificationPermission();
    if (!mounted) {
      return;
    }

    if (status.status == AppPermissionStatus.granted) {
      await runtime.openNotificationSettings();
    } else {
      await requestNotificationPermissionInContext(
        context,
        requestContext: NotificationPermissionContext.settings,
        controller: runtime,
      );
    }
    await runtime.refresh();
  }

  Future<void> _sendTestNotification(
    NotificationRuntimeController runtime,
  ) async {
    final permission = await requestNotificationPermissionInContext(
      context,
      requestContext: NotificationPermissionContext.testNotification,
      controller: runtime,
    );
    if (!mounted) {
      return;
    }

    if (permission.status != AppPermissionStatus.granted &&
        permission.status != AppPermissionStatus.notApplicable) {
      _showMessage('Android 尚未允许通知，未发送测试通知。');
      return;
    }

    final result = await runtime.sendTestNotification();
    if (!mounted) {
      return;
    }
    if (result.errorCode == 'habit_channel_disabled' ||
        runtime.health?.habitChannelAvailable == false) {
      _showMessage(
        '“习惯提醒”渠道未开启，测试通知未发送。',
        action: SnackBarAction(
          label: '渠道设置',
          onPressed: () {
            unawaited(runtime.openHabitChannelSettings());
          },
        ),
      );
      return;
    }

    _showMessage(result.isCompleted ? '测试通知已提交，请查看通知栏。' : '测试通知暂时无法发送，请稍后重试。');
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action));
  }
}

class _HealthDetails extends StatelessWidget {
  const _HealthDetails({required this.state});

  final NotificationRuntimeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helperColor = AppThemeTokens.secondaryTextTone(theme.colorScheme);
    final health = state.health;
    final permissionStatus = state.permission?.status;
    final apiLevel = state.permission?.apiLevel;
    final rows = <(String, String)>[
      ('通知权限', _permissionBadge(state.permission?.status)),
      (
        '习惯提醒渠道',
        _channelLabel(
          health?.habitChannelAvailable,
          permissionStatus: permissionStatus,
          apiLevel: apiLevel,
        ),
      ),
      (
        '专注完成渠道',
        _channelLabel(
          health?.focusChannelAvailable,
          permissionStatus: permissionStatus,
          apiLevel: apiLevel,
        ),
      ),
      ('提醒精度', '普通提醒（无需精确闹钟权限）'),
      ('待发送提醒', '${health?.pendingCount ?? 0} 条'),
      ('最近调度', health?.lastErrorCode == null ? '正常' : '有一次操作未完成'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index += 1) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[index].$1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: helperColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceMd),
                Flexible(
                  child: Text(
                    rows[index].$2,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (index != rows.length - 1)
              const SizedBox(height: AppThemeTokens.spaceSm),
          ],
        ],
      ),
    );
  }
}

String _permissionBadge(AppPermissionStatus? status) {
  return switch (status) {
    AppPermissionStatus.granted => '已开启',
    AppPermissionStatus.denied => '未开启',
    AppPermissionStatus.settingsRequired => '需前往设置',
    AppPermissionStatus.restricted => '受系统限制',
    AppPermissionStatus.unavailable => '暂不可用',
    AppPermissionStatus.notApplicable => '无需申请',
    null => '检查中',
  };
}

String _permissionSubtitle(AppPermissionStatus? status) {
  return switch (status) {
    AppPermissionStatus.granted => 'Android 可以显示已安排的提醒。',
    AppPermissionStatus.denied => '启用提醒或点击此处时才会申请。',
    AppPermissionStatus.settingsRequired => '系统对话框无法再次弹出，请前往设置开启。',
    AppPermissionStatus.restricted => '通知受到系统或设备策略限制。',
    AppPermissionStatus.unavailable => '当前无法读取通知状态，提醒数据不受影响。',
    AppPermissionStatus.notApplicable => '当前平台无需 Android 通知权限。',
    null => '正在读取真实系统状态。',
  };
}

String _channelLabel(
  bool? available, {
  required AppPermissionStatus? permissionStatus,
  required int? apiLevel,
}) {
  if (permissionStatus == AppPermissionStatus.notApplicable ||
      (apiLevel != null && apiLevel < 26)) {
    return '不适用';
  }

  return switch (available) {
    true => '可用',
    false => '未开启',
    null => '检查中',
  };
}

String _channelSettingsSubtitle({
  required AppPermissionStatus? permissionStatus,
  required int? apiLevel,
  required String channelName,
}) {
  if (permissionStatus == null) {
    return '正在确认 Android 通知渠道支持。';
  }
  if (permissionStatus == AppPermissionStatus.notApplicable) {
    return '当前平台不提供 Android 通知渠道。';
  }
  if (apiLevel != null && apiLevel < 26) {
    return 'Android 8 以下没有独立通知渠道。';
  }
  if (apiLevel == null) {
    return '当前无法确认 Android 通知渠道支持。';
  }

  return '打开“$channelName”渠道设置。';
}

String _channelSettingsBadge({
  required AppPermissionStatus? permissionStatus,
  required int? apiLevel,
}) {
  if (permissionStatus == null) {
    return '检查中';
  }
  if (permissionStatus == AppPermissionStatus.notApplicable ||
      (apiLevel != null && apiLevel < 26)) {
    return '不适用';
  }
  if (apiLevel == null) {
    return '暂不可用';
  }

  return '可用';
}

String _healthSummary(NotificationRuntimeState state) {
  final pending = state.health?.pendingCount ?? 0;
  final hasError = state.health?.lastErrorCode != null;
  final permissionStatus = state.permission?.status;
  final apiLevel = state.permission?.apiLevel;
  final channelsApplicable =
      permissionStatus != AppPermissionStatus.notApplicable &&
      (apiLevel == null || apiLevel >= 26);
  final hasChannelIssue =
      channelsApplicable &&
      (state.health?.habitChannelAvailable == false ||
          state.health?.focusChannelAvailable == false);
  return '${_permissionBadge(state.permission?.status)} · '
      '$pending 条待发送${hasChannelIssue ? ' · 渠道需检查' : ''}'
      '${hasError ? ' · 需检查' : ''}';
}
