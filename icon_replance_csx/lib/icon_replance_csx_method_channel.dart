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
  Future<EditIconBackModel?> changeIcon(
    String? iconName, {
    // 安卓需要知道其他所有的别名(第一个是默认)，iOS不需要设置
    List<String>? aliasNames,
    // 安卓是否是立即更换，默认false：当应用进入后台时更换（因为更换入口会导致应用退出（非闪退），且有些设备更换需要时间）
    bool changeNow = false,
  }) async {
    final back = await methodChannel.invokeMethod<Map>('changeIcon', {
      "iconName": iconName,
      "aliasNames": aliasNames,
      "changeNow": changeNow,
    });
    return back == null ? null : EditIconBackModel.fromJson(back);
  }

  //移除替换icon带来的系统弹窗
  //only support ios
  @override
  Future<bool?> removeSysAlert() async {
    final result = await methodChannel.invokeMethod<bool>('removeSystemAlert');
    return result;
  }

  //恢复替换icon更换的系统弹窗方法替换
  //only support ios
  @override
  Future<bool?> resetSysAlert() async {
    final result = await methodChannel.invokeMethod<bool>('resetSystemAlert');
    return result;
  }

  //当前icon名称, null表示默认icon
  //only support ios
  @override
  Future<String?> nowIconName() async {
    final result = await methodChannel.invokeMethod<String?>('nowIconName');
    return result;
  }
}
