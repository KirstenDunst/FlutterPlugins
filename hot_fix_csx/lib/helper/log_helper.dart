/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:29:57
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-29 09:40:05
 * @Description: 
 */

import 'package:hot_fix_csx/base/common.dart';

class LogHelper {
  factory LogHelper() => _getInstance();
  static LogHelper get instance => _getInstance();
  static LogHelper? _instance;
  static LogHelper _getInstance() {
    return _instance ??= new LogHelper._internal();
  }

  LogHelper._internal();
  LogInfoCall? _call;

  set logCall(LogInfoCall? call) {
    _call = call;
  }

  void logInfo(String info) {
    if (_call != null) {
      _call!(info);
    }
  }
}
