/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:46:39
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-20 13:09:39
 * @Description: 
 */
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class BasicFileSyncKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_db_view;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_FILESYNC;
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
