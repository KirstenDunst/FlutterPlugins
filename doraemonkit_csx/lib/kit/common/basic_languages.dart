/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 14:59:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-05 15:10:00
 * @Description: 
 */
import 'package:doraemonkit_csx/common/assets.dart';
import 'package:doraemonkit_csx/doraemonkit_csx.dart';
import 'package:flutter/material.dart';

import 'common.dart';

//仅支持安卓
class BasicLanguagesKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_kit_local_lang;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_LANGUAGE;
  }

  @override
  void tabAction() {
    DoraemonkitCsx.openLocalLanguagesPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
