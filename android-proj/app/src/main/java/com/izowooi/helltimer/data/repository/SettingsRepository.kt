package com.izowooi.helltimer.data.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.izowooi.helltimer.data.model.AppTheme
import com.izowooi.helltimer.data.model.UserSettings
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class SettingsRepository(private val context: Context) {

    private object Keys {
        val APP_THEME = stringPreferencesKey("app_theme")
        val HELLTIDE_NOTIFICATION = booleanPreferencesKey("helltide_notification")
        val LEGION_NOTIFICATION = booleanPreferencesKey("legion_notification")
        val WORLD_BOSS_NOTIFICATION = booleanPreferencesKey("world_boss_notification")
        val NOTIFICATION_MINUTES = stringSetPreferencesKey("notification_minutes")
    }

    val settingsFlow: Flow<UserSettings> = context.dataStore.data.map { prefs ->
        UserSettings(
            appTheme = prefs[Keys.APP_THEME]?.let { AppTheme.valueOf(it) } ?: AppTheme.SYSTEM,
            helltideNotificationEnabled = prefs[Keys.HELLTIDE_NOTIFICATION] ?: false,
            legionNotificationEnabled = prefs[Keys.LEGION_NOTIFICATION] ?: false,
            worldBossNotificationEnabled = prefs[Keys.WORLD_BOSS_NOTIFICATION] ?: false,
            notificationMinutesBefore = prefs[Keys.NOTIFICATION_MINUTES]
                ?.map { it.toInt() }?.toSet() ?: setOf(5)
        )
    }

    suspend fun setAppTheme(theme: AppTheme) {
        context.dataStore.edit { it[Keys.APP_THEME] = theme.name }
    }

    suspend fun setHelltideNotification(enabled: Boolean) {
        context.dataStore.edit { it[Keys.HELLTIDE_NOTIFICATION] = enabled }
    }

    suspend fun setLegionNotification(enabled: Boolean) {
        context.dataStore.edit { it[Keys.LEGION_NOTIFICATION] = enabled }
    }

    suspend fun setWorldBossNotification(enabled: Boolean) {
        context.dataStore.edit { it[Keys.WORLD_BOSS_NOTIFICATION] = enabled }
    }

    suspend fun setNotificationMinutes(minutes: Set<Int>) {
        context.dataStore.edit { it[Keys.NOTIFICATION_MINUTES] = minutes.map { m -> m.toString() }.toSet() }
    }

    suspend fun resetToDefaults() {
        context.dataStore.edit { it.clear() }
    }
}
