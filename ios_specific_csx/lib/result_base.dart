/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:32:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-29 09:15:30
 * @Description: 返回的模型接收
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

class ResultBase {
  //是否操作成功，
  bool success;
  //如果失败，失败的具体信息
  String errorDescri;
  ResultBase({this.success, this.errorDescri});

  ResultBase.fromJson(Map json) {
    success = json['success'] ?? false;
    errorDescri = json['errorDescri'];
  }

  Map toJson() {
    var data = <String, dynamic>{};
    data['success'] = success;
    data['errorDescri'] = errorDescri;
    return data;
  }
}
