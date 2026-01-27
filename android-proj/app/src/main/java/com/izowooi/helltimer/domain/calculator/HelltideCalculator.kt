package com.izowooi.helltimer.domain.calculator

import com.izowooi.helltimer.domain.model.HelltideEvent
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime

object HelltideCalculator {

    // 지옥물결 활성 시간 (55분)
    const val ACTIVE_DURATION_MINUTES = 55

    // 지옥물결 휴식 시간 (5분)
    const val BREAK_DURATION_MINUTES = 5

    fun getCurrentStatus(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): HelltideEvent {
        val zonedDateTime = ZonedDateTime.ofInstant(
            Instant.ofEpochSecond(currentTimeSeconds),
            ZoneId.systemDefault()
        )
        val minutes = zonedDateTime.minute
        val seconds = zonedDateTime.second

        return if (minutes < ACTIVE_DURATION_MINUTES) {
            // 활성 상태 (0~54분)
            val remainingMinutes = ACTIVE_DURATION_MINUTES - 1 - minutes
            val remainingSeconds = 60 - seconds
            val remainingTime = (remainingMinutes * 60L + remainingSeconds)

            val nextStart = getNextHourStart(currentTimeSeconds)

            HelltideEvent(
                nextEventTime = nextStart,
                isActive = true,
                remainingActiveTime = remainingTime
            )
        } else {
            // 휴식 상태 (55~59분)
            val nextStart = getNextHourStart(currentTimeSeconds)

            HelltideEvent(
                nextEventTime = nextStart,
                isActive = false,
                remainingActiveTime = null
            )
        }
    }

    private fun getNextHourStart(currentTimeSeconds: Long): Long {
        val zonedDateTime = ZonedDateTime.ofInstant(
            Instant.ofEpochSecond(currentTimeSeconds),
            ZoneId.systemDefault()
        )

        val nextHour = zonedDateTime
            .withMinute(0)
            .withSecond(0)
            .withNano(0)
            .plusHours(1)

        return nextHour.toEpochSecond()
    }

    fun isActive(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): Boolean {
        val zonedDateTime = ZonedDateTime.ofInstant(
            Instant.ofEpochSecond(currentTimeSeconds),
            ZoneId.systemDefault()
        )
        return zonedDateTime.minute < ACTIVE_DURATION_MINUTES
    }

    fun getTimeUntilNextStart(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): Long? {
        if (isActive(currentTimeSeconds)) return null
        return getNextHourStart(currentTimeSeconds) - currentTimeSeconds
    }

    fun getScheduleForNext24Hours(currentTimeSeconds: Long = System.currentTimeMillis() / 1000): List<Long> {
        val events = mutableListOf<Long>()
        var nextStart = getNextHourStart(currentTimeSeconds)

        repeat(24) {
            events.add(nextStart)
            nextStart += 3600L
        }

        return events
    }
}
