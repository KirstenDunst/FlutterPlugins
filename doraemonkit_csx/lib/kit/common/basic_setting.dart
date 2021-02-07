/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 11:38:17
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-05 15:03:13
 * @Description: 
 */
import 'package:doraemonkit_csx/common/assets.dart';
import 'package:doraemonkit_csx/dokitchannel.dart';
import 'package:flutter/material.dart';

import 'common.dart';

//仅支持iOS
class BasicSettingKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dokit_setting;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_SETTING;
  }

  @override
  void tabAction() {
    DoraemonkitCsx.openSettingPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
