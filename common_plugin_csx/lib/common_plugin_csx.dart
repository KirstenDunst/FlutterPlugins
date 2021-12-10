/*
 * @Author: Cao Shixin
 * @Date: 2021-12-10 09:13:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-12-10 09:35:33
 * @Description: 
 */
import 'dart:async';

import 'package:flutter/services.dart';

class CommonPluginCsx {
  static const MethodChannel _channel = MethodChannel('common_plugin_csx');

  ///获取文件的md5值
  ///filePath：需要转换md5的文件路径
  static Future<String?> getFileMd5(String filePath) async {
    var md5Str = await _channel.invokeMethod('getFileMd5', filePath);
    return md5Str;
  }
}
