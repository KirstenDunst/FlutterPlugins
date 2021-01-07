package cn.brainco.image_compress_csx.logger

import android.util.Log
import cn.brainco.image_compress_csx.ImageCompressCsxPlugin

fun Any.log(any: Any?) {
  if (ImageCompressCsxPlugin.showLog) {
    Log.i("image_compress_csx", any?.toString() ?: "null")
  }
}