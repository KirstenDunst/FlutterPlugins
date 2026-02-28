/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 14:59:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 15:22:27
 * @Description: 
 */
import 'package:flutter/material.dart';

import '../channel/common/common_channel.dart';
import 'common.dart';

//仅支持安卓
class BasicLanguagesKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_kit_local_lang.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseLanguage;
  }

  @override
  void tabAction() {
    DoraemonkitCsx.openAndroidLocalLanguagesPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
