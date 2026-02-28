/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 11:38:17
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 15:22:35
 * @Description: 
 */
import 'package:flutter/material.dart';

import '../channel/common/common_channel.dart';
import 'common.dart';

//仅支持iOS
class BasicSettingKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dokit_setting.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseSetting;
  }

  @override
  void tabAction() {
    DoraemonkitCsx.openiOSSettingPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
