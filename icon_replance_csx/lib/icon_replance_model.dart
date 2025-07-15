class EditIconBackModel {
  bool? isSuccess;
  String? errorMsg;
  //错误代码：1:版本低于10.3不支持  2:系统检测不支持修改icon  3:操作未知错误，详细见errorMsg
  int? errorCode;
  EditIconBackModel(this.isSuccess, this.errorCode, this.errorMsg);
  factory EditIconBackModel.fromJson(Map? json) => EditIconBackModel(
        json?['isSuccess'] ?? false,
        json?["errorCode"],
        json?["msg"] ?? '',
      );

  Map toJson() => {
        "isSuccess": isSuccess,
        "errorCode": errorCode,
        "errorMsg": errorMsg,
      };
}
