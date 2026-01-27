package com.izowooi.helltimer.domain.model

sealed interface GameEvent {
    val eventType: EventType
    val nextEventTime: Long
    val isActive: Boolean
    val timeRemaining: Long
}

data class HelltideEvent(
    override val nextEventTime: Long,
    override val isActive: Boolean,
    val remainingActiveTime: Long?
) : GameEvent {
    override val eventType: EventType = EventType.HELLTIDE
    override val timeRemaining: Long
        get() = if (isActive && remainingActiveTime != null) {
            remainingActiveTime
        } else {
            maxOf(0L, nextEventTime - System.currentTimeMillis() / 1000)
        }
}

data class LegionEvent(
    override val nextEventTime: Long,
    override val isActive: Boolean,
    override val timeRemaining: Long
) : GameEvent {
    override val eventType: EventType = EventType.LEGION
}

data class WorldBossEvent(
    override val nextEventTime: Long,
    override val isActive: Boolean,
    override val timeRemaining: Long
) : GameEvent {
    override val eventType: EventType = EventType.WORLD_BOSS
}
