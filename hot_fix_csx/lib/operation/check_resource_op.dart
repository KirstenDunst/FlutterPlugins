/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:11:17
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-28 17:24:34
 * @Description: 资源核对操作工具
 */
import 'dart:io';

import 'package:hot_fix_csx/base/enum.dart';
import 'package:hot_fix_csx/helper/error_helper.dart';
import 'package:hot_fix_csx/helper/md5_helper.dart';


class CheckResourceOp {
  /*
   * 核对内部资源是否完整
   */
  static void checkResourceFull(
      Map<String, String> manifestJson,
      String resourceDirect,
      Function(bool checkIsComplete, Error? checkError) result) async {
    if (manifestJson.isEmpty || !(await Directory(resourceDirect).exists())) {
      result(false,
          ErrorHelper.errorWithType(HotFixErrorType.ResourceSumNotExists));
      return;
    } else {
      HotFixErrorType? errorType;
      var manifestKeys = manifestJson.keys.toList();
      for (var i = 0; i < manifestKeys.length; i++) {
        var key = manifestKeys[i];
        var value = manifestJson[key];
        var filePath = resourceDirect + key;
        if (await File(filePath).exists()) {
          var fileMd5 = await Md5Helper.getFileMd5(filePath) ?? '';
          if (fileMd5.isEmpty || fileMd5 != value) {
            errorType = HotFixErrorType.ResourceSumMd5NotEqual;
            break;
          }
        } else {
          errorType = HotFixErrorType.ResourceSumNotExists;
          break;
        }
      }
      if (errorType != null) {
        result(false, ErrorHelper.errorWithType(errorType));
      } else {
        result(true, null);
      }
    }
  }
}
