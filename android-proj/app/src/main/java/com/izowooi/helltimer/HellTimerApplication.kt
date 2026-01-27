package com.izowooi.helltimer

import android.app.Application
import com.izowooi.helltimer.notification.NotificationChannels

class HellTimerApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        NotificationChannels.createAllChannels(this)
    }
}
