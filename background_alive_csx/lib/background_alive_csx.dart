/*
 * @Author: Cao Shixin
 * @Date: 2021-01-05 15:53:19
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 16:08:25
 * @Description: 
 */
import 'dart:async';

import 'package:flutter/services.dart';

class BackgroundAliveCsx {
  static const MethodChannel _channel =
      const MethodChannel('background_alive_csx');

  static Future keepBackgroundAlive() async {
    await _channel.invokeMethod('keepBackgroundAlive');
  }
}
