/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:44:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 13:47:58
 * @Description: 
 */
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class BasicH5Kit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_web_door;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_H5;
  }

  @override
  Widget createDisplayPage() {
    return Container();
  }
}
