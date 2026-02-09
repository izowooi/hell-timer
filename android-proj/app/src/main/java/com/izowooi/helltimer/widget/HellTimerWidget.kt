package com.izowooi.helltimer.widget

import android.content.Context
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.AndroidRemoteViews
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.izowooi.helltimer.MainActivity
import com.izowooi.helltimer.R
import com.izowooi.helltimer.domain.calculator.HelltideCalculator
import com.izowooi.helltimer.domain.calculator.LegionCalculator
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator

class HellTimerWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val isDark = WidgetUtils.isDarkMode(context)
        val colors = WidgetUtils.getColors(isDark)
        val helltideTitle = context.getString(R.string.event_helltide)
        val legionTitle = context.getString(R.string.event_legion)
        val worldBossTitle = context.getString(R.string.event_world_boss)

        provideContent {
            GlanceTheme {
                val size = LocalSize.current
                val isLarge = size.height >= 100.dp
                val currentTime = System.currentTimeMillis() / 1000
                val helltide = HelltideCalculator.getCurrentStatus(currentTime)
                val legion = LegionCalculator.getNextEvent(currentTime)
                val worldBoss = WorldBossCalculator.getNextEvent(currentTime)

                val helltideSeconds = maxOf(0L,
                    if (helltide.isActive) helltide.remainingActiveTime ?: 0L else helltide.timeRemaining
                )
                val timerSizeSp = if (isLarge) 22f else 16f

                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .background(colors.background)
                        .cornerRadius(16.dp)
                        .clickable(actionStartActivity<MainActivity>())
                        .padding(if (isLarge) 16.dp else 12.dp)
                ) {
                    Row(
                        modifier = GlanceModifier.fillMaxSize(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        EventColumn(
                            title = helltideTitle,
                            iconRes = R.drawable.ic_helltide,
                            iconColor = Color(0xFFFF4444),
                            isActive = helltide.isActive,
                            chronometerRv = WidgetUtils.buildChronometerRemoteViews(
                                context, helltideSeconds, timerSizeSp,
                                if (helltide.isActive) Color(0xFFFF4444).toArgb() else colors.inactiveTimerText.toArgb()
                            ),
                            nextTimeText = if (isLarge) WidgetUtils.formatTime(helltide.nextEventTime) else null,
                            isLarge = isLarge,
                            colors = colors,
                            modifier = GlanceModifier.defaultWeight()
                        )

                        EventColumn(
                            title = legionTitle,
                            iconRes = R.drawable.ic_legion,
                            iconColor = Color(0xFF9944FF),
                            isActive = legion.isActive,
                            chronometerRv = WidgetUtils.buildChronometerRemoteViews(
                                context, legion.timeRemaining, timerSizeSp,
                                if (legion.isActive) Color(0xFF9944FF).toArgb() else colors.inactiveTimerText.toArgb()
                            ),
                            nextTimeText = if (isLarge) WidgetUtils.formatTime(legion.nextEventTime) else null,
                            isLarge = isLarge,
                            colors = colors,
                            modifier = GlanceModifier.defaultWeight()
                        )

                        EventColumn(
                            title = worldBossTitle,
                            iconRes = R.drawable.ic_worldboss,
                            iconColor = Color(0xFFFF8800),
                            isActive = worldBoss.isActive,
                            chronometerRv = WidgetUtils.buildChronometerRemoteViews(
                                context, worldBoss.timeRemaining, timerSizeSp,
                                if (worldBoss.isActive) Color(0xFFFF8800).toArgb() else colors.inactiveTimerText.toArgb()
                            ),
                            nextTimeText = if (isLarge) WidgetUtils.formatTime(worldBoss.nextEventTime) else null,
                            isLarge = isLarge,
                            colors = colors,
                            modifier = GlanceModifier.defaultWeight()
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun EventColumn(
        title: String,
        iconRes: Int,
        iconColor: Color,
        isActive: Boolean,
        chronometerRv: RemoteViews,
        nextTimeText: String?,
        isLarge: Boolean,
        colors: WidgetColors,
        modifier: GlanceModifier = GlanceModifier
    ) {
        Column(
            modifier = modifier.padding(horizontal = 4.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(if (isLarge) 32.dp else 24.dp),
                colorFilter = ColorFilter.tint(ColorProvider(iconColor))
            )

            Spacer(modifier = GlanceModifier.height(4.dp))

            Text(
                text = title,
                style = TextStyle(
                    fontSize = if (isLarge) 13.sp else 10.sp,
                    color = ColorProvider(colors.text)
                )
            )

            if (isActive) {
                Text(
                    text = "LIVE",
                    style = TextStyle(
                        fontSize = if (isLarge) 11.sp else 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(Color(0xFF4CAF50))
                    )
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            AndroidRemoteViews(remoteViews = chronometerRv)

            if (nextTimeText != null) {
                Text(
                    text = nextTimeText,
                    style = TextStyle(
                        fontSize = 11.sp,
                        color = ColorProvider(colors.subtitleText)
                    )
                )
            }
        }
    }
}
