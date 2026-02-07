package com.izowooi.helltimer.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.work.CoroutineWorker
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
        val hasWidgets = WIDGET_RECEIVERS.any { receiverClass ->
            val component = ComponentName(applicationContext, receiverClass)
            appWidgetManager.getAppWidgetIds(component).isNotEmpty()
        }

        if (!hasWidgets) {
            return Result.success()
        }

        updateAllInstances(applicationContext, WorldBossWidget())
        updateAllInstances(applicationContext, HellTimerWidget())

        enqueue(applicationContext)
        return Result.success()
    }

    private suspend fun updateAllInstances(context: Context, widget: GlanceAppWidget) {
        val manager = GlanceAppWidgetManager(context)
        val glanceIds = manager.getGlanceIds(widget.javaClass)
        glanceIds.forEach { widget.update(context, it) }
    }

    companion object {
        private const val WORK_NAME = "widget_periodic_update"

        private val WIDGET_RECEIVERS = listOf(
            WorldBossWidgetReceiver::class.java,
            WorldBossWidgetLargeReceiver::class.java,
            HellTimerWidgetReceiver::class.java,
            HellTimerWidgetLargeReceiver::class.java
        )

        fun enqueue(context: Context) {
            val request = OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
                .setInitialDelay(60, TimeUnit.SECONDS)
                .build()
            WorkManager.getInstance(context)
                .enqueueUniqueWork(WORK_NAME, ExistingWorkPolicy.KEEP, request)
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        }
    }
}
