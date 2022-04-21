/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 11:55:25
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-15 17:52:19
 * @Description: 
 */
import 'dart:io';
import 'package:hot_fix_csx/helper/config_helper.dart';
import 'package:hot_fix_csx/helper/md5_helper.dart';
import 'package:hot_fix_csx/operation/path_op.dart';

class DownloadHelper {
  static Future<String> getDiffUrl() async {
    String filePath = ConfigHelp.instance.resourceModel.baseZipPath;
    if (!ConfigHelp.instance.configModel.isFirst) {
      if (await File(PathOp.instance.latestZipFilePath()).exists()) {
        filePath = PathOp.instance.latestZipFilePath();
      }
      //不存在资源包，就用本地资源包
      //热更新--下载阶段--热更新资源包路径获取失败,将用基准包请求增量
    }
    var md5Str = await Md5Helper.getFileMd5(filePath);
    return ConfigHelp.instance.manifestNetModel.patchRootUrl + '/$md5Str.patch';
  }
}
