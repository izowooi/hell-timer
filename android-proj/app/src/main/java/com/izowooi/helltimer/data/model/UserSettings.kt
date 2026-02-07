package com.izowooi.helltimer.data.model

enum class AppTheme {
    LIGHT, DARK, SYSTEM
}

data class UserSettings(
    val appTheme: AppTheme = AppTheme.SYSTEM,
    val helltideNotificationEnabled: Boolean = false,
    val legionNotificationEnabled: Boolean = false,
    val worldBossNotificationEnabled: Boolean = false,
    val notificationMinutesBefore: Set<Int> = setOf(5)
) {
    val hasAnyNotificationEnabled: Boolean
        get() = helltideNotificationEnabled || legionNotificationEnabled || worldBossNotificationEnabled

    companion object {
        val availableNotificationMinutes = listOf(1, 5, 10, 15, 30)
    }
}
