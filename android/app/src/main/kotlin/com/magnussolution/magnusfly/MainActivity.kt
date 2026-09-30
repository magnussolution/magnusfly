package com.magnussolution.magnusfly

import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.magnussolution.magnusfly/pilot_background",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> result.success(isPressureSensorAvailable())
                "isRunning" -> result.success(PilotForegroundBridge.isRunning)
                "start" -> {
                    startPilotForegroundService()
                    result.success(null)
                }
                "stop" -> {
                    stopService(Intent(this, PilotForegroundService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.magnussolution.magnusfly/pilot_barometer",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                PilotForegroundBridge.setEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                PilotForegroundBridge.setEventSink(null)
            }
        })
    }

    private fun isPressureSensorAvailable(): Boolean {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return sensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE) != null
    }

    private fun startPilotForegroundService() {
        val intent = Intent(this, PilotForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
}
