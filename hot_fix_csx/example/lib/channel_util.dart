/*
 * @Author: Cao Shixin
 * @Date: 2022-03-02 10:50:16
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 16:57:32
 * @Description: 
 */
import 'package:flutter/services.dart';

class ChannelUtil {
  static const MethodChannel _channel = MethodChannel('hot_fix_csx_example123');

  /// 基本资源迁移
  /// targetPath:需要迁移到的文件路径
  static Future<bool> copyBaseResource(String targetPath) async {
    print('>>>>>>>>>>>>1234256>>>${targetPath}');
    var result = await _channel.invokeMethod('move_base_zip', targetPath) ?? 0;
    return result == 1 ? true : false;
  }
}
