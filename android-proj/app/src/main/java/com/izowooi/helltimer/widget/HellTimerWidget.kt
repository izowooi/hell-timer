package com.izowooi.helltimer.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import android.util.SizeF
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontFamily
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.izowooi.helltimer.MainActivity
import com.izowooi.helltimer.R
import com.izowooi.helltimer.domain.calculator.HelltideCalculator
import com.izowooi.helltimer.domain.calculator.LegionCalculator
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator
import com.izowooi.helltimer.domain.model.HelltideEvent
import com.izowooi.helltimer.domain.model.LegionEvent
import com.izowooi.helltimer.domain.model.WorldBossEvent
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.ColorFilter

class HellTimerWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                WidgetContent()
            }
        }
    }

    @Composable
    private fun WidgetContent() {
        val size = LocalSize.current
        val currentTime = System.currentTimeMillis() / 1000

        val helltide = HelltideCalculator.getCurrentStatus(currentTime)
        val legion = LegionCalculator.getNextEvent(currentTime)
        val worldBoss = WorldBossCalculator.getNextEvent(currentTime)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color(0xFF1E1E1E))
                .cornerRadius(16.dp)
                .clickable(actionStartActivity<MainActivity>())
                .padding(12.dp)
        ) {
            if (size.width < 200.dp) {
                SmallWidgetContent(worldBoss = worldBoss)
            } else {
                MediumWidgetContent(
                    helltide = helltide,
                    legion = legion,
                    worldBoss = worldBoss
                )
            }
        }
    }

    @Composable
    private fun SmallWidgetContent(worldBoss: WorldBossEvent) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.Top
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Image(
                    provider = ImageProvider(R.drawable.ic_worldboss),
                    contentDescription = null,
                    modifier = GlanceModifier.size(20.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(Color(0xFFFF8800)))
                )
                Spacer(modifier = GlanceModifier.width(4.dp))
                Text(
                    text = "World Boss",
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = ColorProvider(Color.White)
                    )
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            Text(
                text = formatInterval(worldBoss.timeRemaining),
                style = TextStyle(
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace,
                    color = ColorProvider(Color(0xFFFF8800))
                )
            )

            Text(
                text = formatTime(worldBoss.nextEventTime),
                style = TextStyle(
                    fontSize = 11.sp,
                    color = ColorProvider(Color(0xFFAAAAAA))
                )
            )
        }
    }

    @Composable
    private fun MediumWidgetContent(
        helltide: HelltideEvent,
        legion: LegionEvent,
        worldBoss: WorldBossEvent
    ) {
        Row(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            EventColumn(
                title = "Helltide",
                iconRes = R.drawable.ic_helltide,
                iconColor = Color(0xFFFF4444),
                isActive = helltide.isActive,
                timeText = formatInterval(
                    if (helltide.isActive) helltide.remainingActiveTime ?: 0L
                    else helltide.timeRemaining
                ),
                modifier = GlanceModifier.defaultWeight()
            )

            EventColumn(
                title = "Legion",
                iconRes = R.drawable.ic_legion,
                iconColor = Color(0xFF9944FF),
                isActive = legion.isActive,
                timeText = formatInterval(legion.timeRemaining),
                modifier = GlanceModifier.defaultWeight()
            )

            EventColumn(
                title = "World Boss",
                iconRes = R.drawable.ic_worldboss,
                iconColor = Color(0xFFFF8800),
                isActive = worldBoss.isActive,
                timeText = formatInterval(worldBoss.timeRemaining),
                modifier = GlanceModifier.defaultWeight()
            )
        }
    }

    @Composable
    private fun EventColumn(
        title: String,
        iconRes: Int,
        iconColor: Color,
        isActive: Boolean,
        timeText: String,
        modifier: GlanceModifier = GlanceModifier
    ) {
        Column(
            modifier = modifier.padding(horizontal = 4.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(24.dp),
                colorFilter = ColorFilter.tint(ColorProvider(iconColor))
            )

            Spacer(modifier = GlanceModifier.height(4.dp))

            Text(
                text = title,
                style = TextStyle(
                    fontSize = 10.sp,
                    color = ColorProvider(Color.White)
                )
            )

            if (isActive) {
                Text(
                    text = "LIVE",
                    style = TextStyle(
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(Color(0xFF4CAF50))
                    )
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            Text(
                text = timeText,
                style = TextStyle(
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace,
                    color = ColorProvider(if (isActive) iconColor else Color.White)
                )
            )
        }
    }

    private fun formatInterval(seconds: Long): String {
        val hours = seconds / 3600
        val minutes = (seconds % 3600) / 60
        val secs = seconds % 60

        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, minutes, secs)
        } else {
            String.format("%02d:%02d", minutes, secs)
        }
    }

    private fun formatTime(epochSeconds: Long): String {
        val date = java.util.Date(epochSeconds * 1000)
        val formatter = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
        return formatter.format(date)
    }
}
