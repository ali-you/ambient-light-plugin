package com.aliyou.ambient_light

import android.app.Activity
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

/** AmbientLightPlugin */
class AmbientLightPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, SensorEventListener {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var sensorManager: SensorManager? = null
  private var lightSensor: Sensor? = null
  private var activity: Activity? = null
  private var result: Result? = null
  private var eventSink: EventSink? = null
  private var lastLux: Float? = null
  private var isListeningForResult: Boolean = false

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "ambient_light.aliyou.dev")
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "ambient_light_stream.aliyou.dev")
    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(object : StreamHandler {
      override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
        startListening()
      }

      override fun onCancel(arguments: Any?) {
        stopListening()
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getAmbientLight") {
      if (isListeningForResult) {
        result.error("IN_PROGRESS", "Another ambient light request is in progress", null)
      } else {
        this.result = result
        if (lastLux != null) {
          result.success(lastLux)
        } else {
          startListeningForResult()
        }
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    sensorManager = activity?.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  private fun startListeningForResult() {
    if (lightSensor == null) {
      result?.error("NO_SENSOR", "No ambient light sensor found", null)
      return
    }
    isListeningForResult = true
    sensorManager?.registerListener(this, lightSensor, SensorManager.SENSOR_DELAY_NORMAL)
  }

  private fun startListening() {
    if (lightSensor == null) {
      eventSink?.error("NO_SENSOR", "No ambient light sensor found", null)
      return
    }
    sensorManager?.registerListener(this, lightSensor, SensorManager.SENSOR_DELAY_NORMAL)
  }

  private fun stopListening() {
    sensorManager?.unregisterListener(this)
    lastLux = null
    isListeningForResult = false
  }

  override fun onSensorChanged(event: SensorEvent?) {
    if (event?.sensor?.type == Sensor.TYPE_LIGHT) {
      val lux = event.values[0]
      lastLux = lux
      if (result != null && isListeningForResult) {
        result?.success(lux)
        result = null
        isListeningForResult = false
        stopListening()
      } else {
        eventSink?.success(lux)
      }
    }
  }

  override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
