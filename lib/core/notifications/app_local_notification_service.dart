import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:four_in_one_app/core/notifications/app_notification_payload.dart';
import 'package:four_in_one_app/core/notifications/device_time_zone_provider.dart';
import 'package:four_in_one_app/core/notifications/local_notifications_gateway.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum NotificationOperationStatus { completed, unavailable, failed }

class NotificationOperationResult {
  const NotificationOperationResult({required this.status, this.errorCode});

  const NotificationOperationResult.completed()
    : status = NotificationOperationStatus.completed,
      errorCode = null;

  const NotificationOperationResult.unavailable([this.errorCode])
    : status = NotificationOperationStatus.unavailable;

  const NotificationOperationResult.failed(this.errorCode)
    : status = NotificationOperationStatus.failed;

  final NotificationOperationStatus status;
  final String? errorCode;

  bool get isCompleted => status == NotificationOperationStatus.completed;
}

class AppNotificationHealth {
  const AppNotificationHealth({
    required this.pendingCount,
    required this.channelsAvailable,
    required this.timeZoneId,
    this.habitChannelAvailable,
    this.focusChannelAvailable,
    this.lastErrorCode,
  });

  final int pendingCount;
  final bool? channelsAvailable;
  final bool? habitChannelAvailable;
  final bool? focusChannelAvailable;
  final String? timeZoneId;
  final String? lastErrorCode;
}

class _AndroidChannelHealth {
  const _AndroidChannelHealth({
    required this.querySucceeded,
    required this.habitAvailable,
    required this.focusAvailable,
    this.errorCode,
  });

  const _AndroidChannelHealth.notApplicable()
    : querySucceeded = true,
      habitAvailable = null,
      focusAvailable = null,
      errorCode = null;

  final bool querySucceeded;
  final bool? habitAvailable;
  final bool? focusAvailable;
  final String? errorCode;

  bool? get allAvailable {
    if (habitAvailable == null || focusAvailable == null) {
      return null;
    }
    return habitAvailable! && focusAvailable!;
  }
}

