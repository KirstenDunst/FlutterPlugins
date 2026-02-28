/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:42:11
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-19 17:13:47
 * @Description: 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'common.dart';

class BasicLocationsKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_gps_mock.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseLocation;
  }

  @override
  Widget createDisplayPage() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'MyLocationPlatformView',
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'MyLocationPlatformView',
      );
    }
    return Text('platform is not yet supported by this plugin');
  }
}