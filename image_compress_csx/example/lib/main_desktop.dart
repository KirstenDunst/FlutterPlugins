/*
 * @Author: Cao Shixin
 * @Date: 2020-10-15 02:38:18
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-06 17:08:47
 * @Description: 
 */
import 'package:flutter/foundation.dart';
import 'package:image_compress_csx/image_compress_csx.dart';

import 'main.dart' as m;

main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  ImageCompressCsx.validator.ignoreCheckSupportPlatform = true;
  m.main();
}
