package com.magnussolution.magnusfly

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import io.flutter.plugin.common.EventChannel

object PilotForegroundBridge {
    private var eventSink: EventChannel.EventSink? = null

    @Volatile
    var isRunning: Boolean = false
        private set

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun markRunning(running: Boolean) {
        isRunning = running
    }

    fun sendSample(pressureHpa: Double, relativeAltitudeMeters: Double) {
        eventSink?.success(
            mapOf(
                "pressureHpa" to pressureHpa,
                "relativeAltitudeMeters" to relativeAltitudeMeters,
                "timestampMillis" to System.currentTimeMillis(),
            )
        )
    }
}

class PilotForegroundService : Service(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var pressureSensor: Sensor? = null
    private var baselineAltitudeMeters: Float? = null

    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        pressureSensor = sensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(notificationId, buildNotification())
        PilotForegroundBridge.markRunning(true)

        pressureSensor?.let { sensor ->
            sensorManager.registerListener(
                this,
                sensor,
                SensorManager.SENSOR_DELAY_NORMAL,
            )
        } ?: stopSelf()

        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        baselineAltitudeMeters = null
        PilotForegroundBridge.markRunning(false)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_PRESSURE) {
            return
        }

        val pressureHpa = event.values.first()
        val altitudeMeters = SensorManager.getAltitude(
            SensorManager.PRESSURE_STANDARD_ATMOSPHERE,
            pressureHpa,
        )
        val baseline = baselineAltitudeMeters ?: altitudeMeters.also {
            baselineAltitudeMeters = it
        }

        PilotForegroundBridge.sendSample(
            pressureHpa = pressureHpa.toDouble(),
            relativeAltitudeMeters = (altitudeMeters - baseline).toDouble(),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun buildNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, notificationChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(getString(R.string.pilot_service_notification_title))
            .setContentText(getString(R.string.pilot_service_notification_text))
            .setOngoing(true)
            .setPriority(Notification.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(
            notificationChannelId,
            getString(R.string.pilot_service_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        )
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }

    companion object {
        private const val notificationChannelId = "magnusfly_pilot_service"
        private const val notificationId = 1001
    }
}
