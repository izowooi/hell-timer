package com.izowooi.helltimer.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.glance.appwidget.GlanceAppWidgetManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class WidgetRefreshReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val pendingResult = goAsync()
        CoroutineScope(Dispatchers.Default).launch {
            try {
                val manager = GlanceAppWidgetManager(context)

                for (id in manager.getGlanceIds(WorldBossWidget::class.java)) {
                    WorldBossWidget().update(context, id)
                }
                for (id in manager.getGlanceIds(HellTimerWidget::class.java)) {
                    HellTimerWidget().update(context, id)
                }

                WidgetRefreshScheduler.scheduleNextRefresh(context)
            } finally {
                pendingResult.finish()
            }
        }
    }
}
