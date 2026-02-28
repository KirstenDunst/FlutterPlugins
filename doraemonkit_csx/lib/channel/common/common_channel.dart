import 'dart:async';
import 'common_platform_interface.dart';

class DoraemonkitCsx {
  static Future<String?> getPlatformVersion() {
    return DoraemonkitCsxPlatform.instance.getPlatformVersion();
  }

  //获取UserDefault的所有存储(这里为了避免特殊不同语言类型的问题，key和value已经都强制转为字符串传输接收了)
  static Future<Map> getUserDefaults() {
    return DoraemonkitCsxPlatform.instance.getUserDefaults();
  }

  /*
   * 修改本地存储
   */
  static Future setUserDefault(Map<String, dynamic> tempJson) {
    return DoraemonkitCsxPlatform.instance.setUserDefault(tempJson);
  }

  // iOS
  /*
   * 进入app设置页面
   */
  static Future<bool> openiOSSettingPage() {
    return DoraemonkitCsxPlatform.instance.openiOSSettingPage();
  }

  // Android
  /*
   * 打开开发者选项
   */
  static Future openAndroidDeveloperOptions() {
    return DoraemonkitCsxPlatform.instance.openAndroidDeveloperOptions();
  }

  /*
   * 打开本地语言设置界面
   */
  static Future<bool> openAndroidLocalLanguagesPage() {
    return DoraemonkitCsxPlatform.instance.openAndroidLocalLanguagesPage();
  }
}
