/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 15:25:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-20 13:09:10
 * @Description: 
 */

// 基本工具
import 'dart:io';

import 'package:doraemonkit_csx/kit/apm/apm.dart';
import 'package:doraemonkit_csx/kit/common/basic_clear_cache.dart';
import 'package:doraemonkit_csx/kit/common/basic_dev_options.dart';
import 'package:doraemonkit_csx/kit/common/basic_file_sync.dart';
import 'package:doraemonkit_csx/kit/common/basic_h5.dart';
import 'package:doraemonkit_csx/kit/common/basic_languages.dart';
import 'package:doraemonkit_csx/kit/common/basic_sandbox.dart';
import 'package:doraemonkit_csx/kit/common/basic_setting.dart';
import 'package:doraemonkit_csx/kit/common/basic_userdefaults.dart';
import 'package:doraemonkit_csx/ui/resident_page.dart';
import 'package:flutter/material.dart';

import 'basic_info.dart';
import 'basic_location.dart';
import 'basic_qr.dart';

abstract class CommonKit implements IKit {
  static BuildContext rootNavigatorContext =
      rootNavigatorKey.currentState.overlay.context;
  @override
  void tabAction() {
    Navigator.push(
      rootNavigatorContext,
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                title: Text(getKitName()),
              ),
              body: createDisplayPage());
        },
      ),
    );
  }

  Widget createDisplayPage();
}

class CommonKitManager {
  Map<String, CommonKit> kitMap = (Platform.isIOS
      ? {
          CommonKitName.KIT_BASE_SETTING: BasicSettingKit(),
        }
      : {
          CommonKitName.KIT_BASE_DEVOPTIONS: BasicDevOptionsKit(),
          CommonKitName.KIT_BASE_LANGUAGE: BasicLanguagesKit(),
        });

  CommonKitManager._privateConstructor() {
    kitMap.addAll({
      CommonKitName.KIT_BASIC_INFO: BasicInfoKit(),
      CommonKitName.KIT_BASE_SANDBOX: BasicSandBoxKit(),
      CommonKitName.KIT_BASE_LOCATION: BasicLocationsKit(),
      CommonKitName.KIT_BASE_H5: BasicH5Kit(),
      CommonKitName.KIT_BASE_CLEARCACHE: BasicClearCacheKit(),
      CommonKitName.KIT_BASE_USERDEFAULTS: BasicUserDefaultsKit(),
      CommonKitName.KIT_BASE_FILESYNC: BasicFileSyncKit(),
      CommonKitName.KIT_BASE_QR: BasicQRKit(),
    });
  }

  static final CommonKitManager _instance =
      CommonKitManager._privateConstructor();

  static CommonKitManager get instance => _instance;

  // 如果想要自定义实现，可以用这个方式进行覆盖。后续扩展入口
  void addKit(String tag, CommonKit kit) {
    assert(tag != null && kit != null);
    kitMap[tag] = kit;
  }

  T getKit<T extends CommonKit>(String name) {
    assert(name != null);
    if (kitMap.containsKey(name)) {
      return kitMap[name];
    }
    return null;
  }
}

class CommonKitName {
  static const String KIT_BASIC_INFO = '基本信息';
  static const String KIT_BASE_SANDBOX = '沙盒浏览';
  static const String KIT_BASE_LOCATION = '位置模拟';
  static const String KIT_BASE_H5 = 'H5任意门';
  static const String KIT_BASE_CLEARCACHE = '清理缓存';
  static const String KIT_BASE_USERDEFAULTS = 'UserDefaults';
  static const String KIT_BASE_FILESYNC = 'DBView'; //文件同步助手
  static const String KIT_BASE_QR = '二维码生成器';

  //专属于安卓的
  static const String KIT_BASE_DEVOPTIONS = '开发者选项';
  static const String KIT_BASE_LANGUAGE = '本地语言';

  //专属于iOS的
  static const String KIT_BASE_SETTING = '应用设置';
}
