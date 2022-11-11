/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:32:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-07-26 10:26:54
 * @Description: 返回的模型接收
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

class ResultBase {
  //是否操作成功，
  bool success;
  //如果失败，失败的具体信息
  String errorDescri;
  ResultBase({this.success = false, this.errorDescri = ''});

  static fromJson(Map json) {
    return ResultBase(
      success: json['success'] ?? false,
      errorDescri: json['errorDescri'] ?? '');
  }

  Map toJson() {
    var data = <String, dynamic>{};
    data['success'] = success;
    data['errorDescri'] = errorDescri;
    return data;
  }
}

class GetHealthData {
  ResultBase resultBase;
  dynamic result;
  GetHealthData({required this.resultBase, this.result});

  static fromJson(Map json) =>
      GetHealthData(resultBase: json['resultBase'], result: json['result']);

  Map toJson() {
    var data = <String, dynamic>{};
    data['resultBase'] = resultBase.toJson();
    data['result'] = result;
    return data;
  }
}
