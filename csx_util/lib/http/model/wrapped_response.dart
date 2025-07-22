class WrappedResponse<T> {
  //有字符串和int两种返回
  dynamic code;
  bool? success;
  String? msg;
  T? data;

  WrappedResponse({required this.code, this.success, this.msg, this.data});

  ///创建异常信息wrapper的工厂方法
  factory WrappedResponse.error({
    dynamic code,
    bool? success,
    String? message,
    T? data,
  }) {
    return WrappedResponse(
      code: code ?? -1,
      success: success ?? false,
      msg: message,
      data: data,
    );
  }

  WrappedResponse.fromJson(Map<String, dynamic> json)
    : code = json['code'] is String
          ? int.parse((json['code'] as String))
          : (json['code'] as num).toInt(),
      success = (json['success'] as bool?) ?? false,
      msg = json['msg'] as String?,
      data = json['data'] as T?;

  @override
  String toString() {
    return 'WrappedResponse{code: $code, success: $success, msg: $msg, data: $data}';
  }
}
