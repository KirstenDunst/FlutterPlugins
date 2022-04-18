/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:29:57
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 10:26:10
 * @Description: 
 */

import 'package:hot_fix_csx/constant/enum.dart';
import 'package:logger_util/logger_util.dart';

class LogHelper {
  factory LogHelper() => _getInstance();
  static LogHelper get instance => _getInstance();
  static LogHelper? _instance;
  static LogHelper _getInstance() {
    return _instance ??= LogHelper._internal();
  }

  LogHelper._internal() {
    _call = (str) {
      LogUtil.logD(str, fileSubName: 'hotfixLog');
    };
  }

  late LogInfoCall _call;

  set logCall(LogInfoCall? call) {
    if (call != null) {
      _call = call;
    }
  }

  void logInfo(String info) => _call(info);

  void dispose() {
    _instance = null;
  }
}
