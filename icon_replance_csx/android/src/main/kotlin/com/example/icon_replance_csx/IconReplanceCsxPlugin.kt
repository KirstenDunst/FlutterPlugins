package com.example.icon_replance_csx

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.lifecycle.DefaultLifecycleObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result as Result1
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner


/** IconReplanceCsxPlugin */
class IconReplanceCsxPlugin : FlutterPlugin, MethodCallHandler, DefaultLifecycleObserver {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var changeIconParam: Map<*, *>? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "icon_replance_csx")
        this.applicationContext = flutterPluginBinding.applicationContext;
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result1) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "changeIcon") {
            val argument = call.arguments as Map<*, *>?
            changeIconParam = argument
            val changeNow = argument?.get("changeNow") as Boolean?
            if (changeNow == true) {
                dealChangeIcon()
            }
            result.success(mapOf("isSuccess" to true))
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        dealChangeIcon()
    }

    private fun dealChangeIcon() {
        if (changeIconParam != null) {
            var needSetIcon = changeIconParam?.get("iconName") as String?
            val aliasNames = changeIconParam?.get("aliasNames") as List<*>?
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
            changeIconParam = null
        }
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

