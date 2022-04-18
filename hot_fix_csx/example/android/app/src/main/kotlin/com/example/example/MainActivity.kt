package com.example.example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.example.plugin.NormalChannel

class MainActivity: FlutterActivity() {
    private val channelNormalUtil = "hot_fix_csx_example123"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, channelNormalUtil).setMethodCallHandler(NormalChannel(this))
    }
}
