package com.tlt.flutter_zebra_sdk

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.zebra.sdk.btleComm.BluetoothLeConnection
import com.zebra.sdk.comm.ConnectionException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterZebraSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  // / The MethodChannel that will the communication between Flutter and native Android
  // /
  // / This local reference serves to register the plugin with the Flutter Engine and unregister it
  // / when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private var logTag: String = "ZebraSDK"
  private lateinit var context: Context
  private lateinit var activity: Activity
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_zebra_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {
    val result: MethodResultWrapper = MethodResultWrapper(rawResult)
    Thread(MethodRunner(call, result)).start()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  inner class MethodRunner(call: MethodCall, result: Result) : Runnable {
    private val call: MethodCall = call
    private val result: Result = result

    override fun run() {
      when (call.method) {
        "printZPLOverBluetooth" -> {
          onPrintZplDataOverBluetooth(call, result)
        }
        else -> result.notImplemented()
      }
    }
  }

  class MethodResultWrapper(methodResult: Result) : Result {

    private val methodResult: Result = methodResult
    private val handler: Handler = Handler(Looper.getMainLooper())

    override fun success(result: Any?) {
      handler.post { methodResult.success(result) }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
      handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
    }

    override fun notImplemented() {
      handler.post { methodResult.notImplemented() }
    }
  }

  private fun onPrintZplDataOverBluetooth(@NonNull call: MethodCall, @NonNull result: Result) {
    var macAddress: String? = call.argument("mac")
    var data: String? = call.argument("data")
    Log.d(logTag, "onPrintZplDataOverBluetooth $macAddress $data")
    if (data == null) {
      result.error("onPrintZplDataOverBluetooth", "Data is required", "Data Content")
    }

    var conn: BluetoothLeConnection? = null
    try {
      conn = BluetoothLeConnection(macAddress, context)

      // Open the connection - physical connection is established here.
      conn.open()

      // Send the data to printer as a byte array.
      conn.write(data?.toByteArray())

      Thread.sleep(500)
    } catch (e: Exception) {
      e.printStackTrace()
      result.error("BT_DELIVERY", "Unable to deliver data to the printer $macAddress", e)
    } finally {
      if (null != conn) {
        try {
          conn.close()
        } catch (e: ConnectionException) {
          e.printStackTrace()
          result.error("BT_CONNECTION_CLOSE", "Unable to close Bluetooth connection to $macAddress", e)
          return
        }
      }
      result.success(null)
    }
  }
}
