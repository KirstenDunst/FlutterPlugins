import 'icon_replance_csx_platform_interface.dart';
import 'icon_replance_model.dart';

class IconReplanceCsx {
  Future<String?> getPlatformVersion() {
    return IconReplanceCsxPlatform.instance.getPlatformVersion();
  }

  Future<bool?> removeSysAlert() {
    return IconReplanceCsxPlatform.instance.removeSysAlert();
  }

  Future<bool?> resetSysAlert() {
    return IconReplanceCsxPlatform.instance.resetSysAlert();
  }

  //传null表示使用默认icon
  Future<EditIconBackModel?> changeIcon(String? iconName) {
    return IconReplanceCsxPlatform.instance.changeIcon(iconName);
  }

  //当前icon名称, null表示默认icon
  Future<String?> nowIconName() {
    throw IconReplanceCsxPlatform.instance.nowIconName();
  }
}
