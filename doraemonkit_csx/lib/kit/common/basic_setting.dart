/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 11:38:17
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 15:22:35
 * @Description: 
 */
import 'package:doraemonkit_csx/channel/common/common_channel.dart';
import 'package:doraemonkit_csx/resource/assets.dart';
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
    DoKitCommonCsx.openSettingPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
