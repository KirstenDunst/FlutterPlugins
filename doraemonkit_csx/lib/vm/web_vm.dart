/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 11:44:07
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 15:19:27
 * @Description: 
 */
import 'dart:convert';

import '../utils/shared_prefer_util.dart';

class WebVM {
  //搜索保存本地的key值
  static const String urlSearchHis = 'Dokit.web.search';
  /*
   * 获取搜索历史
   */
  static Future<List<String>> getLocalWebSearchList() async {
    var result = await SPService.instance.get(urlSearchHis, '');
    if (result.isEmpty) {
      return <String>[];
    } else {
      return jsonDecode(result).cast<String>();
    }
  }

  /*
   * 添加搜索历史,最多十条
   */
  static Future<bool> addSearchList(String url) async {
    var tempArr = await getLocalWebSearchList();
    if (tempArr.contains(url)) {
      tempArr.remove(url);
    }
    tempArr.insert(0, url);
    if (tempArr.length > 10) {
      tempArr.removeLast();
    }
    bool result =
        await SPService.instance.set(urlSearchHis, jsonEncode(tempArr));
    return result;
  }

  /*
   * 清除搜索历史
   */
  static Future<bool> delectSearchList() async {
    var result = await SPService.instance.remove(urlSearchHis);
    return result;
  }
}
