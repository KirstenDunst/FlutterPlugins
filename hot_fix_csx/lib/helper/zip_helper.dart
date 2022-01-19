/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:13:32
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-28 11:25:42
 * @Description: 
 */
import 'dart:io';

import 'package:archive/archive.dart';

class ZipHelper {
  /*
   * 解压zip文件
   * filePath：文件路径
   * targetDirectory：解压到的目标文件目录
   */
  static Future<bool> unZipFile(String filePath, String targetDirectory) async {
    if (!(await File(filePath).exists())) {
      throw '解压文件zip不存在，请校验zip文件：$filePath';
    }
    if (!(await Directory(targetDirectory).exists())) {
      await Directory(targetDirectory).create(recursive: true);
    }
    var bytes = File(filePath).readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var filename = file.name;
      if (file.isFile) {
        var data = file.content as List<int>;
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(filename)..create(recursive: true);
      }
    }
    return true;
  }
}
