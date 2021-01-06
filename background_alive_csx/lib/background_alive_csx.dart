/*
 * @Author: Cao Shixin
 * @Date: 2021-01-05 15:53:19
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-06 15:13:16
 * @Description: 
 */
import 'dart:async';

import 'package:flutter/services.dart';

class BackgroundAliveCsx {
  static const MethodChannel _channel =
      const MethodChannel('background_alive_csx');

  /// 启动后台任务
  static Future openBackgroundTask() async {
    await _channel.invokeMethod('openBackgroundTask');
  }

  /// 关闭后台任务
  static Future stopBackgroundTask() async {
    await _channel.invokeMethod('stopBackgroundTask');
  }
}
