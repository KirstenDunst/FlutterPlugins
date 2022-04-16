/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:27:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-15 17:57:00
 * @Description: 文件处理
 */
import 'dart:io';

import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

class FileSystemHelper {
  /// 文件夹是否存在
  static Future<bool> isExistsWithDirectoryPath(String dirName) {
    return Directory(dirName).exists();
  }

  /// 文件是否存在
  static Future<bool> isExistsWithFilePath(String filePatch) {
    return File(filePatch).exists();
  }

  static Future<bool> clearLastDiff() async {
    await File(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixDiffDirName}')
        .delete(recursive: true);
    return true;
  }

  static Future<bool> clearLastZip() async {
    var path =
        '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}';
    if (await File(path).exists()) {
      await File(path).delete(recursive: true);
    }
    return true;
  }

  static Future<bool> mvMakeZipToLastZip() async {
    File('${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}')
        .rename(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}');
    return true;
  }
}
