/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 13:39:04
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 16:16:16
 * @Description: 
 */

extension StringRegular on String {
  /*
   * 是否属于网页
   */
  bool isWeb() {
    return this.startsWith(RegExp(r'^(http|ftp|https)://'));
    // return RegExp(
    //         r'(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?')
    //     .hasMatch(this);
  }
}
