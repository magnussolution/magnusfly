package com.magnussolution.magnusfly

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.magnussolution.magnusfly/driver_vario_audio",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playBeep" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val frequencyHz = (arguments?.get("frequencyHz") as? Number)?.toDouble()
                    val durationMs = (arguments?.get("durationMs") as? Number)?.toInt()
                    val volume = (arguments?.get("volume") as? Number)?.toDouble() ?: 0.7
                    if (frequencyHz == null || durationMs == null) {
                        result.error("invalid_arguments", "Invalid beep arguments.", null)
                    } else {
                        DriverVarioTonePlayer.play(frequencyHz, durationMs, volume)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
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

object DriverVarioTonePlayer {
    fun play(frequencyHz: Double, durationMs: Int, volume: Double) {
        Thread {
            val sampleRate = 44100
            val frameCount = (sampleRate * durationMs.coerceAtLeast(30) / 1000.0).toInt()
            val samples = ShortArray(frameCount)
            val amplitude = (Short.MAX_VALUE * volume.coerceIn(0.0, 1.0) * 0.35).toInt()
            val fadeFrames = (sampleRate * 0.006).toInt().coerceAtLeast(1)

            for (frame in samples.indices) {
                val progress = frame.toDouble() / sampleRate.toDouble()
                val fadeIn = (frame.toDouble() / fadeFrames.toDouble()).coerceAtMost(1.0)
                val fadeOut = ((samples.size - frame).toDouble() / fadeFrames.toDouble()).coerceAtMost(1.0)
                val envelope = minOf(fadeIn, fadeOut)
                samples[frame] = (kotlin.math.sin(2.0 * Math.PI * frequencyHz * progress) * amplitude * envelope).toInt().toShort()
            }

            val audioTrack = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(samples.size * 2)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()
            } else {
                @Suppress("DEPRECATION")
                AudioTrack(
                    AudioManager.STREAM_MUSIC,
                    sampleRate,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    samples.size * 2,
                    AudioTrack.MODE_STATIC,
                )
            }

            audioTrack.write(samples, 0, samples.size)
            audioTrack.play()
            Thread.sleep(durationMs.toLong().coerceAtLeast(30))
            audioTrack.stop()
            audioTrack.release()
        }.start()
    }
}
