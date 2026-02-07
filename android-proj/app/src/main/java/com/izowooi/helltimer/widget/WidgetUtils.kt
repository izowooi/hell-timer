package com.izowooi.helltimer.widget

import android.content.Context
import android.content.res.Configuration
import android.os.SystemClock
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.compose.ui.graphics.Color
import com.izowooi.helltimer.R
import com.izowooi.helltimer.data.model.AppTheme
import com.izowooi.helltimer.data.repository.SettingsRepository
import kotlinx.coroutines.flow.first

data class WidgetColors(
    val background: Color,
    val text: Color,
    val subtitleText: Color,
    val inactiveTimerText: Color
)

object WidgetUtils {

    val darkColors = WidgetColors(
        background = Color(0xFF1E1E1E),
        text = Color.White,
        subtitleText = Color(0xFFAAAAAA),
        inactiveTimerText = Color.White
    )

    val lightColors = WidgetColors(
        background = Color(0xFFF5F5F5),
        text = Color(0xFF1E1E1E),
        subtitleText = Color(0xFF757575),
        inactiveTimerText = Color(0xFF333333)
    )

    suspend fun isDarkMode(context: Context): Boolean {
        val repository = SettingsRepository(context)
        val settings = repository.settingsFlow.first()
        return when (settings.appTheme) {
            AppTheme.DARK -> true
            AppTheme.LIGHT -> false
            AppTheme.SYSTEM -> {
                val nightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                nightMode == Configuration.UI_MODE_NIGHT_YES
            }
        }
    }

    fun getColors(isDark: Boolean): WidgetColors = if (isDark) darkColors else lightColors

    fun formatInterval(seconds: Long): String {
        val hours = seconds / 3600
        val minutes = (seconds % 3600) / 60
        val secs = seconds % 60

        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, minutes, secs)
        } else {
            String.format("%02d:%02d", minutes, secs)
        }
    }

    fun buildChronometerRemoteViews(
        context: Context,
        remainingSeconds: Long,
        textSizeSp: Float,
        textColor: Int
    ): RemoteViews {
        val rv = RemoteViews(context.packageName, R.layout.widget_chronometer)
        val base = SystemClock.elapsedRealtime() + remainingSeconds * 1000
        rv.setChronometer(R.id.chronometer, base, null, true)
        rv.setChronometerCountDown(R.id.chronometer, true)
        val actualSize = if (remainingSeconds >= 3600) textSizeSp * 0.7f else textSizeSp
        rv.setTextViewTextSize(R.id.chronometer, TypedValue.COMPLEX_UNIT_SP, actualSize)
        rv.setTextColor(R.id.chronometer, textColor)
        return rv
    }

    fun formatTime(epochSeconds: Long): String {
        val date = java.util.Date(epochSeconds * 1000)
        val formatter = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
        return formatter.format(date)
    }
}
