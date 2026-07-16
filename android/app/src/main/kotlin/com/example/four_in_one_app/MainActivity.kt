package com.example.four_in_one_app

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private var permissionChannel: MethodChannel? = null
    private val pendingNotificationPermissionResults = mutableListOf<MethodChannel.Result>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        permissionChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSION_CHANNEL).also { channel ->
                channel.setMethodCallHandler { call, result ->
                    handlePermissionCall(call, result)
                }
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        permissionChannel?.setMethodCallHandler(null)
        permissionChannel = null
        completePendingRequestAsUnavailable("activityDetached")
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) {
            return
        }

        if (shouldRememberNotificationPermissionResult(permissions, grantResults)) {
            markNotificationPermissionRequested()
        }

        completePendingRequests(notificationStatusMap())
    }

    private fun handlePermissionCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "notificationStatus" -> result.success(notificationStatusMap())
                "requestNotificationPermission" -> requestNotificationPermission(result)
                "openNotificationSettings" -> result.success(openNotificationSettings())
                "openNotificationChannelSettings" -> {
                    result.success(openNotificationChannelSettings(channelIdFrom(call)))
                }
                "getTimeZoneId" -> result.success(currentTimeZoneId())
                else -> result.notImplemented()
            }
        } catch (_: Exception) {
            when (call.method) {
                "getTimeZoneId" -> result.success(UTC_TIME_ZONE_ID)
                "openNotificationSettings", "openNotificationChannelSettings" -> {
                    result.success(false)
                }
                "notificationStatus", "requestNotificationPermission" -> {
                    result.success(
                        runCatching {
                            notificationStatusMap(
                                statusOverride = STATUS_UNAVAILABLE,
                                reason = "nativeOperationUnavailable",
                            )
                        }.getOrElse {
                            unavailableStatusMap(
                                Build.VERSION.SDK_INT,
                                "nativeOperationUnavailable",
                            )
                        },
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        val currentStatus = notificationStatusMap()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            currentStatus[KEY_STATUS] != STATUS_DENIED
        ) {
            result.success(currentStatus)
            return
        }

        if (pendingNotificationPermissionResults.isNotEmpty()) {
            // Coalesce callers onto the one Android system dialog so no caller
            // observes a synthetic denial while the real request is pending.
            pendingNotificationPermissionResults.add(result)
            return
        }

        pendingNotificationPermissionResults.add(result)
        try {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                NOTIFICATION_PERMISSION_REQUEST_CODE,
            )
        } catch (_: Exception) {
            completePendingRequests(
                notificationStatusMap(
                    statusOverride = STATUS_UNAVAILABLE,
                    reason = "permissionRequestUnavailable",
                ),
            )
        }
    }

    private fun notificationStatusMap(
        statusOverride: String? = null,
        reason: String? = null,
    ): MutableMap<String, Any?> {
        val apiLevel = Build.VERSION.SDK_INT
        val notificationsEnabled =
            runCatching {
                NotificationManagerCompat.from(this).areNotificationsEnabled()
            }.getOrElse {
                return unavailableStatusMap(apiLevel, reason ?: "notificationStatusUnavailable")
            }
        val runtimePermissionRequired = apiLevel >= Build.VERSION_CODES.TIRAMISU
        val permissionDeclared =
            if (runtimePermissionRequired) {
                isNotificationPermissionDeclared()
            } else {
                true
            }
        val permissionGranted =
            !runtimePermissionRequired ||
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS,
                ) == PackageManager.PERMISSION_GRANTED
        val shouldShowRationale =
            runtimePermissionRequired &&
                !permissionGranted &&
                ActivityCompat.shouldShowRequestPermissionRationale(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS,
                )
        val restrictedByPolicy =
            runtimePermissionRequired &&
                permissionDeclared &&
                !permissionGranted &&
                runCatching {
                    packageManager.isPermissionRevokedByPolicy(
                        Manifest.permission.POST_NOTIFICATIONS,
                        packageName,
                    )
                }.getOrDefault(false)
        val wasRequested =
            runtimePermissionRequired &&
                permissionDeclared &&
                wasNotificationPermissionRequested()

        val resolvedStatus =
            statusOverride ?: when {
                runtimePermissionRequired && !permissionDeclared -> STATUS_UNAVAILABLE
                restrictedByPolicy -> STATUS_RESTRICTED
                permissionGranted && notificationsEnabled -> STATUS_GRANTED
                permissionGranted -> STATUS_SETTINGS_REQUIRED
                wasRequested && !shouldShowRationale -> STATUS_SETTINGS_REQUIRED
                else -> STATUS_DENIED
            }

        return mutableMapOf<String, Any?>(
            KEY_STATUS to resolvedStatus,
            KEY_API_LEVEL to apiLevel,
            KEY_NOTIFICATIONS_ENABLED to notificationsEnabled,
            KEY_RUNTIME_PERMISSION_REQUIRED to runtimePermissionRequired,
            KEY_PERMISSION_DECLARED to permissionDeclared,
            KEY_PERMISSION_GRANTED to permissionGranted,
            KEY_CAN_REQUEST to (resolvedStatus == STATUS_DENIED),
            KEY_SHOULD_SHOW_RATIONALE to shouldShowRationale,
            KEY_REQUEST_IN_PROGRESS to pendingNotificationPermissionResults.isNotEmpty(),
        ).apply {
            if (reason != null) {
                this[KEY_REASON] = reason
            }
        }
    }

    private fun unavailableStatusMap(
        apiLevel: Int,
        reason: String,
    ): MutableMap<String, Any?> =
        mutableMapOf(
            KEY_STATUS to STATUS_UNAVAILABLE,
            KEY_API_LEVEL to apiLevel,
            KEY_NOTIFICATIONS_ENABLED to false,
            KEY_RUNTIME_PERMISSION_REQUIRED to
                (apiLevel >= Build.VERSION_CODES.TIRAMISU),
            KEY_PERMISSION_DECLARED to false,
            KEY_PERMISSION_GRANTED to false,
            KEY_CAN_REQUEST to false,
            KEY_SHOULD_SHOW_RATIONALE to false,
            KEY_REQUEST_IN_PROGRESS to pendingNotificationPermissionResults.isNotEmpty(),
            KEY_REASON to reason,
        )

    private fun isNotificationPermissionDeclared(): Boolean =
        runCatching {
            val packageInfo =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.PackageInfoFlags.of(
                            PackageManager.GET_PERMISSIONS.toLong(),
                        ),
                    )
                } else {
                    @Suppress("DEPRECATION")
                    packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
                }
            packageInfo.requestedPermissions?.contains(
                Manifest.permission.POST_NOTIFICATIONS,
            ) == true
        }.getOrDefault(false)

    private fun shouldRememberNotificationPermissionResult(
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        val permissionIndex = permissions.indexOf(Manifest.permission.POST_NOTIFICATIONS)
        if (permissionIndex < 0 || permissionIndex >= grantResults.size) {
            return false
        }

        // A dismissed Android 13+ dialog can return without changing the
        // permission state. Remember only a grant or a denial for which the
        // public rationale API confirms that the user made a denial choice.
        // After a later denial removes the rationale, the earlier marker lets
        // us direct the user to Settings without relying on hidden APIs.
        return grantResults[permissionIndex] == PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            )
    }

    private fun wasNotificationPermissionRequested(): Boolean =
        runCatching {
            getSharedPreferences(PERMISSION_PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_NOTIFICATION_PERMISSION_REQUESTED, false)
        }.getOrDefault(false)

    private fun markNotificationPermissionRequested() {
        runCatching {
            getSharedPreferences(PERMISSION_PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_NOTIFICATION_PERMISSION_REQUESTED, true)
                .apply()
        }
    }

    private fun openNotificationSettings(): Boolean {
        val primaryIntent =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
            } else {
                applicationDetailsSettingsIntent()
            }
        return startSettingsIntent(primaryIntent) ||
            (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                startSettingsIntent(applicationDetailsSettingsIntent()))
    }

    private fun openNotificationChannelSettings(
        channelId: String?,
    ): Boolean {
        if (!isValidChannelId(channelId)) {
            return false
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        if (notificationManager?.getNotificationChannel(channelId) == null) {
            return false
        }

        return startSettingsIntent(
            Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                putExtra(Settings.EXTRA_CHANNEL_ID, channelId)
            },
        ) || openNotificationSettings()
    }

    private fun applicationDetailsSettingsIntent(): Intent =
        Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", packageName, null),
        )

    private fun startSettingsIntent(intent: Intent): Boolean =
        runCatching {
            startActivity(intent)
            true
        }.getOrDefault(false)

    private fun channelIdFrom(call: MethodCall): String? =
        when (val arguments = call.arguments) {
            is String -> arguments
            is Map<*, *> -> arguments[KEY_CHANNEL_ID] as? String
            else -> null
        }?.trim()

    private fun isValidChannelId(channelId: String?): Boolean =
        channelId != null && CHANNEL_ID_PATTERN.matches(channelId)

    private fun currentTimeZoneId(): String =
        runCatching {
            TimeZone.getDefault().id.takeIf { it.isNotBlank() } ?: UTC_TIME_ZONE_ID
        }.getOrDefault(UTC_TIME_ZONE_ID)

    private fun completePendingRequestAsUnavailable(reason: String) {
        if (pendingNotificationPermissionResults.isEmpty()) {
            return
        }
        completePendingRequests(
            notificationStatusMap(
                statusOverride = STATUS_UNAVAILABLE,
                reason = reason,
            ),
        )
    }

    private fun completePendingRequests(status: Map<String, Any?>) {
        if (pendingNotificationPermissionResults.isEmpty()) {
            return
        }
        val results = pendingNotificationPermissionResults.toList()
        pendingNotificationPermissionResults.clear()
        for (pendingResult in results) {
            runCatching { pendingResult.success(status) }
        }
    }

    private companion object {
        const val PERMISSION_CHANNEL = "four_in_one_app/android_permissions"
        const val PERMISSION_PREFS_NAME = "android_permission_coordinator"
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 9_013
        const val UTC_TIME_ZONE_ID = "UTC"

        const val STATUS_GRANTED = "granted"
        const val STATUS_DENIED = "denied"
        const val STATUS_SETTINGS_REQUIRED = "settingsRequired"
        const val STATUS_RESTRICTED = "restricted"
        const val STATUS_UNAVAILABLE = "unavailable"

        const val KEY_STATUS = "status"
        const val KEY_API_LEVEL = "apiLevel"
        const val KEY_NOTIFICATIONS_ENABLED = "notificationsEnabled"
        const val KEY_RUNTIME_PERMISSION_REQUIRED = "runtimePermissionRequired"
        const val KEY_PERMISSION_DECLARED = "permissionDeclared"
        const val KEY_PERMISSION_GRANTED = "permissionGranted"
        const val KEY_CAN_REQUEST = "canRequest"
        const val KEY_SHOULD_SHOW_RATIONALE = "shouldShowRationale"
        const val KEY_REQUEST_IN_PROGRESS = "requestInProgress"
        const val KEY_CHANNEL_ID = "channelId"
        const val KEY_REASON = "reason"
        const val KEY_NOTIFICATION_PERMISSION_REQUESTED =
            "notificationPermissionRequested"

        val CHANNEL_ID_PATTERN = Regex("^[A-Za-z0-9._-]{1,100}$")
    }
}
