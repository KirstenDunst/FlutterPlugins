/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 11:59:29
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-18 17:36:49
 * @Description: 
 */
import 'dart:async';

import 'package:doraemonkit_csx/model/android_device_info.dart';
import 'package:doraemonkit_csx/model/ios_device_info.dart';
import 'package:flutter/services.dart';

class DoKitCommonCsx {
  static const MethodChannel _channel = const MethodChannel('doraemonkit_csx');
//公共桥接
  /*
   * 获取设备信息
   */
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /*
   * 获取UserDefault的所有存储(这里为了避免特殊不同语言类型的问题，key和value已经都强制转为字符串传输接收了)
   */
  static Future<Map> get getUserDefaults async {
    final Map result = await _channel.invokeMethod('getUserDefaults');
    return result;
  }

  /*
   * 修改本地存储
   */
  static Future setUserDefault(Map<String, dynamic> tempJson) async {
    await _channel.invokeMethod('setUserDefault', tempJson);
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
