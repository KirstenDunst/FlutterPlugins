/*
 * @Author: Cao Shixin
 * @Date: 2022-04-19 09:39:33
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 16:28:04
 * @Description: 跨版本清理旧的数据
 */
import 'dart:io';

import 'package:hot_fix_csx/operation/path_op.dart';

import 'config_helper.dart';

class ClearHelp {
  /// 跨版本清理旧文件
  static Future clearOldData() async {
    var nowAppVersion = ConfigHelp.instance.nowAppVersion;
    var localAppVerison = ConfigHelp.instance.configModel.appVersion;
    if (nowAppVersion != localAppVerison && localAppVerison.isNotEmpty) {
      await Directory(PathOp.instance.baseDirectory).delete(recursive: true);
    }
  }
}
