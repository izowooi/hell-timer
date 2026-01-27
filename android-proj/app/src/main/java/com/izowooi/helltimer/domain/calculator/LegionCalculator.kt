package com.izowooi.helltimer.domain.calculator

import com.izowooi.helltimer.domain.model.LegionEvent
import kotlin.math.ceil

object LegionCalculator {

    const val INTERVAL_MINUTES = 25
    const val INTERVAL_SECONDS = 25L * 60  // 1500

    // UTC 기반 고정 앵커 타임스탬프
    const val ANCHOR_TIMESTAMP = 1200L

    // 군단 이벤트 지속 시간 (4분)
    private const val EVENT_DURATION_SECONDS = 4L * 60

    fun getNextEvent(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): LegionEvent {
        val nextEventTime = calculateNextEventTime(currentTimeSeconds)
        val isActive = checkIfActive(nextEventTime, currentTimeSeconds)
        val timeRemaining = maxOf(0L, nextEventTime - currentTimeSeconds)

        return LegionEvent(
            nextEventTime = nextEventTime,
            isActive = isActive,
            timeRemaining = timeRemaining
        )
    }

    private fun calculateNextEventTime(currentTimeSeconds: Long): Long {
        val elapsed = currentTimeSeconds - ANCHOR_TIMESTAMP
        val cyclesPassed = ceil(elapsed.toDouble() / INTERVAL_SECONDS).toLong()
        return ANCHOR_TIMESTAMP + (cyclesPassed * INTERVAL_SECONDS)
    }

    private fun checkIfActive(nextEventTime: Long, currentTimeSeconds: Long): Boolean {
        val previousEventTime = nextEventTime - INTERVAL_SECONDS
        val timeSincePrevious = currentTimeSeconds - previousEventTime
        return timeSincePrevious >= 0 && timeSincePrevious < EVENT_DURATION_SECONDS
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