/// One process-wide owner for local notification initialization and delivery.
class AppLocalNotificationService {
  AppLocalNotificationService({
    LocalNotificationsGateway? gateway,
    DeviceTimeZoneProvider? timeZoneProvider,
    int accentColorValue = 0xFF16A34A,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _gateway = gateway ?? FlutterLocalNotificationsGateway(),
       _timeZoneProvider =
           timeZoneProvider ?? AndroidMethodChannelTimeZoneProvider(),
       _accentColorValue = accentColorValue,
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  static const habitChannelId = 'habit_reminders_v1';
  static const habitChannelName = '习惯提醒';
  static const habitChannelDescription = '按你设置的日期和时间发送习惯打卡提醒';
  static const focusChannelId = 'focus_completion_v1';
  static const focusChannelName = '专注完成';
  static const focusChannelDescription = '在一轮专注结束时提醒你查看记录';
  static const notificationIcon = 'ic_stat_getready';
  static const testNotificationId = 990001;
  static const scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

  static const _habitChannel = AndroidNotificationChannel(
    habitChannelId,
    habitChannelName,
    description: habitChannelDescription,
    importance: Importance.defaultImportance,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const _focusChannel = AndroidNotificationChannel(
    focusChannelId,
    focusChannelName,
    description: focusChannelDescription,
    importance: Importance.defaultImportance,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  final LocalNotificationsGateway _gateway;
  final DeviceTimeZoneProvider _timeZoneProvider;
  final int _accentColorValue;
  final bool _isWeb;
  final TargetPlatform _platform;
  final StreamController<NotificationResponse> _responses =
      StreamController<NotificationResponse>.broadcast(sync: true);

  Future<void>? _initialization;
  bool _initialized = false;
  bool _disposed = false;
  NotificationResponse? _initialResponse;
  String? _configuredTimeZoneId;
  String? _lastRuntimeErrorCode;
  String? _lastSchedulingErrorCode;
  int _schedulingErrorRevision = 0;

  Stream<NotificationResponse> get responses => _responses.stream;
  bool get isInitialized => _isWeb || _initialized;
  String? get lastErrorCode => _lastSchedulingErrorCode;
  String? get configuredTimeZoneId => _configuredTimeZoneId;
  int get schedulingErrorRevision => _schedulingErrorRevision;

  Future<void> initialize() {
    if (_isWeb || _initialized || _disposed) {
      return Future<void>.value();
    }

    final inFlight = _initialization;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<void> attempt;
    attempt = _initializeOnce().whenComplete(() {
      if (identical(_initialization, attempt)) {
        _initialization = null;
      }
    });
    _initialization = attempt;
    return attempt;
  }

  Future<void> _initializeOnce() async {
    try {
      await _configureLocalTimeZone();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings(notificationIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      final didInitialize = await _gateway.initialize(
        settings: settings,
        onResponse: _handleResponse,
      );
      if (didInitialize == false) {
        _lastRuntimeErrorCode = 'initialize:rejected';
        return;
      }

      if (_platform == TargetPlatform.android) {
        await _gateway.createAndroidChannel(_habitChannel);
        await _gateway.createAndroidChannel(_focusChannel);
      }

      final launchDetails = await _gateway.getLaunchDetails();
      if ((launchDetails?.didNotificationLaunchApp ?? false) &&
          launchDetails?.notificationResponse != null) {
        _initialResponse = launchDetails!.notificationResponse;
      }
      _initialized = true;
      _lastRuntimeErrorCode = null;
    } catch (error) {
      _recordRuntimeError('initialize', error);
    }
  }

  void markSchedulingHealthy(int baselineRevision) {
    if (_schedulingErrorRevision == baselineRevision) {
      _lastSchedulingErrorCode = null;
    }
  }

  NotificationResponse? takeInitialResponse() {
    final response = _initialResponse;
    _initialResponse = null;
    return response;
  }

  Future<bool> refreshTimeZone() async {
    if (_isWeb) {
      return false;
    }

    final previousId = _configuredTimeZoneId;
    await _configureLocalTimeZone();
    return previousId != null && previousId != _configuredTimeZoneId;
  }

  Future<NotificationOperationResult> scheduleHabitReminder({
    required int id,
    required String habitName,
    required tz.TZDateTime scheduledDate,
    required DateTimeComponents matchDateTimeComponents,
    required String payload,
  }) async {
    if (_isWeb) {
      return const NotificationOperationResult.unavailable('web');
    }

    await initialize();
    if (!_initialized) {
      return NotificationOperationResult.failed(
        _recordSchedulingCode('schedule_habit:initialization_unavailable'),
      );
    }
    final normalizedName = habitName.trim();
    final body = normalizedName.isEmpty
        ? '今天还有一个习惯等待完成'
        : '今天的「$normalizedName」还未完成';

    try {
      await _gateway.cancel(id);
      await _gateway.zonedSchedule(
        id: id,
        title: '该打卡了',
        body: body,
        scheduledDate: scheduledDate,
        details: NotificationDetails(
          android: _habitAndroidDetails(body),
          iOS: const DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: scheduleMode,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      return const NotificationOperationResult.completed();
    } catch (error) {
      return NotificationOperationResult.failed(
        _recordSchedulingError('schedule_habit', error),
      );
    }
  }

  Future<NotificationOperationResult> scheduleFocusCompletion({
    required int id,
    required DateTime targetEndAt,
    required String payload,
  }) async {
    if (_isWeb) {
      return const NotificationOperationResult.unavailable('web');
    }

    await initialize();
    if (!_initialized) {
      return NotificationOperationResult.failed(
        _recordSchedulingCode('schedule_focus:initialization_unavailable'),
      );
    }
    const body = '本轮专注已完成，回来看看刚才的进展';

    try {
      await _gateway.cancel(id);
      await _gateway.zonedSchedule(
        id: id,
        title: '专注完成',
        body: body,
        scheduledDate: tz.TZDateTime.from(targetEndAt.toUtc(), tz.local),
        details: NotificationDetails(
          android: _focusAndroidDetails(body),
          iOS: const DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: scheduleMode,
        payload: payload,
      );
      return const NotificationOperationResult.completed();
    } catch (error) {
      return NotificationOperationResult.failed(
        _recordSchedulingError('schedule_focus', error),
      );
    }
  }

  Future<NotificationOperationResult> sendTestNotification({
    required String payload,
    bool channelsApplicable = true,
  }) async {
    if (_isWeb) {
      return const NotificationOperationResult.unavailable('web');
    }

    await initialize();
    if (!_initialized) {
      return const NotificationOperationResult.failed(
        'show_test:initialization_unavailable',
      );
    }
    if (channelsApplicable) {
      final channelHealth = await _readAndroidChannelHealth();
      if (!channelHealth.querySucceeded) {
        return NotificationOperationResult.failed(
          channelHealth.errorCode ?? 'show_test:channel_status_unavailable',
        );
      }
      if (channelHealth.habitAvailable == false) {
        return const NotificationOperationResult.unavailable(
          'habit_channel_disabled',
        );
      }
    }
    const body = '这是一条测试通知，不会重复发送';

    try {
      await _gateway.cancel(testNotificationId);
      await _gateway.show(
        id: testNotificationId,
        title: '通知测试',
        body: body,
        details: NotificationDetails(
          android: _testAndroidDetails(body),
          iOS: const DarwinNotificationDetails(presentSound: true),
        ),
        payload: payload,
      );
      return const NotificationOperationResult.completed();
    } catch (error) {
      return NotificationOperationResult.failed(
        _recordRuntimeError('show_test', error),
      );
    }
  }

  Future<NotificationOperationResult> cancel(int id) async {
    if (_isWeb) {
      return const NotificationOperationResult.unavailable('web');
    }

    await initialize();
    if (!_initialized) {
      return NotificationOperationResult.failed(
        _recordSchedulingCode('cancel:initialization_unavailable'),
      );
    }
    try {
      await _gateway.cancel(id);
      return const NotificationOperationResult.completed();
    } catch (error) {
      return NotificationOperationResult.failed(
        _recordSchedulingError('cancel', error),
      );
    }
  }

  Future<List<PendingNotificationRequest>> pendingRequests({
    bool recordSchedulingFailure = false,
  }) async {
    if (_isWeb) {
      return const <PendingNotificationRequest>[];
    }

    await initialize();
    if (!_initialized) {
      if (recordSchedulingFailure) {
        _recordSchedulingCode('pending:initialization_unavailable');
      } else {
        _lastRuntimeErrorCode = 'pending:initialization_unavailable';
      }
      return const <PendingNotificationRequest>[];
    }
    try {
      return await _gateway.pendingRequests();
    } catch (error) {
      if (recordSchedulingFailure) {
        _recordSchedulingError('pending', error);
      } else {
        _recordRuntimeError('pending', error);
      }
      return const <PendingNotificationRequest>[];
    }
  }

  Future<AppNotificationHealth> health() async {
    final pending = await pendingRequests();
    final channelHealth = await _readAndroidChannelHealth();

    return AppNotificationHealth(
      pendingCount: pending.length,
      channelsAvailable: channelHealth.allAvailable,
      habitChannelAvailable: channelHealth.habitAvailable,
      focusChannelAvailable: channelHealth.focusAvailable,
      timeZoneId: _configuredTimeZoneId,
      lastErrorCode: lastErrorCode,
    );
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _responses.close();
  }

  AndroidNotificationDetails _habitAndroidDetails(String body) {
    return AndroidNotificationDetails(
      habitChannelId,
      habitChannelName,
      channelDescription: habitChannelDescription,
      icon: notificationIcon,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
      color: Color(_accentColorValue),
      visibility: NotificationVisibility.private,
      category: AndroidNotificationCategory.reminder,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          AppNotificationAction.habitOpen,
          '去打卡',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  AndroidNotificationDetails _focusAndroidDetails(String body) {
    return AndroidNotificationDetails(
      focusChannelId,
      focusChannelName,
      channelDescription: focusChannelDescription,
      icon: notificationIcon,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
      color: Color(_accentColorValue),
      visibility: NotificationVisibility.private,
      category: AndroidNotificationCategory.reminder,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          AppNotificationAction.focusViewRecords,
          '查看记录',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  AndroidNotificationDetails _testAndroidDetails(String body) {
    return AndroidNotificationDetails(
      habitChannelId,
      habitChannelName,
      channelDescription: habitChannelDescription,
      icon: notificationIcon,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
      color: Color(_accentColorValue),
      visibility: NotificationVisibility.private,
      category: AndroidNotificationCategory.status,
    );
  }

  void _handleResponse(NotificationResponse response) {
    if (!_disposed && !_responses.isClosed) {
      _responses.add(response);
    }
  }

  Future<_AndroidChannelHealth> _readAndroidChannelHealth() async {
    if (_isWeb || _platform != TargetPlatform.android) {
      return const _AndroidChannelHealth.notApplicable();
    }

    if (!_initialized) {
      final errorCode = _lastRuntimeErrorCode ?? 'channels:not_initialized';
      return _AndroidChannelHealth(
        querySucceeded: false,
        habitAvailable: false,
        focusAvailable: false,
        errorCode: errorCode,
      );
    }

    try {
      final channels = await _gateway.getAndroidChannels();
      if (channels == null) {
        const errorCode = 'channels:unavailable';
        _lastRuntimeErrorCode = errorCode;
        return const _AndroidChannelHealth(
          querySucceeded: false,
          habitAvailable: false,
          focusAvailable: false,
          errorCode: errorCode,
        );
      }

      AndroidNotificationChannel? habitChannel;
      AndroidNotificationChannel? focusChannel;
      for (final channel in channels) {
        if (channel.id == habitChannelId) {
          habitChannel = channel;
        } else if (channel.id == focusChannelId) {
          focusChannel = channel;
        }
      }

      return _AndroidChannelHealth(
        querySucceeded: true,
        habitAvailable:
            habitChannel != null && habitChannel.importance != Importance.none,
        focusAvailable:
            focusChannel != null && focusChannel.importance != Importance.none,
      );
    } catch (error) {
      final errorCode = _recordRuntimeError('channels', error);
      return _AndroidChannelHealth(
        querySucceeded: false,
        habitAvailable: false,
        focusAvailable: false,
        errorCode: errorCode,
      );
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();
    final requestedId = await _timeZoneProvider.getTimeZoneId();

    if (requestedId != null) {
      try {
        tz.setLocalLocation(tz.getLocation(requestedId));
        _configuredTimeZoneId = requestedId;
        return;
      } catch (_) {
        // Fall through to the fixed-offset fail-safe below.
      }
    }

    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final abbreviation = now.timeZoneName.trim().isEmpty
        ? 'Local'
        : now.timeZoneName.trim();
    final offsetId = 'device-offset-${offset.inMinutes}';
    tz.setLocalLocation(
      tz.Location(offsetId, <int>[tz.minTime], <int>[0], <tz.TimeZone>[
        tz.TimeZone(offset, isDst: false, abbreviation: abbreviation),
      ]),
    );
    _configuredTimeZoneId = offsetId;
  }

  String _recordRuntimeError(String operation, Object error) {
    final code = '$operation:${error.runtimeType}';
    _lastRuntimeErrorCode = code;
    return code;
  }

  String _recordSchedulingError(String operation, Object error) {
    return _recordSchedulingCode('$operation:${error.runtimeType}');
  }

  String _recordSchedulingCode(String code) {
    _schedulingErrorRevision += 1;
    _lastSchedulingErrorCode = code;
    return code;
  }
}
