/*
 * @Author: Cao Shixin
 * @Date: 2021-06-26 18:10:15
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-24 10:50:39
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';
import 'package:common_plugin_csx/common_plugin_csx.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class Md5Helper {
  /// 获取文件的md5
  static Future<String?> getFileMd5(String path) async {
    if (path.isNotEmpty && await File(path).exists()) {
      var result = await CommonPluginCsx.getFileMd5(path);
      return result;
    } else {
      return null;
    }
  }

  /// 处理字符串的md5值
  static String? getStringMd5(String string) {
    if (string.isNotEmpty) {
      var content = const Utf8Encoder().convert(string);
      var digest = md5.convert(content);
      return hex.encode(digest.bytes);
    } else {
      return null;
    }
  }
}
