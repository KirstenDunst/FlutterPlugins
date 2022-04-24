/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:29:57
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-22 17:51:22
 * @Description: 
 */

import 'dart:async';

import 'package:hot_fix_csx/constant/enum.dart';
import 'package:flutter_utils/flutter_utils.dart';

class LogHelper {
  factory LogHelper() => _getInstance();
  static LogHelper get instance => _getInstance();
  static LogHelper? _instance;
  static LogHelper _getInstance() {
    return _instance ??= LogHelper._internal();
  }

  Stream<String> get logStream => _logStreamController.stream;
  List<String> get historyLogs => _historyLogs;

  late StreamController<String> _logStreamController;
  late List<String> _historyLogs;
  late StreamSubscription _streamSubscription;

  LogHelper._internal() {
    _call = (str) {
      LogUtil.logD(str, fileSubName: 'hotfixLog');
    };
    _historyLogs = <String>[];
    _logStreamController = StreamController<String>.broadcast();
    _streamSubscription = _logStreamController.stream.listen((event) {
      //设置上限：最近70条
      if (_historyLogs.length > 70) {
        _historyLogs.removeAt(0);
      }
      _historyLogs.add(event);
    });
  }

  late LogInfoCall _call;

  set logCall(LogInfoCall? call) {
    if (call != null) {
      _call = call;
    }
  }

  void logInfo(String info) {
    _logStreamController.sink.add(info);
    _call(info);
  }

  void dispose() {
    _streamSubscription.cancel();
    _logStreamController.close();
    _instance = null;
  }
}
