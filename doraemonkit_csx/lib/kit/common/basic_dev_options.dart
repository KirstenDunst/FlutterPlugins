/*
 * @Author: Cao Shixin
 * @Date: 2021-02-05 14:59:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 14:38:08
 * @Description: 
 */
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/doraemonkit_csx.dart';
import 'package:flutter/material.dart';

import 'common.dart';

//仅支持安卓
class BasicDevOptionsKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_kit_devlop;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_DEVOPTIONS;
  }

  @override
  void tabAction() {
    DoKitCommonCsx.openDeveloperOptions();
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
