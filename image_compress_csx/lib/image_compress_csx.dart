
import 'dart:async';

import 'package:flutter/services.dart';

class ImageCompressCsx {
  static const MethodChannel _channel =
      const MethodChannel('image_compress_csx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
