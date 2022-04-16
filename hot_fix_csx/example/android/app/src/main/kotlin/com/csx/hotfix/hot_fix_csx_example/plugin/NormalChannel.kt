package com.csx.hotfix.hot_fix_csx_example.plugin

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.*
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import tech.brainco.starkidapp.R


class NormalChannel(val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "move_base_zip" -> {
                var inputStream = assets.open("www.zip")
                var outputStream = FileOutputStream(CacheUtils.getExternalStorageDirectory() + "www.zip")
                var byteArray = ByteArray(512)
                while (inputStream.read(byteArray) != -1) {
                    outputStream.write(byteArray)
                }
                outputStream.flush()
                outputStream.close()
                inputStream.close()
                // val zipName = call.argument<String>("zipName") ?: ""
                // val targetPath = call.argument<String>("targetPath") ?: ""
                // Thread {
                //     ZipUtils().unzip(activity, targetPath)
                //     activity.runOnUiThread {
                //         result.success(true)
                //     }
                // }.start()
            }
        }
    }
}