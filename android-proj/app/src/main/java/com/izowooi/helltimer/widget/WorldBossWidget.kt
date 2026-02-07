package com.izowooi.helltimer.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
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
import com.izowooi.helltimer.domain.calculator.WorldBossCalculator

class WorldBossWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                val currentTime = System.currentTimeMillis() / 1000
                val worldBoss = WorldBossCalculator.getNextEvent(currentTime)

                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .background(Color(0xFF1E1E1E))
                        .cornerRadius(16.dp)
                        .clickable(actionStartActivity<MainActivity>())
                        .padding(12.dp)
                ) {
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
                            text = WidgetUtils.formatInterval(worldBoss.timeRemaining),
                            style = TextStyle(
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Bold,
                                fontFamily = FontFamily.Monospace,
                                color = ColorProvider(Color(0xFFFF8800))
                            )
                        )

                        Text(
                            text = WidgetUtils.formatTime(worldBoss.nextEventTime),
                            style = TextStyle(
                                fontSize = 11.sp,
                                color = ColorProvider(Color(0xFFAAAAAA))
                            )
                        )
                    }
                }
            }
        }
    }
}
