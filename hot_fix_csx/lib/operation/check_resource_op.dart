/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:11:17
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-15 17:28:43
 * @Description: 资源核对操作工具
 */
import 'dart:io';
import 'package:hot_fix_csx/constant/enum.dart';
import 'package:hot_fix_csx/helper/error_helper.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';
import 'package:hot_fix_csx/helper/md5_helper.dart';
import 'package:hot_fix_csx/model/config_model.dart';

class CheckResourceOp {
  /// 核对内部资源是否完整
  static Future<CheckResultModel> checkResourceFull(
      Map<String, dynamic> manifestJson, String resourceDirect) async {
    if (manifestJson.isEmpty || !(await Directory(resourceDirect).exists())) {
      return CheckResultModel(
          checkIsComplete: false,
          checkError:
              ErrorHelper.errorWithType(HotFixErrorType.resourceSumNotExists));
    } else {
      HotFixErrorType? errorType;
      var checkSum = manifestJson['checksum'] as Map;
      var manifestKeys = checkSum.keys.toList();
      for (var i = 0; i < manifestKeys.length; i++) {
        var key = manifestKeys[i];
        var value = checkSum[key];
        var filePath = resourceDirect + '/$key';
        if (await File(filePath).exists()) {
          var fileMd5 = await Md5Helper.getFileMd5(filePath) ?? '';
          if (fileMd5.isEmpty || fileMd5 != value) {
            LogHelper.instance.logInfo('完备性校验失败:>>md5不一致>>$filePath>>$fileMd5');
            errorType = HotFixErrorType.resourceSumMd5NotEqual;
            break;
          }
        } else {
          LogHelper.instance.logInfo('完备性校验失败:>>不存在>>$filePath');
          errorType = HotFixErrorType.resourceSumNotExists;
          break;
        }
      }
      if (errorType != null) {
        return CheckResultModel(
            checkIsComplete: false,
            checkError: ErrorHelper.errorWithType(errorType));
      } else {
        return CheckResultModel(checkIsComplete: true, checkError: null);
      }
    }
  }
}
