import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'icon_replance_csx_platform_interface.dart';
import 'icon_replance_model.dart';

/// An implementation of [IconReplanceCsxPlatform] that uses method channels.
class MethodChannelIconReplanceCsx extends IconReplanceCsxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('icon_replance_csx');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<EditIconBackModel?> changeIcon(String? iconName) async {
    final back = await methodChannel.invokeMethod<Map>('changeIcon', iconName);
    return back == null ? null : EditIconBackModel.fromJson(back);
  }

  //利用runtime移除替换icon带来的系统弹窗
  @override
  Future<bool?> removeSysAlert() async {
    final result = await methodChannel.invokeMethod<bool>('removeSystemAlert');
    return result;
  }

  //恢复runtime替换icon更换的系统弹窗方法替换
  @override
  Future<bool?> resetSysAlert() async {
    final result = await methodChannel.invokeMethod<bool>('resetSystemAlert');
    return result;
  }
}
