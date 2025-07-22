import 'dart:io';
import 'package:dio/dio.dart';
import '../model/dio_http_config.dart';
import 'dio_http_util.dart';

abstract class DioErrorHandler {
  const DioErrorHandler();

  ///根据异常解析并映射异常信息
  String parseErrorMessage(DioException error, {String? tag});
}

extension DioErrorExt on DioException {
  int get code => response?.statusCode ?? -1;
}

///默认实现
class DefaultDioErrorHandler extends DioErrorHandler {
  const DefaultDioErrorHandler() : super();

  @override
  String parseErrorMessage(DioException err, {String? tag}) {
    var errorModel = DioHttpUtil(tag: tag).errorModel;
    switch (err.type) {
      case DioExceptionType.sendTimeout:
        return errorModel.sendTimeout;
      case DioExceptionType.connectionTimeout:
        return errorModel.connectionTimeout;
      case DioExceptionType.receiveTimeout:
        return errorModel.receiveTimeout;
      case DioExceptionType.cancel:
        return errorModel.cancel;
      case DioExceptionType.badResponse:
        return _parseHttpCodeMessage(err.code, errorModel);
      case DioExceptionType.unknown:
        return err.code > -1
            ? _parseHttpCodeMessage(err.code, errorModel)
            : _parseOtherMessage(err, errorModel);
      case DioExceptionType.badCertificate:
        return errorModel.badCertificate;
      case DioExceptionType.connectionError:
        return errorModel.connectionError;
    }
  }

  String _parseHttpCodeMessage(int code, ErrorModel errorModel) {
    switch (code) {
      case 400:
        return errorModel.unknown400;
      case 401:
        return errorModel.unknown401;
      case 402:
        return errorModel.unknown402;
      case 403:
        return errorModel.unknown403;
      case 404:
        return errorModel.unknown404;
      case 500:
        return errorModel.unknown500;
      case 501:
        return errorModel.unknown501;
      case 502:
        return errorModel.unknown502;
      case 503:
        return errorModel.unknown503;
      case 504:
        return errorModel.unknown504;
      default:
        return errorModel.other;
    }
  }

  ///DioExceptionType.other类型，异常解析
  ///目前只处理了[SocketException] [HandshakeException]两种异常
  ///需要处理其他异常，可以在此处扩展
  String _parseOtherMessage(DioException err, ErrorModel errorModel) {
    var message = err.message ?? err.error.toString();
    if (err.error is SocketException) {
      message = errorModel.socketException;
    } else if (err.error is HandshakeException) {
      message = errorModel.handshakeException;
    }
    if (message.contains(
          'HttpException: Connection closed while receiving data',
        ) ||
        message.contains('SocketException: Failed host lookup')) {
      message = errorModel.linkBreak;
    }
    return message;
  }
}
