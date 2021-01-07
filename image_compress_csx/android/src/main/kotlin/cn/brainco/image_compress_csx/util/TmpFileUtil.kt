package cn.brainco.image_compress_csx.util

import android.content.Context
import java.io.File
import java.util.*

object TmpFileUtil {

  fun createTmpFile(context: Context): File {
    val string = UUID.randomUUID().toString()
    return File(context.cacheDir, string)
  }

}