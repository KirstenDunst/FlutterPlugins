/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:13:32
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 13:50:53
 * @Description: 
 */
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/file_system_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:hot_fix_csx/operation/path_op.dart';
import 'config_helper.dart';

class ZipHelper {
  /// 解压zip文件
  /// filePath：文件路径
  /// targetDirectory：解压到的目标文件目录
  static Future<bool> unZipFile(String filePath, String targetDirectory) async {
    if (!(await File(filePath).exists())) {
      throw '解压文件zip不存在,请校验zip文件:$filePath';
    }
    if (!(await Directory(targetDirectory).exists())) {
      await Directory(targetDirectory).create(recursive: true);
    }
    // 从磁盘读取Zip文件。
    List<int> bytes = File(filePath).readAsBytesSync();
    // 解码Zip文件
    Archive archive = ZipDecoder().decodeBytes(bytes);
    // 将Zip存档的内容解压缩到磁盘。
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> tempData = file.content;
        File(targetDirectory + "/" + file.name)
          ..createSync(recursive: true)
          ..writeAsBytesSync(tempData);
      } else {
        Directory(targetDirectory + "/" + file.name).create(recursive: true);
      }
    }
    LogHelper.instance.logInfo("解压成功");
    return true;
  }

  /// patch resource
  static Future<bool> patchResource() async {
    var filePath = '';
    if (ConfigHelp.instance.configModel.currentValidResourceType ==
        HotFixValidResource.base) {
      filePath = ConfigHelp.instance.getBaseZipPath();
    } else {
      var isExists = await FileSystemHelper.isExistsFile(
          PathOp.instance.latestZipFilePath());
      if (!isExists) {
        //不存在资源包，就用本地资源包
        LogHelper.instance.logInfo('热更新--合并增量--老热更新资源包路径获取失败,将用基准包合并');
        filePath = ConfigHelp.instance.getBaseZipPath();
      }
    }
    LogHelper.instance.logInfo('patchResource filePath:$filePath');
    if (filePath.isNotEmpty) {
      var savePath = await File(PathOp.instance.makeupZipFilePath())
          .create(recursive: true);
      var patchPatch = PathOp.instance.diffDownloadFilePath();
      LogHelper.instance
          .logInfo('savePath: ${savePath.path}, \n patchPatch:$patchPatch');
      var result = HotFixCsx.bsPatchWithC(
          ['bspatch', filePath, savePath.path, patchPatch]);
      return result == 1;
    } else {
      return false;
    }
  }
}
