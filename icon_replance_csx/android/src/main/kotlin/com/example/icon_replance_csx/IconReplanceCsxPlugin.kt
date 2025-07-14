package com.example.icon_replance_csx

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result as Result1


/** IconReplanceCsxPlugin */
class IconReplanceCsxPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "icon_replance_csx")
        this.applicationContext = flutterPluginBinding.applicationContext;
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result1) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "changeIcon") {
            val argument = call.arguments as Map<*, *>?
            var needSetIcon = argument?.get("iconName") as String?
            val aliasNames = argument?.get("aliasNames") as List<*>?
            if (needSetIcon == null && !aliasNames.isNullOrEmpty()) {
                needSetIcon = aliasNames[0] as String
            }
            if (aliasNames != null) {
                for (e in aliasNames) {
                    if (e != needSetIcon) {
                        disableComponent(e as String)
                    }
                }
            }
            if (!needSetIcon.isNullOrEmpty()) {
                enableComponent(needSetIcon)
            }
            result.success(mapOf("isSuccess" to true))
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    private fun enableComponent(componentName: String) {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(
                applicationContext,
                applicationContext.packageName + '.' + componentName
            ),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun disableComponent(componentName: String) {
        applicationContext.packageManager.setComponentEnabledSetting(
            ComponentName(
                applicationContext,
                applicationContext.packageName + '.' + componentName
            ),
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
    }
}
