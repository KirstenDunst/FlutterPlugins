/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 13:39:52
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 13:43:03
 * @Description: 
 */
class ByteUtil {
  /* byte转对应字符串显示
   * bytes：最小单位的数量
   * toStringAsFixed：转化过程中的小数保留位数，默认2位小数。
   */
  static String toByteString(int bytes, {int toStringAsFixed = 2}) {
    if (bytes <= 1024) {
      return '${bytes}B';
    } else if (bytes <= 1024 * 1024) {
      return '${(bytes / (1024)).toStringAsFixed(toStringAsFixed)}K';
    } else if (bytes <= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}M';
    } else if (bytes <= 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}G';
    } else {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}T';
    }
  }
}
