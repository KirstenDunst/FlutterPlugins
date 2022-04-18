/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:27:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 14:16:38
 * @Description: 文件处理
 */
import 'dart:io';
import 'package:hot_fix_csx/operation/path_op.dart';

class FileSystemHelper {
  /// 文件夹是否存在
  static Future<bool> isExistsDirectory(String dirName) {
    return Directory(dirName).exists();
  }

  /// 文件是否存在
  static Future<bool> isExistsFile(String filePatch) {
    return File(filePatch).exists();
  }

  /// 清理diff
  static Future<bool> clearLastDiff() async {
    if (await File(PathOp.instance.diffDownloadFilePath()).exists()) {
      await File(PathOp.instance.diffDownloadFilePath())
          .delete(recursive: true);
    }
    return true;
  }

  static Future<bool> clearLastZip() async {
    if (await File(PathOp.instance.latestZipFilePath()).exists()) {
      await File(PathOp.instance.latestZipFilePath()).delete(recursive: true);
    }
    return true;
  }

  static Future<bool> mvTotalZipToLastZip() async {
    File(PathOp.instance.totalDownloadFilePath())
        .rename(PathOp.instance.latestZipFilePath());
    return true;
  }

  static Future<bool> mvMakeZipToLastZip() async {
    File(PathOp.instance.makeupZipFilePath())
        .rename(PathOp.instance.latestZipFilePath());
    return true;
  }
}
