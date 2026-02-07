package com.izowooi.helltimer.presentation.settings

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BrightnessHigh
import androidx.compose.material.icons.filled.Code
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.NotificationsOff
import androidx.compose.material.icons.filled.OpenInNew
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.RestartAlt
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.izowooi.helltimer.R
import com.izowooi.helltimer.data.model.AppTheme
import com.izowooi.helltimer.data.model.UserSettings
import com.izowooi.helltimer.domain.model.EventType

@Composable
fun SettingsDrawerContent(
    viewModel: SettingsViewModel = viewModel(),
    modifier: Modifier = Modifier
) {
    val settings by viewModel.settings.collectAsState()
    val permissionGranted by viewModel.notificationPermissionGranted.collectAsState()
    val context = LocalContext.current

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { viewModel.refreshNotificationPermission() }

    LaunchedEffect(Unit) {
        viewModel.refreshNotificationPermission()
    }

    Column(
        modifier = modifier
            .fillMaxHeight()
            .width(300.dp)
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        // Header
        Text(
            text = stringResource(R.string.settings),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        HorizontalDivider()

        // MARK: - Theme
        SectionHeader(stringResource(R.string.settings_theme))

        ThemeRow(
            label = stringResource(R.string.theme_light),
            icon = Icons.Default.BrightnessHigh,
            iconTint = Color(0xFFFF9800),
            selected = settings.appTheme == AppTheme.LIGHT,
            onClick = { viewModel.setAppTheme(AppTheme.LIGHT) }
        )
        ThemeRow(
            label = stringResource(R.string.theme_dark),
            icon = Icons.Default.DarkMode,
            iconTint = Color(0xFF5C6BC0),
            selected = settings.appTheme == AppTheme.DARK,
            onClick = { viewModel.setAppTheme(AppTheme.DARK) }
        )
        ThemeRow(
            label = stringResource(R.string.theme_system),
            icon = Icons.Default.PhoneAndroid,
            iconTint = MaterialTheme.colorScheme.onSurfaceVariant,
            selected = settings.appTheme == AppTheme.SYSTEM,
            onClick = { viewModel.setAppTheme(AppTheme.SYSTEM) }
        )

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // MARK: - Notification Permission
        SectionHeader(stringResource(R.string.settings_notification_status))

        Row(
            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = if (permissionGranted) Icons.Default.Notifications else Icons.Default.NotificationsOff,
                contentDescription = null,
                tint = if (permissionGranted) Color(0xFF4CAF50) else Color(0xFFF44336),
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = stringResource(R.string.settings_notification_permission),
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = if (permissionGranted) stringResource(R.string.permission_authorized) else stringResource(R.string.permission_denied),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        if (!permissionGranted) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                TextButton(onClick = {
                    permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }) {
                    Text(stringResource(R.string.settings_request_permission))
                }
            }
            TextButton(onClick = {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                }
                context.startActivity(intent)
            }) {
                Text(stringResource(R.string.settings_change_in_settings))
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // MARK: - Event Notifications
        SectionHeader(stringResource(R.string.settings_event_notifications))

        EventNotificationToggle(
            eventType = EventType.HELLTIDE,
            enabled = settings.helltideNotificationEnabled,
            disabled = !permissionGranted,
            onToggle = { viewModel.setHelltideNotification(it) }
        )
        EventNotificationToggle(
            eventType = EventType.LEGION,
            enabled = settings.legionNotificationEnabled,
            disabled = !permissionGranted,
            onToggle = { viewModel.setLegionNotification(it) }
        )
        EventNotificationToggle(
            eventType = EventType.WORLD_BOSS,
            enabled = settings.worldBossNotificationEnabled,
            disabled = !permissionGranted,
            onToggle = { viewModel.setWorldBossNotification(it) }
        )

        if (!permissionGranted) {
            Text(
                text = stringResource(R.string.settings_enable_permission_first),
                style = MaterialTheme.typography.bodySmall,
                color = Color(0xFFFF9800)
            )
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // MARK: - Notification Timing
        SectionHeader(stringResource(R.string.settings_notification_time))

        UserSettings.availableNotificationMinutes.forEach { minutes ->
            val selected = settings.notificationMinutesBefore.contains(minutes)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(enabled = permissionGranted) {
                        viewModel.toggleNotificationMinute(minutes)
                    }
                    .padding(vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.minutes_before, minutes),
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (permissionGranted) MaterialTheme.colorScheme.onSurface
                    else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                )
                Spacer(modifier = Modifier.weight(1f))
                if (selected) {
                    Text(
                        text = "\u2713",
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // MARK: - App Info
        SectionHeader(stringResource(R.string.settings_info))

        Row(
            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = stringResource(R.string.settings_version),
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "1.0",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable {
                    val intent = Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("https://github.com/izowooi/hell-timer/tree/main/android-proj")
                    )
                    context.startActivity(intent)
                }
                .padding(vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Code,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = stringResource(R.string.settings_source_code),
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.weight(1f))
            Icon(
                imageVector = Icons.Default.OpenInNew,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // MARK: - Reset
        TextButton(onClick = { viewModel.cancelAllNotifications() }) {
            Icon(
                imageVector = Icons.Default.Delete,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = stringResource(R.string.settings_cancel_all_notifications),
                color = MaterialTheme.colorScheme.error
            )
        }

        TextButton(onClick = { viewModel.resetSettings() }) {
            Icon(
                imageVector = Icons.Default.RestartAlt,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = stringResource(R.string.settings_reset),
                color = MaterialTheme.colorScheme.error
            )
        }

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Composable
private fun SectionHeader(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.labelMedium,
        color = MaterialTheme.colorScheme.primary,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(top = 8.dp, bottom = 4.dp)
    )
}

@Composable
private fun ThemeRow(
    label: String,
    icon: ImageVector,
    iconTint: Color,
    selected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconTint,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(text = label, style = MaterialTheme.typography.bodyMedium)
        Spacer(modifier = Modifier.weight(1f))
        if (selected) {
            Text(
                text = "\u2713",
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun EventNotificationToggle(
    eventType: EventType,
    enabled: Boolean,
    disabled: Boolean,
    onToggle: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            painter = painterResource(id = eventType.iconResId),
            contentDescription = null,
            tint = eventType.color,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = stringResource(eventType.displayNameResId),
            style = MaterialTheme.typography.bodyMedium,
            color = if (disabled) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
            else MaterialTheme.colorScheme.onSurface
        )
        Spacer(modifier = Modifier.weight(1f))
        Switch(
            checked = enabled,
            onCheckedChange = onToggle,
            enabled = !disabled
        )
    }
}
