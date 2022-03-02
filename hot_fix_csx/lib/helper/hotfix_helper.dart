/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:37:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-03-01 18:19:10
 * @Description: 
 */
import 'dart:io';

import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

import 'resource_helper.dart';
import 'zip_helper.dart';

class HotFixHelper {
  /*
   * 当前可用资源的父级目录
   */
  static String currentValidResourceBasePath() {
    var type = ConfigHelp.instance.configModel.currentValidResourceType;
    var footPath = Constant.hotfixBaseResourceDirName;
    switch (type) {
      case HotFixValidResource.fix:
        footPath = Constant.hotfixFixResourceDirName;
        break;
      case HotFixValidResource.fixTmp:
        footPath = Constant.hotfixFixTempResourceDirName;
        break;
      case HotFixValidResource.base:
      case HotFixValidResource.none:
      default:
        footPath = Constant.hotfixBaseResourceDirName;
    }
    return PathOp.instance.baseDirectory + '/$footPath';
  }

  /*
   * 当前资源文件的清单文件路径
   */
  static String currentManifestPath() {
    var parentPath = currentManifestPath();
    return '$parentPath/${Constant.hotfixResourceListFile}';
  }

  static Future<bool> isCompletedUnarchiveBase() async {
    return ZipHelper.unZipFile(
        ResourceHelper.instance.getBaseZipName(),
        PathOp.instance.baseDirectory +
            '/${Constant.hotfixBaseResourceDirName}');
  }

  /// 增量合并
  static Future<bool> makeupZip() async {
    var isBbase = true;
    var currentResource =
        ConfigHelp.instance.configModel.currentValidResourceType;
    if (currentResource == HotFixValidResource.fix ||
        currentResource == HotFixValidResource.fixTmp) {
      isBbase = false;
    }
    var result = await ZipHelper.patchResource(isBbase);
    LogHelper.instance.logInfo('增量合并完成---result:$result');
    return true;
  }

  static Future<bool> clearLastDiff() async {
    await File(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixDiffDirName}')
        .delete(recursive: true);
    return true;
  }

  static Future<bool> clearLastZip() async {
    await File(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}')
        .delete(recursive: true);
    return true;
  }

  static Future<bool> clearMakeupZip() async {
    await File(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}')
        .delete(recursive: true);
    return true;
  }

  static Future<bool> mvMakeZipToLastZip() async {
    File('${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixMakeupResourceFile}')
        .copy(
            '${PathOp.instance.baseDirectory}/${Constant.hotfixDownloadDirName}/${Constant.hotfixLatestResourceFile}');
    return true;
  }
}
