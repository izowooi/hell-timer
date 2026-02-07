package com.izowooi.helltimer.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.izowooi.helltimer.domain.calculator.HelltideCalculator
import com.izowooi.helltimer.domain.calculator.LegionCalculator
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator

object WidgetRefreshScheduler {

    private const val REQUEST_CODE = 99999

    fun scheduleNextRefresh(context: Context) {
        val currentTime = System.currentTimeMillis() / 1000

        val nextTimes = mutableListOf<Long>()

        // Helltide: next activation or next deactivation
        val helltide = HelltideCalculator.getCurrentStatus(currentTime)
        if (helltide.isActive && helltide.remainingActiveTime != null) {
            nextTimes.add(currentTime + helltide.remainingActiveTime)
        }
        nextTimes.add(helltide.nextEventTime)

        // Legion: next event start
        nextTimes.add(LegionCalculator.getNextEvent(currentTime).nextEventTime)

        // WorldBoss: next event start
        nextTimes.add(WorldBossCalculator.getNextEvent(currentTime).nextEventTime)

        val nextRefreshEpoch = nextTimes.filter { it > currentTime }.minOrNull() ?: return

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, WidgetRefreshReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                nextRefreshEpoch * 1000,
                pendingIntent
            )
        } catch (e: SecurityException) {
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                nextRefreshEpoch * 1000,
                pendingIntent
            )
        }
    }
}
