
import 'dart:async';

import 'package:flutter/services.dart';

class DoraemonkitCsx {
  static const MethodChannel _channel =
      const MethodChannel('doraemonkit_csx');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
