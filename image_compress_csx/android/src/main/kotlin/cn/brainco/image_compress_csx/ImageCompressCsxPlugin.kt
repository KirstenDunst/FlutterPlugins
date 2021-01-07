package cn.brainco.image_compress_csx

import android.content.Context
import android.os.Build
import cn.brainco.image_compress_csx.core.CompressFileHandler
import cn.brainco.image_compress_csx.core.CompressListHandler
import cn.brainco.image_compress_csx.format.FormatRegister
import cn.brainco.image_compress_csx.handle.common.CommonHandler
import cn.brainco.image_compress_csx.handle.heif.HeifHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class ImageCompressCsxPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var context: Context
  var channel: MethodChannel? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val plugin = ImageCompressCsxPlugin()
      plugin.channel = MethodChannel(registrar.messenger(), "image_compress_csx")
      plugin.context = registrar.context()
      plugin.channel?.setMethodCallHandler(plugin)
    }

    var showLog = false
  }

  init {
    FormatRegister.registerFormat(CommonHandler(0)) // jpeg
    FormatRegister.registerFormat(CommonHandler(1)) // png
    FormatRegister.registerFormat(HeifHandler()) // heic / heif
    FormatRegister.registerFormat(CommonHandler(3)) // webp
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    when (call.method) {
      "showLog" -> result.success(handleLog(call))
      "compressWithList" -> CompressListHandler(call, result).handle(context)
      "compressWithFile" -> CompressFileHandler(call, result).handle(context)
      "compressWithFileAndGetFile" -> CompressFileHandler(call, result).handleGetFile(context)
      "getSystemVersion" -> result.success(Build.VERSION.SDK_INT)
      else -> result.notImplemented()
    }
  }

  private fun handleLog(call: MethodCall): Int {
    val arg = call.arguments<Boolean>()
    showLog = (arg == true)
    return 1
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    this.context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "image_compress_csx")
    channel?.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

}
