import 'dart:math';

import 'package:dio/dio.dart';

import '../apm.dart';
import '../apm/http_kit_dio.dart';

class AppLogInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = generateRequestId();
    options.extra["requestId"] = requestId;
    var httpInfo = HttpInfo1(options.uri, options.method, requestId);
    httpInfo.request = HttpRequest(
      header: options.headers,
      queryParameters: options.queryParameters,
      body: options.data,
    );
    final kit = ApmKitManager.instance.getKit(ApmKitName.kitHttp);
    kit?.save(httpInfo);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra["requestId"];
    _filterByRequestId(requestId, (httpInfo) {
      httpInfo?.response = HttpResponse(
        statusCode: response.statusCode,
        data: response.data,
        header: response.headers.map,
      );
    });
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra["requestId"];
    _filterByRequestId(requestId, (httpInfo) {
      httpInfo?.error = err.message;
    });
    handler.next(err);
  }

  void _filterByRequestId(String requestId, Function(HttpInfo1?) eventDeal) {
    var kit = ApmKitManager.instance.getKit<HttpKit>(ApmKitName.kitHttp);
    var filterArr = kit?.storage.getAll().where(
      (e) => (e as HttpInfo1).requestId == requestId,
    );
    HttpInfo1? httpInfo1;
    if (filterArr?.isNotEmpty ?? false) {
      httpInfo1 = filterArr!.first as HttpInfo1?;
    }
    eventDeal.call(httpInfo1);
    kit?.listener?.call();
  }
}

String generateRequestId() {
  return DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(999999999).toString();
}
