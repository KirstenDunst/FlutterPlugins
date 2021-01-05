/*
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:12:14
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-05 15:31:26
 * @Description: 
 */
import 'dart:async';

import 'package:flutter/services.dart';

class LimitingDirectionCsx {
  static const MethodChannel _channel =
      const MethodChannel('limiting_direction_csx');
      
  /// 设置屏幕支持的方位
  static Future setUpScreenDirection(DeviceDirectionMask directionMask) async {
    return _channel
        .invokeMethod('changeScreenDirection', [directionMask.index]);
  }
}

/// 方位枚举
enum DeviceDirectionMask {
  //竖屏
  Portrait,
  //左旋转
  LandscapeLeft,
  //右旋转
  LandscapeRight,
  //竖直方向向上向下可旋转
  PortraitUpsideDown,
  //横屏
  Landscape,
  //全部四个方位
  All,
  //左右旋转
  AllButUpsideDown,
}
