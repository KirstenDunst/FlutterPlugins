// 视觉功能
import 'package:doraemonkit_csx/common/basic_clear_cache.dart';
import 'package:doraemonkit_csx/common/basic_dev_options.dart';
import 'package:doraemonkit_csx/common/basic_h5.dart';
import 'package:doraemonkit_csx/common/basic_languages.dart';
import 'package:doraemonkit_csx/common/basic_location.dart';
import 'package:doraemonkit_csx/common/basic_qr.dart';
import 'package:doraemonkit_csx/common/basic_sandbox.dart';
import 'package:doraemonkit_csx/common/basic_setting.dart';
import 'package:doraemonkit_csx/common/basic_userdefaults.dart';
import 'package:flutter/material.dart';

import '../kit.dart';
import '../page/kits_page.dart';
import 'basic_info.dart';

abstract class CommonKit extends IKit {
  @override
  void tabAction() {
    KitsPage.tag = getKitName();
  }

  Widget createDisplayPage();
}

class CommonKitManager {
  Map<String, CommonKit> kitMap = {
    CommonKitName.kitBaseInfo: BasicInfoKit(),
    CommonKitName.kitBaseSandbox: BasicSandBoxKit(),
    CommonKitName.kitBaseLocation: BasicLocationsKit(),
    CommonKitName.kitBaseH5: BasicH5Kit(),
    CommonKitName.kitBaseClearcache: BasicClearCacheKit(),
    CommonKitName.kitBaseUserDefaults: BasicUserDefaultsKit(),
    CommonKitName.kitBaseQR: BasicQRKit(),
    CommonKitName.kitBaseDevoptions: BasicDevOptionsKit(),
    CommonKitName.kitBaseLanguage: BasicLanguagesKit(),
    CommonKitName.kitBaseSetting: BasicSettingKit(),
  };

  CommonKitManager._privateConstructor();

  static final CommonKitManager _instance =
      CommonKitManager._privateConstructor();

  static CommonKitManager get instance => _instance;

  // 如果想要自定义实现，可以用这个方式进行覆盖。后续扩展入口
  void addKit(String tag, CommonKit kit) {
    kitMap[tag] = kit;
  }

  T? getKit<T extends CommonKit?>(String name) {
    if (kitMap.containsKey(name)) {
      return kitMap[name] as T;
    }
    return null;
  }
}

class CommonKitName {
  static const String kitBaseInfo = '基本信息';
  static const String kitBaseSandbox = '沙盒浏览';
  static const String kitBaseLocation = '位置模拟';
  static const String kitBaseH5 = 'H5任意门';
  static const String kitBaseClearcache = '清理缓存';
  static const String kitBaseUserDefaults = 'UserDefaults';
  static const String kitBaseQR = '二维码生成器';

  //专属于安卓的
  static const String kitBaseDevoptions = '开发者选项';
  static const String kitBaseLanguage = '本地语言';

  //专属于iOS的
  static const String kitBaseSetting = '应用设置';
}
