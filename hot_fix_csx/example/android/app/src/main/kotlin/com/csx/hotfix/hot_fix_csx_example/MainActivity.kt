package com.csx.hotfix.hot_fix_csx_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import tech.brainco.starkidapp.plugin.NormalChannel

class MainActivity: FlutterActivity() {
    private val channelNormalUtil = "hot_fix_csx_example"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, channelNormalUtil).setMethodCallHandler(NormalChannel(this))
    }
}
