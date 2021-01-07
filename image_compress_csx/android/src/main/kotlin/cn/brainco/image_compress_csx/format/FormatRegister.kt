package cn.brainco.image_compress_csx.format

import android.util.SparseArray
import cn.brainco.image_compress_csx.handle.FormatHandler

object FormatRegister {

  private val formatMap = SparseArray<FormatHandler>()

  fun registerFormat(handler: FormatHandler) {
    formatMap.append(handler.type, handler)
  }

  fun findFormat(formatIndex: Int): FormatHandler? {
    return formatMap.get(formatIndex)
  }


}