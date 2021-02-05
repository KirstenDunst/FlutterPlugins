/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 11:05:51
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-05 11:07:56
 * @Description: 
 */

import 'dart:async';

import 'package:flutter/services.dart';

class DoraemonkitCsx {
  static const MethodChannel _channel =
      const MethodChannel('doraemonkit_csx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
