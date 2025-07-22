import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../model/wrapped_response.dart';
import '../util/dio_http_util.dart';

///响应结果拦截器
///统一Dio异常处理
class DioResponseInterceptor extends Interceptor {
  final String? tag;

  DioResponseInterceptor({this.tag});

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var wrapped = response.requestOptions.extra['wrapped'];
    if (wrapped != true) {
      super.onResponse(response, handler);
      return;
    }

    var collectException = response.requestOptions.extra['collectException'];
    var wrappedResponse = WrappedResponse.fromJson(response.data);
    if (collectException != false && wrappedResponse.success != true) {
      DioHttpUtil(tag: tag).businessExceptionStream.add(wrappedResponse);
    }
    response.data = wrappedResponse;
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    var wrapped = err.requestOptions.extra['wrapped'];
    if (wrapped != true) {
      super.onError(err, handler);
      return;
    }
    var collectException = err.requestOptions.extra['collectException'];
    try {
      ///首先按照预定义wrapper格式解析异常信息
      var wrappedResponse = WrappedResponse.fromJson(err.response?.data);
      if (wrappedResponse.msg == null || wrappedResponse.msg!.isEmpty) {
        ///服务器返回的异常信息为空，按照默认逻辑解析异常message
        wrappedResponse.msg = DioHttpUtil(
          tag: tag,
        ).httpConfig.errorHandler.parseErrorMessage(err);
      }
      if (collectException != false) {
        DioHttpUtil(tag: tag).httpExceptionStream.add(wrappedResponse);
      }
      err.response?.data = wrappedResponse;
    } catch (e, stack) {
      ///出现异常后，按照默认逻辑解析异常信息
      debugPrint('DioResponseInterceptor, onError $e, $stack');
      var wrappedResponse = WrappedResponse(
        code: err.response?.statusCode,
        success: false,
        msg: DioHttpUtil(
          tag: tag,
        ).httpConfig.errorHandler.parseErrorMessage(err),
      );
      if (err.response == null) {
        err = err.copyWith(
          response: Response(
            data: wrappedResponse,
            requestOptions: err.requestOptions,
          ),
        );
      } else {
        err.response?.data = wrappedResponse;
      }
      if (collectException != false) {
        DioHttpUtil(tag: tag).httpExceptionStream.add(wrappedResponse);
      }
    }
    super.onError(err, handler);
  }
}
