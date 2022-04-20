package com.csx.hotfix.hot_fix_csx

import CommonTool
import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** HotFixCsxPlugin */
class HotFixCsxPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hot_fix_csx")
        applicationContext = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "move_resource" -> {
                val resourseName = call.argument<String>("resourseName") ?: ""
                val targetPath = call.argument<String>("targetPath") ?: ""
                Thread { //读取与写入
                    CommonTool().copyResourceToLocal(applicationContext, resourseName, targetPath)
                    activity.runOnUiThread {
                        result.success(true)
                    }
                }.start()
            }
            "unzip_resource" -> {
                val resourseName = call.argument<String>("resourseName") ?: ""
                val targetPath = call.argument<String>("targetDirectPath") ?: ""
                Thread {
                    CommonTool().unzip(applicationContext, resourseName, targetPath)
                    activity.runOnUiThread {
                        result.success(true)
                    }
                }.start()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(p0: ActivityPluginBinding) {
        activity = p0.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
        activity = p0.activity;
    }

    override fun onDetachedFromActivity() {

    }
}
