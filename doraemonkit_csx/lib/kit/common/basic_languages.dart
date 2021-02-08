/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 14:59:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 15:22:27
 * @Description: 
 */
import 'package:doraemonkit_csx/channel/common/common_channel.dart';
import 'package:doraemonkit_csx/resource/assets.dart';
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
    DoKitCommonCsx.openLocalLanguagesPage();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
