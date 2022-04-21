/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 13:32:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 17:17:03
 * @Description: 本地存储校验的config.json内部key键使用
 */
class ConfigModel {
  //当前版本号，留作版本升级的时候清理使用
  String appVersion;
  //记录是否是第一次加载
  bool isFirst;
  //记录上一次进行热更新的时间
  String lastHotfixTime;

  ConfigModel(this.appVersion, this.isFirst, this.lastHotfixTime);

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        json['appVersion'] ?? '',
        json['isFirst'] ?? true,
        json['lastHotfixTime'] ?? '',
      );

  Map toJson() {
    var data = <String, dynamic>{};
    data['appVersion'] = appVersion;
    data['isFirst'] = isFirst;
    data['lastHotfixTime'] = lastHotfixTime;
    return data;
  }
}

class CheckResultModel {
  bool checkIsComplete;
  Error? checkError;
  CheckResultModel({required this.checkIsComplete, this.checkError});
}
