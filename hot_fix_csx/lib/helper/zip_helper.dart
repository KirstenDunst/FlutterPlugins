/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:13:32
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-01 18:06:23
 * @Description: 
 */
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/helper/file_system_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/helper/resource_helper.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

class ZipHelper {
  /// 解压zip文件
  /// filePath：文件路径
  /// targetDirectory：解压到的目标文件目录
  static Future<bool> unZipFile(String filePath, String targetDirectory) async {
    if (!(await File(filePath).exists())) {
      throw '解压文件zip不存在，请校验zip文件:$filePath';
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
        await Directory(filename).create(recursive: true);
      }
    }
    return true;
  }

  /// patch resource
  /// isBase:是否是基准包˝
  static Future<bool> patchResource(bool isBase) async {
    var filePath = '';
    if (isBase) {
      filePath = ResourceHelper.instance.getBaseZipName();
    } else {
      var isExists = await FileSystemHelper.isExistsWithFilePath(PathOp
              .instance.baseDirectory +
          '/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}');
      if (!isExists) {
        //不存在资源包，就用本地资源包
        LogHelper.instance.logInfo('热更新--合并增量--老热更新资源包路径获取失败,将用基准包合并');
        filePath = ResourceHelper.instance.getBaseZipName();
      }
    }
    if (filePath.isNotEmpty) {
      var savePath = await File(PathOp.instance.baseDirectory +
              '/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}')
          .create(recursive: true);
      var patchPatch =
          '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixDiffDirName}';
      var result = HotFixCsx.bsPatchWithC(
          ['bspatch', filePath, savePath.path, patchPatch]);
      return result == 1;
    } else {
      return false;
    }
  }
}
