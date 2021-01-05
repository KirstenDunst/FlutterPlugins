/*
 * @Author: Cao Shixin
 * @Date: 2021-01-04 17:54:49
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-04 18:16:18
 * @Description: 
 */

import 'dart:async';

import 'package:flutter/services.dart';

import 'model/android_device_info.dart';
import 'model/ios_device_info.dart';

class DeviceInfoCsx {
  static const MethodChannel _channel =
      const MethodChannel('device_info_csx');

  // Method channel for Android devices
  static Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await _channel.invokeMethod('getAndroidDeviceInfo'))
          .cast<String, dynamic>(),
    );
  }

  // Method channel for iOS devices
  static Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await _channel.invokeMethod('getIosDeviceInfo')).cast<String, dynamic>(),
    );
  }
}
