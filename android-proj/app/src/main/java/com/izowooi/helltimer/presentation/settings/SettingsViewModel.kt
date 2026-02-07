package com.izowooi.helltimer.presentation.settings

import android.Manifest
import android.app.Application
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.izowooi.helltimer.data.model.AppTheme
import com.izowooi.helltimer.data.model.UserSettings
import com.izowooi.helltimer.data.repository.SettingsRepository
import com.izowooi.helltimer.notification.NotificationScheduler
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = SettingsRepository(application)
    private val scheduler = NotificationScheduler(application)

    val settings: StateFlow<UserSettings> = repository.settingsFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), UserSettings())

    private val _notificationPermissionGranted = MutableStateFlow(checkNotificationPermission())
    val notificationPermissionGranted: StateFlow<Boolean> = _notificationPermissionGranted.asStateFlow()

    fun refreshNotificationPermission() {
        _notificationPermissionGranted.value = checkNotificationPermission()
    }

    private fun checkNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                getApplication(),
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    fun setAppTheme(theme: AppTheme) {
        viewModelScope.launch { repository.setAppTheme(theme) }
    }

    fun setHelltideNotification(enabled: Boolean) {
        viewModelScope.launch {
            repository.setHelltideNotification(enabled)
            rescheduleNotifications()
        }
    }

    fun setLegionNotification(enabled: Boolean) {
        viewModelScope.launch {
            repository.setLegionNotification(enabled)
            rescheduleNotifications()
        }
    }

    fun setWorldBossNotification(enabled: Boolean) {
        viewModelScope.launch {
            repository.setWorldBossNotification(enabled)
            rescheduleNotifications()
        }
    }

    fun toggleNotificationMinute(minute: Int) {
        viewModelScope.launch {
            val current = settings.value.notificationMinutesBefore
            val updated = if (current.contains(minute)) current - minute else current + minute
            repository.setNotificationMinutes(updated)
            rescheduleNotifications()
        }
    }

    fun cancelAllNotifications() {
        scheduler.cancelAllNotifications()
    }

    fun resetSettings() {
        viewModelScope.launch {
            repository.resetToDefaults()
            scheduler.cancelAllNotifications()
        }
    }

    private fun rescheduleNotifications() {
        scheduler.cancelAllNotifications()
        val s = settings.value
        val minutes = s.notificationMinutesBefore.toList()
        if (minutes.isEmpty()) return

        if (s.helltideNotificationEnabled) scheduler.scheduleHelltideNotifications(minutes)
        if (s.legionNotificationEnabled) scheduler.scheduleLegionNotifications(minutes)
        if (s.worldBossNotificationEnabled) scheduler.scheduleWorldBossNotifications(minutes)
    }
}
