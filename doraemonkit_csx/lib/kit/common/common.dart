// 视觉功能
import 'dart:io';

import 'package:doraemonkit_csx/kit/apm/apm.dart';
import 'package:doraemonkit_csx/kit/common/basic_dev_options.dart';
import 'package:doraemonkit_csx/kit/common/basic_languages.dart';
import 'package:doraemonkit_csx/kit/common/basic_setting.dart';
import 'package:doraemonkit_csx/ui/resident_page.dart';
import 'package:flutter/material.dart';

import 'basic_info.dart';

abstract class CommonKit implements IKit {
  @override
  void tabAction() {
    ResidentPage.residentPageKey.currentState.setState(() {
      ResidentPage.tag = getKitName();
    });
  }

  Widget createDisplayPage();
}

class CommonKitManager {
  Map<String, CommonKit> kitMap = Platform.isIOS
      ? {
          CommonKitName.KIT_BASE_SETTING: BasicSettingKit(),
          CommonKitName.KIT_BASIC_INFO: BasicInfoKit(),
        }
      : {
          CommonKitName.KIT_BASIC_INFO: BasicInfoKit(),
          CommonKitName.KIT_BASE_DEVOPTIONS: BasicDevOptionsKit(),
          CommonKitName.KIT_BASE_LANGUAGE: BasicLanguagesKit(),
        };

  CommonKitManager._privateConstructor() {}

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
  static const String KIT_BASE_SETTING = '设置';
  static const String KIT_BASE_DEVOPTIONS = '开发者选项';
  static const String KIT_BASE_LANGUAGE = '本地语言';
}
