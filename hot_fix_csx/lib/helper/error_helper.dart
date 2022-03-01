/*
 * @Author: Cao Shixin
 * @Date: 2021-06-25 10:09:50
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-21 15:25:46
 * @Description: 
 */

import 'package:hot_fix_csx/constant/enum.dart';
class ErrorHelper {
  static Error errorWithType(HotFixErrorType errorType) {
    Error error;
    switch (errorType) {
      case HotFixErrorType.unknow:
        error = ArgumentError.value(errorType, '未知错误');
        break;
      case HotFixErrorType.pathInvalid:
        error = ArgumentError.value(errorType, '路径无效');
        break;
      case HotFixErrorType.resourceListInvalid:
        error = ArgumentError.value(errorType, '资源清单无效');
        break;
      case HotFixErrorType.resourceSumNotExists:
        error = ArgumentError.value(errorType, '资源不完整');
        break;
      case HotFixErrorType.resourceSumMd5NotEqual:
        error = ArgumentError.value(errorType, '有资源md5不一致');
        break;
      case HotFixErrorType.netResourceIsWrong:
        error = ArgumentError.value(errorType, '网络全量资源不正确');
        break;
      case HotFixErrorType.diffResourceIsWrong:
        error = ArgumentError.value(errorType, '网络增量资源不正确（合并包错误）');
        break;
      case HotFixErrorType.urlInvalid:
        error = ArgumentError.value(errorType, 'URL无效');
        break;
      default:
        error = ArgumentError.value('未知错误');
    }
    return error;
  }
}
