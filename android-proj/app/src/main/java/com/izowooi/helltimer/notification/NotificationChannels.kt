package com.izowooi.helltimer.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.core.app.NotificationManagerCompat
import com.izowooi.helltimer.R

object NotificationChannels {

    const val HELLTIDE_CHANNEL_ID = "helltide_channel"
    const val LEGION_CHANNEL_ID = "legion_channel"
    const val WORLD_BOSS_CHANNEL_ID = "worldboss_channel"

    fun createAllChannels(context: Context) {
        val notificationManager = NotificationManagerCompat.from(context)

        val helltideChannel = NotificationChannel(
            HELLTIDE_CHANNEL_ID,
            context.getString(R.string.notification_channel_helltide),
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = context.getString(R.string.notification_channel_helltide_desc)
        }

        val legionChannel = NotificationChannel(
            LEGION_CHANNEL_ID,
            context.getString(R.string.notification_channel_legion),
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = context.getString(R.string.notification_channel_legion_desc)
        }

        val worldBossChannel = NotificationChannel(
            WORLD_BOSS_CHANNEL_ID,
            context.getString(R.string.notification_channel_worldboss),
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = context.getString(R.string.notification_channel_worldboss_desc)
        }

        notificationManager.createNotificationChannels(
            listOf(helltideChannel, legionChannel, worldBossChannel)
        )
    }
}
