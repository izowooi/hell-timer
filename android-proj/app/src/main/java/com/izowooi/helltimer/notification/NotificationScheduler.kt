package com.izowooi.helltimer.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.izowooi.helltimer.domain.calculator.HelltideCalculator
import com.izowooi.helltimer.domain.calculator.LegionCalculator
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator
import com.izowooi.helltimer.domain.model.EventType

class NotificationScheduler(private val context: Context) {

    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun scheduleAllNotifications(minutesBefore: List<Int> = listOf(5)) {
        scheduleWorldBossNotifications(minutesBefore)
        scheduleLegionNotifications(minutesBefore)
        scheduleHelltideNotifications(minutesBefore)
    }

    fun scheduleWorldBossNotifications(minutesBefore: List<Int>) {
        val upcomingEvents = WorldBossCalculator.getUpcomingEvents(5)

        upcomingEvents.forEach { eventTimeSeconds ->
            minutesBefore.forEach { minutes ->
                val notificationTimeMillis = (eventTimeSeconds - minutes * 60) * 1000

                if (notificationTimeMillis > System.currentTimeMillis()) {
                    scheduleAlarm(
                        eventType = EventType.WORLD_BOSS,
                        triggerTimeMillis = notificationTimeMillis,
                        minutesBefore = minutes
                    )
                }
            }
        }
    }

    fun scheduleLegionNotifications(minutesBefore: List<Int>) {
        val upcomingEvents = LegionCalculator.getUpcomingEvents(10)

        upcomingEvents.forEach { eventTimeSeconds ->
            minutesBefore.forEach { minutes ->
                val notificationTimeMillis = (eventTimeSeconds - minutes * 60) * 1000

                if (notificationTimeMillis > System.currentTimeMillis()) {
                    scheduleAlarm(
                        eventType = EventType.LEGION,
                        triggerTimeMillis = notificationTimeMillis,
                        minutesBefore = minutes
                    )
                }
            }
        }
    }

    fun scheduleHelltideNotifications(minutesBefore: List<Int>) {
        val upcomingEvents = HelltideCalculator.getScheduleForNext24Hours()

        upcomingEvents.take(10).forEach { eventTimeSeconds ->
            minutesBefore.forEach { minutes ->
                val notificationTimeMillis = (eventTimeSeconds - minutes * 60) * 1000

                if (notificationTimeMillis > System.currentTimeMillis()) {
                    scheduleAlarm(
                        eventType = EventType.HELLTIDE,
                        triggerTimeMillis = notificationTimeMillis,
                        minutesBefore = minutes
                    )
                }
            }
        }
    }

    private fun scheduleAlarm(
        eventType: EventType,
        triggerTimeMillis: Long,
        minutesBefore: Int
    ) {
        val intent = Intent(context, EventAlarmReceiver::class.java).apply {
            putExtra(EventAlarmReceiver.EXTRA_EVENT_TYPE, eventType.ordinal)
            putExtra(EventAlarmReceiver.EXTRA_MINUTES_BEFORE, minutesBefore)
        }

        val requestCode = (eventType.ordinal * 10000) + (triggerTimeMillis / 1000 % 10000).toInt()

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )
        } catch (e: SecurityException) {
            // Handle case where SCHEDULE_EXACT_ALARM permission is not granted
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                triggerTimeMillis,
                pendingIntent
            )
        }
    }

    fun cancelAllNotifications() {
        // Cancel all pending alarms for each event type
        EventType.entries.forEach { eventType ->
            for (i in 0 until 100) {
                val intent = Intent(context, EventAlarmReceiver::class.java)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    eventType.ordinal * 10000 + i,
                    intent,
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                )
                pendingIntent?.let { alarmManager.cancel(it) }
            }
        }
    }
}
