/*
 * @Author: Cao Shixin
 * @Date: 2021-06-26 18:10:15
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-19 16:08:43
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class Md5Helper {
  /*
   * 获取文件的md5
   */
  static Future<String?> getFileMd5(String path) async {
    if (path.isNotEmpty && await File(path).exists()) {
      var fileStr = await File(path).readAsString();
      var result = await getStringMd5(fileStr);
      return result;
    } else {
      return null;
    }
  }

  /*
   * 处理字符串的md5值
   */
  static Future<String?> getStringMd5(String string) async {
    if (string.isNotEmpty) {
      var content = const Utf8Encoder().convert(string);
      var digest = md5.convert(content);
      return hex.encode(digest.bytes);
    } else {
      return null;
    }
  }
}
