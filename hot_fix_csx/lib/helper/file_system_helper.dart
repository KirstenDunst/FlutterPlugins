/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:27:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 17:46:46
 * @Description: 文件处理
 */
import 'dart:io';
import 'package:hot_fix_csx/operation/path_op.dart';

class FileSystemHelper {
  /// 存在判断
  /// 文件夹是否存在
  static Future<bool> isExistsDirectory(String dirName) =>
      Directory(dirName).exists();

  /// 文件是否存在
  static Future<bool> isExistsFile(String filePatch) =>
      File(filePatch).exists();

  /// 文件夹清理
  /// 清理临时文件
  static Future<bool> clearFixDir() =>
      _clearDirectory(PathOp.instance.fixDirectoryPath());

  /// 清理临时文件
  static Future<bool> clearFixTempDir() =>
      _clearDirectory(PathOp.instance.fixtempDirectoryPath());

  static Future<bool> _clearDirectory(String directoryPath) async {
    if (await isExistsDirectory(directoryPath)) {
      await Directory(directoryPath).delete(recursive: true);
    }
    return true;
  }

  /// 文件清理
  /// 清理diff
  static Future<bool> clearLastDiff() =>
      _clearFile(PathOp.instance.diffDownloadFilePath());

  static Future<bool> _clearFile(String filePath) async {
    if (await isExistsFile(filePath)) {
      await File(filePath).delete(recursive: true);
    }
    return true;
  }

  /// 重命名rename
  static Future<bool> mvTotalZipToLastZip() => _fileRename(
      PathOp.instance.totalDownloadFilePath(),
      PathOp.instance.latestZipFilePath());

  static Future<bool> mvMakeZipToLastZip() => _fileRename(
      PathOp.instance.makeupZipFilePath(), PathOp.instance.latestZipFilePath());

  static Future<bool> _fileRename(
      String fromFilePath, String toFilePath) async {
    if (await isExistsFile(toFilePath)) {
      await File(toFilePath).delete(recursive: true);
    }
    var frontPath = toFilePath.replaceAll('/${toFilePath.split('/').last}', '');
    if (!await isExistsDirectory(frontPath)) {
      await Directory(frontPath).create(recursive: true);
    }
    await File(fromFilePath).rename(toFilePath);
    return true;
  }

  static Future<bool> mvFixTempDirToBaseDir() => _directoryRename(
      PathOp.instance.fixtempDirectoryPath(),
      PathOp.instance.baseDirectoryPath());
  static Future<bool> mvBaseDirToFixTempDir() => _directoryRename(
      PathOp.instance.baseDirectoryPath(),
      PathOp.instance.fixtempDirectoryPath());
  static Future<bool> mvFixDirToBaseDir() => _directoryRename(
      PathOp.instance.fixDirectoryPath(), PathOp.instance.baseDirectoryPath());

  static Future<bool> _directoryRename(
      String fromDirePath, String toDirePath) async {
    if (await isExistsDirectory(toDirePath)) {
      await Directory(toDirePath).delete(recursive: true);
    }
    var frontPath = toDirePath.replaceAll('/${toDirePath.split('/').last}', '');
    if (!await isExistsDirectory(frontPath)) {
      await Directory(frontPath).create(recursive: true);
    }
    await Directory(fromDirePath).rename(toDirePath);
    return true;
  }
}
