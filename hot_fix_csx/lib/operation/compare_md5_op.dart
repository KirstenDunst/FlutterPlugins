/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:10:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-15 17:29:36
 * @Description: 
 */
import 'dart:io';
import 'package:hot_fix_csx/helper/md5_helper.dart';

class CompareMd5Op {
  /// 比对md5值和本地文件的校验
  static Future<bool> compareMd5(String md5Str, String filePath) async {
    if (await File(filePath).exists()) {
      var fileMd5 = await Md5Helper.getFileMd5(filePath);
      if (fileMd5 == null) {
        return false;
      } else {
        return fileMd5 == md5Str;
      }
    } else {
      return false;
    }
  }
}
