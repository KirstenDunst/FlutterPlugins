/*
 * @Author: Cao Shixin
 * @Date: 2021-02-18 15:26:26
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:30:16
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

/// 数字工具方法
extension NumExtension on num {
  /* byte转对应字符串显示
   * bytes：最小单位的数量
   * toStringAsFixed：转化过程中的小数保留位数，默认2位小数。
   */
  String byteFormat({int toStringAsFixed = 2}) {
    var result = this;
    if (result < 1024) {
      return '${result.toStringAsFixed(0)}B';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}K';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}M';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}G';
    } else {
      result = result / 1024;
    }
    return '${result.toStringAsFixed(toStringAsFixed)}T';
  }
}
