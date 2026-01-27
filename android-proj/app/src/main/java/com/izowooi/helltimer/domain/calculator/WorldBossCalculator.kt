package com.izowooi.helltimer.domain.calculator

import com.izowooi.helltimer.domain.model.WorldBossEvent
import kotlin.math.ceil

object WorldBossCalculator {

    const val INTERVAL_MINUTES = 105
    const val INTERVAL_SECONDS = 105L * 60  // 6300

    // UTC 기반 고정 앵커 타임스탬프 (2026-01-06 12:30 UTC = 21:30 KST)
    const val ANCHOR_TIMESTAMP = 1767702600L

    fun getNextEvent(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): WorldBossEvent {
        val nextEventTime = calculateNextEventTime(currentTimeSeconds)
        val timeRemaining = maxOf(0L, nextEventTime - currentTimeSeconds)

        return WorldBossEvent(
            nextEventTime = nextEventTime,
            isActive = false,
            timeRemaining = timeRemaining
        )
    }

    private fun calculateNextEventTime(currentTimeSeconds: Long): Long {
        val elapsed = currentTimeSeconds - ANCHOR_TIMESTAMP
        val cyclesPassed = ceil(elapsed.toDouble() / INTERVAL_SECONDS).toLong()
        return ANCHOR_TIMESTAMP + (cyclesPassed * INTERVAL_SECONDS)
    }

    fun getUpcomingEvents(count: Int, currentTimeSeconds: Long = System.currentTimeMillis() / 1000): List<Long> {
        val events = mutableListOf<Long>()
        var nextEvent = calculateNextEventTime(currentTimeSeconds)

        repeat(count) {
            events.add(nextEvent)
            nextEvent += INTERVAL_SECONDS
        }

        return events
    }

    fun getTimeUntilNext(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): Long {
        val nextEventTime = calculateNextEventTime(currentTimeSeconds)
        return maxOf(0L, nextEventTime - currentTimeSeconds)
    }
}
