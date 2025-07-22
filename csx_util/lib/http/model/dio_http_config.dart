import '../util/dio_error_handler.dart';

///http配置
/// [collectException] 异常是否加入统一的异常流
class HttpConfig {
  //可筛选基础url字典：<展示名称：对应baseUrl>
  final Map<String, String> baseUrlMap;
  //本地没有默认设置的url
  final String defaultBaseUrl;
  final Duration? connectTimeout;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
  final bool collectException;
  final DioErrorHandler errorHandler;

  const HttpConfig({
    required this.baseUrlMap,
    required this.defaultBaseUrl,
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
    this.collectException = true,
    this.errorHandler = const DefaultDioErrorHandler(),
  });

  @override
  String toString() {
    return 'HttpConfig{baseUrlMap: $baseUrlMap, connectTimeout: $connectTimeout, sendTimeout: $sendTimeout, receiveTimeout: $receiveTimeout, collectException: $collectException, errorHandler: $errorHandler}';
  }
}

class ErrorModel {
  final String sendTimeout;
  final String connectionTimeout;
  final String receiveTimeout;
  final String cancel;
  final String badCertificate;
  final String connectionError;
  final String unknown400;
  final String unknown401;
  final String unknown402;
  final String unknown403;
  final String unknown404;
  final String unknown500;
  final String unknown501;
  final String unknown502;
  final String unknown503;
  final String unknown504;
  final String other;
  final String socketException;
  final String handshakeException;
  final String linkBreak;

  const ErrorModel({
    this.sendTimeout = '网络发送超时，请检查网络后重试',
    this.connectionTimeout = '网络连接超时，请检查网络后重试',
    this.receiveTimeout = '网络请求超时，请检查网络后重试',
    this.cancel = '网络请求已取消',
    this.badCertificate = '服务器证书验证失败，请联系客服',
    this.connectionError = '网络连接异常，请检查网络后重试',
    this.unknown400 = '请求参数错误',
    this.unknown401 = '登录已过期',
    this.unknown402 = '登录已过期',
    this.unknown403 = '没有访问权限',
    this.unknown404 = '服务器异常，请稍候重试',
    this.unknown500 = '服务器故障，请联系客服',
    this.unknown501 = '服务未实现',
    this.unknown502 = '网关请求失败，请稍后重试',
    this.unknown503 = '服务不可用，请稍后重试',
    this.unknown504 = '网关请求超时，请稍后重试',
    this.other = '网络请求失败，请稍后重试',
    this.socketException = '网络连接异常，请检查网络后重试！',
    this.handshakeException = '网络证书异常，请到手机设置中找到日期和时间，\n打开自动设置,使用网络上的时间和时区',
    this.linkBreak = '网络连接断开，请检查网络！',
  });

  static ErrorModel normal = ErrorModel();
}
