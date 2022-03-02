/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:27:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-01 18:06:30
 * @Description: 文件处理
 */
import 'dart:io';

class FileSystemHelper {
  /// 文件夹是否存在
  static Future<bool> isExistsWithDirectoryPath(String dirName) {
    return Directory(dirName).exists();
  }

  /// 文件是否存在
  static Future<bool> isExistsWithFilePath(String filePatch) {
    return File(filePatch).exists();
  }
}
