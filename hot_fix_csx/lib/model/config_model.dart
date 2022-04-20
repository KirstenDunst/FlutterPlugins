/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 13:32:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 10:06:53
 * @Description: 本地存储校验的config.json内部key键使用
 */
import 'package:hot_fix_csx/constant/enum.dart';

class ConfigModel {
  //当前版本号，留作版本升级的时候清理使用
  String appVersion;
  //当前可用资源的的类型
  int currentValidResource;
  HotFixValidResource get currentValidResourceType =>
      {
        0: HotFixValidResource.base,
        1: HotFixValidResource.fix,
        2: HotFixValidResource.fixTmp
      }[currentValidResource] ??
      HotFixValidResource.base;
  //记录是否是第一次加载
  bool isFirst;
  //记录上一次进行热更新的时间
  String lastHotfixTime;

  ConfigModel(this.appVersion, this.currentValidResource, this.isFirst,
      this.lastHotfixTime);

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        json['appVersion'] ?? '',
        json['currentValidResource'] ?? 0,
        json['isFirst'] ?? true,
        json['lastHotfixTime'] ?? '',
      );

  Map toJson() {
    var data = <String, dynamic>{};
    data['appVersion'] = appVersion;
    data['currentValidResource'] = currentValidResource;
    data['isFirst'] = isFirst;
    data['lastHotfixTime'] = lastHotfixTime;
    return data;
  }
}

class UnArchiveModel {
  String dirName;
  HotFixValidResource preRecourceType;
  UnArchiveModel({required this.dirName, required this.preRecourceType});
}

class CheckResultModel {
  bool checkIsComplete;
  Error? checkError;
  CheckResultModel({required this.checkIsComplete, this.checkError});
}
