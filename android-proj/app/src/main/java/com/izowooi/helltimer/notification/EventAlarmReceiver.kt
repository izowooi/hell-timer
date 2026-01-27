package com.izowooi.helltimer.notification

import android.Manifest
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.izowooi.helltimer.MainActivity
import com.izowooi.helltimer.R
import com.izowooi.helltimer.domain.model.EventType

class EventAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_EVENT_TYPE = "event_type"
        const val EXTRA_MINUTES_BEFORE = "minutes_before"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val eventTypeOrdinal = intent.getIntExtra(EXTRA_EVENT_TYPE, 0)
        val minutesBefore = intent.getIntExtra(EXTRA_MINUTES_BEFORE, 5)

        val eventType = EventType.entries[eventTypeOrdinal]

        val channelId = when (eventType) {
            EventType.HELLTIDE -> NotificationChannels.HELLTIDE_CHANNEL_ID
            EventType.LEGION -> NotificationChannels.LEGION_CHANNEL_ID
            EventType.WORLD_BOSS -> NotificationChannels.WORLD_BOSS_CHANNEL_ID
        }

        val title = context.getString(eventType.displayNameResId)
        val body = if (minutesBefore == 0) {
            context.getString(R.string.notification_starts_now)
        } else {
            context.getString(R.string.notification_starts_in_minutes, minutesBefore)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(eventType.iconResId)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            NotificationManagerCompat.from(context)
                .notify(eventType.ordinal * 100 + minutesBefore, notification)
        }
    }
}
