import 'icon_replance_csx_platform_interface.dart';
import 'icon_replance_model.dart';

class IconReplanceCsx {
  Future<String?> getPlatformVersion() {
    return IconReplanceCsxPlatform.instance.getPlatformVersion();
  }

  //移除替换icon带来的系统弹窗
  //only support ios
  Future<bool?> removeSysAlert() {
    return IconReplanceCsxPlatform.instance.removeSysAlert();
  }

  //恢复替换icon更换的系统弹窗方法替换
  //only support ios
  Future<bool?> resetSysAlert() {
    return IconReplanceCsxPlatform.instance.resetSysAlert();
  }

  //传null表示使用默认icon
  Future<EditIconBackModel?> changeIcon(
    String? iconName, {
    // 安卓需要知道其他所有的别名(第一个是默认)，iOS不需要设置
    List<String>? aliasNames,
    // 安卓是否是立即更换，默认false：当应用进入后台时更换（因为更换入口会导致应用退出（非闪退），且有些设备更换需要时间）
    bool changeNow = false,
  }) {
    return IconReplanceCsxPlatform.instance.changeIcon(
      iconName,
      aliasNames: aliasNames,
      changeNow: changeNow,
    );
  }

  //当前icon名称, null表示默认icon
  //only support ios
  Future<String?> nowIconName() {
    throw IconReplanceCsxPlatform.instance.nowIconName();
  }
}
