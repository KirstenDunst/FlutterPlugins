package com.example.doraemonkit_csx

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import java.io.IOException

/** DoraemonkitCsxPlugin */
class DoraemonkitCsxPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "doraemonkit_csx")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "openDeveloperOptions") {
            CommonTool.startDevelopmentActivity(context);
        } else if (call.method == "openLocalLanguagesPage") {
            CommonTool.startLocalActivity(context);
        }  else if (call.method == "getUserDefaults") {
            try {
                val data = SharedPreferencesPlugin.getUserDefaults(context)
                result.success(data)
            } catch (e: IOException) {
                result.success(HashMap<String, Any?>())
            }
        } else if (call.method == "setUserDefault") {
            val arguments = call.arguments as? HashMap<String, Any?>
            if (arguments != null) {
                SharedPreferencesPlugin.setUserDefault(
                    context,
                    arguments
                )
            } 
        } else {
            result.notImplemented();
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
