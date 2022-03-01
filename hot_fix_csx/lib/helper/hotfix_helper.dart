/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:37:35
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-21 15:25:27
 * @Description: 
 */
import 'package:hot_fix_csx/constant/constant.dart';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/config_helper.dart';
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

  static Future<bool> makeupZip() async {
    return true;
  }

  static Future<bool> clearLastDiff() async {
    return true;
  }

  static Future<bool> clearLastZip() async {
    return true;
  }

  static Future<bool> clearMakeupZip() async {
    return true;
  }

  static Future<bool> mvMakeZipToLastZip() async {
    return true;
  }
}
