/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 14:59:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 14:38:08
 * @Description: 
 */
import 'package:flutter/material.dart';

import '../channel/common/common_channel.dart';
import 'common.dart';

//仅支持安卓
class BasicDevOptionsKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_kit_devlop.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseDevoptions;
  }

  @override
  void tabAction() {
    DoraemonkitCsx.openAndroidDeveloperOptions();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
