/*
 * @Author: Cao Shixin
 * @Date: 2020-12-28 15:12:14
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-12-10 08:38:07
 * @Description: 
 */
import 'dart:async';

import 'package:flutter/services.dart';

class LimitingDirectionCsx {
  /// 第一次获取可能为默认值Unknown，
  /// 如果方便的话可以调用[LimitingDirectionCsx().getNowDeviceDirection]来获取当前的状态，
  /// 或者使用[LimitingDirectionCsx().getDeviceDirection]以流的方式处理状态变化
  UIDeviceOrientation get currentDeviceOrientation => _currentDeviceOrientation;

  late var _deviceOrientationController;
  late UIDeviceOrientation _currentDeviceOrientation;

  static const MethodChannel _channel =
      const MethodChannel('limiting_direction_csx');
  static const deviceOrientationMap = {
    '0': UIDeviceOrientation.Unknown,
    '1': UIDeviceOrientation.Portrait,
    '2': UIDeviceOrientation.PortraitUpsideDown,
    '3': UIDeviceOrientation.LandscapeLeft,
    '4': UIDeviceOrientation.LandscapeRight,
    '5': UIDeviceOrientation.FaceUp,
    '6': UIDeviceOrientation.FaceDown
  };

  LimitingDirectionCsx() {
    _currentDeviceOrientation = UIDeviceOrientation.Unknown;
    _deviceOrientationController =
        StreamController<UIDeviceOrientation>.broadcast();
    _deviceOrientationController.stream.listen((event) {
      _currentDeviceOrientation = event;
    });
    _dealCallHandler();
  }

  @Deprecated('after version 0.0.3 to Use `setScreenDirection` method instead')
  static Future setUpScreenDirection(DeviceDirectionMask directionMask) async {
    await _channel.invokeMethod('changeScreenDirection', [directionMask.index]);
  }

  /// 设置屏幕支持的方位
  static Future setScreenDirection(DeviceDirectionMask directionMask) async {
    await _channel.invokeMethod('changeScreenDirection', [directionMask.index]);
  }

  /// 获取陀螺仪的陈列方位的变化流
  Stream<UIDeviceOrientation> getDeviceDirectionStream() {
    return _deviceOrientationController.stream;
  }

  /// 实时获取当前陀螺仪的陈列方位
  Future<UIDeviceOrientation?> getNowDeviceDirection() async {
    var tempStr = await _channel.invokeMethod('getNowDeviceDirection');
    var deviceOrientation = deviceOrientationMap[tempStr];
    _currentDeviceOrientation =
        deviceOrientation ?? UIDeviceOrientation.Unknown;
    return _currentDeviceOrientation;
  }

  void _dealCallHandler() async {
    await getNowDeviceDirection();
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "orientationCallback") {
        var deviceOrientation = deviceOrientationMap['${call.arguments}'];
        _deviceOrientationController.sink
            .add(deviceOrientation ?? UIDeviceOrientation.Unknown);
      }
    });
  }
}

// 设备陀螺仪当前方位
enum UIDeviceOrientation {
  Unknown,
  // Device oriented vertically, home button on the bottom
  Portrait,
  // Device oriented vertically, home button on the top
  PortraitUpsideDown,
  // Device oriented horizontally, home button on the right
  LandscapeLeft,
  // Device oriented horizontally, home button on the left
  LandscapeRight,
  // Device oriented flat, face up
  FaceUp,
  // Device oriented face down
  FaceDown
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
