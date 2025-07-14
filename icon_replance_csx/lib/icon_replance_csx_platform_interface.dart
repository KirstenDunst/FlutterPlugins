import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'icon_replance_csx_method_channel.dart';
import 'icon_replance_model.dart';

abstract class IconReplanceCsxPlatform extends PlatformInterface {
  /// Constructs a IconReplanceCsxPlatform.
  IconReplanceCsxPlatform() : super(token: _token);

  static final Object _token = Object();

  static IconReplanceCsxPlatform _instance = MethodChannelIconReplanceCsx();

  /// The default instance of [IconReplanceCsxPlatform] to use.
  ///
  /// Defaults to [MethodChannelIconReplanceCsx].
  static IconReplanceCsxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IconReplanceCsxPlatform] when
  /// they register themselves.
  static set instance(IconReplanceCsxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  //传null表示使用默认icon
  Future<EditIconBackModel?> changeIcon(
    String? iconName, {
    // 安卓需要知道其他所有的别名(第一个是默认)，iOS不需要设置
    List<String>? aliasNames,
    // 安卓是否是立即更换，默认false：当应用进入后台时更换（因为更换入口会导致应用退出（非闪退），且有些设备更换需要时间）
    bool changeNow = false,
  }) {
    throw UnimplementedError('changeIcon() has not been implemented.');
  }

  //移除替换icon带来的系统弹窗
  //only support ios
  Future<bool?> removeSysAlert() {
    throw UnimplementedError('removeSysAlert() has not been implemented.');
  }

  //恢复替换icon更换的系统弹窗方法替换
  //only support ios
  Future<bool?> resetSysAlert() {
    throw UnimplementedError('resetSysAlert() has not been implemented.');
  }

  //当前icon名称, null表示默认icon
  //only support ios
  Future<String?> nowIconName() {
    throw UnimplementedError('nowIconName() has not been implemented.');
  }
}
