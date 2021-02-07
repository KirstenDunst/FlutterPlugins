/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 11:05:51
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 09:45:08
 * @Description: 
 */

import 'dart:async';

import 'package:flutter/services.dart';

import 'model/android_device_info.dart';
import 'model/ios_device_info.dart';

class DoraemonkitCsx {
  static const MethodChannel _channel = const MethodChannel('doraemonkit_csx');
//公共桥接
  /*
   * 获取设备信息
   */
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

// iOS
  /*
   * 进入app设置页面
   */
  static Future<bool> openSettingPage() async {
    var result = await _channel.invokeMethod('openSettingPage');
    return result;
  }

  /*
   * 获取iOS的设备信息
   */
  static Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await _channel.invokeMethod('getIosDeviceInfo')).cast<String, dynamic>(),
    );
  }

// Android
  /*
   * 打开开发者选项
   */
  static Future openDeveloperOptions() async {
    await _channel.invokeMethod('openDeveloperOptions');
  }

  /*
   * 打开本地语言设置界面
   */
  static Future<bool> openLocalLanguagesPage() async {
    var result = await _channel.invokeMethod('openLocalLanguagesPage');
    return result;
  }

  /*
   * 获取安卓的设备信息
   */
  static Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await _channel.invokeMethod('getAndroidDeviceInfo'))
          .cast<String, dynamic>(),
    );
  }
}
