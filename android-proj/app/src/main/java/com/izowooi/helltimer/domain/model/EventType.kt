package com.izowooi.helltimer.domain.model

import androidx.compose.ui.graphics.Color
import com.izowooi.helltimer.R

enum class EventType(
    val displayNameResId: Int,
    val iconResId: Int,
    val color: Color,
    val intervalSeconds: Long
) {
    HELLTIDE(
        displayNameResId = R.string.event_helltide,
        iconResId = R.drawable.ic_helltide,
        color = Color(0xFFFF4444),
        intervalSeconds = 3600L
    ),
    LEGION(
        displayNameResId = R.string.event_legion,
        iconResId = R.drawable.ic_legion,
        color = Color(0xFF9944FF),
        intervalSeconds = 1500L
    ),
    WORLD_BOSS(
        displayNameResId = R.string.event_world_boss,
        iconResId = R.drawable.ic_worldboss,
        color = Color(0xFFFF8800),
        intervalSeconds = 6300L
    )
}
