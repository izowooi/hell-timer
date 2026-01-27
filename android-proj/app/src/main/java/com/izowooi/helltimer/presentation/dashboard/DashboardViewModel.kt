package com.izowooi.helltimer.presentation.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.izowooi.helltimer.domain.calculator.HelltideCalculator
import com.izowooi.helltimer.domain.calculator.LegionCalculator
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator
import com.izowooi.helltimer.domain.model.GameEvent
import com.izowooi.helltimer.domain.model.HelltideEvent
import com.izowooi.helltimer.domain.model.LegionEvent
import com.izowooi.helltimer.domain.model.WorldBossEvent
import com.izowooi.helltimer.util.TimeFormatter
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class DashboardUiState(
    val helltideEvent: HelltideEvent = HelltideCalculator.getCurrentStatus(),
    val legionEvent: LegionEvent = LegionCalculator.getNextEvent(),
    val worldBossEvent: WorldBossEvent = WorldBossCalculator.getNextEvent(),
    val isLoading: Boolean = false,
    val lastUpdatedText: String = ""
) {
    val activeEvents: List<GameEvent>
        get() = buildList {
            if (helltideEvent.isActive) add(helltideEvent)
            if (legionEvent.isActive) add(legionEvent)
            if (worldBossEvent.isActive) add(worldBossEvent)
        }

    val nextUpcomingEvent: GameEvent?
        get() {
            val events = listOf(helltideEvent, legionEvent, worldBossEvent)
            return events.minByOrNull { it.timeRemaining }
        }
}

class DashboardViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        startTimer()
    }

    private fun startTimer() {
        viewModelScope.launch {
            while (true) {
                updateAllEvents()
                delay(1000L)
            }
        }
    }

    private fun updateAllEvents() {
        val currentTime = System.currentTimeMillis() / 1000

        _uiState.update { state ->
            state.copy(
                helltideEvent = HelltideCalculator.getCurrentStatus(currentTime),
                legionEvent = LegionCalculator.getNextEvent(currentTime),
                worldBossEvent = WorldBossCalculator.getNextEvent(currentTime),
                lastUpdatedText = TimeFormatter.formatCurrentTime()
            )
        }
    }
}
