package com.example.example.plugin

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.*


class NormalChannel(val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "move_base_zip" -> {
                 Thread { //读取与写入
                     setScript("dist.zip", call.arguments as String, activity)
                     activity.runOnUiThread {
                        result.success(1)
                     }
                 }.start()
            }
        }
    }

    fun setScript(assetName: String, targetPath: String, activity: Activity) {
        //读取assets中的文件
        var inputStream: InputStream = activity.baseContext.assets.open(assetName)
        //保存到手机
        val file = File(targetPath)
        val fos = FileOutputStream(file)
        var bytes: ByteArray = ByteArray(1024)
        var byteCount: Int = inputStream.read(bytes)
        while (byteCount !== -1) {
            fos.write(bytes, 0, byteCount)
            byteCount = inputStream.read(bytes)
        }
        fos.flush()
        inputStream.close()
        fos.close()
    }
}