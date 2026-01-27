package com.izowooi.helltimer.util

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object TimeFormatter {

    fun formatInterval(seconds: Long): String {
        val hours = seconds / 3600
        val minutes = (seconds % 3600) / 60
        val secs = seconds % 60

        return if (hours > 0) {
            String.format(Locale.getDefault(), "%d:%02d:%02d", hours, minutes, secs)
        } else {
            String.format(Locale.getDefault(), "%02d:%02d", minutes, secs)
        }
    }

    fun formatTime(epochSeconds: Long): String {
        val date = Date(epochSeconds * 1000)
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        return formatter.format(date)
    }

    fun formatDateTime(epochSeconds: Long): String {
        val date = Date(epochSeconds * 1000)
        val formatter = SimpleDateFormat("MM/dd HH:mm", Locale.getDefault())
        return formatter.format(date)
    }

    fun formatCurrentTime(): String {
        val formatter = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        return formatter.format(Date())
    }
}
