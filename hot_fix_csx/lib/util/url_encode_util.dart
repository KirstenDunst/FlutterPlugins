/*
 * @Author: Cao Shixin
 * @Date: 2022-04-19 14:41:12
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 14:44:30
 * @Description: 
 */
class UrlEncodeUtil {
  /// 针对url的编码，将url中的中文转换成urlencode之后的一个新的url
  /// 如果url没有中文，返回的文本和之前的一致
  static String urlEncode(String originStr) {
    var tempStr = '';
    for (var i = 0; i < originStr.length; i++) {
      var nowStr = originStr.substring(i, i + 1);
      //正则匹配中文
      if (RegExp(r'[\u4E00-\u9FA5]').hasMatch(nowStr)) {
        tempStr += Uri.encodeComponent(nowStr);
      } else {
        tempStr += nowStr;
      }
    }
    return tempStr;
  }
}
