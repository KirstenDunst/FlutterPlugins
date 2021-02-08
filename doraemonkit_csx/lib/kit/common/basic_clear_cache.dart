/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:45:22
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-08 15:41:34
 * @Description: 
 */

import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class BasicClearCacheKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_data_clean;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_CLEARCACHE;
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
