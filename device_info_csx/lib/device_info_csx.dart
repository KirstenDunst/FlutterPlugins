
import 'dart:async';

import 'package:flutter/services.dart';

class DeviceInfoCsx {
  static const MethodChannel _channel =
      const MethodChannel('device_info_csx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
