/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:17:59
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-26 10:23:41
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:async';

import 'package:flutter/services.dart';

class IosSpecificCsx {
  static const MethodChannel _channel = const MethodChannel('ios_specific_csx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
