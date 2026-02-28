import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'common_platform_interface.dart';

/// An implementation of [DoraemonkitCsxPlatform] that uses method channels.
class MethodChannelDoraemonkitCsx extends DoraemonkitCsxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doraemonkit_csx');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<Map> getUserDefaults() async {
    final Map result = await methodChannel.invokeMethod('getUserDefaults');
    return result;
  }

  @override
  Future setUserDefault(Map<String, dynamic> tempJson) async {
    await methodChannel.invokeMethod('setUserDefault', tempJson);
  }

  @override
  Future<bool> openiOSSettingPage() async {
    var result = await methodChannel.invokeMethod('openSettingPage');
    return result;
  }

  @override
  Future openAndroidDeveloperOptions() async {
    await methodChannel.invokeMethod('openDeveloperOptions');
  }

  @override
  Future<bool> openAndroidLocalLanguagesPage() async {
    var result = await methodChannel.invokeMethod('openLocalLanguagesPage');
    return result;
  }
}
