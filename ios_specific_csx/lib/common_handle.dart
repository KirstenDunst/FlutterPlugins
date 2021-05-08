/*
 * @Author: Cao Shixin
 * @Date: 2021-05-08 15:33:05
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-05-08 16:32:09
 * @Description: 
 */
import 'package:flutter/services.dart';

class CommonHandle {
  final MethodChannel _channel = const MethodChannel('ios_specific_csx_common');
  /*
   * 测试
   */
  Future<String> get platformVersion async {
    String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
