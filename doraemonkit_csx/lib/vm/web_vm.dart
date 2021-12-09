/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:44:07
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:19:27
 * @Description: 
 */
import 'package:shared_preferences/shared_preferences.dart';

class WebVM {
  //搜索保存本地的key值
  static const String urlSearchHis = 'Dokit.web.search';
  /*
   * 获取搜索历史
   */
  static Future<List<String>> getLocalWebSearchList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tempArr = prefs.getStringList(urlSearchHis) ?? <String>[];
    return tempArr;
  }

  /*
   * 添加搜索历史,最多十条
   */
  static Future<bool> addSearchList(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tempArr = prefs.getStringList(urlSearchHis) ?? <String>[];
    if (tempArr.contains(url)) {
      tempArr.remove(url);
    }
    tempArr.insert(0, url);
    if (tempArr.length > 10) {
      tempArr.removeLast();
    }
    bool result = await prefs.setStringList(urlSearchHis, tempArr);
    return result;
  }

  /*
   * 清除搜索历史
   */
  static Future<bool> delectSearchList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.remove(urlSearchHis);
    return result;
  }
}
